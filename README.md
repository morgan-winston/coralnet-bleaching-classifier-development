coralnet-bleaching-classifier-development repository README

This repository contains code used to develop a CoralNet classifier to automate annotations of coral bleaching. There are four scripts included here:

1. "Point_Annotator_Raster_v1.0.R"
This script serves as a tool to generate additional targeted annotations, which can later be uploaded to CoralNet. The script currently contains labels for the CREP-HAWAII BLEACHING v3 CoralNet Source; however, it can be altered to work for other simple labelsets.
2. "Point_Annotator_Review.R"
As the name implies, the purpose of this script is to review the annotations created in "Point_Annotator_Raster_v1.0.R" and should be used immediately after. 
3. "Annotation_Row_invert.R"
The row coordinates of annotations generated in "Point_Annotator_Raster_v1.0.R" appear inverted when uploaded to CoralNet. Thus, "Annotation_Row_invert.R" was created to invert row values for each annotation. Please note that row values are dependent on image height, so if image height varies within an imageset, that will need to be taken into consideration (this is noted in the script as well).
4. "V3_Bleaching_Site_Sorting.R"
This script was created to randomly sort sites into two categories: Training sites (80%) and Test sites (20%). It should be mentioned that sites with annotations generated with "Point_Annotator_Raster_v1.0.R" were automatically classified as Training sites. The script itself can easily be altered to include sites with targeted annotations in the random sorting process.

* To learn more about the development of the NOAA coral bleaching classifier & instructions on creating your own, please visit: [insert link to admin report once published]
* To learn more about CoralNet, visit: https://coralnet.ucsd.edu/about/
