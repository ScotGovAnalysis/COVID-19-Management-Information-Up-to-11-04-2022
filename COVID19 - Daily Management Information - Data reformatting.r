# ------------------------------------------------------------------------------
# Title - SG Covid-19 daily update (Management Information)
# Purpose - Reformatting Covid-19 daily update data to upload to 
#           statistics.gov.scot and github.com/DataScienceScotland
# Authors:
# - Victoria Avila (victoria.avila@gov.scot)
# - Miles Drake (miles.drake@gov.scot)
# Open Data info - statistics.opendata@gov.scot
# Date created - 17/04/2020
# Last updated - 27/01/2021
# ------------------------------------------------------------------------------

# [0] Loading libraries --------------------------------------------------------
library(httr)      # GET
library(readxl)    # excel_sheets, read_excel
library(dplyr)     # %>%, if_else, rename, rename_at, mutate
library(lubridate) # day, month, year, ymd
library(tidyr)     # gather, join, na_if
library(stringr)   # str_c, str_remove, str_replace, bind_rows, left_join

# [1a] Manual URL overrides -----------------------------------------------
# If the URLs for the data sets have changed, replace NAs with the URLs
metadata <- as.list(NULL)
metadata$daily_data_trends$url_manual <- NA
metadata$daily_data_by_nhs_board$url_manual <- NA

# [1b] Health Board 2014 codes --------------------------------------------
HB_codes <- tribble(
  ~HB2014Code, ~HB2014Name,
  "S08000015",	"Ayrshire and Arran",
  "S08000016",	"Borders",
  "S08000017",	"Dumfries and Galloway",
  "S08000019",	"Forth Valley",
  "S08000020",	"Grampian",
  "S08000022",	"Highland",
  "S08000024",	"Lothian",
  "S08000025",	"Orkney",
  "S08000026",	"Shetland",
  "S08000028",	"Western Isles",
  "S08000029",	"Fife",
  "S08000030",	"Tayside",
  "S08000031",	"Greater Glasgow and Clyde",
  "S08000032",	"Lanarkshire",
  "SB0801",     "The Golden Jubilee National Hospital"
)

# [1c] Today's date -------------------------------------------------------
today <- as.list(NULL)
today$iso <- Sys.Date() %>% ymd()
today$day <- today$iso %>% day() %>% as.integer()
today$month <- today$iso %>% month() %>% as.integer()
today$month_name <- today$iso %>% month(label = TRUE, abbr = FALSE) %>% as.character()
today$year <- today$iso %>% year() %>% as.integer()

# [2a] Reading original files from website --------------------------------
# Fetch today's data sets
# Generate the URLs to the data sets using the date generated above
# https://www.gov.scot/publications/coronavirus-covid-19-trends-in-daily-data/

# Trends in daily COVID-19 data
metadata[[1]]$url_auto <- str_c(
  "https://www.gov.scot/",
  "binaries/content/documents/govscot/publications/statistics/2020/04/coronavirus-covid-19-trends-in-daily-data/documents/",
  "trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/",
  "govscot%3Adocument/",
  "COVID-19%2BDaily%2Bdata%2B-%2BTrends%2Bin%2Bdaily%2BCOVID-19%2Bdata%2B-%2B",
  today$day, "%2B", today$month_name, "%2B", today$year, ".xlsx"
)

# COVID-19 data by NHS Board
metadata[[2]]$url_auto <- str_c(
  "https://www.gov.scot/",
  "binaries/content/documents/govscot/publications/statistics/2020/04/coronavirus-covid-19-trends-in-daily-data/documents/",
  "covid-19-data-by-nhs-board/covid-19-data-by-nhs-board/",
  "govscot%3Adocument/",
  "COVID-19%2Bdaily%2Bdata%2B-%2Bby%2BNHS%2BBoard%2B-%2B",
  today$day, "%2B", today$month_name, "%2B", today$year, ".xlsx"
)

# Generate temporary file paths to write the downloaded data sets to
sapply(1:length(metadata), function(i) {
  
  temporary_file_path <- tempfile(fileext = ".xlsx")
  
  metadata[[i]]$temporary_file_path <<- temporary_file_path
  
  str_c("tf", i) %>% 
    assign(temporary_file_path, envir = .GlobalEnv)
  
  return()
  
})

# Fetch the data sets from gov.scot, and write them to disk
# If user overrides are not given for each URL, then use the URLs automatically
# generated from today's date
sapply(1:length(metadata), function(i) {
  
  temporary_file_path <- metadata[[i]]$temporary_file_path
  url_auto <- metadata[[i]]$url_auto
  url_manual <- metadata[[i]]$url_manual
  
  if (!is.na(url_manual)) {
    url <- url_manual
  } else {
    url <- url_auto
  }
  
  GET(url, write_disk(temporary_file_path))
  
  return()
  
})

