#!/usr/bin/env python

#LICENSE AND COPYRIGHT

#Copyright (C) 2015 National Research Council Canada

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
import argparse
import collections
import logging
import os
import re
import sys
import errno
import time

# Append pipeline directory to Python library path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(sys.argv[0]))))

# GenPipes/NRC Modules
from core.config import *
from core.job import *
from core.pipeline import *
from bio.readset import *

from bio import example_functions

from pipelines import common
#from pipelines.illumina import illumina

# Global scope variables
log = logging.getLogger(__name__)

class PipelineExample(common.NRCPipeline):
    """
    Pipeline template
    Written by Julien Tremblay
    ========================

    Simple pipeline template

    """

    def trim(self):
        
        """
        Step trim(): Raw fastqs will be trimmed using Trimmomatic. Interleaved fastqs will be generated after trimming. 
        """
        
        jobs = []
        
        for readset in self.readsets:
            
            if not os.path.exists(os.path.join("qced_reads", readset.sample.name)):
                os.makedirs(os.path.join("qced_reads", readset.sample.name))
            
            if readset.run_type == "PAIRED_END":

                job = example_functions.trimmomatic(
                    readset.fastq1,
                    readset.fastq2,
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.pair1.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.single1.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.pair2.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.single2.fastq.gz"),
                    readset.quality_offset,
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.out"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.stats.csv")
                )
                job.name = "trimmomatic_" + readset.sample.name
                job.subname = "trim"
                jobs.append(job) 
                
                # Merge R1 and R2 to get an interleaved file. We do this here because of memory requirements
                # for downstream duk steps. Here we assume that R1 and R2 are in the same exact order.
                job = example_functions.create_interleaved_fastq(
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.pair1.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.pair2.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.interleaved.fastq"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.interleaved.fastq.gz")
                )
                job.name = "create_interleaved_fastq_" + readset.sample.name
                job.subname = "interleaved_fastq"
                jobs.append(job) 

            elif readset.run_type == "SINGLE_END" :

                job = example_functions.trimmomatic_se(
                    readset.fastq1,
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.pair1.fastq.gz"),
                    readset.quality_offset,
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.out"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.stats.csv")
                )
                job.name = "trimmomatic_" + readset.sample.name
                job.subname = "trim"
                jobs.append(job) 
    
            else:
                raise Exception("Error: run type \"" + readset.run_type +
                "\" is invalid for readset \"" + readset.name + "\" (should be PAIRED_END or SINGLE_END)")
        
        return jobs
            
    def remove_contam(self):
        """
        Step remove_contam(): Trimmed fastqs will be filtered for contaminant sequences (e.g. Illumina adapters,
                              known primer sequences, etc). A second round of contaminant filtering will be done 
                              to filter out PhiX sequences which are usually spiked-in in Illumina sequencing runs.
        """
        jobs=[]
        #outdir = self._root_dir
        logs = []
        readset_ids = []

        for readset in self.readsets:
            
            if readset.run_type == "PAIRED_END":
                log = os.path.join("qced_reads", readset.sample.name, readset.name + ".duk_contam_interleaved_log.txt")

                job = example_functions.bbduk(
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.interleaved.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".contam.fastq"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".ncontam.fastq.gz"),
                    log,
                    config.param('DB', 'contaminants', 1, 'filepath'),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.interleaved.fastq.gz")
                )
                job.name = "bbduk_interleaved_" + readset.sample.name
                job.subname = "duk"
                jobs.append(job)
            
                job = example_functions.remove_unpaired_reads_and_split(
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".ncontam.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".ncontam_unpaired_R1.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".ncontam_unpaired_R2.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".ncontam_paired_R1.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".ncontam_paired_R2.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".ncontam_paired.fastq.gz")
                )
                job.name = "remove_unpaired_and_split_" + readset.sample.name
                job.subname = "remove_unpaired"
                jobs.append(job)
                
                logs.append(log)
                readset_ids.append(readset.name)
            
            elif readset.run_type == "SINGLE_END":
                log = os.path.join(self._root_dir, "qced_reads", readset.sample.name, readset.name + ".duk_contam_pair1_log.txt")

                job = example_functions.bbduk(
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.pair1.fastq.gz"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".contam.fastq"),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".ncontam.fastq.gz"),
                    log,
                    config.param('DB', 'contaminants', 1, 'filepath'),
                    os.path.join("qced_reads", readset.sample.name, readset.name + ".trim.pair1.fastq.gz")
                )
                job.name = "bbduk_single_end_reads_" + readset.sample.name
                job.subname = "duk"
                jobs.append(job)
                
                logs.append(log)
                readset_ids.append(readset.name)
            
        # Compile duk logs.
        job = example_functions.merge_duk_logs_interleaved(
            logs,
            readset_ids,
            os.path.join(self._root_dir, "qced_reads", "duk_merged_logs.tsv")
        )
        job.name = "merge_duk_logs"
        job.subname = "merge_duk_logs"
        jobs.append(job)
            
        return jobs
     
    def cleanup(self):
        #Here, compress all .fastq files into .fastq.gz.
        jobs = []
        #job = example_functions.mymethod(
        #)
        #job.name = "myjobname"
        #jobs.append(job)
        sys.stderr.write('[DEBUG] cleanup() not implemented yet\n')
        return jobs
    
    # Override illumina.py readsets to make sure we are parsing a nanuq sample sheet
    # and not a readset sheet.
    @property
    def readsets(self):
        if not hasattr(self, "_readsets"):
            self._readsets = parse_nanuq_readset_file(self.args.readsets.name)
        return self._readsets

    @property
    def steps(self):
        
        return [
            # Core steps.
            self.trim,
            self.remove_contam
            #self.cleanup
        ]

    def set_local_variables(self):
        self._parser_local = self.argparser

        # barcodes
        self._args_local = self._parser_local.parse_args()
        config.parse_files(self._args_local.config)
        self._config = self._args_local.config[0]
        self._config = os.path.abspath(self._config.name)
        #self._normalize = self._args_local.normalize
        #self._extended_taxonomy = self._args_local.extended_taxonomy
        
        self._root_dir = self._args_local.output_dir
        if not os.path.exists(self._root_dir):
            os.makedirs(self._root_dir)
        
        # Make directories
        self.make_directories(self._root_dir)
  
    # Define and make directories. Also desing initial infile.
    def make_directories(self, root_dir):
        def mkdir_p(path):
            try:
                os.makedirs(path)
            except OSError as exc: # Python >2.5
                if exc.errno == errno.EEXIST and os.path.isdir(path):
                    pass
                else: raise
         
        mkdir_p(root_dir)
        mkdir_p(os.path.join(root_dir, "qced_reads"))

    @property
    def readsets(self):
        if not hasattr(self, "_readsets"):
            self._readsets = parse_readset_file(self.args.readsets.name)
        return self._readsets


    def __init__(self):
        pipeline_string = """
###############################################################################
                                    
                           Pipeline Example

               Support: julien.tremblay@nrc-cnrc.gc.ca
             Home page: jtremblay.github.io/pipelines.html

###############################################################################"""
        sys.stderr.write(pipeline_string + '\n')
        time.sleep(1)
        # Add pipeline specific arguments
        self.argparser.add_argument("-r", "--readsets", help="readset file", type=file, required=False)
        self.set_local_variables()
        sys.stderr.write('Pipeline Example\n')
        super(PipelineExample, self).__init__()
                
PipelineExample().submit_jobs()
