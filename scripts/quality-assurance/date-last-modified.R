# Prompt the user if the data sets downloaded were not last updated today

sapply(1:length(metadata), function(i) {
  
  name <- names(metadata)[[i]]
  date_last_modified <- metadata[[i]]$date_last_modified$data_set
  date_now <- today$iso
  age <- date_now - date_last_modified
  
  if (age != 0) {
    
    warning(
      str_c(
        "Data set number ", i, " (", name, ") does not seem to be the most recent version.\n  ",
        "It was last updated on ", date_last_modified, " (", age, " days ago)."
      )
    )
    
  }
  
  return()
  
})
