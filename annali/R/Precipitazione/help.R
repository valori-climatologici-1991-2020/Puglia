trovaColonneVuote<-function(x){    
  
  purrr::map(1:ncol(x),.f=function(colonna){
    
    x[[colonna]]->.y
  
    #Può capitare che una colonna sia vuota ma una o alcune celle abbiano un "." simbolo che compare ogni tanto negli Annali
    #affiancando dati di precipitazione...elimino i punti isolati per evitare che falliscano i controlli che seguono  
    str_remove(.y,"^\\.$")->.y
    #if(!all(.z==.y)) browser()
      
    if(all(is.na(.y))) return() #colonna tutti NA, non posso fare str_count
    if(any(str_count(str_trim(.y,side="both"))!=0)) return()
    
    colonna
    
  }) %>% purrr::compact()->listaColonne
  
  
  unlist(listaColonne)
  
}#trovaColonneVuote



eliminaColonneVuote<-function(x){    
  
  trovaColonneVuote(x)->colonne
  
  if(length(colonne)) x[,-colonne]->x
  
  x
  
}#eliminaColonneVuote

riempiColonneVuote<-function(x){
  
  trovaColonneVuote(x)->colonne
  
  if(!length(colonne)) return(x)
 
  for(cc in 1:length(colonne)){
    x[[colonne[cc]]]<-">>"
  }
  
  x
  
}#fine riempiColonneVuote




trovaRigheIntestazioni<-function(x){

  purrr::map(1:nrow(x),.f=function(rr){
    
    str_replace_all(paste0(x[rr,1:ncol(x)],collapse = "")," {1,}","")->stringa
    
    if(grepl("GFMAMGLASOND.*GFMAMGLASOND",stringa)) return(rr)
    if(grepl("GFMAMGLASOND.{1} *",stringa)) return(rr)
    
    return()
    
  })->righeIntestazioni
  
  purrr::compact(righeIntestazioni) %>% unlist->righeIntestazioni

}#trovaRigheIntestazioni


pulisciColonnaConGiorni<-function(z){
  
  rep(FALSE,31)->vettore
  
  for(ii in 1:31){
    str_detect(z[ii+1],pattern=paste0("^",ii," "))->ris
    if(ris) vettore[ii]<-TRUE
  }#fine ciclo for
  
  
  if(all(vettore)){
    #str_remove servenel caso in cui la colonna che ingloba i giorni riporti una delle lettere della parola Giorno
    #Ad esempio "o G F": la colonna contiene i mesi di Gennaio e Febbraio e la colonna dei giorni. Se non elimino "o"
    #successivamente separate trovera' tre nomi per le nuove colonne e quindi assegnera' Gennaio a una colonna connome "o"
    # e Febbraio a una colonna Gennaio!
    nuovaColonna<-c(str_remove(z[1],"[giorno]"),rep("",31))
    for(ii in 1:31){
      str_remove(z[ii+1],pattern=paste0("^",ii," "))->nuovaColonna[ii+1]
    }#fine ciclo for
    
    return(nuovaColonna)
    
  }#fine if su all(vettore)
  
  NULL
  
}#fine pulisciColonnaGiorni


trovaColonnaGiorni<-function(x){
  
  eliminaColonneVuote(x)->x


  #Se non trvo la colonna dei giorni in questo modo significa che la colonna dei giorni sta inglobata o nella colonna di
  #dicembre della tabella a sinistra o nella colonna di gennaio della tabella a destra
  
  #La funzione pulisciColonnaConGiorni verifica se la colonna di dicembre o gennaio contiene le stringhe da 1 a 31, 
  #toglie queste stringhe dei giorni e restituisce la colonna priva dei giorni. Se pulisciColonnaConGiorni invece restituisce
  #NULL vuol dire che la colonna non contiene i giorni
  
  tryCatch({
    stopifnot(sum(as.numeric(x[2:32,colonna][[1]]))==sum(1:31))
    x[1,colonna]<-"d"
    x
  },error=function(e){
    NULL
  })->out
  
  if(is.null(out)){
    
    grep("D",x[1,])->colonneDicembre
    length(colonneDicembre)->quantiDicembre
    
    colonneDicembre[1]->primoDicembre
    ncol(x)->numeroColonne
    x[,c(1:primoDicembre)]->tabella1
    
    pulisciColonnaConGiorni(tabella1[[primoDicembre]])->nuovaColonna
    if(!is.null(nuovaColonna)){
      tabella1[[primoDicembre]]<-nuovaColonna
    }
    
    if(quantiDicembre==2){
      colonneDicembre[2]->secondoDicembre
      x[,c((primoDicembre+1):secondoDicembre)]->tabella2
      pulisciColonnaConGiorni(tabella2[[1]])->nuovaColonna
      if(!is.null(nuovaColonna)){
        tabella2[[1]]<-nuovaColonna
      }
      

    }#if quantiDicembre==2  
    
    #tabella1 e tabella2 sono le tabelle a sinistra e a destra. In una delle due tabelle ho tolto le stringhe dei giorni
    #Creo una nuova tabella in cui affianco tabella1 + giorni +tabella2
    bind_cols(tabella1,c("d",1:31))->tabella1
    
    tryCatch({
      
      bind_cols(tabella1,tabella2)
      
    },error=function(e){
      
      tabella1
      
    })->x
    
    
  }else{
    x
  }
  
  x
  
}#trovaColonneGiorni


