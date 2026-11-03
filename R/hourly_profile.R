#' Typical-day pedestrian profile for chosen sensors and years
#'
#' Selects the average hourly pedestrian counts for the sensors, years and day
#' type you choose, so you can compare the shape of a typical day across
#' places and years. This is the table behind the app's "typical day" chart.
#'
#' @param sensors Integer vector of sensor `location_id` values to keep. See
#'   [ped_sensors] for the available IDs.
#' @param years Integer vector of years to keep.
#' @param day Which kind of day to show: `"Weekday"` (Monday to Friday) or
#'   `"Weekend"` (Saturday and Sunday). Defaults to `"Weekday"`.
#' @param data A data frame with the same columns as [ped_hourly]. Defaults to
#'   [ped_hourly].
#'
#' @return A data frame with one row per sensor, year and hour, containing
#'   `location_id`, `sensor_name`, `year`, `day_type`, `hour`, `mean_count` and
#'   `n_days`. If none of the chosen sensors and years have data, a data frame
#'   with zero rows is returned, so callers can show a helpful message.
#'
#' @export
#'
#' @examples
#' # Busiest sensor in the data, weekdays in the latest year
#' top_sensor <- ped_hourly[which.max(ped_hourly$mean_count), "location_id"][[1]]
#' hourly_profile(sensors = top_sensor, years = max(ped_hourly$year), day = "Weekday")
hourly_profile <- function(sensors, years, day = c("Weekday", "Weekend"),
                           data = ped_hourly) {
  day <- match.arg(day)
  needed <- c("location_id", "sensor_name", "year", "day_type", "hour",
              "mean_count", "n_days")
  if (!is.data.frame(data) || !all(needed %in% names(data))) {
    stop("`data` must be a data frame with columns: ",
         paste(needed, collapse = ", "), ".", call. = FALSE)
  }

  data |>
    dplyr::filter(
      .data$location_id %in% sensors,
      .data$year %in% years,
      .data$day_type == day
    ) |>
    dplyr::arrange(.data$sensor_name, .data$year, .data$hour)
}
