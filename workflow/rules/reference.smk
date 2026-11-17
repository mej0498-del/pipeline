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