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
tbl <- "stage_uraods.mv_toimenpide"

# Target
tg_tbl <- "synthetic.toimenpide"


N <- 100000

#
# Compute synthetic data
#

stime <- system.time( S <- 
  cbind(rhetu(tbl, "henkilotunnus", N), 
        rfactor(tbl, "tyyppi", N),
        rchar(17, "palvelunumero", N, type="0"),
        rfactor(tbl, "rivi_numero", N, default=0),
        rfactor(tbl, "palvelu_tunnus", N),  
        rfactor(tbl, c("pot_eala_koodi", "pot_eala_selite"), N),
        rfactor(tbl, c("kayntityyppi_koodi", "kayntityyppi_selite"), N),
        rfactor(tbl, c("toimenpide_koodi", "toimenpide_selite"), N),
        rfactor(tbl, "ominaisuus1", N),  
        rfactor(tbl, "ominaisuus2", N),  
        rfactor(tbl, "ominaisuus3", N),
        rfactor(tbl, "kiireellinen", N),
        rdate(tbl, "toimenpide_hetki_pvm", N),
        rfactor(tbl, "toimenpide_hetki_min", N, min_count=NA),
        rfactor(tbl, c("suor_toimipiste_koodi","suor_toimipiste_nimi"), N),
        rfactor(tbl, c("vo_toimipiste_koodi","vo_toimipiste_nimi"), N),
        rtime(tbl, "luontihetki_s", N),
        rfactor(tbl, "toimenpidekok_lkm", N, default=0),
        rfactor(tbl, "lisa_tmp_lkm", N, default=0),
        rfactor(tbl, c("muutos_syy","muutos_selite"), N),
        rtime(tbl, "tapahtuma_aikaleima", N, onlyDates=TRUE )
        ))

print(stime)
cat("\n")

#
# Write data to db
#
write_data()

cat("Done.\n")
