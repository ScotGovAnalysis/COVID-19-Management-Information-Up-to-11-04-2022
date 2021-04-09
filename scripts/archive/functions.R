# Metadata functions ------------------------------------------------------

# Fetch dates last modified for each dataset ---------------------------- #

date_table_last_modified <- function(df) {
  df[[1]] %>% max(na.rm = TRUE) %>% ymd() %>% 
    return()
}

# Quality assurance functions ---------------------------------------------

# Confirm that the number of variables in each data set matches the expected value
test_variable_count <- function(df, expected_variable_count){

  variable_count <- length(df)
  
  if(variable_count != expected_variable_count){
    warning(
      str_c(
        "Data frame does not contain the expected number of variables.\n  ",
        "Counted ", variable_count, " variables, expected ", expected_variable_count, "."
      )
    )
  }
  
  invisible()
  
}

# Confirm that the name of each variable in each data set matches the expected value
# TODO Variable count should be implicit from the variable names being defined
test_variable_names <- function(df, expected_variable_names){
  
  variable_count <- length(df)
  variable_names <- names(df)
  
  compare_variable_names <- variable_names == expected_variable_names
  
  same_variable_name_count <- compare_variable_names %>% 
    as.integer() %>% 
    sum()
  
  if(same_variable_name_count != variable_count){
    warning(
      str_c(
        "Data frame does not have the expected variable names.\n  ",
        variable_count - same_variable_name_count, " variables have unexpected names, or are in an unexpected order."
      )
    )
  }
  
  invisible()
  
}
