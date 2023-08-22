tabPanel(
  "ARG Abundance", tabsetPanel(id="Circular_plot_tabset",
              tabPanel(title = "ARGs Richness",
                       downloadButton(outputId = "download_circular_richness_plot",
                                      label = "Download Richness Plot (PNG)"),
                       plotOutput("plot_circular_richness_plot")),
              tabPanel(title = "ARGs Abundance",
                       downloadButton(outputId = "download_circular_abundance_plot",
                                      label = "Download Abundance Plot (PNG)"),
                       plotOutput("plot_circular_abundance_plot")
                       )
              )
)