tabPanel(
  "ARG Abundance", tabsetPanel(id="Circular_plot_tabset",
              tabPanel(title = "ARGs Richness",
                       tabsetPanel(id="Richness_per_group",
                         tabPanel(title = "Control Richness",
                                  downloadButton(outputId = "control_download_circular_richness_plot",
                                                 label = "Download Control Richness Plot (PNG)"),
                                  plotOutput("plot_control_circular_richness_plot", height = "100%")
                                    
                                  ),
                         tabPanel(title = "Case Richness",
                                  downloadButton(outputId = "case_download_circular_richness_plot",
                                                 label = "Download Case Richness Plot(PNG)"),
                                  plotOutput("plot_case_circular_richness_plot", height = "100%")
                                )
                       )
                       ),
              tabPanel("ARGs Abundance",
                       tabsetPanel(id="Abundance_per_group",
                                   tabPanel(title = "Control Abundance",
                                            downloadButton(outputId = "download_control_abundance_heatmap",
                                                           label = "Download Control Abundance HeatMap (PNG)"),
                                            plotOutput("plot_control_abundance_heatmap", height = "150%", width = "100%")
                                              
                                            ),
                                   tabPanel(title = "Case Abundance",
                                            downloadButton(outputId = "download_case_abundance_heatmap",
                                                           label = "Download Case Abundance HeatMap (PNG)"),
                                            plotOutput("plot_case_abundance_heatmap", height = "150%", width = "100%")
                                            )
                                   )
                       )
              )
  )