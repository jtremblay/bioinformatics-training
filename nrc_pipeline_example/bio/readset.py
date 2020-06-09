#!/usr/bin/env python

# Python Standard Modules
import csv
import logging
import os
import re

# NRC Modules
from sample import *

log = logging.getLogger(__name__)

class Readset:

    def __init__(self, name, run_type):
        if re.search("^\w[\w.-]*$", name):
            self._name = name
        else:
            raise Exception("Error: readset name \"" + name +
                "\" is invalid (should match [a-zA-Z0-9_][a-zA-Z0-9_.-]*)!")

        if run_type in ("PAIRED_END", "SINGLE_END", "SINGLE_END_LONG", "SPE_LSE", "FASTA"):
            self._run_type = run_type
        else:
            raise Exception("Error: readset run_type \"" + run_type +
                "\" is invalid (should be \"PAIRED_END\" or \"SINGLE_END\" or \"SINGLE_END_LONG\" or \"FASTA\")!")
    
    #def __init__(self, name):
    #    if re.search("^\w[\w.-]*$", name):
    #        self._name = name
    #    else:
    #        raise Exception("Error: readset name \"" + name +
    #            "\" is invalid (should match [a-zA-Z0-9_][a-zA-Z0-9_.-]*)!")

    def show(self):
        print('Readset -- name: ' + self._name + ', run_type: ' + self._run_type)

    @property
    def name(self):
        return self._name

    @property
    def run_type(self):
        return self._run_type

    @property
    def sample(self):
        return self._sample

    @property
    def bam(self):
        return self._bam

    @property
    def fastq1(self):
        return self._fastq1

    @property
    def fastq2(self):
        return self._fastq2

    @property
    def library(self):
        return self._library

    @property
    def run(self):
        return self._run

    @property
    def lane(self):
        return self._lane

    @property
    def adaptor1(self):
        return self._adaptor1

    @property
    def adaptor2(self):
        return self._adaptor2

    @property
    def quality_offset(self):
        return self._quality_offset

    @property
    def beds(self):
        return self._beds

def parse_readset_file(readset_file):
    readsets = []
    samples = []

    log.info("Parse readset file " + readset_file + " ...")
    readset_csv = csv.DictReader(open(readset_file, 'rb'), delimiter='\t')
    for line in readset_csv:
        sample_name = line['Sample']
        sample_names = [sample.name for sample in samples]
        if sample_name in sample_names:
            # Sample already exists
            sample = samples[sample_names.index(sample_name)]
        else:
            # Create new sample
            sample = Sample(sample_name)
            samples.append(sample)

        # Create readset and add it to sample
        readset = Readset(line['Readset'], line['RunType'])

        # Readset file paths are either absolute or relative to the readset file
        # Convert them to absolute paths
        for format in ("BAM", "FASTQ1", "FASTQ2"):
            if line.get(format, None) and not os.path.isabs(line[format]):
                line[format] = os.path.dirname(os.path.abspath(readset_file)) + os.sep + line[format]

        readset.bam = line.get('BAM', None)
        readset.fastq1 = line.get('FASTQ1', None)
        readset.fastq2 = line.get('FASTQ2', None)
        readset.library = line.get('Library', None)
        readset.run = line.get('Run', None)
        readset.lane = line.get('Lane', None)
        readset.adaptor1 = line.get('Adaptor1', None)
        readset.adaptor2 = line.get('Adaptor2', None)
        readset.quality_offset = int(line['QualityOffset']) if line.get('QualityOffset', None) else None
        readset.beds = line['BED'].split(";") if line.get('BED', None) else []

        readsets.append(readset)
        sample.add_readset(readset)

    log.info(str(len(readsets)) + " readset" + ("s" if len(readsets) > 1 else "") + " parsed")
    log.info(str(len(readsets)) + " sample" + ("s" if len(samples) > 1 else "") + " parsed\n")
    return readsets

