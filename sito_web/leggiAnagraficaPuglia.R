rm(list=objects())
library("tidyverse")
library("xml2")
library("rvest")

read_delim("ris.csv",delim=";",col_names = TRUE,col_types = cols(Elevation=col_integer(),Longitude=col_double(),Latitude=col_double()))->ana

purrr::map_dfr(1:nrow(ana),.f=function(riga){
  
  if(is.na(ana[riga,]$SiteCode)) return(ana[riga,])
  
  ana[riga,]$SiteCode->CODICE

  xml2::read_html(glue::glue("http://93.57.89.4:8081/temporeale/stazioni/{CODICE}/anagrafica"))->myhtml
  
  myhtml %>%
    rvest::html_node(xpath = "/html/body/div/div[1]/section/div/div/div/div[2]/div/div") %>%
    html_nodes(xpath="h5")->ris
  
  unlist(str_split(str_trim(str_remove(html_text(ris[[3]]),"[:alpha:]+:"),side="both"),","))->coordinate
  coordinate[1]->lat
  coordinate[2]->lon
  str_extract(html_text(ris[[4]]),"[0-9]+")->quota
  

  ana[riga,]$Elevation<-as.integer(quota)
  ana[riga,]$Longitude<-as.double(lon)
  ana[riga,]$Latitude<-as.double(lat)
  
  
  
  Sys.sleep(5)
  
  ana[riga,]
  
})->finale
