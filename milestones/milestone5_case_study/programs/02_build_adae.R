###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  5 - Clinical Programming Case Study
#
# Script:     02_build_adae.R
#
# Purpose:
#   Build an ADAE-style analysis dataset by combining SDTM adverse-event records
#   with subject-level treatment information and deriving analysis flags.
###############################################################################


# -----------------------------------------------------------------------------
# 1. Load Milestone Setup
# -----------------------------------------------------------------------------

source("milestones/milestone5_case_study/programs/00_setup.R")


# -----------------------------------------------------------------------------
# 2. Read Input Data
# -----------------------------------------------------------------------------

ae <- read_sas(
  file.path(
    raw_path,
    "ae.sas7bdat"
  )
)

adsl <- read_csv(
  milestone4_adsl_path,
  show_col_types = FALSE
)

# -----------------------------------------------------------------------------
# 3. Select Subject-Level Variables
# -----------------------------------------------------------------------------

adsl_adae <- adsl %>%
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
    RFENDY,
    TRTSDY,
    TRTEDY,
    TRTDUR
  )

# -----------------------------------------------------------------------------
# 4. Merge AE with Subject-Level Treatment Information
# -----------------------------------------------------------------------------

adae <- ae %>%
  left_join(
    adsl_adae,
    by = c("STUDYID", "RUSUBJID"),
    relationship = "many-to-one"
  )


# -----------------------------------------------------------------------------
# 5. Derive Treatment-Window Flags
# -----------------------------------------------------------------------------

adae <- adae %>%
  mutate(
    ONTRTFL = case_when(
      is.na(AESTDY) | is.na(TRTSDY) | is.na(TRTEDY) ~ NA_character_,
      AESTDY >= TRTSDY & AESTDY <= TRTEDY ~ "Y",
      TRUE ~ "N"
    ),
    
    POSTTRTFL = case_when(
      is.na(AESTDY) | is.na(TRTEDY) ~ NA_character_,
      AESTDY > TRTEDY & AESTDY <= TRTEDY + 30 ~ "Y",
      TRUE ~ "N"
    ),
    
    TRTEMFL = case_when(
      is.na(AESTDY) | is.na(TRTSDY) | is.na(TRTEDY) ~ NA_character_,
      AESTDY >= TRTSDY & AESTDY <= TRTEDY + 30 ~ "Y",
      TRUE ~ "N"
    )
  )


# -----------------------------------------------------------------------------
# 6. Validate Treatment-Window Derivations
# -----------------------------------------------------------------------------

adae_flag_summary <- adae %>%
  summarise(
    n_records = n(),
    n_on_treatment = sum(ONTRTFL == "Y", na.rm = TRUE),
    n_post_treatment = sum(POSTTRTFL == "Y", na.rm = TRUE),
    n_treatment_emergent = sum(TRTEMFL == "Y", na.rm = TRUE),
    n_not_treatment_emergent = sum(TRTEMFL == "N", na.rm = TRUE),
    n_unclassified = sum(is.na(TRTEMFL))
  )

adae %>%
  count(ONTRTFL, POSTTRTFL, TRTEMFL)

adae %>%
  count(AETRTEM, TRTEMFL)


# -----------------------------------------------------------------------------
# 7. Investigate Non-Treatment-Emergent Records
# -----------------------------------------------------------------------------

adae_non_te_summary <- adae %>%
  filter(TRTEMFL == "N") %>%
  mutate(
    timing_category = case_when(
      AESTDY < TRTSDY ~ "Before treatment start",
      AESTDY > TRTEDY + 30 ~ "After 30-day window",
      TRUE ~ "Other"
    )
  ) %>%
  count(
    timing_category,
    AEPATT,
    AETRTEM,
    sort = TRUE
  )

adae_unclassified_summary <- adae %>%
  filter(is.na(TRTEMFL)) %>%
  summarise(
    n_records = n(),
    n_missing_aestdy = sum(is.na(AESTDY)),
    n_missing_trtsdy = sum(is.na(TRTSDY)),
    n_missing_trtedy = sum(is.na(TRTEDY))
  )

adae_flag_summary <- adae_flag_summary %>%
  mutate(
    treatment_emergent_reconciles =
      n_on_treatment + n_post_treatment == n_treatment_emergent,
    
    total_records_reconcile =
      n_treatment_emergent +
      n_not_treatment_emergent +
      n_unclassified == n_records
  )


# -----------------------------------------------------------------------------
# 8. Write ADAE and Validation Outputs
# -----------------------------------------------------------------------------

readr::write_csv(
  adae,
  file.path(
    milestone5_derived_path,
    "milestone5_adae.csv"
  )
)

readr::write_csv(
  adae_flag_summary,
  file.path(
    milestone5_listing_path,
    "adae_flag_summary.csv"
  )
)

readr::write_csv(
  adae_non_te_summary,
  file.path(
    milestone5_listing_path,
    "adae_non_treatment_emergent_summary.csv"
  )
)

readr::write_csv(
  adae_unclassified_summary,
  file.path(
    milestone5_listing_path,
    "adae_unclassified_summary.csv"
  )
)

# -----------------------------------------------------------------------------
# 9. Verify Final ADAE Dataset
# -----------------------------------------------------------------------------

adae_saved <- readr::read_csv(
  file.path(
    milestone5_derived_path,
    "milestone5_adae.csv"
  ),
  show_col_types = FALSE
)

stopifnot(
  nrow(adae) == nrow(ae),
  nrow(adae_saved) == nrow(ae),
  
  dplyr::n_distinct(adae$RUSUBJID) ==
    dplyr::n_distinct(ae$RUSUBJID),
  
  dplyr::n_distinct(adae_saved$RUSUBJID) ==
    dplyr::n_distinct(ae$RUSUBJID),
  
  !anyDuplicated(
    adae_saved[c("STUDYID", "RUSUBJID", "AESEQ")]
  ),
  
  all(adae_flag_summary$treatment_emergent_reconciles),
  
  all(adae_flag_summary$total_records_reconcile),
  
  !any(adae$ONTRTFL == "Y" & adae$POSTTRTFL == "Y", na.rm = TRUE),
  
  sum(is.na(adae$SAFETY)) == 0
)