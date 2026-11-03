# Typical hourly pedestrian counts by sensor, year and day type

Average pedestrian counts for each hour of the day, summarised from the
City of Melbourne Pedestrian Counting System (counts per hour). Each row
is the average count in one hour of the day, for one sensor location, in
one year, on weekdays or on weekends. Hours with fewer than 10 recorded
days were dropped to avoid noisy averages.

## Usage

``` r
ped_hourly
```

## Format

A data frame (tibble) with one row per sensor, year, day type and hour,
and these columns:

- location_id:

  Integer ID of the sensor location. Matches `location_id` in
  [ped_sensors](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/ped_sensors.md).

- sensor_name:

  Short name of the sensor location, for example a street or mall name.

- year:

  Calendar year (integer).

- day_type:

  Either `"Weekday"` (Monday to Friday) or `"Weekend"` (Saturday and
  Sunday).

- hour:

  Hour of the day, from 0 (midnight to 1am) to 23 (11pm to midnight).

- mean_count:

  Average number of pedestrians counted in that hour, across all
  recorded days in that group, rounded to one decimal place.

- n_days:

  Number of distinct days that went into the average. Small values mean
  the sensor was working for only part of the year, so treat the average
  with more caution.

## Source

City of Melbourne, *Pedestrian Counting System (counts per hour)*, City
of Melbourne Open Data Portal,
<https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-monthly-counts-per-hour/>.
The portal page for this dataset does not state a licence. The companion
Sensor Locations dataset is licensed CC BY 4.0, so attribution to the
City of Melbourne is given here.

## Details

Every year covers the same stretch of the calendar, from 1 January to 2
November, so years can be compared without seasonal differences. Earlier
parts of the data that did not span a whole January to November window
(late 2024) and dates after 2 November are not included.

The data are prepared by `data-raw/ped_data.R`.

## Examples

``` r
head(ped_hourly)
#> # A tibble: 6 × 7
#>   location_id sensor_name  year day_type  hour mean_count n_days
#>         <int> <chr>       <int> <chr>    <int>      <dbl>  <int>
#> 1         108 261Will_T    2025 Weekday      0       56.3    218
#> 2         108 261Will_T    2025 Weekday      1       30.1    218
#> 3         108 261Will_T    2025 Weekday      2       19.7    218
#> 4         108 261Will_T    2025 Weekday      3       14.5    218
#> 5         108 261Will_T    2025 Weekday      4       14.2    217
#> 6         108 261Will_T    2025 Weekday      5       83.1    218
```
