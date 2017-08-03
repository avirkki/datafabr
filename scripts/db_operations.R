
# Common functions for all get scripts

# Author(s)  : Arho Virkki
# Copyright  : TUH Centre for Clinical Informatics
# Date       : 2017-05-31



# Open posgres connection as 'synergetr_con'
open_con <- function() {
  if( is.null(unlist(options("synergetr_con"))) ) { local({
    pgpass <- readLines("~/.pgpass")
    creds <- strsplit(pgpass[grep("synth_data", pgpass)], ":")[[1]]
    drv <- dbDriver("PostgreSQL")
    options("synergetr_con"=dbConnect(drv, host=creds[1], dbname="ktp",
                                      user=creds[4], password=creds[5])) })}
}

write_data <- function() {
  cat("Creating table", tg_tbl, "\n")
  sql <- paste("CREATE TABLE IF NOT EXISTS", tg_tbl, "( LIKE ", tbl, ")")
  res <- dbGetQuery(options("synergetr_con")[[1]], sql)
  res <- dbGetQuery(options("synergetr_con")[[1]], paste("TRUNCATE", tg_tbl))
  cat("Writing data to", tg_tbl, "\n")
  res <- dbWriteTable(options("synergetr_con")[[1]], 
                      name=strsplit(tg_tbl,".",fixed=TRUE)[[1]], 
                      S, append=TRUE, row.names=FALSE)
}
