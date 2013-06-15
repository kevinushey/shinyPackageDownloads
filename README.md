R Shiny Package Download Visualizations
======

This is a simple R Shiny application for visualization of CRAN package downloads,
as parsed from the [RStudio CRAN logs](http://cran-logs.rstudio.com/).

All data is pre-processed such that we only retain the number of downloads
per day for each package, to keep the data size down. A more full-fledged app
could interact with the entirety of the logs in a more feature-filled way.

Clone this repository and run the application with

    R -e "shiny::runApp('shinyPackageDownloads')"
    