#!/usr/bin/Rscript

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-05-31

require("RPostgreSQL")
require("synergetr")
source("db_operations.R") 

# Open the database
open_con()

# Source
tbl <- "stage_uraods.v_asiakas"

# Target
tg_tbl <- "synthetic.asiakas"

N <- 10000

#
# Compute synthetic data
#

stime <- system.time({ 

  # Patient number and birth date are needed multiple times
  pnum <- rchar(18, "potilasnumero", N, type="0")
  bdate <- rdate(tbl, "syntymaaika_pvm", N )

  S <- cbind(rhetu(tbl, "henkilotunnus", N), 
             data.frame("potilasnumero"=pnum[[1]], 
                        "yhd_viite"=pnum[[1]]),
             rfactor(tbl, "sukupuoli_selite", N),
             bdate,             
             rdate(tbl, "kuolinaika_pvm", N, sparse=TRUE),
             rfactor(tbl, "sukunimi", N, min_count=10),
             rchar(5, "etunimi", N, type="A"),
             rfactor(tbl, "jakeluosoite", N, partial=TRUE, nsplits=1),
             rfactor(tbl, "ammatti", N),
             rfactor(tbl, "aidinkieli_selite", N),
             rfactor(tbl, c("pot_kotikunta_selite", "pot_kotikunta_koodi",
                            "vrk_kotikunta_selite", "vrk_kotikunta_koodi",
                            "ominaisuus1"), N),
             data.frame("tapahtuma_aikaleima"=bdate[[1]])
             )
})

print(stime)
cat("\n")


# Write data to db
write_data()

cat("Done.\n")
