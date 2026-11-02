# Melbourne foot traffic planner: Shiny app.
# Launched with melbfoot::launch_app(). All data come from the installed
# package, so the app reads no CSV or other external file when it runs.

library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)

# ---- Data and helpers (run once per R process) --------------------------------

ped_hourly <- melbfoot::ped_hourly
ped_sensors <- melbfoot::ped_sensors

sensor_lookup <- ped_hourly |>
  distinct(location_id, sensor_name) |>
  arrange(sensor_name)
sensor_choices <- setNames(sensor_lookup$location_id, sensor_lookup$sensor_name)

all_years <- sort(unique(ped_hourly$year))
baseline_year <- min(all_years)   # earliest year in the packaged data
default_years <- sort(unique(c(baseline_year, max(all_years))))

# Start with the sensor that has the most recorded days
default_sensor <- ped_hourly |>
  group_by(location_id) |>
  summarise(days = sum(n_days), .groups = "drop") |>
  slice_max(days, n = 1, with_ties = FALSE) |>
  pull(location_id)

# 0 -> "12am", 13 -> "1pm" ...
hour_label <- function(h) {
  h12 <- ifelse(h %% 12 == 0, 12, h %% 12)
  paste0(h12, ifelse(h < 12, "am", "pm"))
}

field_guide <- data.frame(
  Field = c(
    "Sensor location",
    "Year",
    "Type of day",
    "Hour of day",
    "Average pedestrians per hour",
    "Days of data",
    paste0("Daily traffic index (", baseline_year, " = 100)")
  ),
  Meaning = c(
    "A fixed counting device on a Melbourne street. Choose the ones closest to your business or event.",
    paste0("Calendar year of the counts. ", baseline_year, " is the earliest year in the data and is the baseline for the change chart. The latest year may be incomplete, so check the days of data."),
    "Weekday means Monday to Friday. Weekend means Saturday and Sunday.",
    "The hour that starts at the time shown, for example 8am means 8:00 to 8:59.",
    "The average number of people counted by the sensor in that hour, across all recorded days of that type in that year.",
    "How many different days the average is built from. Small numbers mean the sensor worked for only part of the year, so treat the average with more care.",
    paste0("Average people per day in a year as a percentage of the same sensor in ", baseline_year, ". 100 means the same as ", baseline_year, ", 70 means 30% fewer people.")
  ),
  stringsAsFactors = FALSE
)

app_theme <- theme_minimal(base_size = 15) +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    axis.title = element_text(colour = "#52606d")
  )

# ---- User interface -------------------------------------------------------------

