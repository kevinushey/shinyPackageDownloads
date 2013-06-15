library(Kmisc)
library(data.table)
library(ggplot2)

## get the log files
start <- as.Date('2012-10-01')
today <- as.Date('2013-06-13')

all_days <- seq(start, today, by = 'day')

year <- as.POSIXlt(all_days)$year + 1900
urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')

setwd("data")
for( file in urls ) {
  download.file(file, destfile=gsub(".*/", "", file))
}
setwd("../")

## summarize the files, write to a new file
files <- grep( "gz$", list.files("data", full.names=TRUE), value=TRUE )
pkg_dl_counts <- lapply( files, function(file) {
  system( paste("gunzip -c", file, ">", gsub("\\.gz", "", file)) )
  dat <- fread( gsub( "\\.gz", "", file ) )
  pkg_table <- counts(dat$package)
  pkg_table <- pkg_table[ !is.na( names(pkg_table) ) ]
  out <- data.frame(
    package=names(pkg_table),
    downloads=pkg_table,
    date=gsub( "\\..*", "", gsub(".*/", "", file) ),
    stringsAsFactors=FALSE
  )
  return(out)
})
pkg_dl_counts <- rbindlist(pkg_dl_counts)
write.table(pkg_dl_counts, file="download_counts_by_day.csv",
            row.names=FALSE,
            col.names=TRUE,
            sep="\t",
            quote=FALSE
            )

## read and practice plots
dat <- fread("download_counts_by_day.csv")

## filter to Kmisc
dat_sub <- dat[ dat$package == "Kmisc", ]
date2numeric <- function(date) {
  date_split <- strsplit(date, "-", fixed=TRUE)
  sapply( date_split, function(x) {
    return( 365 * as.numeric( x[[1]] ) + 30 * as.numeric( x[[2]] ) + as.numeric( x[[3]] ) )
  })
}
dat_sub$date2 <- date2numeric( dat_sub$date )
dat_sub$date2 <- as.Date( dat_sub$date, format="%Y-%m-%d" )
ggplot( dat_sub, aes(x=date2, y=downloads)) +
  geom_point() +
  geom_smooth(method="loess") +
  xlab("Date") +
  ylab("Number of Downloads") +
  ggtitle("Package Downloads by Day")