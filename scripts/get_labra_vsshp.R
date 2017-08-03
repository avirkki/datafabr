#!/usr/bin/Rscript

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-05-31

require("RPostgreSQL")
require("synergetr")
options("synergetr_sample_max"=1000000)
source("db_operations.R")


# Open database connection as 'options("synergetr_con")'
open_con()

# Source
tbl <- "main_dev.mv_labra_vsshp"

# Target
tg_tbl <- "synthetic.labra_vsshp"

N <- 100000

#
# Compute synthetic data
#


compute <- TRUE
if( compute ) {
  stime <- system.time( S <- 
    cbind(rhetu(tbl, "henkilotunnus", N),
          rpk("labra_id", N),
          rchar(9, "tutkimusriviavain", N, type="0Aa"),
          rfactor(tbl, "naytetunnus", N),
          rfactor(tbl, "putkien_lkm", N),
          rtime(tbl, "naytteenotto", N),
          rfactor(tbl, c("paatutkimuspaketti",
                              "tutkimus","tutkimuksen_tyyppi",
                              "tulos_teksti","tuloksen_mittayksikko",
                              "tarkein_mikrobi",
                              "viitearvo_min","viitearvo_max",
                              "viitearvojen_ulkopuolella"), N, 
                       min_count=5),
          rfactor(tbl, c("tilaaja_taso_0", "tilaaja_taso_1",
                              "tilaaja_taso_2", "tilaaja_taso_3"), N,
                       min_count=5),
          rfactor(tbl, c("ulkoinen_asiakas", "kiireellinen_tutkimus",
                              "ulkopuolella_teetetty"), N,
                       min_count=5),
          rfactor(tbl, "projektin_tunnus", N, 
                       min_count=5),
          rfactor(tbl, c("sisainen_kustannus","laskutettu_hinta"), N,
                 default=0, min_count=5),
          rfactor(tbl, c("paivityshetki_main"), N,
                  default="'1970-01-01'", min_count=5),
          rpk("stage_labdw_transform_id", N),
          ccol(NA, "potilas_asia_id", N),
          ccol(NA, "lahde_koodi_id", N),
          ccol(NA, "tiedon_omistaja_koodi_id", N),
          ccol(NA, "tiedon_omistaja", N),
          ccol(NA, "potilas_id", N),
          ccol(TRUE, "vastaus_kuuluu_vsshp", N),
          rtime(tbl, "tapahtuma_aikaleima", N)
          ))

  print(stime)
  cat("\n")
}


#
# Write data to db
#
write_data()

cat("Done.\n")
