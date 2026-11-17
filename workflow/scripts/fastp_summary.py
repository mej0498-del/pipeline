import csv
import json
from pathlib import Path

rows = []
for i in snakemake.input:
    with open(i) as f:
        a = json.load(f)

    old = a["summary"]["before_filtering"]
    new = a["summary"]["after_filtering"]
    filtered = a["filtering_result"]

    rows.append({
        "sample": Path(i).name.replace(".fastp.json", ""),
        "reads_before_fastp": old["total_reads"],
        "reads_after_fastp": new["total_reads"],
        "bases_before_fastp": old["total_bases"],
        "bases_after_fastp": new["total_bases"],
        "q30_before_fastp": round(old["q30_rate"], 4),
        "q30_after_fastp": round(new["q30_rate"], 4),
        "gc_after_fastp": round(new["gc_content"], 4),
        "too_short": filtered["too_short_reads"],
        "low_quality": filtered["low_quality_reads"],
        "duplication_rate": round(a["duplication"]["rate"], 4),
    })

with open(snakemake.output[0], "w", newline="") as output:
    w = csv.DictWriter(output, fieldnames=rows[0].keys(), delimiter="\t")
    w.writeheader()
    w.writerows(rows)
