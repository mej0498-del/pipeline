import csv
import glob
import os

rows = []
for r1 in sorted(glob.glob("data/raw/*_R1.fastq.gz")):
    sample = os.path.basename(r1).replace("_R1.fastq.gz", "")
    r2 = r1.replace("_R1.fastq.gz", "_R2.fastq.gz")
    rows.append([sample, "short", r1, r2])

with open("samples.tsv", "w", newline="") as f:
    w = csv.writer(f, delimiter="\t")
    w.writerow(["sample", "read_type", "r1", "r2"])
    w.writerows(rows)

print(f"Turned {len(rows)} samples to samples.tsv")