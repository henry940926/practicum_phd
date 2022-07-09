import pandas as pd

# read the clinical data
clin = pd.read_excel('data/raw/clinical/seqlist.xlsx')

# read the fam file
fam = pd.read_table('data/raw/misc136/hg38_mis-c_gg136.20220127.fam',
 header = None, sep = ' ', usecols = [0,1], names = ['famid','id'])
# 
clin2 = clin[(clin['MIS-C postive, COVID+'] == 'Y') | (clin['COVID+ (no MIS-C)']=='Y')]

l = clin2['Sample ID']

out = fam[fam['id'].isin(l)]

out.to_csv('data/interim/misc136/ids/covidpos_ids.txt', header = None, sep = '\t',index = False)