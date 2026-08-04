# Oncology Clinical Programming Portfolio

This repository presents a series of hands-on clinical programming projects developed using a publicly available oncology clinical trial submission package.

Using data from the Sanofi EFC10261 Phase II Non-Small Cell Lung Cancer (NSCLC) study, I built reproducible clinical programming workflows that reflect tasks commonly performed by clinical and statistical programmers. The portfolio progresses from SDTM data exploration through cross-domain validation, analysis-ready dataset development, and an end-to-end treatment-emergent adverse event case study.

---

## Study

- **Sponsor:** Sanofi
- **Study:** EFC10261
- **Therapeutic Area:** Non-Small Cell Lung Cancer (NSCLC)
- **Study Phase:** Phase II
- **Data Standard:** CDISC SDTM
- **Programming Language:** R

---

## Portfolio Roadmap

| Milestone | Status |
|---|---|
| ✅ Milestone 1 – SDTM Domain Inventory | Complete |
| ✅ Milestone 2 – Subject-Level Clinical Review | Complete |
| ✅ Milestone 3 – Cross-Domain Data Validation | Complete |
| ✅ Milestone 4 – Analysis-Ready Dataset Exploration | Complete |
| ✅ Milestone 5 – Clinical Programming Case Study | Complete |

---

## Completed Milestones

### Milestone 1 – SDTM Domain Inventory

Reviewed the structure of the SDTM submission package, classified domains according to CDISC observation classes, and developed a reproducible workflow for documenting domain contents and study coverage.

📁 `milestones/milestone1_sdtm_domain_inventory/`

---

### Milestone 2 – Subject-Level Clinical Review

Reconstructed the clinical course of a selected study participant by integrating treatment exposure, adverse events, disposition, target lesion assessments, and patient-reported outcomes across multiple SDTM domains.

The milestone demonstrates how clinical programmers use longitudinal data to understand a subject’s treatment history and clinical experience.

📁 `milestones/milestone2_subject_clinical_review/`

---

### Milestone 3 – Cross-Domain Data Validation

Developed a reproducible validation workflow to assess subject integrity, visit consistency, and temporal consistency across multiple SDTM domains.

The checks confirmed that:

- Subjects appearing in the reviewed clinical domains were present in DM
- Subject-visit combinations were represented in SV
- No reviewed records had end study days preceding start study days

📁 `milestones/milestone3_cross_domain_validation/`

---

### Milestone 4 – Analysis-Ready Dataset Exploration

Created subject-level analysis components from SDTM EX and DS and integrated them with the DM backbone to produce an ADSL-style dataset.

The workflow derives treatment timing, treatment duration, end-of-treatment reason, last-contact information, and safety population status while preserving one record per subject.

📁 `milestones/milestone4_analysis_ready_datasets/`

---

### Milestone 5 – Clinical Programming Case Study

Completed an end-to-end clinical safety programming case study using adverse-event data.

The milestone includes:

- SDTM AE source-data assessment
- ADAE-style dataset development
- Treatment-period and treatment-emergent flag derivation
- TEAE incidence summaries by System Organ Class and Preferred Term
- Toxicity-grade and seriousness summaries
- A top-15 TEAE incidence figure
- Programmatic validation and quality-control checks
- An employer-facing clinical programming report

📁 `milestones/milestone5_case_study/`

---

## Portfolio Progression

The milestones follow the progression of a clinical programming workflow:

1. Understand the structure and content of the SDTM submission
2. Review an individual subject across clinical domains
3. Validate data consistency across domains
4. Transform SDTM data into subject-level analysis datasets
5. Produce an end-to-end clinical safety analysis with tables, listings, figures, and reporting

---

## Skills Demonstrated

- R programming with the tidyverse
- CDISC SDTM data review and manipulation
- Clinical trial data exploration
- Oncology clinical data interpretation
- Subject-level longitudinal review
- Cross-domain data integration
- Clinical data validation and quality control
- ADSL-style dataset construction
- ADAE-style dataset construction
- Analysis-variable derivation
- Treatment-emergent adverse event analysis
- Safety population and denominator management
- System Organ Class and Preferred Term summarization
- Toxicity-grade and seriousness analysis
- Subject-incidence and event-frequency analysis
- Longitudinal and safety-data visualization using ggplot2
- Tables, listings, and figures
- Reviewer-friendly technical reporting
- Reproducible and modular programming workflows
- Git and GitHub version control

---

## Repository Structure

```text
data/
└── raw/

docs/

milestones/
├── milestone1_sdtm_domain_inventory/
│   ├── programs/
│   ├── derived/
│   ├── output/
│   └── README.md
├── milestone2_subject_clinical_review/
│   ├── programs/
│   ├── derived/
│   ├── output/
│   └── README.md
├── milestone3_cross_domain_validation/
│   ├── programs/
│   ├── derived/
│   ├── output/
│   └── README.md
├── milestone4_analysis_ready_datasets/
│   ├── programs/
│   ├── derived/
│   ├── output/
│   └── README.md
└── milestone5_case_study/
    ├── programs/
    ├── derived/
    ├── output/
    │   ├── figures/
    │   ├── listings/
    │   └── tables/
    └── README.md