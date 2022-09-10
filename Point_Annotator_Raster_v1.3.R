#######################################################################
##### Stratified Point Annotator ######
#Very Beta Code Written by Tom Oliver: thomas.oliver@noaa.gov to faciliate 
# "stratified" (i.e. Non-random, user-defined) point annotation for
#ingestion to CoralNet. This code is useful, but 'hacky', 'kludgy' and otherwise 
#inelegant but hopefully functional. Please email any questions.
#######################################################################
# Start By: 
#(1) Setting In File Path to your images (line 21) and out file path for annotations (22)
# if you use "./" format, you don't need to input full file paths, as the code will know 
# which directory contains the script file, and all paths will be relative to that directory
#(2) Set Up your labelset (23), and colors (24) for the interactive plot 
#(3) Then "Source" the File:  Code Menu, "Source, Ctrl+Shift+S"
#######################################################################
rm(list=ls())
library(raster)
library(grid)
library(lubridate)
library(rstudioapi)

### USER INPUT
fpath_in="./Images/" #./ should work if setwd code (lines 26-27 is functioning)
fpath_out="./Annotations/"
LABELSET=c("*UNK","*CORAL","*CORAL_BL")
LABELSET_COL=c("grey75","green","red") #Colors of Points. Manual or: hcl.colors(length(LABELSET))

#Get Working Directory Set up
HomeDirectory=dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(HomeDirectory)


### PREP LABELSET TO RUN / prompt
if(length(LABELSET)!=length(unique(LABELSET))){
  print("DUPLICATES IN YOUR LABELSET. REMOVING THEM, BUT SORT ORDER MAY CHANGE. YOU SHOULD LOOK INTO THAT")
  LABELSET=unique(LABELSET)
}
ConsW=options("width")$width
LABELSET_PROMPT="Input Label or Skip?"
Nlabels=length(LABELSET)
for(i in 1:Nlabels){
  LastLineLength=nchar(tail(strsplit(LABELSET_PROMPT,"\n")[[1]],1))
  NextLabel=paste0(" [",i,"]:",LABELSET[i])
  if((LastLineLength+nchar(NextLabel))>ConsW){
    LABELSET_PROMPT=paste0(LABELSET_PROMPT,"\n",NextLabel)
  }else{
    LABELSET_PROMPT=paste0(LABELSET_PROMPT,NextLabel)
  }
}
LABELSET_PROMPT=paste0(LABELSET_PROMPT," [-999]:End All Annotation [0]:Skip to Next Image: ")
if(nchar(LABELSET_PROMPT)>256){cat("Your Labelset prompt will be too long to show every time.\nYour numbering should work, but you won't prompt the user fully every point...")}

#Get file lists
lf=list.files(fpath_in,pattern = "(.JPG|.jpg)",full.names = F)
lff=list.files(fpath_in,pattern = "(.JPG|.jpg)",full.names = T)

#pull/plot the first image to welcome user
r=stack(lff[1])
rasp=dim(r)[1]/dim(r)[2]
plotRGB(r)
text(dim(r)[2]/2,dim(r)[1]/2,
     "Welcome To Point Annotator",
     col="white",cex=3)
Sys.sleep(2)
#Instruct the user on the window sizing weirdness. I'd love to update this issue, but Rstudio is a pain
plotRGB(r)
text(dim(r)[2]/2,dim(r)[1]/2,
     "Change Plot Window Size Until \nThere Are No White Edges,\nOr Point Addresses Will Be Wrong!!!\n Hit Return In the Console When Done.",
     col="white",cex=3)
readline("Click on Console and Hit Return to Proceed...")
dev.off()
Sys.sleep(1)

#Image Loop
All_Out=NULL #Build flexible output structure to collect annotations across images
for(i in 1:length(lff)){
  Img_Out=NULL #Build flexible output structure to collect annotations for this one image
  if(dev.cur()!=1) {dev.off()}
  
  #Show the current image
  print(paste0("Loading Image ",i," of ",length(lff)))
  r=stack(lff[i])
  plotRGB(r)
  #Get image sizes
  row_sz=dim(r)[1]
  col_sz=dim(r)[2]
  
  #Annotate Loop: Annotate this single image
  KEEP_GOING=TRUE
  MAX_PTS=10000;N_PTS=0
  while(KEEP_GOING&N_PTS<MAX_PTS){ #Keep collecting points until the user says they're done
    print("Waiiit for it... Click on your point:")
    pnt=grid.locator(unit="npc") #core interactivity call
    X=as.numeric(substr(pnt$x,1,nchar(pnt$x)-3)) #get address without "npc" at end
    Y=as.numeric(substr(pnt$y,1,nchar(pnt$y)-3))
    row_px=round(row_sz*Y,0) # Invert this measurement for CoralNet standard
    col_px=round(col_sz*X,0)
    thispoint=data.frame(Name=lf[i],
                         Row=row_sz-row_px, # Invert this measurement for CoralNet standard
                         Column=col_px,
                         Row_plot=row_px, # Leave this measurement for R plotting standard
                         Label="")
    points(thispoint$Column,thispoint$Row_plot,pch=21,col="white",cex=3,lwd=3)
    
    #Prompt for Labelset input
    repeat{
      lab=readline(prompt = LABELSET_PROMPT)
      if (lab%in%c(0:Nlabels,"-999")) {break} 
    }
    
    #convert Labelset input to an integer, suppress and re-instate warnings (about NA)
    optW=getOption("warn");options(warn=-1)
    lab=as.integer(lab);options(warn=optW)
    
    #Capture output in "thispoint" data.frame
    if(lab %in% 1:Nlabels){
      thispoint$Label=LABELSET[lab]
      Img_Out=rbind(Img_Out,thispoint[,c("Name","Row","Column","Label")])
      points(thispoint$Column,thispoint$Row_plot,pch=21,col=LABELSET_COL[lab],cex=3,lwd=3)
      print(thispoint)
    }else {KEEP_GOING=F}
    N_PTS=N_PTS+1
  }#Exit when KEEP_GOING==F or If there's an infinite loop (hard to imagine, but just in case)
  
  #Move to Next Image, output this image's data to the screen, an image file, and add to All_Out
  if(!is.null(Img_Out)){
    print("This image's annotations:")
    print(subset(Img_Out,Name==lf[i]))
    TimeStamp=sub(" ","T",gsub(pattern = ":",replacement = "_",now()))
    print("Writing Out Single Image's Points:")
    write.csv(x = Img_Out,
              file = paste0(fpath_out,"R_Annotations_",substr(lf[i],1,nchar(lf[i])-4),"_ANN",".csv"),row.names = F)
    All_Out=rbind(All_Out,Img_Out)
  }else{print("No Annotations to Print.")}

  #Full Exit Code
  if(lab%in%c(-999)){
    plotRGB(r)
    text(dim(r)[2]/2,dim(r)[1]/2,
         "Thank you for using Point Annotator",
         col="white",cex=3)
    Sys.sleep(2)
    break()
  }else{ 
    print("Skipping to next image.")
  }
  
}

#Write out File name
TimeStamp=sub(" ","T",gsub(pattern = ":",replacement = "_",now()))
print(paste0('Writing out Full Data Frame to: ',fpath_out,"All_R_Annotations_ANN",TimeStamp,".csv"))
write.csv(x = All_Out,file = paste0(fpath_out,"All_R_Annotations_ANN",TimeStamp,".csv"),row.names = F)
