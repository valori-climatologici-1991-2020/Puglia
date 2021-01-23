#Gennaio 2021
#
#I dati del 2020 sono disponibili alla pagina : http://93.57.89.4:8081/temporeale/stazioni/50/giornalieri
#ovvero nell'archivio dei dati giornalieri della regione Puglia.
#
#Con Firefox e' facile catturare "a mano" i json che sono alla base dei grafici di temperatura e precipitazione (con chrome e' meno pratico ma fattibile)
#
#Questo script permette di automatizzare l'acquisizione dei dati di temperatura e precipitazione.

#Lo script usa curl. La stringa passata a curl e' stata ottenuta mediante "copy cUrl" da firefox (sempre utilizzando il web developer)
#
#Sono stati acquisiti i dati 2020 (a gennaio 2021. Questi dati prima o poi diventeranno dei pdf scaricabili come Annali) e i dati 2014 (dati che non erano 
#leggibili dai pdf degli Annali e mai passati dalla regione Puglia.)
rm(list=objects())
library("tidyverse")
library("RCurl")

#anno da scaricare
ANNO<-2020

PARAMETRO<-c("Prec","Temp")[2]

if(grepl("^P",PARAMETRO)){ 
  SENSORE<-0
  MISURA<-9
  nomeAna<-"sensori_precipitazione_Puglia.csv"
}else{
  SENSORE<-5
  MISURA<-"[1,3]"
  nomeAna<-"sensori_temperatura_Puglia.csv"
}

#Questo file contiene il nome stazione e il codice. Il codice e' stato ricavato dalla pagina:
# http://93.57.89.4:8081/temporeale/meteo/stazioni?viewType=tab
#I codici stazione necessari per curl si ottengono dal codice html della pagina.

read_delim(nomeAna,delim=";",col_names = TRUE)->codici


"'http://93.57.89.4:8081/temporeale/api/stations/#CODICE#/daily-data-novalidate/q' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0'"->stringa1
"-H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: http://93.57.89.4:8081/temporeale/stazioni/{CODICE}/giornalieri' -H 'Content-Type: application/json' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H 'Cookie: pugliatr.sid=s%3AX1D7pBWIcXXkF7Sfde0-RQ83xadGPsAj.lhr4vmTbYstH2ZkBPtr8C5QPylg%2FxJ%2FoiXN2lpc2R9M' -H 'Sec-GPC: 1'"->stringa2
"--data '{\"rete\":1,\"sensore\":#SENSORE#,\"misura\":#MISURA#,\"giornaliero\":true,\"period\":\"days\",\"startData\":\"#ANNO#-01-01\",\"endData\":\"#ANNO#-12-31\"}'"->stringa3

#Qui non posso usare le parentesi { } perche' già compaiono nella stringa passata a curl
glue::glue(stringa3,.open = "#",.close = "#")->stringa3


#CODICE viene sostituito per generare la stringa specifica necessaria per curl.
purrr::walk(codici$codice,.f=function(CODICE){ 
  
  if(file.exists(glue::glue("{CODICE}.json"))) return()
  glue::glue(stringa1,.open = "#",.close = "#")->stringa1
  
  glue::glue(stringa2)->stringa2Fixed
  
  
  
  str_c(stringa1,stringa2Fixed,stringa3,sep=" ")->stringacURL
  str_c("curl",stringacURL,glue::glue(">{CODICE}.json"),sep=" ")->esegui
  try({system(esegui)})
  
  Sys.sleep(10) # importante almeno 10 secondi 

})