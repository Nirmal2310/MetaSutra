observe(
  {
    validate(
      need((input$data_file_type == "examplelist") | (!is.null(input$inputfile))
           | (!is.null(input$metafile)), message = "Please select a File")
    )
})

input_data_reactive <-  reactive({
  
  print("inputting data")
  
  validate(
    need((input$data_file_type == "examplelist") | (!is.null(input$inputfile)) |
           (!is.null(input$metafile)), "Please Select A File")
    )
  
  if (input$data_file_type == "examplelist") {
    
    seqdata <- read.csv("example/Sample_information.csv")
    
    print("Uploaded Example List")
    
    return(list('data' = seqdata))
  
  }
  else if(input$data_file_type == "upload"){
    if (!is.null(input$inputfile)) {
      file <- input$inputfile
      
      seqdata <- read.csv(file$datapath)
      
      print("Uploaded User Sample List")
      
      validate(need(ncol(seqdata) > 1,
                    message = "File appears to be one column. Check that it is a .csv file.")
      )
      return(list('data' = seqdata))
    }
  }
  else{
    if (!is.null(input$metafile)){
      file <- input$metafile
    
      seqdata <- read.csv(file$datapath)
    
      print("Uploaded User Sample List")
    
      validate(need(ncol(seqdata) > 1,
                    message = "File appears to be one column. Check that it is a .csv file.")
    )
    return(list('data' = seqdata))
    }
    }
})


output$fileUploaded <- reactive({
  
  return(!is.null(input_data_reactive()))

})

outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)

