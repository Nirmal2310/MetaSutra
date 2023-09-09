required = c("shiny", "shinyFiles", "markdown", "shinyBS", "validate", "tidyverse",
             "stringr", "ggpubr", "dendextend", "ComplexHeatmap", "vegan", "grid",
             "ggforce")
sapply(required, function(x){
  if(!require(x, character.only = TRUE)){
    install.packages(x); library(x,  character.only = TRUE)}
  else{library(x, character.only = TRUE)}
  }
)


# library(shiny)
# library(shinyFiles)
# library(markdown)
# library(shinyBS)
# library(validate)
# library(tidyverse)
# library(stringr)
# library(ggpubr)
# library(dendextend)
# library(ComplexHeatmap)
# library(vegan)
# library(grid)
# library(ggforce)