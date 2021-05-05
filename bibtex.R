# For this example we used 3 files with data of references search in ScienceDirect, Web of Science and PubMed
# In ScienceDirect and Web of Science we used the option save as BibTex. In PubMed this option is not available, so I saved as csv.

# install.packages("bib2df")

library(bib2df) # This package read BibTex format

# ScienceDirect data
df1 <- bib2df("ScienceDirect.bib") # creat a dataframe from bibtex 
head(df1)
str(df1)
df1$AUTHOR<-as.character(df1$AUTHOR) # author variable was a list, if I join with PubMed data, them I need to transform in character

# In Sciencedirect data, the DOI variable begin with https://doi.org/ and the other no, so I removed this part:
library(stringr)
df1$DOI <- stringr::str_replace(df1$DOI, 'https://doi.org/', '')


# Web of Science data
df2 <- bib2df("savedrecs.bib")  
head(df2)
df2$YEAR<-as.numeric(df2$YEAR) # the year was as character, so I need to transform in muneric
df2$AUTHOR<-as.character(df2$AUTHOR) # author variable was a list, if I join with PubMed data, them I need to transform in character


###########################
# read  csv file from pubmed
df3<-read.csv("csv-butyrylcho-set.csv", header = T)
head(df3)

library(dplyr)
# select variables and reorder:
df3<-select(df3, Authors, Journal.Book, Title, Publication.Year, DOI)

# Change variables names to match with df1 and df2:
nomes<-c("AUTHOR","JOURNAL", "TITLE", "YEAR","DOI")
colnames(df3)<-nomes

str(df3)
###########################
# join the 3 files:

res <- dplyr::bind_rows(df1,df2,df3)

##########################

# removing duplicated entries, using DOI variable:

res_sem_dupl<-res %>% distinct(DOI, .keep_all = TRUE)

########################
# select variables
dados<-select(res_sem_dupl, AUTHOR, TITLE, JOURNAL, ISSN, VOLUME,PAGES, YEAR,  DOI)
# order variables by title
dados<-arrange(dados,TITLE)
########################




