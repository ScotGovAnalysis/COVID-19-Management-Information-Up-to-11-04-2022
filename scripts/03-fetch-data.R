# Today's date ------------------------------------------------------------
# Used to generate the URLs of the Scottish and Health Boards data sets,
# and used to confirm that the data sets downloaded are up-to-date.

today <- as.list(NULL)
today$iso <- Sys.Date() %>% ymd()
today$year <- today$iso %>% year() %>% as.integer()
today$month <- today$iso %>% month() %>% as.integer()
today$day <- today$iso %>% day() %>% as.integer()
today$month_name <- today$iso %>% month(label = TRUE, abbr = FALSE) %>% as.character()

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

print_header("Fetch data sets")

cat("Generating temporary file paths ...")

sapply(1:length(metadata), function(i) {
  
  temporary_file_path <- tempfile(fileext = ".xlsx")
  
  metadata[[i]]$temporary_file_path <<- temporary_file_path
  
  str_c("tf", i) %>% 
    assign(temporary_file_path, envir = .GlobalEnv)
  
  return()
  
})

print_done()

# Fetch data sets ---------------------------------------------------------

cat("Fetching data sets from remote source, and copying them to temporary local files:\n\n")

sapply(1:length(metadata), function(i) {
  
  i_max <- length(metadata)
  
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
  
  cat(
    "- #", i, "/", i_max, " -- ", yellow(names(metadata[i])), "\n",
    "  Using ", if_else(is.na(url_manual), "automatically generated", "manually entered"), " URL\n",
    "  Remote: ", truncate_for_print(url, max_length_delta = -10L), "\n",
    "  Local: ", truncate_for_print(temporary_file_path, max_length_delta = -9L), "\n",
    "  ...",
    sep = ""
  )
  
  # Save data set as a temporary file
  GET(url, write_disk(temporary_file_path))
  
  print_done()
  
  return()
  
})
