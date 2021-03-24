# Export data -------------------------------------------------------------

# Write whole data set for export to statistics.gov.scot ------------------

whole_data_set <- NULL

for(x in names(data_sets)){
  
  if(data_sets[[x]]$flags$export){
    
    print(
      paste("Exporting table", x, "--", data_sets[[x]]$metadata$table_name, "..."),
      quote = FALSE
    )
    
    export_path_new <- str_c(
      "data/export/",
      case_when(
        data_sets[[x]]$import_rules$source == "hb" ~ "health-boards/",
        data_sets[[x]]$import_rules$source == "sc" ~ "scotland/",
      ),
      data_sets[[x]]$export_rules$export_filename_new,
      ".csv"
    )
    
    export_path_old <- str_c(
      "data/export/old-file-structure/",
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
    
  }
  
}

whole_data_set %>% write_csv("data/export/upload-to-open-data-platform.csv")
whole_data_set %>% write_csv("data/export/old-file-structure/COVID19 - Daily Management Information - Tidy dataset to upload to statistics.gov.scot.csv")

print("Done.", quote = FALSE)
