# Shared chart builders -------------------------------------------------------
# One version of each chart type, parameterized by title/subtitle, instead of
# the 4x-copy-pasted ggplot blocks in the original .Rmd files. Each returns a
# plain ggplot; dashboard.Rmd wraps them in plotly::ggplotly() for hover/zoom.

library(ggplot2)
library(dplyr)
library(lubridate)

#' Current water year's daily discharge against the historical percentile
#' envelope for each day-of-year. Replaces the old separate "last 5 years /
#' last year / this year" static plots with one chart that's always current.
plot_hydrograph_vs_normal <- function(daily, stats, title, subtitle) {
  this_wy <- daily %>% filter(water_year == max(water_year))

  ribbon <- stats %>%
    mutate(plot_date = as.Date(paste(2000, month, day, sep = "-"), format = "%Y-%m-%d"))
  this_wy <- this_wy %>%
    mutate(plot_date = as.Date(paste(2000, month, day, sep = "-"), format = "%Y-%m-%d"))

  ggplot() +
    geom_ribbon(data = ribbon, aes(x = plot_date, ymin = p05, ymax = p95, fill = "5th-95th pctile"), alpha = 0.15) +
    geom_ribbon(data = ribbon, aes(x = plot_date, ymin = p25, ymax = p75, fill = "25th-75th pctile"), alpha = 0.3) +
    geom_line(data = ribbon, aes(x = plot_date, y = p50, color = "Historical median"), linetype = "dashed") +
    geom_line(data = this_wy, aes(x = plot_date, y = q_cfs, color = "This water year"), linewidth = 0.7) +
    scale_fill_manual(name = NULL, values = c("5th-95th pctile" = "steelblue", "25th-75th pctile" = "steelblue")) +
    scale_color_manual(name = NULL, values = c("Historical median" = "grey30", "This water year" = "firebrick")) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b") +
    labs(title = title, subtitle = subtitle, y = "Q (cfs)", x = "Date (water year)") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}

#' Full period-of-record hydrograph.
plot_full_record <- function(daily, title, subtitle) {
  ggplot(daily, aes(x = date, y = q_cfs)) +
    geom_line(color = "steelblue", linewidth = 0.3) +
    labs(title = title, subtitle = subtitle, y = "Q (cfs)", x = "Date") +
    theme_minimal()
}

#' Monthly climatology boxplot, last N years.
plot_monthly_climatology <- function(daily, title, subtitle, n_years = 10) {
  recent <- daily %>% filter(year > max(year) - n_years)
  ggplot(recent, aes(x = factor(month, levels = 1:12, labels = month.abb), y = q_cfs)) +
    geom_boxplot(fill = "steelblue", alpha = 0.5, outlier.size = 0.5) +
    labs(title = title, subtitle = subtitle, y = "Q (cfs)", x = "Month") +
    theme_minimal()
}

#' Summertime (Jun 21 - Sep 21) annual mean discharge trend.
plot_summertime_trend <- function(daily, title, subtitle) {
  summer <- daily %>%
    filter((month == 6 & day >= 21) | between(month, 7, 8) | (month == 9 & day <= 21)) %>%
    group_by(year) %>%
    summarize(summer_mean_q = mean(q_cfs, na.rm = TRUE), .groups = "drop")

  ggplot(summer, aes(x = year, y = summer_mean_q)) +
    geom_point(color = "steelblue") +
    geom_smooth(method = "loess", se = FALSE, color = "grey40", linewidth = 0.5) +
    labs(title = title, subtitle = subtitle, y = "Summer mean Q (cfs)", x = "Year") +
    theme_minimal()
}

#' This year's SWE vs. the historical daily envelope for the station.
plot_snowpack_vs_normal <- function(swe, title, subtitle) {
  this_year <- swe %>% filter(year(date) == max(year(date)))

  normal <- swe %>%
    filter(date < max(this_year$date) | year(date) != max(year(date))) %>%
    group_by(month, day) %>%
    summarize(
      p25 = quantile(swe_mm, 0.25, na.rm = TRUE),
      median_swe = median(swe_mm, na.rm = TRUE),
      p75 = quantile(swe_mm, 0.75, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(plot_date = as.Date(paste(2000, month, day, sep = "-"), format = "%Y-%m-%d"))

  this_year <- this_year %>%
    mutate(plot_date = as.Date(paste(2000, month, day, sep = "-"), format = "%Y-%m-%d"))

  ggplot() +
    geom_ribbon(data = normal, aes(x = plot_date, ymin = p25, ymax = p75), fill = "steelblue", alpha = 0.25) +
    geom_line(data = normal, aes(x = plot_date, y = median_swe), color = "grey30", linetype = "dashed") +
    geom_line(data = this_year, aes(x = plot_date, y = swe_mm), color = "firebrick", linewidth = 0.7) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b") +
    labs(title = title, subtitle = subtitle, y = "SWE (mm)", x = "Date") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}
