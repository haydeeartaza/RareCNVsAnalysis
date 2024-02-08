#!/usr/bin/env Rscript

## This script generates plot for the CNVs length distribution in cases and controls.
# 
# Args:
# 1.Length distribution file in CNV deletions
# 2.Length distribution file in CNV duplications
#
##


library(ggplot2)
library(gridExtra)

args = commandArgs(TRUE)
case_control_CNVs_length_del = args[1]
case_control_CNVs_length_dup = args[2]
outputdir = args[3]

     
case_control_length_samples_output=paste(outputdir,"CNVs_distributin_by_length.png",sep='/')
data <- read.table(case_control_CNVs_length_del, header = T, sep = "\t")
data$length <- factor(data$length, levels = unique(data$length))

png(case_control_length_samples_output, width = 880, height = 580)

p1 <- ggplot(data=data, aes(x=length, y=numCNV, group=pheno, colour=factor(pheno))) + geom_line() + geom_point() +
    labs(title="Number of CNVs (DELETIONS) distributed by length and grouped by Case/Control category", 
             x="CNVs length (Kb)",y="Number of CNVs") +
scale_color_discrete(name = "CAT", labels = c("Control","Case"))

data <- read.table(case_control_CNVs_length_dup, header = T, sep = "\t")
data$length <- factor(data$length, levels = unique(data$length))


p2 <- ggplot(data=data, aes(x=length, y=numCNV, group=pheno, colour=factor(pheno))) + geom_line() + geom_point() +
    labs(title="Number of CNVs (DUPLICATIONS) distributed by length and grouped by Case/Control category",
             x="CNVs length (Kb)",y="Number of CNVs") +
scale_color_discrete(name = "CAT", labels = c("Control","Case"))

grid.arrange(p1, p2, ncol = 1)

dev.off()
