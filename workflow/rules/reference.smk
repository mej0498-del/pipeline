BWA_INDEX_EXT = [".amb", ".ann", ".bwt", ".pac", ".sa"]
rule bwa_index:
    input:
        rf=config["reference"],
    output:
        multiext(config["reference"], *BWA_INDEX_EXT),
    log:
        "logs/bwa_index/bwa_index.log",
    conda:
        "../envs/mapping.yaml"
    shell:
        "bwa index {input.rf} > {log} 2>&1"

rule fai:
    input:
        config["reference"],
    output:
        config["reference"] + ".fai",
    log:
        "logs/fai/fai.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        "samtools faidx {input} 2> {log}"


rule chromosome:
    input:
        config["reference"] + ".fai"
    output:
        "results/reference/chromosome.tab"
    shell:
        "cut -f1,2 {input} > {output}"


rule sliding_windows:
    input:
        "results/reference/chromosome.tab"
    output:
        "results/reference/sliding_windows.bed"
    params:
        size=config["coverage"]["window_size"],
        step=config["coverage"]["window_step"]
    log:
        "logs/sliding_windows/sliding_windows.log"
    conda:
        "../envs/coverage.yaml"
    shell:
        "bedtools makewindows -g {input} -w {params.size} -s {params.step} "
        "> {output} 2> {log}"