analyze_data_reactive <-
  eventReactive(input$upload_data, ignoreNULL = FALSE,
  {
    
    withProgress(message = "Analyzing data, please wait",{
      print("analysisCountDataReactive")
      
      
      if (input$data_file_type == "examplelist") {
          
          file_list <- gsub(".txt", "", list.files("example/")
                      [grep("\\consolidated_final_arg_counts.txt$", list.files("example/"))])
          
          
          family_info_list <- gsub(".txt", "", list.files("example/")[grep("\\_family_info.txt$", 
                                                                           list.files("example/"))])
          
        
          samples_header <- gsub("_consolidated_final_arg_counts","", file_list)
          
          sample_metadata <- input_data_reactive()$data
          
          
          family_data_list <- list()
          
          for (i in 1:length(family_info_list)){
            family_data_list[[i]] <- read.delim(file <- paste0("example/",family_info_list[i],".txt"), header = TRUE)
          }
          
          family_data_list <- lapply(family_data_list, function(x){
            x$Classification <- str_replace_all(string=x$Classification, pattern = "_", replacement = " ") 
            return(x)})
          
          
          sample_data_list <- list()
          
          for (i in 1:length(file_list)){
            sample_data_list[[i]] <- read.delim(file = paste0("example/",file_list[i],".txt"), header = TRUE)
          }
          
          sample_data_list <- lapply(sample_data_list, function(x){
            x <- x %>% filter(Percentage_Identity >= 85, Percentage_Identity <= 100)
            x <- x %>% filter(Percentage_Coverage >= 85, Percentage_Coverage <= 100)
            return(x)
          
            }
          
          )
          
          
          
          sample_data_list <- lapply(sample_data_list, function(x) {
            
            x$Drug_Class <- str_replace_all(string = x$Drug_Class,
                                            pattern = "\\;.*$", replacement = "")
            
            x$AMR_Gene_Family <- str_replace_all(string = x$AMR_Gene_Family, 
                                                 pattern = "\\;.*$", replacement = "")
            
            x$Resistance_Mechanism <- str_replace_all(string = x$Resistance_Mechanism,
                                                      pattern = "\\;.*$", replacement = "")
            return(x)
          }
          )
          
          
          
          for (i in 1:length(sample_data_list))
            {
            sample_data_list[[i]]$Sample_Id <- samples_header[i]
          }
          
          
          
          duplicates_removal <- function(df)
          {
            temp <- df %>%
              group_by(Sample_Id,Classification,ARO_term) %>%
              summarise(Summed_Counts = sum(Counts))
            
            temp2 <- subset(df, select = -c(Counts, ARG))
            
            df <- inner_join(temp, temp2, 
                             by = c("ARO_term","Classification", "Sample_Id"))
            
            df <- rename(df, Counts = Summed_Counts)
            
            return(df)
          }
          
          
          sample_data_list <- lapply(sample_data_list, duplicates_removal)
          
          
          
          gpcm_calculation <- function(df)
          {
            df$Normalized_counts <- round(((df$Counts/df$ARG_length)*10^6/
                                             sum(df$Counts/df$ARG_length)), digits = 2)
            return(df)
          }
          
          sample_data_list <- lapply(sample_data_list, gpcm_calculation)
          
          
          
          for (i in 1:length(samples_header)){
            
            sample_data_list[[i]] <- inner_join(sample_data_list[[i]],
                                                family_data_list[[i]], by = "Classification")
            
          }
          
          
          
          countsmetadata <- do.call("rbind", sample_data_list)
          
          countsmetadata <- inner_join(countsmetadata, sample_metadata, by = "Sample_Id")
          
          print(countsmetadata)
          
          return(list('countsmetadata' = countsmetadata, 
                      'sample_metadata' = sample_metadata))

        }else if(input$data_file_type == "upload")
          {
          
          work_dir <- getwd()
          
          result_path <- paste0(input$datadir,"/","Results")
          
          fasta_file <- paste0(input$datadir,"/",input$fastafile)
          
          data_path <- paste0(input$datadir,"/","Data")
          
          observeEvent(input$Setup, {
            if(input$Setup){
              system('cp -r $work_dir/Installation $data_path')
              system('cd $data_path/Installation && bash env_install.sh')
            }
          })
          
          system('ls $data_path/*1.fastq.gz | cut -d "_" -f1 > $data_path/list')
          
          system('if [ !-d $result_path ]; then mkdir $result_path')
          
          system('while read sample; do bash $work_dir/Pipeline/rgi_main.sh -s $data_path/$sample
                 -r $data_path/$fasta_file -t $threads -m $memory -c $comp -d $cont; done < $data_path/list')
          system('mv $data_path/*_out/*_consolidated_final_arg_counts.txt $result_path/')
          
          system('mv $data_path/*_out/*_family_info.txt $result_path/')
          
          file_list <- gsub(".txt", "", list.files(result_path)
                      [grep("\\consolidated_final_arg_counts.txt$", list.files(result_path))])
          
          family_info_list <- gsub(".txt", "", list.files(result_path)
                                   [grep("\\_family_info.txt$", list.files(result_path))])
          
          samples_header <- gsub("_consolidated_final_arg_counts","", file_list)
          
          sample_metadata <- input_data_reactive()$data
          
          family_data_list <- list()
          
          for (i in 1:length(family_info_list)){
            family_data_list[[i]] <- read.delim(file = paste0(result_path,"/",family_info_list[i],".txt"), header = TRUE)
          }
          
          family_data_list <- lapply(family_data_list, function(x) {
            x$Classification <- str_replace_all(string=x$Classification, pattern = "_", replacement = " ") 
            return(x)})
          sample_data_list <- list()
          
          for (i in 1:length(file_list)){
            sample_data_list[[i]] <- read.delim(file = paste0(result_path,"/",file_list[i],".txt"), header = TRUE)
          }
          
          sample_data_list <- lapply(sample_data_list, function(x){
            x <- x %>% filter(Percentage_Identity >= 85, Percentage_Identity <= 100)
            x <- x %>% filter(Percentage_Coverage >= 85, Percentage_Coverage <= 100)
            return(x)
          }
          )
          
          sample_data_list <- lapply(sample_data_list, function(x) {
            x$Drug_Class <- str_replace_all(string = x$Drug_Class,
                                            pattern = "\\;.*$", replacement = "")
            
            x$AMR_Gene_Family <- str_replace_all(string = x$AMR_Gene_Family,
                                                 pattern = "\\;.*$", replacement = "")
            
            x$Resistance_Mechanism <- str_replace_all(string = x$Resistance_Mechanism,
                                                      pattern = "\\;.*$", replacement = "")
            return(x)
          }
          )
          
          for (i in 1:length(sample_data_list))
          {
            sample_data_list[[i]]$Sample_Id <- samples_header[i]
          }
          
          duplicates_removal <- function(df)
          {
            temp <- df %>%
              group_by(Sample_Id,Classification,ARO_term) %>%
              summarise(Summed_Counts = sum(Counts))
            
            temp2 <- subset(df, select = -c(Counts, ARG))
            
            df <- inner_join(temp, temp2, 
                             by = c("ARO_term","Classification", "Sample_Id"))
            
            df <- rename(df, Counts = Summed_Counts)
            
            return(df)
          }
          
          
          sample_data_list <- lapply(sample_data_list, duplicates_removal)
          
          gpcm_calculation <- function(df)
          {
            df$Normalized_counts <- round(((df$Counts/df$ARG_length)*10^6/
                                             sum(df$Counts/df$ARG_length)), digits = 2)
            return(df)
          }
          
          sample_data_list <- lapply(sample_data_list, gpcm_calculation)
          
          for (i in 1:length(samples_header)){
            
            sample_data_list[[i]] <- inner_join(sample_data_list[[i]],
                                                family_data_list[[i]], by = "Classification")
            
          }
          
          countsmetadata <- do.call("rbind", sample_data_list)
          
          countsmetadata <- inner_join(countsmetadata, sample_metadata, by = "Sample_Id")
          return(list('countsmetadata' = countsmetadata, 
                      'sample_metadata' = sample_metadata))
        }
      else{
        files_path <- input$countdir
        print(files_path)
        file_list <- gsub(".txt", "", list.files(files_path)
                          [grep("\\consolidated_final_arg_counts.txt$", list.files(files_path))])
        
        family_info_list <- gsub(".txt", "", list.files(files_path)
                                 [grep("\\_family_info.txt$", list.files(files_path))])
        
        samples_header <- gsub("_consolidated_final_arg_counts","", file_list)
        
        sample_metadata <- input_data_reactive()$data
        
        print(sample_metadata)
        
        family_data_list <- list()
        
        for (i in 1:length(family_info_list)){
          family_data_list[[i]] <- read.delim(file = paste0(files_path,"/",family_info_list[i],".txt"), header = TRUE)
        }
        
        family_data_list <- lapply(family_data_list, function(x) {
          x$Classification <- str_replace_all(string=x$Classification, pattern = "_", replacement = " ") 
          return(x)})
        sample_data_list <- list()
        
        for (i in 1:length(file_list)){
          sample_data_list[[i]] <- read.delim(file = paste0(files_path,"/",file_list[i],".txt"), header = TRUE)
        }
        
        sample_data_list <- lapply(sample_data_list, function(x){
          x <- x %>% filter(Percentage_Identity >= 85, Percentage_Identity <= 100)
          x <- x %>% filter(Percentage_Coverage >= 85, Percentage_Coverage <= 100)
          return(x)
        }
        )
        
        sample_data_list <- lapply(sample_data_list, function(x) {
          x$Drug_Class <- str_replace_all(string = x$Drug_Class,
                                          pattern = "\\;.*$", replacement = "")
          
          x$AMR_Gene_Family <- str_replace_all(string = x$AMR_Gene_Family,
                                               pattern = "\\;.*$", replacement = "")
          
          x$Resistance_Mechanism <- str_replace_all(string = x$Resistance_Mechanism,
                                                    pattern = "\\;.*$", replacement = "")
          return(x)
        }
        )
        
        for (i in 1:length(sample_data_list))
        {
          sample_data_list[[i]]$Sample_Id <- samples_header[i]
        }
        
        duplicates_removal <- function(df)
        {
          temp <- df %>%
            group_by(Sample_Id,Classification,ARO_term) %>%
            summarise(Summed_Counts = sum(Counts))
          
          temp2 <- subset(df, select = -c(Counts, ARG))
          
          df <- inner_join(temp, temp2, 
                           by = c("ARO_term","Classification", "Sample_Id"))
          
          df <- rename(df, Counts = Summed_Counts)
          
          return(df)
        }
        
        
        sample_data_list <- lapply(sample_data_list, duplicates_removal)
        
        gpcm_calculation <- function(df)
        {
          df$Normalized_counts <- round(((df$Counts/df$ARG_length)*10^6/
                                           sum(df$Counts/df$ARG_length)), digits = 2)
          return(df)
        }
        
        sample_data_list <- lapply(sample_data_list, gpcm_calculation)
        
        for (i in 1:length(samples_header)){
          
          sample_data_list[[i]] <- inner_join(sample_data_list[[i]],
                                              family_data_list[[i]], by = "Classification")
          
        }
        
        countsmetadata <- do.call("rbind", sample_data_list)
        
        countsmetadata <- inner_join(countsmetadata, sample_metadata, by = "Sample_Id")
        return(list('countsmetadata' = countsmetadata, 
                    'sample_metadata' = sample_metadata))
      }
    
    })
  })

output$sampleinfo <- renderDataTable({
  
  temp <- input_data_reactive()
  
  if(!is.null(temp)) temp$data

})

observeEvent(input$upload_data,
({

  updateCollapse(session,id = "input_collapse_panel", open = "analysis_panel",
                 style = list("analysis_panel" = "success", "data_panel" = "primary"))
}))

output$analysisoutput <- renderDataTable({
  
  print("Data Engineering Output")
  
  analyze_data_reactive()$countsmetadata

})

output$download_results_CSV <- downloadHandler(
  filename = paste0("consolidated_data_", Sys.Date(), ".csv"),
  
  content = function(file) {
    
    write.csv(analyze_data_reactive()$data_results_table,
    
    file, row.names = FALSE)
  }
)