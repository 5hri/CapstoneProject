# ui.R

library(shiny)
library(shinythemes)
source("tabsetPanel2.R")

shinyUI(fluidPage(
  # shinythemes::themeSelector("united","yeti"),

  theme = shinythemes::shinytheme("slate"),

  titlePanel(h1("Mind Reader", align="center"),
             windowTitle = "A coursera capstone project"),
  h3("We read your mind and predict your next word.", align="center"),
  h5("*optimized for mobile/iPad", align="center"),

  hr(),

  fluidRow(

    column(5, offset=3,

        tabsetPanel2(type = "tabs", tabcolors = c("#DC7633","#8E44AD","#117A65"),
          tabPanel("Old-School",
                   
            "Type below and click the button to test if we read your mind all-right:",
            textInput("typetext", label = "", value = ""),
            tags$head(tags$style(type="text/css", "a{color: #17202A;}","#typetext {width: 400px;}")),
            
            fluidRow(
              column(6,
                     p(textOutput("output")),
                     actionButton("Predict", "Read my mind!",icon("paper-plane"), 
                                  style="color: #fff; background-color: #337ab7; border-color: #fff"),
                     br(), br()
              ),
              column(6,
                     h4("Your next word is..."),
                     h2(textOutput("nextword"))
              )
            )

          ),
          tabPanel("Read ASAP",
            "Reads your mind and predict as you type:",
            textInput("typetext2", label = "", value = ""),
            tags$head(tags$style(type="text/css", "#typetext2 {width: 400px;}")),

            fluidRow(
              column(6,
                    p(textOutput("output2")),
                    br(),br(),br()
              ),     
              column(6,
                    h4("Your next word is..."),
                    h2(textOutput("nextword2"))
                    )
            )
          ),
          tabPanel("How to",
                   fluidRow(
                       h4("How to use this app?"),
                       br(),
                       h4("Old-School mode: Type in the box and click 'Read my mind! button."),
                       
                       h4("Read ASAP mode: Just type and your next word predicted in an instant.")
                       
                   )
          )
        )
    )
  ),

  hr(),

  fluidRow(

    column(6,offset=3,
           selectInput("language",
                       label = "What language does your mind speak?",
                       choices = list("English (US)" = "english",
                                      "Hindi" = "hindi",
                                      "Spanish" = "spanish"),
                       selected = "english"),
           checkboxInput("childmode",
                         label = "Child safe mode on (remove swear words, etc.)",
                         value = TRUE),
           br(),
           p("Source Code Link:",
             a("Github", href="https://github.com/5hri/CapstoneProject"),
             align="left")
    )
  )
))
