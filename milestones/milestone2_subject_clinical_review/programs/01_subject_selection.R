#===============================================================================
# Milestone 2: Subject-Level Clinical Story
# Script 01: Subject Selection
#
# Purpose:
# Identify subjects with data across key SDTM domains and select one subject
# with sufficiently rich longitudinal data for clinical story reconstruction.
#===============================================================================

source(file.path("R", "00_setup.R"))

#-------------------------------------------------------------------------------
# 1. Load SDTM datasets
#-------------------------------------------------------------------------------

dm <- read_sas(file.path(raw_path, "dm.sas7bdat"))
sv <- read_sas(file.path(raw_path, "sv.sas7bdat"))
ex <- read_sas(file.path(raw_path, "ex.sas7bdat"))
ae <- read_sas(file.path(raw_path, "ae.sas7bdat"))
lb <- read_sas(file.path(raw_path, "lb.sas7bdat"))
vs <- read_sas(file.path(raw_path, "vs.sas7bdat"))
ds <- read_sas(file.path(raw_path, "ds.sas7bdat"))
cd <- read_sas(file.path(raw_path, "cd.sas7bdat"))
ls <- read_sas(file.path(raw_path, "ls.sas7bdat"))
qs <- read_sas(file.path(raw_path, "qs.sas7bdat"))
cm <- read_sas(file.path(raw_path, "cm.sas7bdat"))
mh <- read_sas(file.path(raw_path, "mh.sas7bdat"))

#-------------------------------------------------------------------------------
# 2. Identify subjects represented across all selected domains
#-------------------------------------------------------------------------------

subject_lists <- list(
  DM = unique(dm$RUSUBJID),
  SV = unique(sv$RUSUBJID),
  EX = unique(ex$RUSUBJID),
  AE = unique(ae$RUSUBJID),
  LB = unique(lb$RUSUBJID),
  VS = unique(vs$RUSUBJID),
  DS = unique(ds$RUSUBJID),
  CD = unique(cd$RUSUBJID),
  LS = unique(ls$RUSUBJID),
  QS = unique(qs$RUSUBJID),
  CM = unique(cm$RUSUBJID),
  MH = unique(mh$RUSUBJID)
)

common_subjects <- Reduce(intersect, subject_lists)
cat(
  "Subjects represented in all 12 selected domains:",
  length(common_subjects),
  "\n"
)

#-------------------------------------------------------------------------------
# 3. Calculate domain record counts by subject
#-------------------------------------------------------------------------------

ae_counts <- ae %>% 
  group_by(RUSUBJID) %>%
  summarise(n_ae = n(), .groups = "drop")

ex_counts <- ex %>%
  group_by(RUSUBJID) %>%
  summarise(n_ex = n(), .groups = "drop")

lb_counts <- lb %>%
  group_by(RUSUBJID) %>%
  summarise(n_lb = n(), .groups = "drop")

sv_counts <- sv %>%
  group_by(RUSUBJID) %>%
  summarise(n_sv = n(), .groups = "drop")

vs_counts <- vs %>%
  group_by(RUSUBJID) %>%
  summarise(n_vs = n(), .groups = "drop")

ds_counts <- ds %>%
  group_by(RUSUBJID) %>%
  summarise(n_ds = n(), .groups = "drop")

cd_counts <- cd %>%
  group_by(RUSUBJID) %>%
  summarise(n_cd = n(), .groups = "drop")

ls_counts <- ls %>%
  group_by(RUSUBJID) %>%
  summarise(n_ls = n(), .groups = "drop")

qs_counts <- qs %>%
  group_by(RUSUBJID) %>%
  summarise(n_qs = n(), .groups = "drop")

cm_counts <- cm %>%
  group_by(RUSUBJID) %>%
  summarise(n_cm = n(), .groups = "drop")

mh_counts <- mh %>%
  group_by(RUSUBJID) %>%
  summarise(n_mh = n(), .groups = "drop")

#-------------------------------------------------------------------------------
# 4. Create derived subject-level domain count dataset
#-------------------------------------------------------------------------------

subject_counts <- dm %>%
  distinct(RUSUBJID) %>%
  left_join(ae_counts, by = "RUSUBJID") %>%
  left_join(ex_counts, by = "RUSUBJID") %>%
  left_join(lb_counts, by = "RUSUBJID") %>%
  left_join(sv_counts, by = "RUSUBJID") %>%
  left_join(vs_counts, by = "RUSUBJID") %>%
  left_join(ds_counts, by = "RUSUBJID") %>%
  left_join(cd_counts, by = "RUSUBJID") %>%
  left_join(ls_counts, by = "RUSUBJID") %>%
  left_join(qs_counts, by = "RUSUBJID") %>%
  left_join(cm_counts, by = "RUSUBJID") %>%
  left_join(mh_counts, by = "RUSUBJID")

subject_counts <- subject_counts %>%
  mutate(
    across(
      starts_with("n_"),
      ~ replace_na(.x,0)
    )
  )

write_csv(
  subject_counts,
  file.path(derived_path, "milestone2_subject_domain_counts.csv")
)

#-------------------------------------------------------------------------------
# 5. Screen candidate subjects
#-------------------------------------------------------------------------------

top_ae_candidates <- subject_counts %>%
  arrange(desc(n_ae)) %>%
  slice_head(n = 10)

top_ae_candidates

candidate_subjects <- c(
  "010261-000-999-244",
  "010261-000-999-403",
  "010261-000-999-450"
)

write_csv(
  top_ae_candidates,
  file.path(listing_path, "milestone2_top_ae_candidates.csv")
)

candidate_dm <- dm %>%
  filter(RUSUBJID %in% candidate_subjects)

candidate_ds <- ds %>%
  filter(RUSUBJID %in% candidate_subjects)

write_csv(
  candidate_dm,
  file.path(listing_path, "milestone2_candidate_demographics.csv")
)

write_csv(
  candidate_ds,
  file.path(listing_path, "milestone2_candidate_disposition.csv")
)

#-------------------------------------------------------------------------------
# 6. Document final subject selection
#-------------------------------------------------------------------------------

selected_subject <- "010261-000-999-450"

selected_subject_profile <- subject_counts %>%
  filter(RUSUBJID == selected_subject)

stopifnot(nrow(subject_counts) == n_distinct(dm$RUSUBJID))
stopifnot(selected_subject %in% subject_counts$RUSUBJID)
stopifnot(nrow(selected_subject_profile) == 1)

selected_subject_profile

write_csv(
  selected_subject_profile,
  file.path(listing_path, "milestone2_selected_subject_profile.csv")
)

# Selection rationale:
# Subject 010261-000-999-450 had rich longitudinal data across all selected
# domains. Preliminary review identified treatment changes, premature treatment
# discontinuation, disease progression, and continued survival follow-up,
# providing several cross-domain questions for detailed reconstruction.