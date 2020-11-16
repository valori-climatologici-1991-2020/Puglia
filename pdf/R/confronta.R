#confronto fra i dati acquisiti dagli annali con i dati ricevuti dal centro funzionale puglia
#In putput produce:
# - file pdf con confronto tra dati centro funzionale e dati annali
# - file di testo associazioni.txt in cui compare: il nome della stazione dell'annale; il codice della stazione associata del Centro Funzionale; ilnome della stazione come compare in anagrafica del Centro Funzionale.

rm(list=objects())
library("tidyverse")

PARAM<-c("Tmax","Tmin")[2]

read_delim("reg.puglia.info.csv",delim=";",col_names = TRUE) %>%
  filter(!is.na(SiteID)) %>%
  filter(!is.na(SiteName))->ana

#questi sono i deti del Centro Funzionale
read_delim(glue::glue("{PARAM}_11aprile2016.csv"),delim=",",col_names = TRUE,col_types = cols(.default = col_double()))->datiCF

#questi sono i dati estratti dagli annali
read_delim(glue::glue("../fatto/{PARAM}_puglia_1997_2020.csv"),delim=";")->datiANA

names(datiCF)[4:ncol(datiCF)]->codiciStazioni

pdf(glue::glue("puglia{PARAM}.pdf"),12,12,onefile=TRUE)
purrr::map(codiciStazioni,.f=function(codice){
  
  ana[ana$SiteID==codice,]$SiteName->nomeStazione
  
  #il nome della stazione in anagrafica non coincider mai con il nome della stazione nell'annali quindi devo usare agrep
  agrep(nomeStazione,datiANA$stazione,ignore.case = TRUE)->ris
  
  unique(datiANA[ris,]$stazione)->nomeANA
  #la corrispondenza deve essere unica, incaso contrario salto la stazione...
  if(length(nomeANA)!=1) return()
  
  
  datiANA[ris,]->subDatiAna
  datiCF[,c("yy","mm","dd",codice)]->subDatiCF
  names(subDatiCF)<-c("yy","mm","dd","valCF")
  full_join(subDatiAna,subDatiCF)->jdati
  plot(jdati$val,jdati$valCF,main=paste0(nomeANA,"-",codice,"-",nomeStazione))
  abline(a=0,b=1,col="red")
  sink("associazioni.txt",append=TRUE)
  cat(paste0(nomeANA,";",codice,";",nomeStazione,"\n"))
  sink()

  
  
})
dev.off()