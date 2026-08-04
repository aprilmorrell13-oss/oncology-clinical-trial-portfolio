###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  3 - Cross-Domain Data Validation
#
# Script:     00_setup.R
#
# Purpose:
#   Load required R packages and define file paths used by the Milestone 3
#   cross-domain validation programs.
###############################################################################

# -----------------------------------------------------------------------------
# 1. Load Packages
# -----------------------------------------------------------------------------

library(tidyverse)
library(haven)
library(janitor)

# Global Options

options(stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# 2. Define Project Paths
# -----------------------------------------------------------------------------

# Shared source data
raw_path <- "data/raw"

# Milestone-specific root directory
milestone_path <- "milestones/milestone3_cross_domain_validation"

# Milestone-specific program directory
program_path <- file.path(
  milestone_path,
  "programs"
)

# Milestone-specific output directories
output_path <- file.path(
  milestone_path,
  "output"
)

derived_path <- file.path(
  output_path,
  "derived"
)

listing_path <- file.path(
  output_path,
  "listings"
)

figure_path <- file.path(
  output_path,
  "figures"
)

table_path <- file.path(
  output_path,
  "tables"
)

# -----------------------------------------------------------------------------
# 3. Create Output Directories
# -----------------------------------------------------------------------------

dir.create(
  output_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  derived_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  listing_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  figure_path,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  table_path,
  recursive = TRUE,
  showWarnings = FALSE
)