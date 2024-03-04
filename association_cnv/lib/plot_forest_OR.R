#!/usr/bin/env Rscript

## This script plot OR forest distribution
#
# Args:
# 1.input tsv file with OR distribution 
# 2.output path + png file name
#
##
source(file.path(getwd(), "association_cnv/lib/plots_functions.R"))

args = commandArgs(TRUE)
orfile = args[1]
output = args[2]

library(ggplot2)

df <- read.table(orfile, header = TRUE, sep = '\t')
df$Length <- as.character(df$Length)
df$Length[df$Length == "1000KB_1000000KB"] <- "1000KB_>"
df$Length <- factor(df$Length, levels=unique(df$Length))
  
#png(output, width = 900, height = 600)
p0<- ggplot(df, aes(x = Length, y = log2(OR), ymin = log2(X95.CI.lower), ymax = log2(X95.CI.upper))) + 
        geom_pointrange() + 
        geom_hline(yintercept = log2(1), lty = 2) +
        geom_text(aes(label = paste0('p=',formatC(P, format = "e", digits = 1),'')), vjust = -0.9, position = position_dodge(0.8), size = 3.5) +
        coord_flip() +
        xlab("Interval") + ylab("Odds Ratio") +
        #scale_y_continuous(breaks = c(-2, -1, 0, 1, 2, 3, 4), labels = c("1/4", "1/2", "1", "2", "4", "8", "16"), limits = c(-2, 4)) +
        scale_y_continuous(breaks = c(-3,-2, -1, 0, 1, 2, 3, 4, 5), labels = c("1/8", "1/4", "1/2", "1", "2", "4", "8", "16", "32"), limits = c(-4, 5)) +
        #scale_y_continuous(breaks = c(-3,-2, -1, 0, 1, 2, 3, 4, 5, 6), labels = c("1/8", "1/4", "1/2", "1", "2", "4", "8", "16", "32", 64), limits = c(-4, 6)) +
        #facet_wrap(~CN) + 
        theme_bw()  + 
        theme(axis.text = element_text(size = 15, face = "bold"), axis.title = element_text(size = 22)) 
        #theme(legend.position="bottom")

#dev.off()
savePlot(filename=output, plot=p0, width=1900, height=1100)

