library(shiny)
library(leaflet)
library(RColorBrewer)
library(readxl)

shinyUI(
  navbarPage(
    tags$head(
      HTML(
        "
          <script>
          var socket_timeout_interval
          var n = 0
          $(document).on('shiny:connected', function(event) {
          socket_timeout_interval = setInterval(function(){
          Shiny.onInputChange('count', n++)
          }, 15000)
          });
          $(document).on('shiny:disconnected', function(event) {
          clearInterval(socket_timeout_interval)
          });
          </script>
          "
      )
    ),
    title = "Schull Moorings",
    position= "static-top",
    inverse = T,
    # Tab to display the filters & map
    tabPanel("Map and filters",
             div(class="outer",
                 
             tags$head(
               # Include our custom CSS
               includeCSS("styles.css")
               ),
             
              leafletOutput("map", width = "100%", height = "100%"),
               
              absolutePanel(id = "filters", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                            top = 60, left = "auto", right = 20, bottom = "auto",
                            width = 330, height = "auto",
                            
                            sliderInput("chain_size_range", "Chain size",
                                        0, 50,
                                        value = c(8, 20), step = 1, post = "mm"
                            ),
                            sliderInput("chain_length_range", "Chain length",
                                        0, 100,
                                        value = c(0,20), step = 1, post = "m"
                            ),
                            sliderInput("max_size_range", "Max boat size",
                                        0, 100,
                                        value = c(0,20), step = 1, post = "m"
                            ),
                            sliderInput("last_major_check_range", "Last major check",
                                        as.POSIXct("1900-01-01"), as.POSIXct("2100-01-01"),
                                        value = c(as.POSIXct("1900-01-01"), as.POSIXct("2020-01-01")), timeFormat="%b %Y"
                            ),
                            checkboxInput("unknownChainSize", "Show unknown chain size", TRUE),
                            checkboxInput("unknownChainLength", "Show unknown chain length", TRUE),
                            checkboxInput("unknownMaxBoatSize", "Show unknown max boat length", TRUE),
                            checkboxInput("unknownLastMajorCheck", "Show unknown last major check", TRUE),
                            
                            selectInput("onRequest", "Show on request?", c("No" = 0, "Both" = 1, "Only" = 2)),
                            selectInput("colors", "Color Scheme",
                                        rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                            ),
                            checkboxInput("legend", "Show legend", TRUE)
                          )
             )
           ),
      # Tab to upload the Excel file
      tabPanel("Load Mooring Data", 
               fluidRow(
                 column(width = 6, offset = 0,
                   fileInput('dataFile', 'Choose xlsx file',
                             accept = c(".xlsx")
                 )
                ),
                textOutput("keepAlive")
               ),
             fluidRow(
               column(width = 6, offset = 0,
                 dataTableOutput('parsedData')
               )
             )
      )
  )
)
