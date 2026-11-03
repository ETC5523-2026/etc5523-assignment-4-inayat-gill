# Launch the Melbourne foot traffic Shiny app

Opens the interactive app included in this package. The app lets you
compare the typical hourly pattern of foot traffic across Melbourne
sensor locations and years, and see how traffic has changed since the
earliest year in the data.

## Usage

``` r
launch_app()
```

## Value

Called for its side effect of starting the app. It does not return a
value.

## Examples

``` r
if (interactive()) {
  launch_app()
}
```
