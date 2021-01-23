rm(list=objects())
library("jsonlite")
library("tidyverse")
library("guido")

annoI<-annoF<-2020
creaCalendario(annoI,annoF)->calendario

PARAMETRO<-c("Prec","Tmax","Tmin")[3]

list.files(pattern="^.+\\.json$")->ffile

purrr::map(ffile,.f=function(nomeFile){
  
  read_json(nomeFile,simplifyVector = TRUE)->dati

  if(!length(dati)) return()

  dati$Stazione[1]->idstaz
  
  stopifnot(str_remove(nomeFile,"\\.json")==idstaz)
  
  dati %>% 
    dplyr::select(Data,Valore,Stazione) %>%
    mutate(yymmdd=str_remove(Data,"T.+$")) %>%
    tidyr::separate(yymmdd,into=c("yy","mm","dd"),sep="-")%>%
    mutate(yy=as.integer(yy),mm=as.integer(mm),dd=as.integer(dd)) %>%
    dplyr::select(yy,mm,dd,Valore)->dati2
  
  
  if(grepl("Tmax",PARAMETRO)){
    
    dati2 %>% 
      group_by(yy,mm,dd) %>%
      summarise_all(.funs=max,na.rm=TRUE) %>%
      ungroup()->dati3
    
  }else if(grepl("Tmin",PARAMETRO)){
    
    
    dati2 %>% 
      group_by(yy,mm,dd) %>%
      summarise_all(.funs=min,na.rm=TRUE) %>%
      ungroup()->dati3
    
  }else if(grepl("^P.+",PARAMETRO)){
    
    dati2->dati3
    
  }

  names(dati3)[4]<-idstaz
  print(idstaz)
  dati3[!duplicated(dati3[,c("yy","mm","dd")]),]
  
  
})->listaOut

purrr::compact(listaOut)->listaOut

if(!length(listaOut)) stop(glue::glue("Nessun dato per {PARAMETRO}"))


purrr::reduce(listaOut,.f=left_join,.init=calendario)->finale


print(skimr::skim(calendario))
print(skimr::skim(finale))


write_delim(finale,glue::glue("{PARAMETRO}_{annoI}_{annoF}_puglia.csv"),delim=";",col_names = TRUE)
