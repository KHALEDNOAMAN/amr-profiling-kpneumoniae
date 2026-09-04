# =====================================================
# Script: vfdb_lollipop.R
# Purpose: Summarize VFDB virulence gene hits by functional
#          category and plot as a lollipop chart.
# Input:   virulence_results.tsv (abricate --db vfdb output)
# Output:  VFDB_Virulence_LollipopChart.pdf / .png (300dpi)
# =====================================================

library(readr)
library(dplyr)
library(stringr)
library(forcats)
library(ggplot2)
library(scales)

setwd("path/to/results")  # set to your working directory

# ---- Load and parse ----
vf <- read_tsv("virulence_results.tsv")

# Functional category is embedded in PRODUCT, e.g.:
# "... [ECP (VF0404) - Adherence (VFC0001)] [...]"
# Category text may include "/" (e.g. "Antimicrobial activity/Competitive
# advantage"), so match any non-bracket characters preceding "(VFC".
vf <- vf %>%
  mutate(
    vf_category = str_extract(PRODUCT, "(?<=- )[^\\[\\(]+(?=\\(VFC)"),
    vf_category = trimws(vf_category)
  )

# ---- Summarize ----
vf_summary <- vf %>%
  count(vf_category, name = "gene_count") %>%
  mutate(
    vf_category = fct_reorder(vf_category, gene_count),
    pct = round(100 * gene_count / sum(gene_count), 1)
  )

# ---- Visualization ----
p_vf <- ggplot(vf_summary, aes(x = vf_category, y = gene_count)) +
  geom_segment(aes(xend = vf_category, y = 0, yend = gene_count, color = gene_count),
               linewidth = 2.2, lineend = "round") +
  geom_point(aes(color = gene_count), size = 9) +
  geom_text(aes(label = gene_count), color = "white", size = 3.3, fontface = "bold") +
  geom_text(aes(label = paste0(pct, "%")), hjust = -0.9, size = 3.2, color = "grey40") +
  coord_flip(clip = "off") +
  scale_color_gradient(low = "#4393c3", high = "#08306b") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18)), breaks = pretty_breaks()) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = "grey90", linewidth = 0.3),
    axis.text.y = element_text(size = 11, color = "grey20"),
    axis.title.x = element_text(size = 11, color = "grey30", margin = margin(t = 8)),
    plot.title = element_text(face = "bold", size = 15, margin = margin(b = 3)),
    plot.subtitle = element_text(size = 11, color = "grey40", margin = margin(b = 15)),
    plot.caption = element_text(size = 8.5, color = "grey50", hjust = 0, margin = margin(t = 12)),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(15, 25, 10, 10)
  ) +
  labs(
    title = "Virulence Factor Landscape",
    subtitle = paste0("K. pneumoniae HS11286 · ", sum(vf_summary$gene_count), " virulence genes across ",
                       nrow(vf_summary), " functional categories"),
    x = NULL,
    y = "Number of Genes",
    caption = "Assembly: GCF_000240185.1 (RefSeq)  ·  Database: VFDB  ·  Tool: abricate v1.4.0"
  )

# ---- Export (white background, vector PDF, 300dpi) ----
ggsave("VFDB_Virulence_LollipopChart.pdf", p_vf, width = 10, height = 6.5, dpi = 300, bg = "white")
ggsave("VFDB_Virulence_LollipopChart.png", p_vf, width = 10, height = 6.5, dpi = 300, bg = "white")
