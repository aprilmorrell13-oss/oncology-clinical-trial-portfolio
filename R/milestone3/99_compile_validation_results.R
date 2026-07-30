###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  3 - Cross-Domain Data Validation
#
# Script:     99_compile_validation_results.R
#
# Purpose:
#   Compile the results from all Milestone 3 validation scripts into a master
#   validation summary and a master findings listing.
###############################################################################

# Project Setup

source("R/00_setup.R")

###############################################################################
# Run Validation Scripts

source("R/milestone3/01_subject_integrity_validation.R")
source("R/milestone3/02_visit_integrity_validation.R")
source("R/milestone3/03_temporal_consistency_validation.R")

###############################################################################
# Combile Summaries

master_validation_summary <- bind_rows(
  subject_validation_summary,
  visit_validation_summary,
  temporal_validation_summary
)

master_validation_findings <- bind_rows(
  subject_validation_findings,
  visit_validation_findings,
  temporal_validation_findings
)

###############################################################################
# Export Master Validation Outputs

write_csv(
  master_validation_summary,
  file.path(listing_path, "milestone3_validation_summary.csv")
)

write_csv(
  master_validation_findings,
  file.path(listing_path, "milestone3_validation_findings.csv")
)