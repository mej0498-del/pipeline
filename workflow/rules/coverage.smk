rule perbase_bedgraph:
    input:
        bam="results/mapped/{sample}.mdup.bam",
        chrom="results/reference/chromosome.tab",
    output:
        temp("results/coverage/{sample}.perbase.bedGraph"),
    log:
        "logs/perbase_bedgraph/{sample}.log"
    conda:
        "../envs/coverage.yaml"
    shell:
        """
        (bedtools genomecov -ibam {input.bam} -g {input.chrom} -d \
         | awk -v OFS="\\t" '{{print $1, $2-1, $2, $3}}' \
         | bedtools sort -g {input.chrom} -i - > {output}) 2> {log}
        """


rule window_coverage:
    input:
        windows="results/reference/sliding_windows.bed",
        bedgraph="results/coverage/{sample}.perbase.bedGraph",
        chrom="results/reference/chromosome.tab",
    output:
        "results/coverage/{sample}.slidingwindow.tab",
    log:
        "logs/window_coverage/{sample}.log"
    conda:
        "../envs/coverage.yaml"
    shell:
        "bedtools map -a {input.windows} -b {input.bedgraph} -c 4 -o median "
        "-g {input.chrom} > {output} 2> {log}"