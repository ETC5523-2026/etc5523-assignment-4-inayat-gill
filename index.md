# melbfoot

## Purpose

`melbfoot` helps people who plan around foot traffic in central
Melbourne, such as café owners and event planners, answer a practical
question: **when and where are the most people walking past, and how
much has foot traffic changed since 2025?**

The package contains the data, two helper functions and a Shiny app:

- `ped_hourly`: average pedestrians per hour for each sensor, year and
  type of day (weekday or weekend).
- `ped_sensors`: where each sensor is.
- [`hourly_profile()`](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/hourly_profile.md):
  pulls out the typical-day pattern for chosen sensors and years.
- [`change_index()`](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/change_index.md):
  compares each year’s average daily traffic with a baseline year (the
  earliest year in the data, 2025, by default).
- [`launch_app()`](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/reference/launch_app.md):
  opens the Shiny app.

## Data

The data come from the City of Melbourne [Pedestrian Counting
System](https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-monthly-counts-per-hour/)
(counts per hour) and its [Sensor
Locations](https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/)
dataset, published on the City of Melbourne Open Data Portal. The Sensor
Locations dataset is licensed [CC BY
4.0](https://creativecommons.org/licenses/by/4.0/). The portal page for
the counts dataset does not state a licence, so the City of Melbourne is
credited as the source throughout.

The raw hourly counts are large, so the package includes a summarised
version: average pedestrians per hour, by sensor, year and day type. The
portal data start in November 2024 and run to early November 2026, so to
make years comparable the package keeps only 1 January to 2 November in
2025 and 2026. The script `data-raw/ped_data.R` downloads the raw files
and builds the packaged data, so the process can be reproduced.

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

In the app, choose up to three sensor locations, pick the years to
compare and choose weekday or weekend. The first tab shows the typical
hour-by-hour pattern and the busiest hour for each sensor. The second
tab shows how each year’s daily traffic compares with 2025. The third
tab explains the fields and what to keep in mind when reading the
charts. A step-by-step guide is in the vignette:
[`vignette("getting-started", package = "melbfoot")`](https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/articles/getting-started.md).

## Example

``` r

library(melbfoot)

# Typical weekday in the latest year for the sensor with the most data
busiest <- ped_hourly$location_id[which.max(ped_hourly$n_days)]
hourly_profile(sensors = busiest, years = max(ped_hourly$year), day = "Weekday")

# How has daily traffic at the same sensor changed since 2025?
change_index(sensors = busiest)
```

## Documentation

Full documentation, including a getting-started guide and the function
reference, is on the package website:
<https://etc5523-2026.github.io/etc5523-assignment-4-inayat-gill/>

## Generative AI declaration

I used Claude AI to check my draft against the assessment rubric, verify
figures and claims against the original paper, and suggest wording
improvements for clarity and tone. I checked, verified, and revised all
suggestions and the final text myself.
