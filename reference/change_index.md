# Change in foot traffic relative to a baseline year

Works out the average number of pedestrians per day at each chosen
sensor in each year, then compares each year with a baseline year. An
index of 100 means the same daily traffic as the baseline year. An index
of 60 means 40% fewer people. By default the baseline is the earliest
year in the data, so the index shows how foot traffic has grown or
shrunk since then.

## Usage

``` r
change_index(sensors, baseline_year = NULL, years = NULL, data = ped_hourly)
```

## Arguments

- sensors:

  Integer vector of sensor `location_id` values to keep. See
  [ped_sensors](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/ped_sensors.md).

- baseline_year:

  The year to compare against. The default, `NULL`, uses the earliest
  year in `data`.

- years:

  Optional integer vector of years to return. The default, `NULL`,
  returns every year available.

- data:

  A data frame with the same columns as
  [ped_hourly](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/ped_hourly.md).
  Defaults to
  [ped_hourly](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/ped_hourly.md).

## Value

A data frame with one row per sensor and year, containing `location_id`,
`sensor_name`, `year`, `daily_mean` (average pedestrians per day),
`baseline` (average per day in the baseline year) and `index`
(`daily_mean` as a percentage of `baseline`). `baseline` and `index` are
`NA` for sensors with no complete data in the baseline year.

## Details

The average daily count adds up the 24 hourly averages for weekdays and
for weekends, then weights them 5 to 2 to represent a typical week. A
sensor and year are only included when both day types have all 24 hours
recorded, so years with large gaps in the data are left out rather than
understated.

## Examples

``` r
some_sensors <- unique(ped_hourly$location_id)[1:3]
change_index(sensors = some_sensors)
#> # A tibble: 6 × 6
#>   location_id sensor_name  year daily_mean baseline index
#>         <int> <chr>       <int>      <dbl>    <dbl> <dbl>
#> 1         108 261Will_T    2025     11264.   11264. 100  
#> 2         108 261Will_T    2026     11178.   11264.  99.2
#> 3         107 280Will_T    2025      3801.    3801. 100  
#> 4         107 280Will_T    2026      3712.    3801.  97.6
#> 5         141 474Fl_T      2025      4314.    4314. 100  
#> 6         141 474Fl_T      2026      4787.    4314. 111. 
```
