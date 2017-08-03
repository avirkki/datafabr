#!/usr/bin/Rscript

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-05-31

require("RPostgreSQL")
require("synergetr")
options("synergetr_sample_max"=1000000)
source("db_operations.R")

# Open posgres connection as 'options("synergetr_con")'
open_con()

# Source
tbl <- "stage_dw.mv_opera_leikkaus_toimenpide"

# Target
tg_tbl <- "synthetic.opera_leikkaus_toimenpide"

N <- 10000

#
# Compute synthetic data
#

stime <- system.time({ S <- 
  cbind(rhetu(tbl, "henkilotunnus", N), 
        rfactor(tbl, c("pk_dmf_leikkaus","leikkaus_tmp_act_id"), N),
        rdate(tbl, "hoitopaatospvm", N),
        rdate(tbl, "varaus_pvm", N),
        rdate(tbl, "suunniteltu_pvm", N),
        rdate(tbl, "toteutunut_pvm", N),
        rfactor(tbl, c("pituus","paino"), N),
        rfactor(tbl, "asa_luokka", N),
        rfactor(tbl, c("potilaan_erikoisala_koodi",
                       "potilaan_erikoisala_nimi", "hoitava_osasto_koodi",
                       "hoitava_osasto_nimi", "hoitava_laitos_koodi",
                       "hoitava_laitos_nimi", "toimenpideosasto_koodi",
                       "toimenpideosasto_nimi", "lahettava_osasto_koodi",
                       "lahettava_osasto_nimi", "jatkohoito_osasto_koodi",
                       "jatkohoito_osasto_nimi"), N),
        rfactor(tbl, "jonottamisen_syy", N),
        rfactor(tbl, c("leikkaussali_koodi", "leikkaussali_nimi",
                       "anestesiamuotovalue", "lahettavayksikkovalue",
                       "potilasryhmavalue", 
                       "toteutunut_toimenpide_koodi",
                       "toteutunut_toimenpide_nimi", "diagnoosi_koodi",
                       "diagnoosi_nimi", "preopdiagnoosicodein",
                       "preopdiagnoosivalue", "postopdiagnoosicodein",
                       "postopdiagnoosivalue", "puolisuus_koodi",
                       "puolisuus_nimi",  "on_paatoimenpide",
                       "on_anestesiatoimenpide", "on_paivystys",
                       "suunniteltu_toimenpide_koodi",
                       "suunniteltu_toimenpide_nimi"), N,
                min_count=10),
        rpk("pk_dmf_toimenpide",N),
        rpk("toimenpide_act_id",N),
        rtime(tbl, "toimenpide_paivityshetki_stage",N),
        rtime(tbl, "tapahtuma_aikaleima",N)
        )

  # Re-arrange columns
  S <- S[,get_colnames(tbl)]
  })

print(stime)
cat("\n")

#
# Write data to db
#
write_data()                    

cat("Done.\n")
