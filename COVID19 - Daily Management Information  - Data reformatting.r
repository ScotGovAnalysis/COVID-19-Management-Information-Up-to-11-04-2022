# ------------------------------------------------------------------------------
# Title - SG Covid-19 daily update (Management Information)
# Purpose - Reformatting Covid-19 daily update data to upload to 
#           statistics.gov.scot and github.com/DataScienceScotland
# Author - Victoria Avila (victoria.avila@gov.scot)
# Date created - 17/04/2020
# Last update - 24/04/2020
# ------------------------------------------------------------------------------


#Loading libraries -------------------------------------------------------------
library(httr) #GET
library(readxl) #read_excel
library(readr) #read_csv
library(dplyr) #%>%, mutate 
library(tidyr) #gather, join
library(stringr) #str_remove


# [1] Reading original files from website --------------------------------------
# URL shouldn't have changed, but it would good to confirm before running the
# whole code
url1 <- "https://www.gov.scot/binaries/content/documents/govscot/publications/statistics/2020/04/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/documents/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/govscot%3Adocument/HSCA%2B-%2BSG%2BWebsite%2B-%2BIndicator%2BTrends%2Bfor%2Bdaily%2Bdata%2Bpublication.xlsx"
url2 <- "https://www.gov.scot/binaries/content/documents/govscot/publications/statistics/2020/04/trends-in-number-of-people-in-hospital-with-confirmed-or-suspected-covid-19/documents/covid-19-data-by-nhs-board/covid-19-data-by-nhs-board/govscot%3Adocument/HSCA%2B-%2BSG%2BWebsite%2B-%2BIndicator%2BTrends%2Bfor%2Bdaily%2Bdata%2Bpublication%2B-%2BHealth%2BBoard%2BBreakdown.xlsx"

# -- Scotland (SC) --
GET(url1, write_disk(tf1 <- tempfile(fileext = ".xlsx")))
excel_sheets(tf1)

# -- Health Boards (HB) --
GET(url2, write_disk(tf2 <- tempfile(fileext = ".xlsx")))
excel_sheets(tf2)


# [2] Saving individual tables -------------------------------------------------
SC_table1 <- read_excel(tf1, "Table 1 - NHS 24", skip = 2)
SC_table2 <- read_excel(tf1, "Table 2 - Hospital Care", skip = 2)[-1, ]
SC_table3 <- read_excel(tf1, "Table 3 - Ambulance", skip = 2)
SC_table4 <- read_excel(tf1, "Table 4 - Delayed Discharge", skip = 2)
SC_table5 <- read_excel(tf1, "Table 5 - Testing", skip = 2)[-1, ]
SC_table6 <- read_excel(tf1, "Table 6 - Workforce", skip = 2)
SC_table7 <- read_excel(tf1, "Table 7 - Care Homes", skip = 2)[, -c(5,8)]
SC_table8 <- read_excel(tf1, "Table 8 - Deaths", skip = 2)[, 1:2]

HB_table1 <- read_excel(tf2, "Table 1 - Cumulative cases", skip = 2)[,-16]
HB_table2 <- read_excel(tf2, "Table 2 - ICU patients", skip = 2)[, -17]
HB_table3 <- read_excel(tf2, "Table 3 - Hospital patients", skip = 2)[, -17]

unlink(tf1)
unlink(tf2)

# Renaming variables -----------------------------------------------------------
SC_table1 <- SC_table1 %>%
  rename("Calls - NHS24 111" = "NHS24 111 Calls",
         "Calls - Coronavirus helpline" = "Coronavirus Helpline Calls")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table2 <- SC_table2 %>%
  rename("COVID-19 patients in ICU - Confirmed" = "(i) COVID-19 patients in ICU\r\n or combined ICU/HDU", 
         "COVID-19 patients in ICU - Suspected" = "...3", 
         "COVID-19 patients in ICU - Total" = "...4",                  
         "COVID-19 patients in hospital - Confirmed" = "(ii) COVID-19 patients in hospital (including those in ICU)",
         "COVID-19 patients in hospital - Suspected" = "...6",
         "COVID-19 patients in hospital - Total" = "...7")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table3 <- SC_table3 %>%
  rename("Ambulance attendances - Total" = "Number of attendances",                                  
         "Ambulance attendances - COVID-19 suspected" = "Number of COVID-19 suspected attendances",               
         "Ambulance attendances - COVID-19 suspected patients taken to hospital" = "Number of suspected COVID-19 patients taken to hospital")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table4 <- SC_table4 %>%
  rename("Delayed discharges" = "Number of delayed discharges")
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table5 <- SC_table5 %>%
  rename("Date" = "Date notified",
         "Cumulative people tested for COVID-19 - Negative" = "Cumulative people tested for COVID-19",
         "Cumulative people tested for COVID-19 - Positive" = "...3",
         "Cumulative people tested for COVID-19 - Total" = "...4" )
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table6 <- SC_table6 %>%
  rename("NHS workforce COVID-19 absences - Nursing and midwifery staff" = "Nursing and midwifery absences",
         "NHS workforce COVID-19 absences - Medical and dental staff" = "Medical and dental staff absences",
         "NHS workforce COVID-19 absences - Other staff" = "Other staff absences",
         "NHS workforce COVID-19 absences - All staff" = "All staff absences") %>%
  na.omit
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
SC_table7 <- SC_table7 %>%
  rename("Care homes - Cumulative number that have reported a suspected COVID-19 case" = "Cumulative number of care homes that have reported a suspected COVID-19 case",
         "Care homes - Proportion that have reported a suspected COVID-19 case" = "Proportion of all adult care homes that have reported a suspected COVID-19 case",
         "Care homes - Cumulative number that have reported more than one suspected COVID-19 case" = "Cumulative number of care homes that have reported more than one case of suspected COVID-19",
         "Care homes - Number with current suspected COVID-19 cases" = "Number of care homes with current case of suspected COVID-19",
         "Care homes - Proportion with current suspected COVID-19 cases" = "Proportion of all adult care homes with current case of suspected COVID-19",
         "Care homes - Cumulative number of suspected COVID-19 cases" = "Cumulative number of suspected COVID-19 cases in care homes",
         "Care homes - Daily number of new suspected COVID-19 cases" = "Daily number of new suspected COVID-19 cases in care homes") %>%
  mutate(`Care homes - Proportion that have reported a suspected COVID-19 case` = 100*`Care homes - Proportion that have reported a suspected COVID-19 case`,
         `Care homes - Proportion with current suspected COVID-19 cases` = 100*as.numeric(`Care homes - Proportion with current suspected COVID-19 cases`),
         `Care homes - Number with current suspected COVID-19 cases` = as.numeric(`Care homes - Number with current suspected COVID-19 cases`))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table1 <- HB_table1 %>%
  rename_at(vars(starts_with("NHS")), list(~ str_remove(., "NHS ")))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table2 <- HB_table2 %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS ")))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
