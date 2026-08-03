###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  5 - Case Study
#
# Script:     00_setup.R
#
# Purpose:
#   Load shared project settings, define Milestone 5 paths, and create the
#   required milestone-specific output directories.
###############################################################################


# -----------------------------------------------------------------------------
# 1. Load Global Project Setup
# -----------------------------------------------------------------------------

source("milestones/00_setup.R")


# -----------------------------------------------------------------------------
# 2. Define Milestone 5 Root Path
# -----------------------------------------------------------------------------

milestone5_path <- file.path(
  "milestones",
  "milestone5_case_study"
)

milestone4_adsl_path <- file.path(
  "milestones",
  "milestone4_analysis_ready_dataset",
  "derived",
  "milestone4_adsl.csv"
)

# -----------------------------------------------------------------------------
# 3. Define Milestone 5 Output Paths
# -----------------------------------------------------------------------------

milestone5_derived_path <- file.path(
  milestone5_path,
  "derived"
)

milestone5_figure_path <- file.path(
  milestone5_path,
  "output",
  "figures"
)

milestone5_table_path <- file.path(
  milestone5_path,
  "output",
  "tables"
)

milestone5_listing_path <- file.path(
  milestone5_path,
  "output",
  "listings"
)


# -----------------------------------------------------------------------------
# 4. Create Milestone 5 Output Directories
# -----------------------------------------------------------------------------

dir.create(
  milestone5_derived_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  milestone5_figure_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  milestone5_table_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  milestone5_listing_path,
  recursive = TRUE,
  showWarnings = FALSE
)