import re
from pathlib import Path
import pandas as pd
configfile: "config.yaml"

samples = pd.read_csv(config["samples"], sep="\t", dtype=str).fillna("")

def validate_samples(df):
    required_cols = {"sample", "read_type", "r1", "r2"}
    missing_cols = required_cols - set(df.columns)
    if missing_cols:
        raise ValueError(f"samples.tsv is missing columns: {sorted(missing_cols)}")
    errors = []
     duplicates = df.loc[df["sample"].duplicated(), "sample"].tolist()
    if duplicates:
        errors.append(f"Duplicate sample names: {duplicates}")
    for _,row in df.iterrows():
        name = row["sample"]
        if not re.fullmatch(r"[A-Za-z0-9_.-]+", name):
            errors.append(f"{name}: use only letters, numbers, _ . -")
        if row["read_type"] not in "short":
            errors.append(f"{name}: read_type must be 'short'")
        if not row["r1"] or not Path(row["r1"]).exists():
            errors.append(f"{name}: r1 not found ({row['r1']})")
        if not row["r2"] or not Path(row["r2"]).exists():
            errors.append(f"{name}: short reads need r2 ({row['r2']})")
    if errors:
        raise ValueError("Sample sheet problems:\n  " + "\n  ".join(errors))

validate_samples(samples)
samples = samples.set_index("sample", drop=False)
SAMPLES = list(samples.index)

# Helper functions for rules to find each sample's reads
def read_1(wildcards):
    return samples.loc[wildcards.sample, "r1"]
def read_2(wildcards):
    return samples.loc[wildcards.sample, "r2"]

rule validated_samples:
    output: "results/inputs/samples_validated.tsv"
    run:
        samples.to_csv(output[0], sep="\t", index=False)