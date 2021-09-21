# Table of statistics -----------------------------------------------------

invisible(sapply("Statistics", function(title){
  
  spacer_width <- options()$width - (str_length(title) + 4)
  
  cat(
    paste0(
      "\n", cyan("--")
    ),
    bold(title),
    paste0(
      cyan(rep("-", spacer_width)),
      collapse = ""
    ),
    "\n\n"
  )
  
}))

cat(
  "The following statistics are intended to help with quality assurance.",
  "They are given for the whole data set.\n\n"
)

cat(
  "Today's date: ", today$iso %>% as.character(), "\n",
  "Latest date: ", whole_data_set$DateCode %>% max() %>% as.character(), "\n",
  "Time difference between today's date and latest date: ", as.integer(today$iso - max(whole_data_set$DateCode)), " days\n",
  "Earliest date: ", whole_data_set$DateCode %>% min() %>% as.character(), "\n\n",
  "Number of observations: ", whole_data_set$Value %>% length(), "\n",
  "NA values dropped: ", na_count_total, "\n\n",
  sep = ""
)

# End of script -----------------------------------------------------------

cat(
  bold(green("Done.")), "\n",
  "End of script.\n",
  sep = ""
)
