# Rename variables --------------------------------------------------------

print_header("Rename variables")

print_table_action("Renaming variables for")

for(i in 1:table_import_count){
  
  x <- names(data_sets)[i]
  
  if(data_sets[[x]]$flags$import){
    
    print_table_working(i = i, i_max = table_import_count, x = x, short_description = data_sets[[x]]$metadata$table_name)

    data_sets[[x]]$data$new <- data_sets[[x]]$data$raw
    
    names(data_sets[[x]]$data$new) <- data_sets[[x]]$table_structure$col_name_new[data_sets[[x]]$table_structure$col_type != "skip"]
    
    print_done()
    
  }
  
}

# QA: Confirm new variable names ------------------------------------------

print_break()
print_table_action("Confirming new variable names for")

for(i in 1:table_import_count){
  
  x <- names(data_sets)[i]
  
  if(data_sets[[x]]$flags$import){
    
    variable_names_actual <- names(data_sets[[x]]$data$new)
    variable_names_expected <- data_sets[[x]]$table_structure$col_name_new[data_sets[[x]]$table_structure$col_type != "skip"]
    
    print_table_working(i = i, i_max = table_import_count, x = x, short_description = data_sets[[x]]$metadata$table_name)
    
    if(sum(variable_names_actual != variable_names_expected) > 0){
      warning("After renaming, the data set ", x, " does not have the expected variable names.")
    }
    
    if(variable_names_actual[1] != "Date"){
      warning("After renaming, the data set ", x, " does not have 'Date' as its first column.")
    }
    
    print_done()
    
  }
  
}

rm(variable_names_actual, variable_names_expected)
