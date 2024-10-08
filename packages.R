required = c("shiny", "shinyFiles", "markdown", "shinyBS", "validate", "tidyverse",
             "stringr", "ggpubr", "dendextend", "BiocManager", "vegan", "grid",
             "ggforce", "gridExtra")
sapply(required, function(x){
  if(!require(x, character.only = TRUE)){
    install.packages(x); library(x,  character.only = TRUE)}
  else{library(x, character.only = TRUE)}
  }
)

if(!require("ComplexHeatmap", character.only = TRUE)){
  BiocManager::install("ComplexHeatmap"); library("ComplexHeatmap", character.only = TRUE)
}else{
  library("ComplexHeatmap", character.only = TRUE)
}