def parse_nanuq_readset_file(readset_file):
    readsets = []
    samples = []

    log.info("Parse Nanuq readset file " + readset_file + " ...")
    #readset_csv = csv.DictReader(open(readset_file, 'rb'), delimiter='\t')
    readset_csv = csv.DictReader(open(readset_file, 'rb'), delimiter=',', quotechar='"')
    for line in readset_csv:
        if line['Status'] and line['Status'] == "Data is valid":
            sample_name = line['Name']
            sample_names = [sample.name for sample in samples]
            if sample_name in sample_names:
                # Sample already exists
                sample = samples[sample_names.index(sample_name)]
            else:
                # Create new sample
                sample = Sample(sample_name)
                samples.append(sample)
    
            # Create readset and add it to sample
            readset = Readset(line['Filename Prefix'], line['Run Type'])
    
            readset.library = line['Library Barcode']
            readset.run = line['Run']
            readset.lane = line['Region']
    
            readset.adaptor1 = line['Adaptor Read 1 (NOTE: Usage is bound by Illumina Disclaimer found on Nanuq Project Page)']
            readset.adaptor2 = line['Adaptor Read 2 (NOTE: Usage is bound by Illumina Disclaimer found on Nanuq Project Page)']
            readset.quality_offset = int(line['Quality Offset'])
            if line['BED Files']:
                readset.beds = line['BED Files'].split(";")
            else:
                readset.beds = []
    
            file_prefix = "raw_reads/{sample_name}/run{readset.run}_{readset.lane}/{sample_name}.{readset.library}.{readset.quality_offset}.".format(sample_name=sample_name, readset=readset)
    
            if line['BAM']:
                line['BAM'] = file_prefix + "bam"
                line['FASTQ1'] = ""
                line['FASTQ2'] = ""
            elif line['FASTQ1']:
                if line['FASTQ2']:
                    line['FASTQ1'] = file_prefix + "pair1.fastq.gz"
                    line['FASTQ2'] = file_prefix + "pair2.fastq.gz"
                else:
                    line['FASTQ1'] = file_prefix + "single.fastq.gz"

            # Readset file paths are either absolute or relative to the readset file
            # Convert them to absolute paths
            for format in ['BAM', 'FASTQ1', 'FASTQ2']:
                if line[format] and not os.path.isabs(line[format]):
                    line[format] = os.path.abspath(line[format])

            readset.bam = line['BAM']
            readset.fastq1 = line['FASTQ1']
            readset.fastq2 = line['FASTQ2']

            readsets.append(readset)
            sample.add_readset(readset)

        else:
            log.warning("Sample Name " + line['Name'] + ", Run ID " + line['Run'] + ", Lane " + line['Region'] + " data is not valid... skipping")

    log.info(str(len(readsets)) + " readset" + ("s" if len(readsets) > 1 else "") + " parsed")
    log.info(str(len(readsets)) + " sample" + ("s" if len(samples) > 1 else "") + " parsed\n")
    return readsets


class PacBioReadset(Readset):

    @property
    def run(self):
        return self._run

    @property
    def smartcell(self):
        return self._smartcell

    @property
    def protocol(self):
        return self._protocol

    @property
    def nb_base_pairs(self):
        return self._nb_base_pairs

    @property
    def estimated_genome_size(self):
        if self._estimated_genome_size:
            return self._estimated_genome_size
        else:
            raise Exception("Error: readset \"" + self.name + "\" estimated_genome_size is not defined!")

    @property
    def bas_files(self):
        return self._bas_files

    @property
    def bax_files(self):
        return self._bax_files

def parse_pacbio_readset_file(pacbio_readset_file):
    readsets = []
    samples = []

    log.info("Parse PacBio readset file " + pacbio_readset_file + " ...")
    readset_csv = csv.DictReader(open(pacbio_readset_file, 'rb'), delimiter='\t')
    for line in readset_csv:
        sample_name = line['Sample']
        sample_names = [sample.name for sample in samples]
        if sample_name in sample_names:
            # Sample already exists
            sample = samples[sample_names.index(sample_name)]
        else:
            # Create new sample
            sample = Sample(sample_name)
            samples.append(sample)

        # Create readset and add it to sample
        #readset = PacBioReadset(line['Readset'], "SINGLE_END")
        readset = PacBioReadset(line['Smartcell'], "SINGLE_END")

        # Readset file paths are either absolute or relative to the readset file
        # Convert them to absolute paths
        for format in ("BAS", "BAX"):
            if line.get(format, None):
                abs_files = []
                for file in line[format].split(","):
                    file = os.path.expandvars(file)
                    if not os.path.isabs(file):
                        file = os.path.dirname(os.path.abspath(os.path.expandvars(pacbio_readset_file))) + os.sep + file
                    abs_files.append(os.path.normpath(file))
                line[format] = ",".join(abs_files)

        readset._run = line.get('Run', None)
        readset._smartcell = line.get('Smartcell', None)
        readset._protocol = line.get('Protocol', None)
        readset._nb_base_pairs = int(line['NbBasePairs']) if line.get('NbBasePairs', None) else None
        readset._estimated_genome_size = int(line['EstimatedGenomeSize']) if line.get('EstimatedGenomeSize', None) else None
        readset._bas_files = line['BAS'].split(",") if line.get('BAS', None) else []
        readset._bax_files = line['BAX'].split(",") if line.get('BAX', None) else []

        readsets.append(readset)
        sample.add_readset(readset)

    log.info(str(len(readsets)) + " readset" + ("s" if len(readsets) > 1 else "") + " parsed")
    log.info(str(len(samples)) + " sample" + ("s" if len(samples) > 1 else "") + " parsed\n")
    return readsets

