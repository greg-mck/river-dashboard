# Gage configuration --------------------------------------------------------
# One row per USGS streamgage shown on the dashboard. Add a gage by adding a
# row here -- no new .Rmd or duplicated plotting code required.
#
#   site_no       USGS site number (character, preserves leading zeros)
#   river         River/stream name as it should be labeled (verified against
#                 USGS site service -- see is_tributary note below)
#   common_name   Short label used on dashboard tabs/titles
#   location      Town/landmark + state, for subtitles
#   state         Two-letter state code
#   is_tributary  TRUE if this gage is on a tributary rather than the named
#                 river's mainstem -- forces a "tributary, not mainstem"
#                 note in the dashboard so it's never mislabeled again
#   snotel_id     site_id of the SNOTEL station (from snotelr::snotel_info())
#                 representing this gage's upstream headwater snowpack.
#                 Chosen by checking station coordinates fall within the
#                 gage's basin -- see README for how these were picked.
#   snotel_label  Human-readable name for the snowpack panel

library(tibble)

gage_config <- tribble(
  ~site_no,    ~river,                 ~common_name,        ~location,                        ~state, ~is_tributary, ~snotel_id, ~snotel_label,
  "06752260",  "Cache la Poudre River", "Poudre (Fort Collins)", "Fort Collins, CO",            "CO",   FALSE,         551,        "Joe Wright SNOTEL (Poudre headwaters)",
  "06620000",  "North Platte River",   "North Platte (Northgate)", "Northgate, CO",             "CO",   FALSE,         1046,       "Cinnabar Park SNOTEL (North Park headwaters)",
  "06630000",  "North Platte River",   "North Platte (ab. Seminoe)", "above Seminoe Reservoir, near Sinclair, WY", "WY", FALSE, 1046, "Cinnabar Park SNOTEL (North Park headwaters)",
  "06622700",  "North Brush Creek",    "Brush Creek (Saratoga area)", "near Saratoga, WY",       "WY",   TRUE,          1046,       "Cinnabar Park SNOTEL (North Park headwaters)",
  "09058000",  "Colorado River",       "Colorado (Kremmling)", "near Kremmling, CO",             "CO",   FALSE,         688,        "Phantom Valley SNOTEL (Colorado River headwaters, RMNP)",
  "09239500",  "Yampa River",          "Yampa (Steamboat Springs)", "Steamboat Springs, CO",     "CO",   FALSE,         825,        "Tower SNOTEL (Yampa headwaters, Buffalo Pass)",
  "09085000",  "Roaring Fork River",   "Roaring Fork (Glenwood Springs)", "Glenwood Springs, CO", "CO",  FALSE,         542,        "Independence Pass SNOTEL (Roaring Fork headwaters)",
  "06719505",  "Clear Creek",          "Clear Creek (Golden)", "Golden, CO",                     "CO",   FALSE,         602,        "Loveland Basin SNOTEL (Clear Creek headwaters)",
  "06701500",  "South Platte River",   "South Platte (Deckers)", "below Cheesman Reservoir, near Deckers, CO", "CO",   FALSE,      531,        "Hoosier Pass SNOTEL (South Platte headwaters, South Park)"
)

# Sanity check: fail loudly if a gage number is duplicated or malformed.
stopifnot(
  all(nchar(gage_config$site_no) %in% c(8, 15)),
  !any(duplicated(gage_config$site_no))
)
