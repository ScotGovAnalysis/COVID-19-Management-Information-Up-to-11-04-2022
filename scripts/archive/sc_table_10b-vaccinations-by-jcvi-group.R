# ----------------------------------------------------------------------- #
# Table 10-B
# Daily COVID-19 vaccinations in Scotland by JCVI Priority Group
# Number of people who have received the Covid vaccination by JCVI priority group
# ----------------------------------------------------------------------- #

# Because the structure of this data set frequently changes, a hard-coded
# solution has been used. This script will need changing every time that
# the data set is changed, but it will return errors and warnings to
# indicate that this has to be done.

sc_table_10_b <- NULL

sc_table_10_b$metadata$title <- "Vaccinations by JCVI priority group"
sc_table_10_b$metadata$description <- "Number of people who have received the Covid vaccination by JCVI priority group"

sc_table_10_b$variables$expected_category_names <- c(
  "Care Home Residents (1st dose)",
  "Care Home Staff (1st dose)",
  "Individuals aged 80 or over living in the community (excluding care home residents) (1st dose)",
  "Frontline health and social care workers (1st dose)",
  "Individuals aged 75-79 living in the community (excluding care home residents) (1st dose)",
  "Individuals aged 70-74 living in the community (excluding care home residents) (1st dose)",
  "Clinically extremely vulnerable (individuals on the shielding list) (1st dose)",
  "Care Home Residents (2nd dose)"
)

sc_table_10_b$variables$expected_names <- c(
  "...1",
  "Number vaccinated...2",
  "Estimated population of residents in older adult care homes...3",
  "% Vaccinated for residents in older adult care homes...4",
  "Estimated population of residents in all care homes...5",
  "% Vaccinated for residents in all care homes...6",
  "Number vaccinated...7",
  "Estimated population of staff in older adult care homes",
  "% Vaccinated for staff in older adult care homes",
  "Estimated population of staff in all care homes",
  "% Vaccinated for staff in all care homes",
  "Number vaccinated...12",
  "Estimated population...13",
  "% Vaccinated...14",
  "Number vaccinated...15",
  "Estimated population...16",
  "% Vaccinated...17",
  "Number vaccinated...18",
  "Estimated population...19",
  "% Vaccinated...20",
  "Number vaccinated...21",
  "Estimated population...22",
  "% Vaccinated...23",
  "Number vaccinated...24",
  "Estimated population...25",
  "% Vaccinated...26",
  "...27",
  "Number vaccinated with 2nd dose",
  "Estimated population of residents in older adult care homes...29",
  "% Vaccinated for residents in older adult care homes...30",
  "Estimated population of residents in all care homes...31",
  "% Vaccinated for residents in all care homes...32"
)

sc_table_10_b$variables$expected_count <- length(sc_table_10_b$variables$expected_names)

# Read data ---------------------------------------------------------------

sc_table_10_b$data$raw <- read_excel(
  path = tf1,
  sheet = "Table 10b - Vac by JCVI group",
  col_types = c(
    "date",
    rep("numeric", times = sc_table_10_b$variables$expected_count - 1)
  ),
  na = c(
    "* Age breakdowns now provided on a diffferent basis - see Table 10c",
    "*Initial target met"
  ),
  skip = 3
)

# Fetch prefix for each variable name from the merged cells above them

sc_table_10_b$variables$actual_category_names <- read_excel(
  path = tf1,
  sheet = "Table 10b - Vac by JCVI group",
  col_names = FALSE,
  skip = 2,
  n_max = 1
  ) %>% 
  as.character()

sc_table_10_b$variables$actual_category_names <- sc_table_10_b$variables$actual_category_names[
  sc_table_10_b$variables$actual_category_names != "NA" & sc_table_10_b$variables$actual_category_names != "Date"
  ] %>% 
  str_remove_all("\\r\\n")

# Quality assurance -------------------------------------------------------

test_variable_count(sc_table_10_b$data$raw, sc_table_10_b$variables$expected_count)
test_variable_names(sc_table_10_b$data$raw, sc_table_10_b$variables$expected_names)

# Drop variables ----------------------------------------------------------

sc_table_10_b$data$new <- sc_table_10_b$data$raw %>% 
  select(
    -"...27"
  )

# Rename variables --------------------------------------------------------

sc_table_10_b$variables$new_category_names <- c(
  
  "Care home residents - All care homes - Dose 1",
  "Care home residents - Older adult care homes - Dose 1",
  "Care home staff - All care homes - Dose 1",
  "Care home staff - Older adult care homes - Dose 1",
  "Aged 80 or over excluding care home residents - Dose 1",
  "Frontline health and social care workers - Dose 1",
  "Aged 75 to 79 excluding care home residents - Dose 1",
  "Aged 70 to 74 excluding care home residents - Dose 1",
  "Clinically extremely vulnerable - Dose 1",
  
  "Care home residents - All care homes - Dose 2",
  "Care home residents - Older adult care homes - Dose 2"
  
)

sc_table_10_b$variables$new_category_names <- c(
  
  sc_table_10_b$variables$new_category_names[1] %>% rep(1),
  sc_table_10_b$variables$new_category_names[2] %>% rep(2),
  sc_table_10_b$variables$new_category_names[1] %>% rep(2),
  
  sc_table_10_b$variables$new_category_names[3] %>% rep(1),
  sc_table_10_b$variables$new_category_names[4] %>% rep(2),
  sc_table_10_b$variables$new_category_names[3] %>% rep(2),
  
  sc_table_10_b$variables$new_category_names[5:9] %>% rep(each = 3),
  
  sc_table_10_b$variables$new_category_names[10] %>% rep(1),
  sc_table_10_b$variables$new_category_names[11] %>% rep(2),
  sc_table_10_b$variables$new_category_names[10] %>% rep(2)
  
)

sc_table_10_b$variables$new_names <- names(sc_table_10_b$data$new)[-1]

sc_table_10_b$variables$new_names[grep("Number vaccinated", sc_table_10_b$variables$new_names)] <- "Number vaccinated"
sc_table_10_b$variables$new_names[grep("Estimated population", sc_table_10_b$variables$new_names)] <- "Estimated population"
sc_table_10_b$variables$new_names[grep("% Vaccinated", sc_table_10_b$variables$new_names)] <- "Percentage of estimated population vaccinated"

sc_table_10_b$variables$new_names <- str_c(
  "Vaccinations",
  "By JCVI priority group",
  sc_table_10_b$variables$new_category_names,
  sc_table_10_b$variables$new_names,
  sep = " - "
)

sc_table_10_b$variables$new_names <- c(
  "Date",
  sc_table_10_b$variables$new_names
)

names(sc_table_10_b$data$new) <- sc_table_10_b$variables$new_names

# Tidy data frame ---------------------------------------------------------

sc_table_10_b$data$tidy <- sc_table_10_b$data$new %>% 
  select(
    -ends_with("Estimated population")
  ) %>% 
  gather(
    key = "Variable",
    value = "Value",
    -Date
  ) %>%
  mutate(
    Measurement = case_when(
      str_ends(Variable, "Number vaccinated") ~ "Count",
      str_ends(Variable, "Percentage of estimated population vaccinated") ~ "Ratio"
    )
  )

# Copy data frame to global environment -----------------------------------

tidy_SC_table10b <- sc_table_10_b$data$tidy
