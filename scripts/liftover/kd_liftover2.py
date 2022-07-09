
import pandas as pd
import numpy as np

# Load data

df = pd.read_csv('data/raw/kd_clive/summarystats/liftover/summary.csv')
lift = pd.read_csv('data/raw/kd_clive/summarystats/liftover/ucsclo2.bed', names=['hg38'])
print(df.shape)
print(lift.shape)
print(df.loc[[2871548]])
print(lift.loc[[2871548]])

print(lift.head())

# cbind with the new
df_out = df.reset_index(drop=True).join(lift)
print(df_out.loc[[2871548]])

print(df_out.shape)



kwargs = {
    'beta.khor' : lambda x: np.log(x['or.khor']),
    'SNP' : lambda x: x['#CHR'].astype(str) + '_' + x['POS'].astype(str) + 
     '_'+ x['effect_allele'].astype(str) + '_' + x['other_allele'].astype(str)
}

re1 = {
    0: '#CHR',
    1: 'POS',
    2: 'POS2'
}

chr1 = {
    '#CHR' : lambda x: x['#CHR'].str.lstrip('chr')
}

df_out = (df_out.hg38.str.split(':|-',expand = True)
                .rename(re1,axis=1)
                .assign(**chr1)
                .join(df_out, how = 'outer')
                .assign(**kwargs)
                .filter(['#CHR','POS',
                'other_allele','effect_allele',
                'SNP', 'p.khor','beta.khor'])
                )
print(df_out.shape)
print(df_out.head())
print(df_out.loc[[2871548]])

# rename

col_rename = {
    #'CHR' : '#CHR',
    #'BP' : 'POS',
    'other_allele':'REF',
    'effect_allele':'ALT',
    'beta.khor':'all_inv_var_meta_beta',
    'p.khor' : 'all_inv_var_meta_p'

}

df_out = df_out.rename(col_rename, axis = 1)


df_out.to_csv('data/raw/kd_clive/summarystats/summary_hg38.txt', sep = '\t',index = False)
