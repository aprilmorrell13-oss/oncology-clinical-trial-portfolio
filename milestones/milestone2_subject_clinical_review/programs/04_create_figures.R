# ==============================================================================
# Milestone 2: Subject-Level Clinical Story
# Script 04: Create Figures
#
# Purpose:
# Create reviewer-friendly figures summarizing treatment exposure, clinically
# important events, patient-reported outcomes, and disease response for the
# selected subject.
# ==============================================================================

# -----------------------------------------------------------------------------
# 1. Setup
# -----------------------------------------------------------------------------

source(
  file.path(
    "milestones",
    "milestone2_subject_clinical_review",
    "programs",
    "00_setup.R"
  )
)

selected_subject <- "010261-000-999-450"

# -----------------------------------------------------------------------------
# 2. Load Milestone Outputs and Required SDTM Data
# -----------------------------------------------------------------------------

subject_timeline <- readr::read_csv(
  file.path(
    derived_path,
    "milestone2_subject_timeline.csv"
  ),
  show_col_types = FALSE
)

important_ae_review <- readr::read_csv(
  file.path(
    listing_path,
    "milestone2_important_ae_review.csv"
  ),
  show_col_types = FALSE
)

qs_summary <- readr::read_csv(
  file.path(
    listing_path,
    "milestone2_qs_summary.csv"
  ),
  show_col_types = FALSE
)

ls <- haven::read_sas(
  file.path(
    raw_path,
    "ls.sas7bdat"
  )
)

lesion_review <- ls %>%
  filter(
    RUSUBJID == selected_subject,
    LSTEST == "Measurement of Target Lesion"
  ) %>%
  select(
    VISITNUM,
    LSSPID,
    LSDY,
    LSSTRESC,
    LSLOC
  ) %>%
  arrange(
    LSSPID,
    LSDY
  )

# -----------------------------------------------------------------------------
# 3. Create Patient-Reported Outcomes Figure
# -----------------------------------------------------------------------------

qs_plot_data <- qs_summary %>%
  mutate(
    measure = recode(
      QSTEST,
      "LCSS TOTAL SCORE" = "LCSS Total Score",
      "AVERAGE SYMPTOM BURDEN INDEX" = "ASBI"
    )
  )

qs_figure <- ggplot(
  qs_plot_data,
  aes(
    x = QSDY,
    y = QSSTRESN,
    group = measure,
    linetype = measure,
    shape = measure
  )
) +
  geom_line(
    linewidth = 0.8
  ) +
  geom_point(
    size = 2.5
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(
      0,
      100,
      by = 20
    )
  ) +
  labs(
    title = "Patient-Reported Outcomes Over Time",
    subtitle = paste(
      "Subject:",
      selected_subject,
      "| Lower scores indicate better outcomes"
    ),
    x = "Study Day",
    y = "Score (0-100)",
    linetype = "Measure",
    shape = "Measure"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(
      face = "bold"
    )
  )


# -----------------------------------------------------------------------------
# 4. Create Target Lesion Percent-Change Figure
# -----------------------------------------------------------------------------

lesion_plot_data <- lesion_review %>%
  mutate(
    lesion_size = as.numeric(
      LSSTRESC
    )
  ) %>%
  group_by(
    LSSPID
  ) %>%
  arrange(
    LSDY,
    .by_group = TRUE
  ) %>%
  mutate(
    baseline_size = first(
      lesion_size
    ),
    percent_change = 100 *
      (lesion_size - baseline_size) /
      baseline_size
  ) %>%
  ungroup()

lesion_figure <- ggplot(
  lesion_plot_data,
  aes(
    x = LSDY,
    y = percent_change,
    group = LSSPID,
    shape = LSSPID
  )
) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    linewidth = 0.5
  ) +
  geom_line(
    linewidth = 0.8
  ) +
  geom_point(
    size = 2.5
  ) +
  labs(
    title = "Target Lesion Size Changes from Baseline",
    subtitle = paste(
      "Subject:",
      selected_subject
    ),
    x = "Study Day",
    y = "Percent Change from Baseline",
    shape = "Target Lesion",
    caption = "Positive = growth; Negative = shrinkage."
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(
      face = "bold"
    )
  )

# -----------------------------------------------------------------------------
# 5. Prepare Subject-Level Clinical Timeline Data
# -----------------------------------------------------------------------------

