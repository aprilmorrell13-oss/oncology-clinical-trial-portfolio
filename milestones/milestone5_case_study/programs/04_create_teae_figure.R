###############################################################################
# Project:    Oncology Clinical Programming Portfolio
# Study:      Sanofi EFC10261 (NSCLC)
# Milestone:  5 - Clinical Programming Case Study
#
# Script:     04_create_teae_figure.R
#
# Purpose:
#   Create a horizontal bar chart showing the most frequently reported
#   treatment-emergent adverse-event preferred terms by subject incidence.
###############################################################################


# -----------------------------------------------------------------------------
# 1. Load Milestone Setup
# -----------------------------------------------------------------------------

source("milestones/milestone5_case_study/programs/00_setup.R")


# -----------------------------------------------------------------------------
# 2. Read TEAE Summary Data
# -----------------------------------------------------------------------------

teae_summary <- readr::read_csv(
  file.path(
    milestone5_table_path,
    "teae_summary_analysis.csv"
  ),
  show_col_types = FALSE
)

# -----------------------------------------------------------------------------
# 3. Select the Most Common TEAE Preferred Terms
# -----------------------------------------------------------------------------

top_teae_terms <- teae_summary %>%
  filter(row_type == "Preferred Term") %>%
  arrange(
    desc(n_subjects),
    preferred_term
  ) %>%
  slice_head(n = 15) %>%
  mutate(
    preferred_term = factor(
      preferred_term,
      levels = rev(preferred_term)
    ),
    incidence_label = sprintf(
      "%d (%.1f%%)",
      n_subjects,
      percent
    )
  )

# -----------------------------------------------------------------------------
# 4. Create TEAE Incidence Figure
# -----------------------------------------------------------------------------

teae_figure <- ggplot(
  top_teae_terms,
  aes(
    x = percent,
    y = preferred_term
  )
) +
  geom_col(
    width = 0.7,
    fill = "#2C6E9B"
  ) +
  geom_text(
    aes(label = incidence_label),
    hjust = -0.1,
    size = 3.6
  ) +
  scale_x_continuous(
    limits = c(
      0,
      max(top_teae_terms$percent) + 8
    ),
    breaks = seq(0, 40, by = 5),
    labels = function(x) paste0(x, "%"),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Most Common Treatment-Emergent Adverse Events",
    subtitle = "Top 15 preferred terms by subject incidence",
    x = "Safety population subjects (%)",
    y = NULL,
    caption = "Safety population: N = 453"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      size = 11,
      color = "grey35"
    ),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(
      size = 10,
      color = "grey20"
    ),
    plot.caption = element_text(
      hjust = 0,
      color = "grey40"
    ),
    plot.margin = margin(
      t = 10,
      r = 25,
      b = 10,
      l = 10
    )
  )

teae_figure


# -----------------------------------------------------------------------------
# 5. Validate and Save TEAE Figure
# -----------------------------------------------------------------------------

stopifnot(
  nrow(top_teae_terms) == 15,
  all(top_teae_terms$n_subjects <= 453),
  all(top_teae_terms$percent >= 0),
  all(top_teae_terms$percent <= 100),
  identical(
    as.character(top_teae_terms$preferred_term),
    rev(levels(top_teae_terms$preferred_term))
  )
)

ggsave(
  filename = file.path(
    milestone5_figure_path,
    "top_15_teae_incidence.png"
  ),
  plot = teae_figure,
  width = 12,
  height = 7,
  units = "in",
  dpi = 300,
  bg = "white"
)
