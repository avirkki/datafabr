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
tbl <- "stage_uraods.mv_laakemaarays"

# Target
tg_tbl <- "synthetic.laakemaarays"

N <- 10000

#
# Compute synthetic data
#

stime <- system.time({ 

  S <- cbind(rhetu(tbl, "henkilotunnus", N),
             rchar(18,"laakemaarays_numero", N, type="0"),
             rfactor(tbl, c("kauppanimi", "vaikuttava_aine",
                            "atc_koodi", "vahvuus", "muoto",
                            "antotapa_koodi", "antotapa_selite",
                            "kotilaake", "n_laake", "antibiootti",
                            "ex_tempore"),N),
             rdate(tbl, "alkuaika_pvm", N),
             rchar(tbl, "alkuaika_min", N, type="m"),
             rdate(tbl, "loppuaika_pvm", N),
             rchar(tbl, "loppuaika_min", N, type="m"),
             rfactor(tbl, c("lopetus_syy_koodi", "lopetus_syy_selite"), N),
             rfactor(tbl, c("poisto_syy_koodi", "poisto_syy_selite"), N),
             rfactor(tbl, c("muutos_syy_koodi", "muutos_syy_selite"), N),
             rfactor(tbl, c("maarayksen_tila_koodi", "maarayksen_tila_selite"), N),
             rfactor(tbl, c("maaraystapa_koodi", "maaraystapa_selite"), N),
             rfactor(tbl, c("annostelu_tyyppi_koodi", "annostelu_tyyppi_selite",
                            "annostelu_profylaksia", "annostelu_lisatieto",
                            "annostelu_eril_ohje", "annostelu_tarv_annos",
                            "annostelu_tarv_pvm_max_annos", "annostelu_annos",
                            "annostelu_annos_yksikko", "annostelu_esilaake",
                            "annostelu_saan_pvm_annos",
                            "annostelu_muuttuva_toistuvuus",
                            "annostelu_muuttuva_ajan_tyyppi"),N),
             rdate(tbl,"annostelu_voimassaolo_pvm", N, sparse=TRUE),
             rfactor(tbl,"annostelu_suun_antoaika", N), 
             rfactor(tbl, "rivi_numero", N),
             ccol(NA, "poisto_aika_pvm", N),
             rchar(2, "poisto_aika_min", N, type="m"),
             rdate(tbl, "kotilaake_arv_alkuaika", N, sparse=TRUE),
             rdate(tbl, "kotilaake_arv_loppuaika", N, sparse=TRUE),
             rtime(tbl, "tapahtuma_aikaleima", N)
             )
  
  # Simulate missing data
  loppuaika_na <- rmissing(tbl, "loppuaika_pvm", N)
  S$loppuaika_pvm[loppuaika_na] <- NA
  S$loppuaika_min[loppuaika_na] <- NA
  
})

print(stime)
cat("\n")


#
# Write data to db
#
write_data()

cat("Done.\n")
