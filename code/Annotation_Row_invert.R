################################################################################
#Beta Code Written by Courtney Couch:courtney.s.couch@noaa.gov 
#This script should be the final step before the annotations are ready
#to be uploaded to CoralNet.
#DO NOT use this script before "Point_Annotator_Review.R"
################################################################################
rm(list=ls())
library(tidyverse)
library(dplyr)
library(readr)

list_of_files <- list.files(path = "C:/Users/jon.ehrenberg/WORK/Projects/FY22/CoralNet/Coral Bleaching Classifier/Bleaching Classifier/High Bleaching Sites/ESD/MAI/MAI-B2482/",
                            recursive = TRUE,
                            pattern = "\\.csv$",
                            full.names = TRUE)

z <- readr::read_csv(list_of_files, id = "file_name")
head(z)
View(z)
z<-subset(z,select = -c(file_name))

#invert rows based on image height and add a new column to the CSV file
#image height can vary, so make sure the image height is correct
z$row.new<-2736-z$Row
head(z)

#delete the old column for the Row
z<-subset(z,select = -c(Row))
colnames(z)[4] <- "Row"


#reorder columns
z<- z[, c("Name", "Row", "Column", "Label")] 
head(z)

write.csv(z, file = "C:/Users/jon.ehrenberg/WORK/Projects/FY22/CoralNet/Coral Bleaching Classifier/Bleaching Classifier/High Bleaching Sites/Corrected R annotations/fixed_annotations_MAI-B2482.csv")


#Before uploading CSV to CoralNet, delete the numbers in the far left column