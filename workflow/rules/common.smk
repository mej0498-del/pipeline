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
   