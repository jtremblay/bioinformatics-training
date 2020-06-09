#!/bin/bash

#-------------------------------------------------------------------------------
# PipelineExample SlurmScheduler Job Submission Bash script
# Created on: 2020-06-09 15:13:56.592481
# Steps:
#   trim: 12 jobs
#   remove_contam: 13 jobs
#   TOTAL: 25 jobs
#-------------------------------------------------------------------------------

OUTPUT_DIR=/home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project
JOB_OUTPUT_DIR=$OUTPUT_DIR/job_output
TIMESTAMP=`date +%FT%H.%M.%S`
JOB_LIST=$JOB_OUTPUT_DIR/PipelineExample_job_list_$TIMESTAMP
mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

#-------------------------------------------------------------------------------
# STEP: trim
#-------------------------------------------------------------------------------
STEP=trim
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: trim_1_JOB_ID: trimmomatic_Microbial_Mock_Community_Even_C
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic_Microbial_Mock_Community_Even_C
JOB_DEPENDENCIES=
JOB_DONE=job_output/trim/trimmomatic_Microbial_Mock_Community_Even_C.ebab8f4e45f3b5c8bcc975fa8e227ab9.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_1_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/java/jdk1.8.0_144 nrc/trimmomatic/0.39 && \

java -XX:ParallelGCThreads=6 -Xmx2G -jar \$TRIMMOMATIC_JAR PE \
  -threads 6 \
  -phred33 \
  /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Even_C_R1.fastq.gz /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Even_C_R2.fastq.gz \
  qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.pair1.fastq.gz qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.single1.fastq.gz qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.pair2.fastq.gz qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.single2.fastq.gz \
  ILLUMINACLIP:/project/6008026/databases/contaminants/adapters-nextera-xt-v2.fa:2:10:10 \
  TRAILING:30 \
  SLIDINGWINDOW:4:15 \
  MINLEN:45 \
  HEADCROP:16 \
  2> qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.out && \
grep ^Input qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.out | perl -pe 's/^Input Read Pairs: (\d+).*Both Surviving: (\d+).*Forward Only Surviving: (\d+).*$/Raw Fragments,\1\nFragment Surviving,\2\nSingle Surviving,\3/' > qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.stats.csv
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=32000 -N 1 -n 6  | grep -o "[0-9]*")
echo "$trim_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_2_JOB_ID: create_interleaved_fastq_Microbial_Mock_Community_Even_C
#-------------------------------------------------------------------------------
JOB_NAME=create_interleaved_fastq_Microbial_Mock_Community_Even_C
JOB_DEPENDENCIES=$trim_1_JOB_ID
JOB_DONE=job_output/trim/create_interleaved_fastq_Microbial_Mock_Community_Even_C.cb19819f942913d610071050e2bbd6dc.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_2_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev nrc/pigz/2.3.4 && \

createInterleavedFastq.pl \
  --reads1 qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.pair1.fastq.gz \
  --reads2 qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.pair2.fastq.gz \
  > qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.interleaved.fastq && pigz -p 6 -f qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.interleaved.fastq
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=3000 -N 1 -n 6  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$trim_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_3_JOB_ID: trimmomatic_Microbial_Mock_Community_Straggered_A
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic_Microbial_Mock_Community_Straggered_A
JOB_DEPENDENCIES=
JOB_DONE=job_output/trim/trimmomatic_Microbial_Mock_Community_Straggered_A.d9d6b41e4d00f85cee397a65fdd02820.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_3_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/java/jdk1.8.0_144 nrc/trimmomatic/0.39 && \

java -XX:ParallelGCThreads=6 -Xmx2G -jar \$TRIMMOMATIC_JAR PE \
  -threads 6 \
  -phred33 \
  /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Straggered_A_R1.fastq.gz /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Straggered_A_R2.fastq.gz \
  qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.pair1.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.single1.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.pair2.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.single2.fastq.gz \
  ILLUMINACLIP:/project/6008026/databases/contaminants/adapters-nextera-xt-v2.fa:2:10:10 \
  TRAILING:30 \
  SLIDINGWINDOW:4:15 \
  MINLEN:45 \
  HEADCROP:16 \
  2> qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.out && \
