# Typical-day pedestrian profile for chosen sensors and years

Selects the average hourly pedestrian counts for the sensors, years and
day type you choose, so you can compare the shape of a typical day
across places and years. This is the table behind the app's "typical
day" chart.

## Usage

``` r
hourly_profile(
  sensors,
  years,
  day = c("Weekday", "Weekend"),
  data = ped_hourly
)
```

## Arguments

- sensors:

  Integer vector of sensor `location_id` values to keep. See
  [ped_sensors](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/ped_sensors.md)
  for the available IDs.

- years:

  Integer vector of years to keep.

- day:

  Which kind of day to show: `"Weekday"` (Monday to Friday) or
  `"Weekend"` (Saturday and Sunday). Defaults to `"Weekday"`.

- data:

  A data frame with the same columns as
  [ped_hourly](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/ped_hourly.md).
  Defaults to
  [ped_hourly](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/ped_hourly.md).

## Value

A data frame with one row per sensor, year and hour, containing
`location_id`, `sensor_name`, `year`, `day_type`, `hour`, `mean_count`
and `n_days`. If none of the chosen sensors and years have data, a data
frame with zero rows is returned, so callers can show a helpful message.

## Examples

``` r
# Busiest sensor in the data, weekdays in the latest year
top_sensor <- ped_hourly[which.max(ped_hourly$mean_count), "location_id"][[1]]
hourly_profile(sensors = top_sensor, years = max(ped_hourly$year), day = "Weekday")
#> # A tibble: 24 × 7
#>    location_id sensor_name  year day_type  hour mean_count n_days
#>          <int> <chr>       <int> <chr>    <int>      <dbl>  <int>
#>  1           4 Swa123_T     2026 Weekday      0      203.     216
#>  2           4 Swa123_T     2026 Weekday      1      105.     216
#>  3           4 Swa123_T     2026 Weekday      2       58.3    216
#>  4           4 Swa123_T     2026 Weekday      3       38.2    216
#>  5           4 Swa123_T     2026 Weekday      4       39.1    215
#>  6           4 Swa123_T     2026 Weekday      5       72.3    215
#>  7           4 Swa123_T     2026 Weekday      6      188.     215
#>  8           4 Swa123_T     2026 Weekday      7      425.     215
#>  9           4 Swa123_T     2026 Weekday      8      940.     215
#> 10           4 Swa123_T     2026 Weekday      9     1132      215
#> # ℹ 14 more rows
```
