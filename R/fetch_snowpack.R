# Snowpack (snow-water-equivalent) fetchers ----------------------------------
# New data source (not in the original .Rmd files): NRCS SNOTEL stations,
# used as a leading indicator of spring/summer runoff for each gage's
# upstream basin. Station-to-basin matches live in gage_config.R and were
# picked by checking each station's coordinates fall in the right headwater
# drainage (see README).

library(snotelr)
library(dplyr)
library(lubridate)

#' Daily SWE history for one SNOTEL station.
#'
#' @param snotel_id numeric site_id from snotel_info()
#' @return tibble: date, month, day, swe_mm
fetch_snowpack <- function(snotel_id) {
  snotel_download(site_id = snotel_id, internal = TRUE) %>%
    transmute(
      date = as.Date(date),
      month = month(date),
      day = day(date),
      swe_mm = snow_water_equivalent
    ) %>%
    filter(!is.na(swe_mm))
}

#' Latest SWE reading + historical median for that day-of-year, i.e. is
#' this year's snowpack running above or below normal.
snowpack_current_vs_normal <- function(swe) {
  latest <- swe %>% filter(date == max(date))
  normal <- swe %>%
    filter(month == latest$month, day == latest$day, date != latest$date) %>%
    summarize(median_swe_mm = median(swe_mm, na.rm = TRUE))

  pct_of_normal <- if (nrow(normal) == 1 && !is.na(normal$median_swe_mm) && normal$median_swe_mm > 0) {
    round(100 * latest$swe_mm / normal$median_swe_mm)
  } else {
    NA_real_
  }

  list(
    as_of = latest$date,
    swe_mm = latest$swe_mm,
    median_swe_mm = normal$median_swe_mm,
    pct_of_normal = pct_of_normal
  )
}
