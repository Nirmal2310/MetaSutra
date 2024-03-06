tabPanel(
  "Input Data",
  fluidRow(
    column(
      width = 3,
      wellPanel(
        radioButtons(
          "data_file_type",
          "Use example data or upload the list",
          c("Example Data" = "examplelist","Downstream Analysis" = "precomputed",
            "Complete Analysis" = "upload"),
          selected = "examplelist"
        ),
        conditionalPanel(
          condition = "input.data_file_type == 'upload'",
          textInput("datadir", "Enter the Data Directory", value = ""),
          fileInput("inputfile", "Select the sample Information File", accept = ".csv", multiple = FALSE),
          textInput("fastafile", "Enter the Name of the Host Genome Fasta", value = ""),
          numericInput("threads", "Number of Threads", 16),
          numericInput("memory", "Memory utilized (GB)", 200),
          numericInput("comp", "% Completeness (metaWRAP)", 55),
          numericInput("cont", "% Contamination (metaWRAP)", 10),
          checkboxInput("Setup", "Setup")
        ),
        conditionalPanel(
          condition = "input.data_file_type == 'precomputed'",
          textInput("countdir", "Enter the Directory Containing Counts Data", value = ""),
          fileInput("metafile", "Select the sample Information File", accept = ".csv", multiple = FALSE)
        ),
        actionButton("upload_data","Submit Data")
    )),
    
    column(
      width = 9,
      bsCollapse(id = "input_collapse_panel",open = "data_panel",multiple = FALSE,
        bsCollapsePanel(title = "Data Contents: Check Before `Submit`",
          value = "data_panel",
          dataTableOutput("sampleinfo")
        ),
        bsCollapsePanel(title = "Analysis Results: Ready to View Other Tabs",
                        value = "analysis_panel", 
                        downloadButton("download_results_CSV","Save Results as CSV File"),
                        dataTableOutput("analysisoutput")
                        )
      )
    )
  ),
  p(hr(), p(("ShinyApp created by Nirmal Singh Mahar, Anshul Budhraja,
                                                    Suman Pakala, S.V. Rajagopala* and
                                                    Ishaan Gupta*"), align = "center", width=2),
    p(("Copyrigth (C) 2023, code licensed under GPLv3"), align="center", width=2),
    p(("Code available on Github:"), a("https://github.com/Nirmal2310/MetaShiny",
                                       href="https://github.com/Nirmal2310/MetaShiny"),
      align="center",width=2)
  )
)
