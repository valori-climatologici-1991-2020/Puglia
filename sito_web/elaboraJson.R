rm(list=objects())
library("jsonlite")
library("tidyverse")
library("guido")

annoI<-annoF<-2014
creaCalendario(annoI,annoF)->calendario

PARAMETRO<-c("Tmax","Tmin")[1]

if(grepl("Tmax",PARAMETRO)){
  ID<-1873
}else if(grepl("Tmin",PARAMETRO)){
  ID<-1871
}else if(grepl("^P.+",PARAMETRO)){
  
}

list.files(pattern="^.+\\.json$")->ffile

purrr::map_dfc(ffile,.f=function(nomeFile){
  browser()
  read_json(nomeFile,simplifyVector = TRUE) %>%
    filter(Id==ID)->dati
  
  dati$Stazione[1]->idstaz
  
  stopifnot(str_remove(nomeFile,"\\.json")==idstaz)
  
  dati %>% 
    dplyr::select(Data,Valore,Stazione) %>%
    mutate(yymmdd=str_remove(Data,"T.+$")) %>%
    tidyr::separate(yymmdd,into=c("yy","mm","dd"),sep="-")%>%
    mutate(yy=as.integer(yy),mm=as.integer(mm),dd=as.integer(dd)) %>%
    dplyr::select(yy,mm,dd,Valore)->dati2
  
  names(dati2)[4]<-idstaz
  
  dati2[!duplicated(dati2[,c("yy","mm","dd")]),]
  
  
}) %>% purrr::reduce(.f=left_join,.init=calendario)->finale


print(skimr::skim(calendario))
print(skimr::skim(finale))


write_delim(finale,glue::glue("{PARAMETRO}_{annoI}_{annoF}_puglia.csv"),delim=";",col_names = TRUE)
