# Read metadata -----------------------------------------------------------

cat(
  "Reading table importing rules from:",
  "- import/data-set-rules.csv (table dimensions, and metadata).",
  "- import/data-set-structure.csv (variable counts, names, and types).",
  "",
  sep = "\n"
)

import_metadata <- read_csv("import/data-set-rules.csv")
import_table_structure <- read_csv("import/data-set-structure.csv")

# Create an empty list to populate with data
data_sets <- NULL

cat(
  "Reading rules for", length(import_metadata$data_set_id), "tables:\n"
)

for(it in 1:length(import_metadata$data_set_id)){
  
  it_max <- length(import_metadata$data_set_id)
  x <- import_metadata$data_set_id[it]
  
  cat(
    "  #", it, "/", it_max, " -- ",
    yellow(x),
    sep = ""
  )
  
  # Descriptive metadata ------------------------------------------------ #
  
  data_sets[[x]]$metadata <- import_metadata %>% 
    filter(data_set_id == x) %>% 
    select(table_name, table_name_old, description) %>% 
    as.list()
  
  cat(" --", data_sets[[x]]$metadata$table_name, "...\n")

  # Flags --------------------------------------------------------------- #
  # Used to simplify if statements, debugging, and for quality assurance
  
  data_sets[[x]]$flags <- import_metadata %>% 
    filter(data_set_id == x) %>% 
    select(import, export, archived, partial) %>% 
    as.list()
  
  # read_excel() rules -------------------------------------------------- #
  
  data_sets[[x]]$import_rules <- import_metadata %>% 
    filter(data_set_id == x) %>% 
    select(source, sheet, na, skip, n_max) %>% 
    as.list()
  
  # Vectorise NA rules
  # This allows multiple NA values to be defined in metadata.csv
  if(!is.na(data_sets[[x]]$import_rules$na)){
    data_sets[[x]]$import_rules$na <- data_sets[[x]]$import_rules$na %>% 
      str_split(";") %>% 
      unlist()
  }
  
  # Cell limits --------------------------------------------------------- #
  # Try to leave as many cell limits open as possible (especially col_max)
  # This will allow read_excel() to detect the addition of new columns
  
  data_sets[[x]]$import_rules$cell_limits <- import_metadata %>% 
    filter(data_set_id == x) %>% 
    select(row_min, col_min, row_max, col_max) %>% 
    as.list()
  
  # If cell limits have been explicitly defined, set a flag
  data_sets[[x]]$flags$cell_limits_defined <- FALSE
  
  for(y in data_sets[[x]]$import_rules$cell_limits){
    if(!is.na(y) && data_sets[[x]]$flags$cell_limits_defined == FALSE){
      data_sets[[x]]$flags$cell_limits_defined <- TRUE
    }
  }
  
  # Export rules -------------------------------------------------------- #
  
  data_sets[[x]]$export_rules <- import_metadata %>% 
    filter(data_set_id == x) %>% 
    select(export_filename_new, export_filename_old, variable_name) %>% 
    as.list()
  
  # Table structure ----------------------------------------------------- #
  # Column names, column types, etc.

  data_sets[[x]]$table_structure <- import_table_structure %>% 
    filter(data_set_id == x) %>% 
    select(-data_set_id) %>% 
    as.list()
  
}

cat(
  "  ", crayon::green("Done."), "\n\n", sep = ""
)

# Read data ---------------------------------------------------------------

for(x in names(data_sets)){
  
  if(data_sets[[x]]$flags$import){
    
    print(
      paste("Importing table", x, "--", data_sets[[x]]$metadata$table_name, "..."),
      quote = FALSE
    )

    data_sets[[x]]$data$raw <- read_excel(
      
      path = case_when(
        data_sets[[x]]$import_rules$source == "sc" ~ tf1,
        data_sets[[x]]$import_rules$source == "hb" ~ tf2
      ),
      
      sheet = data_sets[[x]]$import_rules$sheet,
      
      range = if(data_sets[[x]]$flags$cell_limits_defined == TRUE){
        cell_limits(
          ul = c(
            data_sets[[x]]$import_rules$cell_limits$row_min,
            data_sets[[x]]$import_rules$cell_limits$col_min
          ),
          lr = c(
            data_sets[[x]]$import_rules$cell_limits$row_max,
            data_sets[[x]]$import_rules$cell_limits$col_max
          )
        )
      } else {
        NULL
      },
      
      # Explicitly define the expected columns, using col_types
      # This will cause errors (and terminate) if the table structure has changed
      # This is intended behaviour, and indicates to the user not to publish
      # Change /data/import/table-structure.csv to reflect the changed columns
      col_types = if(length(data_sets[[x]]$table_structure$col_type) > 0){
        data_sets[[x]]$table_structure$col_type
      } else {
        NULL
      },
      
      na = if(sum(!is.na(data_sets[[x]]$import_rules$na)) > 0){
        data_sets[[x]]$import_rules$na
      } else {
        ""
      },
      
      skip = if(!is.na(data_sets[[x]]$import_rules$skip)){
        data_sets[[x]]$import_rules$skip
      } else {
        0
      },
      
      .name_repair = "minimal"
      
    )
    
    # Fix variable names (remove carriage returns and line feeds)
    names(data_sets[[x]]$data$raw) <- names(data_sets[[x]]$data$raw) %>% 
      str_remove_all("\\r\\n")
    
  }
  
}

# QA: Variable names ------------------------------------------------------

for(x in names(data_sets)){
  
  if(data_sets[[x]]$flags$import){
    
    print(
      paste("Confirming raw variable names for table", x, "--", data_sets[[x]]$metadata$table_name, "..."),
      quote = FALSE
    )
    
    data_sets[[x]]$table_structure$variables$actual <- names(data_sets[[x]]$data$raw)
    data_sets[[x]]$table_structure$variables$expected <- data_sets[[x]]$table_structure$col_name_old[data_sets[[x]]$table_structure$col_type != "skip"] %>% 
      str_replace_na(replacement = "")
    
    if(sum(data_sets[[x]]$table_structure$variables$actual != data_sets[[x]]$table_structure$variables$expected) > 0){
      warning("Data set ", x, " does not have the expected (raw) variable names.")
    }
    
  }
  
}
