# ----------------------------------------------------------------------- #
# Scottish Government COVID-19 Management Information Weekly Update
# Reformats COVID-19 daily update data for simultaneous upload to both
#   GitHub and the Open Data Platform
# Authors:
# - Victoria Avila (victoria.avila@gov.scot)
# - Miles Drake (miles.drake@gov.scot)
# Open Data Platform:
# - https://statistics.opendata@gov.scot/
# The latest version of this script can be found at:
# - https://github.com/DataScienceScotland/COVID-19-Management-Information
# Written with R version 4.0.3 (2020-10-10)
# ----------------------------------------------------------------------- #

# Load required libraries -------------------------------------------------

library(crayon)     # Console message formatting
library(httr)       # GET
library(readxl)     # excel_sheets, read_excel
library(dplyr)      # %>%, if_else, rename, rename_at, mutate
library(lubridate)  # day, month, year, ymd
library(readr)      # read_csv
library(tidyr)      # gather, join, na_if
library(stringr)    # str_c, str_remove, str_replace, bind_rows, left_join

# Run scripts -------------------------------------------------------------

# Run each script that is found in the "scripts/" subdirectory
# Scripts are ran in alphanumeric order

script_paths <- as.list(
  paste0(
    "scripts/",
    # Get the complement of both files and folders in "scripts/"
    # This workaround is necessary since list.files() also returns folders
    setdiff(
      list.files(path = "scripts/"),
      list.dirs(path = "scripts/", full.names = FALSE, recursive = FALSE)
    )
  )
)

invisible(sapply(
  script_paths,
  function(i){
    source(i, echo = FALSE)
  }
))
