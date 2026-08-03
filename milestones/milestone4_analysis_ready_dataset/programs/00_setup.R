###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  4 - Analysis-Ready Dataset Exploration
#
# Script:     00_setup.R
#
# Purpose:
#   Load shared project settings, define Milestone 4 paths, and create the
#   required milestone-specific output directories.
###############################################################################


# -----------------------------------------------------------------------------
# 1. Load Global Project Setup
# -----------------------------------------------------------------------------

source("milestones/00_setup.R")


# -----------------------------------------------------------------------------
# 2. Define Milestone 4 Root Path
# -----------------------------------------------------------------------------

milestone4_path <- file.path(
  "milestones",
  "milestone4_analysis_ready_dataset"
)


# -----------------------------------------------------------------------------
# 3. Define Milestone 4 Output Paths
# -----------------------------------------------------------------------------

milestone4_derived_path <- file.path(
  milestone4_path,
  "derived"
)

milestone4_figure_path <- file.path(
  milestone4_path,
  "output",
  "figures"
)

milestone4_table_path <- file.path(
  milestone4_path,
  "output",
  "tables"
)

milestone4_listing_path <- file.path(
  milestone4_path,
  "output",
  "listings"
)


# -----------------------------------------------------------------------------
# 4. Create Milestone 4 Output Directories
# -----------------------------------------------------------------------------

dir.create(
  milestone4_derived_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  milestone4_figure_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  milestone4_table_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  milestone4_listing_path,
  recursive = TRUE,
  showWarnings = FALSE
)