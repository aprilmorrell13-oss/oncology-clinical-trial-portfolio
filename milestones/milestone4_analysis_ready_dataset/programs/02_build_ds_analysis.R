###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  4 - Analysis-Ready Dataset Exploration
#
# Script:     02_build_ds_analysis.R
#
# Purpose:
#   Create a subject-level disposition analysis component from the SDTM DS
#   domain for later integration into an ADSL-style dataset.
###############################################################################


# -----------------------------------------------------------------------------
# 1. Load Milestone Setup
# -----------------------------------------------------------------------------

source(
  "milestones/milestone4_analysis_ready_dataset/programs/00_setup.R"
)


# -----------------------------------------------------------------------------
# 2. Read Source Data
# -----------------------------------------------------------------------------

ds <- read_sas(
  file.path(
    raw_path,
    "ds.sas7bdat"
  )
)

# -----------------------------------------------------------------------------
# 3. Create End-of-Treatment Summary
# -----------------------------------------------------------------------------

eot_summary <- ds %>%
  filter(DSSCAT == "END OF TREATMENT") %>%
  transmute(
    RUSUBJID,
    EOTRSN = DSDECOD
  )

# -----------------------------------------------------------------------------
# 4. Create Last-Contact Summary
# -----------------------------------------------------------------------------

lt_summary <- ds %>%
  filter(DSSCAT == "LAST CONTACT") %>%
  transmute(
    RUSUBJID,
    LCONTDY = DSSTDY,
    LCONTST = DSDECOD
  )

# -----------------------------------------------------------------------------
# 5. Create Subject-Level DS Analysis Dataset
# -----------------------------------------------------------------------------

ds_analysis <- full_join(
  eot_summary,
  lt_summary,
  by = "RUSUBJID"
)

# -----------------------------------------------------------------------------
# 6. Validate Subject-Level DS Analysis Structure
# -----------------------------------------------------------------------------

ds_structure_validation <- ds_analysis %>%
  summarise(
    n_records = n(),
    n_unique_subjects = n_distinct(RUSUBJID),
    n_duplicate_subjects = n() - n_distinct(RUSUBJID),
    n_missing_eot_reason = sum(is.na(EOTRSN)),
    n_missing_last_contact_day = sum(is.na(LCONTDY)),
    n_missing_last_contact_record = sum(is.na(LCONTST)),
    validation_status = if_else(
      n_duplicate_subjects == 0,
      "PASS",
      "FAIL"
    )
  )

# -----------------------------------------------------------------------------
# 7. Export Milestone 4 DS Outputs
# -----------------------------------------------------------------------------

write_csv(
  ds_analysis,
  file.path(
    milestone4_derived_path,
    "milestone4_ds_analysis.csv"
  ),
  na = ""
)

write_csv(
  ds_structure_validation,
  file.path(
    milestone4_listing_path,
    "milestone4_ds_structure_validation.csv"
  ),
  na = ""
)