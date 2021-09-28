# Import rules and settings -----------------------------------------------

print_header("Import rules and script settings")

cat(
  "Reading table importing rules from:\n",
  "- 'import/data-set-rules.csv' (table dimensions, and metadata) ...",
  sep = ""
)

import_metadata <- read_csv(
  file = "import/data-set-rules.csv",
  col_types = cols(
    .default = col_character(),
    import = col_logical(),
    export = col_logical(),
    archived = col_logical(),
    partial = col_logical(),
    row_min = col_integer(),
    col_min = col_integer(),
    row_max = col_integer(),
    col_max = col_integer(),
    skip = col_integer(),
    n_max = col_integer()
  )
)

print_done()

cat("- 'import/data-set-structure.csv' (variable counts, names, and types) ...")

import_table_structure <- read_csv(
  file = "import/data-set-structure.csv",
  col_types = cols(
    .default = col_character(),
    col_id = col_integer()
  )
)

print_done()

# Import metadata ---------------------------------------------------------

print_header("Import table metadata")

# Create an empty list to populate with data
data_sets <- NULL

table_count <- length(import_metadata$data_set_id)

cat(
  "Reading metadata for", table_count, "tables:\n\n"
)

for(i in 1:table_count){
  
  x <- import_metadata$data_set_id[i]
  
  cat(
    "  #", i, "/", table_count, " -- ",
    yellow(x),
    " -- ",
    sep = ""
  )
  
  # Descriptive metadata ------------------------------------------------ #
  
  data_sets[[x]]$metadata <- import_metadata %>% 
    filter(data_set_id == x) %>% 
    select(table_name, table_name_old, description) %>% 
    as.list()
  
  cat(data_sets[[x]]$metadata$table_name, "...")

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
  
  print_done()
  
}

# Read data ---------------------------------------------------------------

print_header("Read data")

table_import_count <- 0L

for(i in 1:table_count){
  if(data_sets[[i]]$flags$import){
    table_import_count <- table_import_count + 1L
  }
}

print_table_action("Reading")

for(i in 1:table_count){
  
  x <- names(data_sets)[i]
  
  if(data_sets[[x]]$flags$import){
    
    print_table_working(i = i, i_max = table_import_count, x = x, short_description = data_sets[[x]]$metadata$table_name)

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
    
    print_done()
    
  }
  
}

# QA: Variable names ------------------------------------------------------

print_break()
print_table_action("Confirming raw variable names for")

for(i in 1:table_import_count){
  
  x <- names(data_sets)[i]
  
  if(data_sets[[x]]$flags$import){
    
    print_table_working(i = i, i_max = table_import_count, x = x, short_description = data_sets[[x]]$metadata$table_name)
    
    data_sets[[x]]$table_structure$variables$actual <- names(data_sets[[x]]$data$raw)
    data_sets[[x]]$table_structure$variables$expected <- data_sets[[x]]$table_structure$col_name_old[data_sets[[x]]$table_structure$col_type != "skip"] %>% 
      str_replace_na(replacement = "")
    
    if(sum(data_sets[[x]]$table_structure$variables$actual != data_sets[[x]]$table_structure$variables$expected) > 0){
      warning("Data set ", x, " does not have the expected (raw) variable names.")
    }
    
    print_done()
    
  }
  
}