grep ^Input qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.out | perl -pe 's/^Input Read Pairs: (\d+).*Both Surviving: (\d+).*Forward Only Surviving: (\d+).*$/Raw Fragments,\1\nFragment Surviving,\2\nSingle Surviving,\3/' > qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.stats.csv
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=32000 -N 1 -n 6  | grep -o "[0-9]*")
echo "$trim_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_4_JOB_ID: create_interleaved_fastq_Microbial_Mock_Community_Straggered_A
#-------------------------------------------------------------------------------
JOB_NAME=create_interleaved_fastq_Microbial_Mock_Community_Straggered_A
JOB_DEPENDENCIES=$trim_3_JOB_ID
JOB_DONE=job_output/trim/create_interleaved_fastq_Microbial_Mock_Community_Straggered_A.56dbb364bcbda62d7c4a4d97d7bf3b0a.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_4_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev nrc/pigz/2.3.4 && \

createInterleavedFastq.pl \
  --reads1 qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.pair1.fastq.gz \
  --reads2 qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.pair2.fastq.gz \
  > qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.interleaved.fastq && pigz -p 6 -f qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.interleaved.fastq
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=3000 -N 1 -n 6  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$trim_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_5_JOB_ID: trimmomatic_Microbial_Mock_Community_Straggered_C
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic_Microbial_Mock_Community_Straggered_C
JOB_DEPENDENCIES=
JOB_DONE=job_output/trim/trimmomatic_Microbial_Mock_Community_Straggered_C.325ee02ea8dc1653cf24c41af7bfe9ff.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_5_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/java/jdk1.8.0_144 nrc/trimmomatic/0.39 && \

java -XX:ParallelGCThreads=6 -Xmx2G -jar \$TRIMMOMATIC_JAR PE \
  -threads 6 \
  -phred33 \
  /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Straggered_C_R1.fastq.gz /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Straggered_C_R2.fastq.gz \
  qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.pair1.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.single1.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.pair2.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.single2.fastq.gz \
  ILLUMINACLIP:/project/6008026/databases/contaminants/adapters-nextera-xt-v2.fa:2:10:10 \
  TRAILING:30 \
  SLIDINGWINDOW:4:15 \
  MINLEN:45 \
  HEADCROP:16 \
  2> qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.out && \
grep ^Input qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.out | perl -pe 's/^Input Read Pairs: (\d+).*Both Surviving: (\d+).*Forward Only Surviving: (\d+).*$/Raw Fragments,\1\nFragment Surviving,\2\nSingle Surviving,\3/' > qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.stats.csv
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=32000 -N 1 -n 6  | grep -o "[0-9]*")
echo "$trim_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_6_JOB_ID: create_interleaved_fastq_Microbial_Mock_Community_Straggered_C
#-------------------------------------------------------------------------------
JOB_NAME=create_interleaved_fastq_Microbial_Mock_Community_Straggered_C
JOB_DEPENDENCIES=$trim_5_JOB_ID
JOB_DONE=job_output/trim/create_interleaved_fastq_Microbial_Mock_Community_Straggered_C.2095ae4af51301b2f4dab7ec8f1ab1f4.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_6_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev nrc/pigz/2.3.4 && \

createInterleavedFastq.pl \
  --reads1 qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.pair1.fastq.gz \
  --reads2 qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.pair2.fastq.gz \
  > qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.interleaved.fastq && pigz -p 6 -f qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.interleaved.fastq
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=3000 -N 1 -n 6  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$trim_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_7_JOB_ID: trimmomatic_Microbial_Mock_Community_Even_B
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic_Microbial_Mock_Community_Even_B
JOB_DEPENDENCIES=
JOB_DONE=job_output/trim/trimmomatic_Microbial_Mock_Community_Even_B.dc9b3641fc165d22c3b16bd18cb650b6.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_7_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/java/jdk1.8.0_144 nrc/trimmomatic/0.39 && \

