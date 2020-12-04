rm(list=objects())
library("tabulizer")
library("tidyverse")
library("pdftools")
source("help.R")

"../annale2019.pdf"->nomeFile
str_extract(nomeFile,"[0-9]{4}")->anno

print(glue::glue("Elaborazione Annali, anno {anno}"))

ULTIMA_PAGINA<-FALSE
##50:150

purrr::walk(97:150,.f=function(numeroPagina){

  print(glue::glue("Elaboro pagina: {numeroPagina}"))
  
  tryCatch({ 
    extract_tables(file=nomeFile,page = numeroPagina,method = "stream",output="matrix")[[1]]->tabella
    as_tibble(tabella)
  },error=function(e){ 
    NULL
  })->tabella
  
  if(is.null(tabella)) {warning(glue::glue("Lettura pagina {numeroPagina} fallita!")); return()}
  
  eliminaColonneVuote(x=tabella)->tabella
  trovaRigheIntestazioni(x=tabella)->righeIntestazioni
  if(!length(righeIntestazioni)){warning("righeIntestazioni vuoto");return()}
  if(ULTIMA_PAGINA) stop("Ho trovato precedentemente una sola riga intestazione ma non era l'ultima pagina!")
  if(length(righeIntestazioni)==1) ULTIMA_PAGINA<<-TRUE
  
  tabella[1:(righeIntestazioni[1]-1),]->intestazione
  nrow(intestazione)->nHeader

  #nomi delle stazioni nelle due tabelle in alto
  cercaNomiStazioni(x=intestazione)->nomiUpper

  if(any(nchar(nomiUpper)<=3)){
    sink(glue::glue("logNomi{anno}.txt"),append=TRUE)
    print(nomiUpper)
    sink()
  }
  
  tabella[righeIntestazioni[1]:nrow(tabella),]->tabella
  #per il corretto funzionamento della funzione coalesceColonne e' necessario che la colonna che corrisponde ai giorni
  #abbia sempre un'intestazione e non sia vuota. La funzione che segue cerca la colonnadei giorni e le assegna un nome ("d")
  trovaRigheTotali(x=tabella)->righeTotali
  if(!length(righeTotali)) stop("righeTotali vuoto")
  
  as.tibble(tabella[1:(righeTotali[1]-1),1:ncol(tabella)])->tabella1.upper
  
  #il cui solo scopo e' quello di assicurare che la prima cella della colonnadei giorni non sia "" che ingannerebbe
  #la funzione coalesceColonne
  
  trovaColonnaGiorni(x=tabella1.upper)->tabella1.upper
  
  creaTabelle(x=tabella1.upper,anno=anno)->tabelle.upper

  #Cerco le stringhe che hanno piu' di 1 carattere (per escludere una cella "" o una cella "G": "G" corrisponde alla G di Giorno
  #che compare in verticale nei pdf tra le tabelle di precipitazione)
  as.character(nomiUpper)[nchar(nomiUpper)>1]->nomiUpper
  str_remove(str_remove(nomiUpper,"^G "),"i$")->nomiUpper
  nomiUpper[nchar(nomiUpper)>0]->nomiUpper
  
  tabelle.upper[[1]]$stazione<-nomiUpper[1]
  
  try({
    tabelle.upper[[2]]$stazione<-nomiUpper[2]
  })
  

  if(!ULTIMA_PAGINA){
    
    cercaNomiStazioni(x=intestazione)->nomiUpper
    #Qui fissiamo a 36 l'inizio della tabella lower, ma potrebbe non funzionare?
    tabella[36:(righeIntestazioni[2]-3),]->intestazioneLower
    cercaNomiStazioni(x=intestazioneLower)->nomiLower
    if(any(nchar(nomiLower)==2)) browser()
    
    as.tibble(tabella[(righeIntestazioni[2]-nHeader):(righeTotali[2]-1),1:ncol(tabella)])->tabella1.lower
    trovaColonnaGiorni(x=tabella1.lower)->tabella1.lower
   
    creaTabelle(x=tabella1.lower,anno=anno)->tabelle.lower
  
    as.character(nomiLower)[nchar(nomiLower)>1]->nomiLower
    str_remove(str_remove(nomiLower,"^G "),"i$")->nomiLower
    
    nomiLower[nchar(nomiLower)>0]->nomiLower
    
    tabelle.lower[[1]]$stazione<-nomiLower[1]
    
    if(length(tabelle.lower)==2){
      tabelle.lower[[2]]$stazione<-nomiLower[2]
    }
    
    list(tabelle.upper,tabelle.lower)->daScrivere
      
  }else{
    
    list(tabelle.upper)->daScrivere
    
    
  }
  
  
  mysum<-function(x){ 
  
    which(is.na(x))->qualiNA
    if(length(qualiNA)>10) return(NA)
    
    sum(x,na.rm=TRUE)
    
  }


  purrr::walk(daScrivere,.f=function(tt){
  
    try({
      tt[[1]]$yy<-anno
      str_replace_all(tt[[1]]$stazione[1]," ","_")->nomeStazione
      write_delim(tt[[1]] %>% dplyr::select(stazione,yy,dd,everything()),glue::glue("Puglia_precipitazione_{anno}_{nomeStazione}.csv"),delim=";",col_names = TRUE)
      
      tt[[1]] %>%
        dplyr::select(-stazione,-yy,-dd) %>%
        apply(.,2,mysum)->somma
      
      sink(glue::glue("logSommeMensili{anno}.txt"),append=TRUE)
      cat(paste0(paste0(nomeStazione,";",anno),";",paste0(somma,collapse = ";")),"\n")
      sink()
      
    })
    
    try({
      tt[[2]]$yy<-anno
      str_replace_all(tt[[2]]$stazione[1]," ","_")->nomeStazione
      write_delim(tt[[2]] %>% dplyr::select(stazione,yy,dd,everything()),glue::glue("Puglia_precipitazione_{anno}_{nomeStazione}.csv"),delim=";",col_names = TRUE)
      
      tt[[2]] %>%
        dplyr::select(-stazione,-yy,-dd) %>%
        apply(.,2,mysum)->somma
      
      sink(glue::glue("logSommeMensili{anno}.txt"),append=TRUE)
      cat(paste0(paste0(nomeStazione,";",anno),";",paste0(somma,collapse = ";")),"\n")
      sink()
      
    })
    
  })

  
  print(glue::glue("finito pagina {numeroPagina}"))

})
