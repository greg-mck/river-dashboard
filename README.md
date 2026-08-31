# river-dashboard

Daily-refreshing dashboard of river discharge conditions, built on USGS
`dataRetrieval` and NRCS SNOTEL data. Replaces 4 separate, copy-pasted
`.Rmd` scripts (in the sibling `poudre/` and `North_platte_trip/` repos)
with one config-driven dashboard that auto-updates.

**Live dashboard:** set up GitHub Pages (Settings > Pages > Deploy from
branch > `main` / `docs`) and it'll be at
`https://<your-github-username>.github.io/river-dashboard/`.

## Gages

| Gage | Site # | Type | Notes |
|---|---|---|---|
| Cache la Poudre River, Fort Collins, CO | 06752260 | Mainstem | |
| North Platte River, Northgate, CO | 06620000 | Mainstem | |
| North Platte River, above Seminoe Reservoir, near Sinclair, WY | 06630000 | Mainstem | |
| North Brush Creek, near Saratoga, WY | 06622700 | **Tributary** | Historically mislabeled "North Platte, Saratoga" in the old `.Rmd`. It's actually a small tributary, not the mainstem. The real North Platte-at-Saratoga gage (06627000) stopped recording discharge in 1970, so there's no active mainstem gage right at Saratoga — this is the nearest active gage to that reach. |
| Colorado River, near Kremmling, CO | 09058000 | Mainstem | |
| Yampa River, Steamboat Springs, CO | 09239500 | Mainstem | |
| Roaring Fork River, Glenwood Springs, CO | 09085000 | Mainstem | |
| Clear Creek, Golden, CO | 06719505 | Mainstem | |
| South Platte River, below Cheesman Reservoir near Deckers, CO | 06701500 | Mainstem | |

Add a gage by adding a row to `R/gage_config.R` — no new files needed.

## Snowpack (SNOTEL) stations

| Station | ID | Used for |
|---|---|---|
| Joe Wright | 551 | Poudre headwaters (Cameron Pass area) |
| Cinnabar Park | 1046 | North Platte / North Park headwaters (used for all 3 North Platte-basin gages) |
| Phantom Valley | 688 | Colorado River headwaters (Kawuneeche Valley, RMNP) |
| Tower | 825 | Yampa headwaters (Buffalo Pass) |
| Independence Pass | 542 | Roaring Fork headwaters |
| Loveland Basin | 602 | Clear Creek headwaters (Loveland Pass) |
| Hoosier Pass | 531 | South Platte headwaters (South Park) |

Picked by pulling `snotelr::snotel_info()` and checking each candidate
station's coordinates fall inside the right headwater drainage. SWE (and
its % of historical normal) is only meaningful roughly Nov-Jun; expect
`NA`/near-zero numbers in summer when there's no snowpack to compare.

## Local development

```r
# one-time setup
install.packages(c("dataRetrieval", "tidyverse", "lubridate", "flexdashboard", "plotly", "snotelr"))

# render
rmarkdown::render("dashboard.Rmd", output_file = "index.html", output_dir = "docs")
```

## Automation

`.github/workflows/update-dashboard.yml` re-renders and re-publishes
`docs/index.html` daily (12:00 UTC) via GitHub Actions, plus on every push
to `main` and on manual trigger (`gh workflow run update-dashboard.yml`).

## Known future migration

USGS is decommissioning the legacy NWIS `dv`/`stat` web services that
`readNWISdv()`/`readNWISstat()` (in `R/fetch_discharge.R`) call, in favor
of `read_waterdata_daily()` / `read_waterdata_stats_por()` (same
`dataRetrieval` package). As of this writing the legacy services still
work and return clean percentile columns the new stats endpoint doesn't
cleanly expose yet. If discharge fetches start failing, that's the
migration to make.
