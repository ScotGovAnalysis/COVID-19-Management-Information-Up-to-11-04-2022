# Health board codes (2014) -----------------------------------------------

print_header("Read health board codes")

cat("Reading health board codes from 'import/health-board-codes.csv' ...")

HB_codes <- read_csv(
  file = "import/health-board-codes.csv",
  col_types = cols(
    HB2014Code = col_character(),
    HB2014Name = col_character()
  )
)

print_done()
