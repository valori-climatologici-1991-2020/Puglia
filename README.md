# Puglia

Valoci climatologici per la regione Puglia.

### Dati HisCentral

Su HisCentral la Puglia è presente con un solo anno (il 2004).

### Annali

Sul [sito web del Centro Funzionale della regione Puglia](https://protezionecivile.puglia.it/centro-funzionale-decentrato/rete-di-monitoraggio/annali-e-dati-idrologici-elaborati/) sono disponibili gli Annali. Per il periodo 1997 - 2019 si tratta di documenti in formato pdf (ovvero non si tratta di scansioni, ma di vere e proprie tabelle numeriche).

#### Temperatura

Alcuni file pdf presentano tabelle con strane formattazioni che creano problemi al codice R scritto per leggere le tabelle di temperatura (anni con tabelle problematiche per la temperatura: 1999, 2007, 2008, 2011 e 2013). Sono invece stati estratti senza problemi gli anni restanti per il periodo 1997 - 2019. 
Gli anni 1999, 2007, 2008 e 2011 fanno parte del set di dati inviati dal Centro Funzionale (vedi sotto), quindi gli errori di formattazione delle tabelle nei file pdf possono essere ignorati. L'anno 2013 invece (non inviato dal Centro Funzionale) ha richiesto una revisione e correzione manuale delle tabelle prodotte mediante R.

Il 2014 e' un pdf particolare che non si e' riuscito a elaborare quindi i dati del 2014 sono tutti NA.

#### Precipitazione

Per la lettura delle tabelle di precipitazione si e' usato un approccio diverso da quello usato per le serie di temperatura (basato sul pacchetto R `tabulizer`).
Ulteriori informazioni sulla lettura dei dati di temperatura e di precipitazione dai pdf degli Annali sono [qui disponibili](./annali/annali_elaborazione.md).

### Dati Centro Funzionale

Il Centro Funzionale ha inviato i dati degli Annali in formato Excel per il periodo 1995 - 2012 nel 2016 (richiesta avvenuta mediante modulo inviato via fax/mail). Le coordinate delle stazioni di questi dati sono state ricevute (su richiesta) in data 21 Aprile 2016.

### Confronto dati Annali e dati Centro Funzionale

Gli anni comuni tra i dati del Centro Funzionale e i dati degli Annali sono stati confrontati (associando mediante agrep il nome della stazione che compare nell'Annale con il nome della stazione che compare nel file di Anagrafica). Il confronto e' stato fatto graficamente (scatterplot e linea bisettrice del primo quadrante). 

Il confronto ha evidenziato che si tratta degli stessi dati :v:.

Sintetizzando:
- per il periodo 1995 - 2012 si possono usare i dati del Centro Funzionale;
- dal 2013 in poi si possono utilizzare i dati estratti dagli Annali.


### Stato dei dati, gennaio 2021

- Sistemate l'anagrafica delle stazioni. Le coordinate, le quote e i codici delle stazioni sono state ricavate dal sito: [http://93.57.89.4:8081/temporeale/meteo/stazioni]

- Le seguenti stazioni sono state eliminate dal dataset dei dati:

| SiteID | Nome |
|--------|------|
| 63     | Lacedonia |   
| 78     | MASSERIA_BRELA_II_POD |
| 79     | MASSERIA_CHIANCARELLO |
| 80     | Masseria cicchetto |
| 83     | MASSERIA_POSTA_DELLE_CAPRE |

Si tratta di stazioni che comparivano nelle vecchie forniture dati o su HisCentral (?) ma di cui non abbiamo coordinate e che non compaiono nella pagina web 
dell'anagrafica delle stazioni della Puglia del Centro Funzionale. In ogni caso si tratta di serie che sono interrotte.

- I dati 2020 e 2014 sono stati acquisiti dall'archivio del dati giornalieri della Puglia. I restanti dati sono stati ricavati rielaborando gli Annali e sulla base dei dati forniti dal Centro Funzionale nel 2016.

- Per 4 stazioni i dati dal 2007 al 2020 sono stati ricavati dall'archivio dei dati giornalieri del Centro Funzionale per colmare i buchi dati dati.


