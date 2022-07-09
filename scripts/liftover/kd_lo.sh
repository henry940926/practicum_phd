awk 'NR==1 || $1<=22 {print}' GCST90013537_buildGRCh37.tsv > liftover/gwas1_22.txt
cd liftover/
awk 'FNR>1 {print "chr",$1,":",$2,"-",$2}' gwas1_22.txt > Meta_GWAS_To_Lift.txt
sed -i -e 's/ //g' Meta_GWAS_To_Lift.txt