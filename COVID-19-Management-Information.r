# ----------------------------------------------------------------------- #
# SG Covid-19 Weekly Update (Management Information)
# Reformats COVID-19 daily update data for simultaneous upload to
#   https://statistics.gov.scot/ and https://github.com/DataScienceScotland/
# Authors:
# - Victoria Avila (victoria.avila@gov.scot)
# - Miles Drake (miles.drake@gov.scot)
# Open Data Platform:
# - https://statistics.opendata@gov.scot/
# Written for R version 4.0.3 (2020-10-10)
# ----------------------------------------------------------------------- #

# Load required libraries -------------------------------------------------

library(httr)       # GET
library(readxl)     # excel_sheets, read_excel
library(dplyr)      # %>%, if_else, rename, rename_at, mutate
library(lubridate)  # day, month, year, ymd
library(readr)      # read_csv
library(tidyr)      # gather, join, na_if
library(stringr)    # str_c, str_remove, str_replace, bind_rows, left_join

# Manual URL entry --------------------------------------------------------
# If the URL for either data set has changed, replace NA with the new URL
# Eg: metadata$daily_data_trends$url_manual <- "https://gov.scot/new.xlsx"
# This is only necessary if the file naming scheme has changed
# Otherwise, leave this section unchanged

metadata <- as.list(NULL)
metadata$daily_data_trends$url_manual <- NA
metadata$daily_data_by_nhs_board$url_manual <- NA

# Today's date ------------------------------------------------------------
# Used to generate the URLs of the Scottish and Health Boards data sets,
# and used to confirm that the data sets downloaded are up-to-date.

today <- as.list(NULL)
today$iso <- Sys.Date() %>% ymd()
today$year <- today$iso %>% year() %>% as.integer()
today$month <- today$iso %>% month() %>% as.integer()
today$day <- today$iso %>% day() %>% as.integer()
today$month_name <- today$iso %>% month(label = TRUE, abbr = FALSE) %>% as.character()

# Health board codes (2014) -----------------------------------------------
HB_codes <- read_csv("import/health-board-codes.csv")

# Generate data set URLs --------------------------------------------------
# https://www.gov.scot/publications/coronavirus-covid-19-trends-in-daily-data/

# Trends in daily COVID-19 data (Whole-of-Scotland data)
metadata[[1]]$url_auto <- str_c(
  "https://www.gov.scot/",
  "binaries/content/documents/govscot/publications/statistics/2020/04/coronavirus-covid-19-trends-in-daily-data/documents/",
  "trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/",
  "govscot%3Adocument/",
  "COVID-19%2BDaily%2Bdata%2B-%2BTrends%2Bin%2Bdaily%2BCOVID-19%2Bdata%2B-%2B",
  today$day, "%2B", today$month_name, "%2B", today$year, ".xlsx"
)

# COVID-19 data by NHS Board (Health board data)
metadata[[2]]$url_auto <- str_c(
  "https://www.gov.scot/",
  "binaries/content/documents/govscot/publications/statistics/2020/04/coronavirus-covid-19-trends-in-daily-data/documents/",
  "covid-19-data-by-nhs-board/covid-19-data-by-nhs-board/",
  "govscot%3Adocument/",
  "COVID-19%2Bdaily%2Bdata%2B-%2Bby%2BNHS%2BBoard%2B-%2B",
  today$day, "%2B", today$month_name, "%2B", today$year, ".xlsx"
)

# Generate temporary file paths -------------------------------------------

sapply(1:length(metadata), function(i) {
  
  temporary_file_path <- tempfile(fileext = ".xlsx")
  
  metadata[[i]]$temporary_file_path <<- temporary_file_path
  
  str_c("tf", i) %>% 
    assign(temporary_file_path, envir = .GlobalEnv)
  
  return()
  
})

# Fetch data sets ---------------------------------------------------------

sapply(1:length(metadata), function(i) {
  
  temporary_file_path <- metadata[[i]]$temporary_file_path
  url_auto <- metadata[[i]]$url_auto
  url_manual <- metadata[[i]]$url_manual
  
  # If the user has not manually entered a URL for the data set, then use
  # the standard URL, which is automatically generated using today's date
  if (!is.na(url_manual)) {
    url <- url_manual
  } else {
    url <- url_auto
  }
  
  # Save data set as a temporary file
  GET(url, write_disk(temporary_file_path))
  
  return()
  
})

# Read data sets ----------------------------------------------------------
source("scripts/read-data.R")

# Tidy data sets ----------------------------------------------------------
# Rename variables, then convert data frames into a tidy (long) data format
# Variable names are according to the statistics.gov.scot specification
source("scripts/rename-variables.R")
source("scripts/tidy-data.R")


# Export data sets --------------------------------------------------------
source("scripts/export-data.R")

print("Done.", quote = FALSE)
