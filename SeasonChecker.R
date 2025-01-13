library(tidyverse)
library(sf)
library(jpeg)

out_of_seasons <- sightings_processed %>% 
  st_drop_geometry() %>% 
  filter(in_season == FALSE) %>% 
  left_join(., master_list) %>% 
  drop_na(Months)

for (observation in out_of_seasons$id) {
  download.file(
    url = as.character(out_of_seasons[out_of_seasons$id == observation, "image_url"]), 
    destfile = paste0("Out of Season Photos/", observation, ".jpg"), 
    mode = "wb")
}  

out_of_seasons <- out_of_seasons %>% 
  mutate(is_adult = NA)

for (observation in out_of_seasons$id) {
  # skip anything already done
  if (is.na(out_of_seasons[out_of_seasons$id == observation, "is_adult"])) {
    photo <- readJPEG(paste0("Out of Season Photos/", observation, ".jpg"))
    plot(0:1, 0:1, type = "n", ann = FALSE, axes = FALSE)
    rasterImage(photo, 0, 0, 1, 1)
    title(main = as.character(out_of_seasons[out_of_seasons$id == observation, "ScientificName"]))
    
    Sys.sleep(1)
    
    is_adult <- askYesNo("Does the image depict an adult on the wing?")
    out_of_seasons[out_of_seasons$id == observation, "is_adult"] <- is_adult
  }
}

# (manually) record any species with errors (misclicks) to go back over a second time
error_species <- c("Hesperilla idothea", "Trapezites praxedes", "Delias aganippe")

for (observation in out_of_seasons$id) {
  # skip anything without an error
  if (out_of_seasons[out_of_seasons$id == observation, "ScientificName"] %in% error_species) {
    photo <- readJPEG(paste0("Out of Season Photos/", observation, ".jpg"))
    plot(0:1, 0:1, type = "n", ann = FALSE, axes = FALSE)
    rasterImage(photo, 0, 0, 1, 1)
    title(main = as.character(out_of_seasons[out_of_seasons$id == observation, "ScientificName"]))
    
    Sys.sleep(1)
    
    is_adult <- askYesNo("Does the image depict an adult on the wing?")
    out_of_seasons[out_of_seasons$id == observation, "is_adult"] <- is_adult
  }
}

save(out_of_seasons, file = "Data/OutOfSeasons.RData")