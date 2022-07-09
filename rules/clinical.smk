

CLIN_MERGED = 'data/interim/clinical/merged/data.csv'

CLIN_MISC = 'data/raw/clinical/seqlist.xlsx'
CLIN_GENOME1000 = 'data/raw/genome1000/Subjects.xlsx'
CLIN_HGICA = 'data/raw/hgica/all.cov'
rule merge_clinical:
    input:
        misc1 = CLIN_MISC,
        genome1 = CLIN_GENOME1000,
        hgica1 = CLIN_HGICA
    output:
        CLIN_MERGED
    threads: 4
    resources:
        mem=10
    run:
        shell("Rscript scripts/clinical/merge_clin.R \
        --input-misc {input.misc1} \
        --input-genome {input.genome1} \
        --input-hgica {input.hgica1} \
        --output {output}")




# rule get_cpos_ids:
#     input: 
#         clin = CLIN_MISC,
#         plink = expand(MISC136_RAW_EXT, ext = EXTENSIONS)
#     output: CPOS_ID
#     threads: 2
#     resources:
#         mem=8
#     run:
#         shell("python scripts/filter/filter_cposid.py")
    