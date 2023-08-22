tabPanel("Introduction",
         fluidRow(
           column(2, wellPanel(
             h4("Introduction"),
             a("Features", href="#Features"),br(),
             a("Data Formats", href="#DataFormat"),br(),
             a("Additional Information", href="#help"),br()
           )
           ),
           column(8, includeMarkdown("Tabs/Instructions.md"))
         )
  
)