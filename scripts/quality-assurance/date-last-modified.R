# Fetch dates last modified for each dataset ------------------------------

date_table_last_modified <- function(df) {
  df[[1]] %>% max(na.rm = TRUE) %>% ymd() %>% 
    return()
}

# Whole-of-Scotland data ------------------------------------------------ #

metadata[[1]]$date_last_modified$tables$raw_SC_table1 <- date_table_last_modified(raw_SC_table1)
metadata[[1]]$date_last_modified$tables$raw_SC_table2 <- date_table_last_modified(raw_SC_table2)
metadata[[1]]$date_last_modified$tables$raw_SC_table3 <- date_table_last_modified(raw_SC_table3)
metadata[[1]]$date_last_modified$tables$raw_SC_table4 <- date_table_last_modified(raw_SC_table4)
metadata[[1]]$date_last_modified$tables$raw_SC_table5 <- date_table_last_modified(raw_SC_table5)
metadata[[1]]$date_last_modified$tables$raw_SC_table6 <- date_table_last_modified(raw_SC_table6)
metadata[[1]]$date_last_modified$tables$raw_SC_table7b <- date_table_last_modified(raw_SC_table7b)
metadata[[1]]$date_last_modified$tables$raw_SC_table8 <- date_table_last_modified(raw_SC_table8)
metadata[[1]]$date_last_modified$tables$raw_SC_table9a <- date_table_last_modified(raw_SC_table9a)
metadata[[1]]$date_last_modified$tables$raw_SC_table9b <- date_table_last_modified(raw_SC_table9b)
metadata[[1]]$date_last_modified$tables$raw_SC_table10a <- date_table_last_modified(raw_SC_table10a)
metadata[[1]]$date_last_modified$tables$raw_SC_table10b <- date_table_last_modified(raw_SC_table10b)

metadata[[1]]$date_last_modified$data_set <- metadata[[1]]$date_last_modified$tables %>% 
  unlist() %>% max() %>% as.Date(origin = "1970-01-01") %>% ymd()

# Health board data ----------------------------------------------------- #

metadata[[2]]$date_last_modified$tables$raw_HB_table1 <- date_table_last_modified(raw_HB_table1)
metadata[[2]]$date_last_modified$tables$raw_HB_table2 <- date_table_last_modified(raw_HB_table2)
metadata[[2]]$date_last_modified$tables$raw_HB_table3 <- date_table_last_modified(raw_HB_table3)

metadata[[2]]$date_last_modified$data_set <- metadata[[2]]$date_last_modified$tables %>% 
  unlist() %>% max() %>% as.Date(origin = "1970-01-01") %>% ymd()

# Test date last modified -------------------------------------------------
# Return warning if the data sets downloaded were not last updated today

sapply(1:length(metadata), function(i) {
  
  count <- length(metadata)
  name <- names(metadata)[[i]]
  date_last_modified <- metadata[[i]]$date_last_modified$data_set
  date_now <- today$iso
  age <- date_now - date_last_modified
  
  if (age != 0) {
    
    warning(
      str_c(
        "Data set number ", i, " of ", count, " (", name, ") does not seem to be the most recent version.\n  ",
        "It was last updated on ", date_last_modified, " (", age, " days ago)."
      )
    )
    
  }
  
  return()
  
})
