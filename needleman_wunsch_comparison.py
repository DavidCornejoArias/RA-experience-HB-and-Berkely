# -*- coding: utf-8 -*-
"""
Created on Sun Nov 10 18:44:27 2019

@author: David Rolando Cornejo Arias & Javier Alfaro
"""
import textdistance
import os
import re
import pandas as pd
import csv
import re
import nltk.tokenize
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from unicodedata import normalize

# setting the file path
direccion = r"location"
os.chdir(direccion)
Archivo = r"FileName"
data = pd.read_excel (Archivo)
Archivo2 = r"ComparionFIle"
data2 = pd.read_excel (Archivo2)
# reading the dataset
df = pd.DataFrame(data)
df2 = pd.DataFrame(data2)
# reading just a part of the dataset
# cleaning the information
# creating  function to clean the databse
def cleaning(address_token2, language):
    
    # quitar las tildes
    address_token2 = re.sub(
        r"([^n\u0300-\u036f]|n(?!\u0303(?![\u0300-\u036f])))[\u0300-\u036f]+", r"\1", 
        normalize( "NFD", address_token2), 0, re.I
    )
    address_token2 = normalize( 'NFC', address_token2)
    
    ListStopWords =stopwords.words(language)
    ListStopWords.append("san")
    ListStopWords.append("santo")
    ListStopWords.append("santa")
    return re.sub(r'[^\w\s]','',' '.join([ token for token in word_tokenize(address_token2) if token.lower() not in ListStopWords]))

def cleaning2(address_token2, language):
    
    # quitar las tildes
    address_token2 = re.sub(
        r"([^n\u0300-\u036f]|n(?!\u0303(?![\u0300-\u036f])))[\u0300-\u036f]+", r"\1", 
        normalize( "NFD", address_token2), 0, re.I
    )
    address_token2 = normalize( 'NFC', address_token2)
    
    ListStopWords =stopwords.words(language)
    ListStopWords.append("san")
    ListStopWords.append("santo")
    ListStopWords.append("santa")
    ListStopWords.append("colonia")
    ListStopWords.append("canton")
    ListStopWords.append("barrio")
    ListStopWords.append("caserio")
    ListStopWords.append("comunidad")
    ListStopWords.append("lotificacion")
    ListStopWords.append("urbanizacion")
    return re.sub(r'[^\w\s]','',' '.join([ token for token in word_tokenize(address_token2) if token.lower() not in ListStopWords]))

# the result of the function I want to word_tokenize and for each three found the one with the least similarity
listadoPalabras = ["colonia","canton","barrio","caserio","comunidad","lotificacion","urbanizacion"]
df2['municipio'] = df2['municipio'].apply(lambda x: x.lower() if type(x)==str else "")
df2['place_name3'] = df2['place_name'].apply(lambda x: cleaning2(x,"spanish") if type(x)==str else "")
df['municipio'] = df['MUNICIPIO'].apply(lambda x: x.lower() if type(x)==str else "")
df['locations2'] = df['locations'].apply(lambda x: cleaning(x,"spanish").lower() if type(x)==str and x != "character(0)" else "")
df2['place_name2'] = df2['place_name'].apply(lambda x: cleaning(x,"spanish").lower())

address_list = df['locations2'].tolist()
address_list2 = df['address2'].tolist()

# setting columns
sim, text = [], []
for nombre in range(0, len(address_list)):
    if address_list[nombre] != "character0" or type(address_list[nombre]) != "NoneType" or address_list[nombre] != "character  0 " or address_list[nombre] != "character":
        filter_municipio = df2[df2['municipio'] == df['municipio'].tolist()[nombre].lower()]
        max_value = []
        address_token = word_tokenize(address_list[nombre])
        filter_municipio['municipio'].tolist()
        if len(filter_municipio['place_name2'].tolist())!=0 and len(address_token)!=0 and len(address_token)!=1:
            for nombre2 in filter_municipio['place_name2'].tolist():
                palabra = ""
                value = []
                for i in range(0, len(address_token)):
                    if address_token[i] in listadoPalabras:
                        palabra = address_token[i]
                    else:
                        palabra = palabra + " " + address_token[i]
                    if len(word_tokenize(palabra)) > 1:
                        numero = textdistance.needleman_wunsch.normalized_similarity(nombre2,palabra)
                    if numero != "":
                        value.append(numero)
                max_value.append(max(value))
            filter_municipio['DistanceValue'] = max_value
            filter_municipio.sort_values(by='DistanceValue', ascending=False, inplace=True)
            
            sim.append(filter_municipio['DistanceValue'].tolist()[0])
            text.append(filter_municipio['place_name2'].tolist()[0])
        else:
            sim.append(0)
            text.append(0)
    else:
        filter_municipio = df2[df2['municipio'] == df['municipio'].tolist()[nombre].lower()]
        max_value = []
        address_token2 = word_tokenize(address_list2[nombre])
        if len(filter_municipio['place_name3'].tolist()) != 0 and len(address_token2) != 0 and len(address_token2) != 1:
            for nombre2 in filter_municipio['place_name3'].tolist():
                palabra = ""
                value = []
                for i in range(0, len(address_token2)):
                    address_token2Evaluated = address_token2[i:len(address_token2)]
                    for i in range(0, len(address_token2Evaluated)):
                        if i !=0:
                            palabra = palabra +" " + address_token2[i]
                        else:
                            palabra = address_token2[i]
                        numero = textdistance.needleman_wunsch.normalized_similarity(nombre2,palabra)
                        value.append(numero)
                max_value.append(max(value))
            filter_municipio['DistanceValue'] = max_value
            filter_municipio.sort_values(by='DistanceValue', ascending=False, inplace=True)
            
            sim.append(filter_municipio['DistanceValue'].tolist()[0])
            text.append(filter_municipio['place_name2'].tolist()[0])
        else:
            sim.append(0)
            text.append(0)

df['Similarity'] = sim
df['Matched Address'] = text

df.to_csv(r'test1.csv')
