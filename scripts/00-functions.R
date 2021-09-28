# Print functions ---------------------------------------------------------

print_break <- function(newlines = 1L){
  cat(
    rep("\n", newlines),
    sep = ""
  )
}

print_done <- function(bold = FALSE, spaces = 1L, newlines = 1L){
  cat(
    rep(" ", spaces),
    ifelse(bold, bold(green("Done.")), green("Done.")),
    rep("\n", newlines),
    sep = ""
  )
}

print_header <- function(x, break_before = TRUE, break_after = TRUE){
  
  right_spacer_width <- options()$width - (nchar(x) + 4)
  
  if(break_before){
    print_break()
  }
  
  cat(
    cyan("--"), " ",
    bold(x), " ",
    cyan(rep("-", right_spacer_width)),
    "\n",
    sep = ""
  )
  
  if(break_after){
    print_break()
  }
  
}

print_table_action <- function(x){
  cat(
    x,
    " ",
    table_import_count,
    "/",
    table_count,
    " tables:\n\n",
    sep = ""
  )
}

print_table_working <- function(i, i_max, x, short_description = NULL){
  cat(
    "  #", i, "/", i_max, " -- ",
    yellow(x),
    if(!is.null(short_description)){
      paste0(" -- ", data_sets[[x]]$metadata$table_name)
    },
    " ...",
    sep = ""
  )
}

truncate_for_print <- function(x, end_length = 16L, max_length_delta = 0L, sep = "[...]", message = "[TRUNCATED]", spacer = TRUE){
  
  x <- as.character(x)
  
  str_len <- nchar(x)
  len_max <- options()$width + as.integer(max_length_delta)
  
  if(str_len > len_max){
    
    sep <- as.character(sep)
    msg <- as.character(message)
    spacer <- as.logical(spacer)
    
    end_len <- as.integer(end_length)
    sep_len <- nchar(sep)
    msg_len <- nchar(msg)
    len_max <- len_max - ifelse(spacer, 3L, 0L)
    
    str_start <- substr(x, 0L, min(str_len, len_max) - sep_len - end_len - msg_len - 1L)
    str_end <- substr(x, str_len - end_len, str_len)
    
    x <- ifelse(
      spacer,
      paste(str_start, sep, str_end, msg),
      paste0(str_start, sep, str_end, msg)
    )
    
  }
  
  return(x)
  
}
