MISC136_RAW = 'data/raw/misc136/hg38_mis-c_gg136.20220127'
MISC136_P1 = 'data/interim/misc136/plink/all'
MISC136_RAW_EXT = MISC136_RAW + '.{ext}'
MISC136_P1_EXT = MISC136_P1 + '.{ext}'

# Does nothing at this moment other than copying
# But reserved this space for future
rule process_misc136:
    input: expand(MISC136_RAW_EXT, ext = EXTENSIONS)
    output: expand(MISC136_P1_EXT, ext = EXTENSIONS)
    params: 
        i = MISC136_RAW,
        o = MISC136_P1
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i} \
        --allow-extra-chr \
        --make-bed --out {params.o}")



CPOS_ID = 'data/interim/misc136/ids/covidpos_ids.txt'
MISC_2 = 'data/interim/misc_cpos/plink/all'
MISC_2_EXT = MISC_2 + '.{ext}'

# Filter to covid + only
rule filter_misc136:
    input: 
        plink = expand(MISC136_RAW_EXT, ext = EXTENSIONS),
        ids = CPOS_ID
    output: expand(MISC_2_EXT, ext = EXTENSIONS)
    params: 
        i = MISC136_RAW,
        o = MISC_2
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i} \
        --allow-extra-chr \
        --keep {input.ids} \
        --make-bed --out {params.o}")


# Filter to misc covid + only
MISCPOS_ID = 'data/interim/misc136/ids/miscpos_ids.txt'
MISC_3 = 'data/interim/misc_only/plink/all'
MISC_3_EXT = MISC_3 + '.{ext}'
rule filter_misc_pos:
    input: 
        plink = expand(MISC136_RAW_EXT, ext = EXTENSIONS),
        ids = MISCPOS_ID
    output: expand(MISC_3_EXT, ext = EXTENSIONS)
    params: 
        i = MISC136_RAW,
        o = MISC_3
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i} \
        --allow-extra-chr \
        --keep {input.ids} \
        --make-bed --out {params.o}")