# ------------------------------------------------------------------------------
# Title - SG Covid-19 daily update (Management Information)
# Purpose - Reformatting Covid-19 daily update data to upload to 
#           statistics.gov.scot and github.com/DataScienceScotland
# Author - Victoria Avila (victoria.avila@gov.scot)
# Open Data info - statistics.opendata@gov.scot
# Date created - 17/04/2020
# Last updated - 18/06/2020
# ------------------------------------------------------------------------------


# [0] Loading libraries --------------------------------------------------------
library(httr)    # GET
library(readxl)  # excel_sheets, read_excel
library(dplyr)   # %>%, rename, rename_at, mutate
library(tidyr)   # gather, join, na_if
library(stringr) # str_remove, str_replace, bind_rows, left_join

# [1] Health Board 2014 codes --------------------------------------------------
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


# [2a] Reading original files from website -------------------------------------
# URL shouldn't have changed, but it would good to confirm before running the
# whole code
url1 <- "http://www.gov.scot/binaries/content/documents/govscot/publications/statistics/2020/04/coronavirus-covid-19-trends-in-daily-data/documents/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/govscot%3Adocument/Trends%2Bin%2Bdaily%2BCOVID-19%2Bdata%2B18%2BJune%2B2020.xlsx"   
url2 <- "http://www.gov.scot/binaries/content/documents/govscot/publications/statistics/2020/04/coronavirus-covid-19-trends-in-daily-data/documents/covid-19-data-by-nhs-board/covid-19-data-by-nhs-board/govscot%3Adocument/COVID-19%2Bdata%2Bby%2BNHS%2BBoard%2B18%2BJune%2B2020.xlsx"
 
# -- Scotland (SC) --
GET(url1, write_disk(tf1 <- tempfile(fileext = ".xlsx")))
excel_sheets(tf1)
 
# -- Health Boards (HB) --
GET(url2, write_disk(tf2 <- tempfile(fileext = ".xlsx")))
excel_sheets(tf2)

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

# [3] Saving individual tables -------------------------------------------------
raw_SC_table1  <- read_excel(tf1, "Table 1 - NHS 24", skip = 2)
raw_SC_table2  <- read_excel(tf1, "Table 2 - Hospital Care", skip = 3)
raw_SC_table3  <- read_excel(tf1, "Table 3 - Ambulance", skip = 2)[,-1]
raw_SC_table4  <- read_excel(tf1, "Table 4 - Delayed Discharges", skip = 2)[,-1]
raw_SC_table5  <- read_excel(tf1, "Table 5 - Testing", skip = 2)[-1, ]
raw_SC_table6  <- read_excel(tf1, "Table 6 - Workforce", skip = 1)
raw_SC_table7a <- read_excel(tf1, "Table 7a - Care Homes", skip = 2)[, -c(5,8)]
raw_SC_table7b <- read_excel(tf1, "Table 7b - Care Home Workforce", skip = 1)
raw_SC_table8  <- read_excel(tf1, "Table 8 - Deaths", skip = 2)[, 1:2]

raw_HB_table1  <- read_excel(tf2, "Table 1 - Cumulative cases", skip = 2)[,-16]
raw_HB_table2  <- read_excel(tf2, "Table 2 - ICU patients", skip = 2)[, -17]
raw_HB_table3a <- read_excel(tf2, "Table 3a - Hospital Confirmed", skip = 2)[, -17]
raw_HB_table3b <- read_excel(tf2, "Table 3b- Hospital Suspected", skip = 2)[, -17]

#unlink(tf1)
#unlink(tf2)

# [4] Renaming variables -------------------------------------------------------
SC_table1 <- raw_SC_table1 %>%
  rename("Calls - NHS24 111" = "NHS24 111 Calls",
         "Calls - Coronavirus helpline" = "Coronavirus Helpline Calls")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table2 <- raw_SC_table2
