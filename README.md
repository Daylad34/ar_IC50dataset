# ChEMBL36 Androgen receptor data curation
# Androgen Receptor IC50 Assay Concordance Analysis

## Overview
This repository contains a Python-based analytical workflow for assessing **concordance between biochemical IC50 assays targeting the Androgen Receptor (AR; CHEMBL1871)** using curated data from the **ChEMBL database**.

The analysis quantifies **assay-to-assay variability**, evaluates **experimental agreement**, and identifies systematic bias between overlapping biochemical assays.

---

## Methods Summary

### Data Source
- **ChEMBL database**
- Target: **Androgen Receptor (CHEMBL1871)**
- Target type: *Single protein*
- Assay type: *Biochemical*
- Endpoint: **IC50 (nM), expressed as pChEMBL**
- Confidence score ≥ 9
- Equality relations only (`standard_relation = '='`)

---

### Data Curation
The workflow applies the following filters:
- Removal of assays with missing or invalid measurements
- Restriction to **Goldilocks assay sizes** (default: 20–100 compounds)
- Exclusion of **mutant AR variants** (e.g., AR-V7, T878A, F877L, L702H)
- Retention of assays sharing a minimum number of overlapping compounds

---

### Assay Pair Construction
Pairs of assays are constructed based on:
- Shared compounds (`molregno`)
- Minimum overlap threshold (default: ≥5 compounds)

Matched compound activities are extracted for pairwise comparison.

---

### Statistical Analysis
The following metrics are computed to assess assay concordance:
- Coefficient of determination (R²)
- Median Absolute Error (MAE)
- Spearman rank correlation (ρ)
- Kendall’s Tau (τ)
- Fraction of compound pairs exceeding:
  - 0.3 log units (approximate experimental error)
  - 1.0 log unit (biologically meaningful deviation)

---

### Visualisation
The workflow generates:
- Scatter plots of paired pChEMBL values with ±1 log unit reference lines
- Histograms of absolute error distributions
- Ranked tables of assay-pair bias based on mean pChEMBL differences

---

## Main Functions

### `gather_data(engine, ...)`
Queries and curates ChEMBL biochemical assay data and returns overlapping assay pairs suitable for concordance analysis.

### `show_comparison(pts, title=...)`
Performs statistical analysis, generates visualisations, and prints summary metrics.

---

## Usage
```python
data_points = gather_data(engine)
show_comparison(data_points)