HB_table3 <- HB_table3 %>%
  rename_at(vars(starts_with("NHS")), funs(str_remove(., "NHS ")))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 



# Creating tidy datasets for each table ----------------------------------------
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
tidy_SC_table7 <- SC_table7 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = Variable,
         Measurement = recode(Measurement,
                              "Care homes - Cumulative number that have reported a suspected COVID-19 case" = "Count",
                              "Care homes - Proportion that have reported a suspected COVID-19 case" = "Ratio",
                              "Care homes - Cumulative number that have reported more than one suspected COVID-19 case" = "Count",
                              "Care homes - Number with current suspected COVID-19 cases" = "Count",
                              "Care homes - Proportion with current suspected COVID-19 cases" = "Ratio",
                              "Care homes - Cumulative number of suspected COVID-19 cases" = "Count",
                              "Care homes - Daily number of new suspected COVID-19 cases" = "Count"))
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
tidy_SC_table8 <- SC_table8 %>%
  gather(key = "Variable", value = "Value", -Date) %>%
  mutate(Measurement = "Count")


# Binding tidy datasets together -------------------------------------------------------------------------
whole_output_dataset <- bind_rows(tidy_SC_table1,
                                  tidy_SC_table2,
                                  tidy_SC_table3,
                                  tidy_SC_table4,
                                  tidy_SC_table5,
                                  tidy_SC_table6,
                                  tidy_SC_table7,
                                  tidy_SC_table8#,
                                  #tidy_HB_table1,
                                  #tidy_HB_table2,
                                  #tidy_HB_table3
                                  ) %>%
  # Creating required variables
  mutate(GeographyCode = "S92000003",
         "Units" = Variable) %>%
  # Ordering variables appropriately
  select(GeographyCode,
         DateCode = Date,
         Measurement,
         Units,
         Value,
         Variable) %>%
  na.omit

# Saving final tidy dataset as .csv to upload to statistics.gov.scot -----------
write.csv(whole_output_dataset, "./COVID19 - Daily Management Information - Tidy dataset to upload to statistics.gov.scot.csv", quote = FALSE, row.names = F)  

write.csv(SC_table1, "COVID19 - Daily Management Information - Scotland - Calls.csv", quote = FALSE, row.names = F)
write.csv(SC_table2, "COVID19 - Daily Management Information - Scotland - Hospital care.csv", quote = FALSE, row.names = F)
write.csv(SC_table3, "COVID19 - Daily Management Information - Scotland - Ambulance.csv", quote = FALSE, row.names = F)
write.csv(SC_table4, "COVID19 - Daily Management Information - Scotland - Delayed discharges.csv", quote = FALSE, row.names = F)
write.csv(SC_table5, "COVID19 - Daily Management Information - Scotland - Testing.csv", quote = FALSE, row.names = F)
write.csv(SC_table6, "COVID19 - Daily Management Information - Scotland - Workforce.csv", quote = FALSE, row.names = F)
write.csv(SC_table7, "COVID19 - Daily Management Information - Scotland - Care homes.csv", quote = FALSE, row.names = F)
write.csv(SC_table8, "COVID19 - Daily Management Information - Scotland - Deaths.csv", quote = FALSE, row.names = F)

write.csv(HB_table1, "COVID19 - Daily Management Information - Scottish Health Boards - Cumulative cases.csv", quote = FALSE, row.names = F)
write.csv(HB_table2, "COVID19 - Daily Management Information - Scottish Health Boards - ICU patients.csv", quote = FALSE, row.names = F)
write.csv(HB_table3, "COVID19 - Daily Management Information - Scottish Health Boards - Hospital patients.csv", quote = FALSE, row.names = F)


# Bits of code used in previous versions ---------------------------------------
# '\\p{No}'  - to match super and subscripts -- https://www.regular-expressions.info/unicode.html
# '\\*'      - to match asterisks
# mutate(Value = str_remove(Value, '\\p{No}'),
#        Date = as.Date(as.numeric(Date), origin = "1899-12-30"),
       