# Renaming variables in this table the old way because different package versions
# create different default names for variables
names(SC_table2) <- c("Date",
                      "COVID-19 patients in ICU - Confirmed",
                      "COVID-19 patients in ICU - Suspected",
                      "COVID-19 patients in ICU - Total",
                      "COVID-19 patients in hospital - Confirmed",
                      "COVID-19 patients in hospital - Suspected",
                      "COVID-19 patients in hospital - Total")
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
                      "Testing - Daily people found positive",
                      "Testing - Total number of COVID-19 tests carried out by NHS Labs - Daily",
                      "Testing - Total number of COVID-19 tests carried out by NHS Labs - Cumulative",
                      "Testing - Total number of COVID-19 tests carried out by Regional Testing Centres - Daily",
                      "Testing - Total number of COVID-19 tests carried out by Regional Testing Centres - Cumulative")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table6 <- raw_SC_table6 %>%
  rename("NHS workforce COVID-19 absences - Nursing and midwifery staff" = "Nursing and midwifery absences",
         "NHS workforce COVID-19 absences - Medical and dental staff" = "Medical and dental staff absences",
         "NHS workforce COVID-19 absences - Other staff" = "Other staff absences",
         "NHS workforce COVID-19 absences - All staff" = "All staff absences") %>%
  na.omit
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table7a <- raw_SC_table7a %>%
  rename("Adult care homes - Cumulative number that have reported a suspected COVID-19 case" 
           = "Cumulative number of adult care homes that have reported a suspected COVID-19 case",
         "Adult care homes - Proportion that have reported a suspected COVID-19 case"        
           = "Proportion of all adult care homes that have reported a suspected COVID-19 case",
         "Adult care homes - Cumulative number that have reported more than one suspected COVID-19 case" 
           = "Cumulative number of adult care homes that have reported more than one case of suspected COVID-19",
         "Adult care homes - Number with current suspected COVID-19 cases" 
           = "Number of adult care homes with current case of suspected COVID-19",
         "Adult care homes - Proportion with current suspected COVID-19 cases" 
           = "Proportion of all adult care homes with current case of suspected COVID-19",
         "Adult care homes - Cumulative number of suspected COVID-19 cases" 
           = "Cumulative number of suspected COVID-19 cases in adult care homes",
         "Adult care homes - Daily number of new suspected COVID-19 cases" 
           = "Daily number of new suspected COVID-19 cases in adult care homes") %>%
  mutate(`Adult care homes - Proportion that have reported a suspected COVID-19 case` = 100*`Adult care homes - Proportion that have reported a suspected COVID-19 case`,
         `Adult care homes - Proportion with current suspected COVID-19 cases` = 100*as.numeric(`Adult care homes - Proportion with current suspected COVID-19 cases`),
         `Adult care homes - Number with current suspected COVID-19 cases` = as.numeric(`Adult care homes - Number with current suspected COVID-19 cases`))
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
HB_table1 <- raw_HB_table1 %>%
  rename_at(vars(starts_with("NHS")), list(~ str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and"))) 
  
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table2 <- raw_HB_table2 %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and"))) %>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) 
  
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table3a <- raw_HB_table3a %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and")))%>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) %>%
  mutate(Lanarkshire = na_if(Lanarkshire, "N/A"))

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table3b <- raw_HB_table3b %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS "))) %>%
  rename_at(vars(contains("&")), list(~ str_replace(., "&", "and")))%>%
  rename_at(vars(contains("Golden")), list(~ str_replace(., "Golden", "The Golden"))) %>%
  mutate(Lanarkshire = na_if(Lanarkshire, "N/A"),
         `Greater Glasgow and Clyde` = na_if(`Greater Glasgow and Clyde`, "N/A"))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


# [5] Creating tidy datasets from each table -----------------------------------
# Some variable names have been slightly changed so they get placed together in
# alphabetic order
tidy_SC_table1 <- SC_table1 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
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
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table6 <- SC_table6 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Count")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table7a <- SC_table7a %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = Variable,
         Measurement = recode(Measurement,
                              "Adult care homes - Cumulative number that have reported a suspected COVID-19 case" = "Count",
                              "Adult care homes - Proportion that have reported a suspected COVID-19 case" = "Ratio",
                              "Adult care homes - Cumulative number that have reported more than one suspected COVID-19 case" = "Count",
                              "Adult care homes - Number with current suspected COVID-19 cases" = "Count",
                              "Adult care homes - Proportion with current suspected COVID-19 cases" = "Ratio",
                              "Adult care homes - Cumulative number of suspected COVID-19 cases" = "Count",
                              "Adult care homes - Daily number of new suspected COVID-19 cases" = "Count"))
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
tidy_HB_table1 <- HB_table1 %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "Testing - Cumulative people tested for COVID-19 - Positive")
  
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table2 <- HB_table2 %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in ICU - Total")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table3a <- HB_table3a %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in hospital - Confirmed")

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_HB_table3b <- HB_table3b %>%
  gather(key = HBname, value = "Value", -Date) %>%
  mutate(Units = "COVID-19 patients in hospital - Suspected")


