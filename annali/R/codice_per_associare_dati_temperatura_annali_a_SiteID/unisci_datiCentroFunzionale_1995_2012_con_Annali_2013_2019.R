rm(list=objects())
library("tidyverse")

PARAM<-c("Tmax","Tmin")[2]

#anagrafica in cui compare la colonna stazione: questa ci serve per associare i nomi delle stazioni negli ANNALI
#con i nomi delle stazioni nell'anagrafica ricevuta a suo tempo dal CENTRO FUNZIONALE
read_delim("reg.puglia.info.csv",col_names = TRUE,delim=";") %>%
  filter(!is.na(SiteName_norm)) %>%
  mutate(stazioni=str_trim(stazioni,side="both"))->ana

#dati ricevuti dal CENTRO FUNZIONALE: periodo 1995-2012 (FORMATO WIDE, QUELLO DEI CONTROLLIDI QUALITA)
TIPI<-cols(yy=col_integer(),mm=col_integer(),dd=col_integer(),.default = col_double())
read_delim(glue::glue("{PARAM}_11aprile2016.csv"),delim=",",col_names=TRUE,col_types = TIPI)->datiOld

#dati ricavati daI pdf degli ANNALI: sono in formato long e il 2014 tutto NA
read_delim(glue::glue("{PARAM}_puglia_2013_2019.csv"),delim=";",col_names=TRUE) %>%
  mutate(stazione=ifelse(stazione=="GRAVINA DI PUGLIA","GRAVINA IN PUGLIA",stazione)) %>%
  mutate(stazione=ifelse(stazione=="BORGO LIBERTA'","BORGO LIBERTA",stazione)) %>%
  mutate(stazione=ifelse(stazione=="CORIGLIANO","CORIGLIANO D'OTRANTO",stazione)) %>%
  mutate(stazione=ifelse(stazione=="CASSANO MURGE","CASSANO DELLE MURGE",stazione)) %>%
  mutate(stazione=ifelse(stazione=="BORGO LIBERTÀ","BORGO LIBERTA'",stazione)) %>%
  mutate(stazione=ifelse(stazione=="ROCCHETTA SANT'ANTONIO (Trav. S. Venere)","ROCCHETTA SANT'ANTONIO (TRAV. S. VENERE)",stazione)) %>%
  mutate(stazione=ifelse(stazione=="NARDÒ","NARDO'",stazione)) %>%
  mutate(stazione=ifelse(stazione=="FOGGIA (Osservatorio)","FOGGIA (OSSERVATORIO)",stazione)) %>%  
  mutate(stazione=ifelse(stazione=="FOGGIA (Istituto Sperimentale per la Cerealicoltura)","FOGGIA (IST. SPERIM. PER CEREALICOLTURA)",stazione)) %>%
  mutate(stazione_norm=str_trim(Hmisc::capitalize(tolower(str_replace_all(stazione," ","_"))),side="both"))->datiNEW

#confronto stazione_norm con la colonna stazioni per ricavare il SiteID
left_join(datiNEW,ana[,c("stazioni","SiteID")],by=c("stazione_norm"="stazioni")) %>%
  filter(!is.na(SiteID))->datiNew2

datiNew2 %>%
  dplyr::select(-stazione,-stazione_norm,-param) %>%
  spread(key="SiteID",value="val")->finale

bind_rows(datiOld%>% filter(yy<=2012),finale)->finale


#passo in formato long
annoI<-min(finale$yy)
annoF<-max(finale$yy)

as_tibble(seq.Date(from=as.Date(glue::glue("{annoI}-01-01")),to=as.Date(glue::glue("{annoF}-12-31")),by="day")) %>%
  separate(value,into=c("yy","mm","dd"),sep="-") %>%
  mutate(yy=as.integer(yy),mm=as.integer(mm),dd=as.integer(dd))->calendario

left_join(calendario,finale)->finale

write_delim(finale,glue::glue("{PARAM}_puglia_1995_2019.csv"),delim=";",col_names=TRUE)



