###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  3 - Cross-Domain Data Validation
#
# Script:     02_visit_integrity_validation.R
#
# Purpose:
#   Validate visit integrity across visit-based SDTM domains by confirming that
#   each subject-visit combination in LB, VS, and QS also exists in SV.
###############################################################################

# -----------------------------------------------------------------------------
# 1. Project Setup
# -----------------------------------------------------------------------------

source(
  "milestones/milestone3_cross_domain_validation/programs/00_setup.R"
)

# -----------------------------------------------------------------------------
# 2. Load Required SDTM Domains
# -----------------------------------------------------------------------------

lb <- read_sas(file.path(raw_path, "lb.sas7bdat"))
vs <- read_sas(file.path(raw_path, "vs.sas7bdat"))
qs <- read_sas(file.path(raw_path, "qs.sas7bdat"))
sv <- read_sas(file.path(raw_path, "sv.sas7bdat"))

# -----------------------------------------------------------------------------
# 3. Create SV Subject-Visit Reference
# -----------------------------------------------------------------------------

sv_visit_reference <- sv %>%
  distinct(RUSUBJID, VISITNUM)

visit_domains <- list(
  LB = lb,
  VS = vs,
  QS = qs
)

# -----------------------------------------------------------------------------
# 4. Run Visit Integrity Validation
# -----------------------------------------------------------------------------

visit_validation_results <- lapply(
  names(visit_domains),
  function(domain_name) {
    domain_data <- visit_domains[[domain_name]]
    domain_visit_pairs <- domain_data %>%
      distinct(RUSUBJID, VISITNUM)
    missing_sv_visits <- domain_visit_pairs %>%
      anti_join(
        sv_visit_reference,
        by = c("RUSUBJID", "VISITNUM")
      )
    summary <- data.frame(
      Validation = "Visit Integrity",
      Domain = domain_name,
      Check = "Subject-visit combination exists in SV",
      Finding_Count = nrow(missing_sv_visits),
      Status = ifelse(
        nrow(missing_sv_visits) == 0,
        "PASS",
        "FAIL"
      )
    )
    findings <- missing_sv_visits %>%
      mutate(
        Validation = "Visit Integrity",
        Domain = domain_name,
         Issue = paste(
           "Subject-visit combination present in",
           domain_name,
           "but absent from SV"
         )
      ) %>%
      select(
        Validation,
        Domain,
        RUSUBJID,
        VISITNUM,
        Issue
      )
    list(
      summary = summary,
      findings = findings
    )
  }
)

# -----------------------------------------------------------------------------
# 5. Create Validation Outputs
# -----------------------------------------------------------------------------

visit_validation_summary <- bind_rows(
  lapply(visit_validation_results, function(x) x$summary)
)

visit_validation_findings <- bind_rows(
  lapply(visit_validation_results, function(x) x$findings)
)
