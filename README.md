# pipeline

A Snakemake workflow for variant calling, from raw FASTQ files to a VCF, with coverage statistics and plots at the end.

> **Status:** work in progress. This README is an initial draft and will be extended as the pipeline is built.

## Overview

| Step | Description | Tool |
|------|-------------|------|
| 1 | Quality control and trimming of raw reads | fastp |
| 2 | Mapping of trimmed reads to the reference genome | BWA |
| 3 | Sorting, indexing and BAM processing (to be defined) | samtools |
| 4 | Coverage calculation | samtools |
| 5 | Post-processing of alignments, e.g. duplicate marking (to be defined) | GATK |
| 6 | Further preparation for variant calling (to be defined) | GATK |
| 7 | Variant calling | GATK HaplotypeCaller |
| 8 | Plots and summary of results (planned) | to be defined |

## Requirements

- Linux environment (developed in GitHub Codespaces)
- Conda / Mamba
- Snakemake, fastp, BWA, samtools, GATK4, OpenJDK 17

## Installation

```bash
git clone https://github.com/mej0498-del/pipeline.git
cd pipeline
conda env create -f environment.yml
conda activate project
```

## Input data

- Raw sequencing reads in FASTQ format (paired-end / single-end: to be specified)
- Reference genome in FASTA format (source and version: to be specified)

## Usage

Dry run:

```bash
snakemake -n
```

Run the pipeline:

```bash
snakemake --cores 4 --use-conda
```

## Output

To be finalized.

## To do

- [ ] Define samples and parameters in `config.yaml`
- [ ] Write the Snakemake rules for each step
- [ ] Add the missing intermediate steps
- [ ] Add plots (coverage, variant summary)
- [ ] Test on a small dataset

## Author

mej0498-del