alpha_diversity_analysis <- reactive({
    data <- analyze_data_reactive()$countsmetadata
    sample_metadata <- analyze_data_reactive()$sample_metadata
    fun_diversity_plot <- function(data)
    {
        diversity_data <- data %>% group_by(Sample_Id,ARO_term) %>%
          summarise(Counts = sum(Normalized_counts)) %>%
          mutate(Abundance = Counts/sum(Counts)*100)
        diversity_data <- inner_join(diversity_data, sample_metadata, by="Sample_Id")
        diversity_data <- diversity_data %>% select(Sample_Id, Group, everything())
        diversity_data <- diversity_data %>% group_by(Sample_Id) %>% summarise(Shannon = diversity(Abundance, index = "shannon"),
        Simpson = diversity(Abundance, index = "simpson"))
        diversity_data <- inner_join(diversity_data, sample_metadata, by="Sample_Id")
        diversity_data <- diversity_data %>% select(Sample_Id, Group, everything())
        diversity_data$Group <- factor(diversity_data$Group,
                                levels = c("Control", "Case"))
        diversity_data <- pivot_longer(diversity_data, cols = c(Shannon, Simpson),
                                        names_to = "Diversity", values_to = "Value")

        diversity_facet <- ggplot(diversity_data, aes(x = Group, y = Value, color = Group)) +
          geom_boxplot() +
          geom_jitter(shape = 16, position = position_jitter(0.2)) +
          scale_color_manual(values = c("#ffbf00", "#746AB0")) +
          theme_light() +
          labs(y = "ARGs diversity", x = "") +
          guides(color = guide_legend(title = "Groups", title.position = "top")) +
          facet_wrap(~ Diversity) +
          theme(
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            strip.text.x = element_text(size = 14),
            axis.text.y = element_text(size = 14),
            axis.text.x = element_text(size = 14),
            legend.title = element_text(colour = "black",size = 10),
            legend.text = element_text(colour = "black", size = 10),
            plot.title = element_text(hjust = 0.5, size = rel(2)))
        return(diversity_facet)
    }
    fun_abundance_plot <- function(data)
    {
        abundance_data <- data %>% 
          group_by(Sample_Id, ARO_term) %>%
          summarise(Counts = sum(Normalized_counts))
        abundance_data <- inner_join(abundance_data, sample_metadata,
                                    by = "Sample_Id")
        abundance_data <- abundance_data %>% select(Sample_Id, Group, everything())
        abundance_data$Group <- factor(abundance_data$Group,
                                    levels = c("Control", "Case"))
        abundance_data <- subset(abundance_data, select = -Sample_Id)
        abundance_plot <- ggplot(abundance_data, aes(x = Group, y = log2(Counts), color = Group)) +
          geom_boxplot() +
          stat_compare_means(comparisons = list(c("Control", "Case"))) +
          stat_summary(fun = mean, geom = "point", shape = 9, size = 2) +
          geom_jitter(shape = 16, position = position_jitter(0.2)) +
          scale_color_manual(values = c("#ffbf00", "#746AB0")) +
          theme_light() +
          xlab("Group") +
          ylab("Log2(Counts)")
        return(abundance_plot)
    }
    return(list(diversity_plot = fun_diversity_plot(data),
        abundance_plot = fun_abundance_plot(data)))
})
observeEvent(input$upload_data, {
    plots_data <- alpha_diversity_analysis()
    output$plot_alpha_diversity <- renderPlot({
        plots_data$diversity_plot},height = 500
        )

    output$plot_abundance <- renderPlot({
        plots_data$abundance_plot}, height = 500
        )

    output$download_alpha_diversity_plot <- downloadHandler(
        filename = function() {
            paste("Alpha_diversity_plot_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plots_data$diversity_plot, width = 6.07, height = 3.96, units = "in", dpi = "retina")
        }
    )

    output$download_abundance_plot <- downloadHandler(
        filename = function() {
            paste("Abundance_plot_", Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plots_data$abundance_plot, width = 6.07, height = 3.96, units = "in", dpi = "retina")
        }
    )
})