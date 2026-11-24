# pipeline

A Snakemake workflow for variant calling, from raw FASTQ files to a VCF, with coverage statistics and plots at the end.

> **Status:** work in progress. This README is an initial draft and will be extended as the pipeline is built.

## Overview

| Step | Description | Tool |
|------|-------------|------|
| 1 | Quality control and trimming of raw reads | fastp |
| 2 | Mapping of trimmed reads to the reference genome | BWA |
| 3 | Sorting, indexing and BAM processing (to be defined) | samtools |
| 4 | Coverage calculation | bedtools |
| 5 | Post-processing of alignments, e.g. duplicate marking (to be defined) | GATK |
| 6 | Further preparation for variant calling (to be defined) | GATK |
| 7 | Variant calling | GATK HaplotypeCaller |
| 8 | Plots and summary of results (planned) | to be defined |

## Requirements

- Linux environment (developed in GitHub Codespaces)
- Conda / Mamba
- Snakemake, fastp, BWA, samtools, GATK4, OpenJDK 17

## Layout

```
pipeline/
├── environment.yml
├── config.yaml
├── samples.tsv
├── README.md
├── resources/                      
│   ├── reference.fasta             # you provide this
│   ├── reference.fasta.fai         # created by samtools faidx
│   └── reference.fasta.{amb,ann,bwt,pac,sa}   # created by bwa index
├── workflow/
│   ├── Snakefile                   # includes + rule all
│   ├── rules/
│   │   ├── common.smk              # validation and some helper functions
│   │   ├── qc.smk                  # fastp
│   │   ├── reference.smk           # bwa_index
│   │   ├── mapping.smk             # bwa_mem, samtools, java
│   │   ├── coverage.smk            # bedtools
│   │   └── calling.smk             # gatk4 haplotypecaller
│   ├── envs/                       # conda environments
│   └── scripts/
│       ├── make_samples.py         # generates samples.tsv from data/raw/
│       └── fastp_summary.py        # combines fastp JSON reports into one table
├── resources/                      # reference genome 
├── data/raw/                       # raw FASTQ files
├── logs/                           # one log file per rule and sample (created by the pipeline)
└── results/                        # pipeline output (created by the pipeline)
    ├── inputs/
    │   └── samples_validated.tsv   # copy of the validated sample sheet
    ├── trimmed/
    │   ├── {sample}_R1.fastq.gz    
    │   └── {sample}_R2.fastq.gz
    ├── reference/
    │   ├── chromosome.tab          # chromosome names and lengths
    │   └── sliding_windows.bed     # sliding windows  
    │
    ├──coverage/
    │   └── {sample}.slidingwindow.tab   # median depth per window
    ├── mapped/
    │   ├── {sample}.mdup.bam           # final BAM
    │   ├── {sample}.mdup.bam.bai       # BAM index
    │   ├── {sample}.mdup.metrics.txt   # duplicate statistics
    │   └── {sample}.flagstat.txt       # mapping statistics
    └── qc/
        ├── {sample}.fastp.html     # per-sample fastp report
        ├── {sample}.fastp.json     # per-sample fastp metrics
        └── read_qc_summary.tsv     # one table with all samples
```

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
### Prepare the sample sheet

Place paired-end reads in `data/raw/` named `{sample}_R1.fastq.gz` and `{sample}_R2.fastq.gz`, then generate `samples.tsv`:

```bash
python workflow/scripts/make_samples.py
```

## Input data

- **Reads:** paired-end FASTQ files in `data/raw/`, named `{sample}_R1.fastq.gz` and `{sample}_R2.fastq.gz`.
  Single-end reads are not supported.
- **Reference genome:** an uncompressed FASTA file (any name, e.g. `.fa`, `.fasta`)
  placed in `resources/`. Set its path in `config.yaml` (`reference` key).
  The index files (`.fai` and the BWA index) are created automatically next to it.
  You have to avoid spaces in the file and folder names.

The script lists every `*_R1.fastq.gz` file in `data/raw/` and writes the sample sheet necessary with the columns `sample`, `read_type`, `r1`, `r2`. You can also write `samples.tsv` by hand if you are working with small number of samples

### Configuration

All settings live in `config.yaml`. The defaults are intentionally minimal, so you can tune the pipeline to your liking.

| Key | Description | Default |
|-----|-------------|---------|
| `samples` | Path to the sample sheet | `samples.tsv` |
| `fastp.extra` | Extra command-line options passed to fastp | empty (fastp defaults) |
| `threads.fastp` | Threads used by fastp | `4` |
| `reference` | Path to the reference genome FASTA (uncompressed, any file name) | none, required |

Example: trim reads shorter than 50 bp and require base quality of at least 20:

```yaml
fastp:
  extra: "--length_required 50 --qualified_quality_phred 20"
```

See the [fastp documentation](https://github.com/OpenGene/fastp) for all available options.
Do not add options that change input/output files (`-i`, `-o`, `--json`, `--html`), since the pipeline sets those itself.

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

## Citations

If you use this pipeline, please cite the tools it relies on:

- fastp: Chen S, Zhou Y, Chen Y, Gu J. Bioinformatics 2018; 34(17): i884-i890. doi:10.1093/bioinformatics/bty560
- fastp (newer features): Chen S. iMeta 2023; 2: e107. doi:10.1002/imt2.107
- bwa-mem: Li H. (2013) Aligning sequence reads, clone sequences and assembly contigs with BWA-MEM. arXiv:1303.3997v2 [q-bio.GN]. (if you use the BWA-MEM algorithm or the fastmap command, or want to cite the whole BWA package)
- samtools: Twelve years of SAMtools and BCFtools
Petr Danecek, James K Bonfield, Jennifer Liddle, John Marshall, Valeriu Ohan, Martin O Pollard, Andrew Whitwham, Thomas Keane, Shane A McCarthy, Robert M Davies, Heng Li
GigaScience, Volume 10, Issue 2, February 2021, giab008, https://doi.org/10.1093/gigascience/giab008