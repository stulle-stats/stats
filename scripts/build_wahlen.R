dir.create(file.path("data", "publish"), recursive = TRUE, showWarnings = FALSE)

df <- data.frame(
  jahr = 2015:2025,
  wert = c(10, 11, 13, 12, 15, 18, 17, 20, 22, 21, 24)
)

saveRDS(df, file.path("data", "publish", "wahlen.rds"))
write.csv(df, file.path("data", "publish", "wahlen.csv"), row.names = FALSE)
