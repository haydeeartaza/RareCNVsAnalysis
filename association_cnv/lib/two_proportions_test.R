## This script run the two proportion test and calculate the OR for the frequency of CNVs in cases vs. controls
#
# Args:
# 1.file containing the number of CNVs in cases and controls 
# 	e.g.
# 	CAT,VALUE
# 	1,2615
# 	2,827
# 	CAT: 1:controls, 2:cases
# 2.Total number of cases
# 3.Total number of controls
# 4.Interval length
# 5.Output file name
#
##

args <- commandArgs(TRUE)
cnv.data <- args[1]
total_cases <- args[2] # cat=2
total_controls <- args[3] # cat=1
length <- args[4] # e.g 50KB, 100KB_200KB
output.file <- args[5]

library(fmsb)


data.in <- read.table(cnv.data,header = TRUE, sep = ',')
data.in <- data.in[order(data.in$CAT, decreasing = T),]
#1,10: controls 10 cnvs
#2,51: cases 51 cnvs

total_cases = as.numeric(total_cases)
total_controls = as.numeric(total_controls)



n1_cases = sum(data.in[grep("^2", data.in$CAT),]$VALUE)
n2_cases = total_cases - n1_cases
n1_controls = sum(data.in[grep("^1", data.in$CAT),]$VALUE)
n2_controls = total_controls - n1_controls

# Proportion test
test <-prop.test(c(n1_cases, n1_controls), n = c(total_cases, total_controls))

# Odds Ratio test
OR <- oddsratio(n1_cases, n2_cases, n1_controls, n2_controls)

OR_conf_inter <- paste(OR$conf.int[1], OR$conf.int[2], sep = ",")

if( (total_cases > n1_cases) & (total_controls > n1_controls) ) { 
	# Proportion test
	test <-prop.test(c(n1_cases, n1_controls), n = c(total_cases, total_controls))

	# Odds Ratio test
	OR <- oddsratio(n1_cases, n2_cases, n1_controls, n2_controls)
	OR_conf_inter <- paste(OR$conf.int[1], OR$conf.int[2], sep = ",")

	data.out<-data.frame("Length" = length, 
                      "Cases" =  n1_cases, 
                      "Controls" =  n1_controls, 
                      "Cases_freq" = test$estimate[[1]], 
                      "Controls_freq" = test$estimate[[2]],
                      "P-value" = test$p.value,
                      "OR" = OR$estimate[1],
                      "95%CI" = OR_conf_inter,
                      "P" = OR$p.value
                      )

}else{
	data.out<-data.frame("Length" = length,
                      "Cases" =  n1_cases,
                      "Controls" =  n1_controls,
                      "Cases_freq" = 0,
                      "Controls_freq" = 0,
                      "P-value" = 0,
                      "OR" = 0,
                      "95%CI" = "0,0",
                      "P" = 0
                      )
}

write.table(data.out, file = output.file, sep = "\t", quote = F, row.names = F)

