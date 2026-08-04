###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  4 - Analysis-Ready Dataset Exploration
#
# Script:     03_build_adsl_style.R
#
# Purpose:
#   Create an ADSL-style subject-level analysis dataset by using DM as the
#   subject-level backbone and integrating derived exposure and disposition
#   analysis components.
###############################################################################


# -----------------------------------------------------------------------------
# 1. Load Milestone Setup
# -----------------------------------------------------------------------------

source(
  "milestones/milestone4_analysis_ready_dataset/programs/00_setup.R"
)

# -----------------------------------------------------------------------------
# 2. Read Source and Derived Data
# -----------------------------------------------------------------------------

dm <- read_sas(
  file.path(
    raw_path,
    "dm.sas7bdat"
  )
)

ex_analysis <- read_csv(
  file.path(
    milestone4_derived_path,
    "milestone4_ex_analysis.csv"
  ),
  show_col_types = FALSE
)

ds_analysis <- read_csv(
  file.path(
    milestone4_derived_path,
    "milestone4_ds_analysis.csv"
  ),
  show_col_types = FALSE
)

# -----------------------------------------------------------------------------
# 3. Create Subject-Level DM Backbone
# -----------------------------------------------------------------------------

dm_adsl <- dm %>%
  select(
    STUDYID,
    RUSUBJID,
    AGE,
    AGEU,
    SEX,
    RACE,
    ARMCD,
    ARM,
    SAFETY,
    RFSTDY,
    RFENDY
  )

# -----------------------------------------------------------------------------
# 4. Integrate Exposure and Disposition Components
# -----------------------------------------------------------------------------

adsl <- dm_adsl %>%
  left_join(
    ex_analysis,
    by = "RUSUBJID"
  ) %>%
  left_join(
    ds_analysis,
    by = "RUSUBJID"
  )

# -----------------------------------------------------------------------------
# 5. Validate ADSL-Style Dataset Structure
# -----------------------------------------------------------------------------

adsl_structure_validation <- adsl %>%
  summarise(
    n_records = n(),
    n_unique_subjects = n_distinct(RUSUBJID),
    n_duplicate_subjects = n() - n_distinct(RUSUBJID),
    
    n_missing_exposure = sum(is.na(TRTSDY)),
    n_missing_eot_reason = sum(is.na(EOTRSN)),
    n_missing_last_contact_status = sum(is.na(LCONTST)),
    
    validation_status = if_else(
      n_duplicate_subjects == 0 &
        n_records == n_unique_subjects,
      "PASS",
      "FAIL"
    )
  )

# -----------------------------------------------------------------------------
# 6. Validate Analysis Population Alignment
# -----------------------------------------------------------------------------

adsl_population_validation <- adsl %>%
  summarise(
    n_safety_yes = sum(SAFETY == "Y", na.rm = TRUE),
    n_safety_no = sum(SAFETY == "N", na.rm = TRUE),
    
    n_safety_yes_missing_exposure = sum(
      SAFETY == "Y" & is.na(TRTSDY),
      na.rm = TRUE
    ),
    
    n_safety_no_with_exposure = sum(
      SAFETY == "N" & !is.na(TRTSDY),
      na.rm = TRUE
    ),
    
    validation_status = if_else(
      n_safety_yes_missing_exposure == 0 &
        n_safety_no_with_exposure == 0,
      "PASS",
      "FAIL"
    )
  )

# -----------------------------------------------------------------------------
# 7. Export Milestone 4 Outputs
# -----------------------------------------------------------------------------

write_csv(
  adsl,
  file.path(
    milestone4_derived_path,
    "milestone4_adsl.csv"
  ),
  na = ""
)

write_csv(
  adsl_structure_validation,
  file.path(
    milestone4_listing_path,
    "milestone4_adsl_structure_validation.csv"
  ),
  na = ""
)

write_csv(
  adsl_population_validation,
  file.path(
    milestone4_listing_path,
    "milestone4_adsl_population_validation.csv"
  ),
  na = ""
)