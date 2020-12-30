#Unisce i file delle serei di precipitazione della Puglia. Va fatto girare
#all'interno di ogni cartella con i dati 2013/2015/2016/....
rm(list=objects())
library("tidyverse")
library("seplyr")

PARAM<-c("Tmax","Tmin","Prec")[3]

if(grepl("Tm",PARAM)){
  colonnaSensore<-"idSensoreTemp"
}else{
  colonnaSensore<-"idSensorePrec"
}


list.files(pattern="^Puglia_precipitazione_.+\\.csv$")->ffile

purrr::map_dfr(ffile,.f=function(nomeFile){
  
  read_delim(nomeFile,delim=";",col_names = TRUE,col_types = cols(stazione=col_character(),yy=col_integer(),dd=col_integer(),.default = col_double()))->dati


  dati
  
})->finale

browser()

unique(finale$yy)->ANNO

finale %>%
  gather(key="mm",value="Prcp",-stazione,-yy,-dd) %>%
  write_delim(.,glue::glue("{PARAM}_annali_{ANNO}.csv"),delim=";",col_names=TRUE)
