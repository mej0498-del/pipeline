rule haplotypecaller:
    input:
        bam="results/mapped/{sample}.mdup.bam",
        bai="results/mapped/{sample}.mdup.bam.bai",
        ref=config["reference"],
        fai=config["reference"] + ".fai",
        dct=os.path.splitext(config["reference"])[0] + ".dict",
    output:
        "results/variants/{sample}.g.vcf.gz",
    params:
        mem_gb=config["gatk"]["mem_gb"],
        ploidy=config["gatk"]["ploidy"],
    log:
        "logs/haplotypecaller/{sample}.log"
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk --java-options "-Xmx{params.mem_gb}g" HaplotypeCaller \
            -R {input.ref} -I {input.bam} -O {output} \
            -ERC GVCF -ploidy {params.ploidy} > {log} 2>&1
        """