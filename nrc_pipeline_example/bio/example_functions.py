#!/usr/bin/env python

#LICENSE AND COPYRIGHT

#Copyright (C) 2020 National Research Council Canada

#This license does not grant you the right to use any trademark, service
#mark, tradename, or logo of the Copyright Holder.

#This license includes the non-exclusive, worldwide, free-of-charge
#patent license to make, have made, use, offer to sell, sell, import and
#otherwise transfer the Package with respect to any patent claims
#licensable by the Copyright Holder that are necessarily infringed by the
#Package. If you institute patent litigation (including a cross-claim or
#counterclaim) against any party alleging that the Package constitutes
#direct or contributory patent infringement, then this Artistic License
#to you shall terminate on the date that such litigation is filed.

#Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
#AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
#THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
#PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
#YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
#CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
#CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
#EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#Author: Julien Tremblay - julien.tremblay@nrc-cnrc.gc.ca

# Python Standard Modules

# NRC Modules
from core.config import *
from core.job import *

def trimmomatic(input1, input2, paired_output1, unpaired_output1, paired_output2, unpaired_output2, quality_offset, trim_log, trim_stats):

    job = Job(
        [input1, input2], 
        [paired_output1, unpaired_output1, paired_output2, unpaired_output2, trim_log, trim_stats],
        [
            ['java', 'module_java'], 
            ['trimmomatic', 'module_trimmomatic']
        ]
    )

    threads = config.param('trim', 'threads', type='posint')
    adapter_file = config.param('trim', 'adapter_fasta', type='filepath')
    illumina_clip_settings = config.param('trim', 'illumina_clip_settings')
    trailing_min_quality = config.param('trim', 'trailing_min_quality', type='int')
    min_length = config.param('trim', 'min_length', type='posint')
    headcrop = config.param('trim', 'headcrop', required=False, type='int')
    sliding_window1 = config.param('trim', 'sliding_window1', required=False, type='int')
    sliding_window2 = config.param('trim', 'sliding_window2', required=False, type='int')
   
    if not isinstance( sliding_window1, int ):
        if not(sliding_window1 and sliding_window1.strip()):
            sliding_window1 = 4
    
    if not isinstance( sliding_window2, int ):
        if not(sliding_window2 and sliding_window2.strip()):
            sliding_window2 = 15

    job.command = """
java -XX:ParallelGCThreads={threads} -Xmx2G -jar \$TRIMMOMATIC_JAR {mode} \\
  -threads {threads} \\
  -phred{quality_offset} \\
  {input1} {input2} \\
  {paired_output1} {unpaired_output1} {paired_output2} {unpaired_output2} \\
  ILLUMINACLIP:{adapter_file}{illumina_clip_settings} \\
  TRAILING:{trailing_min_quality} \\
  SLIDINGWINDOW:{sliding_window1}:{sliding_window2} \\
  MINLEN:{min_length} \\
  HEADCROP:{headcrop}""".format(
        mode = "PE",
        threads = threads,
        quality_offset = quality_offset,
        input1 = input1,
        input2 = input2,
        paired_output1 = paired_output1,
        paired_output2 = paired_output2,
        unpaired_output1 = unpaired_output1,
        unpaired_output2 = unpaired_output2,
        adapter_file=adapter_file,
        illumina_clip_settings=illumina_clip_settings,
        trailing_min_quality=trailing_min_quality,
        min_length = min_length,
        sliding_window1 = sliding_window1,
        sliding_window2 = sliding_window2,
        headcrop = str(headcrop)
    )

    job.command += " \\\n  2> " + trim_log

    # Compute statistics
    job.command += " && \\\ngrep ^Input " + trim_log + " | perl -pe 's/^Input Read Pairs: (\\d+).*Both Surviving: (\\d+).*Forward Only Surviving: (\\d+).*$/Raw Fragments,\\1\\nFragment Surviving,\\2\\nSingle Surviving,\\3/' > " + trim_stats

    return job

def trimmomatic_se(input1, output1, quality_offset, trim_log, trim_stats):

    job = Job(
        [input1], 
        [output1, trim_log, trim_stats],
        [
            ['java', 'module_java'], 
            ['trimmomatic', 'module_trimmomatic']
        ]
    )
    threads = config.param('trim', 'threads', type='posint')
    adapter_file = config.param('trim', 'adapter_fasta', required=False, type='filepath')
    illumina_clip_settings = config.param('trim', 'illumina_clip_settings')
    trailing_min_quality = config.param('trim', 'trailing_min_quality', type='int')
    min_length = config.param('trim', 'min_length', type='posint')
    headcrop = config.param('trim', 'headcrop', required=False, type='int')
    average_quality = config.param('trim', 'average_quality', required=False, type='posint')

    job.command = """
java -XX:ParallelGCThreads={threads} -Xmx2G -jar \$TRIMMOMATIC_JAR {mode} \\
  -threads {threads} \\
  -phred{quality_offset} \\
  {input1} {output1} \\
  ILLUMINACLIP:{adapter_file}{illumina_clip_settings} \\
  TRAILING:{trailing_min_quality} \\
  MINLEN:{min_length} \\
  HEADCROP:{headcrop} \\
  AVGQUAL:{average_quality}""".format(
        mode = "SE",
        threads = threads,
        quality_offset = quality_offset,
        input1 = input1,
        output1 = output1,
        illumina_clip_settings=illumina_clip_settings,
        trailing_min_quality=trailing_min_quality,
        adapter_file = config.param('trim', 'adapter_fasta', type='filepath'),
        min_length = min_length,
        headcrop = str(headcrop),
        average_quality = average_quality
    )

    job.command += " \\\n  2> " + trim_log

    # Compute statistics
    job.command += " && \\\ngrep ^Input " + trim_log + " | perl -pe 's/^Input Read Pairs: (\\d+).*Both Surviving: (\\d+).*Forward Only Surviving: (\\d+).*$/Raw Fragments,\\1\\nFragment Surviving,\\2\\nSingle Surviving,\\3/' > " + trim_stats

    return job