# [6] Binding tidy datasets together -------------------------------------------
SC_output_dataset <- bind_rows(tidy_SC_table1,
                               tidy_SC_table2,
                               tidy_SC_table3,
                               tidy_SC_table4,
                               tidy_SC_table5,
                               tidy_SC_table6,
                               tidy_SC_table7a,
                               tidy_SC_table7b,
                               tidy_SC_table8) %>%
  # Creating required variables
  mutate(GeographyCode = "S92000003",
         "Units" = Variable,
         Value = as.character(Value)) %>%
  # Ordering variables appropriately
  select(GeographyCode,
         DateCode = Date,
         Measurement,
         Units,
         Value,
         Variable) 

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_output_dataset <- bind_rows(tidy_HB_table1,
                               tidy_HB_table2,
                               tidy_HB_table3a,
                               tidy_HB_table3b) %>%
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
write.csv(SC_table2,  "./COVID19 - Daily Management Information - Scotland - Hospital care.csv", quote = FALSE, row.names = F)
write.csv(SC_table3,  "./COVID19 - Daily Management Information - Scotland - Ambulance.csv", quote = FALSE, row.names = F)
write.csv(SC_table4,  "./COVID19 - Daily Management Information - Scotland - Delayed discharges.csv", quote = FALSE, row.names = F)
write.csv(SC_table5,  "./COVID19 - Daily Management Information - Scotland - Testing.csv", quote = FALSE, row.names = F)
write.csv(SC_table6,  "./COVID19 - Daily Management Information - Scotland - Workforce.csv", quote = FALSE, row.names = F)
write.csv(SC_table7a, "./COVID19 - Daily Management Information - Scotland - Care homes.csv", quote = FALSE, row.names = F)
write.csv(SC_table7b, "./COVID19 - Daily Management Information - Scotland - Care home workforce.csv", quote = FALSE, row.names = F)
write.csv(SC_table8,  "./COVID19 - Daily Management Information - Scotland - Deaths.csv", quote = FALSE, row.names = F)

write.csv(HB_table1,  "./COVID19 - Daily Management Information - Scottish Health Boards - Cumulative cases.csv", quote = FALSE, row.names = F)
write.csv(HB_table2,  "./COVID19 - Daily Management Information - Scottish Health Boards - ICU patients.csv", quote = FALSE, row.names = F)
write.csv(HB_table3a, "./COVID19 - Daily Management Information - Scottish Health Boards - Hospital patients - Confirmed.csv", quote = FALSE, row.names = F)
write.csv(HB_table3b, "./COVID19 - Daily Management Information - Scottish Health Boards - Hospital patients - Suspected.csv", quote = FALSE, row.names = F)


# Bits of code used in previous versions ---------------------------------------
# '\\p{No}'  - to match super and subscripts -- https://www.regular-expressions.info/unicode.html
# '\\*'      - to match asterisks
# mutate(Value = str_remove(Value, '\\p{No}'),
#        Date = as.Date(as.numeric(Date), origin = "1899-12-30"),

