# Milestone 1 – SDTM Domain Inventory

**Status:** Complete

## Objective

The goal of this milestone was to become familiar with the structure of an SDTM submission package before performing subject-level clinical data review. Rather than memorizing SDTM domain definitions, I explored the sponsor-provided datasets and metadata to understand the purpose of each domain, how the domains are organized, and what a single record represents.

## Study

**Sponsor:** Sanofi  
**Study:** EFC10261  
**Therapeutic Area:** Oncology — Non-Small Cell Lung Cancer

## Work Completed

During this milestone, I:

- Imported all available SDTM datasets into R.
- Created an automated inventory of every SDTM domain in the submission package.
- Calculated the number of records and variables in each dataset.
- Classified each domain according to the SDTM General Observation Model.
- Identified the observational unit represented by a record in each domain.
- Reviewed sponsor-defined domains using the study metadata, variable definitions, and record-level data.
- Distinguished subject-level domains from trial design domains.
- Used record counts and variable values to validate assumptions about unfamiliar domains.

## Deliverables

- `R/00_setup.R`
- `R/01_sdtm_inventory.R`
- `output/tables/sdtm_inventory.csv`

## SDTM Package Summary

The submission package contained 25 SDTM datasets:

| SDTM Class | Domains |
|---|---|
| Events | AE, CE, DS, MH |
| Findings | CD, EG, LB, LS, PC, PE, QS, SU, VS |
| Interventions | CM, EX, RA, SG |
| Special Purpose | DM, IE, SV, TA, TE, TI, TS, TV |

The complete inventory includes the description, SDTM class, record count, variable count, and observational unit for each domain.

## Skills Demonstrated

- R programming with `haven`, `dplyr`, `purrr`, and `readr`
- Programmatic discovery and import of SAS datasets
- SDTM package exploration
- SDTM domain classification
- Understanding of the General Observation Model
- Identification of domain-level observational units
- Review of sponsor-defined domains
- Trial design versus subject-level data interpretation
- Reproducible clinical data documentation

## Key Takeaways

This milestone strengthened my understanding of how SDTM datasets are organized within a clinical trial submission package. Examining both the dataset structure and sponsor metadata allowed me to determine the purpose of unfamiliar domains and identify what each record represents.

I also learned that domain abbreviations alone are not sufficient for understanding a dataset. Variable patterns, subject identifiers, timing variables, record counts, and actual data values must be evaluated together. This approach was particularly useful when reviewing sponsor-defined domains such as CD, RA, and SG and when distinguishing protocol-level domains such as TI and TV from subject-level domains such as IE and SV.

## Next Milestone

The next phase of the project will follow an individual subject across multiple SDTM domains to reconstruct the subject’s clinical journey. The review will connect demographic information, study visits, treatment exposure, adverse events, laboratory results, and vital signs across DM, SV, EX, AE, LB, VS, and other relevant domains.