# Summarize actual treatment exposure periods.
# Positive doses represent administered treatment.
treatment_plot_data <- subject_timeline %>%
  filter(
    domain == "EX",
    event %in% c(
      "DOCETAXEL",
      "PLACEBO"
    ),
    !is.na(value),
    value > 0
  ) %>%
  group_by(
    event
  ) %>%
  summarise(
    start_day = min(
      study_day,
      na.rm = TRUE
    ),
    end_day = max(
      study_day,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  mutate(
    timeline_row = recode(
      event,
      "DOCETAXEL" = "Docetaxel Exposure",
      "PLACEBO" = "Placebo Exposure"
    )
  )

# Select clinically meaningful adverse events
ae_plot_data <- important_ae_review %>%
  filter(
    AEDECOD %in% c(
      "URTICARIA",
      "PERIPHERAL SENSORY NEUROPATHY",
      "CYTOLYTIC HEPATITIS"
    )
  ) %>%
  distinct(
    AEDECOD,
    AESTDY,
    AETOXGR,
    .keep_all = TRUE
  ) %>%
  mutate(
    timeline_row = "Important Adverse Events",
    event_label = case_when(
      AEDECOD == "URTICARIA" ~
        paste0(
          "Urticaria (G",
          AETOXGR,
          ")"
        ),
      AEDECOD == "PERIPHERAL SENSORY NEUROPATHY" ~
        paste0(
          "Neuropathy (G",
          AETOXGR,
          ")"
        ),
      AEDECOD == "CYTOLYTIC HEPATITIS" ~
        paste0(
          "Hepatitis (G",
          AETOXGR,
          ")"
        ),
      TRUE ~ AEDECOD
    )
  )

# Identify disposition record for disease progression
progression_plot_data <- subject_timeline %>%
  filter(
    domain == "DS",
    stringr::str_detect(
      event,
      stringr::regex(
        "progress",
        ignore_case = TRUE
      )
    )
  ) %>%
  distinct(
    study_day,
    event
  ) %>%
  mutate(
    timeline_row = "Disease Status",
    event_label = "Disease Progression"
  )

# Set timeline row order explicitly
timeline_levels <- c(
  "Disease Status",
  "Docetaxel Exposure",
  "Important Adverse Events",
  "Placebo Exposure"
)

treatment_plot_data <- treatment_plot_data %>%
  mutate(
    timeline_row = factor(
      timeline_row,
      levels = timeline_levels
    )
  )

ae_plot_data <- ae_plot_data %>%
  mutate(
    timeline_row = factor(
      timeline_row,
      levels = timeline_levels
    )
  )

progression_plot_data <- progression_plot_data %>%
  mutate(
    timeline_row = factor(
      timeline_row,
      levels = timeline_levels
    )
  )

# -----------------------------------------------------------------------------
# 6. Create Subject-Level Clinical Timeline Figure
# -----------------------------------------------------------------------------

clinical_timeline_figure <- ggplot() +
  
  # Treatment exposure periods
  geom_segment(
    data = treatment_plot_data,
    aes(
      x = start_day,
      xend = end_day,
      y = timeline_row,
      yend = timeline_row
    ),
    linewidth = 2,
    lineend = "round"
  ) +
  
  # Treatment exposure start points
  geom_point(
    data = treatment_plot_data,
    aes(
      x = start_day,
      y = timeline_row
    ),
    shape = 21,
    size = 2.75,
    fill = "white",
    stroke = 0.8
  ) +
  
  # Treatment exposure end points
  geom_point(
    data = treatment_plot_data,
    aes(
      x = end_day,
      y = timeline_row
    ),
    shape = 21,
    size = 2.75,
    fill = "white",
    stroke = 0.8
  ) +
  
  # Important adverse event markers
  geom_point(
    data = ae_plot_data,
    aes(
      x = AESTDY,
      y = timeline_row,
      shape = AEDECOD
    ),
    size = 3
  ) +
  
  # Important adverse event labels
  geom_text(
    data = ae_plot_data,
    aes(
      x = AESTDY,
      y = timeline_row,
      label = event_label
    ),
    hjust = -0.08,
    vjust = -0.9,
    size = 3.2,
    fontface = "bold",
    check_overlap = TRUE
  ) +
  
  # Disease progression marker
  geom_point(
    data = progression_plot_data,
    aes(
      x = study_day,
      y = timeline_row
    ),
    shape = 18,
    size = 4
  ) +
  
  # Disease progression label
  geom_text(
    data = progression_plot_data,
    aes(
      x = study_day,
      y = timeline_row,
      label = event_label
    ),
    hjust = 1,
    vjust = -1,
    size = 3.4
  ) +
  
  scale_shape_manual(
    values = c(
      "URTICARIA" = 15,
      "PERIPHERAL SENSORY NEUROPATHY" = 17,
      "CYTOLYTIC HEPATITIS" = 16
    )
  ) +
  
  scale_x_continuous(
    breaks = seq(
      0,
      450,
      by = 50
    ),
    limits = c(
      0,
      475
    ),
    expand = expansion(
      mult = c(
        0.01,
        0.01
      )
    )
  ) +
  
  labs(
    title = "Subject-Level Clinical Timeline",
    subtitle = paste(
      "Subject:",
      selected_subject
    ),
    x = "Study Day",
    y = NULL
  ) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(
      face = "bold"
    ),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(
      face = "bold",
      size = 11
    ),
    legend.position = "none",
    plot.margin = margin(
      t = 15,
      r = 30,
      b = 15,
      l = 15
    )
  )

clinical_timeline_figure

# -----------------------------------------------------------------------------
# 7. Validate Figure Inputs
# -----------------------------------------------------------------------------

stopifnot(
  nrow(qs_plot_data) > 0,
  nrow(lesion_plot_data) > 0,
  nrow(treatment_plot_data) == 2,
  nrow(ae_plot_data) == 3,
  nrow(progression_plot_data) > 0
)

stopifnot(
  all(
    qs_plot_data$measure %in% c(
      "LCSS Total Score",
      "ASBI"
    )
  )
)

stopifnot(
  all(
    treatment_plot_data$start_day <=
      treatment_plot_data$end_day
  )
)

# -----------------------------------------------------------------------------
# 8. Save Figures
# -----------------------------------------------------------------------------

ggsave(
  filename = file.path(
    figure_path,
    "milestone2_patient_reported_outcomes.png"
  ),
  plot = qs_figure,
  width = 8,
  height = 5,
  dpi = 300
)

ggsave(
  filename = file.path(
    figure_path,
    "milestone2_target_lesion_percent_change.png"
  ),
  plot = lesion_figure,
  width = 8,
  height = 5,
  dpi = 300
)

ggsave(
  filename = file.path(
    figure_path,
    "milestone2_subject_clinical_timeline.png"
  ),
  plot = clinical_timeline_figure,
  width = 11,
  height = 5.5,
  dpi = 300
)