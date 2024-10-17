# import libraries
library(tidyverse)
library(sf)
library(terra)
library(spData)
library(ncdf4)
library(ggplot2)
library(gt)

# load world (filter out Antarctica) and CRU data
data(world)

download.file('https://crudata.uea.ac.uk/cru/data/temperature/absolute.nc','crudata.nc', method = 'curl')

# load cru data as raster, then show it in console and plot it
tmean = rast('crudata.nc')
tmean
plot(tmean)

# find max values across all 12 months and save to tmean_max
# show it in console and plot it
tmean_max <- max(tmean)
tmean_max
plot(tmean_max)

# get max value in each country, then convert to sf
world_clim <- terra::extract(tmean_max, world, 
                             fun = max, na.rm = TRUE, small = TRUE) %>% 
  bind_cols(world) %>%
  st_as_sf()

# get geometry from world_clim, then bind back to world_clim to convert to spatial df
geo <- st_transform(select(world_clim, c(geom)), crs = 4326)
world_clim <- cbind(geo, world_clim) %>% select(-c(geom.1)) %>% st_transform(crs = 4326)

world_clim

# plot max temp by country
ggplot(world_clim) +
  geom_sf(aes(fill = max)) +
  scale_fill_viridis_c(
    name = 'Maximum\nTemperature (C)'
  ) +
  theme(legend.position = 'bottom')

# create table of hottest country in each continent using gt
hottest_continents <- world_clim %>%
  st_set_geometry(NULL) %>%
  group_by(continent) %>%
  select(c(name_long, continent, max)) %>%
  top_n(n = 1) %>%
  arrange(desc(max)) %>%
  gt(groupname_col = NULL) %>%
  cols_width(
    name_long ~ px(300),
    continent ~ px(200)
  ) %>%
  cols_label(
    name_long = 'Country',
    continent = 'Continent',
    max = 'Max Temp (C)'
  ) %>%
  fmt_number(columns = max, decimals = 1) %>%
  tab_header(
    title = 'Highest Temperature by Continent (C)'
  )

hottest_continents