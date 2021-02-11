# Test variable count -----------------------------------------------------
# Confirm that the number of values read in each data set matches the
# expected value

test_expected_variable_count <- function(df, expected_variable_count){
  
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

# Whole-of-Scotland data ------------------------------------------------ #

raw_SC_table1   %>% test_expected_variable_count(3)
raw_SC_table2   %>% test_expected_variable_count(4)
raw_SC_table3   %>% test_expected_variable_count(4)
raw_SC_table4   %>% test_expected_variable_count(2)
raw_SC_table5   %>% test_expected_variable_count(19)
raw_SC_table6   %>% test_expected_variable_count(5)
raw_SC_table7b  %>% test_expected_variable_count(6)
raw_SC_table8   %>% test_expected_variable_count(2)
raw_SC_table9a  %>% test_expected_variable_count(5)
raw_SC_table9b  %>% test_expected_variable_count(5)
raw_SC_table10a %>% test_expected_variable_count(3)
raw_SC_table10b %>% test_expected_variable_count(11)

# Health board data ----------------------------------------------------- #

raw_HB_table1   %>% test_expected_variable_count(15)
raw_HB_table2   %>% test_expected_variable_count(16)
raw_HB_table3   %>% test_expected_variable_count(16)
