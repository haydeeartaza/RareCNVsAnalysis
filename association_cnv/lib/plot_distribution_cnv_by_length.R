#!/usr/bin/env Rscript

## This script generates plot for the CNVs length distribution in cases and controls.
# 
# Args:
# 1.Length distribution file in CNV deletions
# 2.Length distribution file in CNV duplications
#
##


library(ggplot2)
library(ggpubr)
library(ggtext)
library(gridExtra)
source(file.path(getwd(), "association_cnv/lib/plots_functions.R"))

args = commandArgs(TRUE)
case_control_CNVs_length_del = args[1]
case_control_CNVs_length_dup = args[2]
outputdir = args[3]

     
case_control_length_samples_output = paste(outputdir, "CNVs_distributin_by_length.png", sep = '/')
data <- read.table(case_control_CNVs_length_del, header = T, sep = "\t")
data$length <- factor(data$length, levels = unique(data$length))
data[data$pheno == 1,]$pheno = "CONTROL"
data[data$pheno == 2,]$pheno = "CASE"

#png(case_control_length_samples_output, width = 880, height = 580)

cbPalette <- c("#D55E00", "#56B4E9")
p1 <- ggplot(data = data, aes(x = length, y = numCNV, group = pheno, colour = factor(pheno))) + 
	geom_line() + 
	geom_point() + 
	scale_colour_manual(values = cbPalette) +
	theme_bw() +
    theme(plot.title = element_textbox(hjust=0.5,
			  				           width = unit(0.9, "npc"),
					                   size = 7)) +
	labs(title="Number of CNVs (DELETIONS) distributed by length and grouped by Case/Control category", x = "CNVs length (Kb)",y = "CNVs")

data <- read.table(case_control_CNVs_length_dup, header = T, sep = "\t")
data$length <- factor(data$length, levels = unique(data$length))
data[data$pheno == 1,]$pheno = "CONTROL"
data[data$pheno == 2,]$pheno = "CASE"


p2 <- ggplot(data = data, aes(x = length, y = numCNV, group = pheno, colour = factor(pheno))) + 
	geom_line() + 
	geom_point() + 
	scale_colour_manual(name = "CLASS", labels = c("CASE","CONTROL"), values = cbPalette) +
	theme_bw() +
    theme(plot.title = element_textbox(hjust=0.5,
			  				           width = unit(0.9, "npc"),
					                   size = 7)) +
	labs(title = "Number of CNVs (DUPLICATIONS) distributed by length and grouped by Case/Control category", x = "CNVs length (Kb)", y = "CNVs") + 

p3 <- grid.arrange(p1, p2, ncol = 1)
p3 <- ggarrange(p1, p2, ncol = 1, nrow = 2, common.legend=T, legend="bottom")

savePlot(filename=case_control_length_samples_output, plot=p3, width=1900, height=1100)
#dev.off()
