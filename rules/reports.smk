
rule genome1000report:
    run:
        shell('''Rscript -e "rmarkdown::render('scripts/report/genome1000.Rmd',
    output_file = '../../reports/genome1000.pdf')"''')
        shell('open reports/genome1000.pdf')


rule misc_report:
    run:
        shell('''Rscript -e "rmarkdown::render('scripts/report/misc_report.Rmd',
    output_file = '../../reports/misc_report.pdf')"''')
        shell('open reports/misc_report.pdf')

rule lab:
    run:
        shell('''Rscript -e "rmarkdown::render('scripts/report/labpresentation.Rmd',
    output_file = '../../reports/labpresentation.pdf')"''')
        shell('open reports/labpresentation.pdf')