# GENERAL FUNCTIONS FOR CNVS ANALYSIS

#set -u


# Get CORE CNVs from clean samples in rawcn format
# Args:
# 1.Rawcn file with clean samples (e.g. samplespass.rawcn)
# 2.Mapping file: two columns file original id sample and PennCNV id
# 3.Core file: file including list core samples  
# 4.Core rawcn  dir+file: core rawcn file after QC and merging name + out dir 
#Rscript=$1

function get_qc_core_cnvs_rawcn {
    rawcnfile=$1
    mapfile=$2
    corefile=$3
    corerawcnfile=$4
    
    echo "##### Generating CORE rawcn file.. #####"
    for i in `awk 'BEGIN{OFS=";"} {$1=$1}1' $rawcnfile`; do
        sample=`echo $i | cut -f5 -d';'`
        id=`grep -w $sample $mapfile | cut -f2`
        found=`grep -c -w $id $corefile`
        if [[ $found -gt 0 ]]; then echo $i; fi
     done | tr ";" "\t" > $corerawcnfile
    
     echo "##### Generating Not CORE rawcn file in $corerawcnfile.NOT.CORE.rawcn... #####"
     awk 'BEGIN{OFS=";"} {$1=$1}1' $rawcnfile > temp1.txt
     awk 'BEGIN{OFS=";"} {$1=$1}1' $corerawcnfile > temp2.txt
     rm temp*.txt


}

# Create final core rawcnv file with CNVs biger than x_KB and y_SNPs
# 1.QC core  prefix file: core rawcn file after QC and merging
# 2.final core rawcnv file
# 3.kb: CNV length for filter
# 4.snps: CNV snps for filter
function get_final_core_cnvs_rawcn {
    qccorerawcnfile=$1
    corerawcnfile=$2
    kb=$3
    snps=$4
    
    echo "##### Generating rawcn file with CNVs bigger than $kb Kb and $snps SNPs... #####"
    awk -v KB=$kb -v SNPs=$snps '{sample=$5; sub(/.*\//,"",sample); 
    len=$3; sub(/.*=/,"",len); len=gensub(/,/,"","g",len); len=len/1000;  
    numsnp=$2; sub(/.*=/,"",numsnp); numsnp=numsnp*1; 
    if(numsnp>SNPs) if(len>KB) print $0}' $qccorerawcnfile > $corerawcnfile
}    


