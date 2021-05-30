# For this example we used 3 files with data of references search in ScienceDirect, Web of Science and PubMed
# In ScienceDirect and Web of Science we used the option save as BibTex. In PubMed this option is not available, so I saved as csv, or download direct with the pubmedR package.
# the results are mixed, the duplicated entries are removed and a word cloud with the abstracts are constructed.

###################################################
# install.packages("bib2df")

library(bib2df) # This package read BibTex format

# ScienceDirect data
df1 <- bib2df("ScienceDirect.bib") # create a dataframe from bibtex 
head(df1)
str(df1)
df1$AUTHOR<-as.character(df1$AUTHOR) # author variable was a list, if I join with PubMed data, them I need to transform in character
df1<-select(df1, AUTHOR, TITLE, JOURNAL, ISSN, VOLUME,PAGES, YEAR,  DOI, ABSTRACT)

# In Sciencedirect data, the DOI variable begin with https://doi.org/ and the other no, so I removed this part:
library(stringr)
df1$DOI <- stringr::str_replace(df1$DOI, 'https://doi.org/', '')

#################
# Web of Science data
df2 <- bib2df("savedrecs.bib")  
head(df2)
df2$YEAR<-as.numeric(df2$YEAR) # the year was as character, so I need to transform in muneric
df2$AUTHOR<-as.character(df2$AUTHOR) # author variable was a list, if I join with PubMed data, them I need to transform in character

df2<-select(df2, AUTHOR, TITLE, JOURNAL, ISSN, VOLUME,PAGES, YEAR,  DOI, ABSTRACT)

###########################
# read  csv file from pubmed
# in this example, the abstract is not available
# to include the abstract, see the next example
df3<-read.csv("csv-butyrylcho-set.csv", header = T)
head(df3)

library(dplyr)
# select variables and reorder:
df3<-select(df3, Authors, Journal.Book, Title, Publication.Year, DOI)

# Change variables names to match with df1 and df2:
nomes<-c("AUTHOR","JOURNAL", "TITLE", "YEAR","DOI")
colnames(df3)<-nomes

str(df3)
##########################
# pubmed direct access

library(pubmedR)
query <- "butyrylcholinesterase[Title/Abstract] AND english[LA]
AND Journal Article[PT] AND 2000:2020[DP]"
D <- pmApiRequest(query = query, limit = 500, api_key = NULL)
df4 <- pmApi2df(D)

df4<-select(df4, AU, TI, J9, SN, VL,PG, PY,  DI, AB)
nomes2<-c("AUTHOR", "TITLE", "JOURNAL", "ISSN", "VOLUME","PAGES", "YEAR",  "DOI", "ABSTRACT")
colnames(df4)<-nomes2

###########################
# join the 3 files:

res <- dplyr::bind_rows(df1,df2,df4)
##########################

# removing duplicated entries, using DOI variable:

res_sem_dupl<-res %>% distinct(DOI, .keep_all = TRUE)

########################

# order variables by title
dados<-arrange(res_sem_dupl,TITLE)
########################
# save the dataframe
library(openxlsx)

write.xlsx(dados, "results/results.xlsx", sheetName="Plan1", col.names=T, row.names=F,append=F)
########################
# Results analysis

library(tm)
text<-dados$ABSTRACT
docs <- Corpus(VectorSource(text))
docs <- docs %>%
  tm_map(removeNumbers) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace)
docs <- tm_map(docs, content_transformer(tolower))
docs <- tm_map(docs, removeWords, stopwords("english"))

dtm <- TermDocumentMatrix(docs) 
matrix <- as.matrix(dtm) 
words <- sort(rowSums(matrix),decreasing=TRUE) 
df <- data.frame(word = names(words),freq=words)

inspect(dtm)
findFreqTerms(dtm, 30) # find those terms that occur at least 30 times
findAssocs(dtm, "butyrylcholinesterase", 0.5) # find associations

library(wordcloud)
set.seed(1234) # for reproducibility 
wordcloud(words = df$word, freq = df$freq, min.freq = 1,           max.words=200, random.order=FALSE, rot.per=0.35,            colors=brewer.pal(8, "Dark2"))


# or using package worcloud2
library(wordcloud2)

wordcloud2(data=df, size=1.6, color='random-dark')
#######################




