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

# -----------------------------------------------------------------------------
# 1. Project Setup
# -----------------------------------------------------------------------------

source(
  "milestones/milestone3_cross_domain_validation/programs/00_setup.R"
)

# -----------------------------------------------------------------------------
# 2. Run Validation Scripts
# -----------------------------------------------------------------------------

source(file.path(program_path, "01_subject_integrity_validation.R"))
source(file.path(program_path, "02_visit_integrity_validation.R"))
source(file.path(program_path, "03_temporal_consistency_validation.R"))

# -----------------------------------------------------------------------------
# 3. Combine Summaries
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# 4. Export Master Validation Outputs
# -----------------------------------------------------------------------------

write.csv(
  master_validation_summary,
  file.path(
    listing_path,
    "milestone3_validation_summary.csv"
  ),
  row.names = FALSE
)

write.csv(
  master_validation_findings,
  file.path(
    listing_path,
    "milestone3_validation_findings.csv"
  ),
  row.names = FALSE
)