#!/usr/bin/Rscript

# Generate an Excel file containing synthetic patient data from TYKS.
# The SQL calls are PostgreSQL-specific.

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-08-02

library("RPostgreSQL")
library("openxlsx")

NROWS <- 400
XLSXFILE <- "data/vsshp_synteettinen_raakadata.xlsx"


# Open PosgreSQL connection as 'pg_con' (when run at TYKS analysis
# environment)

if( !exists("pg_con") ) { local({
  pgpass <- readLines("~/.pgpass")
  creds <- strsplit(pgpass[grep("synth_data", pgpass)], ":")[[1]]
  drv <- dbDriver("PostgreSQL")
  pg_con <<- dbConnect(drv, host=creds[1], dbname="ktp",
                          user=creds[4], password=creds[5]) })}


# List all available synthetic tables

sql <- "SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'synthetic'"

tblnames <- dbGetQuery(pg_con, sql)$table_name

cat("Reading data...\n")

sdata <- list()
for( tbl in tblnames ) {
  sql <- paste0("SELECT * FROM synthetic.", tbl, " LIMIT ", NROWS)
  cat(sql, "\n")

  sdata[[tbl]] <- as.data.frame(dbGetQuery(pg_con, sql))
}

cat("Writing", XLSXFILE, "...\n")
write.xlsx(sdata, file=XLSXFILE)
cat("Done.\n")
