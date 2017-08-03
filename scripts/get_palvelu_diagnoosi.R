#!/usr/bin/Rscript

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-07-17

require("RPostgreSQL")
require("synergetr")
options("synergetr_sample_max"=1000000)
source("db_operations.R")

# Open posgres connection as 'options("synergetr_con")'
open_con()

# Source
tbl <- "stage_uraods.mv_palvelu_diagnoosi"

# Target
tg_tbl <- "synthetic.palvelu_diagnoosi"

N <- 10000

#
# Compute synthetic data
#

stime <- system.time({ 

  # doctor's name and number should match code
  hoi_laakari_koodi <- rcode(1000, "hoi_laakari_koodi", N, type="A")

  S <- cbind(rhetu(tbl, "henkilotunnus", N), 
             rchar(18, "potilasnumero", N, type="0"), 
             rchar(18, "palvelu_numero", N, type="0"), 
             rchar(18, "varaus_numero", N, type="0"),                # 1
             rdate(tbl, "varaushetki_pvm", N),                       # 1
             rfactor(tbl, c("kayntityyppi_selite",
                            "kayntityyppi_tarkenne_selite"), N),
             rtime(tbl, "alkuhetki_pvm", N, onlyDates=TRUE),
             rchar(tbl, "alkuhetki_min", N, type="m"),
             rtime(tbl, "loppuhetki_pvm", N, onlyDates=TRUE),        # 2
             rchar(tbl, "loppuhetki_min", N, type="m"),              # 2
             rfactor(tbl, c("vo_toimipiste_koodi", "vo_toimipiste_koodi", 
                            "yksikko_nimi", "kustannuspaikka"), N),
             hoi_laakari_koodi,                                      # 3
             rcode(along=hoi_laakari_koodi,                          # 3
                   cols="hoi_laakari_nimi", size=N, slength=20, type="Aa"),
             rcode(along=hoi_laakari_koodi,                          # 3 
                   cols="hoi_laakari_yksilointitunnus", size=N, slength=6,
                   type="0"),
             rfactor(tbl, c("pot_eala_koodi", "pot_eala_selite", 
                            "res_koodi", "res_selite"), N),
             rchar(18, "siirto_palvelulta", N, type="0"),            # 4
             rchar(18, "hoiko_numero", N, type="0"),
             rfactor(tbl, c("tulotapa_selite", "mista_tuli_selite",
                            "jatkoh_laitos_nimi", "siirto_pkl_os",
                            "siirto_os_os", "siirto_osastolle",
                            "jh_selite", "laitossiirto",
                            "jatkoh_toimipiste_nimi",
                            "palvelumuoto"), N),
             data.frame("view_refreshed"=rep(Sys.time(),N)),
             rchar(18,"dgn_numero",N, type="0"),                     # 5
             rfactor(tbl, c("dg_syy_koodi", "dg_syy_selite",
                            "dg_oire_koodi", "dg_oire_selite",
                            "paadgn", "tarkenne1", "tarkenne2"), N),
             rtime(tbl, "diagnoosi_luontihetki_s", N),               # 5
             rdate(tbl, "hoiko_alkupvm", N),
             rdate(tbl, "hoiko_loppupvm", N),                        # 6
             rfactor(tbl, "hoiko_alkamissyy_selite", N),
             rtime(tbl, "tapahtuma_aikaleima", N)                    # 5
             )

  # Simulate missing data for categores {1..6}

  varaus_na <- rmissing(tbl, "varaus_numero", N)
  S$varaus_numero[varaus_na] <- NA
  S$varaushetki_pvm[varaus_na] <- NA

  loppuhetki_na <- rmissing(tbl, "loppuhetki_pvm", N)
  S$loppuhetki_pvm[loppuhetki_na] <- NA
  S$loppuhetki_min[loppuhetki_na] <- NA
 
  laakari_na <- rmissing(tbl,"hoi_laakari_koodi", N)
  S$hoi_laakari_koodi[laakari_na] <- NA
  S$hoi_laakari_nimi[laakari_na] <- NA
  S$hoi_laakari_yksilointitunnus[laakari_na] <- NA

  S$siirto_palvelulta[rmissing(tbl, "siirto_palvelulta",N)] <- NA
  
  dianoosiaika_na <- rmissing(tbl, "diagnoosi_luontihetki_s", N)
  S$dgn_numero[dianoosiaika_na] <- NA
  S$diagnoosi_luontihetki_s[dianoosiaika_na] <- NA
  S$tapahtuma_aikaleima[dianoosiaika_na] <- NA

})

print(stime)
cat("\n")

#
# Write data to db
#
write_data()

cat("Done.\n")
