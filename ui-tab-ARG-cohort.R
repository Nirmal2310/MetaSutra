tabPanel(
  "ARG Classification",
  tabsetPanel(id="Classification_tabset",
                tabPanel(title = "ARGs vs Drug Class",
                       downloadButton(outputId = "download_drug_class_barplot",
                                      label = "Download Bar Plot (PNG)"),
                                      plotOutput("plot_drug_class_barplot")),
                tabPanel(title = "Resistance Mechanisms of ARGs",
                       downloadButton(outputId = "download_resistance_plot",
                                      label = "Download Donut Plot (PNG)"),
                                      plotOutput("plot_resistance_plot"))
              )
)