# [2b] Reading original files locally ------------------------------------------
# Use this option if using a SCOTS machine
#
# Download files from:
# https://www.gov.scot/publications/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/
# Modify to use your own folder and file names
#
#path <- "C:/Users/Victoria/Downloads/" 
#tf1 <- paste0(path, "Trends+in+daily+COVID-19+data+050520.xlsx")
#tf2 <- paste0(path, "COVID-19+data+by+NHS+Board-050520.xlsx")

# [3a] Saving individual tables -------------------------------------------------
raw_SC_table1  <- read_excel(tf1, "Table 1 - NHS 24", skip = 2)
raw_SC_table2_archived  <- read_excel(tf1, "Table 2 - Archive Hospital Care", skip = 3)[,-8]
raw_SC_table2  <- read_excel(tf1, "Table 2 - Hospital Care", skip = 2)
raw_SC_table3  <- read_excel(tf1, "Table 3 - Ambulance", skip = 2)[,-1]
raw_SC_table4  <- read_excel(tf1, "Table 4 - Delayed Discharges", skip = 2)[,-1]
raw_SC_table5  <- read_excel(tf1, "Table 5 - Testing", skip = 2)[-1,-c(20,21)]
raw_SC_table6  <- read_excel(tf1, "Table 6 - Workforce", skip = 1, n_max = 112) 
# raw_SC_table7a <- read_excel(tf1, "Table 7a - Care Homes", skip = 2, n_max = 105)[-1, -c(5,10)]
raw_SC_table7b <- read_excel(tf1, "Table 7b - Care Home Workforce", skip = 1)
raw_SC_table8  <- read_excel(tf1, "Table 8 - Deaths", skip = 2)[, 1:2]
# Table 9 / 9a: Daily attendance and absence in schools in Scotland
raw_SC_table9a  <- read_excel(tf1, "Table 9 - School education", skip = 2, n_max = 93)[, 1:5]
# Table 9b: Percentage of pupils in attendance at school (2021)
raw_SC_table9b  <- read_excel(tf1, "Table 9 - School education", skip = 98)[, 1:5]
# Table 10a: Daily COVID-19 vaccinations in Scotland
# Number of people who have received the Covid vaccination
raw_SC_table10a <- read_excel(tf1, "Table 10a - Vaccinations", skip = 2)[, 1:3]
# Table 10b: Daily COVID-19 vaccinations in Scotland by JCVI Priority Group
# Number of people who have received the Covid vaccination by JCVI priority group
raw_SC_table10b <- read_excel(tf1, "Table 10b - Vac by JCVI group", skip = 3)[, c(1, 2, 4, 6, 7, 9, 11, 12, 14, 15, 17)]

raw_HB_table1  <- read_excel(tf2, "Table 1 - Cumulative cases", skip = 2)[,-c(16:18)]

# TODO 2b is continuation of old table 2, decide what to do with 2.b as being ignored just now

raw_HB_table2a_archived  <- read_excel(tf2, "Table 2 - ICU (Hist.)", skip = 2)[, -c(17:35)]
colnames(raw_HB_table2a_archived) <- c("Date",
                                       "NHS Ayrshire & Arran",
                                       "NHS Borders",
                                       "NHS Dumfries & Galloway",
                                       "NHS Fife",
                                       "NHS Forth Valley",
                                       "NHS Grampian",
                                       "NHS Greater Glasgow & Clyde",
                                       "NHS Highland",
                                       "NHS Lanarkshire",
                                       "NHS Lothian",
                                       "NHS Orkney",
                                       "NHS Shetland",
                                       "NHS Tayside",
                                       "NHS Western Isles",              
                                       "Golden Jubilee National Hospital")

raw_HB_table2b_archived  <- read_excel(tf2, "Table 2 - ICU (Hist.)", skip = 2, n_max = 126)[, -c(1:18, 35)]
colnames(raw_HB_table2b_archived) <- c("Date",
                                       "NHS Ayrshire & Arran",
                                       "NHS Borders",
                                       "NHS Dumfries & Galloway",
                                       "NHS Fife",
                                       "NHS Forth Valley",
                                       "NHS Grampian",
                                       "NHS Greater Glasgow & Clyde",
                                       "NHS Highland",
                                       "NHS Lanarkshire",
                                       "NHS Lothian",
                                       "NHS Orkney",
                                       "NHS Shetland",
                                       "NHS Tayside",
                                       "NHS Western Isles",              
                                       "Golden Jubilee National Hospital")

# To bring in both tables:
# raw_HB_table2a  <- read_excel(tf2, "Table 2a - ICU patients", skip = 2)[, -17]
# raw_HB_table2b  <- read_excel(tf2, "Table 2b - ICU patients (Hist.)", skip = 2)[, -17]

