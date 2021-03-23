# Manually fix data for specific data sets --------------------------------

# sc_07a ---------------------------------------------------------------- #

# Convert date column that contains strings (because it is describing an interval) to a true date column
# Use the end-of-week date as the reporting date
data_sets$sc_07a$data$new <- data_sets$sc_07a$data$new %>% 
  mutate(
    Date = Date %>% 
      str_sub(start = -8L) %>% 
      as.Date("%d/%m/%y")
  )

# Tidy data ---------------------------------------------------------------
# Convert data frames into a tidy (long) data format
# For use on https://statistics.gov.scot/

ratio_dictionary_regex <- "( per )|( percent)|( rate)|( ratio)"

for(x in names(data_sets)){
  
  if(data_sets[[x]]$flags$import){
    
    # Fix common errors with data entry and formatting ------------------ #
    
    data_sets[[x]]$data$new <- data_sets[[x]]$data$new %>% 
      # Drop rows where the date is NA
      filter(!is.na(Date)) %>% 
      # Where the variable name contains a word that indicates that it is a ratio, multiply the value by 100
      mutate(
        across(
          matches(ratio_dictionary_regex),
          ~ . * 100
        )
      )
    
    # Pivot data into tidy (long) format -------------------------------- #
    
    data_sets[[x]]$data$tidy_long <- data_sets[[x]]$data$new %>% 
      pivot_longer(
        cols = -Date,
        names_to = "Variable",
        values_to = "Value"
      ) %>% 
      # Measurement type is "Count", unless the variable name contains a word that indicates that it is a ratio
      mutate(
        Measurement = if_else(
          condition = str_detect(str_to_lower(Variable), ratio_dictionary_regex),
          true = "Ratio",
          false = "Count"
        )
      )
    
  }
  
}
