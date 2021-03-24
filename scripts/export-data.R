# Export data -------------------------------------------------------------

whole_data_set <- NULL

for(x in names(data_sets)){
  
  if(data_sets[[x]]$flags$import){
    
    whole_data_set <- whole_data_set %>% 
      bind_rows(data_sets[[x]]$data$tidy_long) %>% 
      arrange(
        Variable,
        GeographyCode,
        DateCode
      )
    
  }
  
}

whole_data_set %>% 
  write.csv(
    file = "data/export/upload-to-open-data-platform.csv",
    quote = FALSE,
    row.names = F
  )
