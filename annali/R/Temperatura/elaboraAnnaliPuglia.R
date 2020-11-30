rm(list=objects())
library("tidyverse")
library("curl")

ESEGUI<-TRUE

annoI<-2013
annoF<-annoI

anni<-seq(annoI,annoF)


purrr::map(anni,.f=function(anno){
  
  
  print(paste0("Elaboro anno:",anno))
  
  if(ESEGUI){
    if(file.exists("dati.csv")) file.remove("dati.csv")
    if(file.exists("nomiStazioni.csv")) file.remove("nomiStazioni.csv")
  }
  
  glue::glue("https://protezionecivile.puglia.it/wp-content/uploads/Annali_I/annale{anno}.pdf")->cfURL
  
  #scarico annale
  tryCatch({
      if(!file.exists(glue::glue("annale{anno}.pdf"))) system(glue::glue("wget {cfURL}"))
      
      if(ESEGUI){system(glue::glue("./scriptPuglia.sh annale{anno}.pdf"))}
      
      if(!file.exists("dati.csv")) stop("File dati.csv non trovato")
      if(!file.exists("nomiStazioni.csv")) stop("File nomiStazioni.csv non trovato")
      
      nomeFile<-"dati.csv"
      nomiStazioni<-"nomiStazioni.csv"
      
      read_delim(nomeFile,delim=";",col_types = cols(.default = col_double()),col_names = FALSE)->dati
      
      problems(dati)->problemi
      which(is.na(problemi$col))->ris
      if(length(ris)){
        sink("log.txt",append=TRUE)
        cat(paste(anno,"\n"))
        sink()
        return(dati)
      }
      readLines(con="nomiStazioni.csv")->nomiStazioni
      
      stopifnot((length(nomiStazioni)*31)==nrow(dati))
      
      rep(nomiStazioni,each=31)->dati$stazione
      stopifnot(min(dati$X1)==1)
      stopifnot(max(dati$X1)==31)
      
      dati$X1<-rep(seq(1,31),length(nomiStazioni))
      
      dati$yy<-anno
      names(dati)<-c("dd",paste(c("Tmax","Tmin"),rep(seq(1,12),each=2),sep="."),"stazione","yy")
      dati
  },error=function(e){
    NULL
  })->out
  
  out
  
}) %>% purrr::compact(.)->listaOut


if(!length(listaOut)) stop("Nessun file dati disponibile")

bind_rows(listaOut)->mydf

mydf %>%
  gather(key="chiave",value="val",-yy,-dd,-stazione) %>%
  mutate(stazione=str_remove(stazione,"^ +")) %>%
  separate(col=chiave,into=c("param","mm"),sep="\\.")->finale

finale %>% filter(param=="Tmax")->Tmax
write_delim(Tmax,file=glue::glue("Tmax_puglia_{annoI}_{annoF}.csv"),delim=";",col_names=TRUE )
finale %>% filter(param=="Tmin")->Tmin
write_delim(Tmin,file=glue::glue("Tmin_puglia_{annoI}_{annoF}.csv"),delim=";",col_names=TRUE )



library("skimr")
skim(Tmax)
skim(Tmin)
