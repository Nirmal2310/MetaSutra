arg_distribution_analysis <- reactive({
    data <- analyze_data_reactive()$countsmetadata
    sample_metadata <- analyze_data_reactive()$sample_metadata
    fun_richness_plot <- function(data) {
        data_2 <- data %>%
                    group_by(Family, Classification) %>%
                    summarise(ARG_Richness = n_distinct(ARO_term))

        data_2$Family <- as.factor(data_2$Family)

        data_2 <- data_2 %>% arrange(Family, ARG_Richness)

        empty_bar <- 4
        to_add <- data.frame(matrix(NA, empty_bar * nlevels(data_2$Family),
                                ncol(data_2)))
        colnames(to_add) <- colnames(data_2)
        to_add$Family <- rep(levels(data_2$Family), each = empty_bar)
        data_2 <- rbind(data_2, to_add)
        data_2 <- data_2 %>% arrange(as.factor(Family))
        data_2$id <- seq(1, nrow(data_2))

        label_data <- data_2
        number_of_bar <- nrow(label_data)
        angle <- 90 - 360 * (label_data$id - 0.5)/ number_of_bar
        label_data$hjust <- ifelse(angle < -90, 1, 0)
        label_data$angle <- ifelse(angle < -90, angle + 180, angle)

        base_data <- data_2 %>%
            group_by(Family) %>%
            summarize(start = min(id), end = max(id) - empty_bar) %>%
            rowwise() %>%
            mutate(title = mean(c(start, end)))

        grid_data <- base_data
        grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
        grid_data$start <- grid_data$start - 1
        grid_data <- grid_data[-1, ]

        y_data_richness <- floor(seq(5, floor(max(data_2$ARG_Richness %>%
            replace(., is.na(.), 0))), length.out = 5))

        richness_plot <- ggplot(data_2, aes(x = as.factor(id), y = ARG_Richness, fill = Family)) +
            geom_bar(aes(x = as.factor(id), y = ARG_Richness, fill = Family),
                        stat = "identity", alpha = 0.3) +
        geom_segment(data = grid_data, aes(x = end, y = y_data_richness[5],
                xend = start, yend = y_data_richness[5]),
                colour = "grey",  size = 0.3, inherit.aes = FALSE) +
            geom_segment(data = grid_data, aes(x = end, y = y_data_richness[4],
                    xend = start, yend = y_data_richness[4]),
                colour = "grey",  size = 0.3, inherit.aes = FALSE) +
            geom_segment(data=grid_data, aes(x = end, y = y_data_richness[3],
                    xend = start, yend = y_data_richness[3]),
                colour = "grey",  size = 0.3, inherit.aes = FALSE) +
            geom_segment(data=grid_data, aes(x = end, y = y_data_richness[2],
                    xend = start, yend = y_data_richness[2]),
                colour = "grey",  size = 0.3, inherit.aes = FALSE) +
            geom_segment(data=grid_data, aes(x = end, y = y_data_richness[1],
                    xend = start, yend = y_data_richness[1]),
                colour = "grey",  size = 0.3, inherit.aes = FALSE) +
            annotate("text", x = rep(max(data_2$id)-1,5), y = c(y_data_richness[1:5]),
            label = c(y_data_richness[1:5]), color = "black", size = 3, angle = 0,
            fontface = "bold", hjust = 1) +
            geom_bar(aes(x = as.factor(id), y = ARG_Richness, fill = Family),
            stat = "identity", alpha = 0.3) +
            ylim(-max(data_2$ARG_Richness + 10, na.rm = TRUE), max(data_2$ARG_Richness + 10, na.rm = TRUE)) +
            theme_minimal() +
            theme(
                    axis.text = element_blank(),
                    axis.title = element_blank(),
                    panel.grid = element_blank(),
                    plot.margin = unit(rep(-1, 4), "cm")
                ) +
            coord_polar() +
            geom_text(data = label_data, aes(x = id, y = ARG_Richness + 5, label = Classification, 
                    hjust = hjust), color = "black", fontface = "bold",
                    alpha = 0.6, size = 2.5, angle = label_data$angle, inherit.aes = FALSE ) +
            geom_text(x = max(data_2$id+0.45), y = y_data_richness[5] + 10, label = "ARG Richness", 
                color = "black", size = 3.5, angle = 0, fontface = "bold", hjust = 1)
        return(richness_plot)
    }
    fun_abundance_plot <- function(data)
    {
        data_3 <- data %>%
                    group_by(Classification, AMR_Gene_Family) %>%
                            summarise(Counts = sum(Normalized_counts)) %>%
                            mutate(Abundance = Counts / sum(Counts) * 100)
        data_3$Classification <- as.factor(data_3$Classification)
        data_3 <- data_3 %>% filter(Abundance > 0.001)
        data_3 <- data_3 %>% arrange(Classification, Abundance)

        empty_bar <- 4
        to_add <- data.frame(matrix(NA, empty_bar * nlevels(data_3$Classification),
                                    ncol(data_3)))
        colnames(to_add) <- colnames(data_3)
        to_add$Classification <- rep(levels(data_3$Classification), each = empty_bar)
        data_3 <- rbind(data_3, to_add)
        data_3 <- data_3 %>% arrange(as.factor(Classification))
        data_3$id <- seq(1, nrow(data_3))


        label_data <- data_3
        number_of_bar <- nrow(label_data)
        angle <- 90 - 360 * (label_data$id - 0.5) / number_of_bar
        label_data$hjust <- ifelse(angle < -90, 1, 0)
        label_data$angle <- ifelse(angle < -90, angle + 180, angle)


        base_data <- data_3 %>%
                        group_by(Classification) %>%
                        summarize(start = min(id), end = max(id) - empty_bar) %>%
                        rowwise() %>%
                        mutate(title = mean(c(start, end)))

        grid_data <- base_data
        grid_data$end <- grid_data$end[c(nrow(grid_data), 1:nrow(grid_data) - 1)] + 1
        grid_data$start <- grid_data$start - 1
        grid_data <- grid_data[-1, ]

        y_data_abundance <- floor(seq(5, floor(max(data_3$Abundance %>%
                                    replace(., is.na(.), 0))), length.out = 5))

        abundance_plot <- ggplot(data_3, aes(x = as.factor(id), y = Abundance, fill = Classification)) +
        geom_bar(aes(x = as.factor(id), y = Abundance,
                    fill = Classification), stat = "identity", alpha = 0.3) +
        geom_segment(data = grid_data, aes(x = end, y = y_data_abundance[5],
                                        xend = start, yend = y_data_abundance[5]),
                    colour = "grey",  size = 0.3, inherit.aes = FALSE) +
        geom_segment(data = grid_data, aes(x = end, y = y_data_abundance[4],
                                        xend = start, yend = y_data_abundance[4]),
                    colour = "grey",  size = 0.3, inherit.aes = FALSE) +
        geom_segment(data = grid_data, aes(x = end, y = y_data_abundance[3],
                                        xend = start, yend = y_data_abundance[3]),
                    colour = "grey",  size = 0.3, inherit.aes = FALSE) +
        geom_segment(data = grid_data, aes(x = end, y = y_data_abundance[2],
                                        xend = start, yend = y_data_abundance[2]),
                    colour = "grey",  size = 0.3, inherit.aes = FALSE) +
        geom_segment(data = grid_data, aes(x = end, y = y_data_abundance[1],
                                        xend = start, yend = y_data_abundance[1]),
                    colour = "grey",  size = 0.3, inherit.aes = FALSE) +
        annotate("text", x = rep(max(data_3$id) -1, 5), y = y_data_abundance[1:5],
                label = y_data_abundance[1:5], color = "black", size = 3, angle = 0,
                fontface = "bold", hjust = 1) +
        geom_bar(aes(x = as.factor(id), y = Abundance, fill = Classification),
                stat = "identity", alpha = 0.3) +
        ylim(-max(data_3$Abundance, na.rm = TRUE),
                max(data_3$Abundance, na.rm = TRUE)) +
        theme_minimal() +
        theme(
            axis.text = element_blank(),
            axis.title = element_blank(),
            panel.grid = element_blank(),
            plot.margin = unit(rep(-1, 4), "cm")
        ) +
        coord_polar() +
        geom_text(data = label_data, aes(x = id, y = Abundance, label = AMR_Gene_Family, hjust = hjust), color = "black", fontface= "bold",
                    alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) +
        geom_text(x = max(data_3$id+1), y = y_data_abundance[5] + 5, label = "Gene Family Abundance",
                    color = "black", size = 3.5, angle = 0, fontface = "bold", hjust = 1)
        return(abundance_plot)
    }
    return(list(richness_plot = fun_richness_plot(data),
    abundance_plot = fun_abundance_plot(data)))
})
observeEvent(input$upload_data, {
    plots_data <- arg_distribution_analysis()
    output$plot_circular_richness_plot <- renderPlot({
        plots_data$richness_plot
    })
    output$plot_circular_abundance_plot <- renderPlot({
        plots_data$abundance_plot
    })
    output$download_circular_richness_plot <- downloadHandler(
        filename = function() {
            paste("Circular_Cohort_Richness_plot_",
            Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plots_data$richness_plot, width = 8.27, height = 11.69,
                   units = "in", dpi = "retina")
        }
    )
    output$download_circular_abundance_plot <- downloadHandler(
        filename = function() {
            paste("Circular_Cohort_Abundance_plot_",
            Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plots_data$abundance_plot, width = 26, height = 31,
                   units = "in", dpi = "retina")
        }
    )
})