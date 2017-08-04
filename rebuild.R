#!/usr/bin/Rscript

# Refresh and re-compile an R package given as the first argument

# To install, issue 'install' as a second command line argument. 
# (Run with sudo rights to install the package for all users.)

# Author(s)     : Arho Virkki
# Copyright     : Turku University Hospital
# Original date : 2017-06-05


# Check the first argument
argv <- commandArgs(TRUE)

if( length(argv) == 0 ) {
  cat("# Please give the package name as an argument.\n")
  quit(save="no")
}
package_name <- argv[1]

# Generate the documentation with Roxygen2
library(utils)
library(methods)
library(roxygen2)

# Load data, in case the package has some 
if( dir.exists(paste0(package_name,"/data")) ) {
  dfiles <- list.files(paste0(package_name,"/data"))
  for( d in dfiles ) {
    load(paste0(package_name,"/data/",d))
  }}

# Generate documentation (.Rd files)
roxygenize(package_name)

# Build the package
system(paste("R CMD build", package_name))


if( length(argv) > 1 ) { 
  if( argv[2] == 'install' ) {
    # Install the latest version
    package_file <- sort(list.files(pattern=paste0(package_name,"_")),
                         decreasing=TRUE)[1]

    cat("Installing package:", package_file, "\n")
    system(paste("R CMD INSTALL", package_file))
  }
}
