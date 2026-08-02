# ==============================================================================
# Milestone 2: Subject-Level Clinical Story
# Script 02: Subject Timeline
#
# Purpose:
# Create a standardized, chronological timeline for the selected subject using
# exposure, adverse event, and disposition records. Subject visit data are used
# only to derive missing study days when appropriate.
# ==============================================================================


# 1. Setup ---------------------------------------------------------------------

source(
  file.path(
    "milestones",
    "milestone2_subject_clinical_review",
    "programs",
    "00_setup.R"
  )
)

selected_subject <- "010261-000-999-450"


# 2. Load required SDTM domains ------------------------------------------------

ex <- haven::read_sas(file.path(raw_path, "ex.sas7bdat"))
ae <- haven::read_sas(file.path(raw_path, "ae.sas7bdat"))
ds <- haven::read_sas(file.path(raw_path, "ds.sas7bdat"))
sv <- haven::read_sas(file.path(raw_path, "sv.sas7bdat"))

# 3. Create exposure timeline --------------------------------------------------

ex_timeline <- ex %>%
  filter(RUSUBJID == selected_subject) %>%
  left_join(
    sv %>%
      filter(RUSUBJID == selected_subject) %>%
      select(RUSUBJID, VISITNUM, SVSTDY),
    by = c("RUSUBJID", "VISITNUM")
  ) %>%
  transmute(
    RUSUBJID,
    study_day = coalesce(EXSTDY, SVSTDY),
    visit = VISITNUM,
    domain = "EX",
    event = EXTRT,
    value = EXDOSE,
    unit = EXDOSU,
    detail = if_else(
      is.na(EXDOSE),
      "Dose not recorded",
      NA_character_
    ),
    treatment_period = NA_character_,
    day_source = case_when(
      !is.na(EXSTDY) ~ "Reported in EX",
      is.na(EXSTDY) & !is.na(SVSTDY) ~ "Derived from SV visit start",
      TRUE ~ NA_character_
    )
  )

# 4. Create adverse event timeline --------------------------------------------

ae_timeline <- ae %>%
  filter(RUSUBJID == selected_subject) %>%
  transmute(
    RUSUBJID,
    study_day = AESTDY,
    visit = VISITNUM,
    domain = "AE",
    event = AEDECOD,
    value = NA_real_,
    unit = NA_character_,
    detail = AEACCOL,
    treatment_period = AETRTEM,
    day_source = if_else(
      is.na(AESTDY),
      NA_character_,
      "Reported in AE"
    )
  )

# 5. Create disposition timeline ----------------------------------------------

ds_timeline <- ds %>%
  filter(RUSUBJID == selected_subject) %>%
  left_join(
    sv %>%
      filter(RUSUBJID == selected_subject) %>%
      select(RUSUBJID, VISITNUM, SVSTDY),
    by = c("RUSUBJID", "VISITNUM")
  ) %>%
  transmute(
    RUSUBJID,
    study_day = coalesce(DSSTDY, SVSTDY),
    visit = VISITNUM,
    domain = "DS",
    event = DSDECOD,
    value = NA_real_,
    unit = NA_character_,
    detail = DSSCAT,
    treatment_period = NA_character_,
    day_source = case_when(
      !is.na(DSSTDY) ~ "Reported in DS",
      is.na(DSSTDY) & !is.na(SVSTDY) ~
        "Derived from SV visit start",
      TRUE ~ NA_character_
    )
  )  

# 6. Combine timeline records --------------------------------------------------

subject_timeline <- bind_rows(
  ex_timeline,
  ae_timeline,
  ds_timeline
) %>%
  arrange(study_day, domain, event)

# 7. Validate derived timeline -------------------------------------------------

# Confirm that only the selected subject is represented
stopifnot(n_distinct(subject_timeline$RUSUBJID) == 1)

stopifnot(
  all(subject_timeline$RUSUBJID == selected_subject)
)

# Confirm that only the intended domains are represented
stopifnot(
  all(subject_timeline$domain %in% c("EX", "AE", "DS"))
)

# Confirm that no source records were lost
stopifnot(
  nrow(ex_timeline) ==
    ex %>%
    filter(RUSUBJID == selected_subject) %>%
    nrow()
)

stopifnot(
  nrow(ae_timeline) ==
    ae %>%
    filter(RUSUBJID == selected_subject) %>%
    nrow()
)

stopifnot(
  nrow(ds_timeline) ==
    ds %>%
    filter(RUSUBJID == selected_subject) %>%
    nrow()
)

# 8. Review timeline -----------------------------------------------------------

# Confirm the number of timeline records contributed by each domain
domain_record_counts <- subject_timeline %>%
  count(domain, name = "record_count")

print(domain_record_counts)

# Review records that cannot be positioned by study day
missing_study_day_review <- subject_timeline %>%
  filter(is.na(study_day)) %>%
  count(domain, event, sort = TRUE)

print(missing_study_day_review)


# 9. Export derived timeline ---------------------------------------------------

write_csv(
  subject_timeline,
  file.path(
    derived_path,
    "milestone2_subject_timeline.csv"
  ),
  na = ""
)