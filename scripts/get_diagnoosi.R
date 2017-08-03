#!/usr/bin/Rscript

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-07-18

require("RPostgreSQL")
require("synergetr")
options("synergetr_sample_max"=1000000)
source("db_operations.R")

# Open posgres connection
open_con()

# Source
tbl <- "stage_uraods.mv_diagnoosi"

# Target
tg_tbl <- "synthetic.diagnoosi"

N <- 10000

#
# Compute synthetic data
#

stime <- system.time({ 

  S <- cbind(rhetu(tbl, "henkilotunnus", N), 
             rtime(tbl, "dgn_pvm", N),
             rfactor(tbl, "ika", N),
             rchar(18,"palvelu_numero", N, type="0"),
             rchar(18,"dgn_numero", N, type="0"),
             rfactor(tbl, c("diagnoosi", "on_syy", "on_tapahtuma_dgn", "selite",
                            "paadgn", "tarkenne1", "tarkenne2"), N),
             rfactor(tbl, c("vo_toimipiste_koodi", "yksikko_nimi", 
                            "tulosyksikko_selite", "vastuualue", 
                            "pot_eala_koodi", "pot_eala_selite"), N),
             rtime(tbl, "tapahtuma_aikaleima", N)
             )
})

print(stime)
cat("\n")


#
# Write data to db
#
write_data()

cat("Done.\n")
