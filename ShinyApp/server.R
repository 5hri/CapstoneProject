# server.R

load("dataset/Appdata.RData", envir=.GlobalEnv)
source("predword.R")

nextw <- function(typetext, language, childmode) {
  if (language == "english") {
    return(StupidBackoff(typetext, removeProfanity=childmode))
  } else if (language == "hindi") {
    return("We read your mind but don't speak HINDI, yet! but soon.." )
  } else if (language == "spanish") {
    return("We read your mind but don't speak SPANISH, yet! but soon..")
  }
}

shinyServer(function(input, output) {

    Textinput <- eventReactive(input$Predict, {
      input$typetext
    })
    
    output$nextword <- renderText({
        result <- nextw(Textinput(), input$language, input$childmode)
        paste0(result)
    })
    
    output$output <- renderText({
      countword <- length(strsplit(input$typetext," ")[[1]])
      countchar <- nchar(input$typetext)
      paste("You wrote", countword, " words and ", countchar, "characters!")
    })
    
    output$output2 <- renderText({
      countword <- length(strsplit(input$typetext2," ")[[1]])
      countchar <- nchar(input$typetext2)
      paste("You wrote", countword, " words and ", countchar, "characters!")
    })
    output$nextword2 <- renderText({
      result <- nextw(input$typetext2, input$language, input$childmode)
      paste0(result)
    })

})
