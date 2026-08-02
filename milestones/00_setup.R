# ============================================================
# Phase II Oncology Clinical Trial Portfolio
# Global Setup Script
# Author: April Morrell
# ============================================================

# Load packages
library(tidyverse)
library(haven)
library(janitor)

# Global options
options(stringsAsFactors = FALSE)

# Shared source-data path
raw_path <- "data/raw/"