<div align="center">

# Conformal Survival Prediction Under Distribution Shift

**Censoring-aware calibration · Breast cancer cohort transportability · Simulation-based stress testing**

[![Python](https://img.shields.io/badge/Python-3.14.4-3776AB?logo=python&logoColor=white)](#software-environment)
[![Survival analysis](https://img.shields.io/badge/Outcome-Overall%20Survival-0D9488)](#data-sources-and-study-populations)
[![External validation](https://img.shields.io/badge/External%20cohort-TCGA--BRCA-5B21B6)](#data-sources-and-study-populations)

**How robust and informative are conformal survival lower bounds when censoring patterns and patient populations change?**

</div>

> **Release status: research code and executed notebook.** This repository contains the primary research notebook, including its saved execution outputs, and environment-capture tooling. Raw clinical data, separately exported tables and figures, local manuscript files, and downloaded reference implementations are deliberately excluded from version control. The repository is **not yet verified as a clean, one-command reproduction** of every analysis.

## Research overview

Accurate survival estimates alone do not provide a calibrated lower bound on an individual's event time. Right censoring and differences between development and target populations make calibration and evaluation more challenging. This project examines **coverage, predictive informativeness, and cross-cohort transportability** of conformal survival lower predictive bounds (LPBs).

The workflow combines:

- Random Survival Forest (RSF) modeling and conformal calibration;
- Naive, Focused, and Fused procedures;
- exploratory density-ratio-weighted variants under covariate shift;
- internal METABRIC and external TCGA-BRCA evaluation with censoring-aware diagnostics;
- controlled Monte Carlo simulation and an independent DR-COSARC benchmark.

**Important:** Performance in a new cohort is an empirical finding, not a blanket finite-sample guarantee under arbitrary censoring or distribution shift. The weighted extensions studied here should not be described as having newly proven theoretical coverage guarantees.

## Data sources and study populations

| Population | Role | Analytical sample |
|---|---|---:|
| [METABRIC](https://www.cbioportal.org/study/summary?id=brca_metabric) | Source cohort for training, calibration, and internal testing | 1,981 OS-eligible patients out of 2,509 initial records |
| METABRIC training | Survival model fitting | 1,188 |
| METABRIC calibration | Calibration procedures | 396 |
| METABRIC internal test | Held-out evaluation | 397 |
| [TCGA-BRCA PanCancer Atlas](https://www.cbioportal.org/study/summary?id=brca_tcga_pan_can_atlas_2018) | Independent external assessment | 1,084 |

The endpoint is **overall survival (OS)**, with event occurrence distinguished from right censoring. Different distributions of follow-up and censoring must be considered when interpreting results. The external, transportable predictor set consists of harmonized **age and histology**; other clinical and extended configurations are evaluated in the source-cohort workflow.

Download the clinical input files from the study providers, subject to applicable terms. **Do not redistribute patient-level data through this repository.**

### Expected local input files

The notebook expects to be run from its `notebooks/` directory, using these local paths relative to the notebook:

```text
data/raw/brca_metabric_clinical_data.tsv
data/raw/brca_tcga_pan_can_atlas_2018_clinical_data.tsv
```

These files are intentionally omitted from Git. Preserve the study-specific field names and inspect event coding, missingness, and survival time origins before reproducing the workflow.

## Methods in brief

1. **Data quality and cohort construction:** inspect outcome availability, coding, and missingness; create nonoverlapping patient-level METABRIC splits.
2. **Survival modeling:** train and tune RSF-based predictors using the source training partition; use harmonized predictors for cross-cohort transport.
3. **Conformal calibration:** evaluate Naive, Focused, and Fused approaches and exploratory weighted variations; keep fitting, calibration, and evaluation roles distinct.
4. **External evaluation:** apply the fixed trained survival predictor to TCGA-BRCA and examine empirical coverage, LPB informativeness, and censoring-model sensitivity.
5. **Simulation and independent benchmark:** study no-shift, favorable/adverse-shift, and other stress scenarios; compare against the independent [DR-COSARC implementation](https://github.com/emonzhw/conformal-survival).

The main outcome summaries are **IPCW-adjusted empirical coverage** where appropriate and the **median LPB (months)**. IPCW depends on censoring assumptions and positivity; reverse Kaplan–Meier follow-up summaries characterize observation duration, not the distribution of true event times.

## Repository structure

```text
conformal-survival-transportability/
├── README.md
├── .gitignore
├── LICENSE                         # if present in the GitHub repository
├── notebooks/
│   └── main.ipynb                  # full research notebook + saved outputs
├── scripts/
│   └── capture_environment.sh     # exports current environment metadata
└── environment/                    # created by running the capture script
    ├── environment.yml             # full Conda spec, no build strings
    ├── conda-history.yml           # explicitly requested Conda packages
    ├── conda-explicit-linux-64.txt  # Conda package URLs for Linux x86_64
    ├── conda-packages.txt          # Conda package inventory
    ├── pip-freeze.txt              # pip-installed package snapshot
    └── software-versions.json      # selected library versions
```

`data/`, `results/`, `figures/`, `references/`, and `manuscript/` exist only locally when populated; they are ignored by Git. **Plots and printed tables may still be visible as saved outputs inside `notebooks/main.ipynb`** and are not a substitute for regenerating the analysis.

## Software environment

The recorded development environment was **WSL/Ubuntu (Linux x86_64), Conda environment `master_thsis`**, with the following reported versions:

| Component | Version | Component | Version |
|---|---|---|---|
| Python | 3.14.4 | NumPy | 2.4.4 |
| pandas | 2.3.3 | SciPy | 1.17.1 |
| scikit-learn | 1.8.0 | scikit-survival | 0.27.0 |
| lifelines | 0.30.3 | Matplotlib | 3.10.8 |
| seaborn | 0.13.2 | joblib | 1.5.3 |
| ipykernel | 7.2.0 | | |

These versions document the original environment; the **full export** is preferred for reconstructing its dependency graph. A `pip freeze` file or a `conda-history.yml` file alone is **not** a complete, tested lockfile for a mixed Conda/pip environment.

### Capture the original environment

On the original machine, from the repository root:

```bash
conda activate master_thsis
bash scripts/capture_environment.sh
```

Review all files in `environment/` for private URLs, tokens, local paths, and proprietary packages **before committing them**. The script does not copy source clinical datasets. The environment files are designed to be committed after review; unlike `manuscript/`, the `environment/` directory is **not Git-ignored**.

### Reconstruct the environment (Linux, recommended)

After the verified `environment/environment.yml` has been committed:

```bash
conda env create -f environment/environment.yml -n conformal-survival-repro
conda activate conformal-survival-repro
python -c "import numpy, pandas, scipy, sklearn, sksurv, lifelines; print('Core imports OK')"
```

The Conda environment export records package versions and includes pip dependencies where detected. Solvers, wheels, and compiled libraries can change; **exact binary identity and successful reproduction are not guaranteed on every system**. The Linux-specific `conda-explicit-linux-64.txt` is a record of exact Conda builds, but does not by itself restore pip-only packages. The environment must be tested with a fresh installation before describing the repository as fully reproducible.

### Run the notebook

Start Jupyter from the notebook directory (the relative paths above matter):

```bash
cd notebooks
jupyter lab main.ipynb
```

JupyterLab might need installation in the reconstructed environment; `ipykernel` alone does not imply `jupyterlab` is installed. Use the Python interpreter/kernel corresponding to the reconstructed Conda environment. **Running all cells requires the data files and external benchmark dependencies described below.**

### Independent benchmark dependencies

The benchmark sections import an external Python implementation from `../references/sesia_python/src`. Download it locally if you intend to rerun those sections:

```bash
mkdir -p references
git clone https://github.com/emonzhw/conformal-survival.git references/sesia_python
```

The [authors' R reference implementation](https://github.com/msesia/conformal_survival) can be stored in `references/sesia_official` for implementation comparison; it is not bundled or licensed by this project. The exact third-party commit revisions and installation requirements should be recorded for a fully reproducible benchmark.

## Results and interpretation

The saved notebook presents descriptive data audits, modeling diagnostics, internal and external coverage estimates, simulations, and benchmark comparisons. All numerical claims in any accompanying manuscript should be traced to the relevant executed cell and validated against rerun outputs.

- **Coverage is not informativeness:** longer LPBs may be more informative but can reduce empirical coverage.
- **Internal is not external validation:** source-cohort hold-out estimates do not establish transportability.
- **IPCW depends on assumptions:** high censoring or extreme weights can make coverage estimates unstable.
- **Simulation and real-world validation are distinct:** oracle weighting is a simulation comparator, not a deployable clinical workflow.
- **Methodological audit remains essential:** numerical consistency tests alone do not prove all assumptions or theoretical guarantees.

## Reproducibility checklist

- [x] Analysis notebook with saved outputs committed
- [x] Raw data and separately exported results excluded from Git
- [x] Environment-capture script available
- [ ] Full environment export generated and reviewed for confidential paths
- [ ] Environment metadata committed to `environment/`
- [ ] External implementation revisions recorded
- [ ] End-to-end rerun verified in a clean environment
- [ ] Final manuscript and source-data provenance documented

## References and citation

- [METABRIC cohort](https://www.cbioportal.org/study/summary?id=brca_metabric)
- [TCGA-BRCA PanCancer Atlas](https://www.cbioportal.org/study/summary?id=brca_tcga_pan_can_atlas_2018)
- [Sesia & Svetnik, *Doubly Robust Conformalized Survival Analysis with Right-Censored Data* (ICML 2025)](https://proceedings.mlr.press/v267/sesia25a.html)
- [DR-COSARC Python implementation](https://github.com/emonzhw/conformal-survival)

Until a manuscript or archived software release has a persistent identifier, cite the repository with its exact Git commit or release tag:

> Maroosi, A. *Conformal Survival Transportability* [research software]. GitHub: https://github.com/ali-maroosi/conformal-survival-transportability

## License and data governance

See the repository's `LICENSE` file for the license, **if that file is present**. No license granted for original code automatically grants permission to redistribute third-party clinical datasets or external reference implementations.

---

<div align="center">

*Reliable survival prediction requires transparent calibration, honest censoring assumptions, and validation beyond the development cohort.*

</div>
