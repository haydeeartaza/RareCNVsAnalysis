#!/usr/bin/env Rscript

## This script plot frequency distribution
#
# Args:
# 1.input .tsv frequency file
# 2.output path+ png file name
#
##
source(file.path(getwd(), "association_cnv/lib/plots_functions.R"))

args = commandArgs(TRUE)
frequencyfile = args[1]
output = args[2]

library(ggplot2)


df <- read.table(frequencyfile, header = T, sep = "\t")
df <- df[order(df$FREQ_IN_POP),]
df$XLABEL = round(df$FREQ_IN_POP*100, digits = 2)

#png(output, width = 1200, height = 800)
p0<- ggplot(data = df, aes(x = sprintf("%.2f", XLABEL), y = TOTAL_CNVR_IN_FREQ, label = CNVR_FREQ_COUNTS )) +  
		geom_bar(stat = "identity", fill = "#56B4E9", position = position_dodge2(width = 0.9, preserve = 'single')) +  
		labs(y = "Loci", x = " Frequency(%)") + theme(axis.text.x = element_text(face = "bold", angle = 90, hjust = 1, size = 8.5)) +  
		geom_text(size = 3, position = position_dodge2(width = 0.9, preserve = "single"), vjust = -0.5)

#dev.off()
savePlot(filename=output, plot=p0, width=1900, height=1100)