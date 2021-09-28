# Table of statistics -----------------------------------------------------

print_header("Statistics")

cat(
  "The following statistics are intended to help with quality assurance.\n",
  "They are given for the whole data set.\n\n",
  sep = ""
)

cat(
  "Scripts found in 'scripts/' folder: ", length(script_paths), "\n\n",
  "Tables defined: ", table_count, "\n",
  "Tables flagged for import: ", table_import_count, "\n\n",
  "Today's date: ", today$iso %>% as.character(), "\n",
  "Latest date: ", whole_data_set$DateCode %>% max() %>% as.character(), "\n",
  "Time difference between today's date and latest date: ", as.integer(today$iso - max(whole_data_set$DateCode)), " days\n",
  "Earliest date: ", whole_data_set$DateCode %>% min() %>% as.character(), "\n\n",
  "Number of observations: ", whole_data_set$Value %>% length(), "\n",
  "NA values dropped: ", na_count_total, "\n\n",
  sep = ""
)

# End of script -----------------------------------------------------------

print_done(bold = TRUE)