raw_HB_table2  <- read_excel(tf2, "Table 2 - ICU patients", skip = 2)[, -17]


raw_HB_table3a_archived <- read_excel(tf2, "Table 3- Hospital (Hist.)", skip = 2)[, -c(17:37)]
colnames(raw_HB_table3a_archived) <- c("Date",
                                       "NHS Ayrshire & Arran",
                                       "NHS Borders",
                                       "NHS Dumfries & Galloway",
                                       "NHS Fife",
                                       "NHS Forth Valley",
                                       "NHS Grampian",
                                       "NHS Greater Glasgow & Clyde",
                                       "NHS Highland",
                                       "NHS Lanarkshire",
                                       "NHS Lothian",
                                       "NHS Orkney",
                                       "NHS Shetland",
                                       "NHS Tayside",
                                       "NHS Western Isles",              
                                       "Golden Jubilee National Hospital")

raw_HB_table3b_archived <- read_excel(tf2, "Table 3- Hospital (Hist.)", skip = 2, n_max = 118)[ -c(1:18, 35:37)]
colnames(raw_HB_table3b_archived) <- c("Date",
                                       "NHS Ayrshire & Arran",
                                       "NHS Borders",
                                       "NHS Dumfries & Galloway",
                                       "NHS Fife",
                                       "NHS Forth Valley",
                                       "NHS Grampian",
                                       "NHS Greater Glasgow & Clyde",
                                       "NHS Highland",
                                       "NHS Lanarkshire",
                                       "NHS Lothian",
                                       "NHS Orkney",
                                       "NHS Shetland",
                                       "NHS Tayside",
                                       "NHS Western Isles",              
                                       "Golden Jubilee National Hospital")


raw_HB_table3  <- read_excel(tf2, "Table 3 - Hospital patients", skip = 2)[, -17]

#unlink(tf1)
#unlink(tf2)

# [3b] Fetch dates last modified for each dataset -------------------------

date_table_last_modified <- function(df) {
  df[[1]] %>% max(na.rm = TRUE) %>% ymd() %>% 
    return()
}

# Scottish data set
metadata[[1]]$date_last_modified$tables$raw_SC_table1 <- date_table_last_modified(raw_SC_table1)
metadata[[1]]$date_last_modified$tables$raw_SC_table2 <- date_table_last_modified(raw_SC_table2)
metadata[[1]]$date_last_modified$tables$raw_SC_table3 <- date_table_last_modified(raw_SC_table3)
metadata[[1]]$date_last_modified$tables$raw_SC_table4 <- date_table_last_modified(raw_SC_table4)
metadata[[1]]$date_last_modified$tables$raw_SC_table5 <- date_table_last_modified(raw_SC_table5)
metadata[[1]]$date_last_modified$tables$raw_SC_table6 <- date_table_last_modified(raw_SC_table6)
metadata[[1]]$date_last_modified$tables$raw_SC_table7b <- date_table_last_modified(raw_SC_table7b)
metadata[[1]]$date_last_modified$tables$raw_SC_table8 <- date_table_last_modified(raw_SC_table8)
metadata[[1]]$date_last_modified$tables$raw_SC_table9a <- date_table_last_modified(raw_SC_table9a)
metadata[[1]]$date_last_modified$tables$raw_SC_table9b <- date_table_last_modified(raw_SC_table9b)
metadata[[1]]$date_last_modified$tables$raw_SC_table10a <- date_table_last_modified(raw_SC_table10a)
metadata[[1]]$date_last_modified$tables$raw_SC_table10b <- date_table_last_modified(raw_SC_table10b)

metadata[[1]]$date_last_modified$data_set <- metadata[[1]]$date_last_modified$tables %>% 
  unlist() %>% max() %>% as.Date(origin = "1970-01-01") %>% ymd()

# Health board data set
metadata[[2]]$date_last_modified$tables$raw_HB_table1 <- date_table_last_modified(raw_HB_table1)
metadata[[2]]$date_last_modified$tables$raw_HB_table2 <- date_table_last_modified(raw_HB_table2)
metadata[[2]]$date_last_modified$tables$raw_HB_table3 <- date_table_last_modified(raw_HB_table3)

metadata[[2]]$date_last_modified$data_set <- metadata[[2]]$date_last_modified$tables %>% 
  unlist() %>% max() %>% as.Date(origin = "1970-01-01") %>% ymd()

