options(shiny.maxRequestSize = 100*1024^2)
source("packages.R")
print(sessionInfo())
server <- function(input, output, session) {
    source("server-input.R", local = TRUE)
    #source("server-pipeline.R", local = TRUE)
    source("server-arg-analysis.R", local = TRUE)
    source("server-arg-distribution.R", local = TRUE)
    source("server-alpha-diversity.R", local = TRUE)
    source("server-beta-diversity.R", local = TRUE)
  
}