def bbduk(infile, contam, ncontam, log, db, infile_done=False):

    if(infile_done == False):
        infiles = [infile]
    else:
        infiles = [infile, infile_done]

    #ncontam_gz = ncontam + ".gz"
    #contam_gz = contam + ".gz"

    job = Job(
        infiles, 
        [contam, ncontam, log],
        [
            ['bbmap', 'module_bbmap']
        ]
    )
        
    job.command="""
bbduk.sh \\
  in={infile} \\
  stats={log} \\
  out={ncontam} \\
  outm={contam} \\
  k={k} \\
  minkmerhits={c} \\
  ref={db} \\
  overwrite=true \\
  threads=1""".format(
    infile = infile,
    log = log,
    ncontam = ncontam,
    contam = contam,
    k = config.param('bbduk', 'k', 'int'),
    c = config.param('bbduk', 'c', 'int'),
    db = db
    ) 
    return job


def merge_duk_logs_interleaved(logs, readset_ids, outfile):
    
    job = Job(
        logs,
        [outfile],
        [
            
            ['nrc_tools', 'module_tools']
        ]
    )
    
    job.command="""
mergeDukLogs.pl --logs {logs} --ids {readset_ids} > {outfile}""".format(
    logs = ",".join(logs),
    readset_ids = ",".join(readset_ids),
    outfile = outfile
    )
    
    return job

def merge_duk_logs(logs_R1, logs_R2, outfile):
    
    job = Job(
        logs_R1 + logs_R2,
        [outfile],
        [
            
            ['nrc_tools', 'module_tools']
        ]
    )
    
    job.command="""
mergeDukLogs.pl --R1 {logs_R1} --R2 {logs_R2} > {outfile}""".format(
    logs_R1 = ",".join(logs_R1),
    logs_R2 = ",".join(logs_R2),
    outfile = outfile
    )

    return job

def merge_pairs(reads1, reads2, out1p, out2p, outfile):
    job = Job(
        [reads1, reads2],
        [outfile, out1p, out2p],
        [
            
            ['nrc_tools', 'module_tools']
        ]
    )
    
    job.command="""
mergePairs.pl \\
  --reads1 {reads1} \\
  --reads2 {reads2} \\
  --reads1_out {out1p} \\
  --reads2_out {out2p} \\
  > {outfile}""".format(
    reads1 = reads1,
    reads2 = reads2,
    out1p = out1p,
    out2p = out2p,
    outfile = outfile
    )

    return job

def create_interleaved_fastq(reads1, reads2, tmp, outfile):
    job = Job(
        [reads1, reads2],
        [outfile],
        [
            
            ['nrc_tools', 'module_tools'],
            ['pigz', 'module_pigz']
        ]
    )
    
    job.command="""
createInterleavedFastq.pl \\
  --reads1 {reads1} \\
  --reads2 {reads2} \\
  > {tmp} && pigz -p {num_threads} -f {tmp}""".format(
    reads1 = reads1,
    reads2 = reads2,
    tmp = tmp,
    num_threads = config.param("interleaved_fastq", "num_threads", 1, "posint") 
    )

    return job

def remove_unpaired_reads_and_split(infile, unpaired_reads1, unpaired_reads2, paired_reads1, paired_reads2, outfile):
    
    tmp1 = os.path.splitext(unpaired_reads1)[0]
    tmp2 = os.path.splitext(unpaired_reads2)[0]
    tmp12 = os.path.splitext(outfile)[0]
    
    job = Job(
        [infile],
        [outfile, unpaired_reads1, unpaired_reads2, paired_reads1, paired_reads2],
        [
            
            ['nrc_tools', 'module_tools']
        ]
    )
    
    job.command="""
removeUnpairedReads.pl \\
  --infile {infile} \\
  --unpaired_reads1 {tmp1} \\
  --unpaired_reads2 {tmp2} \\
  > {tmp12} && \\
gzip -f {tmp1} && gzip -f {tmp2} && gzip -f {tmp12} && \\
splitPairsGz.pl \\
  --infile {tmp12}.gz \\
  --outfile_1 {paired_reads1} \\
  --outfile_2 {paired_reads2}""".format(
    tmp1 = tmp1,
    tmp2 = tmp2,
    tmp12 = tmp12,
    infile = infile, 
    paired_reads1 = paired_reads1,
    paired_reads2 = paired_reads2
    )

    return job


