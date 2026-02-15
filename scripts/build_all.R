# immer vom Projekt-Root aus laufen lassen (wichtig für Pfade)
if (requireNamespace("here", quietly = TRUE)) {
  setwd(here::here())
}

# publish-Ordner sicherstellen
dir.create(file.path("data", "publish"), recursive = TRUE, showWarnings = FALSE)

# einzelne Builds
source(file.path("scripts", "build_manifesto.R"))
