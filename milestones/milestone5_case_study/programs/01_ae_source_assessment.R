###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  5 - Clinical Programming Case Study
#
# Script:     01_ae_source_assessment.R
#
# Purpose:
#   Assess the structure, completeness, terminology, timing, and classification
#   variables in the SDTM AE domain before developing the ADAE-style analysis
#   dataset.
###############################################################################

# -----------------------------------------------------------------------------
# 1. Load Milestone Setup
# -----------------------------------------------------------------------------

source("milestones/milestone5_case_study/programs/00_setup.R")

# -----------------------------------------------------------------------------
# 2. Read Source Data
# -----------------------------------------------------------------------------

ae <- read_sas(
  file.path(
    raw_path,
    "ae.sas7bdat"
  )
)

# -----------------------------------------------------------------------------
# 3. Timing Completeness
# -----------------------------------------------------------------------------

ae_timing_summary <- ae %>%
  summarise(
    n_records = n(),
    n_subjects = n_distinct(RUSUBJID),
    n_missing_start_day = sum(is.na(AESTDY)),
    n_missing_end_day = sum(is.na(AEENDY)),
    n_missing_both_days = sum(is.na(AESTDY) & is.na(AEENDY)),
    n_ongoing_or_missing_end = sum(!is.na(AESTDY) & is.na(AEENDY))
  )

# -----------------------------------------------------------------------------
# 4. Classification Values
# -----------------------------------------------------------------------------

aetoxgr_ct <- ae %>%
  count(AETOXGR, sort = TRUE)

aeser_ct <- ae %>%
  count(AESER, sort = TRUE)

aerel_ct <- ae %>%
  count(AEREL, sort = TRUE)

aeout_ct <- ae %>%
  count(AEOUT, sort = TRUE)

aeacn_ct <- ae %>%
  count(AEACN, sort = TRUE)

aepatt_ct <- ae %>%
  count(AEPATT, sort = TRUE)

# -----------------------------------------------------------------------------
# 5. Assess AE Terminology Completeness
# -----------------------------------------------------------------------------

ae_terminology_summary <- ae %>%
  summarise(
    n_missing_preferred_term = sum(
      is.na(AEDECOD) | trimws(AEDECOD) == ""
    ),
    n_missing_body_system = sum(
      is.na(AEBODSYS) | trimws(AEBODSYS) == ""
    ),
    n_distinct_preferred_terms = n_distinct(
      AEDECOD[!is.na(AEDECOD) & trimws(AEDECOD) != ""]
    ),
    n_distinct_body_systems = n_distinct(
      AEBODSYS[!is.na(AEBODSYS) & trimws(AEBODSYS) != ""]
    )
  )

# -----------------------------------------------------------------------------
# 6. Assess Source Treatment-Emergent Information
# -----------------------------------------------------------------------------

ae_trtem_summary <- ae %>%
  count(AETRTEM, sort = TRUE)

ae_pattern_timing_summary <- ae %>%
  mutate(
    start_day_status = if_else(
      is.na(AESTDY),
      "Missing start day",
      "Start day populated"
    )
  ) %>%
  count(AEPATT, start_day_status, sort = TRUE)

# -----------------------------------------------------------------------------
# 7. Compare AE Pattern and Treatment-Period Classification
# -----------------------------------------------------------------------------

ae_pattern_trtem_summary <- ae %>%
  count(
    AEPATT,
    AETRTEM,
    sort = TRUE
  )

# -----------------------------------------------------------------------------
# 8. Assess AE Study-Day Ranges
# -----------------------------------------------------------------------------

ae_day_range_summary <- ae %>%
  summarise(
    min_start_day = min(AESTDY, na.rm = TRUE),
    max_start_day = max(AESTDY, na.rm = TRUE),
    min_end_day = min(AEENDY, na.rm = TRUE),
    max_end_day = max(AEENDY, na.rm = TRUE),
    n_start_before_day_1 = sum(AESTDY < 1, na.rm = TRUE),
    n_start_on_day_1 = sum(AESTDY == 1, na.rm = TRUE),
    n_start_after_day_1 = sum(AESTDY > 1, na.rm = TRUE)
  )

# -----------------------------------------------------------------------------
# 9. Write Source Assessment Outputs
# -----------------------------------------------------------------------------

readr::write_csv(
  ae_timing_summary,
  file.path(milestone5_listing_path, "ae_timing_summary.csv")
)

readr::write_csv(
  ae_terminology_summary,
  file.path(milestone5_listing_path, "ae_terminology_summary.csv")
)

readr::write_csv(
  ae_trtem_summary,
  file.path(milestone5_listing_path, "ae_source_treatment_period_summary.csv")
)

readr::write_csv(
  ae_pattern_timing_summary,
  file.path(milestone5_listing_path, "ae_pattern_timing_summary.csv")
)

readr::write_csv(
  ae_pattern_trtem_summary,
  file.path(milestone5_listing_path, "ae_pattern_treatment_period_summary.csv")
)

readr::write_csv(
  ae_day_range_summary,
  file.path(milestone5_listing_path, "ae_day_range_summary.csv")
)

readr::write_csv(
  aetoxgr_ct,
  file.path(milestone5_listing_path, "ae_toxicity_grade_counts.csv")
)

readr::write_csv(
  aeser_ct,
  file.path(milestone5_listing_path, "ae_seriousness_counts.csv")
)

readr::write_csv(
  aerel_ct,
  file.path(milestone5_listing_path, "ae_relationship_counts.csv")
)

readr::write_csv(
  aeout_ct,
  file.path(milestone5_listing_path, "ae_outcome_counts.csv")
)

readr::write_csv(
  aeacn_ct,
  file.path(milestone5_listing_path, "ae_action_taken_counts.csv")
)

readr::write_csv(
  aepatt_ct,
  file.path(milestone5_listing_path, "ae_pattern_counts.csv")
)