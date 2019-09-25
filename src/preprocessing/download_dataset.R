# Start Batch Download (500 GB>)
library(RCurl)


# Global parameters -------------------------------------------------------
FTP_DATASET <- 'ftp://m1474000:m1474000@dataserv.ub.tum.de/'
TABLE_DATASET <- "https://raw.githubusercontent.com/csaybar/Geohormiguitas/master/data/table_landuse_report.csv"
SEASON <- "summer"
FTP_DATASETS <- getURL(FTP_DATASET,
                       ftp.use.epsv = FALSE,
                       ftplistonly = TRUE,
                       crlf = TRUE) %>% 
  map(~ strsplit(.x,'\r*\n')[[1]]) %>%
  '[['(1) %>% 
  .[grepl("\\.tar\\.gz$", .)]
  

# Download dataset by season ----------------------------------------------
ftp_dataset_season <- FTP_DATASETS[grepl(SEASON, FTP_DATASETS)]
table_landuse  <- read_csv(TABLE_DATASET)[1:9,]

# land_use modis
where_landuse <- grepl("_lc",ftp_dataset_season)
landuse_url <- paste0(FTP_DATASET, ftp_dataset_season[where_landuse])
landuse_local <- paste0("data/", ftp_dataset_season[where_landuse])
download.file(url = landuse_url, destfile = landuse_local)

file_names <- untar(landuse_local,list=TRUE) 
file_names_just_tiff <- file_names[grepl("\\.tif$", file_names)]

tif_file <- paste0("data/", basename(file_names_just_tiff[1]))
