###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  3 - Cross-Domain Data Validation
#
# Script:     01_subject_integrity_validation.R
#
# Purpose:
#   Validate subject integrity across SDTM domains by confirming that all
#   subject IDs appearing in subject-level domains also exist in DM.
###############################################################################

# Project Setup

source("R/00_setup.R")

###############################################################################
# Load Required SDTM Domains

dm <- read_sas(file.path(raw_path, "dm.sas7bdat"))
ex <- read_sas(file.path(raw_path, "ex.sas7bdat"))
ae <- read_sas(file.path(raw_path, "ae.sas7bdat"))
lb <- read_sas(file.path(raw_path, "lb.sas7bdat"))
vs <- read_sas(file.path(raw_path, "vs.sas7bdat"))
qs <- read_sas(file.path(raw_path, "qs.sas7bdat"))

###############################################################################
# Create DM Subject Reference

dm_subjects <- unique(dm$RUSUBJID)

# Define Validation Scope
domains <- list(
  EX = ex,
  AE = ae,
  LB = lb,
  VS = vs,
  QS = qs
)

###############################################################################
# Run Subject Integrity Validation

subject_validation_results <- lapply(
  names(domains),
  function(domain_name) {
    
    domain_data <- domains[[domain_name]]
    
    domain_subjects <- unique(domain_data$RUSUBJID)
    
    subjects_missing_dm <- setdiff(
      domain_subjects,
      dm_subjects
    )
    
    summary <- data.frame(
      Validation = "Subject Integrity",
      Domain = domain_name,
      Check = "Subject exists in DM",
      Finding_Count = length(subjects_missing_dm),
      Status = ifelse(
        length(subjects_missing_dm) == 0,
        "PASS",
        "FAIL"
      )
    )
    
    if (length(subjects_missing_dm) == 0) {
      
      findings <- data.frame(
        Validation = character(0),
        Domain = character(0),
        RUSUBJID = character(0),
        VISITNUM = numeric(0),
        Issue = character(0)
      )
      
    } else {
      
      findings <- data.frame(
        Validation = "Subject Integrity",
        Domain = domain_name,
        RUSUBJID = subjects_missing_dm,
        VISITNUM = NA_real_,
        Issue = paste(
          "Subject present in",
          domain_name,
          "but missing from DM"
        )
      )
    }
    
    list(
      summary = summary,
      findings = findings
    )
  }
)

subject_validation_summary <- bind_rows(
  lapply(subject_validation_results, function(x) x$summary)
)

subject_validation_findings <- bind_rows(
  lapply(subject_validation_results, function(x) x$findings)
)
