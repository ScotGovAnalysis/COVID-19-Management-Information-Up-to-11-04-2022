print_header("Tidying data")

# Define variables --------------------------------------------------------

na_count_total <- 0L

# Manually fix data for specific data sets --------------------------------

cat("Applying fixes for specific tables ...")

## Convert string columns to dates ----------------------------------------

# sc_06_2
data_sets$sc_06_2$data$new <- data_sets$sc_06_2$data$new %>% 
  mutate(
    Date = Date %>% 
      str_sub(start = -10L) %>% 
      as.Date("%d/%m/%Y")
  )

# sc_07a
data_sets$sc_07a$data$new <- data_sets$sc_07a$data$new %>% 
  mutate(
    Date = Date %>% 
      str_sub(start = -8L) %>% 
      as.Date("%d/%m/%y")
  )

print_done()

# Tidy data ---------------------------------------------------------------
# Convert data frames into a tidy (long) data format
# For use on https://statistics.gov.scot/

ratio_dictionary_regex <- "( per )|(percent)|(rate)|(ratio)"

print_table_action("Tidying")

for(i in 1:table_import_count){
  
  x <- names(data_sets)[i]
  
  if(data_sets[[x]]$flags$import){
    
    print_table_working(i = i, i_max = table_import_count, x = x, short_description = data_sets[[x]]$metadata$table_name)
    
    # Fix common errors with data entry and formatting ------------------ #
    
    data_sets[[x]]$data$new <- data_sets[[x]]$data$new %>% 
      # Drop rows where the date is NA
      # NA values in other columns are treated as valid data
      filter(!is.na(Date)) %>% 
      # Remove timezone information from date variable
      mutate(
        Date = ymd(Date)
      ) %>% 
      # Where the variable name contains a word that indicates that it is a
      # ratio, multiply the value by 100
      mutate(
        across(
          matches(ratio_dictionary_regex, ignore.case = TRUE),
          ~ . * 100
        )
      )
    
    # Pivot data into tidy (long) format -------------------------------- #
    
    # Health board data needs special rules, because the column names
    # indicate the health board rather than the variable being measured;
    # instead, read the variable name from the metadata CSV file
    
    if(data_sets[[x]]$import_rules$source == "hb"){
      
      # Health board data
      data_sets[[x]]$data$tidy_long <- data_sets[[x]]$data$new %>% 
        pivot_longer(
          cols = -Date,
          names_to = "HBname",
          values_to = "Value"
        ) %>% 
        left_join(
          HB_codes,
          by = c(HBname = "HB2014Name")
        ) %>% 
        mutate(
          Variable = data_sets[[x]]$export_rules$variable_name
        )%>% 
        group_by(HBname) %>% 
        arrange(Date, .by_group = TRUE) %>% 
        ungroup()
      
    } else {
      
      # Whole-of-Scotland data
      data_sets[[x]]$data$tidy_long <- data_sets[[x]]$data$new %>% 
        pivot_longer(
          cols = -Date,
          names_to = "Variable",
          values_to = "Value"
        ) %>% 
        mutate(
          HBname = NA,
          HB2014Code = "S92000003"
        )
      
    }
    
    # Drop NA values ---------------------------------------------------- #
    
    # Now that the data is in tidy (long) format, and the Values variables
    # all have the same name, this is a good time to easily drop NA values
    
    na_count <- data_sets[[x]]$data$tidy_long %>% 
      select(Value) %>% 
      filter(is.na(Value)) %>% 
      unlist() %>% 
      length()
    
    na_count_total <- na_count_total + na_count
    
    if(na_count > 0){
      
      cat(
        "\n  - Removing",
        na_count,
        "NA values",
        "..."
      )
      
      data_sets[[x]]$data$tidy_long <- data_sets[[x]]$data$tidy_long %>% 
        filter(!is.na(Value))
      
    }
    
    # Add Measurement and Unit variables -------------------------------- #
    
    data_sets[[x]]$data$tidy_long <- data_sets[[x]]$data$tidy_long %>% 
      mutate(
        # Measurement type is "Count", unless the variable name contains a
        # word that indicates that it is a ratio
        Measurement = if_else(
          condition = str_detect(str_to_lower(Variable), ratio_dictionary_regex),
          true = "Ratio",
          false = "Count"
        ),
        "Units" = Variable,
        # Coerce Value to string, to support health board data's use of *
        Value = as.character(Value)
      ) %>% 
      # Order variables appropriately, drop health board names, and name
      # variables according to https://statistics.gov.scot/ standards
      select(
        GeographyCode = HB2014Code,
        DateCode = Date,
        Measurement, 
        Units,
        Value,
        Variable
      )
    
    print_done()
    
  }
  
}

# Feedback ----------------------------------------------------------------

cat(
  "\nRemoved a total of",
  na_count_total,
  "NA values from all tables.\n"
)
