eliminaColonneVuote<-function(x){    
  
  purrr::map(1:ncol(x),.f=function(colonna){
    
    x[[colonna]]->.y
    
    if(all(!str_count(.y))) return()
    
    str_remove(.y,"^\\. ")
    
  }) %>% purrr::compact() %>% reduce(.f=bind_cols)->out
  
  out
  
}#eliminaColonneVuote

trovaRigheIntestazioni<-function(x){

  purrr::map(1:nrow(x),.f=function(rr){
    
    str_replace_all(paste0(x[rr,1:ncol(x)],collapse = "")," {1,}","")->stringa
    
    if(grepl("GFMAMGLASOND.*GFMAMGLASOND",stringa)) return(rr)
    if(grepl("GFMAMGLASOND.{1} *",stringa)) return(rr)
    
    return()
    
  })->righeIntestazioni
  
  purrr::compact(righeIntestazioni) %>% unlist->righeIntestazioni

}#trovaRigheIntestazioni

trovaRigheTotali<-function(x){

    purrr::map(1:nrow(x),.f=function(rr){
      
      str_replace_all(paste0(x[rr,1:ncol(x)],collapse = "")," {1,}","")->stringa
      #  print(stringa)
      if(grepl("(T|t)ot.*mens",stringa)) return(rr)
      return()
      
    })->righeTotali
    
    purrr::compact(righeTotali) %>% unlist

}#fine trovaRigheTotali

aggiustaTabelle<-function(x,replaceHeader=FALSE){
  
  purrr::map_dfc(x,.f=function(colonna){

    tibble(temp=colonna)->mytibble
    
    if(replaceHeader){
      firstRow<-2
      unlist(str_split(as.character(mytibble[1,1]),pattern=" "))->intestazioneColonna
      round(runif(n=length(intestazioneColonna)),2)->acaso
      paste0(intestazioneColonna,acaso)->nuoviNomi
    }else{
      firstRow<-1
      c("X1","X2")->nuoviNomi
    }  
    

    mytibble %>%
      slice(firstRow:nrow(mytibble)) %>%
      separate(col=temp,into=nuoviNomi,sep=" +")->nuovoTibble
    
    nuovoTibble
    
  })->out2
  
  out2
  
}#fine aggiustaTabelle


coalesceColonne<-function(x){
  
  STOP<-FALSE
  x->X
  
  while(1>0){
    
    which(nchar(x[1,])==0)->colonnE
    
    if(!length(colonnE)){break;}
    if(length(colonnE)>=1) {colonna<-colonnE[1]}
  
      if(colonna==1){
        
        x[,c(colonna,colonna+1)]->xx
        
        
      }else if(colonna>1 & colonna <ncol(x)){ 
    
        x[,c(colonna-1,colonna,colonna+1)]->xx
      
      }else if(colonna==ncol(x)){
        
        x[,c(colonna-1,colonna)]->xx
        
        
      }  
      
      purrr::map_chr(1:nrow(xx),.f=function(rr){
        
        str_trim(paste0(xx[rr,],sep="",collapse = " "),side="both")
        
        
      })->xxx
      
      tibble(xxx=xxx)->xxx
      
      aggiustaTabelle(xxx,replaceHeader = FALSE)->xxx
      
      
      
      if(colonna==1){
        
        bind_cols(xxx,x[,(colonna+2):ncol(x)])->nuovoDF
        
        
      }else if(colonna>1 & colonna <ncol(x)){ 
        
        bind_cols(x[,1:(colonna-2)],xxx,x[,(colonna+2):ncol(x)])->nuovoDF
        
      }else if(colonna==ncol(x)){
        

        bind_cols(x[,1:(ncol(x)-2)],xxx)->nuovoDF
        
        
      }  
      
      nuovoDF->x
  
  }#fine for
  

  x
  
}#fine coalesceColonne



dividiTabelle<-function(x){
  
  if(!sum(as.numeric(x[[13]]))==sum(1:31)) stop("errore")
  
  tryCatch({
    x[,c(13,1:12)]->leftTable
  },error=function(e){
    NULL
  })->leftTable
  
  if(!is.null(leftTable))  {names(leftTable)<-c("dd",month.abb)}

  tryCatch({
    x[,13:25]
  },error=function(e){
    NULL
  })->rightTable
    
  if(!is.null(rightTable))  {names(rightTable)<-c("dd",month.abb)}
  
  list(leftTable,rightTable)
  
} #fine dividiTabelle


correggi31<-function(x,year=anno){
  
  x[31,2:13]->ultimaRiga
  as.character(ultimaRiga)->ultimaRiga
  
  which(nchar(ultimaRiga)==0)->qualiVuote
  ultimaRiga[qualiVuote]<-NA
  which(is.na(ultimaRiga))->qualiNA
  if(length(qualiNA)==5){
    ultimaRiga[!is.na(ultimaRiga)]->valori
    valori[1]->ultimaRiga[1]
    ultimaRiga[2]<-NA
    ultimaRiga[3]<-valori[2]
    ultimaRiga[4]<-NA
    ultimaRiga[5]<-valori[3]
    ultimaRiga[6]<-NA
    ultimaRiga[7]<-valori[4]
    ultimaRiga[8]<-valori[5]
    ultimaRiga[9]<-NA
    ultimaRiga[10]<-valori[6]
    ultimaRiga[11]<-NA
    ultimaRiga[12]<-valori[7]
  }

  x[31,2:13]<-as.list(ultimaRiga)
  
  x
  
}#fine correggi31

correggiRiga<-function(x,riga){
  
  x[riga,2:13]->penultimaRiga

  as.character(penultimaRiga)->penultimaRiga

  which(nchar(penultimaRiga)==0)->qualiVuote
  penultimaRiga[qualiVuote]<-NA
  which(is.na(penultimaRiga))->qualiNA
  
  if(length(qualiNA)==1){
    penultimaRiga[!is.na(penultimaRiga)]->valori
    valori[1]->penultimaRiga[1]
    penultimaRiga[2]<-NA
    penultimaRiga[3:12]<-valori[2:11]
  }
  

  x[riga,2:13]<-as.list(penultimaRiga)
  
  x
  
}#fine correggiRiga



numeriche<-function(x){
  
  
  purrr::map_dfc(x,.f=function(colonna){
    
    str_replace(colonna,"-","0.0")->colonna
    str_replace(colonna,",",".")->colonna
    str_replace(colonna,">>","NA")->colonna    
    as.numeric(colonna)

  })  
  
  
}#numeriche


creaTabelle<-function(x,anno){
  
  aggiustaTabelle(x=x,replaceHeader = TRUE)->y

  coalesceColonne(y)->y

  dividiTabelle(y)->listaTabelle
  
  purrr::compact(listaTabelle)->listaTabelle
  
  if(!length(listaTabelle)) return()

  if(!lubridate::leap_year(as.integer(anno))) map(listaTabelle,.f=correggiRiga,riga=29)->listaTabelle
  map(listaTabelle,.f=correggiRiga,riga=30)->listaTabelle
  map(listaTabelle,.f=correggi31)->listaTabelle
  
  map(listaTabelle,.f=numeriche)->listaTabelle
  
  listaTabelle
  
}#creaTabelle

