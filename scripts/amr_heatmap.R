# =====================================================
# Script: amr_heatmap.R
# Purpose: Build an annotated antimicrobial resistance heatmap
#          from abricate/CARD output, with plasmid/chromosome
#          location annotation.
# Input:   amr_results.tsv (abricate --db card output)
# Output:  AMR_Heatmap_KPneumoniae_HS11286.pdf / .png (300dpi)
# =====================================================

library(dplyr)
library(tidyr)
library(readr)
library(ComplexHeatmap)
library(circlize)
library(grid)

setwd("path/to/results")  # set to your working directory

# ---- Load and parse ----
amr <- read_tsv("amr_results.tsv")

# NC_016845.1 is the chromosome in this assembly; all other
# sequence IDs correspond to plasmids
amr <- amr %>%
  mutate(location = ifelse(SEQUENCE == "NC_016845.1", "Chromosome", "Plasmid"))

# RESISTANCE can list multiple antibiotic classes per gene (";"-separated);
# expand to one row per gene-class pair for the matrix
amr_long <- amr %>%
  filter(!is.na(RESISTANCE)) %>%
  separate_rows(RESISTANCE, sep = ";") %>%
  mutate(RESISTANCE = trimws(RESISTANCE)) %>%
  select(GENE, RESISTANCE, `%IDENTITY`, location) %>%
  distinct()

# ---- Build matrix ----
# Some genes appear multiple times in the assembly (e.g. gene duplication);
# keep the highest identity match per gene-class pair
amr_matrix_df <- amr_long %>%
  group_by(GENE, RESISTANCE) %>%
  summarise(identity = max(`%IDENTITY`), .groups = "drop")

gene_location <- amr_long %>%
  distinct(GENE, location) %>%
  distinct(GENE, .keep_all = TRUE)

mat_wide <- amr_matrix_df %>%
  pivot_wider(names_from = RESISTANCE, values_from = identity, values_fill = 0)

mat <- as.matrix(mat_wide[, -1])
rownames(mat) <- mat_wide$GENE
gene_location <- gene_location[match(rownames(mat), gene_location$GENE), ]

# ---- Visualization ----
col_fun <- colorRamp2(c(0, 50, 100), c("#f7f7f7", "#4393c3", "#053061"))

side_colors <- c("Plasmid" = "#D7263D", "Chromosome" = "#2166AC")
row_anno <- rowAnnotation(
  Location = gene_location$location,
  col = list(Location = side_colors),
  annotation_legend_param = list(Location = list(title = "Gene Location")),
  show_annotation_name = FALSE
)

ht <- Heatmap(
  mat,
  name = "%Identity",
  col = col_fun,
  left_annotation = row_anno,
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  show_row_names = TRUE,
  row_names_gp = gpar(fontsize = 8),
  column_names_gp = gpar(fontsize = 9, fontface = "bold"),
  column_names_rot = 45,
  column_title = "Antimicrobial Resistance Profile: K. pneumoniae HS11286 (GCF_000240185.1)",
  column_title_gp = gpar(fontsize = 12, fontface = "bold"),
  heatmap_legend_param = list(title = "% Identity to\nCARD reference"),
  rect_gp = gpar(col = "white", lwd = 0.5),
  border = TRUE,
  row_names_max_width = max_text_width(rownames(mat), gp = gpar(fontsize = 8))
)

# ---- Export (white background, vector PDF, 300dpi) ----
pdf("AMR_Heatmap_KPneumoniae_HS11286.pdf", width = 15, height = 10, bg = "white")
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "right",
     padding = unit(c(2, 2, 15, 2), "mm"))
dev.off()

png("AMR_Heatmap_KPneumoniae_HS11286.png", width = 15, height = 10, units = "in", res = 300, bg = "white")
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "right",
     padding = unit(c(2, 2, 15, 2), "mm"))
dev.off()
