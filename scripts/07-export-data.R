# Export data -------------------------------------------------------------

print_header("Export data")

# Export individual tables ------------------------------------------------

cat("Exporting individual tables.\n")
print_table_action("Exporting")

whole_data_set <- NULL

for(i in 1:table_import_count){
  
  x <- names(data_sets)[i]
  
  if(data_sets[[x]]$flags$export){
    
    print_table_working(i = i, i_max = table_import_count, x = x, short_description = data_sets[[x]]$metadata$table_name)
    
    export_path_new <- str_c(
      "export/",
      case_when(
        data_sets[[x]]$import_rules$source == "hb" ~ "health-boards/",
        data_sets[[x]]$import_rules$source == "sc" ~ "scotland/"
      ),
      data_sets[[x]]$export_rules$export_filename_new,
      ".csv"
    )
    
    export_path_old <- str_c(
      "export/old-file-structure/",
      data_sets[[x]]$export_rules$export_filename_old,
      ".csv"
    )
    
    data_sets[[x]]$data$new %>% write_csv(export_path_new)
    data_sets[[x]]$data$new %>% write_csv(export_path_old)
    
    whole_data_set <- whole_data_set %>% 
      bind_rows(data_sets[[x]]$data$tidy_long) %>% 
      # Sort to keep like variables and health boards together
      arrange(
        Variable,
        GeographyCode,
        DateCode
      )
    
    print_done()
    
  }
  
}

# Export whole data set ---------------------------------------------------
# Export in tidy format, for use on statistics.gov.scot

print_break()
cat("Exporting whole data set to:\n\n")

whole_df_export_path <- as.list(NULL)
whole_df_export_path["New file structure"] <- "export/upload-to-open-data-platform.csv"
whole_df_export_path["Old file structure"] <- "export/old-file-structure/COVID19 - Daily Management Information - Tidy dataset to upload to statistics.gov.scot.csv"

for(i in 1:length(whole_df_export_path)){
  
  i_max <- length(whole_df_export_path)
  path <- whole_df_export_path[[i]]
  
  path_name <- names(whole_df_export_path[i])
  path_print <- truncate_for_print(
    x = paste0("'", path, "'"),
    max_length_delta = -2L
  )
  
  cat(
    "- #", i, "/", i_max, " -- ", path_name, "\n",
    "  ", path_print, "\n",
    "  ...",
    sep = ""
  )
  
  whole_data_set %>% write_csv(path)
  
  print_done()
    
}
