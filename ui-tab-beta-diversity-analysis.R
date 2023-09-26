tabPanel(
  "Beta Diversity Analysis",
  tabsetPanel(id="beta_diversity_tabset",
              tabPanel(title = "Heat Map",
                       downloadButton(outputId = "download_heatmap",
                                      label = "Download Heat Map (PNG)"),
                       plotOutput("plot_heatmap", height = "100%", width = "100%")),
              tabPanel(title = "PCA Plot",
                       downloadButton(outputId = "download_pca",
                                      label = "Download PCA Plot (PNG)"),
                       plotOutput("plot_pca", height = "100%", width = "100%")))
)
