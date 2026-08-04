# ============================================================
# Milestone 1: SDTM Domain Inventory
# Setup Script
# Study: EFC10261
# Author: April Morrell
# ============================================================

# -----------------------------------------------------------------------------
# 1. Load packages
# -----------------------------------------------------------------------------

library(tidyverse)
library(haven)
library(gt)

# -----------------------------------------------------------------------------
# 2. Global options
# -----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)

# ------------------------------------------------------------
# 3. Shared repository paths
# ------------------------------------------------------------

# Sponsor-provided SDTM datasets remain shared across milestones
raw_path <- file.path("data", "raw")

# ------------------------------------------------------------
# 4. Milestone-specific paths
# ------------------------------------------------------------

milestone_path <- file.path(
  "milestones",
  "milestone1_domain_inventory"
)

program_path <- file.path(
  milestone_path,
  "programs"
)

output_path <- file.path(
  milestone_path,
  "outputs"
)

derived_path <- file.path(
  output_path,
  "derived"
)

figure_path <- file.path(
  output_path,
  "figures"
)

listing_path <- file.path(
  output_path,
  "listings"
)

table_path <- file.path(
  output_path,
  "tables"
)

report_path <- file.path(
  milestone_path,
  "report"
)

# ------------------------------------------------------------
# 5. Create milestone output folders if they do not exist
# ------------------------------------------------------------

milestone_directories <- c(
  derived_path,
  figure_path,
  listing_path,
  table_path,
  report_path
)

walk(
  milestone_directories,
  ~ dir.create(
    path = .x,
    recursive = TRUE,
    showWarnings = FALSE
  )
)

# ------------------------------------------------------------
# 6. Confirm that the shared raw-data folder exists
# ------------------------------------------------------------

if (!dir.exists(raw_path)) {
  stop(
    "Raw data folder was not found: ",
    raw_path,
    "\nOpen the R project from the repository root and try again."
  )
}