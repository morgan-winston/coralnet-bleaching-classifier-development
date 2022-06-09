#######################################################################
# Start By "Sourcing" File:  Code Menu, "Source, Ctrl+Shift+S"
#######################################################################
# Very Beta Code Written by Tom Oliver: thomas.oliver@noaa.gov to faciliate 
# "stratified" (i.e. Non-random, user-defined) point annotation for
#ingestion to CoralNet. This code is useful, but 'hacky', 'kludgy' and otherwise 
#inelegant but hopefully functional. Please email any questions.
#######################################################################

rm(list=ls())
library(raster)
library(grid)
library(lubridate)

fpath_in="C:/Users/jon.ehrenberg/WORK/Projects/FY22/CoralNet/Coral Bleaching Classifier/Bleaching Classifier/High Bleaching Sites/ESD/MAI/MAI-B2482/"
fpath_out="C:/Users/jon.ehrenberg/WORK/Projects/FY22/CoralNet/Coral Bleaching Classifier/Bleaching Classifier/High Bleaching Sites/ESD/MAI/MAI-B2482/"
lf=list.files(fpath_in,pattern = "(.JPG|.jpg)",full.names = F)
lff=list.files(fpath_in,pattern = "(.JPG|.jpg)",full.names = T)

r=stack(lff[1])
rasp=dim(r)[1]/dim(r)[2]
plotRGB(r)
text(dim(r)[2]/2,dim(r)[1]/2,
     "Welcome To Point Annotator",
     col="white",cex=3)
Sys.sleep(2)
plotRGB(r)
text(dim(r)[2]/2,dim(r)[1]/2,
     "Change Plot Window Size Until \nThere Are No White Edges,\nOr Point Addresses Will Be Wrong!!!\n Hit Return In the Console When Done.",
     col="white",cex=3)
readline("Click on Console and Hit Return to Proceed...")
dev.off()
Sys.sleep(1)

All_Out=NULL
dotcol=c("grey75","green","red")
borcol=c("white","white","black")
for(i in 1:length(lff)){
  Img_Out=NULL
  if(dev.cur()!=1) {dev.off()}
  print(paste0("Loading Image ",i," of ",length(lff)))
  r=stack(lff[i])
  plotRGB(r)
  #print("About to query you for input - this is painfully slow, so be patient...:")
  KEEP_GOING=TRUE
  while(KEEP_GOING){
    print("Click on your point:")
    pnt=grid.locator(unit="npc")
    X=as.numeric(substr(pnt$x,1,nchar(pnt$x)-3))
    Y=as.numeric(substr(pnt$y,1,nchar(pnt$y)-3))
    row_sz=dim(r)[1]
    col_sz=dim(r)[2]
    row_px=round(row_sz*Y,0) # Invert this measurement
    col_px=round(col_sz*X,0)
    out=data.frame(Name=lf[i],
                   Row=row_sz-row_px,
                   Column=col_px,
                   Row_plot=row_px,
                   #Column_inv=col_sz-col_px,
                   Label="")
    points(out$Column,out$Row_plot,pch=21,col="white",cex=3,lwd=3)#,bg=dotcol[lab]
    
    ### IF YOU WANT TO CHANGE THE LABELSET
    repeat{
      lab=readline("Input Label or Skip? [1]:*UNK [2]:*CORAL [3]:*CORAL_BL [ANY]:Next Image: ")
      if (lab!="" ) {break} 
    }
    
    lab=as.numeric(lab)
    if(is.na(lab)){lab=4}
    if(lab==1){out$Label="*UNK"
    }else if(lab==2){out$Label="*CORAL"
    }else if(lab==3){out$Label="*CORAL_BL"
    }else{KEEP_GOING=F}
    
    if(lab %in% 1:3){
      Img_Out=rbind(Img_Out,out[,c("Name","Row","Column","Label")])
      points(out$Column,out$Row_plot,pch=21,col=dotcol[lab],cex=3,lwd=3)#,bg=dotcol[lab]
      print(out)
      }
  }
  print("Skipping to next image. This image's annotations:")
  print(subset(All_Out,Name==lf[i]))
  TimeStamp=now()
  print("Writing Out Single File Points:")
  write.csv(x = Img_Out,
            file = paste0(fpath_out,"R_Annotations_",substr(lf[i],1,nchar(lf[i])-4),"_ANN",TimeStamp,".csv"),row.names = F)
  All_Out=rbind(All_Out,Img_Out)
}
head(All_Out)
TimeStamp=now()
print(paste0('Writing out Full Data Frame to: ',fpath_out,"/All_R_Annotations_ANN",TimeStamp,".csv"))

Site_Name=substr(lf[i],1,nchar(lf[i])-7)
write.csv(x = All_Out,file = paste0(fpath_out,Site_Name,"_All_R_Annotations_ANN",TimeStamp,".csv"),row.names = F)
