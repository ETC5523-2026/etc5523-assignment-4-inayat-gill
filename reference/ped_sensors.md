# Pedestrian sensor locations

Details of the pedestrian counting sensors that appear in
[ped_hourly](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/ped_hourly.md).

## Usage

``` r
ped_sensors
```

## Format

A data frame (tibble) with one row per sensor and these columns:

- location_id:

  Integer ID of the sensor location.

- sensor_name:

  Short name of the sensor location.

- sensor_description:

  Where the sensor is located.

- status:

  Sensor status: `"A"` (active), `"I"` (inactive) or `"R"` (removed).

- installation_date:

  Date the sensor was installed.

- latitude:

  Latitude of the sensor, in decimal degrees.

- longitude:

  Longitude of the sensor, in decimal degrees.

## Source

City of Melbourne, *Pedestrian Counting System - Sensor Locations*, City
of Melbourne Open Data Portal,
<https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/>,
licensed under Creative Commons Attribution 4.0 (CC BY 4.0).

## Details

The data are prepared by `data-raw/ped_data.R`.

## Examples

``` r
head(ped_sensors)
#> # A tibble: 6 × 7
#>   location_id sensor_name sensor_description   status installation_date latitude
#>         <int> <chr>       <chr>                <chr>  <date>               <dbl>
#> 1         108 261Will_T   William St - Little… A      2022-10-08           -37.8
#> 2         107 280Will_T   Royal Mint 280 Will… A      2022-10-08           -37.8
#> 3         141 474Fl_T     Awning of Nationwid… A      2023-11-10           -37.8
#> 4          85 488Mac_T    Macaulay Rd (North)  A      2021-12-21           -37.8
#> 5          86 574Qub_T    Queensberry St - Er… A      2021-12-21           -37.8
#> 6          72 ACMI_T      Flinders St- ACMI    A      2020-11-30           -37.8
#> # ℹ 1 more variable: longitude <dbl>
```
