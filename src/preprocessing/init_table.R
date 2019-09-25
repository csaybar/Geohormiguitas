# 1._ Create table summary
library(sf)
library(rgee)
library(dplyr)
library(readr)
library(stars)
library(raster)
library(ggplot2)
library(geojsonio)
library(tidyverse)

ee_Initialize(user_gmail = "aybar1994@gmail.com")
# ee_manage_assets_access('users/aybar1994/selva_peru') #anyone can read


# geoViz -----------------------------------------------------------------
igbpLandCoverVis <- list(
  min = 1.0,
  max = 17.0,
  palette = c(
    "05450a", "086a10", "54a708", "78d203", "009900", "c6b044", "dcd159",
    "dade48", "fbff13", "b6ff05", "27ff87", "c24f44", "a5a5a5", "ff6d4c",
    "69fff8", "f9ffa4", "1c0dff"
  )
)

LC_Type1 <- c(
  "Evergreen Needleleaf Forests",
  "Evergreen Broadleaf Forests",
  "Deciduous Needleleaf Forests",
  "Deciduous Broadleaf Forests",
  "Mixed Forests",
  "Closed Shrublands",
  "Open Shrublands",
  "Woody Savannas",
  "Savannas",
  "Grasslands",
  "Permanent Wetlands",
  "Croplands",
  "Urban and Built-up Lands",
  "Cropland/Natural Vegetation Mosaics",
  "Permanent Snow and Ice",
  "Barren",
  "Water Bodies"
)

color_table <- data.frame(
  value = 1:17,
  name = LC_Type1,
  color = igbpLandCoverVis$palette,
  stringsAsFactors = FALSE
)

# Datasets ----------------------------------------------------------------

amazon_peru <- ee$FeatureCollection("users/aybar1994/selva_peru")
# ee_map(amazon_peru,zoom_start = 5)

dataset <- ee$ImageCollection("MODIS/006/MCD12Q1")
dataset <- dataset$toList(dataset$size())
igbpLandCover <- ee$Image(dataset$get(17))$select("LC_Type1")
# ee_print(igbpLandCover)

amz_peru <- igbpLandCover$clip(amazon_peru)
amz_peru_rpj <- igbpLandCover$clip(amazon_peru)$reproject(crs = "EPSG:4326", scale = 500)
ee_map(amz_peru, igbpLandCoverVis, center = c(-73.902, -6.6205), zoom_start = 6)

amz_region <- amazon_peru$geometry()$bounds()$getInfo()$coordinates

# Summary table -----------------------------------------------------------
task_img <- ee$batch$Export$image$toDrive(
  image = amz_peru_rpj,
  folder = "geoHormiguitas",
  fileFormat = "GEOTIFF",
  region = amz_region,
  fileNamePrefix = "amazon_landuse_MCD12Q1v006"
)

task_img$start()
ee_monitoring(task_img)
landuse_modis <- "data/landuse_MCD12Q1v006"
amz_landuse <- ee_download_drive(task_img, filename = landuse_modis)
amz_landuse[amz_landuse <= 0] <- NA
# plot(amz_landuse)
npixels <- nrow(amz_landuse) * ncol(amz_landuse)
total_area_km <- (npixels * 500 * 500) / 10^6

summary_report_2018 <- table(amz_landuse$landuse_MCD12Q1v006.tif)

summary_report_2018_km <- (summary_report_2018 * 500 * 500) / 10^6
summary_area_report <- data.frame(
  value = names(summary_report_2018_km) %>% as.numeric(),
  name = color_table$name[color_table$value %in% names(summary_report_2018_km)],
  color = color_table$color[color_table$value %in% names(summary_report_2018_km)],
  area = summary_report_2018_km %>% as.numeric()
)

summary_area_report_final <- summary_area_report %>% arrange(desc(area))
write_csv(summary_area_report_final, "data/table_landuse_report.csv")
