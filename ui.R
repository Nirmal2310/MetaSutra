#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("packages.R")

ui <- navbarPage(

  theme = "bootstrap.min.css",
  title = "MetaSutra",
  source("ui-tab-intro.R", local = TRUE)$value,
  source("ui-tab-input.R", local = TRUE)$value,
  source("ui-tab-ARG-cohort.R", local = TRUE)$value,
  source("ui-tab-ARG-abundance-analysis.R", local = TRUE)$value,
  source("ui-tab-Alpha-diversity-analysis.R", local = TRUE)$value,
  source("ui-tab-beta-diversity-analysis.R", local = TRUE)$value,
  source("ui-tab-help.R", local = TRUE)$value,
  source("ui-tab-conditions.R", local = TRUE)$value
 )
