#!/bin/bash
#SBATCH --time=5:00:00
#SBATCH --nodes=1
#SBATCH --account=rrg-yergeaue
#SBATCH -n 1
#SBATCH --mem=4000
#SBATCH -o ./stdout.txt
#SBATCH -e ./stderr.txt



### Preprocess data
#module load nrc/nrc_tools/dev
#~/scripts/generateReadsetSheet.pl --indir ./raw_reads/ > readset.tsv

### Launch the pipelne
# Don't forget to update your PYTHONPATH: 
#export PYTHONPATH=~/build/bioinformatics-training/nrc_pipeline_example:$PYTHONPATH
~/build/bioinformatics-training/nrc_pipeline_example/pipelines/pipeline_example/pipeline_example.py -r readset.tsv -c ./pipeline_example.ini -s 1-2 -o . -j slurm -z ./pipeline.json  > ./commands.sh