# [3c] Quality assurance --------------------------------------------------
# Prompt the user if the data sets downloaded do not appear to be today's
sapply(1:length(metadata), function(i) {
  
  name <- names(metadata)[[i]]
  date_last_modified <- metadata[[i]]$date_last_modified$data_set
  date_now <- today$iso
  age <- date_now - date_last_modified
  
  if (age != 0) {
    
    error_message <- str_c(
      "Data set number ", i, " (", name, ") does not seem to be the most recent version.\n",
      "It was last updated on ", date_last_modified, ".\n",
      "Today is ", date_now, ".\n",
      "This data set was last updated ", age, " days ago.\n",
      "Press [Enter] in the console window to continue."
    )
    
    readline(prompt = error_message) %>% invisible()
    
  }
  
  return()
  
})

# [4] Renaming variables -------------------------------------------------------
SC_table1 <- raw_SC_table1 %>%
  rename("Calls - NHS24 111" = "NHS24 111 Calls",
         "Calls - Coronavirus helpline" = "Coronavirus Helpline Calls")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table2_archived <- raw_SC_table2_archived
# Renaming variables in this table the old way because different package versions
# create different default names for variables
names(SC_table2_archived) <- c("Date",
                               "COVID-19 patients in ICU - Confirmed (archived)",
                               "COVID-19 patients in ICU - Suspected (archived)",
                               "COVID-19 patients in ICU - Total (archived)",
                               "COVID-19 patients in hospital - Confirmed (archived)",
                               "COVID-19 patients in hospital - Suspected (archived)",
                               "COVID-19 patients in hospital - Total (archived)")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table2 <- raw_SC_table2 %>%
  rename("Date" = "Reporting Date",
         "COVID-19 patients in ICU - Confirmed" = "(i) COVID-19 patients in ICU\r\n or combined ICU/HDU",
         "COVID-19 patients in hospital - Confirmed" = "(ii) COVID-19 patients in hospital (including those in ICU)")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table3 <- raw_SC_table3 %>%
  rename("Ambulance attendances - Total" = "Number of attendances",                                  
         "Ambulance attendances - COVID-19 suspected" = "Number of COVID-19 suspected attendances",               
         "Ambulance attendances - COVID-19 suspected patients taken to hospital" = "Number of suspected COVID-19 patients taken to hospital")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table4 <- raw_SC_table4 %>%
  rename("Delayed discharges" = "Number of delayed discharges")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table5 <- raw_SC_table5 #%>%
# rename("Date" = "Date notified",
#        "Cumulative people tested for COVID-19 - Negative" = "Cumulative people tested for COVID-19",
#        "Cumulative people tested for COVID-19 - Positive" = "...3",
#        "Cumulative people tested for COVID-19 - Total" = "...4" )
names(SC_table5) <- c("Date",
                      "Testing - Cumulative people tested for COVID-19 - Negative",
                      "Testing - Cumulative people tested for COVID-19 - Positive",
                      "Testing - Cumulative people tested for COVID-19 - Total",
                      "Testing - New cases reported",
                      "Testing - New cases as percentage of people newly tested",
                      "Testing - Total number of COVID-19 tests reported by NHS Labs - Daily",
                      "Testing - Total number of COVID-19 tests reported by NHS Labs - Cumulative",
                      "Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Daily",
                      "Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Cumulative",
                      "Testing - Total daily tests reported",
                      "Testing - Total daily number of positive tests reported",
                      "Testing - Test positivity (percent of tests that are positive)",
                      "Testing - People with first test results in last 7 days",
                      "Testing - Positive cases reported in last 7 days",
                      "Testing - Tests reported in last 7 days",
                      "Testing - Positive tests reported in last 7 days",
                      "Testing - Test positivity rate in last 7 days",
                      "Testing - Tests in last 7 days per 1000 population") 

SC_table5 <- SC_table5 %>%
  mutate(`Testing - Test positivity (percent of tests that are positive)` = 100*`Testing - Test positivity (percent of tests that are positive)`,
         `Testing - Test positivity rate in last 7 days` = 100*`Testing - Test positivity rate in last 7 days`)


# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table6 <- raw_SC_table6 %>%
  rename("NHS workforce COVID-19 absences - Nursing and midwifery staff" = "Nursing and midwifery absences",
         "NHS workforce COVID-19 absences - Medical and dental staff" = "Medical and dental staff absences",
         "NHS workforce COVID-19 absences - Other staff" = "Other staff absences",
         "NHS workforce COVID-19 absences - All staff" = "All staff absences") %>%
  na.omit
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# SC_table7a <- raw_SC_table7a %>%
#   rename("Adult care homes - Cumulative number that have reported a suspected COVID-19 case" 
#            = "Cumulative number of adult care homes that have reported a suspected COVID-19 case",
#          
#          "Adult care homes - Proportion that have reported a suspected COVID-19 case"        
#            = "Proportion of all adult care homes that have reported a suspected COVID-19 case",
#          
#          "Adult care homes - Cumulative number that have reported more than one suspected COVID-19 case" 
#            = "Cumulative number of adult care homes that have reported more than one case of suspected COVID-19",
#          
#          "Adult care homes - Number with current suspected COVID-19 cases" 
#            = "Number of adult care homes with current case of suspected COVID-19...6",
#          
#          "Adult care homes - Proportion with current suspected COVID-19 cases" 
#            = "Proportion of all adult care homes with current case of suspected COVID-19...7",
#          
#          "Adult care homes - Number with current suspected COVID-19 cases - revised" 
#            = "Number of adult care homes with current case of suspected COVID-19...8",
#          
#          "Adult care homes - Proportion with current suspected COVID-19 cases - revised" 
#            = "Proportion of all adult care homes with current case of suspected COVID-19...9",
#  
#          "Adult care homes - Cumulative number of suspected COVID-19 cases" 
#            = "Cumulative number of suspected COVID-19 cases in adult care homes",
#          
#          "Adult care homes - Daily number of new suspected COVID-19 cases" 
#            = "Daily number of new suspected COVID-19 cases in adult care homes") %>%
#   
#   mutate(`Adult care homes - Proportion that have reported a suspected COVID-19 case` = 100*`Adult care homes - Proportion that have reported a suspected COVID-19 case`,
#          `Adult care homes - Proportion with current suspected COVID-19 cases` = 100*as.numeric(`Adult care homes - Proportion with current suspected COVID-19 cases`),
#          `Adult care homes - Number with current suspected COVID-19 cases` = as.numeric(`Adult care homes - Number with current suspected COVID-19 cases`),
#          `Adult care homes - Proportion with current suspected COVID-19 cases - revised` = 100*as.numeric(`Adult care homes - Proportion with current suspected COVID-19 cases - revised`),
#          `Adult care homes - Number with current suspected COVID-19 cases - revised` = as.numeric(`Adult care homes - Number with current suspected COVID-19 cases - revised`))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table7b <- raw_SC_table7b %>%
  rename("Adult care homes - Number of staff reported as absent" 
         = "No. of staff reported as absent in adult care homes",
         
         "Adult care homes - Adult care homes which submitted a return"        
         = "Adult care homes which submitted a return",
         
         "Adult care homes - Response rate" 
         = "Response rate",
         
         "Adult care homes - Total number of staff in adult care homes which submitted a return" 
         = "Total no. of staff in adult care homes which submitted a return",
         
         "Adult care homes - Staff absence rate" 
         = "Staff absence rate") %>%
  mutate(`Adult care homes - Response rate` = 100*`Adult care homes - Response rate`,
         `Adult care homes - Staff absence rate` = 100*as.numeric(`Adult care homes - Staff absence rate`))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table8 <- raw_SC_table8
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table9a <- raw_SC_table9a
names(SC_table9a) <- c(
  "Date",
  "School education - Number of pupils absent due to COVID-19 related reasons",
  "School education - Percentage attendance",
  "School education - Percentage absence due to COVID-19 related reasons",
  "School education - Percentage absence for non COVID-19 related reasons")
SC_table9a <-SC_table9a %>%
  mutate(`School education - Percentage attendance` = 100*`School education - Percentage attendance`,
         `School education - Percentage absence due to COVID-19 related reasons` = 100*`School education - Percentage absence due to COVID-19 related reasons`,
         `School education - Percentage absence for non COVID-19 related reasons` = 100*`School education - Percentage absence for non COVID-19 related reasons`)
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

SC_table9b <- raw_SC_table9b %>% 
  rename(
    "Date" = "...1",
    "School education - Percentage attendance" = "All...2",
    "School education - Percentage attendance - Primary" = "Primary...3",
    "School education - Percentage attendance - Secondary" = "Secondary...4",
    "School education - Percentage attendance - Special" = "Special...5",
  ) %>% 
  mutate(
    "School education - Percentage attendance" = 100 * `School education - Percentage attendance`,
    "School education - Percentage attendance - Primary" = 100 * `School education - Percentage attendance - Primary`,
    "School education - Percentage attendance - Secondary" = 100 * `School education - Percentage attendance - Secondary`,
    "School education - Percentage attendance - Special" = 100 * `School education - Percentage attendance - Special`
  )

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

SC_table10a <- raw_SC_table10a %>% 
  rename(
    "Vaccinations - Number of people who have received first dose" = "Number of people who have received the first dose of the Covid vaccination",
    "Vaccinations - Number of people who have received second dose" = "Number of people who have received the second dose of the Covid vaccination"
  )

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