java -XX:ParallelGCThreads=6 -Xmx2G -jar \$TRIMMOMATIC_JAR PE \
  -threads 6 \
  -phred33 \
  /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Even_B_R1.fastq.gz /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Even_B_R2.fastq.gz \
  qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.pair1.fastq.gz qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.single1.fastq.gz qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.pair2.fastq.gz qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.single2.fastq.gz \
  ILLUMINACLIP:/project/6008026/databases/contaminants/adapters-nextera-xt-v2.fa:2:10:10 \
  TRAILING:30 \
  SLIDINGWINDOW:4:15 \
  MINLEN:45 \
  HEADCROP:16 \
  2> qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.out && \
grep ^Input qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.out | perl -pe 's/^Input Read Pairs: (\d+).*Both Surviving: (\d+).*Forward Only Surviving: (\d+).*$/Raw Fragments,\1\nFragment Surviving,\2\nSingle Surviving,\3/' > qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.stats.csv
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=32000 -N 1 -n 6  | grep -o "[0-9]*")
echo "$trim_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_8_JOB_ID: create_interleaved_fastq_Microbial_Mock_Community_Even_B
#-------------------------------------------------------------------------------
JOB_NAME=create_interleaved_fastq_Microbial_Mock_Community_Even_B
JOB_DEPENDENCIES=$trim_7_JOB_ID
JOB_DONE=job_output/trim/create_interleaved_fastq_Microbial_Mock_Community_Even_B.7831026aff7d4cd8f987b8795c893cdd.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_8_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev nrc/pigz/2.3.4 && \

createInterleavedFastq.pl \
  --reads1 qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.pair1.fastq.gz \
  --reads2 qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.pair2.fastq.gz \
  > qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.interleaved.fastq && pigz -p 6 -f qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.interleaved.fastq
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=3000 -N 1 -n 6  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$trim_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_9_JOB_ID: trimmomatic_Microbial_Mock_Community_Even_A
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic_Microbial_Mock_Community_Even_A
JOB_DEPENDENCIES=
JOB_DONE=job_output/trim/trimmomatic_Microbial_Mock_Community_Even_A.705c5371b0ee78515a09f8a5d58233a7.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_9_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/java/jdk1.8.0_144 nrc/trimmomatic/0.39 && \

java -XX:ParallelGCThreads=6 -Xmx2G -jar \$TRIMMOMATIC_JAR PE \
  -threads 6 \
  -phred33 \
  /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Even_A_R1.fastq.gz /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Even_A_R2.fastq.gz \
  qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.pair1.fastq.gz qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.single1.fastq.gz qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.pair2.fastq.gz qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.single2.fastq.gz \
  ILLUMINACLIP:/project/6008026/databases/contaminants/adapters-nextera-xt-v2.fa:2:10:10 \
  TRAILING:30 \
  SLIDINGWINDOW:4:15 \
  MINLEN:45 \
  HEADCROP:16 \
  2> qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.out && \
grep ^Input qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.out | perl -pe 's/^Input Read Pairs: (\d+).*Both Surviving: (\d+).*Forward Only Surviving: (\d+).*$/Raw Fragments,\1\nFragment Surviving,\2\nSingle Surviving,\3/' > qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.stats.csv
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=32000 -N 1 -n 6  | grep -o "[0-9]*")
echo "$trim_9_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_10_JOB_ID: create_interleaved_fastq_Microbial_Mock_Community_Even_A
#-------------------------------------------------------------------------------
JOB_NAME=create_interleaved_fastq_Microbial_Mock_Community_Even_A
JOB_DEPENDENCIES=$trim_9_JOB_ID
JOB_DONE=job_output/trim/create_interleaved_fastq_Microbial_Mock_Community_Even_A.68321134985bed2e565b8f8ceb2fc431.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_10_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev nrc/pigz/2.3.4 && \

createInterleavedFastq.pl \
  --reads1 qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.pair1.fastq.gz \
  --reads2 qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.pair2.fastq.gz \
  > qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.interleaved.fastq && pigz -p 6 -f qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.interleaved.fastq
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=3000 -N 1 -n 6  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$trim_10_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_11_JOB_ID: trimmomatic_Microbial_Mock_Community_Straggered_B
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic_Microbial_Mock_Community_Straggered_B
JOB_DEPENDENCIES=
JOB_DONE=job_output/trim/trimmomatic_Microbial_Mock_Community_Straggered_B.e352bf7033436832263ab213f33898a6.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_11_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/java/jdk1.8.0_144 nrc/trimmomatic/0.39 && \

