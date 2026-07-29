# ============================================================
# SDTM Dataset Inventory
# Study: EFC10261
# ============================================================

source("R/00_setup.R")
library(haven)
library(tidyverse)

# Find every SAS dataset in the raw data folder
sdtm_files <- list.files(
  path = raw_path,
  pattern = "\\.sas7bdat$",
  full.names = TRUE,
  ignore.case = TRUE
)

# Read each dataset temporarily and collect inventory information
sdtm_inventory <- map_dfr(sdtm_files, function(file){
  dataset <- read_sas(file)
  tibble(
    domain = tools::file_path_sans_ext(basename(file)) %>% toupper(),
    n_records = nrow(dataset),
    n_variables = ncol(dataset)
  )
})

# Sort domains alphabetically
sdtm_inventory <- sdtm_inventory %>%
  arrange(domain)

# View the inventory
print(sdtm_inventory)

domain_metadata <- tribble(
  ~domain, ~description, ~class, ~observational_unit, 
  "DM", "Demographics", "Special Purpose", "One record per subject", 
  "EX", "Exposure", "Interventions", "One record per treatment exposure for a subject",
  "AE", "Adverse Events", "Events", "One record per adverse event",
  "CD", "Cancer Diagnosis", "Findings", "One record per cancer assessment for a subject",
  "CE", "Clinical Event", "Events", "One record per clinical event experienced by a subject",
  "CM", "Concurrent Medication", "Interventions", "One record per concomitant medication used by a subject",
  "DS", "Disposition", "Events", "One record per disposition experienced by a subject",
  "EG", "Electrocardiogram Test", "Findings", "One record per ECG assessment (test) performed on a subject",
  "IE", "Inclusion/Exclusion Criterion", "Special Purpose", "One record per inclusion/exclusion criterion assessment for a subject",
  "LB", "Laboratory Test", "Findings", "One record per laboratory assessment performed on a subject",
  "LS", "Lesion", "Findings", "One record per lesion assessment for a subject",
  "MH", "Medical History", "Events", "One record per medical history event or condition for a subject",
  "PC", "Pharmacokinetic Test", "Findings", "One record per pharmacokinetic test performed on a subject",
  "PE", "Physical Examination", "Findings", "One record per physical examination assessment performed on a subject",
  "QS", "Questionnaire", "Findings", "One record per questionnaire result for a subject",
  "RA", "Radiotherapy", "Interventions", "One record per radiotherapy treatment administered to a subject",
  "SG", "Surgery", "Interventions", "One record per surgery procedure for a subject",
  "SU", "Substance Use", "Findings", "One record per reported substance use record for a subject",
  "SV", "Subject Visits", "Special Purpose", "One record per subject visit",
  "TA", "Trial Arms", "Special Purpose", "One record per planned study element within a treatment arm",
  "TE", "Trial Elements", "Special Purpose", "One record per planned study element",
  "TI", "Trial Inclusion/Exclusion Criteria", "Special Purpose", "One record per inclusion or exclusion criterion defined in the study protocol",
  "TS", "Trial Summary", "Special Purpose", "One record per trial summary parameter",
  "TV", "Trial Visits", "Special Purpose", "One record per planned study visit",
  "VS", "Vital Signs", "Findings", "One record per vital sign assessment for a subject"
)

sdtm_inventory <- sdtm_inventory %>%
  left_join(domain_metadata, by = "domain") %>%
  select(
    domain,
    description,
    class,
    n_records,
    n_variables,
    observational_unit
  )

# Check that metadata was supplied for every imported domain
missing_metadata <- sdtm_inventory %>%
  filter(
    is.na(description) |
      is.na(class) |
      is.na(observational_unit)
  )

if (nrow(missing_metadata) > 0) {
  stop(
    "Metadata is missing for: ",
    paste(missing_metadata$domain, collapse = ", ")
  )
}

# Save the inventory as a CSV file
write_csv(
  sdtm_inventory,
  file.path(table_path, "sdtm_inventory.csv")
)

library(gt)

sdtm_inventory %>%
  gt() %>%
  tab_header(
    title = "SDTM Domain Inventory",
    subtitle = "Sanofi EFC10261"
  ) %>%
  gtsave(
    filename = file.path(figure_path, "sdtm_inventory.png")
  )