# Create summary file with CNVs organized by length (exclusive intervals), deletions and duplications,
# including the two proportion test and OR test
# Include a forest plot for OR distribution
# Args:
# 1.Input path
# 2.frequency prefix file (e.g. *.cnv)
# 3.Output path
# 4.Intervals size e.g (50 100 200 500 1000 1000000)
# 5.Num cases
# 6.Num controls
# 7.Graphic path
function create_summary_by_cnvs_lengths_exclusive {
    inpathfileprefix=`echo $1"/"$2`
    limits=( $4 ) 
    length=$((${#limits[@]} - 1));
    for((start=0; start<$length; start++)); do
         end=$(($start + 1))
         I1=${limits[$start]}; I2=${limits[($end)]}
         interval=$I1"KB_"$I2"KB"
         if [[ $end -eq ${#limits[@]} ]]; then I2=1000000; interval=echo $I1"KB"; fi
         outfile=$3"/"$2"_"$interval"_statistics.csv";
         echo "##### Processing CNVs > $interval in $outfile #####";
         for i in `awk 'BEGIN{OFS=","}{if($0!~/FID/) print $1,$2,$3,$4,$5,$6,$7,$8}' $inpathfileprefix.cnv` ; do
              sample=`echo $i | cut -f2 -d','`;
              cat=`grep -w "$sample" $inpathfileprefix.fam | awk '{print $6}'`;
              echo -e "$i,$cat";
          done | awk -v start=$I1 -v end=$I2 'BEGIN{FS=",";}{if($5-$4>start*1000 && $5-$4<=end*1000) a[$9]++ }
                  END{print "CAT,VALUE";
                  for(i in a ){
                     if (a[i] == null) a[i]=0; print i","a[i];}
                  }' > $outfile
    done

    outfile=$3"/"$2"_summary_statistics.csv"
    if [[ -f $outfile ]]; then rm $outfile; fi
    for((start=0; start<$length; start++)); do
        end=$(($start + 1))
        I1=${limits[$start]}; I2=${limits[($end)]}
        interval=$I1"KB_"$I2"KB"
        echo "##### Processing summary CNVs > $interval in $outfile #####";
        if [[ $end -eq ${#limits[@]} ]]; then I2=1000000; interval=echo $I1"KB"; fi
        ${Rscript} $libdir/two_proportions_test.R \
                 $3"/"$2"_"$interval"_statistics.csv" \
                 $5 \
                 $6 \
                 $interval \
                 temp.csv
        if [[ ! -f $outfile ]]; then  cat temp.csv > $outfile
        else awk 'NR>1' temp.csv >> $outfile; fi
    done
 
    # Plot OR distribution
    echo "##### Generating forest plots... #####"
    cut -f1,6-10  $outfile | sed 's/X95.CI/X95.CI.lower\tX95.CI.upper/' | sed 's/,/\t/' > temp
    ${Rscript} $libdir/plot_forest_OR.R \
        temp \
        $7"/"$2"_forest_OR.png"
  
    rm temp*
  
}



# Create summary file with CNVs deletions and duplications overall
# including the two proportion test and OR test
# Args:
# 1.Input path
# 2.Frequency prefix file (e.g. *.cnv)
# 3.Output path
# 4.Num cases
# 5.Num controls
function create_summary_by_cnvs_overall_exclusive {
    inpathfileprefix=`echo $1"/"$2`
    outfile=$3"/"$2"_ALL_statistics.csv";
    echo "##### Processing CNVs  in $outfile #####";
    for i in `awk 'BEGIN{OFS=","}{if($0!~/FID/) print $1,$2,$3,$4,$5,$6,$7,$8}' $inpathfileprefix.cnv` ; do
        sample=`echo $i | cut -f2 -d','`;
        cat=`grep -w "$sample" $inpathfileprefix.fam | awk '{print $6}'`;
        echo -e "$i,$cat";
    done | awk 'BEGIN{FS=",";}{ a[$9]++ }
            END{print "CAT,VALUE";
                   for(i in a ){
                       if (a[i] == null) a[i]=0; print i","a[i];}
            }' > $outfile
    
    outfile=$3"/"$2"_ALL_summary_statistics.csv"
    echo "##### Processing CNVs in $outfile #####";
    Rscript $libdir/two_proportions_test.R \
        $3"/"$2"_ALL_statistics.csv" \
        $4 \
        $5 \
        "ALL" \
        temp.csv
        if [[ ! -f $outfile ]]; then  cat temp.csv > $outfile
        else awk 'NR>1' temp.csv >> $outfile; fi
        rm temp.csv

}            

# Create cnv plink file from rawcn PennCNV file
# Args:
# 1.rawcn file: from PennCNV
# 2.prefix: ouputfile prefix
# 3.ouputdir 
function create_cnv_file {
    rawcnfile=$1
    prefix=$2
    outputdir=$3
    cnvfile=$outputdir/$prefix.cnv;
	
    echo "##### Creating cnv file... #####"
    echo -e "FID\tIID\tCHR\tBP1\tBP2\tTYPE\tSCORE\tSITES" > $cnvfile
    awk '{chr=$1; start=$1; end=$1; type=$4; probes=$2; score=$8; gsub(/:.*/,"",chr); gsub(/chr/,"",chr); gsub(/.*:/,"",start); \
    gsub(/-.*/,"",start); gsub(/.*-/,"",end); gsub(/.*=/,"",type); gsub(/.*=/,"",score); gsub(/.*=/,"",probes); \
    print $5"\t"$5"\t"chr"\t"start"\t"end"\t"type"\t"score"\t"probes}' $rawcnfile >> $cnvfile

}

# Create fam  plink file from rawcn PennCNV file
# Args:
# 1.rawcn file: from PennCNV
# 2.mapping file: two columns file original id sample and PennCNV id
# 3.pheno file: file with case/control and sex info and other pheno info (cat: column 3 and sex: column 7). 
# 4.prefix
# 5.ouputdir
function create_fam_file {
    rawcnfile=$1
    mappingfile=$2
    phenofile=$3
    prefix=$4
    outputdir=$5
    famfile=$outputdir/$prefix.fam;

    echo "##### Creating fam file... #####"
    for i in `awk '{print $5}' $rawcnfile  | sort -u`; do 
        sample=`grep -w $i $mappingfile | cut -f2`; 
        data=`grep -w $sample $phenofile | cut -f3,7 | tr "\t" ","`; 
        cat=`echo $data | cut -f1 -d','`;
        sex=`echo $data | cut -f2 -d','`;   
        echo -e "$i\t$i\t0\t0\t$sex\t$cat";
    done | sed 's/NA/0/g' > $famfile
}


# Create map plink file from cnv file
# Args:
# 1.cnv file
# 2.prefix 
# 3.ouputdir
function create_map_file {
    cnvfile=$1
    prefix=$2
    outputdir=$3
    echo "##### Generating map file.. #####"
    $plink \
        --cnv-list $cnvfile \
        --cnv-make-map \
        --out $outputdir/$prefix \
        --noweb
}

# Create cnv, fam, map plink files from rawcn PennCNV file 
# Args:
# 1.rawcn file: from PennCNV
# 2.mapping file: two columns file original id sample and PennCNV id
# 3.pheno file: file with case/control and sex info 
# 4.prefix: ouputfile prefix
# 5.ouputdir
function create_cnv_fam_map {
    rawcnfile=$1
    mappingfile=$2
    phenofile=$3
    prefix=$4
    outputdir=$5
    cnvfile=$outputdir/$prefix.cnv; 
    famfile=$outputdir/$prefix.fam; 
   
    #Create CNV file from rawcn file
    create_cnv_file \
        $rawcnfile \
        $prefix \
        $outputdir
        
    #Create FAM file
    create_fam_file \
        $rawcnfile \
        $mappingfile \
        $phenofile \
        $prefix \
        $outputdir
    
    #Generate MAP file
    create_map_file \
        $cnvfile \
        $prefix \
        $outputdir

}

# Create CNVs frequency plot 
# Args:
# 1.Cnv file with frequency info
# 2.Output file prefix
# 3.Population: total population to calculate % frequency 
# 4.Forplotsdir: output dir for *.tsv files
# 5.Graphicsdir: dir for plots 
function plot_frequency_distribution {
    rarecnvsallfrqfile=$1
    prefix=$2
    population=$3
    forplotsdir=$4
    graphicsdir=$5


   # Extract CNVR with specific frequency: 17_53038201_53137427_1 (chr_bp1_bp2_freq), then calculate how many regions are in this frequency
   awk -v pop=$population '{if($0!~/FID/) a[$3"_"$4"_"$5"_"$NF]++} \
	   END{print "CNVR_FREQ_COUNTS\tTOTAL_CNVR_IN_FREQ\tFREQ_IN_POP"; for(i in a) b[a[i]]++; for(i in b) {freq=(i/pop); print i"\t"b[i]"\t"freq} }' \
	   $rarecnvsallfrqfile > $forplotsdir/CNVs_frequencies_$prefix.tsv
     
    ${Rscript} $libdir/plot_frequency_distribution.R \
           $forplotsdir/CNVs_frequencies_$prefix.tsv \
           $graphicsdir/CNVs_frequencies_$prefix.png

}

# Create sample vs. CNVs distribution plot 
# Args:
# 1.cnv.indv file with frequency info
# 2.Output file prefix
# 3.Intervals size e.g (50 100 200 500 1000 1000000)
# 4.Cases: total cases
# 5.Controls: total controls
# 6.Forplotsdir: output dir for *.tsv files
# 7.Graphicsdir: dir for plots 
function plot_samples_distribution {
    rarecnvsindvfile=$1
    prefix=$2
    cases=$4
    controls=$5
    forplotsdir=$6
    graphicsdir=$7

    # Ratio of samples with X CNVs in cases and controls. Ratio=(Num_samples)/(Total_cases|Total_controls) 
    # a[$3][$4]=a[case|control][num_CNVs]
    echo -e "CLASS\tNUM_SAMPLES\tRATIO_SAMPLES\tNUM_CNVS" > $forplotsdir/numCNVs_by_numIndividual_$prefix.tsv
    awk -v cses=$cases -v ctrls=$controls '{if(NR>1 && $NF!=0) a[$3][$4]++}END{for(i in a){ if(i==1) n=ctrls; else n=cses; for(j in a[i]) print i"\t"a[i][j]"\t"a[i][j]/n"\t"j }}' \
    $rarecnvsindvfile >>  $forplotsdir/numCNVs_by_numIndividual_$prefix.tsv


    limits=($3)
    echo -e "INTERVAL\tCLASS\tNUM_SAMPLES\tRATIO_SAMPLES" > $forplotsdir/Individuals_per_CNVs_Interval_Average_length_$prefix.tsv
    #a[$3]: a[case|control]++ counts how many samples (in cases or controls) have CNVs with average length in each interval.
    #$NF contains the average length of CNVs per individual
    length=$((${#limits[@]} - 1));
    for((start=0; start<$length; start++)); do
        end=$(($start + 1))
        I1=${limits[$start]}; I2=${limits[($end)]}
        interval=$I1"KB_"$I2"KB"
        if [[ $end -eq ${#limits[@]} ]]; then I2=1000000; interval=echo $I1"KB"; fi
        awk -v inte=$interval -v cses=$cases -v ctrls=$controls -v kb1=$I1 -v kb2=$I2 '{if( $NF>kb1 && $NF<=kb2) a[$3]++} \
            END{for(i in a){ if(i==1) n=ctrls; else n=cses; print inte"\t"i"\t"a[i]"\t"a[i]/n} }' $rarecnvsindvfile
    done >> $forplotsdir/Individuals_per_CNVs_Interval_Average_length_$prefix.tsv 

    ${Rscript} $libdir/plot_samples_distribution.R \
        $forplotsdir/numCNVs_by_numIndividual_$prefix.tsv \
        $graphicsdir/numCNVs_by_numIndividual_$prefix.png \
        $forplotsdir/Individuals_per_CNVs_Interval_Average_length_$prefix.tsv \
        $graphicsdir/Individuals_per_CNVs_Interval_Average_length_$prefix.png


}
