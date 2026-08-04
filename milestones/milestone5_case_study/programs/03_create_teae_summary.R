###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  5 - Clinical Programming Case Study
#
# Script:     03_create_teae_summary.R
#
# Purpose:
#   Create a subject-incidence summary of treatment-emergent adverse events by
#   system organ class and preferred term using the safety population.
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
# 3. Establish the Safety Population
# -----------------------------------------------------------------------------

adsl %>%
  count(SAFETY, ARM, sort = TRUE)

adae %>%
  count(SAFETY, TRTEMFL, sort = TRUE)

adae %>%
  filter(
    SAFETY == "Y",
    TRTEMFL == "Y"
  ) %>%
  summarise(
    n_teae_records = n(),
    n_teae_subjects = n_distinct(RUSUBJID),
    n_missing_soc = sum(is.na(AEBODSYS) | trimws(AEBODSYS) == ""),
    n_missing_preferred_term = sum(is.na(AEDECOD) | trimws(AEDECOD) == "")
  )

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
# 4. Calculate Overall TEAE Incidence
# -----------------------------------------------------------------------------

overall_summary <- teae %>%
  summarise(
    row_type = "Overall",
    system_organ_class = "Subjects with at least one TEAE",
    preferred_term = NA_character_,
    n_subjects = n_distinct(RUSUBJID),
    n_events = n()
  ) %>%
  mutate(
    percent = 100 * n_subjects / safety_denominator
  )


# -----------------------------------------------------------------------------
# 5. Calculate TEAE Incidence by System Organ Class
# -----------------------------------------------------------------------------

soc_summary <- teae %>%
  group_by(AEBODSYS) %>%
  summarise(
    n_subjects = n_distinct(RUSUBJID),
    n_events = n(),
    .groups = "drop"
  ) %>%
  transmute(
    row_type = "SOC",
    system_organ_class = AEBODSYS,
    preferred_term = NA_character_,
    n_subjects,
    percent = 100 * n_subjects / safety_denominator,
    n_events
  )


# -----------------------------------------------------------------------------
# 6. Calculate TEAE Incidence by Preferred Term
# -----------------------------------------------------------------------------

pt_summary <- teae %>%
  group_by(AEBODSYS, AEDECOD) %>%
  summarise(
    n_subjects = n_distinct(RUSUBJID),
    n_events = n(),
    .groups = "drop"
  ) %>%
  transmute(
    row_type = "Preferred Term",
    system_organ_class = AEBODSYS,
    preferred_term = AEDECOD,
    n_subjects,
    percent = 100 * n_subjects / safety_denominator,
    n_events
  )

# -----------------------------------------------------------------------------
# 7. Assemble Final TEAE Summary
# -----------------------------------------------------------------------------

soc_order <- soc_summary %>%
  arrange(
    desc(n_subjects),
    system_organ_class
  ) %>%
  transmute(
    system_organ_class,
    soc_order = row_number()
  )

teae_summary <- bind_rows(
  overall_summary,
  soc_summary,
  pt_summary
) %>%
  left_join(
    soc_order,
    by = "system_organ_class"
  ) %>%
  mutate(
    overall_order = if_else(row_type == "Overall", 0L, 1L),
    row_order = case_when(
      row_type == "SOC" ~ 0L,
      row_type == "Preferred Term" ~ 1L,
      TRUE ~ 0L
    )
  ) %>%
  arrange(
    overall_order,
    soc_order,
    row_order,
    desc(n_subjects),
    preferred_term
  ) %>%
  select(
    row_type,
    system_organ_class,
    preferred_term,
    n_subjects,
    percent,
    n_events
  )

teae_summary_display <- teae_summary %>%
  mutate(
    subjects_n_percent = sprintf(
      "%d (%.1f%%)",
      n_subjects,
      percent
    )
  ) %>%
  select(
    row_type,
    system_organ_class,
    preferred_term,
    subjects_n_percent,
    n_events
  )

# -----------------------------------------------------------------------------
# 8. Validate Final TEAE Summary
# -----------------------------------------------------------------------------

stopifnot(
  safety_denominator == 453,
  nrow(overall_summary) == 1,
  nrow(soc_summary) == n_distinct(teae$AEBODSYS),
  nrow(pt_summary) ==
    n_distinct(paste(teae$AEBODSYS, teae$AEDECOD)),
  overall_summary$n_subjects == 420,
  overall_summary$n_events == 8743,
  overall_summary$n_subjects <= safety_denominator,
  all(soc_summary$n_subjects <= safety_denominator),
  all(pt_summary$n_subjects <= safety_denominator),
  all(soc_summary$n_events >= soc_summary$n_subjects),
  all(pt_summary$n_events >= pt_summary$n_subjects)
)

# -----------------------------------------------------------------------------
# 9. Write TEAE Summary Outputs
# -----------------------------------------------------------------------------

readr::write_csv(
  teae_summary,
  file.path(
    milestone5_table_path,
    "teae_summary_analysis.csv"
  )
)

readr::write_csv(
  teae_summary_display,
  file.path(
    milestone5_table_path,
    "teae_summary_table.csv"
  )
)
