# ============================================================
# Phase II Oncology Clinical Trial Portfolio
# Setup Script
# Author: April Morrell
# ============================================================

# Load packages
library(tidyverse)
library(haven)
library(janitor)

# Global options
options(stringsAsFactors = FALSE)

# Folder paths
raw_path <- "data/raw/"
derived_path <- "data/derived/"
figure_path <- "output/figures/"
table_path <- "output/tables/"
listing_path <- "output/listings/"