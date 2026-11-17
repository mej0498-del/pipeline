rule bwa_mem:
    input:
        r1="results/trimmed/{sample}_R1.fastq.gz",
        r2="results/trimmed/{sample}_R2.fastq.gz",
        rf=config["reference"],
        index=multiext(config["reference"], *BWA_INDEX_EXT)
    output:
        bam=temp("results/mapped/{sample}.sorted.bam")
    params:
        r=lambda wildcard: f"@RG\\tID:{wildcard.sample}\\tSM:{wildcard.sample}\\tPL:ILLUMINA\\tLB:{wildcard.sample}",
        extra=config.get("bwa", {}).get("extra", "")
    threads: config["threads"]["bwa"]
    log:
        "logs/bwa_mem/{sample}.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        """
        (bwa mem -t {threads} -R '{params.r}' {params.extra} \
            {input.rf} {input.r1} {input.r2} \
         | samtools sort -@ {threads} -o {output.bam} -) 2> {log}
        """

rule samtools_flagstat:
    input:
        "results/mapped/{sample}.sorted.bam",
    output:
        "results/mapped/{sample}.flagstat.txt",
    log:
        "logs/samtools_flagstat/{sample}.log",
    conda:
        "../envs/mapping.yaml"
    shell:
        "samtools flagstat {input} > {output} 2> {log}"

rule filter_mapped:
    input:
        "results/mapped/{sample}.sorted.bam"
    output:
        temp("results/mapped/{sample}.mapped.bam")
    threads: config["threads"]["bwa"]
    log:
        "logs/filter_mapped/{sample}.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        "samtools view -Sb -F 4 -@ {threads} {input} > {output} 2> {log}"


rule mark_duplicates:
    input:
        "results/mapped/{sample}.mapped.bam"
    output:
        bam="results/mapped/{sample}.mdup.bam"
        metrics="results/mapped/{sample}.mdup.metrics.txt"
    params:
        mem_gb=config.get("gatk", {}).get("mem_gb", 18)
    log:
        "logs/mark_duplicates/{sample}.log"
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk --java-options "-Xmx{params.mem_gb}g" MarkDuplicates \
            -I {input} -O {output.bam} -M {output.metrics} > {log} 2>&1
        """


rule samtools_index:
    input:
        "results/mapped/{sample}.mdup.bam"
    output:
        "results/mapped/{sample}.mdup.bam.bai"
    log:
        "logs/samtools_index/{sample}.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        "samtools index {input} > {log} 2>&1"