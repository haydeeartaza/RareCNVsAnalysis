#!/usr/bin/env Rscript

## This script plot frequency distribution
#
# Args:
# 1.input .tsv frequency file
# 2.output path+ png file name
#
##


args = commandArgs(TRUE)
frequencyfile = args[1]
output = args[2]

library(ggplot2)


df <- read.table(frequencyfile, header = T, sep = "\t")
df <-df[order(df$FREQ_IN_POP),]
df$XLABEL=round(df$FREQ_IN_POP*100,digits=2)

png(output, width=1200, height=800)
ggplot(data=df, aes(x=factor(XLABEL, factor(XLABEL)), y=TOTAL_CNVR_IN_FREQ, label = CNVR_FREQ_COUNTS )) +  
	geom_bar(stat="identity", fill="steelblue") +  labs(y="Loci", x = " Frequency(%)") + 
	theme(axis.text.x=element_text(angle = 90, hjust = 1, size = 8)) +  
	geom_text(size = 3, angle = 90, position = position_stack(vjust = 0.5)) 

dev.off()
