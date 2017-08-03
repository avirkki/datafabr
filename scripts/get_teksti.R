#!/usr/bin/Rscript

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-07-18

require("RPostgreSQL")
require("synergetr")
options("synergetr_sample_max"=1000000)
source("db_operations.R")


# Open posgres connection as 'options("synergetr_con")'
open_con()

# Source
tbl <- "text_mine.teksti"

# Target
tg_tbl <- "synthetic.teksti"

N <- 10000

#
# Compute synthetic data
#

stime <- system.time({ 

  hoitotapahtuma_alkuhetki <- rtime(tbl, "hoitotapahtuma_alkuhetki", N)

  S <- cbind(rhetu(tbl, "henkilotunnus", N), 
             rchar(18, "potilasnumero", N, type="0"),
             rfactor(tbl, "teksti_muoto", N),
             rchar(18, "hoitotapahtuma_numero", N, type="0"),
             rfactor(tbl, "hoitotapahtuma_tunnus", N),
             hoitotapahtuma_alkuhetki,
             hoitotapahtuma_alkuhetki,
             rtime(tbl, "hoitotapahtuma_loppuhetki", N, sparse=TRUE),
             rchar(18, "potilaskertomus_numero", N, type="0A"),
             rfactor(tbl, c("toimipiste_koodi", "toimipiste_nimi",
                            "yksikko_nimi", "nakyma_selite", "tila"), N),
             rchar(18, "teksti_numero", N, type="0A"),
             ccol("text removed", "teksti", N),
             rtime(tbl, "kertomus_paivityshetki_s", N),
             rtime(tbl, "kertomus_paivityshetki_ods", N),
             rtime(tbl, "teksti_paivityshetki_ods", N),
             rtime(tbl, "teksti_aika", N),
             rfactor(tbl, "paivityshetki_mine", N)
             )

  # Simulate missing data
  S$hoitotapahtuma_numero[is.na(S$hoitotapahtuma_tunnus)] <- NA

})

print(stime)
cat("\n")


#
# Write data to db
#
write_data()

cat("Done.\n")
