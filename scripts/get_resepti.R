#!/usr/bin/Rscript

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-07-18

require("RPostgreSQL")
require("synergetr")
options("synergetr_sample_max"=Inf)
source("db_operations.R")


# Open posgres connection as 'options("synergetr_con")'
open_con()

# Source
tbl <- "stage_uraods.v_resepti"

# Target
tg_tbl <- "synthetic.resepti"

N <- 10000

#
# Compute synthetic data
#

stime <- system.time({ 

  aika_pvm <- rdate(tbl, "aika_pvm", N)

  S <- cbind(rhetu(tbl, "henkilotunnus", N), 
             rchar(18,"resepti_numero", N, type="0"),
             rfactor(tbl, c("atc_koodi", "atc_selite", "laakeaine",
                            "laakeainetyyppi", "kauppanimi"), N),
             aika_pvm,            
             rfactor(tbl,c("annostelu", "annos"), N),
             rfactor(tbl,c( "pakkauskoko_kokonaismaara", "pakkaus_lkm",
                           "kestoaika", "kestoaika_yksikko_selite", "vahvuus",
                           "muoto", "paivittaja_yksikko_nimi"), N),
             aika_pvm
             )
})

print(stime)
cat("\n")


#
# Write data to db
#
write_data()

cat("Done.\n")
