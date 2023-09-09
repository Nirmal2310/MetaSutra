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
  title = "MetaShiny",
  source("ui-tab-intro.R", local = TRUE)$value,
  source("ui-tab-input.R", local = TRUE)$value,
  source("ui-tab-ARG-cohort.R", local = TRUE)$value,
  source("ui-tab-ARG-abundance-analysis.R", local = TRUE)$value,
  source("ui-tab-Alpha-diversity-analysis.R", local = TRUE)$value,
  source("ui-tab-beta-diversity-analysis.R", local = TRUE)$value,
  source("ui-tab-help.R", local = TRUE)$value,
  source("ui-tab-conditions.R", local = TRUE)$value,
  p(br()),
  p(br()),
  p(br()),
  p(br()),
  footer=p(hr(), p(("ShinyApp created by Nirmal Singh Mahar, Anshul Budhraja,
                                                  Suman Pakala, S.V. Rajagopala* and
                                                  Ishaan Gupta*"), align = "center", width=2),
           p(("Copyrigth (C) 2023, code licensed under GPLv3"), align="center", width=2),
           p(("Code available on Github:"), a("https://github.com/Nirmal2310/MetaShiny",
                                              href="https://github.com/Nirmal2310/MetaShiny"),
             align="center",width=2),
           )
  )