class NanoporeReadset(Readset):

    @property
    def run(self):
        return self._run

    @property
    def nanopore_library(self):
        return self._nanopore_library

    @property
    def protocol(self):
        return self._protocol

    @property
    def nb_base_pairs(self):
        return self._nb_base_pairs

    @property
    def estimated_genome_size(self):
        if self._estimated_genome_size:
            return self._estimated_genome_size
        else:
            raise Exception("Error: readset \"" + self.name + "\" estimated_genome_size is not defined!")

    @property
    def fastq_file(self):
        return self._fastq_file


def parse_nanopore_readset_file(nanopore_readset_file):
    readsets = []
    samples = []

    log.info("Parse Nanopore readset file " + nanopore_readset_file + " ...")
    readset_csv = csv.DictReader(open(nanopore_readset_file, 'rb'), delimiter='\t')
    for line in readset_csv:
        sample_name = line['Sample']
        sample_names = [sample.name for sample in samples]
        if sample_name in sample_names:
            # Sample already exists
            sample = samples[sample_names.index(sample_name)]
        else:
            # Create new sample
            sample = Sample(sample_name)
            samples.append(sample)

        # Create readset and add it to sample
        #readset = PacBioReadset(line['Readset'], "SINGLE_END")
        readset = NanoporeReadset(line['NanoporeLibrary'], "SINGLE_END")

        # Readset file paths are either absolute or relative to the readset file
        # Convert them to absolute paths
        for format in ("FASTQ"):
            if line.get(format, None):
                abs_files = []
                for file in line[format].split(","):
                    file = os.path.expandvars(file)
                    if not os.path.isabs(file):
                        file = os.path.dirname(os.path.abspath(os.path.expandvars(pacbio_readset_file))) + os.sep + file
                    abs_files.append(os.path.normpath(file))
                line[format] = ",".join(abs_files)

        readset._run = line.get('Run', None)
        readset._smartcell = line.get('NanoporeLibrary', None)
        readset._protocol = line.get('Protocol', None)
        readset._nb_base_pairs = int(line['NbBasePairs']) if line.get('NbBasePairs', None) else None
        readset._estimated_genome_size = int(line['EstimatedGenomeSize']) if line.get('EstimatedGenomeSize', None) else None
        #readset._fastq_files = line['FASTQ'].split(",") if line.get('FASTQ', None) else []
        readset._fastq_file = line.get('FASTQ', None)
        #readset._bax_files = line['BAX'].split(",") if line.get('BAX', None) else []
        fastq_file = line.get('FASTQ', None)
        readset.name = os.path.splitext(os.path.basename(fastq_file))[0]

        readsets.append(readset)
        sample.add_readset(readset)

    log.info(str(len(readsets)) + " readset" + ("s" if len(readsets) > 1 else "") + " parsed")
    log.info(str(len(samples)) + " sample" + ("s" if len(samples) > 1 else "") + " parsed\n")
    return readsets

# MGA set

class MGASet(Readset):

    @property
    def run(self):
        return self._run

    @property
    def smartcell(self):
        return self._smartcell

    @property
    def protocol(self):
        return self._protocol

    @property
    def nb_base_pairs(self):
        return self._nb_base_pairs

    @property
    def estimated_genome_size(self):
        if self._estimated_genome_size:
            return self._estimated_genome_size
        else:
            raise Exception("Error: readset \"" + self.name + "\" estimated_genome_size is not defined!")

    @property
    def bas_files(self):
        return self._bas_files

    @property
    def bax_files(self):
        return self._bax_files
    
    @property
    def fasta_file(self):
        return self._fasta_file

def parse_mgaset_file(mga_set_file):
    mgasets = []
    mgas = []

    log.info("Parse MGA mgaset file " + mga_set_file + " ...")
    mgaset_csv = csv.DictReader(open(mga_set_file, 'rb'), delimiter='\t')
    for line in mgaset_csv:
        mga_name = line['mga_name']
        mga_names = [mga.name for mga in mgas]
        if mga_name in mga_names:
            # Mga already exists
            mga = mgas[mga_names.index(mga_name)]
        else:
            # Create new mga
            mga = Mga(mga_name)
            mgas.append(mga)

        # Create mgaset and add it to mga
        mgaset = MGASet(line['mga_name'], "FASTA")
        mgaset._fasta_file = line.get('FASTA', None)
        
        mgasets.append(mgaset)
        mga.add_mgaset(mgaset)

    log.info(str(len(mgasets)) + " mgaset" + ("s" if len(mgasets) > 1 else "") + " parsed")
    log.info(str(len(mgas)) + " mga" + ("s" if len(mgas) > 1 else "") + " parsed\n")
    
    return mgasets
