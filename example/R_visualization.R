library(tidyverse)
library(stringr)
library(ggpubr)
library(dendextend)
library(ComplexHeatmap)
library(vegan)
library(ggrepel)
setwd("C:/Users/Nirmal/OneDrive/Desktop/MetaShiny/example")
file_list <- gsub(".txt", "", list.files(getwd())[grep("\\consolidated_final_arg_counts.txt$", 
                                                       list.files(getwd()))])
family_info_list <- gsub(".txt", "", list.files(getwd())[grep("\\_family_info.txt$", 
                                                         list.files(getwd()))])
samples_header <- gsub("_consolidated_final_arg_counts","",file_list)
sample_metadata <- read.table(file = "Sample_information.csv", sep = ",", 
                              header = TRUE)
family_data_list <- list()
for (i in 1:length(family_info_list)){
  family_data_list[[i]] <- read.delim(file = paste0(family_info_list[i],".txt"),
                                      header = TRUE)
}
family_data_list <- lapply(family_data_list, function(x){
  x$Classification <- str_replace_all(string=x$Classification,
                                      pattern = "_", replacement = " ") 
  return(x)})
sample_data_list <- list()
for (i in 1:length(file_list))
{
  sample_data_list[[i]] <- read.delim(file = paste0(file_list[i],".txt"), header = TRUE)
}
sample_data_list <- lapply(sample_data_list,function(x){
  x <- x %>% filter(Percentage_Identity >= 85, Percentage_Identity <= 100)
  x <- x %>% filter(Percentage_Coverage >=85, Percentage_Coverage <= 100)
  return(x)
  }
       )
sample_data_list <- lapply(sample_data_list,function(x){
  x$Drug_Class <- str_replace_all(string = x$Drug_Class, 
                                  pattern = "\\;.*$", replacement = "")
  x$AMR_Gene_Family <- str_replace_all(string = x$AMR_Gene_Family, 
                                       pattern = "\\;.*$", replacement = "")
  x$Resistance_Mechanism <- str_replace_all(string = x$Resistance_Mechanism, 
                                            pattern = "\\;.*$", replacement = "")
  return(x)
  }
       )

for ( i in 1:length(sample_data_list))
{
  sample_data_list[[i]]$Sample_Id <- samples_header[i]
}

duplicates_removal <- function(df)
{
  temp <- df %>% group_by(Sample_Id,Classification,ARO_term) %>%
    summarise(Summed_Counts = sum(Counts))
  temp2 <- subset(df, select = -c(Counts,ARG))
  df <- inner_join(temp, temp2, by = c("ARO_term","Classification", "Sample_Id"))
  df <- rename(df, Counts = Summed_Counts)
  return(df)
}


sample_data_list <- lapply(sample_data_list, duplicates_removal)

gpcm_calculation <- function(df)
{
  df$Normalized_counts <- round(((df$Counts/df$ARG_length)*10^6/sum(df$Counts/df$ARG_length))
                                , digits = 2)
  return(df)
}

sample_data_list <- lapply(sample_data_list, gpcm_calculation)

for (i in 1:length(samples_header)){
  sample_data_list[[i]] <- inner_join(sample_data_list[[i]], family_data_list[[i]],
                                      by="Classification")
}

############################### Sample-wise Analysis ###########################


############################### Drug Class Figure ##############################

for (i in 1:length(samples_header))
{
  dc_temp_df <- sample_data_list[[i]] %>% group_by(Drug_Class) %>% 
    summarise(Counts = sum(Normalized_counts)) %>% 
    mutate(Abundance = Counts/sum(Counts)*100)
  
  print(ggplot(dc_temp_df, aes(Drug_Class, Abundance)) +
    geom_col(fill=alpha("blue", 0.5)) +
    coord_flip() +
    theme_minimal() +
    ylab("Percent Abundance") +
    xlab("Drug Class"))
}

################################# Resistance Mechanism Figure ################## 

for (i in 1:length(samples_header))
{
  print(sample_data_list[[i]] %>% group_by(Resistance_Mechanism) %>% 
          summarise(count=n()) %>% 
    mutate(lab = round((count/sum(count))*100)) %>% 
    mutate(lab = paste0(lab,"%")) %>% 
    ggdonutchart("count", label = "lab",
                 fill = "Resistance_Mechanism", color = "white" ) +
    theme(legend.position = "left") +
    theme(plot.title = element_blank(), plot.subtitle = element_blank()) +
    scale_fill_discrete(name = "Resistance Mechanism"))
}


