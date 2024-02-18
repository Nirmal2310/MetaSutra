arg_analysis_plots <- reactive({
    data <- analyze_data_reactive()$countsmetadata
    sample_metadata <- analyze_data_reactive()$sample_metadata
    fun_drug_class_plot <- function(data) {
    dc_temp_df <- data %>%
    group_by(Drug_Class) %>%
    summarise(Count = sum(Normalized_counts)) %>%
    mutate(Abundance = Count / sum(Count) * 100)
    dc_temp_df$Drug_Class <- factor(dc_temp_df$Drug_Class,
    levels = dc_temp_df$Drug_Class[order(
        dc_temp_df$Abundance, decreasing = FALSE)])
    drug_class_barplot <- ggplot(dc_temp_df, aes(Drug_Class, Abundance)) +
        geom_col(fill = alpha("blue", 0.5)) +
        coord_flip() +
        theme_minimal() +
        ylab("Total ARG Abundance") +
        xlab("Drug Class") +
      theme(
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.text.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"),
        axis.text.y = element_text(size = 12, face = "bold")
      )
    return(drug_class_barplot)
    }
    fun_resistance_plot <- function(data) {
        res_temp_df <- data %>%
          group_by(Resistance_Mechanism) %>%
          summarise(count = n()) %>%
          mutate(lab = round((count / sum(count)) * 100)) %>%
          mutate(lab = paste0(lab, "%"))
    resistance_plot <- res_temp_df %>% ggdonutchart("count", label = "lab",
                                    fill = "Resistance_Mechanism", 
                                    color = "white" ) +
      theme(legend.position = "left") +
      theme(plot.title = element_blank(), plot.subtitle = element_blank(),
            axis.text.x = element_text(size = 12, face = "bold"),
            legend.text = element_text(size = 12, face = "bold"),
            legend.title = element_text(size = 12, face = "bold")) +
      scale_fill_discrete(name = "Resistance Mechanism")
    return(resistance_plot)
    }
    return(list(drug_class_plot = fun_drug_class_plot(data),
    resistance_plot = fun_resistance_plot(data)))
})
observeEvent(input$upload_data, {
    plots_data <- arg_analysis_plots()

    output$plot_drug_class_barplot <- renderPlot({
        plots_data$drug_class_plot}, height = 500
        )

    output$plot_resistance_plot <- renderPlot({
        plots_data$resistance_plot}, height = 500
        )

    output$download_drug_class_barplot <- downloadHandler(
        filename = function() {
            paste("ARG_vs_Drug_Class_Plot_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plots_data$drug_class_plot,
            width = 13.69, height = 8.27, units = "in", dpi = "retina")
        }
    )

    output$download_resistance_plot <- downloadHandler(
        filename = function() {
            paste("ARG_Resistance_Mechanism_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plots_data$resistance_plot,
            width = 21, height = 7, units = "in", dpi = "retina")
        }
    )
})