#!/usr/bin/env Rscript

## This script plot samples vs CNVs distribution
#
# Args:
# 1.input tsv file containing the number of samples with X CNVs and its ratio in the population (cases or controls)
# 2.output path + png file name
# 3.input tsv file with number of samples in each interval CNVs size, grouped by class (1:controls and 2:cases)
# 4.output path + png file name
#
##

args = commandArgs(TRUE)
samplesdistributionfile = args[1]
output1 = args[2]
samplesaveragedistlengthfile = args[3]
output2 = args[4]

library(ggplot2)




df <- read.table(samplesdistributionfile, header = T, sep = "\t")
df <-df[order(df$NUM_CNVS),]
png(output1, width=900, height=700)
df[df$CLASE==1,]$CLASE = "CONTROL"
df[df$CLASE==2,]$CLASE = "CASE"
ggplot(data=df, aes(x=NUM_CNVS, y=RATIO_SAMPLES, fill=CLASE)) +  
	geom_bar(stat="identity",position=position_dodge()) +  
	labs(title="Number of CNVs per Individual", x="Number of CNVs", y="Individuals (proportion)") + 
	geom_text(aes(label=NUM_SAMPLES), vjust=1.6, position = position_dodge(0.9), size=3.5) + 
	scale_x_continuous(breaks = seq(0, 20, by = 1)) +
	theme(legend.position="bottom") 
dev.off()


df <- read.table(samplesaveragedistlengthfile, header = T, sep = "\t")
df[df$CLASE==1,]$CLASE = "CONTROL"
df[df$CLASE==2,]$CLASE = "CASE"
png(output2, width=900, height=700)
ggplot(data=df, aes(x=factor(INTERVAL, factor(unique(INTERVAL))), y=RATIO_SAMPLES, fill=CLASE)) +  geom_bar(stat="identity",position=position_dodge()) +  
    labs(title="Ratio of individulas with AVERAGE length of CNVs in five intervals", x="CNVs length intervals", y="Proportion of Individuals") + 
    geom_text(aes(label=NUM_SAMPLES), vjust=1.6, position = position_dodge(0.9), size=3.5) +
    theme(legend.position="bottom")
dev.off()