SC_table10b <- raw_SC_table10b %>% 
  rename(
    "Date" = "...1",
    # Care home residents
    "Vaccinations - By JCVI priority group - Care home residents - Number vaccinated" = "Number vaccinated...2",
    "Vaccinations - By JCVI priority group - Care home residents - Percentage uptake - Older adult care homes" = "% Vaccinated for residents in older adult care homes",
    "Vaccinations - By JCVI priority group - Care home residents - Percentage uptake - All care homes" = "% Vaccinated for residents in all care homes",
    # Care home staff
    "Vaccinations - By JCVI priority group - Care home staff - Number vaccinated" = "Number vaccinated...7",
    "Vaccinations - By JCVI priority group - Care home staff - Percentage uptake - Older adult care homes" = "% Vaccinated for staff in older adult care homes",
    "Vaccinations - By JCVI priority group - Care home staff - Percentage uptake - All care homes" = "% Vaccinated for staff in all care homes",
    # Individuals aged 80 or over living in the community (excluding care home residents)
    "Vaccinations - By JCVI priority group - Aged 80 or over excluding care home residents - Number vaccinated" = "Number vaccinated...12",
    "Vaccinations - By JCVI priority group - Aged 80 or over excluding care home residents - Percentage uptake" = "% Vaccinated...14",
    # Frontline health and social care workers
    "Vaccinations - By JCVI priority group - Frontline health and social care workers - Number vaccinated" = "Number vaccinated...15",
    "Vaccinations - By JCVI priority group - Frontline health and social care workers - Percentage uptake" = "% Vaccinated...17",
  )

for(i in colnames(SC_table10b)[-1]){
  SC_table10b[i][SC_table10b[i] == "*Initial target met"] <- "1"
}

rm(i)

SC_table10b <- SC_table10b %>% mutate(
  across(where(is.character), as.numeric)
)

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table1 <- raw_HB_table1 %>%
  rename_at(vars(starts_with("NHS")), list(~ str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and"))) %>%
  rename("Date" = "Date notified")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table2a_archived <- raw_HB_table2a_archived %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and"))) %>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) 

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table2b_archived <- raw_HB_table2b_archived %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and"))) %>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) 

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table2 <- raw_HB_table2 %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and"))) %>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) %>%
  rename("Date" = "Reporting date")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table3a_archived <- raw_HB_table3a_archived %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and")))%>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) %>%
  mutate(Lanarkshire = na_if(Lanarkshire, "N/A"))

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table3b_archived <- raw_HB_table3b_archived %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and")))%>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) %>%
  mutate(Lanarkshire = na_if(Lanarkshire, "N/A"),
         `Greater Glasgow and Clyde` = na_if(`Greater Glasgow and Clyde`, "N/A"))

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table3 <- raw_HB_table3 %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and")))%>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) %>%
  rename("Date" = "Reporting date")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


# [5] Creating tidy datasets from each table -----------------------------------
# Some variable names have been slightly changed so they get placed together in
# alphabetic order
tidy_SC_table1 <- SC_table1 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table2_archived <- SC_table2_archived %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate_at(vars("Value"), as.numeric) %>%
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table2 <- SC_table2 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate_at(vars("Value"), as.numeric) %>%
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table3 <- SC_table3 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table4 <- SC_table4 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table5 <- SC_table5 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate_at(vars("Value"), as.numeric) %>%
  mutate(Measurement = Variable,
         Measurement = recode(Measurement,
                              "Testing - Cumulative people tested for COVID-19 - Negative" = "Count",
                              "Testing - Cumulative people tested for COVID-19 - Positive" = "Count",
                              "Testing - Cumulative people tested for COVID-19 - Total" = "Count",
                              "Testing - New cases reported" = "Count",
                              "Testing - New cases as percentage of people newly tested" = "Ratio",
                              "Testing - Total number of COVID-19 tests reported by NHS Labs - Daily" = "Count",
                              "Testing - Total number of COVID-19 tests reported by NHS Labs - Cumulative" = "Count",
                              "Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Daily" = "Count",
                              "Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Cumulative" = "Count",
                              "Testing - Total daily tests reported" = "Count",
                              "Testing - Total daily number of positive tests reported" = "Count",
                              "Testing - Test positivity (percent of tests that are positive)" = "Ratio",
                              "Testing - People with first test results in last 7 days" = "Count",
                              "Testing - Positive cases reported in last 7 days" = "Count",
                              "Testing - Tests reported in last 7 days" = "Count",
                              "Testing - Positive tests reported in last 7 days" = "Count",
                              "Testing - Test positivity rate in last 7 days" = "Ratio",
                              "Testing - Tests in last 7 days per 1000 population" = "Ratio"))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table6 <- SC_table6 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# tidy_SC_table7a <- SC_table7a %>%
#   gather(key = "Variable", value = "Value", -Date) %>%
#   mutate(Measurement = Variable,
#          Measurement = recode(Measurement,
#                               "Adult care homes - Cumulative number that have reported a suspected COVID-19 case" = "Count",
#                               "Adult care homes - Proportion that have reported a suspected COVID-19 case" = "Ratio",
#                               "Adult care homes - Cumulative number that have reported more than one suspected COVID-19 case" = "Count",
#                               "Adult care homes - Number with current suspected COVID-19 cases" = "Count",
#                               "Adult care homes - Proportion with current suspected COVID-19 cases" = "Ratio",
#                               "Adult care homes - Number with current suspected COVID-19 cases - revised" = "Count",
#                               "Adult care homes - Proportion with current suspected COVID-19 cases - revised" = "Ratio",
#                               "Adult care homes - Cumulative number of suspected COVID-19 cases" = "Count",
#                               "Adult care homes - Daily number of new suspected COVID-19 cases" = "Count"))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table7b <- SC_table7b %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = Variable,
         Measurement = recode(Measurement,
                              "Adult care homes - Number of staff reported as absent" = "Count",                                
                              "Adult care homes - Adult care homes which submitted a return" = "Count",                         
                              "Adult care homes - Response rate" = "Ratio",
                              "Adult care homes - Total number of staff in adult care homes which submitted a return" = "Count",
                              "Adult care homes - Staff absence rate" = "Ratio"))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table8 <- SC_table8 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table9a <- SC_table9a %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = Variable,
         Measurement = recode(Measurement,
                              "School education - Number of pupils absent due to COVID-19 related reasons" = "Count",                                
                              "School education - Percentage attendance" = "Ratio",
                              "School education - Percentage absence due to COVID-19 related reasons" = "Ratio",
                              "School education - Percentage absence for non COVID-19 related reasons" = "Ratio"))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table9b <- SC_table9b %>% 
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Ratio")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

