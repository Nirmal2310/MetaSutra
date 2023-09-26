tabPanel(
  "Alpha Diversity Analysis",
  tabsetPanel(id="alpha_diversity_tabset",
              tabPanel(title = "Case vs Control Abundance",
                       downloadButton(outputId = "download_abundance_plot",
                                      label = "Download Abundance Plot (PNG)"),
                       plotOutput("plot_abundance", height = "auto", width = "auto") ),
              tabPanel(title = "Case vs Control Diversity",
                       downloadButton(outputId = "download_alpha_diversity_plot",
                                      label = "Download Diversity Plot (PNG)"),
                       plotOutput("plot_alpha_diversity", height = "auto",
                       width = "auto")))
)