cercaNomiStazioni<-function(x){
  
  nrow(x)->numeroRighe
  
  #I nomi delle stazioni generalmente sono posizionati nella riga 1 dell'intestazione, ma non si pu dare per scontato
  #quindi bisogna fare un ciclo sul numero di righe tra 1:nHeader, contare il numero delle colonne. Se abbiamo due o tre
  #colonne allora abbiamo trovato la riga con i nomi delle stazioni. Se invece il numero delle colonne ==0 oppure
  #abbiamo una sola colonna (in tal caso eliminaColonneVuote restituisce un vettore di un unico char e non un tibble) il
  #comando ncol genera un errore.
  for(hh in 1:numeroRighe){
    x[hh,]->nomiStazioni
    eliminaColonneVuote(x=nomiStazioni)->nomiStazioni
    
    tryCatch({
      ncol(nomiStazioni)
    },error=function(e){
      NULL
    })->numeroColonne
    
    if(!is.null(numeroColonne) && (numeroColonne>1)) break;
    if(numeroColonne==1){
      if(nomiStazioni[[1]]!="" & nomiStazioni[[1]]!="G" & nomiStazioni[[1]]!="i") break;
    }
  }
  
  nomiStazioni[nchar(nomiStazioni)>1]
  
}#fine cercaNomiStazioni

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
      unlist(str_split(str_trim(as.character(mytibble[1,1]),side ="both"),pattern=" "))->intestazioneColonna
      round(runif(n=length(intestazioneColonna)),5)->acaso
      paste0(intestazioneColonna,acaso)->nuoviNomi
    }else{
      firstRow<-1
      c("X1","X2")->nuoviNomi
    }  
    
    length(unlist(str_split(str_trim(mytibble[[1]][1],side="both"),pattern=" +")))->numeroDiMesiNellaColonna
   
    if(numeroDiMesiNellaColonna>1){
        while(1>0){
          
          purrr::map(str_split(str_trim(mytibble[[1]][2:32]),pattern=" +"),.f=length) %>% unlist->numeroDiDatiNelleCelleDellaColonna
          
          #3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 2
          #il primo 3 si riferisce ad esempio ai mesi di G L A
          #poi ho una sfilza di 2 e poi una sfilza di tre...
          #questo succede quando ho mesi di dati mancanti. In questo caso i dati mancanti non vengono indicati come ">>"
          #ma come colonne vuote....a pagina 99 dell'Annale 2013 la stazione di Ripalta presenta i mesei da Gennaio a Giugno
          #senza dati (colonne vuote) ma poi Giugno comincia a met mese. tabulizer accorpa i mesi di Giugno Luglio e Agosto
          #I giorni in cui Giugno non ha dati avra' solo i due valori per luglio e agosto. I giorni in cui Giugno ha dati
          #la colonna avr tre valori. In Questa situazione dove ho due valori, prima di dividere la colonna mediante "separate"
          #devo fare inmodo di avere tre dati in tutti le celle altrimenti separate (doveho due valori) li assegna (erroneamente)
          #a giugno e luglio (lasciando NA ad agosto) quando invece e' Giugno che ha una parte di giorni NA e luglio e Agosto sono pieni.
          which((numeroDiMesiNellaColonna-numeroDiDatiNelleCelleDellaColonna)==1)->qualiCelle  
          
          if(length(qualiCelle) && any(qualiCelle<29) ){ 

            str_c(">> ",mytibble$temp[qualiCelle+1])->mytibble$temp[qualiCelle+1]
          }else{
            break
          }
          
        }#fine while
      
    }#fine if
    
    
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
    
    #Una delle celle adiacenti a x[1,colonna] e' vuota?
    #Si: allora faccio coalesceColonne
    #No:si tratta di una colonna che non era tutta vuota (quindi non e' stata tutta riempita con >>)
    #ma di una colonna con una serie di valori vuoti e che poi comincia ad avere valori validi.
    #In questo caso non devo fare coalesceColonne
    
    #Celle vuote sono anche le celle che ho riempito con ">>" quindi per verificare quali sono vuote devo
    #convertire ">>" in "" e poi contare nchar 
    
    tryCatch({
      x[1,colonna-1]->cella
      str_replace(cella,">>","")->cella
      nchar(cella)
    },error=function(e){
      NULL
    })->NCOL1
    
    tryCatch({
      x[1,colonna+1]->cella
      str_replace(cella,">>","")->cella
      nchar(cella)
    },error=function(e){
      NULL
    })->NCOL2
    
   
    #Ho una colonna adiacente con la cella vuota? NO: allora non devo andare avanti
  #  if(!any(c(NCOL1,NCOL2)==0)) break; <-ORIGINALE 3 dicembre
    if((NCOL1==0)||(NCOL2==0)) break;
    
    
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
  
  
  #cerco nuovamente la colonna dei giorni e quella dei mesi (potrebbe succedere di arrivare a questo punto e avere due colonne dei giorni)
  #Inserisco anche la X perche con coalesceColonne potrei aver introdotto colonne con nome X  
  which((1:ncol(x)) %in% grep("[XGFMALSONDd]",names(x),ignore.case = FALSE))->colonna 
  x[,colonna]->x 
  
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
  if(length(qualiVuote)) penultimaRiga[qualiVuote]<-NA
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
    
    str_replace(colonna,"--","0.0")->colonna
    str_replace(colonna,"-","0.0")->colonna
    str_replace(colonna,",",".")->colonna
    str_replace(colonna,">>","NA")->colonna    
    as.numeric(colonna)

  })  
  
  
}#numeriche