java -XX:ParallelGCThreads=6 -Xmx2G -jar \$TRIMMOMATIC_JAR PE \
  -threads 6 \
  -phred33 \
  /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Straggered_B_R1.fastq.gz /home/jtrembla/build/bioinformatics-training/nrc_pipeline_example/mock_community_project/./raw_reads//Microbial_Mock_Community_Straggered_B_R2.fastq.gz \
  qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.pair1.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.single1.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.pair2.fastq.gz qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.single2.fastq.gz \
  ILLUMINACLIP:/project/6008026/databases/contaminants/adapters-nextera-xt-v2.fa:2:10:10 \
  TRAILING:30 \
  SLIDINGWINDOW:4:15 \
  MINLEN:45 \
  HEADCROP:16 \
  2> qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.out && \
grep ^Input qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.out | perl -pe 's/^Input Read Pairs: (\d+).*Both Surviving: (\d+).*Forward Only Surviving: (\d+).*$/Raw Fragments,\1\nFragment Surviving,\2\nSingle Surviving,\3/' > qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.stats.csv
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=32000 -N 1 -n 6  | grep -o "[0-9]*")
echo "$trim_11_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: trim_12_JOB_ID: create_interleaved_fastq_Microbial_Mock_Community_Straggered_B
#-------------------------------------------------------------------------------
JOB_NAME=create_interleaved_fastq_Microbial_Mock_Community_Straggered_B
JOB_DEPENDENCIES=$trim_11_JOB_ID
JOB_DONE=job_output/trim/create_interleaved_fastq_Microbial_Mock_Community_Straggered_B.1532bd34815efbac093562e8c89c426c.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
trim_12_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev nrc/pigz/2.3.4 && \

createInterleavedFastq.pl \
  --reads1 qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.pair1.fastq.gz \
  --reads2 qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.pair2.fastq.gz \
  > qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.interleaved.fastq && pigz -p 6 -f qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.interleaved.fastq
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 6:00:0  --mem=3000 -N 1 -n 6  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$trim_12_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# STEP: remove_contam
#-------------------------------------------------------------------------------
STEP=remove_contam
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: remove_contam_1_JOB_ID: bbduk_interleaved_Microbial_Mock_Community_Even_C
#-------------------------------------------------------------------------------
JOB_NAME=bbduk_interleaved_Microbial_Mock_Community_Even_C
JOB_DEPENDENCIES=$trim_2_JOB_ID
JOB_DONE=job_output/remove_contam/bbduk_interleaved_Microbial_Mock_Community_Even_C.6bc7f21c53f8a745660fb3eadf9f19dc.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_1_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/bbmap/38.11 && \

bbduk.sh \
  in=qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.trim.interleaved.fastq.gz \
  stats=qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.duk_contam_interleaved_log.txt \
  out=qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam.fastq.gz \
  outm=qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.contam.fastq \
  k=21 \
  minkmerhits=1 \
  ref=/project/6008026/databases/contaminants/Illumina.artifacts.fa \
  overwrite=true \
  threads=1
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_2_JOB_ID: remove_unpaired_and_split_Microbial_Mock_Community_Even_C
#-------------------------------------------------------------------------------
JOB_NAME=remove_unpaired_and_split_Microbial_Mock_Community_Even_C
JOB_DEPENDENCIES=$remove_contam_1_JOB_ID
JOB_DONE=job_output/remove_contam/remove_unpaired_and_split_Microbial_Mock_Community_Even_C.7e9fd52943368bd00df2a21adc68f3e3.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_2_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev && \

removeUnpairedReads.pl \
  --infile qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam.fastq.gz \
  --unpaired_reads1 qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_unpaired_R1.fastq \
  --unpaired_reads2 qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_unpaired_R2.fastq \
  > qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_paired.fastq && \
