# Discharge data fetchers ----------------------------------------------------
# Generalizes the readNWISdv() %>% addWaterYear() %>% select() pattern that
# was previously copy-pasted into each of the 4 original .Rmd files.
#
# NOTE (2026-08): USGS is migrating off the legacy NWIS `dv`/`stat` web
# services these functions call, toward a new API (read_waterdata_daily(),
# read_waterdata_stats_por(), etc., also in the dataRetrieval package). As of
# this writing the legacy services still work and return clean p05-p95
# percentile columns that the new stats endpoint doesn't cleanly expose yet.
# If readNWISdv()/readNWISstat() start failing, that's the migration to make.

library(dataRetrieval)
library(dplyr)
library(lubridate)

#' Daily mean discharge for one gage, 1990-present.
#'
#' @param site_no USGS site number
#' @return tibble: date, year (calendar), water_year, q_cfs, month, day
fetch_daily_discharge <- function(site_no, start_date = "1990-01-01") {
  readNWISdv(
    siteNumber = site_no,
    parameterCd = "00060",
    startDate = start_date,
    endDate = Sys.Date()
  ) %>%
    addWaterYear() %>%
    transmute(
      date = Date,
      year = year(Date),
      water_year = waterYear,
      q_cfs = X_00060_00003,
      month = month(Date),
      day = day(Date)
    ) %>%
    filter(!is.na(q_cfs))
}

#' Day-of-year historical percentiles (the "is this normal?" ribbon), from
#' USGS's own statistics service -- same API family as fetch_daily_discharge,
#' no new data source.
#'
#' @return tibble: month, day, p05, p25, p50, p75, p95 (cfs)
fetch_daily_stats <- function(site_no) {
  stats <- readNWISstat(
    siteNumbers = site_no,
    parameterCd = "00060",
    statReportType = "daily",
    statType = c("p05", "p25", "p50", "p75", "p95")
  )
  stats %>%
    transmute(
      month = month_nu,
      day = day_nu,
      p05 = p05_va,
      p25 = p25_va,
      p50 = p50_va,
      p75 = p75_va,
      p95 = p95_va
    )
}

#' Most recent daily value + how it compares to the historical normal for
#' that day-of-year. Used for the dashboard's value boxes.
current_conditions <- function(daily, stats) {
  latest <- daily %>% filter(date == max(date))
  today_stats <- stats %>%
    filter(month == latest$month, day == latest$day)

  pct_of_normal <- if (nrow(today_stats) == 1 && !is.na(today_stats$p50) && today_stats$p50 > 0) {
    round(100 * latest$q_cfs / today_stats$p50)
  } else {
    NA_real_
  }

  list(
    as_of = latest$date,
    q_cfs = latest$q_cfs,
    pct_of_normal = pct_of_normal
  )
}
