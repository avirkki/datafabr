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
tbl <- "stage_dw.mv_radu_vsshp"

# Target
tg_tbl <- "synthetic.radu_vsshp"

N <- 10000

#
# Compute synthetic data
#

stime <- system.time({ 

  tutkimushetki <- rtime(tbl, "tutkimushetki", N)

  S <- cbind(rhetu(tbl, "henkilotunnus", N), 
             rchar(8,"radulahete_id", N, type="0"),
             rchar(8,"radututkimus_id", N, type="0"),
             rfactor(tbl, c("tehty_tutkimus_koodi", "tehty_tutkimus_selite",
                            "tutkimuksen_tyyppi", "tutkimusryhman_selite"), N),
             tutkimushetki,
             rfactor(tbl, "onko_paivystys", N),
             rfactor(tbl, "tutkimuksen_hinta", N),
             rtime(tbl, "lahetehetki", N),
             rtime(tbl, "ajanvaraushetki", N, sparse=TRUE),
             rfactor(tbl, c("tilaava_yksikko", "hoitava_yksikko",
                            "ulkopuolinen_tutkimus", "suorittava_toimipiste"),
                     N),
             rfactor(tbl, "potilaan_kotikunta", N),
             rchar(8,"lausunto_idt", N, type="0"),
             rchar(8,"tutkimuksen_ac_numero", N, type="0"),
             rchar(8,"dw_radututkimus_id", N, type="0"),
             rtime(tbl, "dw_tutkimus_paivityshetki", N),
             rtime(tbl, "dw_lahete_paivityshetki", N),
             rtime(tbl, "paivityshetki_stage", N),
             tutkimushetki
             )
})

print(stime)
cat("\n")

#
# Write data to db
#
write_data()

cat("Done.\n")
