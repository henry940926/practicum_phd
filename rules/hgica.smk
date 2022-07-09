EXTENSIONSP2 = ['psam','pgen','pvar.zst']
HGICA_RAW = 'data/raw/hgica/all'
HGICA_P1 = 'data/interim/hgica/plink/all'
HGICA_RAW_EXT = HGICA_RAW + '.{ext}'
HGICA_P1_EXT = HGICA_P1 + '.{ext}'

# Convert plink2 format to plink

rule plink2_hgica:
    input: expand(HGICA_RAW_EXT, ext = EXTENSIONSP2)
    output: expand(HGICA_P1_EXT, ext = EXTENSIONS)
    params: 
        i = HGICA_RAW,
        o = HGICA_P1
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink2 --pfile {params.i} vzs \
        --max-alleles 2 \
        --make-bed --out {params.o}")


