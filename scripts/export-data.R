whole_data_set <- NULL

for(x in names(data_sets)){
  
  if(data_sets[[x]]$flags$import){
    
    # Convert 
    # This is necessary because the health board data uses "*" to indicate an obfuscated entry
    
    whole_data_set <- whole_data_set %>% 
      bind_rows(data_sets[[x]]$data$tidy_long)
    
  }
  
}
