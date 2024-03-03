#!/usr/bin/env Rscript

##
#
# This script creates a violin plot showing the  number of calls by samples BEFORE and AFTER merging process.
#
# Input:
# 1.Three columns file contanining the sample ID, calls before merging and calls after merging
# 2.Output directory
# Output:
# 1.Violing plot with number of calls distribution before and after merging process
#
##

library(ggplot2)
library(reshape)
library(introdataviz)
source(file.path(getwd(), "qc-cnv/lib/qc_plots_functions.R"))

args = commandArgs(trailingOnly = TRUE)
merge_comparison_file = args[1] 
out_dir = args[2]

data <- read.table(merge_comparison_file, header = T, sep = "\t")

 datamelt <- melt(data,id=("ID"))
 datamelt$condition <- "mergin"
# png(paste(out_dir,"NumCalls_distribution_merging.png",sep="/"), width = 780, height = 580)
 cbPalette <- c("#D55E00", "#56B4E9")
p0 <- ggplot(data = datamelt, aes(y = value, x = condition , fill = variable, shape = variable)) + 
         introdataviz::geom_split_violin(alpha = .4, trim = FALSE) +
         geom_boxplot(width = .2, alpha = .6, fatten = NULL, show.legend = FALSE) +
         stat_summary(fun.data = "mean_se", geom = "pointrange", show.legend = F, 
                      position = position_dodge(.175)) +
         labs(title="Distribution of call number per samples", x ="", y = "NumCNV") +
         theme_minimal() + theme( axis.text.x=element_blank()) +  
	 scale_fill_manual(values=cbPalette, name = "", labels = c("Before merging", "After merging"))
# dev.off()
 savePlot(filename=paste(out_dir,"NumCalls_distribution_merging.png",sep="/"), plot=p0, width=1700, height=1100)