#################################### Cohort Analysis ###########################

data <- do.call("rbind", sample_data_list)
data <- inner_join(data, sample_metadata, by = "Sample_Id")

############################### Drug Class Figure ##############################

dc_temp_df <- data %>% group_by(Drug_Class) %>% 
  summarise(Count = sum(Normalized_counts)) %>% 
  mutate(Abundance = Count/sum(Count)*100)
dc_temp_df$Drug_Class <- factor(dc_temp_df$Drug_Class,
                                levels = dc_temp_df$Drug_Class[
                                  order(dc_temp_df$Abundance, decreasing = FALSE)])
ggplot(dc_temp_df, aes(Drug_Class, Abundance)) +
  geom_col(fill=alpha("blue", 0.5)) +
  coord_flip() +
  theme_minimal() +
  ylab("Total ARG Abundance") +
  xlab("Drug Class")

################################# Resistance Mechanism Figure ##################

data %>% 
  group_by(Resistance_Mechanism) %>%
  summarise(count = n()) %>% 
  mutate(lab = round((count/sum(count))*100)) %>% 
  mutate(lab = paste0(lab,"%")) %>% 
  ggdonutchart("count", label = "lab",
               fill = "Resistance_Mechanism", color = "white" ) +
  theme(legend.position = "left") +
  theme(plot.title = element_blank(), plot.subtitle = element_blank()) +
  scale_fill_discrete(name = "Resistance Mechanism")

#################################### Circular Plot (Richness) ##################


data_2 <- data %>% group_by(Family, Classification) %>% summarise(
  ARG_Richness = n_distinct(ARO_term))

data_2$Family <- as.factor(data_2$Family)

data_2 <- data_2 %>% arrange(Family, ARG_Richness)


empty_bar <- 4
to_add <- data.frame(matrix(NA, empty_bar*nlevels(data_2$Family), ncol(data_2)) )
colnames(to_add) <- colnames(data_2)
to_add$Family <- rep(levels(data_2$Family), each=empty_bar)
data_2 <- rbind(data_2, to_add)
data_2 <- data_2 %>% arrange(as.factor(Family))
data_2$id <- seq(1, nrow(data_2))


label_data <- data_2
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id - 0.5)/ number_of_bar
label_data$hjust <- ifelse(angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)


base_data <- data_2 %>% 
  group_by(Family) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))

grid_data <- base_data
grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
grid_data$start <- grid_data$start - 1
grid_data <- grid_data[-1,]

y_data_richness <- floor(seq(5,floor(max(data_2$ARG_Richness %>% 
                                           replace(.,is.na(.),0))),length.out = 5))

ggplot(data_2, aes(x=as.factor(id), y=ARG_Richness, fill = Family)) +
  geom_bar(aes(x=as.factor(id), y=ARG_Richness, fill = Family), stat = "identity", 
           alpha = 0.3) +
  
  geom_segment(data=grid_data, aes(x = end, y = y_data_richness[5], 
                                   xend = start, yend = y_data_richness[5]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_richness[4], 
                                   xend = start, yend = y_data_richness[4]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_richness[3], 
                                   xend = start, yend = y_data_richness[3]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_richness[2], 
                                   xend = start, yend = y_data_richness[2]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_richness[1], 
                                   xend = start, yend = y_data_richness[1]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  annotate("text", x = rep(max(data_2$id)-1,5), y = c(y_data_richness[1:5]), 
           label = c(y_data_richness[1:5]) , color="black", size=3 , angle=0, 
           fontface="bold", hjust=1) +
  
  geom_bar(aes(x=as.factor(id), y=ARG_Richness, fill = Family), 
           stat = "identity", alpha = 0.3) +
  
  ylim(-max(data_2$ARG_Richness + 10 , na.rm = TRUE),max(data_2$ARG_Richness + 10, 
                                                         na.rm = TRUE)) +
  theme_minimal() +
  theme(
    #legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm")
  ) +
  coord_polar() +
  geom_text(data=label_data, aes(x=id, y=ARG_Richness + 5, label=Classification, 
                                 hjust=hjust), color="black", fontface="bold",
            alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) +
  geom_text(x = max(data_2$id+0.45), y = y_data_richness[5] + 10, label = "ARG Richness", 
            color = "black", size = 3.5, angle=0, fontface="bold", hjust=1)

#################################### Circular Plot (Abundance) #################

data_3 <- data %>% group_by(Classification, AMR_Gene_Family) %>% summarise(
  Counts = sum(Normalized_counts)) %>% mutate(Abundance = Counts/sum(Counts)*100)
data_3$Classification <- as.factor(data_3$Classification)
data_3 <- data_3 %>% filter(Abundance > 0.001)
data_3 <- data_3 %>% arrange(Classification, Abundance)

empty_bar <- 4
to_add <- data.frame(matrix(NA, empty_bar*nlevels(data_3$Classification), 
                            ncol(data_3)) )
colnames(to_add) <- colnames(data_3)
to_add$Classification <- rep(levels(data_3$Classification), each=empty_bar)
data_3 <- rbind(data_3, to_add)
data_3 <- data_3 %>% arrange(as.factor(Classification))
data_3$id <- seq(1, nrow(data_3))


label_data <- data_3
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id - 0.5)/ number_of_bar
label_data$hjust <- ifelse(angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)


base_data <- data_3 %>% 
  group_by(Classification) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))

