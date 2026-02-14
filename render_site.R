
# ins Projekt-Root springen
if (requireNamespace("here", quietly = TRUE)) {
  setwd(here::here())
}

# alles bauen
source(file.path("scripts", "build_all.R"))

# website rendern
system("quarto render", intern = FALSE)