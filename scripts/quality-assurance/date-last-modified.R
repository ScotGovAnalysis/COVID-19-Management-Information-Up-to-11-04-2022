# Prompt the user if the data sets downloaded were not last updated today

sapply(1:length(metadata), function(i) {
  
  name <- names(metadata)[[i]]
  date_last_modified <- metadata[[i]]$date_last_modified$data_set
  date_now <- today$iso
  age <- date_now - date_last_modified
  
  if (age != 0) {
    
    error_message <- str_c(
      "Data set number ", i, " (", name, ") does not seem to be the most recent version.\n",
      "It was last updated on ", date_last_modified, ".\n",
      "Today is ", date_now, ".\n",
      "This data set was last updated ", age, " days ago.\n",
      "Press [Enter] in the console window to continue."
    )
    
    readline(prompt = error_message) %>% invisible()
    
  }
  
  return()
  
})
