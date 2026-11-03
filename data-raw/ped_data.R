# data-raw/ped_data.R
#
# Builds the two datasets included in the melbfoot package:
#   * ped_sensors: where each pedestrian sensor is
#   * ped_hourly:  average hourly counts by sensor, year, day type and hour
#
# Source: City of Melbourne Open Data Portal, Pedestrian Counting System.
#   Counts per hour:
#   https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-monthly-counts-per-hour/
#   Sensor locations (CC BY 4.0):
#   https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/


library(dplyr)
library(readr)

options(timeout = 1200)

counts_url <- paste0(
  "https://data.melbourne.vic.gov.au/api/v2/catalog/datasets/",
  "pedestrian-counting-system-monthly-counts-per-hour/exports/csv?delimiter=%2C"
)
sensors_url <- paste0(
  "https://data.melbourne.vic.gov.au/api/v2/catalog/datasets/",
  "pedestrian-counting-system-sensor-locations/exports/csv?delimiter=%2C"
)

dir.create("data-raw/raw", showWarnings = FALSE, recursive = TRUE)
counts_file <- "data-raw/raw/counts-per-hour.csv"
sensors_file <- "data-raw/raw/sensor-locations.csv"

if (!file.exists(counts_file)) {
  download.file(counts_url, counts_file, mode = "wb")
}
if (!file.exists(sensors_file)) {
  download.file(sensors_url, sensors_file, mode = "wb")
}

# Helper: read every column as text, lower-case the names, check the columns
# we need are present, then convert types explicitly. This avoids surprises
# from type guessing.
read_portal_csv <- function(path, needed) {
  raw <- read_csv(path, col_types = cols(.default = col_character()),
                  progress = FALSE)
  names(raw) <- tolower(names(raw))
  missing_cols <- setdiff(needed, names(raw))
  if (length(missing_cols) > 0) {
    stop("Columns not found in ", path, ": ",
         paste(missing_cols, collapse = ", "),
         ". Check the portal's column names.", call. = FALSE)
  }
  raw
}

# ---- Sensor locations --------------------------------------------------------

sensors_raw <- read_portal_csv(
  sensors_file,
  c("location_id", "sensor_name", "sensor_description", "status",
    "installation_date", "latitude", "longitude")
)

ped_sensors <- sensors_raw |>
  transmute(
    location_id = as.integer(location_id),
    sensor_name,
    sensor_description,
    status,
    installation_date = as.Date(installation_date),
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude)
  ) |>
  distinct(location_id, .keep_all = TRUE) |>
  arrange(sensor_name)

# ---- Hourly counts -----------------------------------------------------------

counts_raw <- read_portal_csv(
  counts_file,
  c("location_id", "sensing_date", "hourday", "pedestriancount")
)

counts <- counts_raw |>
  transmute(
    location_id = as.integer(location_id),
    sensing_date = as.Date(sensing_date),
    hour = as.integer(hourday),
    count = as.numeric(pedestriancount)
  ) |>
  filter(!is.na(location_id), !is.na(sensing_date), !is.na(hour),
         !is.na(count))

stopifnot(all(counts$hour %in% 0:23))

# Make the years comparable. The portal data start part-way through 2024
# and end part-way through the latest year, so a raw yearly average would
# compare different seasons. Keep only years that start on 1 January, and
# only the calendar dates (month and day) up to the last date in the data,
# so that every year covers exactly the same stretch of the year.
last_date <- max(counts$sensing_date)
cutoff_md <- format(last_date, "%m-%d")
year_starts <- counts |>
  mutate(year = as.integer(format(sensing_date, "%Y"))) |>
  group_by(year) |>
  summarise(first_md = format(min(sensing_date), "%m-%d"), .groups = "drop")
full_years <- year_starts$year[year_starts$first_md == "01-01"]

counts <- counts |>
  filter(as.integer(format(sensing_date, "%Y")) %in% full_years,
         format(sensing_date, "%m-%d") <= cutoff_md)

message("Comparison window: 1 January to ", format(last_date, "%d %B"),
        " in each of ", paste(full_years, collapse = ", "))

# Average hour-by-hour pattern for each sensor, year and day type.
# "%u" is the ISO weekday number (1 = Monday ... 7 = Sunday), so it does not
# depend on the computer's language settings.
ped_hourly <- counts |>
  mutate(
    year = as.integer(format(sensing_date, "%Y")),
    day_type = if_else(format(sensing_date, "%u") %in% c("6", "7"),
                       "Weekend", "Weekday")
  ) |>
  group_by(location_id, year, day_type, hour) |>
  summarise(
    mean_count = round(mean(count), 1),
    n_days = n_distinct(sensing_date),
    .groups = "drop"
  ) |>
  # Drop averages built from very few days: they are too noisy to compare
  filter(n_days >= 10) |>
  left_join(select(ped_sensors, location_id, sensor_name),
            by = "location_id") |>
  filter(!is.na(sensor_name)) |>
  select(location_id, sensor_name, year, day_type, hour, mean_count, n_days) |>
  arrange(sensor_name, year, day_type, hour)

# Keep only sensors that appear in the counts
ped_sensors <- ped_sensors |>
  filter(location_id %in% ped_hourly$location_id)

# ---- Checks and save ---------------------------------------------------------

stopifnot(
  nrow(ped_hourly) > 0,
  !anyNA(ped_hourly),
  all(ped_hourly$day_type %in% c("Weekday", "Weekend"))
)

message("ped_hourly: ", nrow(ped_hourly), " rows, ",
        n_distinct(ped_hourly$location_id), " sensors, years ",
        min(ped_hourly$year), " to ", max(ped_hourly$year))

usethis::use_data(ped_hourly, ped_sensors, overwrite = TRUE, compress = "xz")

# The package should stay small (aim for well under 5 MB)
data_size <- file.size(c("data/ped_hourly.rda", "data/ped_sensors.rda"))
message("Saved data sizes (MB): ", paste(round(data_size / 1e6, 2), collapse = ", "))
stopifnot(sum(data_size) < 5e6)