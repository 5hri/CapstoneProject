## NGrams created to predict next word


## Function that cleans a phrase (and removes bracketed parts)
CleanPhrase <- function(x) {
  # convert to lowercase
  x <- tolower(x)
  # remove numbers
  x <- gsub("\\S*[0-9]+\\S*", " ", x)
  # change common hyphenated words to non
  x <- gsub("e-mail","email", x)
  # remove any brackets at the ends
  x <- gsub("^[(]|[)]$", " ", x)
  # remove any bracketed parts in the middle
  x <- gsub("[(].*?[)]", " ", x)
  # remove punctuation, except intra-word apostrophe and dash
  x <- gsub("[^[:alnum:][:space:]'-]", " ", x)
  x <- gsub("(\\w['-]\\w)|[[:punct:]]", "\\1", x)
  # compress and trim whitespace
  x <- gsub("\\s+"," ",x)
  x <- gsub("^\\s+|\\s+$", "", x)
  return(x)
}

LastWords<- function(x, n) {
    x <- CleanPhrase(x)
    words <- unlist(strsplit(x, " ")) # split x based on space between words
    len <- length(words)
    tail(words, n=n)
}

## Functions to check n-gram for x. Returns df with cols: [nextword] Maximum Likelihood Estimation[MLE]
GetBiGram <- function(x, Appbigram, getNrows) {  
    words <- LastWords(x, 1)
    match <- subset(Appbigram, word1 == words[1])
    match <- subset(match, select=c(word2, Freq))
    match <- match[order(-match$Freq), ]
    sumfreq <- sum(match$Freq)
    match$Freq <- round(match$Freq / sumfreq * 100)
    colnames(match) <- c("predword","BiMLE")
    if (nrow(match) < getNrows) {
        getNrows <- nrow(match)
    }
    match[1:getNrows, ]
}

GetTriGram <- function(x, Apptrigram, getNrows) {  
    words <- LastWords(x, 2)
    match <- subset(Apptrigram,  word1 == words[1] & word2 == words[2])
    match <- subset(match, select=c(word3, Freq))
    match <- match[order(-match$Freq), ]
    sumfreq <- sum(match$Freq)
    match$Freq <- round(match$Freq / sumfreq * 100)
    colnames(match) <- c("predword","TriMLE")
    if (nrow(match) < getNrows) {
        getNrows <- nrow(match)
    }
    match[1:getNrows, ]
}

GetQuadGram <- function(x, Appquadgram, getNrows) {  
    words <- LastWords(x, 3)
    match <- subset(Appquadgram,  word1 == words[1] & word2 == words[2] & word3 == words[3])
    match <- subset(match, select=c(word4, Freq))
    match <- match[order(-match$Freq), ]
    sumfreq <- sum(match$Freq)
    match$Freq <- round(match$Freq / sumfreq * 100)
    colnames(match) <- c("predword","QuadMLE")
    if (nrow(match) < getNrows) {
        getNrows <- nrow(match)
    }
    match[1:getNrows, ]
}

GetPentaGram <- function(x, Apppentagram, getNrows) {  
    words <- LastWords(x, 4)
    match <- subset(Apppentagram,  word1 == words[1] & word2 == words[2] & word3 == words[3] & word4 == words[4])
    match <- subset(match, select=c(word5, Freq))
    match <- match[order(-match$Freq), ]
    sumfreq <- sum(match$Freq)
    match$Freq <- round(match$Freq / sumfreq * 100)
    colnames(match) <- c("predword","PentaMLE")
    if (nrow(match) < getNrows) {
        getNrows <- nrow(match)
    }
    match[1:getNrows, ]
}


## Function that computes stupid backoff score
SBScore <- function(alpha=0.4, x5, x4, x3, x2) {
  score <- 0
  if (x5 > 0) {
    score <- x5
  } else if (x4 >= 1) {
    score <- x4 * alpha
  } else if (x3 > 0) {
    score <- x3 * alpha * alpha
  } else if (x2 > 0) {
    score <- x2 * alpha * alpha * alpha
  }
  return(round(score,1))
}

## Function that combines the nextword matches into one dataframe
ScoreNgrams <- function(x, nrows=20) {
  # get dfs from parent env
  Pentamatch <- GetPentaGram(x, Apppentagram, nrows)
  Quadmatch <- GetQuadGram(x, Appquadgram, nrows)
  Trimatch <- GetTriGram(x, Apptrigram, nrows)
  Bimatch <- GetBiGram(x, Appbigram, nrows)
  # merge dfs, by outer join (fills zeroes with NAs)
  merge54 <- merge(Pentamatch, Quadmatch, by="predword", all=TRUE)
  merge43 <- merge(merge54, Trimatch, by="predword", all=TRUE)
  merge32 <- merge(merge43, Bimatch, by="predword", all=TRUE)
  df <- subset(merge32, !is.na(predword))  # rm any zero-match results
  if (nrow(df) > 0) {
    df <- df[order(-df$PentaMLE, -df$QuadMLE, -df$TriMLE, -df$BiMLE), ]
    df[is.na(df)] <- 0  # replace all NAs with 0
    # add in scores
    df$score <- mapply(SBScore, alpha=0.4, df$PentaMLE, df$QuadMLE,
                         df$TriMLE, df$BiMLE)
    df <- df[order(-df$score), ]
  }
  return(df)  # dataframe
}

## Stupid backoff algorithm
StupidBackoff <- function(x, alpha=0.4, getNrows=20, showNresults=1,
                          removeProfanity=TRUE) {
  predword <- ""
  if (x == "") {
    return("the")
  }
  df <- ScoreNgrams(x, getNrows)
  if (nrow(df) == 0) {
    return("and")
  }
  df <- df[df$predword != "unk", ]  # remove unk
  if (showNresults > nrow(df)) {
    showNresults <- nrow(df)
  }
  if (showNresults == 1) {
    # check if top overall score is shared by multiple candidates
    topwords <- df[df$score == max(df$score), ]$predword
    # if multiple candidates, randomly select one
    predword <- sample(topwords, 1)
  } else {
    predword <- df$predword[1:showNresults]
  }
  if (removeProfanity) {
    if (predword %in% profanityWords) {
      predword <- "$**$"
    }
  }
  return(predword)
}