gzip -f qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_unpaired_R1.fastq && gzip -f qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_unpaired_R2.fastq && gzip -f qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_paired.fastq && \
splitPairsGz.pl \
  --infile qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_paired.fastq.gz \
  --outfile_1 qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_paired_R1.fastq.gz \
  --outfile_2 qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.ncontam_paired_R2.fastq.gz
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_3_JOB_ID: bbduk_interleaved_Microbial_Mock_Community_Straggered_A
#-------------------------------------------------------------------------------
JOB_NAME=bbduk_interleaved_Microbial_Mock_Community_Straggered_A
JOB_DEPENDENCIES=$trim_4_JOB_ID
JOB_DONE=job_output/remove_contam/bbduk_interleaved_Microbial_Mock_Community_Straggered_A.7b06299848d6f403195518f0c1cd9ed3.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_3_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/bbmap/38.11 && \

bbduk.sh \
  in=qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.trim.interleaved.fastq.gz \
  stats=qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.duk_contam_interleaved_log.txt \
  out=qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam.fastq.gz \
  outm=qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.contam.fastq \
  k=21 \
  minkmerhits=1 \
  ref=/project/6008026/databases/contaminants/Illumina.artifacts.fa \
  overwrite=true \
  threads=1
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_4_JOB_ID: remove_unpaired_and_split_Microbial_Mock_Community_Straggered_A
#-------------------------------------------------------------------------------
JOB_NAME=remove_unpaired_and_split_Microbial_Mock_Community_Straggered_A
JOB_DEPENDENCIES=$remove_contam_3_JOB_ID
JOB_DONE=job_output/remove_contam/remove_unpaired_and_split_Microbial_Mock_Community_Straggered_A.ca858ac0a673250a40b26c363a0fe576.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_4_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev && \

removeUnpairedReads.pl \
  --infile qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam.fastq.gz \
  --unpaired_reads1 qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_unpaired_R1.fastq \
  --unpaired_reads2 qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_unpaired_R2.fastq \
  > qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_paired.fastq && \
gzip -f qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_unpaired_R1.fastq && gzip -f qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_unpaired_R2.fastq && gzip -f qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_paired.fastq && \
splitPairsGz.pl \
  --infile qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_paired.fastq.gz \
  --outfile_1 qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_paired_R1.fastq.gz \
  --outfile_2 qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.ncontam_paired_R2.fastq.gz
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_5_JOB_ID: bbduk_interleaved_Microbial_Mock_Community_Straggered_C
#-------------------------------------------------------------------------------
JOB_NAME=bbduk_interleaved_Microbial_Mock_Community_Straggered_C
JOB_DEPENDENCIES=$trim_6_JOB_ID
JOB_DONE=job_output/remove_contam/bbduk_interleaved_Microbial_Mock_Community_Straggered_C.8d0d71723a7bae9889239bd06083f189.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_5_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/bbmap/38.11 && \

bbduk.sh \
  in=qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.trim.interleaved.fastq.gz \
  stats=qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.duk_contam_interleaved_log.txt \
  out=qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam.fastq.gz \
  outm=qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.contam.fastq \
  k=21 \
  minkmerhits=1 \
  ref=/project/6008026/databases/contaminants/Illumina.artifacts.fa \
  overwrite=true \
  threads=1
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_6_JOB_ID: remove_unpaired_and_split_Microbial_Mock_Community_Straggered_C
#-------------------------------------------------------------------------------
JOB_NAME=remove_unpaired_and_split_Microbial_Mock_Community_Straggered_C
JOB_DEPENDENCIES=$remove_contam_5_JOB_ID
JOB_DONE=job_output/remove_contam/remove_unpaired_and_split_Microbial_Mock_Community_Straggered_C.66ac939ad44a6abf21f33b1045f5ee22.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_6_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev && \

removeUnpairedReads.pl \
  --infile qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam.fastq.gz \
  --unpaired_reads1 qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_unpaired_R1.fastq \
  --unpaired_reads2 qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_unpaired_R2.fastq \
  > qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_paired.fastq && \
gzip -f qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_unpaired_R1.fastq && gzip -f qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_unpaired_R2.fastq && gzip -f qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_paired.fastq && \
splitPairsGz.pl \
  --infile qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_paired.fastq.gz \
  --outfile_1 qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_paired_R1.fastq.gz \
  --outfile_2 qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.ncontam_paired_R2.fastq.gz
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_7_JOB_ID: bbduk_interleaved_Microbial_Mock_Community_Even_B
#-------------------------------------------------------------------------------
JOB_NAME=bbduk_interleaved_Microbial_Mock_Community_Even_B
JOB_DEPENDENCIES=$trim_8_JOB_ID
JOB_DONE=job_output/remove_contam/bbduk_interleaved_Microbial_Mock_Community_Even_B.4df7c49f58aa39edc47679c500e956a1.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_7_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/bbmap/38.11 && \

