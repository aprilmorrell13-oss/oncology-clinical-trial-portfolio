###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  3 - Cross-Domain Data Validation
#
# Script:     03_temporal_consistency_validation.R
#
# Purpose:
#   Validate temporal consistency across selected SDTM domains by confirming
#   that an end study day does not occur before its corresponding start study day.
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

ae <- read_sas(file.path(raw_path, "ae.sas7bdat"))
ex <- read_sas(file.path(raw_path, "ex.sas7bdat"))
ra <- read_sas(file.path(raw_path, "ra.sas7bdat"))
cm <- read_sas(file.path(raw_path, "cm.sas7bdat"))

# -----------------------------------------------------------------------------
# 3. Define Validation Scope
# -----------------------------------------------------------------------------

temporal_domains <- list(
  AE = list(
    data = ae,
    start_var = "AESTDY",
    end_var = "AEENDY",
    detail_var = "AEDECOD"
  ),
  EX = list(
    data = ex,
    start_var = "EXSTDY",
    end_var = "EXENDY",
    detail_var = "EXTRT"
  ),
  RA = list(
    data = ra,
    start_var = "RASTDY",
    end_var = "RAENDY",
    detail_var = "RATRT"
  ),
  CM = list(
    data = cm,
    start_var = "CMSTDY",
    end_var = "CMENDY",
    detail_var = "CMDECOD"
  )
)

# -----------------------------------------------------------------------------
# 4. Run Temporal Consistency Validation
# -----------------------------------------------------------------------------

temporal_validation_results <- lapply(
  names(temporal_domains),
  function(domain_name) {
    config <- temporal_domains[[domain_name]]
    domain_data <- config$data
    start_var <- config$start_var
    end_var <- config$end_var
    detail_var <- config$detail_var
    both_dates_populated <- domain_data %>%
      filter(
        !is.na(.data[[start_var]]),
        !is.na(.data[[end_var]])
      )
    temporal_findings <- both_dates_populated %>%
      filter(
        .data[[end_var]] < .data[[start_var]]
      )
    summary <- data.frame(
      Validation = "Temporal Consistency",
      Domain = domain_name,
      Check = paste(end_var, "is not earlier than", start_var),
      Finding_Count = nrow(temporal_findings),
      Status = ifelse(
        nrow(temporal_findings) == 0,
        "PASS",
        "FAIL"
      )
    )
    findings <- temporal_findings %>%
      transmute(
        Validation = "Temporal Consistency",
        Domain = domain_name,
        RUSUBJID = RUSUBJID,
        Detail = as.character(.data[[detail_var]]),
        Start_Variable = start_var,
        Start_Value = as.numeric(.data[[start_var]]),
        End_Variable = end_var,
        End_Value = as.numeric(.data[[end_var]]),
        VISITNUM = NA_real_,
        Issue = paste(
          end_var,
          "occurs before",
          start_var
        )
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

temporal_validation_summary <- bind_rows(
  lapply(temporal_validation_results, function(x) x$summary)
)

temporal_validation_findings <- bind_rows(
  lapply(temporal_validation_results, function(x) x$findings)
)