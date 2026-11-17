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