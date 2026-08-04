###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  5 - Clinical Programming Case Study
#
# Script:     05_create_teae_grade_summary.R
#
# Purpose:
#   Summarize treatment-emergent adverse events by maximum toxicity grade and
#   seriousness using the safety population.
###############################################################################


# -----------------------------------------------------------------------------
# 1. Load Milestone Setup
# -----------------------------------------------------------------------------

source("milestones/milestone5_case_study/programs/00_setup.R")


# -----------------------------------------------------------------------------
# 2. Read Analysis Data
# -----------------------------------------------------------------------------

adsl <- readr::read_csv(
  milestone4_adsl_path,
  show_col_types = FALSE
)

adae <- readr::read_csv(
  file.path(
    milestone5_derived_path,
    "milestone5_adae.csv"
  ),
  show_col_types = FALSE
)


# -----------------------------------------------------------------------------
# 3. Establish the Safety Population and TEAE Records
# -----------------------------------------------------------------------------

safety_population <- adsl %>%
  filter(SAFETY == "Y")

safety_denominator <- safety_population %>%
  summarise(
    n_safety = n_distinct(RUSUBJID)
  ) %>%
  pull(n_safety)

teae <- adae %>%
  filter(
    SAFETY == "Y",
    TRTEMFL == "Y"
  )

stopifnot(
  safety_denominator == 453,
  all(teae$RUSUBJID %in% safety_population$RUSUBJID)
)

# -----------------------------------------------------------------------------
# 4. Inspect Toxicity Grade and Seriousness Variables
# -----------------------------------------------------------------------------

teae %>%
  count(AETOXGR, sort = TRUE)

teae %>%
  count(AESER, sort = TRUE)

teae %>%
  count(AETOXGR, AESER, sort = TRUE)

teae %>%
  summarise(
    n_records = n(),
    n_subjects = n_distinct(RUSUBJID),
    
    n_missing_grade = sum(
      is.na(AETOXGR) | trimws(AETOXGR) == ""
    ),
    
    n_missing_seriousness = sum(
      is.na(AESER) | trimws(AESER) == ""
    )
  )

# -----------------------------------------------------------------------------
# 5. Derive Subject-Level TEAE Grade and Seriousness
# -----------------------------------------------------------------------------

teae_subject_summary <- teae %>%
  group_by(RUSUBJID) %>%
  summarise(
    MAXTOXGR = max(AETOXGR),
    SERTEFL = if_else(
      any(AESER == "Y"),
      "Y",
      "N"
    ),
    .groups = "drop"
  )

safety_teae_subjects <- safety_population %>%
  select(RUSUBJID) %>%
  distinct() %>%
  left_join(
    teae_subject_summary,
    by = "RUSUBJID",
    relationship = "one-to-one"
  ) %>%
  mutate(
    ANYTEFL = if_else(
      is.na(MAXTOXGR),
      "N",
      "Y"
    ),
    SERTEFL = coalesce(
      SERTEFL,
      "N"
    )
  )

# -----------------------------------------------------------------------------
# 6. Validate and Inspect Subject-Level TEAE Results
# -----------------------------------------------------------------------------

stopifnot(
  nrow(safety_teae_subjects) == safety_denominator,
  !anyDuplicated(safety_teae_subjects$RUSUBJID),
  sum(safety_teae_subjects$ANYTEFL == "Y") == 420
)

safety_teae_subjects %>%
  count(ANYTEFL)

safety_teae_subjects %>%
  count(MAXTOXGR, sort = TRUE)

safety_teae_subjects %>%
  count(SERTEFL)

safety_teae_subjects %>%
  filter(ANYTEFL == "Y") %>%
  count(MAXTOXGR, SERTEFL, sort = TRUE)

# -----------------------------------------------------------------------------
# 7. Create TEAE Grade and Seriousness Summary
# -----------------------------------------------------------------------------

teae_grade_summary <- bind_rows(
  safety_teae_subjects %>%
    summarise(
      category = "Any TEAE",
      n_subjects = sum(ANYTEFL == "Y")
    ),
  
  safety_teae_subjects %>%
    filter(ANYTEFL == "Y") %>%
    count(MAXTOXGR, name = "n_subjects") %>%
    transmute(
      category = paste(
        "Maximum toxicity Grade",
        MAXTOXGR
      ),
      n_subjects
    ),
  
  safety_teae_subjects %>%
    summarise(
      category = "Maximum toxicity Grade 3 or higher",
      n_subjects = sum(
        MAXTOXGR >= 3,
        na.rm = TRUE
      )
    ),
  
  safety_teae_subjects %>%
    summarise(
      category = "At least one serious TEAE",
      n_subjects = sum(SERTEFL == "Y")
    )
) %>%
  mutate(
    percent = 100 * n_subjects / safety_denominator,
    category = factor(
      category,
      levels = c(
        "Any TEAE",
        "Maximum toxicity Grade 1",
        "Maximum toxicity Grade 2",
        "Maximum toxicity Grade 3",
        "Maximum toxicity Grade 4",
        "Maximum toxicity Grade 3 or higher",
        "At least one serious TEAE"
      )
    )
  ) %>%
  arrange(category) %>%
  mutate(
    category = as.character(category)
  )

teae_grade_summary_display <- teae_grade_summary %>%
  mutate(
    subjects_n_percent = sprintf(
      "%d (%.1f%%)",
      n_subjects,
      percent
    )
  ) %>%
  select(
    category,
    subjects_n_percent
  )

# -----------------------------------------------------------------------------
# 8. Validate Final TEAE Grade Summary
# -----------------------------------------------------------------------------

stopifnot(
  nrow(teae_grade_summary) == 7,
  !any(is.na(teae_grade_summary$category)),
  all(teae_grade_summary$n_subjects <= safety_denominator),
  
  sum(
    teae_grade_summary$n_subjects[
      teae_grade_summary$category %in% paste(
        "Maximum toxicity Grade",
        1:4
      )
    ]
  ) == 420,
  
  teae_grade_summary$n_subjects[
    teae_grade_summary$category ==
      "Maximum toxicity Grade 3 or higher"
  ] == 205,
  
  teae_grade_summary$n_subjects[
    teae_grade_summary$category ==
      "At least one serious TEAE"
  ] == 138
)

# -----------------------------------------------------------------------------
# 9. Write TEAE Grade Summary Outputs
# -----------------------------------------------------------------------------

readr::write_csv(
  teae_grade_summary,
  file.path(
    milestone5_table_path,
    "teae_grade_summary_analysis.csv"
  )
)

readr::write_csv(
  teae_grade_summary_display,
  file.path(
    milestone5_table_path,
    "teae_grade_summary_table.csv"
  )
)
