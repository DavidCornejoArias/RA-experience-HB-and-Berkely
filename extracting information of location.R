# setting the packages
library(readxl) 
library(tidyverse)
library(stringr)
library(tm)
library(dplyr)
library(openxlsx)
library(readxl) 
rm(list = ls())

# change
root <- "C:/Users/david/Dropbox/RA application\Harvard & Berkely/05_database" 
out <- "C:/Users/david/Dropbox/RA application\Harvard & Berkely/05_database"
#
setwd(root)
DB<- read.xlsx("cleanPNCDataBase.xlsx")
#DB2<- read.csv(file="joined with municipios and cantones.csv", header=TRUE, sep=",")
# cleaning and preparing the dataset

#DB$address2<- iconv(DB$clean_address, from = "UTF-8", to = "ASCII//TRANSLIT")
DB$address2 <- str_squish(tolower(removeWords(tolower(DB$address), words = stopwords("spanish"))))
head(DB)
cm <- c("san", "santo", "santa")
DB$address2 <- removeWords(tolower(DB$address2), words = cm)
DB$address2 <- gsub("\"", ' ', DB$address2)
DB$address2 <- str_squish(DB$address2)
# taking away the words to look for'
DB$locations<-str_extract_all(DB$address2,"\\b((canton|colonia|barrio|caserio|comunidad|lotificacion|urbanizacion)\\b (((.+?) (.+?) (.+?)( |\\b))|((.+?) (.+?)( |\\b))|((.+?)( |\\b))))")
DB$locations <-  gsub("[[:digit:]]", "", DB$locations)

# eliminar puntuación
DB$locations <-  gsub("[[:punct:]]", "", DB$locations)
#
DB$locations <- trimws(DB$locations)
DB$address2 <- trimws(DB$address2)
# trying the model

setwd(out)
write.xlsx(DB, 'dataBaseExtractedAddress.xlsx')