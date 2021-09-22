# Manual URL entry --------------------------------------------------------

# If the URL for either data set has changed, replace NA with the new URL.
# Eg: metadata$daily_data_trends$url_manual <- "https://gov.scot/new.xlsx".
# This is only necessary if the file naming scheme has changed.
# Otherwise, leave this section unchanged.

metadata <- as.list(NULL)
metadata$daily_data_trends$url_manual <- NA
metadata$daily_data_by_nhs_board$url_manual <- NA