creaTabelle<-function(x,anno){
  
  aggiustaTabelle(x=x,replaceHeader = TRUE)->y

  #Eliminiamo eventuali colonne vuote che non corrispondono ad alcun mese dell'anno: in alcuni casi
  #succede che a questo punto il data.frame contiene colonne vuote in eccesso. Queste colonne vuote vanno eliminate
  which(!grepl("^[dGFMALSOND]",names(y)))->colonneForseDaEliminare
  
  if(length(colonneForseDaEliminare)){ 
    
    y[,colonneForseDaEliminare]->z  
    #le colonne che ho trovato sono vuote o servono per coalesceColonne?    
    trovaColonneVuote(z)->qualiColonneVuote
    
    if(!is.null(qualiColonneVuote)){ 
    
      colonneForseDaEliminare[qualiColonneVuote]->TOGLI 
      y[,-c(TOGLI)]->y   
      
    }else{ 
      
      if(length(colonneForseDaEliminare)==1){ 
        
      #per non far fallore sum prima di tutto devo convertire la colonna in numerica
      #I valori non numerici vengono convertiti in NA. Se gli NA sono pochi allora
      #potrebbe essere che questa colonna in piu' sia un duplicato della colonna dei giorni e va tolta
      #Se invece la maggior parte dei valori sono NA, allora non e' una colonna numerica e non procedo con
      #sum()=sum(1:20)
        
        as.numeric(y[[colonneForseDaEliminare]][1:20])->vettoreNumerico
        which(is.na(vettoreNumerico))->quantiNA
        if(length(quantiNA)<=2){
        
            #questa colonna in piu' e' un'altra colonna dei giorni? Testiamola sulle prime 20 celle  
            if(sum(vettoreNumerico,na.rm=TRUE)==sum(1:20)){ 
      
              y[,-c(colonneForseDaEliminare)]->y
              
              
            }else{ 
              
              warning("Ho una colonna in piu' che non dovrei avere e non so che fare")  
              browser()          
              
            } 
          
        }#length(quantiNA)<=2 
        
        
      }else{ 
      
        warning("Ho colonne in piu' che non dovrei avere e non so che fare")  
        browser()
      }
      
      
    }
    
  }#fine if 
  

  
  #Aquesto punto il data.frame y se contiene delle colonne vuote (tuttevuote) vanno riempite con ">>"
  #prima di utilizzare coalesceColonne
  
  riempiColonneVuote(x=y)->y
  
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

