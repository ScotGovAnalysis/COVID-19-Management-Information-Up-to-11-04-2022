# Rename variables --------------------------------------------------------

for(x in names(data_sets)){
  
  if(data_sets[[x]]$flags$import){
    
    table_name <- data_sets[[x]]$metadata$table_name
    
    print(
      paste("Renaming variables in table", x, "--", table_name, "..."),
      quote = FALSE
    )

    data_sets[[x]]$data$new <- data_sets[[x]]$data$raw
    
    names(data_sets[[x]]$data$new) <- data_sets[[x]]$table_structure$col_name_new[data_sets[[x]]$table_structure$col_type != "skip"]
    
  }
  
}

rm(x, table_name)

# QA: Confirm new variable names ------------------------------------------

for(x in names(data_sets)){
  
  if(data_sets[[x]]$flags$import){
    
    table_name <- data_sets[[x]]$metadata$table_name
    variable_names_actual <- names(data_sets[[x]]$data$new)
    variable_names_expected <- data_sets[[x]]$table_structure$col_name_new[data_sets[[x]]$table_structure$col_type != "skip"]
    
    print(
      paste("Confirming new variable names for table", x, "--", table_name, "..."),
      quote = FALSE
    )
    
    if(sum(variable_names_actual != variable_names_expected) > 0){
      warning("After renaming, the data set ", x, " does not have the expected variable names.")
    }
    
    if(variable_names_actual[1] != "Date"){
      warning("After renaming, the data set ", x, " does not have 'Date' as its first column.")
    }
    
  }
  
}

rm(x, table_name, variable_names_actual, variable_names_expected)
