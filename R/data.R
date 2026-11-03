#' Typical hourly pedestrian counts by sensor, year and day type
#'
#' Average pedestrian counts for each hour of the day, summarised from the
#' City of Melbourne Pedestrian Counting System (counts per hour). Each row is
#' the average count in one hour of the day, for one sensor location, in one
#' year, on weekdays or on weekends. Hours with fewer than 10 recorded days
#' were dropped to avoid noisy averages.
#'
#' Every year covers the same stretch of the calendar, from 1 January to
#' 2 November, so years can be compared without seasonal differences. Earlier
#' parts of the data that did not span a whole January to November window
#' (late 2024) and dates after 2 November are not included.
#'
#' The data are prepared by `data-raw/ped_data.R`.
#'
#' @format A data frame (tibble) with one row per sensor, year, day type and
#'   hour, and these columns:
#' \describe{
#'   \item{location_id}{Integer ID of the sensor location. Matches
#'     `location_id` in [ped_sensors].}
#'   \item{sensor_name}{Short name of the sensor location, for example a
#'     street or mall name.}
#'   \item{year}{Calendar year (integer).}
#'   \item{day_type}{Either `"Weekday"` (Monday to Friday) or `"Weekend"`
#'     (Saturday and Sunday).}
#'   \item{hour}{Hour of the day, from 0 (midnight to 1am) to 23 (11pm to
#'     midnight).}
#'   \item{mean_count}{Average number of pedestrians counted in that hour,
#'     across all recorded days in that group, rounded to one decimal place.}
#'   \item{n_days}{Number of distinct days that went into the average. Small
#'     values mean the sensor was working for only part of the year, so treat
#'     the average with more caution.}
#' }
#'
#' @source City of Melbourne, *Pedestrian Counting System (counts per hour)*,
#'   City of Melbourne Open Data Portal,
#'   <https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-monthly-counts-per-hour/>.
#'   The portal page for this dataset does not state a licence. The companion
#'   Sensor Locations dataset is licensed CC BY 4.0, so attribution to the City
#'   of Melbourne is given here.
#'
#' @examples
#' head(ped_hourly)
"ped_hourly"

#' Pedestrian sensor locations
#'
#' Details of the pedestrian counting sensors that appear in [ped_hourly].
#'
#' The data are prepared by `data-raw/ped_data.R`.
#'
#' @format A data frame (tibble) with one row per sensor and these columns:
#' \describe{
#'   \item{location_id}{Integer ID of the sensor location.}
#'   \item{sensor_name}{Short name of the sensor location.}
#'   \item{sensor_description}{Where the sensor is located.}
#'   \item{status}{Sensor status: `"A"` (active), `"I"` (inactive) or `"R"`
#'     (removed).}
#'   \item{installation_date}{Date the sensor was installed.}
#'   \item{latitude}{Latitude of the sensor, in decimal degrees.}
#'   \item{longitude}{Longitude of the sensor, in decimal degrees.}
#' }
#'
#' @source City of Melbourne, *Pedestrian Counting System - Sensor Locations*,
#'   City of Melbourne Open Data Portal,
#'   <https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/>,
#'   licensed under Creative Commons Attribution 4.0 (CC BY 4.0).
#'
#' @examples
#' head(ped_sensors)
"ped_sensors"