bbduk.sh \
  in=qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.trim.interleaved.fastq.gz \
  stats=qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.duk_contam_interleaved_log.txt \
  out=qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam.fastq.gz \
  outm=qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.contam.fastq \
  k=21 \
  minkmerhits=1 \
  ref=/project/6008026/databases/contaminants/Illumina.artifacts.fa \
  overwrite=true \
  threads=1
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_8_JOB_ID: remove_unpaired_and_split_Microbial_Mock_Community_Even_B
#-------------------------------------------------------------------------------
JOB_NAME=remove_unpaired_and_split_Microbial_Mock_Community_Even_B
JOB_DEPENDENCIES=$remove_contam_7_JOB_ID
JOB_DONE=job_output/remove_contam/remove_unpaired_and_split_Microbial_Mock_Community_Even_B.67d9c53336ac845c3cac4eabed4439ef.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_8_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev && \

removeUnpairedReads.pl \
  --infile qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam.fastq.gz \
  --unpaired_reads1 qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_unpaired_R1.fastq \
  --unpaired_reads2 qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_unpaired_R2.fastq \
  > qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_paired.fastq && \
gzip -f qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_unpaired_R1.fastq && gzip -f qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_unpaired_R2.fastq && gzip -f qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_paired.fastq && \
splitPairsGz.pl \
  --infile qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_paired.fastq.gz \
  --outfile_1 qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_paired_R1.fastq.gz \
  --outfile_2 qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.ncontam_paired_R2.fastq.gz
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_9_JOB_ID: bbduk_interleaved_Microbial_Mock_Community_Even_A
#-------------------------------------------------------------------------------
JOB_NAME=bbduk_interleaved_Microbial_Mock_Community_Even_A
JOB_DEPENDENCIES=$trim_10_JOB_ID
JOB_DONE=job_output/remove_contam/bbduk_interleaved_Microbial_Mock_Community_Even_A.e0be857664ea8daa13e9f24d96c62dc4.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_9_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/bbmap/38.11 && \

bbduk.sh \
  in=qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.trim.interleaved.fastq.gz \
  stats=qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.duk_contam_interleaved_log.txt \
  out=qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam.fastq.gz \
  outm=qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.contam.fastq \
  k=21 \
  minkmerhits=1 \
  ref=/project/6008026/databases/contaminants/Illumina.artifacts.fa \
  overwrite=true \
  threads=1
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_9_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_10_JOB_ID: remove_unpaired_and_split_Microbial_Mock_Community_Even_A
#-------------------------------------------------------------------------------
JOB_NAME=remove_unpaired_and_split_Microbial_Mock_Community_Even_A
JOB_DEPENDENCIES=$remove_contam_9_JOB_ID
JOB_DONE=job_output/remove_contam/remove_unpaired_and_split_Microbial_Mock_Community_Even_A.5411eb516a1fd762ba2c239fe89fa884.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_10_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev && \

removeUnpairedReads.pl \
  --infile qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam.fastq.gz \
  --unpaired_reads1 qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_unpaired_R1.fastq \
  --unpaired_reads2 qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_unpaired_R2.fastq \
  > qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_paired.fastq && \
gzip -f qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_unpaired_R1.fastq && gzip -f qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_unpaired_R2.fastq && gzip -f qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_paired.fastq && \
splitPairsGz.pl \
  --infile qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_paired.fastq.gz \
  --outfile_1 qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_paired_R1.fastq.gz \
  --outfile_2 qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.ncontam_paired_R2.fastq.gz
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_10_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_11_JOB_ID: bbduk_interleaved_Microbial_Mock_Community_Straggered_B
#-------------------------------------------------------------------------------
JOB_NAME=bbduk_interleaved_Microbial_Mock_Community_Straggered_B
JOB_DEPENDENCIES=$trim_12_JOB_ID
JOB_DONE=job_output/remove_contam/bbduk_interleaved_Microbial_Mock_Community_Straggered_B.d6ca6d613a0c9fe32259b9ab6ee2af60.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_11_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/bbmap/38.11 && \

