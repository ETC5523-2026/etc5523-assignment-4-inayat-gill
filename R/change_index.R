#' Change in foot traffic relative to a baseline year
#'
#' Works out the average number of pedestrians per day at each chosen sensor in
#' each year, then compares each year with a baseline year. An index of 100
#' means the same daily traffic as the baseline year. An index of 60 means 40%
#' fewer people. By default the baseline is the earliest year in the data, so
#' the index shows how foot traffic has grown or shrunk since then.
#'
#' The average daily count adds up the 24 hourly averages for weekdays and for
#' weekends, then weights them 5 to 2 to represent a typical week. A sensor and
#' year are only included when both day types have all 24 hours recorded, so
#' years with large gaps in the data are left out rather than understated.
#'
#' @param sensors Integer vector of sensor `location_id` values to keep. See
#'   [ped_sensors].
#' @param baseline_year The year to compare against. The default, `NULL`, uses
#'   the earliest year in `data`.
#' @param years Optional integer vector of years to return. The default,
#'   `NULL`, returns every year available.
#' @param data A data frame with the same columns as [ped_hourly]. Defaults to
#'   [ped_hourly].
#'
#' @return A data frame with one row per sensor and year, containing
#'   `location_id`, `sensor_name`, `year`, `daily_mean` (average pedestrians
#'   per day), `baseline` (average per day in the baseline year) and `index`
#'   (`daily_mean` as a percentage of `baseline`). `baseline` and `index` are
#'   `NA` for sensors with no complete data in the baseline year.
#'
#' @export
#'
#' @examples
#' some_sensors <- unique(ped_hourly$location_id)[1:3]
#' change_index(sensors = some_sensors)
change_index <- function(sensors, baseline_year = NULL, years = NULL,
                         data = ped_hourly) {
  if (!is.null(baseline_year) &&
      (!is.numeric(baseline_year) || length(baseline_year) != 1)) {
    stop("`baseline_year` must be a single year, such as 2024.", call. = FALSE)
  }
  needed <- c("location_id", "sensor_name", "year", "day_type", "hour",
              "mean_count")
  if (!is.data.frame(data) || !all(needed %in% names(data))) {
    stop("`data` must be a data frame with columns: ",
         paste(needed, collapse = ", "), ".", call. = FALSE)
  }

  if (is.null(baseline_year)) {
    baseline_year <- min(data$year)
  }

  complete <- data |>
    dplyr::filter(.data$location_id %in% sensors) |>
    dplyr::group_by(.data$location_id, .data$sensor_name, .data$year,
                    .data$day_type) |>
    dplyr::summarise(
      total = sum(.data$mean_count),
      n_hours = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::filter(.data$n_hours == 24L)

  daily <- complete |>
    dplyr::mutate(weight = dplyr::if_else(.data$day_type == "Weekday", 5, 2)) |>
    dplyr::group_by(.data$location_id, .data$sensor_name, .data$year) |>
    dplyr::summarise(
      daily_mean = sum(.data$total * .data$weight) / sum(.data$weight),
      n_types = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::filter(.data$n_types == 2L) |>
    dplyr::select(-dplyr::all_of("n_types"))

  baseline <- daily |>
    dplyr::filter(.data$year == baseline_year) |>
    dplyr::transmute(
      location_id = .data$location_id,
      baseline = .data$daily_mean
    )

  out <- daily |>
    dplyr::left_join(baseline, by = "location_id") |>
    dplyr::mutate(index = 100 * .data$daily_mean / .data$baseline)

  if (!is.null(years)) {
    out <- dplyr::filter(out, .data$year %in% years)
  }

  dplyr::arrange(out, .data$sensor_name, .data$year)
}
