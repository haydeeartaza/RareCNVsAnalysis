#!/usr/bin/env Rscript

##
#
# This script creates a plot for QC parameters grouped by PASS and FAIL based on the fileter criteria (LRR, BAF and WF)
#
#Input:
#1.QC summary for all samples (generated with PennCNV filter_cnv.pl command)
#2.Output PREFIX file
#Output:
#1.Box plots for statistics for each sample
#2.Scatter plots for number of calls (NunCNV) versus samples statistics
#
##

library(ggplot2)
library(ggtext)
library(ggpubr)
library(reshape)
library(gridExtra)

source(file.path(getwd(), "qc-cnv/lib/qc_plots_functions.R"))
args = commandArgs(trailingOnly = TRUE)
sample_qcsum_list = args[1]
prefix_output_file = args[2]

default_parametes_output_file = paste(prefix_output_file,"QC_default_parametes_PennCNV.png", sep = "_")
numCNV_output_file = paste(prefix_output_file,"NumCNV_vs_parametres.png", sep = "_")
histogram_output_file = paste(prefix_output_file,"histogram_LRR_SSD_and_NumCNV.png", sep = "_")
data <- read.table(sample_qcsum_list, header = T, sep = "\t")

data$filter<-(data$LRR_SD < 0.3 & data$BAF_drift < 0.01 & abs(data$WF) < 0.05) #sample does not pass if this result is FALSE (it have to meet with the three of them)
data$filter[data$filter == TRUE] = "PASS"
data$filter[data$filter == FALSE] = "FAIL"
datamelt<-melt(data, measure.vars = (c("LRR_mean", "LRR_SD", "BAF_mean", "BAF_SD", "BAF_drift", "WF")))

cbPalette <- c("#D55E00", "#56B4E9")
p0_subtitle <- "Default PennCNV parameters: LRR_SD < 0.3, BAF_drift < 0.01, |WF| < 0.05"
p0 <- ggplot(datamelt, aes(x = filter, y = value, fill = filter)) + 
	geom_boxplot() +
	scale_fill_manual(values = cbPalette, name = "QC") + 
	theme_bw() + 
	theme(axis.text.x = element_blank(),
	      plot.title = element_textbox(hjust = 0.5,
					   size = 10), 
	      plot.subtitle = element_textbox(hjust = 0.5,
					   width = unit(0.7, "npc"),
					   size = 7),
	      legend.position="top",
	      axis.text.y = element_text(size = 5.5)) +
	      facet_wrap(~ variable, scales = "free", ncol = 6) + 
	      labs(title = "Raw data QC", subtitle = p0_subtitle, x = "QC parameters")
savePlot(filename=default_parametes_output_file, plot=p0, width=1900, height=1100)
  
# Number of CNV calls and PennCNV reported statistics which taken together are indicators of the quality of samples 

p1<-ggplot(data, aes(x = LRR_mean, y = NumCNV)) + 
	geom_point(aes(colour=filter), shape = 16, alpha = 0.6) +
	scale_colour_manual(values = cbPalette) + 
	theme_bw() + 
	theme(legend.position = "none",
	      plot.title = element_textbox(hjust=0.5,
					   width = unit(0.9, "npc"),
					   size = 7),
	      axis.text = element_text(size = 5.5),
	      axis.title=element_text(size=6)) + 
	labs(title = "Mean of Log2 R Ratio",  x = "LRR_mean", y = "NumCNV") 

# Graph CNV calls and the LRR_SD measure to find a good threshold to use for filtering for a particular data set
p2<-ggplot(data, aes(x = LRR_SD, y = NumCNV)) + 
	geom_point(aes(colour=filter), shape = 16, alpha = 0.6) +
	scale_x_continuous(breaks = c(seq(from = 0, to = 1, by = 0.1))) +
	scale_colour_manual(values = cbPalette) +
	theme_bw() + 
	theme(legend.position = "none",
	      plot.title = element_textbox(hjust=0.5,
                                           width = unit(0.9, "npc"),
					   size = 7),
	      axis.text = element_text(size = 5.5),
	      axis.title = element_text(size = 5.5)) + 
	labs(title = "Standard deviation of Log2 R Ratio",  x = "LRR SD", y = "NumCNV")  +
	geom_vline(xintercept = c(0.3), linetype = "dotted") 
  
p3<-ggplot(data, aes(x = WF, y = NumCNV)) + 
	geom_point(aes(colour=filter), shape = 16, alpha = 0.6) +
	scale_x_continuous(breaks = c(seq(from = -0.2, to = 0.1, by = 0.05))) +
	scale_colour_manual(values = cbPalette) + 
	theme_bw() + 
	theme(legend.position = "none", 
	      plot.title = element_textbox(hjust=0.5,
                                           width = unit(0.9, "npc"),
					   size = 7),
	      axis.text = element_text(size = 5.5),
              axis.title = element_text(size = 5.5)) +
	labs(title = "Waviness factor",  x = "WF", y = "NumCNV") +
	geom_vline(xintercept = c(-0.05,0.05), linetype = "dotted") 
    
p4<-ggplot(data, aes(x = BAF_drift, y = NumCNV)) + 
	geom_point(aes(color=filter), shape = 16, alpha = 0.6) +
	scale_x_continuous(breaks = c(seq(from = 0, to = 0.08, by = 0.01))) +
	scale_colour_manual(values = cbPalette, name = "QC") +
	theme_bw() +
        theme(legend.position = "none",
              plot.title = element_textbox(hjust=0.5,
                                           width = unit(0.9, "npc"),
					   size = 7),
              axis.text = element_text(size = 5.5),
              axis.title = element_text(size = 5.5)) +
      	labs(title = "B Allele Frequency drift",  x = "BAF_drift", y = "NumCNV") +
	geom_vline(xintercept = c(0.01), linetype = "dotted") 

pp1 <- ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2, common.legend=T, legend="bottom")
savePlot(filename=numCNV_output_file,plot=pp1, width=1700, height=1100)