tidy_SC_table10a <- SC_table10a %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Count")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

tidy_SC_table10b <- SC_table10b %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(
    Measurement = Variable,
    Measurement = recode(
      Measurement,
      # Counts
      "Vaccinations - By JCVI priority group - Care home residents - Number vaccinated" = "Count",
      "Vaccinations - By JCVI priority group - Care home staff - Number vaccinated" = "Count",
      "Vaccinations - By JCVI priority group - Aged 80 or over excluding care home residents - Number vaccinated" = "Count",
      "Vaccinations - By JCVI priority group - Frontline health and social care workers - Number vaccinated" = "Count",
      # Ratios
      "Vaccinations - By JCVI priority group - Care home residents - Percentage uptake - Older adult care homes" = "Ratio",
      "Vaccinations - By JCVI priority group - Care home residents - Percentage uptake - All care homes" = "Ratio",
      "Vaccinations - By JCVI priority group - Care home staff - Percentage uptake - Older adult care homes" = "Ratio",
      "Vaccinations - By JCVI priority group - Care home staff - Percentage uptake - All care homes" = "Ratio",
      "Vaccinations - By JCVI priority group - Aged 80 or over excluding care home residents - Percentage uptake" = "Ratio",
      "Vaccinations - By JCVI priority group - Frontline health and social care workers - Percentage uptake" = "Ratio"
    )
  )

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table1 <- HB_table1 %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "Testing - Cumulative people tested for COVID-19 - Positive")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table2a_archived <- HB_table2a_archived %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in ICU - Confirmed (archived)")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table2b_archived <- HB_table2b_archived %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in ICU - Total (archived)")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table2 <- HB_table2 %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in ICU - Confirmed")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table3a_archived <- HB_table3a_archived %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in hospital - Confirmed (archived)")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table3b_archived <- HB_table3b_archived %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in hospital - Suspected (archived)")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table3 <- HB_table3 %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in hospital - Confirmed")


# [6] Binding tidy datasets together -------------------------------------------
SC_output_dataset <- bind_rows(tidy_SC_table1,
                               tidy_SC_table2_archived,
                               tidy_SC_table2,
                               tidy_SC_table3,
                               tidy_SC_table4,
                               tidy_SC_table5,
                               tidy_SC_table6,
                               # tidy_SC_table7a,
                               tidy_SC_table7b,
                               tidy_SC_table8,
                               tidy_SC_table9a,
                               tidy_SC_table9b,
                               tidy_SC_table10a,
                               tidy_SC_table10b) %>%
  # Creating required variables
  mutate(GeographyCode = "S92000003",
         Value = as.character(Value),
         "Units" = Variable,
         Units = str_remove(Units, pattern = " - revised")) %>%
  
  # Ordering variables appropriately
  select(GeographyCode,
         DateCode = Date,
         Measurement,
         Units,
         Value,
         Variable) 

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_output_dataset <- bind_rows(tidy_HB_table1,
                               tidy_HB_table2a_archived,
                               tidy_HB_table2b_archived,
                               tidy_HB_table2,
                               tidy_HB_table3a_archived,
                               tidy_HB_table3b_archived,
                               tidy_HB_table3) %>%
  # Creating required variables
  left_join(HB_codes, by = c("HBname" = "HB2014Name")) %>%
  mutate(Measurement = "Count",
         "Variable" = Units) %>%
  # Ordering variables appropriately
  select(GeographyCode = HB2014Code,
         DateCode = Date,
         Measurement, 
         Units,
         Value,
         Variable)

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
whole_output_dataset <- bind_rows(SC_output_dataset,
                                  HB_output_dataset) %>%
  # mutate(Value = str_replace(Value, 'N/A', "NA")) %>%
  
  na.omit