ui <- page_sidebar(
  title = "Melbourne foot traffic planner",
  fillable = FALSE,
  theme = bs_theme(
    version = 5,
    bg = "#ffffff",
    fg = "#1f2933",
    primary = "#1b3a4b",
    secondary = "#1f7a8c"
  ),
  includeCSS("www/styles.css"),
  
  sidebar = sidebar(
    width = 340,
    title = "Choose what to compare",
    
    selectizeInput(
      "sensors", "Sensor locations (up to 3)",
      choices = sensor_choices, selected = default_sensor, multiple = TRUE,
      options = list(maxItems = 3, placeholder = "Start typing a street name")
    ),
    helpText("Pick the sensors nearest your business or event."),
    
    checkboxGroupInput(
      "years", "Years to compare",
      choices = all_years, selected = default_years, inline = TRUE
    ),
    helpText(paste0("Tick ", baseline_year, " and a later year to see what has changed since ", baseline_year, ".")),
    
    radioButtons("day", "Type of day", c("Weekday", "Weekend"), inline = TRUE),
    helpText("Weekday and weekend foot traffic often follow very different patterns."),
    
    checkboxInput("same_scale", "Use the same vertical scale for every sensor", FALSE),
    helpText("Off: each sensor gets its own scale, which shows the shape of the day. On: scales match, so you can see which location is busiest."),
    
    hr(),
    uiOutput("sensor_where")
  ),
  
  div(
    class = "app-intro",
    div(
      div(class = "app-intro-label", "Who this is for"),
      p("Café owners, retailers and event planners in central Melbourne who need to decide when to open, roster staff or schedule an event.")
    ),
    div(
      div(class = "app-intro-label", "The question"),
      p(strong(paste0("When are the most people walking past my location, and how much has foot traffic changed since ", baseline_year, "?")))
    )
  ),
  
  navset_card_tab(
    id = "tabs",
    
    nav_panel(
      "When is it busiest?",
      plotOutput("profile", height = "400px", fill = FALSE),
      h5("Busiest hour for each sensor and year", class = "table-title"),
      tableOutput("peaks"),
      div(
        class = "how-to-read",
        strong("How to read this. "),
        "Each line is the average hour-by-hour pattern of a typical day, with one colour per year. ",
        "The highest point of a line is when the most people pass that sensor, which is a good guide to when to be open and fully staffed. ",
        paste0("If a line from a later year sits lower than the ", baseline_year, " line, fewer people pass at that time than in ", baseline_year, ". "),
        "If the peak moves to a different hour, the best time to catch customers has shifted."
      )
    ),
    
    nav_panel(
      paste("Change since", baseline_year),
      plotOutput("recovery", height = "380px", fill = FALSE),
      textOutput("missing_baseline"),
      div(
        class = "how-to-read",
        strong("How to read this. "),
        paste0("Each point is a sensor's average daily foot traffic in that year, as a percentage of ", baseline_year, ". "),
        paste0("The dashed line at 100 is the ", baseline_year, " level. Points below it mean fewer people than in ", baseline_year, ". "),
        paste0("Points above it mean foot traffic is higher than in ", baseline_year, ". "),
        "Compare sensors to see which locations are growing and which are declining."
      )
    ),
    
    nav_panel(
      "Fields and notes",
      h5("What the fields and controls mean", class = "table-title"),
      tableOutput("fields"),
      h5("Things to keep in mind", class = "table-title"),
      tags$ul(
        class = "notes",
        tags$li("A count is a person passing a sensor. The same person can be counted more than once, so these are not unique visitors."),
        tags$li("The charts show averages for a typical day, not totals for a particular day."),
        tags$li("Sensors were added, moved and switched off over time, so some sensors have gaps. Years or hours with fewer than 10 recorded days are left out, and a sensor needs full baseline-year data to appear in the change chart. The latest year may cover only part of the year, so seasonal differences can affect comparisons."),
        tags$li("Foot traffic is only one input to a business decision. It does not show how much people spend or why they were there.")
      ),
      p(
        class = "source",
        "Data: City of Melbourne, Pedestrian Counting System (counts per hour) and Sensor Locations, from the City of Melbourne Open Data Portal. ",
        "Hourly counts were averaged by sensor, year, type of day and hour for this package."
      )
    )
  )
)

# ---- Server ---------------------------------------------------------------------

