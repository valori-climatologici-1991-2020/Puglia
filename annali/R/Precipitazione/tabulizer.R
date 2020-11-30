rm(list=objects())
library("tabulizer")
library("tidyverse")
library("pdftools")
source("help.R")

#"../annale2018.pdf"->nomeFile pag=103
"../annale2018.pdf"->nomeFile
str_extract(nomeFile,"[0-9]{4}")->anno

ULTIMA_PAGINA<-FALSE

purrr::walk(125:143,.f=function(numeroPagina){

  print(numeroPagina)
  
  
  extract_tables(file=nomeFile,page = numeroPagina,method = "stream",output="matrix")[[1]]->tabella
  as.tibble(tabella)->tabella
  
  eliminaColonneVuote(x=tabella)->tabella
  trovaRigheIntestazioni(x=tabella)->righeIntestazioni
  if(!length(righeIntestazioni)) stop("righeIntestazioni vuoto")
  if(ULTIMA_PAGINA) stop("Ho trovato precedentemente una sola riga intestazione ma non era l'ultima pagina!")
  if(length(righeIntestazioni)==1) ULTIMA_PAGINA<<-TRUE
  
  tabella[1:(righeIntestazioni[1]-1),]->intestazione
  nrow(intestazione)->nHeader
  intestazione[1,]->nomiUpper
  tabella[righeIntestazioni[1]:nrow(tabella),]->tabella
  
  trovaRigheTotali(x=tabella)->righeTotali
  if(!length(righeTotali)) stop("righeTotali vuoto")
  
  as.tibble(tabella[1:(righeTotali[1]-1),1:ncol(tabella)])->tabella1.upper
  creaTabelle(x=tabella1.upper,anno=anno)->tabelle.upper
  
  as.character(nomiUpper)[nchar(nomiUpper)!=0]->nomiUpper
  str_remove(str_remove(nomiUpper,"^G "),"i$")->nomiUpper

    
  tabelle.upper[[1]]$stazione<-nomiUpper[1]
  
  try({
    tabelle.upper[[2]]$stazione<-nomiUpper[2]
  })
  
  print("fattoooo<-----")
  
  if(!ULTIMA_PAGINA){
    tabella[righeIntestazioni[2]-nHeader-3,]->nomiLower
    as.tibble(tabella[(righeIntestazioni[2]-nHeader):(righeTotali[2]-1),1:ncol(tabella)])->tabella1.lower
    creaTabelle(x=tabella1.lower,anno=anno)->tabelle.lower
    
    as.character(nomiLower)[nchar(nomiLower)!=0]->nomiLower
    str_remove(str_remove(nomiLower,"^G "),"i$")->nomiLower
    tabelle.lower[[1]]$stazione<-nomiLower[1]
    
    if(length(tabelle.lower)==2){
      tabelle.lower[[2]]$stazione<-nomiLower[2]
    }
    
    list(tabelle.upper,tabelle.lower)->daScrivere
      
  }else{
    
    list(tabelle.upper)->daScrivere
    
    
  }


  
  
  
  purrr::walk(daScrivere,.f=function(tt){
  
    try({
      str_replace_all(tt[[1]]$stazione[1]," ","_")->nomeStazione
      write_delim(tt[[1]],glue::glue("Puglia_precipitazione_{anno}_{nomeStazione}.csv"),delim=";",col_names = TRUE)
    })
    
    try({
      str_replace_all(tt[[2]]$stazione[1]," ","_")->nomeStazione
      write_delim(tt[[2]],glue::glue("Puglia_precipitazione_{anno}_{nomeStazione}.csv"),delim=";",col_names = TRUE)
    })
    
  })

  Sys.sleep(5)
  print("finito")

})