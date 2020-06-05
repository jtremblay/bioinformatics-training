#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --nodes=1
#SBATCH --account=rrg-jtrembla
#SBATCH -n 16
#SBATCH --mem=64000
#SBATCH -o ./stdout.txt
#SBATCH -e ./stderr.txt



# In this example, we will :
# 1) blast (diamond blastp) gene sequences (originating from a de novo shotgun metagenomic assembly) against the KEGG GENES DB. DIAMOND is an optimized implementation of the highly popular blast(p) algorighm.
# 2) Take the blastp results and generaste a overrepresentation analyses of all KEGG KOs.

##############################################################
# Part done using software installed in production on Graham #
# mainly to show how we got from .faa sequences to KEGG KOs. #
##############################################################

# DIAMOND blastp against latest KEGG DB (Only this part should be done with sbatch with the above resources). 
# The rest (because dummy low input dataset) can be executed on head node or ideally on an interactive compute node.
module load nrc/diamond/0.9.25
diamond blastp \
     -d /project/6008026/databases/kegg/2020-03-23/genes/fasta/genes.pep.dmnd \
     -q ../../data/genes.faa \
     -o ./genes_blastp_out.tsv \
     -k 10 \
     -e 1e-10 \
     -p 16 

# Keep best hit only for each gene query.
module load nrc/nrc_tools/dev
~/scripts/keepBestBlastHit.pl --infile ./genes_blastp_out.tsv > genes_blastp_out_best.tsv

# Then add KEGG information (Pathways, Modules, KOs, etc.).
parseKegg.pl \
  --infile ./genes_blastp_out_best.tsv \
  --ko /project/6008026/databases/kegg/2020-03-23/genes/ko/ko \
  --genes_desc /project/6008026/databases/kegg/2020-03-23/genes/fasta/genes.tsv \
  --genetoko /project/6008026/databases/kegg/2020-03-23/genes/links/genes_ko.list \
  > ./genes_blastp_out_best_parsed.tsv


################################################################
# Part done using Python script(s) in this training repository #
# These scripts will perform an overrepresentation analysis    #
# of either KEGG KOs, Pathways and Modules.                    # 
# These scripts are a good showcase of the Python defaultdict  #
# data structure.                                              #
################################################################
# Load libraries (i.e. numpy, etc.).
module load nrc/qiime-dependencies/1.9.1
../../python/scripts/getKeggK.py --help

../../python/scripts/getKeggK.py \
    --infile-blastp ./genes_blastp_out_best_parsed.tsv  \
    --infile-gene-abundance ../../data/merged_gene_abundance_cpm.tsv \
    > genes_blastp_out_best_parsed_KO_matrix.tsv

../../python/scripts/getKeggModules.py \
    --infile-blastp ./genes_blastp_out_best_parsed.tsv  \
    --infile-gene-abundance ../../data/merged_gene_abundance_cpm.tsv \
    > genes_blastp_out_best_parsed_KeggModules_matrix.tsv


../../python/scripts/getKeggPathways.py \
    --infile-blastp ./genes_blastp_out_best_parsed.tsv  \
    --infile-gene-abundance ../../data/merged_gene_abundance_cpm.tsv \
    > genes_blastp_out_best_parsed_KeggPathways_matrix.tsv
