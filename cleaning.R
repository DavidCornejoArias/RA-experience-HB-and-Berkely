######################################################
# cleaning homicides
# author: davidcornejoarias@gmail.com
# last updated: August 28th 2019
#####################################################
# install pacakges 
# install.packages("tidyverse") 
# install.packages("readxl") 
# install.packages("stringr") 
# install.packages("tm") 
# install.packages("openxlsx")
# install.packages("readxl")

library(readxl) 
library(tidyverse)
library(stringr)
library(tm)
library(openxlsx)
library(readxl) 

rm(list = ls())

# importing the data
root <- ""
out <- ""
setwd(root)
DB<- read_excel(".xlsx", sheet = "SheetName")
# creating the doomies
# dummy for genre
DB2 <- mutate(DB,women = ifelse(SEXO=="MUJER",1,0))



#Creating dummies for gans
gan.f = factor(DB2$PANDILLA)
gan_dummies = model.matrix(~gan.f)
DB2<- cbind(DB2,gan_dummies)
DB2<- DB2[-17]

# cleaning the variable description
DB2$address<- iconv(DB2$DIRECCION, from = "UTF-8", to = "ASCII//TRANSLIT")
DB2$address <- str_squish(toupper(removeWords(tolower(DB2$address), words = stopwords("spanish"))))
DB2$address <- gsub("\"", ' ', DB2$address)
DB2$address <- str_squish(DB2$address)
DB2$address <- str_replace_all(DB2$address,"\\bFRENTE.|\\bFRENTE,|\\bFTE A FTE A \\b|\\bFTE. A .\\b|\\bFTE, \\b|\\bFTE. \\b|\\bFTE.A\\b|\\bFTE. DE\\b|\\bFTE. AL\\b|\\bFTE.\\b|\\bFRENTE DEL\\b|\\bFRENTE DE\\b|\\bFRENTE A \\b|\\bFTE \\bAL|\\bFTE. A\\b|\\bFTE A\\b|FTE A\\b|\\bFTE \\b"," FRENTE ")
DB2$address <- str_replace_all(DB2$address,"FRENTE FRENTE A |\\bF\\/"," FRENTE ")
DB2$address <- str_squish(DB2$address)
DB2$address <- str_squish(str_replace_all(DB2$address,"\\bCOL\\b|\\bCOL.\\b|\\bbCol.","COLONIA "))
DB2$address <- str_replace_all(DB2$address,"\\bSTA\\b|\\bSTA.\\b","SANTA")
DB2$address <- str_replace_all(DB2$address,"\\bS/N\\b","SIN NOMBRE")
DB2$address <- str_replace_all(DB2$address,"\\bPTE\\b|\\bPTE.\\b","PONIENTE")
DB2$address <- str_squish(str_replace_all(DB2$address,"\\bAVENIDA\\b|\\bAV.|\\bAV\\b","AVENIDA "))
DB2$address<-str_squish(str_replace_all(DB2$address,"E\\/| \\/|^\\/|^\\/ |^\\/"," ENTRE "))
DB2$address <- str_replace_all(DB2$address,"\\bNOR\\b|\\bNTE\\b","NORTE")
DB2$address <- str_replace_all(DB2$address,"\\bPLP\\b|\\bPP\\b|\\bPPL\\b|\\bPPAL\\b","PRINCIPAL")
DB2$address <- str_replace_all(DB2$address,"\\bU\\/","UNIDAD") #378
DB2$address <- str_squish(str_replace_all(DB2$address,"\\bCTON.|\\bCTN.|\\bHDA.|\\bCTO.|\\bCTN\\b|\\bHDA\\b|\\bCTO\\b|\\bCTON\\b"," CANTON "))
DB2$address <- str_replace_all(DB2$address,"\\bPJE\\b|\\bPJES\\b","PASAJE")
DB2$address<-str_squish(str_replace_all(DB2$address,"J\\/|\\/J"," EN "))
DB2$address <- str_replace_all(DB2$address,"\\bLOTF\\b","LOTIFICACIÓN")
DB2$address <- str_squish(str_replace_all(DB2$address,"\\bINTERIOR RIOR DEL\\b|\\bINTERIOR DE\\b|INTERIORIOR\\b|\\bINTERIOR DEL\\b|\\bINTERIORM\\b|\\bINT. DE\\b|\\bINT.|\\bINT DE\\b|\\bINT\\b","INTERIOR ")) #221
DB2$address <- str_replace_all(DB2$address,"\\bSONSO\\b","SONSONATE")
DB2$address <- str_squish(str_replace_all(DB2$address,"\\bBº\\b|\\bB. |\\bB° |\\bB\\b","BARRIO "))
DB2$address<- str_replace_all(DB2$address,"\\bSN\\b","SAN")
DB2$address<- str_replace_all(DB2$address,"\\bN\\' ","NUMERO ")
DB2$address<- str_replace_all(DB2$address,"\\bOTE\\b","ORIENTE")
DB2$address<- str_replace_all(DB2$address,", DENOMINADO TOMAS REGALADO|PASAJE SIN NOMBRE|LOTE SIN NOMBRE|CASA SIN NOMBRE,|CASA SIN NOMBRE|SE DESCONOCE DIRECCION EXACTA\\'|NO REPORTAN LUGAR DEL HECHO|SOBRE UN CALLEJON, PREDIO VALDIO|EN UNA VEREDA, PREDIO VALDIO|EN UN TERRENO VALDIO|PREDIO VALDIO|EN UN PREDIO VALDIO|TERRENO VALDIO|ALTURA EX CILINEA FERREA|EN UNA CASA SIN NOMBRE|EN UN BASURERO, |NO REPORTA LUGAR DEL HECHO|ORILLA DEL PUENTE CONOCIDO COMO LA GRAMA|PREDIO VALDIO CONTIGUO A CASA 12|LUGAR CONOCIDO COMO PASOS DE LEON, RIO CINCUYO|NO ESPECIFICA LA HORA|CALLE CONOCIDA COMO EL GUIEO|SE DSCONOCE LUGAR DEL HECHO|PROPIEDAD DE LA SRA. ZACAPA|EN UN CALLEJON SIN NOMBRE, PREDIO VALDIO|,  PTO 275 Y 278|CALLE QUE CONDUCE AL CANTON","")
DB2$address<- str_replace_all(DB2$address,", PILA EL MUERTO|NO REPORTA LUGAR EXACTO|CALLE AL CANTON, LUGAR CONOCIDO COMO LAS PLACITAS|CALLE POLVOSA|SIN NOMBRE,|NO SE TIENE DIRECCION EXACTA|, PASAJE SIN NOMBRE|NO SE SABE LUGAR DEL HECHO","")
DB2$address<- str_replace_all(DB2$address,"\\bC. ","CALLE ")
DB2$address<- str_replace_all(DB2$address,"\\bBLV\\b","BULEVAR")
DB2$address<- str_squish(str_replace_all(DB2$address,"\\bC\\/","CARRETERA "))
DB2$address<- str_replace_all(DB2$address,"\\bURB\\b","URBANIZACION")
DB2$address<- str_replace_all(DB2$address,"\\bEDIF\\b","EDIFICIO")
DB2$address<- str_replace_all(DB2$address," \\bX\\b ","POR")
DB2$address<- str_squish(str_replace_all(DB2$address,"\\bPOLG\\b |\\bPGO\\b| \\bPOL\\b "," POLIGONO ")) #211 #217
DB2$address<- str_replace_all(DB2$address,"\\bMK\\b ","KM") #215
DB2$address<- str_replace_all(DB2$address,"\\bLIB\\b ","LIBERTAD")#216
DB2$address<- str_replace_all(DB2$address,"PORC.E.R.","POR CENTRO ESCOLAR REPUBLICA DE ")
DB2$address<- str_replace_all(DB2$address," \\bS\\/"," SUR ") #221
DB2$address<- str_replace_all(DB2$address,"\\bSURPT\\b","SURPONIENTE")
DB2$address<- str_replace_all(DB2$address,"\\bLINMERA\\b","LINEA")
DB2$address<- str_replace_all(DB2$address,"\\bSONSOPOR\\b","SON SONATE POR")#307
DB2$address<- str_replace_all(DB2$address,"\\bFABR\\b","FABRICA") #307
DB2$address<- str_replace_all(DB2$address,"\\bVTE\\b","SAN VICENTE") #309
DB2$address<- str_replace_all(DB2$address,"\\bTONACA\\b","TONACATEPEQUE") #301
DB2$address<- str_replace_all(DB2$address,"\\bHDZ\\b","HERNANDEZ")#311
DB2$address<- str_replace_all(DB2$address,"\\bARTIN\\b","MARTIN")
DB2$address<- str_replace_all(DB2$address,"\\bOPICO\\b","SAN JUAN OPICO")#864
DB2$address<- str_replace_all(DB2$address,"\\bSS\\b","SAN SALVADOR")
DB2$address<- str_replace_all(DB2$address,"\\bSOYA\\b","SOYAPANGO")#351
DB2$address<- str_replace_all(DB2$address,"\\bCARRTEREA\\b","CARRETERA")#351
DB2$address<- str_replace_all(DB2$address,"\\bCARRETERA A.SONSONATE\\b|\\bCARRETERA DE SONSONATE A SAN SALVADOR\\b|\\bCARRETERA DE AHUA A SONSONATE\\b","CA-8")#328
DB2$address<- str_replace_all(DB2$address,"\\bCARRETERA Q DE SANTA ANA CONDUCE A AHUA\\b|CARRETERA DE SANTA ANA A CHALCHUAPA","RN-13")
DB2$address<- str_replace_all(DB2$address,"\\bCARRETERA DE APOPA A QUEZALTE","CARRETERA A NEJAPA")
DB2$address<- str_replace_all(DB2$address,"\\bCARRETERA DE ACAJUTLA A SONSONATE","CARRETERA A ACAJUTLA")
DB2$address<- str_replace_all(DB2$address,"\\bCARRETERA A MARIONA","CALLE A MARIONA")
DB2$address<- str_replace_all(DB2$address,"\\bCARRETERA QUE DE SANTA ANA CONDUCE A SAN SALVADOR","CARRETERA PANAMERICANA")
DB2$address<- str_replace_all(DB2$address,"CARRETERA DE SAN SALVADOR A COMLAPA|CARRETERA A LOS PLANES Y AUTO A COMALAPA|AUTOPISTA A COMALAPA|\\bCARRETERA AUTOPISTA A AEROPUERTO","RN-5")
DB2$address<- str_replace_all(DB2$address,"CARRETEREA DE SENSUNTE A ILOBASCO","RN 8")
DB2$address<- str_replace_all(DB2$address,"CARRETERA QU DE OPICO CONDUCE A TACACHICO","LIB 25 W")
DB2$address<- str_replace_all(DB2$address,"CARRETERA DE SANTA ANA A SOSN","CA 12S")
DB2$address<- str_replace_all(DB2$address,"CALLE DE SANTA ANA A METAPAN","CA 12N")
DB2$address<- str_replace_all(DB2$address,"\\bCONTIGUO A\\b","CONTIGUO")
DB2$address<- str_replace_all(DB2$address,"(\\bA LA |)ALTURA DEL\\b","ALTURA")
DB2$address<- str_replace_all(DB2$address,"\\bLTE\\b","LOTE")
DB2$address<- str_replace_all(DB2$address,"\\bCOM\\b","COMUNIDAD")#895
DB2$address<- str_replace_all(DB2$address,"\\bCALLE PRINCIPAL A VALLE NUEVO\\b","CALLE CIRUNVALACION")
DB2$address<- str_replace_all(DB2$address,"\\bCARRETERA DE AHUA A LAS CHINAMAS\\b","CA 8W")
DB2$address<- str_replace_all(DB2$address,"\\bCARRETERA DE QUEZALTE A SAN SALVADOR\\b","CALLE A QUEZALTEPEQUE")#777 
DB2$address<- str_replace_all(DB2$address,"\\bNVO CUSCATLAN\\b","NUEVO CUSCATLAN")#373
DB2$address<- str_replace_all(DB2$address,"\\bALAM. M.E. ARAUJO\\b","ALAMEDA MANUEL ENRIQUE ARAUJO")
DB2$address<- str_replace_all(DB2$address,"\\J/ (.+?)( |$)"," ")


