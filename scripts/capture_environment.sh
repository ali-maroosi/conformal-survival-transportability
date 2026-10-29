#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

OUT="manuscript/reproducibility"
mkdir -p "$OUT"

echo "Capturing software environment..."

# ------------------------------------------
# 1. Python and key package versions
# ------------------------------------------

python - <<'PY' > "$OUT/software_versions.json"
import json
import platform
import sys
from importlib import metadata

packages = [
    "numpy",
    "pandas",
    "scipy",
    "scikit-learn",
    "scikit-survival",
    "lifelines",
    "matplotlib",
    "seaborn",
    "statsmodels",
    "joblib",
    "optuna",
    "tqdm",
    "ipykernel",
    "jupyterlab"
]

versions = {}

for package in packages:
    try:
        versions[package] = metadata.version(package)
    except metadata.PackageNotFoundError:
        versions[package] = None

info = {
    "python_version": sys.version.split()[0],
    "platform": platform.system(),
    "architecture": platform.machine(),
    "packages": versions
}

print(json.dumps(info, indent=4))
PY

# ------------------------------------------
# 2. Complete pip package snapshot
# ------------------------------------------

python -m pip freeze --all > "$OUT/pip_freeze.txt"

# ------------------------------------------
# 3. Conda package versions and environment
# ------------------------------------------

if command -v conda >/dev/null 2>&1; then

    conda list --export \
        > "$OUT/conda_packages.txt"

    conda env export --from-history \
        | sed '/^prefix:/d' \
        > "$OUT/environment.yml"

else
    echo "Conda not found" \
        > "$OUT/conda_packages.txt"
fi

# ------------------------------------------
# 4. Raw data file hashes
# No patient data is copied
# ------------------------------------------

if compgen -G "data/raw/*.tsv" > /dev/null; then
    sha256sum data/raw/*.tsv \
        > "$OUT/raw_data_sha256.txt"
fi

echo ""
echo "Environment capture completed."
echo "Files created in: $OUT"

ls -lh "$OUT"
