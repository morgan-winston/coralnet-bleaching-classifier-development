################################################################################
# Very Beta Code Written by Tom Oliver: thomas.oliver@noaa.gov to facilitate 
# "stratified" (i.e. Non-random, user-defined) point annotation for
#ingestion to CoralNet. This code is useful, but 'hacky', 'kludgy' and otherwise 
#inelegant but hopefully functional. Please email any questions.
################################################################################
#This code functions similarly to "Point_Annotator_Raster_v1.0.R"
#If a point was mislabeled, the annotator will need to manually fix the error
################################################################################

rm(list=ls())
library(raster)
library(grid)

fpath="C:/Users/jon.ehrenberg/WORK/Projects/FY22/CoralNet/Coral Bleaching Classifier/Bleaching Classifier/High Bleaching Sites/ESD/MAI/MAI-B2482/"

lf=list.files(fpath,pattern = "(.JPG|.jpg|.JPEG|.jpeg)",full.names = F)
lff=list.files(fpath,pattern = "(.JPG|.jpg|.JPEG|.jpeg)",full.names = T)

r=stack(lff[1])
plotRGB(r)
text(dim(r)[2]/2,dim(r)[1]/2,
     "Welcome To Point Annotator - Point Review",
     col="white",cex=3)
Sys.sleep(3)
plotRGB(r)
text(dim(r)[2]/2,dim(r)[1]/2,
     "Change Plot Window Size Until \nThere Are No White Edges,\nOr Point Addresses Will Be Wrong!!!\n Hit Return In the Console When Done.",
     col="white",cex=3)
readline("Click on Console and Hit Return to Proceed...")
dev.off()
Sys.sleep(1)

#make sure to replace "_____.csv" with file name of all annotations .csv file

AnnFile=read.csv(paste0(fpath,"MAI-B2482_2019_All_R_Annotations_2021-12-16.csv"))
dotcol=c("black","green","grey75")
names(dotcol)=c("*UNK","*CORAL","*CORAL_BL")
for(i in 1:length(lff)){
  print(paste0("Loading Image ",i," of ",length(lff)))
  r=stack(lff[i])
  plotRGB(r)
  
  thisimann=subset(AnnFile,Name==lf[i])
  points(thisimann$Column,thisimann$Row,col=dotcol[thisimann$Label],pch=21,cex=3,lwd=2)
  In=readline("Go to Next Image?")
}




