
# Refer to the Milestone for the source code, here I have modified the data for the App

AppngramTokenizer <- function(theCorpus, ngramCount) {
    ngramFunction <- NGramTokenizer(theCorpus, 
                                    Weka_control(min = ngramCount, max = ngramCount, 
                                                 delimiters = " \\r\\n\\t.,;:\"()?!"))
    ngramFunction <- data.frame(table(ngramFunction))
    ngramFunction <- ngramFunction[order(ngramFunction$Freq, 
                                         decreasing = TRUE),]
    colnames(ngramFunction) <- c("String","Count")
    ngramFunction
}

#Profanity words

profanityfile <- file("http://www.bannedwordlist.com/lists/swearWords.txt", open = "rb")
profanityWords<-readLines(profanityfile, encoding = "UTF-8", warn=TRUE, skipNul=TRUE)
close(profanityfile)
saveRDS(profanityWords, file = "./profanityWords.RDS")
rm(profanityfile)

# Create ngram and save
Appunigram <- AppngramTokenizer(finalCorpusDF, 1)
Appunigram<-cbind(as.data.frame(str_split_fixed(Appunigram$String, fixed(" "), 1)),Appunigram$Count)
colnames(Appunigram)<-c("word1","Freq")
saveRDS(Appunigram, file = "./Appunigram.RDS")

Appbigram <- AppngramTokenizer(finalCorpusDF, 2)
Appbigram<-cbind(as.data.frame(str_split_fixed(Appbigram$String, fixed(" "), 2)),Appbigram$Count)
colnames(Appbigram)<-c("word1","word2","Freq")
saveRDS(Appbigram, file = "./Appbigram.RDS")

Apptrigram <- AppngramTokenizer(finalCorpusDF, 3)
Apptrigram<-cbind(as.data.frame(str_split_fixed(Apptrigram$String, fixed(" "), 3)),Apptrigram$Count)
colnames(Apptrigram)<-c("word1","word2","word3","Freq")
saveRDS(Apptrigram, file = "./Apptrigram.RDS")

Appquadgram <- AppngramTokenizer(finalCorpusDF, 4)
Appquadgram<-cbind(as.data.frame(str_split_fixed(Appquadgram$String, fixed(" "), 4)),Appquadgram$Count)
colnames(Appquadgram)<-c("word1","word2","word3","word4","Freq")
saveRDS(Appquadgram, file = "./Appquadgram.RDS")

Apppentagram <- AppngramTokenizer(finalCorpusDF, 5)
Apppentagram<-cbind(as.data.frame(str_split_fixed(Apppentagram$String, fixed(" "), 5)),Apppentagram$Count)
colnames(Apppentagram)<-c("word1","word2","word3","word4","word5","Freq")
saveRDS(Apppentagram, file = "./Apppentagram.RDS")



