# melbfoot

<!-- badges: start -->
<!-- badges: end -->

## Purpose

`melbfoot` helps people who plan around foot traffic in central Melbourne,
such as café owners and event planners, answer a practical question: **when
and where are the most people walking past, and how much has foot traffic
changed since 2024?**

The package contains the data, two helper functions and a Shiny app:

- `ped_hourly`: average pedestrians per hour for each sensor, year and type
  of day (weekday or weekend).
- `ped_sensors`: where each sensor is.
- `hourly_profile()`: pulls out the typical-day pattern for chosen sensors
  and years.
- `change_index()`: compares each year's average daily traffic with a
  baseline year (the earliest year in the data, 2024, by default).
- `launch_app()`: opens the Shiny app.

## Data

The data come from the City of Melbourne
[Pedestrian Counting System](https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-monthly-counts-per-hour/)
(counts per hour) and its
[Sensor Locations](https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/)
dataset, published on the City of Melbourne Open Data Portal. The Sensor
Locations dataset is licensed
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). The portal page for
the counts dataset does not state a licence, so the City of Melbourne is
credited as the source throughout.

The raw hourly counts are large, so the package includes a summarised version:
average pedestrians per hour, by sensor, year and day type. The script
`data-raw/ped_data.R` downloads the raw files and builds the packaged data, so
the process can be reproduced.

## Installation

Install the package from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-inayat-gill")
```

## Launch the app

``` r
library(melbfoot)
launch_app()
```

In the app, choose up to three sensor locations, pick the years to compare and
choose weekday or weekend. The top chart shows the typical hour-by-hour
pattern, and the bottom chart shows how each year's daily traffic compares
with 2024.

## Example

``` r
library(melbfoot)

# Typical weekday in the latest year for the sensor with the most data
busiest <- ped_hourly$location_id[which.max(ped_hourly$n_days)]
hourly_profile(sensors = busiest, years = max(ped_hourly$year), day = "Weekday")

# How has daily traffic at the same sensor changed since 2024?
change_index(sensors = busiest)
```

## Documentation

Full documentation, including a getting-started guide and the function
reference, is on the package website:
<https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/>

## Generative AI declaration

*Complete this section to describe accurately how you used generative AI in
this assessment.*