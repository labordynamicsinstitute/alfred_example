# FRED API Data Vintage Example in R
# Demonstrates the importance of using vintage dates when pulling API data

# Load required libraries
if (!require("fredr")) install.packages("fredr")
if (!require("dplyr")) install.packages("dplyr")
if (!require("tidyr")) install.packages("tidyr")
library(fredr)
library(dplyr)


# Set some parameters we want to re-use
# - the date range we want
DATE_START <- as.Date("2007-01-01")
DATE_END <- as.Date("2007-01-01")
# - the as-of date we want
CURRENT_DATE <- Sys.Date()
VINTAGE <- as.Date("2021-12-31")
# - for testing, other as-of dates
ALTVINTAGES <- as.Date(c("2008-09-15", "2015-09-15"))
NOTE <- "README ::::"

# Now go ahead and import the data, by default (lazy path)
cat("\n=== Pulling data WITHOUT vintage specification ===\n")
data_default <- fredr(
  series_id = "GNPCA",
  observation_start = DATE_START,
  observation_end = DATE_END
)
print(data_default)
default_value <- mean(data_default$value, na.rm = TRUE)

# Now do the same thing, but precisely defining the vintages
cat("\n=== Pulling data WITH vintage specification ===\n")
data_vintaged <- fredr(
  series_id = "GNPCA",
  observation_start = DATE_START,
  observation_end = DATE_END,
  vintage_dates = VINTAGE
)
print(data_vintaged)
vintaged_value <- mean(data_vintaged$value, na.rm = TRUE)

cat(sprintf("\nAs of %s, the two values are:\n", CURRENT_DATE))
cat(sprintf(" - %.2f when not specifying a vintage\n", default_value))
cat(sprintf(" - %.2f when specifying vintage %s\n", vintaged_value, VINTAGE))

# Expected result:
# As of [current date], the two values may differ because:
# - The default pulls the most recent revision
# - The vintaged data pulls the value as it was known on 2021-12-31

# Now let's see why this matters - let's pull down a few more vintages
cat("\n=== Pulling multiple vintages for comparison ===\n")

# Combine all vintage dates
all_vintages <- c(VINTAGE, ALTVINTAGES)

# Pull data for each vintage
vintage_data_list <- lapply(all_vintages, function(vintage) {
  data <- fredr(
    series_id = "GNPCA",
    observation_start = DATE_START,
    observation_end = DATE_END,
    vintage_dates = vintage
  )
  data$vintage <- as.character(vintage)
  return(data)
})

# Combine all vintage data
vintage_comparison <- do.call(rbind, vintage_data_list)

# Reshape for comparison
vintage_wide <- vintage_comparison %>%
  select(date, value, vintage) %>%
  tidyr::pivot_wider(names_from = vintage, values_from = value, names_prefix = "vintage_")

cat("\nComparison of GNPCA values across different vintages:\n")
print(vintage_wide)

cat("\nNOTE: These values should NEVER change once recorded.\n")
cat("The value for 2007-01-01 as of 2008-09-15 will always be what it was on that date.\n")

# LESSON:
cat("\n=== KEY LESSONS ===\n")
cat("1. Always use a fixed vintage date to query the API for reproducibility\n")
cat("2. Some series change as time progresses, even for historical values\n")
cat("3. Without vintage specification, you get the latest revision\n")

# SUPPLEMENTARY LESSON
# Save the data pulled through the API as an intermediate dataset
# and if permissible by the license (check!), redistribute it
# in case that the API is deprecated and won't work in the future

cat("\n=== Data Persistence Strategy ===\n")

# Create directories if they don't exist
dir.create("data", showWarnings = FALSE)
dir.create("data/fred", showWarnings = FALSE)

# Check if file exists
if (file.exists("data/fred/fred_gnpca.rds")) {
  cat(NOTE, "Re-using existing file\n")
  fred_data <- readRDS("data/fred/fred_gnpca.rds")
} else {
  # Code if the file does not exist
  # You could do the full API pull
  # conditional on the intermediate
  # file NOT being there
  cat(NOTE, "Reading in data from FRED API with vintage =", as.character(VINTAGE), "\n")
  fred_data <- fredr(
    series_id = "GNPCA",
    observation_start = DATE_START,
    observation_end = DATE_END,
    vintage_dates = VINTAGE
  )
  saveRDS(fred_data, "data/fred/fred_gnpca.rds")
}

cat("\n=== Final Dataset ===\n")
print(fred_data)

cat("\n=== Analysis Complete ===\n")
cat("Intermediate data saved to: data/fred/fred_gnpca.rds\n")
cat("This ensures reproducibility even if the API changes or becomes unavailable.\n")