grid_data <- base_data
grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
grid_data$start <- grid_data$start - 1
grid_data <- grid_data[-1,]

y_data_abundance <- floor(seq(5,floor(max(data_3$Abundance %>% 
                                            replace(.,is.na(.),0))),length.out = 5))

ggplot(data_3, aes(x=as.factor(id), y=Abundance, fill = Classification)) +
  geom_bar(aes(x=as.factor(id), y=Abundance, fill = Classification), stat = "identity", 
           alpha = 0.3) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_abundance[5], 
                                   xend = start, yend = y_data_abundance[5]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_abundance[4], 
                                   xend = start, yend = y_data_abundance[4]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_abundance[3], 
                                   xend = start, yend = y_data_abundance[3]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_abundance[2], 
                                   xend = start, yend = y_data_abundance[2]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = y_data_abundance[1], 
                                   xend = start, yend = y_data_abundance[1]), 
               colour = "grey",  size=0.3 , inherit.aes = FALSE ) +
  annotate("text", x = rep(max(data_3$id)-1,5), y = y_data_abundance[1:5], 
           label = y_data_abundance[1:5] , color="black", size=3 , angle=0, 
           fontface="bold", hjust=1) +
  geom_bar(aes(x=as.factor(id), y=Abundance, fill = Classification), 
           stat = "identity", alpha = 0.3) +
  ylim(-max(data_3$Abundance , na.rm = TRUE),max(data_3$Abundance, na.rm = TRUE)) +
  theme_minimal() +
  theme(
    #legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm")
  ) +
  coord_polar() +
  geom_text(data=label_data, aes(x=id, y=Abundance, label=AMR_Gene_Family, 
                                 hjust=hjust), color="black", fontface="bold",
            alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) +
  geom_text(x = max(data_3$id+1), y = y_data_abundance[5] + 5, label = "Gene Family Abundance", 
            color = "black", size = 3.5, angle=0, fontface="bold", hjust=1)

#################################### Heat Map Plot ##############################

data_4 <- data %>% group_by(Sample_Id,ARO_term) %>% 
  summarise(Counts = sum(Normalized_counts)) %>% mutate(Counts = log2(Counts))

data_4 <- data_4 %>% pivot_wider(names_from = Sample_Id, values_from = Counts)

data_4 <- as.data.frame(data_4)

rownames(data_4) <- data_4$ARO_term

data_4 <- data_4 %>% subset(. , select = -ARO_term) %>% replace(. , is.na(.), 0)

row_dend <-  hclust(dist(t(data_4)), method = "complete")
column_dend <- hclust(dist(data_4), method = "complete")
Heatmap(t(data_4), name = "Log2Counts",
        row_names_gp = gpar(fontsize = 6.5),
        cluster_rows = color_branches(row_dend),
        cluster_columns = color_branches(column_dend),
        show_column_names = FALSE,
        show_row_names = TRUE)


############################ Alpha Diversity ###################################

diversity_data <- data %>% group_by(Sample_Id,ARO_term) %>% 
  summarise(Counts = sum(Normalized_counts)) %>% 
  mutate(Abundance = Counts/sum(Counts)*100)
