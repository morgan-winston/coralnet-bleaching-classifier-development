library(tidyverse)
library(patchwork)

v2=read.csv("C:/Users/Thomas.Oliver/WORK/Projects/FY22/CoralNet/HawaiiBleachingv2_appended_R_annotations_2022-01-10.csv")
test_data=read.csv("C:/Users/Thomas.Oliver/WORK/Projects/FY22/CoralNet/All test sites-Test Results.csv")

###Generate V2 Site Names from V2 Photo Names
#trim X characters from back end of photo names (a bunch of different cases...)
SiteStrNMinus=rep(7,nrow(v2))
Shallow_i=grep(pattern = "Shallow",v2$Name)
SiteStrNMinus[Shallow_i]=12
HAW_B4313_i=grep(pattern = "HAW_B4313",v2$Name)
SiteStrNMinus[HAW_B4313_i]=9
HAW__B4313_i=grep(pattern = "HAW-B4313",v2$Name)
SiteStrNMinus[HAW_B4313__i]=12
BleachingTest1_i=grep(pattern = "PMNM_2014_bleaching_test",v2$Name)
SiteStrNMinus[BleachingTest1_i]=8
BleachingTest2_i=grep(pattern = "PMNM_2014_bleaching_test \\(10",v2$Name)
SiteStrNMinus[BleachingTest2_i]=9
SIO_1lz_i=grep(pattern = "...-SIO-..._..JPG",v2$Name)
SiteStrNMinus[SIO_1lz_i]=6
TNC_i=grep(pattern = "TNC",v2$Name)
SiteStrNMinus[TNC_i]=13

#v2$Name[grep(pattern = "B4313",x=v2$Name)]
#Actually make the site names
v2$Site=substr(v2$Name,1,nchar(v2$Name)-SiteStrNMinus)
v2$Site[v2$Site=="HAW_B4313"]="HAW-B4313_2019"
#Decide Which Sites Are Which
uSite_SnRTrain=c(
  "LAN-B1824_2019",
  "KUR-B006_2019",
  "KUR-B010_2019",
  'MAI-B2482_2019',
  'MAI-B2488_2019',
  'MAI-B4002_2019',
  "MAI-B4005_2019",
  "MAI-B4037_2019",
  "MAI-B4039_2019",
  "Site26Shallow_2015",
  "OrchidShallow2015",
  "OAH-B3078_2019", #(initially uploaded as a test source, but the annotations were corrected by human)
  "LeahouShallow2015", #(initially uploaded as a test source, but the annotations were corrected by human)
  "M12_KBay2015"#"KaneoheBayMarker12"# (initially uploaded as a test source, but the annotations were corrected by human)
)
set.seed(2599)
uSites_All=sort(unique(c(v2$Site,uSite_SnRTrain)))
Nsite_Total=length(uSites_All)
Nsite_SnRTrain=length(uSite_SnRTrain)
uSites_NoStrat=uSites_All[-na.omit(pmatch(uSite_SnRTrain,uSites_All))]
Nsite_NoStrat=length(uSites_NoStrat)
Nsite_Test=round(Nsite_Total*.2,0)
uSite_Test=uSites_NoStrat[sample(1:Nsite_NoStrat,Nsite_Test,replace=F)]
uSite_RandTrain=uSites_NoStrat[-match(uSite_Test,uSites_NoStrat)]
Nsite_RandTrain=length(uSite_RandTrain)

SiteCat=rbind(data.frame(Site=uSite_SnRTrain,Category="Stratified and Random Training",stringsAsFactors = F),
              data.frame(Site=uSite_RandTrain,Category="Only Random Training",stringsAsFactors = F),
              data.frame(Site=uSite_Test,Category="Testing",stringsAsFactors = F))
SiteCatSort=SiteCat[order(SiteCat$Site),]
c(Nsite_Total,Nsite_SnRTrain,Nsite_RandTrain,Nsite_Test)

write.csv(x = SiteCat,
          file = "C:/Users/Thomas.Oliver/WORK/Projects/FY22/CoralNet/BleachingV3_SiteCategories.csv",row.names = F)
write.csv(x = SiteCatSort,
          file = "C:/Users/Thomas.Oliver/WORK/Projects/FY22/CoralNet/BleachingV3_SiteCategoriesSorted.csv",row.names = F)

Site_Sum=test_data %>% 
  group_by(Site) %>% 
  summarize(
    Human_Pb=length(which(Human.Annotation=="*CORAL_BL"))/
      length(which(Human.Annotation%in%c("*CORAL","*CORAL_BL"))),
    Human_Cover=length(which(Human.Annotation%in%c("*CORAL","*CORAL_BL")))/
      length(which(Human.Annotation%in%c("*CORAL","*CORAL_BL","*UNK"))),
    Human_N=length(which(Human.Annotation%in%c("*CORAL","*CORAL_BL","*UNK"))),
    CN_Pb=length(which(Machine.suggestion.1=="*CORAL_BL"))/
      length(which(Machine.suggestion.1%in%c("*CORAL","*CORAL_BL"))),
    CN_Cover=length(which(Machine.suggestion.1%in%c("*CORAL","*CORAL_BL")))/
      length(which(Machine.suggestion.1%in%c("*CORAL","*CORAL_BL","*UNK"))),
    CN_N=length(which(Machine.suggestion.1%in%c("*CORAL","*CORAL_BL","*UNK")))#,
#    CN_Conf1_Md=median(Machine.confidence.1)
  )

Point_Accuracy=test_data %>% summarize(
  UNK_acc=length(intersect(which(Human.Annotation=="*UNK"),which(Machine.suggestion.1=="*UNK")))/
                   length(which(Human.Annotation=="*UNK")),
  CORAL_acc=length(intersect(which(Human.Annotation=="*UNK"),which(Machine.suggestion.1=="*UNK")))/
    length(which(Human.Annotation=="*UNK")),
  CORAL_BL_acc=length(intersect(which(Human.Annotation=="*UNK"),which(Machine.suggestion.1=="*UNK")))/
    length(which(Human.Annotation=="*UNK"))
)

CC=ggplot(Site_Sum,aes(Human_Cover,CN_Cover))+geom_point()+geom_abline(slope = 1,intercept = 0)+theme_bw()+geom_label(aes(label=Site),size=2)
Pb=ggplot(Site_Sum,aes(Human_Pb,CN_Pb))+geom_point()+geom_abline(slope = 1,intercept = 0)+theme_bw()+geom_label(aes(label=Site),size=2)
CC+Pb
