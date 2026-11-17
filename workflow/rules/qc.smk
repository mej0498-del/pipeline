rule fastp:
    input:
        r1=read_1,
        r2=read_2,
    output:
        r1="results/trimmed/{sample}_R1.fastq.gz",
        r2="results/trimmed/{sample}_R2.fastq.gz",
        json="results/qc/{sample}.fastp.json",
        html="results/qc/{sample}.fastp.html"
    params:
        extra=config.get("fastp", {}).get("extra", ""),
    threads: 
        config.get("threads", {}).get("fastp", 4)
    log:
        "logs/fastp/{sample}.log"
    conda:
        "../envs/fastp.yaml"
    shell:
        "fastp -i {input.r1} -I {input.r2} "
        "-o {output.r1} -O {output.r2} "
        "--json {output.json} --html {output.html} "
        "-w {threads}{params.extra} 2> {log}"