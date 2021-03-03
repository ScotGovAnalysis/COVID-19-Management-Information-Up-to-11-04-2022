# Test functions ----------------------------------------------------------

# Confirm that the number of variables in each data set matches the expected value
test_variable_count <- function(df, expected_variable_count){
  
  variable_count <- length(df)
  
  if(variable_count != expected_variable_count){
    warning(
      str_c(
        "Data frame does not contain the expected number of variables.\n  ",
        "Counted ", variable_count, " variables, expected ", expected_variable_count, "."
      )
    )
  }
  
  invisible()
  
}

# Confirm that the name of each variable in each data set matches the expected value
# TODO Variable count should be implicit from the variable names being defined
test_variable_names <- function(df, expected_variable_names){
  
  variable_count <- length(df)
  variable_names <- names(df)
  
  compare_variable_names <- variable_names == expected_variable_names
  
  same_variable_name_count <- compare_variable_names %>% 
    as.integer() %>% 
    sum()
  
  if(same_variable_name_count != variable_count){
    warning(
      str_c(
        "Data frame does not have the expected variable names.\n  ",
        variable_count - same_variable_name_count, " variables have unexpected names, or are in an unexpected order."
      )
    )
  }
  
  invisible()
  
}

# Test variable count -----------------------------------------------------

# Whole-of-Scotland data ------------------------------------------------ #

raw_SC_table1   %>% test_variable_count(3)
raw_SC_table2   %>% test_variable_count(4)
raw_SC_table3   %>% test_variable_count(4)
raw_SC_table4   %>% test_variable_count(2)
raw_SC_table5   %>% test_variable_count(19)
raw_SC_table6   %>% test_variable_count(5)
raw_SC_table7b  %>% test_variable_count(6)
raw_SC_table8   %>% test_variable_count(2)
raw_SC_table9a  %>% test_variable_count(5)
raw_SC_table9b  %>% test_variable_count(5)
raw_SC_table10a %>% test_variable_count(3)

# Health board data ----------------------------------------------------- #

raw_HB_table1   %>% test_variable_count(15)
raw_HB_table2   %>% test_variable_count(16)
raw_HB_table3   %>% test_variable_count(16)

# Test variable names -----------------------------------------------------

# Whole-of-Scotland data ------------------------------------------------ #

raw_SC_table1 %>% test_variable_names(
  c(
    "Date",
    "NHS24 111 Calls",
    "Coronavirus Helpline Calls"
  )
)

raw_SC_table2 %>% test_variable_names(
  c(
    "Reporting Date",
    "(i) COVID-19 patients in ICU\r\n or combined ICU/HDU (with length of stay 28 days or less)",
    "(ii) COVID-19 patients in hospital (including those in ICU) (with length of stay 28 days or less)",
    "(iii) COVID-19 patients in ICU or combined ICU/HDU (with length of stay more than 28 days)"
  )
)

raw_SC_table3 %>% test_variable_names(
  c(
    "Date",
    "Number of attendances",
    "Number of COVID-19 suspected attendances",
    "Number of suspected COVID-19 patients taken to hospital"
  )
)

raw_SC_table4 %>% test_variable_names(
  c(
    "Date",
    "Number of delayed discharges"
  )
)

raw_SC_table5 %>% test_variable_names(
  c(
    "Date notified",
    "(i) Cumulative number of people with at least one COVID-19 test result reported",
    "...3",
    "...4",
    "(ii) New cases reported",
    "New cases reported as % of people newly tested",
    "(iii) Total number of COVID-19 tests reported by NHS Labs",
    "...8",
    "...9",
    "...10",
    "Total daily tests reported",
    "Total daily number of positive tests reported",
    "Test positivity (percent of tests that are positive)",
    "People with first test results in last 7 days",
    "Positive cases reported in last 7 days",
    "Tests reported in last 7 days",
    "Positive tests reported in last 7 days",
    "Test positivity rate in last 7 days",
    "Tests in last 7 days per 1,000 population"
  )
)

raw_SC_table6 %>% test_variable_names(
  c(
    "Date",
    "Nursing and midwifery absences",
    "Medical and dental staff absences",
    "Other staff absences",
    "All staff absences"
  )
)

raw_SC_table7b %>% test_variable_names(
  c(
    "Date",
    "No. of staff reported as absent in adult care homes",
    "Adult care homes which submitted a return",
    "Response rate",
    "Total no. of staff in adult care homes which submitted a return",
    "Staff absence rate"
  )
)

raw_SC_table8 %>% test_variable_names(
  c(
    "Date",
    "Number of COVID-19 confirmed deaths registered to date"
  )
)

raw_SC_table9a %>% test_variable_names(
  c(
    "Date...1",
    "Number of pupils not in school because of Covid-19 related reasons...2",
    "Percentage attendance...3",
    "Percentage of openings where pupils were not in school for non COVID-19 related reasons (authorised and unauthorised, including exclusions)...4",
    "Percentage of openings where pupils were not in school because of Covid-19 related reasons...5"
  )
)

raw_SC_table9b %>% test_variable_names(
  c(
    "...1",
    "All...2",
    "Primary...3",
    "Secondary...4",
    "Special...5"
  )
)

raw_SC_table10a %>% test_variable_names(
  c(
    "Date",
    "Number of people who have received the first dose of the Covid vaccination",
    "Number of people who have received the second dose of the Covid vaccination"
  )
)

# Health board data ----------------------------------------------------- #

raw_HB_table1 %>% test_variable_names(
  c(
    "Date notified",
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
    "NHS Western Isles"
  )
)

raw_HB_table2 %>% test_variable_names(
  c(
    "Reporting date",
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
    "Golden Jubilee National Hospital"
  )
)

raw_HB_table3 %>% test_variable_names(
  c(
    "Reporting date",
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
    "Golden Jubilee National Hospital"
  )
)
