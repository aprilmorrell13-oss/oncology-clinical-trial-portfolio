# Milestone 5 – Clinical Programming Case Study

## Objective

The objective of this milestone was to complete an end-to-end clinical safety programming case study using adverse-event data from the Sanofi EFC10261 Phase II non-small cell lung cancer trial.

This milestone builds upon the subject-level analysis dataset developed in Milestone 4 by creating an ADAE-style dataset, applying treatment-emergent adverse-event logic, and producing safety tables and a figure suitable for clinical review.

---

## Clinical Programming Objectives

This milestone demonstrates the ability to:

* Assess an SDTM adverse-event domain before analysis
* Create an analysis-ready adverse-event dataset
* Merge event-level and subject-level clinical data
* Derive treatment-period and treatment-emergent flags
* Apply safety population and denominator logic
* Summarize adverse events by subject incidence and event frequency
* Analyze toxicity grade and seriousness
* Produce reproducible safety tables, listings, and figures
* Validate clinical programming outputs

---

## Source Data

| Dataset          | Purpose                                                                 |
| ---------------- | ----------------------------------------------------------------------- |
| SDTM AE          | Event-level adverse-event source data                                   |
| Milestone 4 ADSL | Subject-level treatment dates, demographics, and safety population flag |

The Milestone 4 ADSL-style dataset was used as the subject-level analysis backbone and merged with AE using `RUSUBJID`.

---

## Programming Workflow

The milestone was implemented through five clinical programming workflows.

### 01_ae_source_assessment.R

Assessed the structure and clinical content of the SDTM AE domain.

The assessment reviewed:

* Adverse-event terminology
* Event timing
* Toxicity grade
* Seriousness
* Relationship to treatment
* Action taken
* Outcome
* Event pattern
* Treatment-period information

The resulting listings document important source-data characteristics and support the subsequent analysis decisions.

### 02_build_adae.R

Created an ADAE-style analysis dataset by:

* Starting with SDTM AE records
* Merging subject-level variables from ADSL
* Deriving treatment-period flags
* Deriving the treatment-emergent adverse-event flag
* Preserving traceability to the source data
* Validating record counts and subject membership

### 03_create_teae_summary.R

Created a treatment-emergent adverse-event summary at three levels:

1. Overall TEAE incidence
2. System Organ Class
3. Preferred Term within System Organ Class

The output includes both unique-subject incidence and total event frequency.

### 04_create_teae_figure.R

Created a horizontal bar chart displaying the top 15 TEAE Preferred Terms by subject incidence.

The figure uses the safety population as the denominator and includes reproducible ordering and alphabetical handling of tied counts.

### 05_create_teae_grade_summary.R

Created a subject-level summary of:

* Any TEAE
* Maximum observed toxicity grade
* Maximum Grade 3 or higher
* At least one serious TEAE

Each subject is counted once within each analysis category.

---

## Key Design Decisions

* The safety population was defined using `SAFETY == "Y"` from the Milestone 4 ADSL-style dataset.

* Treatment-emergent analyses were restricted to records with `TRTEMFL == "Y"` among safety population subjects.

* Subject-incidence percentages use all 453 safety subjects as the denominator, including subjects who did not experience a TEAE.

* Subject incidence and event frequency were retained separately. A subject contributes only once to an incidence row but may contribute multiple adverse-event records to the corresponding event count.

* Toxicity intensity was summarized using `AETOXGR` because the study does not include the standard SDTM severity variable `AESEV`.

* Maximum toxicity grade was derived by collapsing qualifying TEAE records to one record per subject.

* Subjects without a TEAE retain a missing maximum toxicity grade rather than being assigned Grade 0 because Grade 0 was not present in the source data.

* Analysis-ready and presentation-ready versions of the summary tables were saved separately to support both quality control and reporting.

---

## Deliverables

### Programs

* 00_setup.R
* 01_ae_source_assessment.R
* 02_build_adae.R
* 03_create_teae_summary.R
* 04_create_teae_figure.R
* 05_create_teae_grade_summary.R

### Derived Dataset

* milestone5_adae.csv

### Tables

* teae_summary_analysis.csv
* teae_summary_table.csv
* teae_grade_summary_analysis.csv
* teae_grade_summary_table.csv

### Figure

* top_15_teae_incidence.png

### Validation and Source-Assessment Listings

* ADAE flag and classification summaries
* AE terminology and timing summaries
* Toxicity-grade and seriousness counts
* Relationship, action-taken, and outcome counts
* Event-pattern and treatment-period summaries

---

## Validation Approach

Validation checks were incorporated throughout the programs to confirm:

* Correct safety population and TEAE denominators
* Valid subject membership
* Expected dataset structures
* One record per subject where required
* Valid treatment-period classifications
* Complete output categories
* Subject counts that do not exceed the safety denominator
* Consistency between toxicity-grade summary categories
* Reproducible selection and ordering of the top 15 TEAEs

Detailed methods, results, clinical interpretation, and output review are presented in the Milestone 5 case-study report.

---

## Skills Demonstrated

* SDTM adverse-event data review
* ADAE-style dataset construction
* Treatment-emergent adverse-event derivation
* Safety population management
* Subject-level and event-level analysis
* Clinical terminology hierarchy
* Toxicity-grade and seriousness analysis
* Table, listing, and figure production
* Programmatic quality control
* Reproducible R programming
* Clinical programming documentation
