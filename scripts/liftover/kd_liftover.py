# %%
import pandas as pd

data = pd.read_table('data/raw/kd_clive/summarystats/GCST90013537_buildGRCh37.tsv')
fail = pd.read_csv('data/raw/kd_clive/summarystats/failed1.txt',header=None)
# data = pd.read_table('../data/raw/cf/summarystats/gwas.public.txt')

#fail.filter()
# data.head()
data = data.rename({'chromosome':'CHR','base_pair_location':'BP'},axis = 1)

# %%
data=data.assign(test = lambda x: 'chr'+x.CHR.astype(str) + ':'+ x.BP.astype(str)+ '-'+ x.BP.astype(str))
data.head()

# %%
import numpy as np
failed = fail.iloc[:,0].to_numpy()
a = failed[failed!= '#Deleted in new']
# failed = failed.extract(failed != '#Deleted in new')
# failed
# a = a.astype(str)
#a = np.array(['a','b'])
a.dtype
data.shape[0]

data2 = data[~data.test.isin(a)]
data2.shape[0]
lift = data2['test']



# %%
data2.to_csv('data/raw/kd_clive/summarystats/summary.csv', index = False)
lift.to_csv('data/raw/kd_clive/summarystats/lift2.txt', index = False,header=False)

# %%



