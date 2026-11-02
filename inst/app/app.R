# Melbourne foot traffic: Shiny app (first working version).
# Launched with melbfoot::launch_app(). Data come from the installed package.

library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)

# Data included in the package (no CSV is read when the app runs)
ped_hourly <- melbfoot::ped_hourly

sensor_lookup <- ped_hourly |>
  distinct(location_id, sensor_name) |>
  arrange(sensor_name)
sensor_choices <- setNames(sensor_lookup$location_id, sensor_lookup$sensor_name)
all_years <- sort(unique(ped_hourly$year))

# Default to the sensor with the most recorded days
default_sensor <- ped_hourly |>
  group_by(location_id) |>
  summarise(days = sum(n_days), .groups = "drop") |>
  slice_max(days, n = 1, with_ties = FALSE) |>
  pull(location_id)

ui <- page_sidebar(
  title = "Melbourne foot traffic: when, where and how much has it recovered?",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  sidebar = sidebar(
    width = 320,
    selectizeInput(
      "sensors", "Sensor locations (choose up to 3)",
      choices = sensor_choices, selected = default_sensor, multiple = TRUE,
      options = list(maxItems = 3)
    ),
    checkboxGroupInput(
      "years", "Years to compare",
      choices = all_years,
      selected = intersect(c(2019, 2020, 2022), all_years)
    ),
    radioButtons("day", "Type of day", c("Weekday", "Weekend"))
  ),
  card(card_header("A typical day: average pedestrians per hour"),
       plotOutput("profile", height = "360px")),
  card(card_header("Average daily foot traffic compared with 2019 (2019 = 100)"),
       plotOutput("recovery", height = "320px"))
)

server <- function(input, output, session) {

  # One shared selection used by both outputs
  chosen_sensors <- reactive({
    validate(need(length(input$sensors) > 0,
                  "Choose at least one sensor location in the sidebar."))
    as.integer(input$sensors)
  }, label = "chosen_sensors")

  profile_data <- reactive({
    validate(need(length(input$years) > 0,
                  "Choose at least one year in the sidebar."))
    melbfoot::hourly_profile(
      sensors = chosen_sensors(),
      years = as.integer(input$years),
      day = input$day
    )
  }, label = "profile_data")

  output$profile <- renderPlot({
    d <- profile_data()
    validate(need(
      nrow(d) > 0,
      "No counts for this sensor, year and day type. Try other years or another sensor."
    ))
    ggplot(d, aes(hour, mean_count, colour = factor(year), group = year)) +
      geom_line(linewidth = 1) +
      facet_wrap(~sensor_name) +
      scale_x_continuous(breaks = seq(0, 23, 3)) +
      labs(x = "Hour of day (0 = midnight)", y = "Average pedestrians per hour",
           colour = "Year") +
      theme_minimal(base_size = 14) +
      theme(legend.position = "bottom")
  })

  output$recovery <- renderPlot({
    d <- melbfoot::recovery_index(chosen_sensors(), baseline_year = 2019)
    validate(need(
      nrow(d) > 0 && any(!is.na(d$index)),
      "No complete 2019 data for the chosen sensors, so no comparison is possible. Try another sensor."
    ))
    d <- filter(d, !is.na(index))
    ggplot(d, aes(year, index, colour = sensor_name)) +
      geom_hline(yintercept = 100, linetype = "dashed", colour = "grey50") +
      geom_line(linewidth = 1) +
      geom_point(size = 2.5) +
      scale_x_continuous(breaks = sort(unique(d$year))) +
      labs(x = NULL, y = "Daily traffic as % of 2019", colour = NULL) +
      theme_minimal(base_size = 14) +
      theme(legend.position = "bottom")
  })
}

shinyApp(ui, server)
