# Milestone 3: Cross-Domain Data Validation

## Objective

The objective of this milestone was to design and implement a reusable validation framework for SDTM datasets using R. Rather than validating individual records manually, automated validation programs were developed to evaluate the internal consistency of multiple SDTM domains and generate standardized validation summaries and reviewer listings.

This milestone focuses on applying clinical programming principles commonly used during data quality review prior to ADaM derivation and statistical analysis.

---

## Validation Framework

Three automated validation programs were developed to evaluate key aspects of SDTM data integrity:

### 1. Subject Integrity Validation

Confirmed that every subject appearing in the following SDTM domains also exists in the Demographics (DM) domain:

- Exposure (EX)
- Adverse Events (AE)
- Laboratory Results (LB)
- Vital Signs (VS)
- Questionnaires (QS)

**Result**

- 5 validation checks performed
- 0 findings identified
- All subject identifiers successfully mapped to DM

---

### 2. Visit Integrity Validation

Validated that each unique subject-visit combination recorded in the following domains also exists in the Subject Visits (SV) domain:

- Laboratory Results (LB)
- Vital Signs (VS)
- Questionnaires (QS)

Validation was performed using the unique combination of **RUSUBJID** and **VISITNUM**.

**Result**

- 3 validation checks performed
- 0 findings identified
- All subject-visit combinations were supported by the SV domain

---

### 3. Temporal Consistency Validation

Validated that end study day variables did not occur before their corresponding start study day variables across multiple SDTM domains.

The following domain pairs were evaluated:

| Domain | Validation Rule |
|---------|-----------------|
| AE | AEENDY ≥ AESTDY |
| EX | EXENDY ≥ EXSTDY |
| RA | RAENDY ≥ RASTDY |
| CM | CMENDY ≥ CMSTDY |

**Result**

- 4 validation checks performed
- 0 findings identified
- No temporal inconsistencies detected

---

## Programming Approach

Rather than writing separate validation programs for every SDTM domain, each validation was developed using a configuration-driven approach.

Each script defines:

- Validation scope
- Domain-specific variable mappings
- Reference datasets
- Validation rules

A common validation algorithm is then applied across all configured domains using `lapply()`, allowing additional domains or validation rules to be incorporated with minimal changes to the underlying code.

This approach improves code readability, maintainability, and scalability while reducing duplication across validation programs.

---

## Deliverables

### Validation Programs

- `01_subject_integrity_validation.R`
- `02_visit_integrity_validation.R`
- `03_temporal_consistency_validation.R`
- `99_compile_validation_results.R`

### Validation Outputs

- `milestone3_validation_summary.csv`
- `milestone3_validation_findings.csv`

---

## Validation Summary

| Validation | Checks | Findings | Status |
|------------|-------:|---------:|:------:|
| Subject Integrity | 5 | 0 | ✅ PASS |
| Visit Integrity | 3 | 0 | ✅ PASS |
| Temporal Consistency | 4 | 0 | ✅ PASS |
| **Total** | **12** | **0** | **PASS** |

---

## Skills Demonstrated

- Clinical data validation
- SDTM cross-domain review
- Cross-domain consistency checks
- Functional programming using `lapply()`
- Configuration-driven R programming
- Automated validation reporting
- Data quality assessment using `dplyr`
- Reusable validation framework design
- Software architecture for scalable clinical programming workflows

---

## Key Learning Outcomes

This milestone expanded beyond basic SDTM exploration into the development of reusable clinical programming workflows. Instead of writing one-off validation programs, the focus shifted toward designing configurable validation algorithms capable of evaluating multiple SDTM domains while producing standardized reviewer outputs.

The resulting framework demonstrates an approach similar to that used in production clinical programming environments, where maintainability, automation, and reproducibility are essential components of data validation.