bbduk.sh \
  in=qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.trim.interleaved.fastq.gz \
  stats=qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.duk_contam_interleaved_log.txt \
  out=qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam.fastq.gz \
  outm=qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.contam.fastq \
  k=21 \
  minkmerhits=1 \
  ref=/project/6008026/databases/contaminants/Illumina.artifacts.fa \
  overwrite=true \
  threads=1
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_11_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_12_JOB_ID: remove_unpaired_and_split_Microbial_Mock_Community_Straggered_B
#-------------------------------------------------------------------------------
JOB_NAME=remove_unpaired_and_split_Microbial_Mock_Community_Straggered_B
JOB_DEPENDENCIES=$remove_contam_11_JOB_ID
JOB_DONE=job_output/remove_contam/remove_unpaired_and_split_Microbial_Mock_Community_Straggered_B.3ea3d42282a7e5ae23ad5ede0d72013f.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_12_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev && \

removeUnpairedReads.pl \
  --infile qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam.fastq.gz \
  --unpaired_reads1 qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_unpaired_R1.fastq \
  --unpaired_reads2 qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_unpaired_R2.fastq \
  > qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_paired.fastq && \
gzip -f qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_unpaired_R1.fastq && gzip -f qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_unpaired_R2.fastq && gzip -f qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_paired.fastq && \
splitPairsGz.pl \
  --infile qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_paired.fastq.gz \
  --outfile_1 qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_paired_R1.fastq.gz \
  --outfile_2 qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.ncontam_paired_R2.fastq.gz
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_12_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

#-------------------------------------------------------------------------------
# JOB: remove_contam_13_JOB_ID: merge_duk_logs
#-------------------------------------------------------------------------------
JOB_NAME=merge_duk_logs
JOB_DEPENDENCIES=$remove_contam_1_JOB_ID:$remove_contam_3_JOB_ID:$remove_contam_5_JOB_ID:$remove_contam_7_JOB_ID:$remove_contam_9_JOB_ID:$remove_contam_11_JOB_ID
JOB_DONE=job_output/remove_contam/merge_duk_logs.56ac8d02aceb007e1fe90460cb4f9580.nrc.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
remove_contam_13_JOB_ID=$(echo "#!/bin/sh
rm -f $JOB_DONE && \
set -o pipefail
module load nrc/nrc_tools/dev && \

mergeDukLogs.pl --logs qced_reads/Microbial_Mock_Community_Even_C/Microbial_Mock_Community_Even_C.duk_contam_interleaved_log.txt,qced_reads/Microbial_Mock_Community_Straggered_A/Microbial_Mock_Community_Straggered_A.duk_contam_interleaved_log.txt,qced_reads/Microbial_Mock_Community_Straggered_C/Microbial_Mock_Community_Straggered_C.duk_contam_interleaved_log.txt,qced_reads/Microbial_Mock_Community_Even_B/Microbial_Mock_Community_Even_B.duk_contam_interleaved_log.txt,qced_reads/Microbial_Mock_Community_Even_A/Microbial_Mock_Community_Even_A.duk_contam_interleaved_log.txt,qced_reads/Microbial_Mock_Community_Straggered_B/Microbial_Mock_Community_Straggered_B.duk_contam_interleaved_log.txt --ids Microbial_Mock_Community_Even_C,Microbial_Mock_Community_Straggered_A,Microbial_Mock_Community_Straggered_C,Microbial_Mock_Community_Even_B,Microbial_Mock_Community_Even_A,Microbial_Mock_Community_Straggered_B > ./qced_reads/duk_merged_logs.tsv
NRC_STATE=\$PIPESTATUS
echo NRC_exitStatus:\$NRC_STATE
if [ \$NRC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
exit \$NRC_STATE" | \
sbatch --account=rrg-jtrembla --export=ALL --mail-type=END --mail-user=$JOB_MAIL -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME -t 12:00:0  --mem=12000 -N 1 -n 1  -d afterok:$JOB_DEPENDENCIES | grep -o "[0-9]*")
echo "$remove_contam_13_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST
