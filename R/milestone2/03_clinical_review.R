# ==============================================================================
# Milestone 2: Subject-Level Clinical Story
# Script 03: Clinical Review
#
# Purpose:
# Review detailed subject-level clinical findings to identify meaningful
# treatment-related, safety, disease, and quality-of-life patterns.
# ==============================================================================
# Clinical Review Notes
#
# LCSS Total Score
# - Mean of 9 questionnaire items
# - Range: 0–100
# - Lower scores indicate better quality of life
#
# ASBI
# - Mean of the 6 major lung cancer symptom scores
# - Lower scores indicate lower symptom burden
#
# Reference:
# Protocol Section 9.1.2.3
# ==============================================================================

# 1. Setup ---------------------------------------------------------------------

source("R/00_setup.R")

selected_subject <- "010261-000-999-450"


# 2. Load required SDTM domains ------------------------------------------------

ae <- haven::read_sas(file.path(raw_path, "ae.sas7bdat"))
qs <- haven::read_sas(file.path(raw_path, "qs.sas7bdat"))
ls <- haven::read_sas(file.path(raw_path, "ls.sas7bdat"))

# 3. Review adverse events ------------------------------------------------------

ae_review <- ae %>%
  filter(RUSUBJID == selected_subject)

# Count unique adverse events
ae_unique_events <- ae_review %>%
  distinct(AEDECOD) %>%
  arrange(AEDECOD)

# Identify clinically important adverse events
important_ae_review <- ae_review %>%
  filter(
    AETOXGR %in% c("3", "4") |
      AESER == "Y" |
      AEACCOL != "NONE"
  ) %>%
  select(
    AEDECOD,
    VISITNUM,
    AESTDY,
    AEENDY,
    AETOXGR,
    AEACCOL,
    AEACN,
    AEOUT
  ) %>%
  arrange(AESTDY, AEDECOD, VISITNUM)

# Review repeated peripheral sensory neuropathy assessments
neuropathy_review <- ae_review %>%
  filter(AEDECOD == "PERIPHERAL SENSORY NEUROPATHY") %>%
  select(
    AESEQ,
    VISITNUM,
    AESTDY,
    AEENDY,
    AETOXGR,
    AEACCOL,
    AEACN,
    AEOUT
  ) %>%
  arrange(VISITNUM)

# 4. Review patient-reported outcomes ------------------------------------------

qs_summary <- qs %>%
  filter(
    RUSUBJID == selected_subject,
    QSTEST %in% c(
      "LCSS TOTAL SCORE",
      "AVERAGE SYMPTOM BURDEN INDEX"
    )
  ) %>%
  select(
    QSTEST,
    QSDY,
    QSSTRESN
  ) %>%
  arrange(QSDY, QSTEST)

# 5. Review target lesion measurements ----------------------------------------

lesion_review <- ls %>%
  filter(
    RUSUBJID == selected_subject,
    LSTEST == "Measurement of Target Lesion"
  ) %>%
  select(
    VISITNUM,
    LSSPID,
    LSDY,
    LSSTRESC,
    LSLOC
  ) %>%
  arrange(LSSPID, LSDY)

# Summarize baseline and last observed measurement for each lesion
lesion_change_summary <- lesion_review %>%
  group_by(LSSPID, LSLOC) %>%
  summarise(
    baseline_day = first(LSDY),
    baseline_value = first(as.numeric(LSSTRESC)),
    last_day = last(LSDY),
    last_value = last(as.numeric(LSSTRESC)),
    absolute_change = last_value - baseline_value,
    .groups = "drop"
  )

# 6. Review overall disease response -------------------------------------------

response_review <- ls %>%
  filter(
    RUSUBJID == selected_subject,
    LSTEST %in% c(
      "Overall Response without Symp. Det.",
      "Overall Response with Symp. Det.",
      "Best Overall Response"
    )
  ) %>%
  select(
    LSTEST,
    LSDY,
    VISITNUM,
    LSSTRESC
  ) %>%
  arrange(LSDY, LSTEST)

# 7. Validate clinical review outputs ------------------------------------------

stopifnot(n_distinct(ae_review$RUSUBJID) == 1)

stopifnot(
  nrow(important_ae_review) ==
    ae_review %>%
    filter(
      AETOXGR %in% c("3", "4") |
        AESER == "Y" |
        AEACCOL != "NONE"
    ) %>%
    nrow()
)

stopifnot(
  all(qs_summary$QSTEST %in% c(
    "LCSS TOTAL SCORE",
    "AVERAGE SYMPTOM BURDEN INDEX"
  ))
)

stopifnot(
  all(lesion_change_summary$baseline_day <=
        lesion_change_summary$last_day)
)

stopifnot(
  nrow(important_ae_review) > 0,
  nrow(qs_summary) > 0,
  nrow(lesion_change_summary) > 0,
  nrow(response_review) > 0
)

# 8. Export clinical review outputs --------------------------------------------

write_csv(
  important_ae_review,
  file.path(listing_path, "milestone2_important_ae_review.csv"),
  na = ""
)

write_csv(
  qs_summary,
  file.path(listing_path, "milestone2_qs_summary.csv"),
  na = ""
)

write_csv(
  lesion_change_summary,
  file.path(listing_path, "milestone2_lesion_change_summary.csv"),
  na = ""
)

write_csv(
  response_review,
  file.path(listing_path, "milestone2_response_review.csv"),
  na = ""
)