server <- function(input, output, session) {
  
  # One shared selection that every output uses
  chosen_sensors <- reactive({
    validate(need(
      length(input$sensors) > 0,
      "Choose at least one sensor location in the sidebar to see foot traffic."
    ))
    as.integer(input$sensors)
  }, label = "chosen_sensors")
  
  profile_data <- reactive({
    sensors <- chosen_sensors()
    validate(need(
      length(input$years) > 0,
      "Tick at least one year in the sidebar."
    ))
    melbfoot::hourly_profile(
      sensors = sensors,
      years = as.integer(input$years),
      day = input$day
    )
  }, label = "profile_data")
  
  recovery_data <- reactive({
    validate(need(
      baseline_year %in% all_years,
      paste0("The data in this package do not include ", baseline_year,
             ", so no comparison with ", baseline_year, " is possible.")
    ))
    melbfoot::change_index(chosen_sensors(), baseline_year = baseline_year)
  }, label = "recovery_data")
  
  # Where the chosen sensors are
  output$sensor_where <- renderUI({
    req(input$sensors)
    info <- ped_sensors |>
      filter(location_id %in% as.integer(input$sensors))
    tags$div(
      class = "sensor-where",
      tags$strong("Where the chosen sensors are"),
      tags$ul(lapply(seq_len(nrow(info)), function(i) {
        where <- info$sensor_description[i]
        if (is.na(where) || where == "") where <- "no description provided"
        tags$li(tags$strong(info$sensor_name[i]), ": ", where)
      }))
    )
  })
  
  # Typical-day chart
  output$profile <- renderPlot({
    d <- profile_data()
    validate(need(
      nrow(d) > 0,
      "No counts for these sensors, years and day type. Try a different year or sensor."
    ))
    ggplot(d, aes(hour, mean_count, colour = factor(year), group = year)) +
      geom_line(linewidth = 1.2) +
      facet_wrap(
        ~sensor_name,
        ncol = 1,
        scales = if (isTRUE(input$same_scale)) "fixed" else "free_y"
      ) +
      scale_x_continuous(breaks = seq(0, 21, 3), labels = hour_label) +
      scale_colour_viridis_d(end = 0.85) +
      labs(
        x = "Hour of day",
        y = "Average pedestrians per hour",
        colour = "Year"
      ) +
      app_theme
  }, alt = "Line chart of the average number of pedestrians in each hour of the day, one line per year, one panel per sensor.")
  
  # Busiest hour table
  output$peaks <- renderTable({
    d <- profile_data()
    req(nrow(d) > 0)
    d |>
      group_by(sensor_name, year) |>
      slice_max(mean_count, n = 1, with_ties = FALSE) |>
      ungroup() |>
      transmute(
        Sensor = sensor_name,
        Year = as.character(year),
        `Busiest hour` = hour_label(hour),
        `Average people that hour` = as.integer(round(mean_count)),
        `Days of data` = as.integer(n_days)
      )
  }, striped = TRUE, spacing = "s", width = "100%")
  
  # Recovery chart
  output$recovery <- renderPlot({
    d <- recovery_data()
    validate(need(
      any(!is.na(d$index)),
      paste0("None of the chosen sensors has complete ", baseline_year, " data, so no comparison is possible. Try another sensor.")
    ))
    d <- filter(d, !is.na(index))
    ggplot(d, aes(year, index, colour = sensor_name, group = sensor_name)) +
      geom_hline(yintercept = 100, linetype = "dashed", colour = "grey40") +
      geom_line(linewidth = 1.2) +
      geom_point(size = 3) +
      expand_limits(y = 0) +
      scale_x_continuous(breaks = sort(unique(d$year))) +
      scale_colour_viridis_d(end = 0.85) +
      labs(
        x = NULL,
        y = paste0("Average daily foot traffic (", baseline_year, " = 100)"),
        colour = NULL
      ) +
      app_theme
  }, alt = "Line chart of each chosen sensor's average daily foot traffic by year, as a percentage of the earliest year, with a dashed line at 100 marking that level.")
  
  # Tell the user if some chosen sensors have no baseline-year comparison
  output$missing_baseline <- renderText({
    d <- recovery_data()
    chosen <- sensor_lookup$sensor_name[sensor_lookup$location_id %in% chosen_sensors()]
    have <- unique(d$sensor_name[!is.na(d$index)])
    missing <- setdiff(chosen, have)
    if (length(missing) == 0) {
      ""
    } else {
      paste0(
        paste0("No complete ", baseline_year, " data for: "), paste(missing, collapse = ", "),
        ". These sensors are left out of the chart."
      )
    }
  })
  
  output$fields <- renderTable(field_guide, striped = TRUE, spacing = "s", width = "100%")
}

shinyApp(ui, server)