whole_output_dataset_9999999 <- whole_output_dataset %>%
  mutate(Value = str_replace(Value, '\\*', "9999999"))

# [7] Saving final dataset as .csv ---------------------------------------------

# to upload to statistics.gov.scot
write.csv(whole_output_dataset, "./COVID19 - Daily Management Information - Tidy dataset to upload to statistics.gov.scot.csv", quote = FALSE, row.names = F)  
write.csv(whole_output_dataset_9999999, "./COVID19 - Daily Management Information - Tidy dataset to upload to statistics.gov.scot_9999999.csv", quote = FALSE, row.names = F)  


# to upload to GitHub
write.csv(SC_table1,  "./COVID19 - Daily Management Information - Scotland - Calls.csv", quote = FALSE, row.names = F)
write.csv(SC_table2_archived,  "./COVID19 - Daily Management Information - Scotland - Hospital care - Archived.csv", quote = FALSE, row.names = F)
write.csv(SC_table2,  "./COVID19 - Daily Management Information - Scotland - Hospital care.csv", quote = FALSE, row.names = F)
write.csv(SC_table3,  "./COVID19 - Daily Management Information - Scotland - Ambulance.csv", quote = FALSE, row.names = F)
write.csv(SC_table4,  "./COVID19 - Daily Management Information - Scotland - Delayed discharges.csv", quote = FALSE, row.names = F)
write.csv(SC_table5,  "./COVID19 - Daily Management Information - Scotland - Testing.csv", quote = FALSE, row.names = F)
write.csv(SC_table6,  "./COVID19 - Daily Management Information - Scotland - Workforce.csv", quote = FALSE, row.names = F)
# write.csv(SC_table7a, "./COVID19 - Daily Management Information - Scotland - Care homes.csv", quote = FALSE, row.names = F)
write.csv(SC_table7b, "./COVID19 - Daily Management Information - Scotland - Care home workforce.csv", quote = FALSE, row.names = F)
write.csv(SC_table8,  "./COVID19 - Daily Management Information - Scotland - Deaths.csv", quote = FALSE, row.names = F)
write.csv(SC_table9a,  "./COVID19 - Daily Management Information - Scotland - School education.csv", quote = FALSE, row.names = F)
write.csv(SC_table9b,  "./COVID19 - Daily Management Information - Scotland - School education (2021).csv", quote = FALSE, row.names = F)
write.csv(SC_table10a,  "./COVID19 - Daily Management Information - Scotland - Vaccinations.csv", quote = FALSE, row.names = F)
write.csv(SC_table10b,  "./COVID19 - Daily Management Information - Scotland - Vaccinations - By JCVI priority group.csv", quote = FALSE, row.names = F)

write.csv(HB_table1,  "./COVID19 - Daily Management Information - Scottish Health Boards - Cumulative cases.csv", quote = FALSE, row.names = F)
write.csv(HB_table2a_archived,  "./COVID19 - Daily Management Information - Scottish Health Boards - ICU patients - Confirmed - Archived.csv", quote = FALSE, row.names = F)
write.csv(HB_table2b_archived,  "./COVID19 - Daily Management Information - Scottish Health Boards - ICU patients - Total - Archived.csv", quote = FALSE, row.names = F)
write.csv(HB_table2,  "./COVID19 - Daily Management Information - Scottish Health Boards - ICU patients - Confirmed.csv", quote = FALSE, row.names = F)
write.csv(HB_table3a_archived, "./COVID19 - Daily Management Information - Scottish Health Boards - Hospital patients - Confirmed - Archived.csv", quote = FALSE, row.names = F)
write.csv(HB_table3b_archived, "./COVID19 - Daily Management Information - Scottish Health Boards - Hospital patients - Suspected - Archived.csv", quote = FALSE, row.names = F)
write.csv(HB_table3,  "./COVID19 - Daily Management Information - Scottish Health Boards - Hospital patients - Confirmed.csv", quote = FALSE, row.names = F)


# Bits of code used in previous versions ---------------------------------------
# '\\p{No}'  - to match super and subscripts -- https://www.regular-expressions.info/unicode.html
# '\\*'      - to match asterisks
# mutate(Value = str_remove(Value, '\\p{No}'),
#        Date = as.Date(as.numeric(Date), origin = "1899-12-30"),