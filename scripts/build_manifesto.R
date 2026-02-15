

dir.create(file.path("data", "publish"), recursive = TRUE, showWarnings = FALSE)

if (!require("pacman")) install.packages("pacman")
pacman::p_load("sf", "raster", "ggplot2",
               "dplyr", "tidyverse",
               "RColorBrewer", "rnaturalearth","rnaturalearthdata", 
               "rnaturalearthhires", "lubridate", "countrycode", "stringr", "readr", "jsonlite")

# lade Daten zu Parteien und Wahlergebnissen
m <- read_csv("data/raw/Politics/Manifesto Project/MPDataset_MPDS2025a.csv")

# 1) Wahl-Datum robust ableiten
# robustes Wahldatum bauen
m <- m %>%
  mutate(
    # edate: "DD/MM/YYYY" -> dmy
    edate_parsed = dmy(edate, quiet = TRUE),
    
    # date: YYYYMM -> YYYY-MM-01
    date_parsed = suppressWarnings(ymd(paste0(as.character(date), "01")))
  ) %>%
  mutate(
    # nutze edate wenn vorhanden, sonst date
    election_date = coalesce(edate_parsed, date_parsed),
    year = year(election_date)
  )

if (all(is.na(m$election_date))) stop("Kein parsebares Wahldatum gefunden (edate/date).")



# 2) # ISO3 Codes erzeugen
m <- m %>%
  mutate(
    iso_a3 = countrycode(countryname,
                         origin = "country.name",
                         destination = "iso3c"),
    parfam = as.integer(parfam),
    vote_share = as.numeric(pervote)
  )

# Nur sinnvolle Beobachtungen behalten
m <- m %>%
  filter(
    !is.na(iso_a3),
    nchar(iso_a3) == 3,
    !is.na(election_date),
    !is.na(parfam),
    parfam != 999
  )

# 3) Aggregation
# Wahl × Land × Parteifamilie
e_parfam <- m %>%
  group_by(iso_a3, election_date, year, parfam) %>%
  summarize(
    vote_sum = sum(vote_share, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(iso_a3, election_date, year) %>%
  mutate(
    vote_total = sum(vote_sum, na.rm = TRUE),
    vote_rel = ifelse(vote_total > 0,
                      100 * vote_sum / vote_total,
                      NA_real_)
  ) %>%
  ungroup()

head(e_parfam)
summary(e_parfam$year)

# Labels
parfam_map <- tibble::tibble(
  parfam = c(10,20,30,40,50,60,70,80,90,95,98),
  parfam_label = c(
    "Green/Ecologist",
    "Left Socialist",
    "Social Democratic",
    "Liberal",
    "Christian Democratic",
    "Conservative",
    "Nationalist",
    "Agrarian/Rural",
    "Ethnic/Regional",
    "Special Interest",
    "Diverse/Other"
  )
)

e_parfam <- e_parfam %>%
  left_join(parfam_map, by = "parfam")
table(e_parfam$parfam_label)

# 3)Export für Browser
# Browser braucht ISO-Datum als String.

e_parfam <- e_parfam %>%
  mutate(
    election_date_str = format(election_date, "%Y-%m-%d")
  )

# Speichern

saveRDS(e_parfam,
        "data/publish/manifesto.rds")

writeLines(
  jsonlite::toJSON(e_parfam,
                   dataframe = "rows",
                   na = "null",
                   auto_unbox = TRUE),
  "data/publish/manifesto.json"
)

file.exists("data/publish/manifesto.json")