diversity_data <- inner_join(diversity_data, sample_metadata, by="Sample_Id")
diversity_data <- diversity_data %>% select(Sample_Id, Group, everything())

diversity_data <- diversity_data %>% 
  group_by(Sample_Id) %>% 
  summarise(Shannon = diversity(Abundance, index = "shannon"),
            Simpson = diversity(Abundance, index = "simpson"))
diversity_data <- inner_join(diversity_data, sample_metadata, by="Sample_Id")
diversity_data <- diversity_data %>% select(Sample_Id, Group, everything())
diversity_data$Group <- factor(diversity_data$Group, 
                               levels = c("Control", "Case"))
diversity_data <- pivot_longer(diversity_data, cols = c(Shannon, Simpson), 
                               names_to = "Diversity", values_to = "Value")

ggplot(diversity_data, aes(x=Group, y=Value, color=Group)) +
  geom_boxplot() +
  geom_jitter(shape=16, position=position_jitter(0.2)) + 
  scale_color_manual(values = c("#ffbf00","#746AB0")) + 
  theme_light() +
  labs(y= "ARGs diversity", x = "") +
  guides(color = guide_legend(title = "Groups", title.position = "top")) +
  facet_wrap(~ Diversity) +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    strip.text.x = element_text(size = 14),
    axis.text.y=element_text(size=14),
    axis.text.x=element_text(size=14),
    # panel.spacing=unit(2,"lines"),
    legend.title=element_text(colour="black",size=10),
    legend.text=element_text(colour="black", size=10),
    plot.title = element_text(hjust = 0.5,size = rel(2)))


############################ Abundance Plot ####################################

abundance_data <- data %>% group_by(Sample_Id,ARO_term) %>% 
  summarise(Counts = sum(Normalized_counts))
abundance_data <- inner_join(abundance_data, sample_metadata, by="Sample_Id")
abundance_data <- abundance_data %>% select(Sample_Id, Group, everything())
abundance_data$Group <- factor(abundance_data$Group, 
                               levels=c("Control","Case"))
abundance_data <- subset(abundance_data,select=-Sample_Id)
ggplot(abundance_data, aes(x=Group, y=log2(Counts), color = Group)) + 
  geom_boxplot() + stat_compare_means(comparisons = list(c("Control", "Case"))) + 
  stat_summary(fun=mean, geom="point", shape=9, size=2) + 
  geom_jitter(shape=16, position=position_jitter(0.2)) + 
  scale_color_manual(values = c("#ffbf00","#746AB0")) + 
  theme_light() +
  xlab("Group") +
  ylab("Log2(Counts)")
abundance_data <- abundance_data %>% group_by(ARO_term) %>% 
  filter(all(c("control", "antibiotic") %in% Group)) %>% ungroup()
aro_term_abundance_list <- split(abundance_data, abundance_data$ARO_term)
aro_abundance_plot <- lapply(aro_term_abundance_list, function(x)
  {
  return(print(ggplot(x, aes(x=Group, y=log2(Counts), color=Group)) +
    geom_boxplot() + stat_compare_means(comparisons = list(c("control","antibiotic"))) +
    stat_summary(fun=mean, geom="point", shape=9, size=2) + 
    geom_jitter(shape=16, position=position_jitter(0.2)) + 
    scale_color_manual(values = c("#ffbf00","#746AB0")) + 
    theme_light() +
      ylab(paste0("Log2(counts ) for ",x$ARO_term))))
})


############################ Beta Diversity ####################################

pca <- prcomp(t(data_4), scale. = T, center = T)
pca.var <- pca$sdev^2
pca.var.per <- round(pca.var/sum(pca.var)*100,1)
pca.data <- data.frame(Sample_Id = rownames(pca$x), X=pca$x[,1],Y=pca$x[,2])
pca.data <- inner_join(pca.data, sample_metadata, by="Sample_Id")


ggplot(data=pca.data, aes(x=X,y=Y, color = Group)) +
  geom_point() +
  xlab(paste0("PC1 (", pca.var.per[1], "%", ")")) +
  ylab(paste0("PC2 (", pca.var.per[2], "%", ")")) +
  theme_bw() +
  geom_text_repel(label=pca.data$Sample_Id)
