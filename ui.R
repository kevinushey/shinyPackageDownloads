library(ggplot2)

weekdays <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

shinyUI( bootstrapPage(
  
  headerPanel("R Package Download Visualization"),
  sidebarPanel(
    
    ## package to visualize
    tags$h2("Package Selection"),
    textInput(inputId = "package_name",
              label="Package to Visualize", 
              value="ggplot2"
    ),
    
    ## filter by day of the week
    tags$h2("Plot Control"),
    checkboxInput(inputId="group_by_day_of_week",
                  label="Group smoothed lines by day of the week?",
                  value=FALSE
    ),
    checkboxGroupInput(inputId="days_of_the_week",
                       label="Days of the week",
                       choices=weekdays,
                       selected=weekdays
    ),
    
    ## smoother settings
    tags$h2("Smoother settings"),
    ## group by day of the week
    checkboxInput(inputId="plot_smoother",
                  label="Plot smoothed fit(s)?",
                  value=TRUE
    ),
    
    conditionalPanel("input.plot_smoother",
                     checkboxInput(inputId="use_smoother_se", label="Plot smoother CI bounds?", value=TRUE),
                     checkboxInput(inputId="use_smoother_span", label="Use custom LOESS span?", value=FALSE),
                     sliderInput(inputId="smoother_span", label="LOESS span",
                                 min=0.10,
                                 max=2,
                                 value=0.75
                     )
    )
    
  ),
  
  mainPanel(
    textOutput("loading"),
    plotOutput("main_plot"),
    tableOutput("summary_stats")
  )
  
))
