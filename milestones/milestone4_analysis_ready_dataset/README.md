# Milestone 4 – Analysis-Ready Dataset Exploration

## Objective

The objective of this milestone was to transform subject-level SDTM domains into analysis-ready datasets that resemble the structure and workflow of an ADaM ADSL dataset.

Rather than analyzing SDTM domains independently, this milestone focused on integrating information across domains and deriving subject-level variables suitable for downstream statistical analyses.

---

## Clinical Programming Objectives

This milestone demonstrates the ability to:

- Transform SDTM domains into subject-level analysis datasets
- Derive analysis variables from longitudinal clinical data
- Integrate multiple SDTM domains using subject identifiers
- Validate dataset structure and derived variables
- Build reproducible clinical programming workflows using R

---

## SDTM Domains Used

| Domain | Purpose |
|---------|---------|
| DM | Subject-level backbone |
| EX | Treatment exposure derivations |
| DS | Treatment disposition and last-contact derivations |

---

## Programming Workflow

## Programming Workflow

The milestone was implemented through three modular clinical programming workflows:

1. Build a subject-level exposure analysis component from SDTM EX.
2. Build a subject-level disposition analysis component from SDTM DS.
3. Integrate the derived analysis components with the subject-level DM dataset to create an ADSL-style analysis dataset.

Each program performs its own derivations, validation checks, and exports independently before being integrated into the final subject-level dataset.

### 01_build_ex_analysis.R

Created a subject-level exposure analysis component from the SDTM EX domain.

Derived variables include:

- DOCSDY
- DOCEDY
- DOCDUR
- PLBSDY
- PLBEDY
- PLBDUR
- TRTSDY
- TRTEDY
- TRTDUR

Validation confirmed:

- One record per subject
- No duplicate subject IDs
- No invalid treatment durations
- No treatment end days preceding treatment start days

---

### 02_build_ds_analysis.R

Created a subject-level disposition analysis component from the SDTM DS domain.

Derived variables include:

- EOTRSN
- LCONTDY
- LCONTST

Validation confirmed:

- One record per subject
- No duplicate subject IDs
- Complete end-of-treatment reason derivations
- Appropriate handling of missing last-contact records

---

### 03_build_adsl.R

Integrated the subject-level DM, EX, and DS analysis components into an ADSL-style dataset.

The program:

- Used DM as the subject-level backbone
- Joined exposure and disposition analysis datasets
- Preserved all randomized subjects
- Validated dataset structure
- Confirmed alignment between treatment exposure and safety population flags

---

## Design Decisions

Several programming decisions were made to ensure that the derived datasets reflected the underlying clinical data while maintaining traceability to the SDTM source domains.

- DM was used as the backbone of the ADSL dataset because it already contains one record per subject. Subject-level analysis components derived from EX and DS were integrated using `RUSUBJID`.

- Treatment duration was calculated as an inclusive study-day span (`TRTEDY - TRTSDY + 1`) to represent the total number of calendar days between the first and last recorded treatment days.

- Overall treatment timing was derived from treatment-specific exposure records using the earliest treatment start day and the latest treatment end day across protocol treatment components.

- Disposition data were summarized by clinically meaningful events rather than retaining all DS records. The final analysis component includes end-of-treatment reason and last-contact status as subject-level variables.

- End-of-treatment study day was intentionally not derived from the Subject Visits (SV) domain. Although end-of-treatment records reference scheduled study visits, the visit date does not necessarily represent the subject's final day of treatment exposure. Treatment timing was therefore derived exclusively from the EX domain, while DS was used to capture the reason for treatment discontinuation.

- Intermediate quality-control variables (such as exposure record counts and missing-date summaries) were used during development and validation but were intentionally excluded from the final analysis datasets because they support programming quality control rather than statistical analysis.
## Deliverables

### Programs

- 00_setup.R
- 01_build_ex_analysis.R
- 02_build_ds_analysis.R
- 03_build_adsl.R

### Derived Datasets

- milestone4_ex_analysis.csv
- milestone4_ds_analysis.csv
- milestone4_adsl.csv

### Validation Listings

- milestone4_ex_structure_validation.csv
- milestone4_ex_derivation_validation.csv
- milestone4_ds_structure_validation.csv
- milestone4_adsl_structure_validation.csv
- milestone4_adsl_population_validation.csv

---

## Skills Demonstrated

- CDISC SDTM data manipulation
- Subject-level dataset construction
- Cross-domain integration
- Analysis variable derivation
- Clinical programming validation
- Reproducible R programming
- Modular workflow design