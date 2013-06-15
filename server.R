library(ggplot2)
library(xtable)

## TODO: figure out how to scope variables in shiny server

shinyServer(function(input, output) {
  
  ## get the current file data
  dat <- get( load( "download_counts_by_day.Rda" ) )
  
  ## get the current title
  getTitle <- reactive({
    paste("Package Downloads for", input$package_name)
  })
  
  get_data_subset <- function(dat) {
    dat_sub <- dat[ dat$package == input$package_name, ]
    dat_sub <- dat_sub[ dat_sub$day %in% input$days_of_the_week, ]
    return( dat_sub )
  }
  
  output$main_plot <- renderPlot({
    dat_sub <- get_data_subset(dat)
    if( input$group_by_day_of_week ) {
      p <- ggplot( dat_sub, aes(x=Date, y=downloads, colour=factor(day, levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) ) +
        scale_colour_discrete(name="Day of the Week")
    } else {
      p <- ggplot( dat_sub, aes(x=Date, y=downloads) )
    }
    p <- p + 
      geom_point() + 
      xlab("Date") + 
      ylab("Number of Downloads") + 
      ggtitle( getTitle() )
    
    if( input$plot_smoother ) {
      p <- p + stat_smooth(
        method="loess", 
        se=input$use_smoother_se,
        span=ifelse( input$use_smoother_span, input$smoother_span, 0.75 )
      )
    }
    print(p)
  })
  
  output$summary_stats <- renderTable({
    dat_sub <- get_data_subset(dat)
    tmp <- tapply( dat_sub$downloads, format(dat_sub$Date, "%Y-%m"), sum )
    tmp <- data.frame(
      `Date`=names(tmp),
      `Number of Downloads`=tmp,
      stringsAsFactors=FALSE,
      check.names=FALSE
    )
    return( xtable(tmp) )
  })
  
  dls_per_pkg <- sapply( split(dat$downloads, dat$package), sum )
  dls_per_pkg <- data.frame(
    downloads=dls_per_pkg,
    package=names(dls_per_pkg)
  )
  
  output$side_plot <- renderPlot({
    dat_sub <- get_data_subset(dat)
    print( ggplot(dls_per_pkg, aes(x=downloads)) +
      geom_histogram() +
      scale_x_log10() +
      xlab("Number of Downloads") +
      ylab("Count") +
      ggtitle("Number of Downloads per Package") +
      geom_vline(xintercept=sum(dat_sub$downloads), col="red", lty="dashed")
    )
  })
  
})
