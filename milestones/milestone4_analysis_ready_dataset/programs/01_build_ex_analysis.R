# ==============================================================================
# Milestone 4: Analysis-Ready Dataset Exploration
# Program: 01_build_exposure_summary.R
#
# Purpose:
#   Create a subject-level exposure summary from the SDTM EX domain.
#
# Input:
#   EX - Exposure
#
# Output:
#   ex_analysis - One record per subject containing treatment-specific and
#                 overall exposure timing variables.
#
# Key Derivations:
#   - First and last exposure days by treatment component
#   - Treatment-specific exposure-period durations
#   - Overall study treatment start day, end day, and duration
#
# Notes:
#   - Records with missing exposure start and end days do not contribute to
#     exposure timing derivations.
#   - Duration variables represent inclusive calendar-day spans and do not
#     represent the number of actual dosing days.
# ==============================================================================


# ------------------------------------------------------------------------------
# 1. Load Packages

source("R/00_setup.R")
library(tidyverse)

# ------------------------------------------------------------------------------
# 1. Read in Datasets

dm <- read_sas(file.path(raw_path, "dm.sas7bdat"))
ex <- read_sas(file.path(raw_path, "ex.sas7bdat"))
ds <- read_sas(file.path(raw_path, "ds.sas7bdat"))

# ------------------------------------------------------------------------------
# 2. Create Subject-by-Treatment Exposure Summary

ex_summary <- ex %>%
  group_by(RUSUBJID, EXTRT) %>%
  summarise(
    first_ex_day = if_else(
      all(is.na(EXSTDY)),
      NA_real_,
      min(EXSTDY, na.rm = TRUE)
    ),
    last_ex_day = if_else(
      all(is.na(EXENDY)),
      NA_real_,
      max(EXENDY, na.rm = TRUE)
    ),
    n_ex_records = n(),
    n_dated_ex_records = sum(
      !is.na(EXSTDY) & !is.na(EXENDY)
    ),
    n_missing_date_records = sum(
      is.na(EXSTDY) & is.na(EXENDY)
    ),
    .groups = "drop"
  )

# ------------------------------------------------------------------------------
# 3. Reshape Exposure Summary to One Record per Subject

ex_wide <- ex_summary %>%
  pivot_wider(
    names_from = EXTRT,
    values_from = c(
      first_ex_day,
      last_ex_day,
      n_ex_records,
      n_dated_ex_records,
      n_missing_date_records
    )
  )

# ------------------------------------------------------------------------------
# 4. Rename Analysis Variables

ex_analysis <- ex_wide %>%
  rename(
    
    DOCSDY = first_ex_day_DOCETAXEL,
    DOCEDY = last_ex_day_DOCETAXEL,
    
    PLBSDY = first_ex_day_PLACEBO,
    PLBEDY = last_ex_day_PLACEBO
    
  )

# ------------------------------------------------------------------------------
# 5. Derive Exposure Variables

ex_analysis <- ex_analysis %>%
  mutate(
    
    DOCDUR = if_else(
      is.na(DOCSDY) | is.na(DOCEDY),
      NA_real_,
      DOCEDY - DOCSDY + 1
    ),
    
    PLBDUR = if_else(
      is.na(PLBSDY) | is.na(PLBEDY),
      NA_real_,
      PLBEDY - PLBSDY + 1
    ),
    
    TRTSDY = if_else(
      is.na(DOCSDY) & is.na(PLBSDY),
      NA_real_,
      pmin(DOCSDY, PLBSDY, na.rm = TRUE)
    ),
    
    TRTEDY = if_else(
      is.na(DOCEDY) & is.na(PLBEDY),
      NA_real_,
      pmax(DOCEDY, PLBEDY, na.rm = TRUE)
    ),
    
    TRTDUR = if_else(
      is.na(TRTSDY) | is.na(TRTEDY),
      NA_real_,
      TRTEDY - TRTSDY + 1
    )
    
  )

# ------------------------------------------------------------------------------
# 6. Validate Subject-Level Dataset Structure

ex_structure_validation <- ex_analysis %>%
  summarise(
    n_records = n(),
    n_unique_subjects = n_distinct(RUSUBJID),
    n_duplicate_subjects = n() - n_distinct(RUSUBJID)
  )

# ------------------------------------------------------------------------------
# 7. Validate Exposure Derivations

ex_derivation_validation <- ex_analysis %>%
  summarise(
    n_missing_docetaxel_duration = sum(
      is.na(DOCDUR)
    ),
    n_missing_placebo_duration = sum(
      is.na(PLBDUR)
    ),
    n_missing_overall_duration = sum(
      is.na(TRTDUR)
    ),
    
    n_invalid_docetaxel_duration = sum(
      DOCDUR <= 0,
      na.rm = TRUE
    ),
    n_invalid_placebo_duration = sum(
      PLBDUR <= 0,
      na.rm = TRUE
    ),
    n_invalid_overall_duration = sum(
      TRTDUR <= 0,
      na.rm = TRUE
    ),
    
    n_docetaxel_end_before_start = sum(
      DOCEDY < DOCSDY,
      na.rm = TRUE
    ),
    n_placebo_end_before_start = sum(
      PLBEDY < PLBSDY,
      na.rm = TRUE
    ),
    n_overall_end_before_start = sum(
      TRTEDY < TRTSDY,
      na.rm = TRUE
    ),
    
    n_overall_duration_shorter_than_component = sum(
      TRTDUR < DOCDUR |
        TRTDUR < PLBDUR,
      na.rm = TRUE
    )
  )

# ------------------------------------------------------------------------------
# 8. Export outputs

write_csv(ex_analysis, file.path(derived_path, "ex.analysis.csv"))

write_csv(ex_structure_validation, file.path(listing_path, "ex_structure_validation.csv"))

write_csv(ex_derivation_validation, file.path(listing_path, "ex_derivation_validation.csv"))
