#Starter med å henter inn biblioteker: 
library(PxWebApiData)
library(tidyr)
library(klassR)
library(MASS)
#Viser hvordan data er hente fra Statistikkbanken og tilrettelegge for kurset.
antall_konf <- ApiData(12026, KOKkommuneregion0000  = TRUE ,  ContentsCode =c("KOSkonfirmanter0000" ,"KOSpersoner150000","KOSdoepte0000","KOSfodde0000"),Tid = c( -1))


ant_konf<-antall_konf[[2]]

#Omgjør fra stående form på data til tabell
konf <- spread(ant_konf, ContentsCode, value )

#Renamer variabler
names(konf)[names(konf) == "KOSkonfirmanter0000"] <- "konfirmanter"
names(konf)[names(konf) == "KOSpersoner150000"] <- "personer15"
names(konf)[names(konf) == "KOSdoepte0000"] <- "dopte"
names(konf)[names(konf) == "KOSfodde0000"] <- "fodde"
names(konf)[names(konf) == "KOKkommuneregion0000"] <- "region"

#Trenger å sammenligne med forrige år, så gjentar med forrige år Tid = c(-2):
# Henter inn forrige år
antall_konf_1 <- ApiData(12026, KOKkommuneregion0000  = TRUE , ContentsCode =c("KOSkonfirmanter0000" ,"KOSpersoner150000","KOSdoepte0000","KOSfodde0000"), Tid = c( -2))


ant_konf_1<-antall_konf_1[[2]]

#Omgjør fra stående form til tabellform
konf_1 <- spread(ant_konf_1, ContentsCode, value )

#Renamer variabler
names(konf_1)[names(konf_1) == "KOSkonfirmanter0000"] <- "konfirmanter_1"
names(konf_1)[names(konf_1) == "KOSpersoner150000"] <- "personer15_1"
names(konf_1)[names(konf_1) == "KOKkommuneregion0000"] <- "region"
names(konf_1)[names(konf_1) == "Tid"] <- "Tid_1"
names(konf_1)[names(konf_1) == "KOSdoepte0000"] <- "dopte_1"
names(konf_1)[names(konf_1) == "KOSfodde0000"] <- "fodde_1"

#Setter to siste perioder sammen 
konfdat <- merge(konf,konf_1,by="region")


#Bruker Klass til å hente ut bare kommuner og legge på kostragrupper: 
#Henter kommunedata 
sn <- GetKlass(klass = 131, date = "2019-01-01") 

#Selekterer ut kode og navn på kommune
kom<-sn[,c("code","name")]

#Renamer kommunekode til region
names(kom)[names(kom) == "code"] <- "region"

#Slår sammen filene slik jeg bare får kommuner
kirkedata <- merge(konfdat,kom, by="region")

#Legger på klassifiseringen kostragruppe på datasettet
kirkedata$kostragr <- ApplyKlass(kirkedata$region, klass = 131, output = "code",
                                 date = c("2019-01-01"), correspond = 112)
