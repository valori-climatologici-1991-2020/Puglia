rm(list=objects())
library("tidyverse")
library("curl")
library("openxlsx")
library("basictabler")

ESEGUI<-FALSE

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

      if(!file.exists(glue::glue("annale{anno}.pdf"))) system(glue::glue("wget {cfURL}"))
      
      if(ESEGUI){system(glue::glue("./scriptPuglia.sh annale{anno}.pdf"))}
      
      if(!file.exists("dati.csv")) stop("File dati.csv non trovato")
      if(!file.exists("nomiStazioni.csv")) stop("File nomiStazioni.csv non trovato")

      nomeFile<-"dati.csv"
      nomiStazioni<-"nomiStazioni.csv"
      
      read_delim(nomeFile,delim=";",col_types = cols(.default = col_double()),col_names = FALSE)->dati

      problems(dati)->problemi
      which(is.na(problemi$col))->ris

      readLines(con="nomiStazioni.csv")->nomiStazioni
      
      stopifnot((length(nomiStazioni)*31)==nrow(dati))
      
      rep(str_trim(nomiStazioni),each=31)->dati$stazione
      stopifnot(min(dati$X1)==1)
      stopifnot(max(dati$X1)==31)
      
      dati$X1<-rep(seq(1,31),length(nomiStazioni))
      
      dati$yy<-anno
      dati$sbagliata<-FALSE
      dati$sbagliata[problemi[ris,]$row]<-TRUE

      names(dati)<-c("dd",paste(c("Tmax","Tmin"),rep(seq(1,12),each=2),sep="."),"stazione","yy","sbagliata")
      dati

  
}) %>% purrr::compact(.)->listaOut


if(!length(listaOut)) stop("Nessun file dati disponibile")

bind_rows(listaOut)->mydf

unique(mydf$stazione)->nomiStazioni

openxlsx::createWorkbook()->myworkbook

purrr::map(nomiStazioni,.f=function(nomeStazione){
  
  mydf %>%
    filter(stazione==nomeStazione) %>%
    dplyr::select(sbagliata,stazione,yy,dd,everything())->subDati
  
  BasicTable$new()->tbl
  tbl$addData(dataFrame = subDati,columnNamesAsColumnHeaders = TRUE,rowNamesAsRowHeaders = FALSE)
  tbl$findCells(columnNumbers = 1,exactValues=list(TRUE),includeNA = FALSE)->qualiCelle
  if(length(qualiCelle)) tbl$setStyling(cells=qualiCelle,declarations = list("background-color"="lightgreen"))
  
  str_sub(nomeStazione,start=1,end=30)->nomeFoglio
  addWorksheet(myworkbook,sheetName=nomeFoglio)
  tbl$writeToExcelWorksheet(wb = myworkbook,wsName = nomeFoglio,topRowNumber = 1,leftMostColumnNumber = 1)
  
  purrr::walk(5:28,.f=~(writeFormula(myworkbook,sheet=nomeFoglio,startCol = .,startRow = 33,x=glue::glue("ROUND(AVERAGE({LETTERS[.]}2:{LETTERS[.]}32),1)"))))
  


})

saveWorkbook(myworkbook,glue::glue("puglia{annoI}.xlsx"),overwrite = TRUE)
