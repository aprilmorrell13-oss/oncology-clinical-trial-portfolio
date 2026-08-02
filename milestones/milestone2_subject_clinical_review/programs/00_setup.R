# ==============================================================================
# Milestone 2: Subject-Level Clinical Review
# Setup Script
#
# Purpose:
# Load required packages and define shared and milestone-specific folder paths.
#
# Run all Milestone 2 scripts from the repository root.
# ==============================================================================


# 1. Load required packages -----------------------------------------------------

library(tidyverse)
library(haven)
library(janitor)


# 2. Global options -------------------------------------------------------------

options(stringsAsFactors = FALSE)


# 3. Define shared project paths ------------------------------------------------

# Shared source SDTM datasets
raw_path <- file.path(
  "data",
  "raw"
)


# 4. Define Milestone 2 paths ---------------------------------------------------

milestone2_path <- file.path(
  "milestones",
  "milestone2_subject_clinical_review"
)

program_path <- file.path(
  milestone2_path,
  "programs"
)

derived_path <- file.path(
  milestone2_path,
  "derived"
)

output_path <- file.path(
  milestone2_path,
  "outputs"
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
  milestone2_path,
  "report"
)


# 5. Create output folders if missing ------------------------------------------

dir.create(
  derived_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  figure_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  listing_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  table_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  report_path,
  recursive = TRUE,
  showWarnings = FALSE
)