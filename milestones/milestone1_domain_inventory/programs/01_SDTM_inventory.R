# ============================================================
# Milestone 1: SDTM Domain Inventory
# Study: EFC10261
# Author: April Morrell
# ============================================================

# Load milestone-specific setup
source(
  file.path(
    "milestones",
    "milestone1_domain_inventory",
    "programs",
    "00_setup.R"
  )
)

# ------------------------------------------------------------
# Identify the sponsor-provided SDTM datasets
# ------------------------------------------------------------

sdtm_files <- list.files(
  path = raw_path,
  pattern = "\\.sas7bdat$",
  full.names = TRUE,
  ignore.case = TRUE
)

if (length(sdtm_files) == 0) {
  stop(
    "No SAS datasets were found in: ",
    raw_path
  )
}

# ------------------------------------------------------------
# Create the programmatic dataset inventory
# ------------------------------------------------------------

sdtm_inventory <- map_dfr(
  sdtm_files,
  function(file) {
    
    dataset <- read_sas(file)
    
    tibble(
      domain = tools::file_path_sans_ext(
        basename(file)
      ) %>%
        toupper(),
      n_records = nrow(dataset),
      n_variables = ncol(dataset)
    )
  }
) %>%
  arrange(domain)

# View the initial inventory
print(sdtm_inventory)

# ------------------------------------------------------------
# Define domain-level metadata
# ------------------------------------------------------------

domain_metadata <- tribble(
  ~domain, ~description, ~class, ~observational_unit,
  
  "DM",
  "Demographics",
  "Special Purpose",
  "One record per subject",
  
  "EX",
  "Exposure",
  "Interventions",
  "One record per treatment exposure for a subject",
  
  "AE",
  "Adverse Events",
  "Events",
  "One record per adverse event",
  
  "CD",
  "Cancer Diagnosis",
  "Findings",
  "One record per cancer assessment for a subject",
  
  "CE",
  "Clinical Event",
  "Events",
  "One record per clinical event experienced by a subject",
  
  "CM",
  "Concurrent Medication",
  "Interventions",
  "One record per concomitant medication used by a subject",
  
  "DS",
  "Disposition",
  "Events",
  "One record per disposition experienced by a subject",
  
  "EG",
  "Electrocardiogram Test",
  "Findings",
  "One record per ECG assessment (test) performed on a subject",
  
  "IE",
  "Inclusion/Exclusion Criterion",
  "Special Purpose",
  "One record per inclusion/exclusion criterion assessment for a subject",
  
  "LB",
  "Laboratory Test",
  "Findings",
  "One record per laboratory assessment performed on a subject",
  
  "LS",
  "Lesion",
  "Findings",
  "One record per lesion assessment for a subject",
  
  "MH",
  "Medical History",
  "Events",
  "One record per medical history event or condition for a subject",
  
  "PC",
  "Pharmacokinetic Test",
  "Findings",
  "One record per pharmacokinetic test performed on a subject",
  
  "PE",
  "Physical Examination",
  "Findings",
  "One record per physical examination assessment performed on a subject",
  
  "QS",
  "Questionnaire",
  "Findings",
  "One record per questionnaire result for a subject",
  
  "RA",
  "Radiotherapy",
  "Interventions",
  "One record per radiotherapy treatment administered to a subject",
  
  "SG",
  "Surgery",
  "Interventions",
  "One record per surgery procedure for a subject",
  
  "SU",
  "Substance Use",
  "Findings",
  "One record per reported substance use record for a subject",
  
  "SV",
  "Subject Visits",
  "Special Purpose",
  "One record per subject visit",
  
  "TA",
  "Trial Arms",
  "Special Purpose",
  "One record per planned study element within a treatment arm",
  
  "TE",
  "Trial Elements",
  "Special Purpose",
  "One record per planned study element",
  
  "TI",
  "Trial Inclusion/Exclusion Criteria",
  "Special Purpose",
  "One record per inclusion or exclusion criterion defined in the study protocol",
  
  "TS",
  "Trial Summary",
  "Special Purpose",
  "One record per trial summary parameter",
  
  "TV",
  "Trial Visits",
  "Special Purpose",
  "One record per planned study visit",
  
  "VS",
  "Vital Signs",
  "Findings",
  "One record per vital sign assessment for a subject"
)

# ------------------------------------------------------------
# Add the descriptive metadata to the inventory
# ------------------------------------------------------------

sdtm_inventory <- sdtm_inventory %>%
  left_join(
    domain_metadata,
    by = "domain"
  ) %>%
  select(
    domain,
    description,
    class,
    n_records,
    n_variables,
    observational_unit
  )

# ------------------------------------------------------------
# Confirm that metadata exists for every imported domain
# ------------------------------------------------------------

missing_metadata <- sdtm_inventory %>%
  filter(
    is.na(description) |
      is.na(class) |
      is.na(observational_unit)
  )

if (nrow(missing_metadata) > 0) {
  stop(
    "Metadata is missing for: ",
    paste(
      missing_metadata$domain,
      collapse = ", "
    )
  )
}

# View the completed inventory
print(sdtm_inventory)

# ------------------------------------------------------------
# Save the final inventory as a milestone-specific CSV
# ------------------------------------------------------------

write_csv(
  sdtm_inventory,
  file.path(
    table_path,
    "sdtm_inventory.csv"
  )
)

# ------------------------------------------------------------
# Save the formatted inventory as a milestone-specific figure
# ------------------------------------------------------------

sdtm_inventory %>%
  gt() %>%
  tab_header(
    title = "SDTM Domain Inventory",
    subtitle = "Sanofi EFC10261"
  ) %>%
  gtsave(
    filename = file.path(
      figure_path,
      "sdtm_inventory.png"
    )
  )

# ------------------------------------------------------------
# Completion message
# ------------------------------------------------------------

message(
  "Milestone 1 inventory completed successfully.",
  "\nCSV: ",
  file.path(table_path, "sdtm_inventory.csv"),
  "\nFigure: ",
  file.path(figure_path, "sdtm_inventory.png")
)