#DB2$address<- str_replace_all(DB2$address,"\\bUB. CERRO SAN JACINTO\\b","SAN JACINTO") #338
DB2$address<- str_replace_all(DB2$address,"\\bATRAS DE\\b|\\bATRÁS DE\\b|\\bATRAS DEL\\b|\\bATRÁS DEL\\b|\\bATRÁS\\b|\\bATRAS\\b","ATRÁS")
#DB2$address<- str_replace_all(DB2$address," \\bEN CANCHA DE FUTBOL\\b","") #241

#CREATING A REFERENCE AND DIRECTION TOWARDS THE REFERENCE, Ex: En frente de Tienda...
DB2<- DB2 %>% 
  mutate(reference=as.character(str_squish(str_extract_all(address, "(\\bFRENTE(.+?),|\\bFRENTE.+|\\bINTERIOR(.+?),|\\bINTERIOR.+|\\bATRÁS(.+?),|\\bATRÁS.+|\\bPOR\\b(.+?),|\\bPOR\\b.+|\\bCONTIGUO\\b(.+?),|\\bCONTIGUO\\b.+|\\bALTURA\\b(.+?),|\\bALTURA\\b.+)"))))
DB2$reference<- str_replace_all(DB2$reference,"character\\(0\\)|character\\(\"|\"\\)|c\\((\"|)",'')
#SEPARATING THE COLUMNS INTO POINT OF REFERENCE AND DIRECTION
DB2<-separate(data = DB2, col = reference, into =c("reference1","place1","reference2","place2","reference3","place3"), sep = "( |\")\\b(?=FRENTE)|(?<=FRENTE)\\b( |\")|( |\")\\b(?=INTERIOR)|(?<=INTERIOR)\\b( |\")|( |\")\\b(?=ATRÁS)|(?<=ATRÁS)\\b( |\")|( |\")\\b(?=POR)|(?<=POR)\\b( |\")|( |\")\\b(?=CONTIGUO)|(?<=CONTIGUO)( |\")|\\b(?=ALTURA)|(?<=ALTURA)( |\")")
# Leaving just the direction without the reference
DB2$clean_address<- str_replace_all(str_trim(str_replace_all(DB2$address,"(\\bFRENTE(.+?),|\\bFRENTE.+|\\bINTERIOR(.+?),|\\bINTERIOR.+|\\bATRÁS(.+?),|\\bATRÁS.+|\\bPOR\\b(.+?),|\\bPOR\\b.+|\\bCONTIGUO\\b(.+?),|\\bCONTIGUO\\b.+|\\bALTURA\\b(.+?),|\\bALTURA\\b.+)","")),",(?=$)","")
# saving the dataset
#load("mineria.RData")
setwd(out)
write.xlsx(DB2, "name")
