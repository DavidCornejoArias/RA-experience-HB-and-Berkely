# -*- coding: utf-8 -*-
"""
Created on Sun Sep 15 08:35:30 2019
# creando pruebas para ver cómo se comparan las distintas API
@author: David Rolando Cornejo Arias
"""
# Setting everything
import cv2
import numpy
import pandas as pd
from opencage.geocoder import OpenCageGeocode
from pprint import pprint
import time
# setting file
path = ''
key = ''
os.chdir(path)

# loading the database
df = pd.read_excel(r'data.xlsx')
listado = df['linea'].tolist()
longitudes = []
latitudes = []

# Using OpenCageGeocode
# Note OpenCageGeocode only allows certain amount of requests per day
geocoder = OpenCageGeocode(key)
for i in range(1,len(listado)):
    try:
        numpy.isnan(df['descripción'].tolist()[0])
        valor = "" 
    except TypeError:
        valor = df['descripción'].tolist()[i]
    query = valor + "," + df['municipio'].tolist()[i]+","+df['departamento'].tolist()[i]+", El Salvador"
    time.sleep(5) 
    results = geocoder.geocode(query)
    longitud = results[0]['geometry']['lat']
    latitud = results[0]['geometry']['lng']
    longitudes.append(latitud)
    latitudes.append(longitud)
# setting the dataframe columns
df2 = pd.DataFrame()
df2['linea'] = df['linea'].tolist()
df2['descripción'] = df['descripción'].tolist()
df2['municipio'] = df['municipio'].tolist()
df2['departamento'] = df['departamento'].tolist()
df2['longitudes'] =longitudes
df2['latitudes']=latitudes
df2.to_excel(r'probe_open_cage.xlsx')
