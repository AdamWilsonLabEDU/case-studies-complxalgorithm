# import libraries
library(tidyverse)
library(sf)
library(spData)
library(ggplot2)
library(leaflet)
library(units)

# load world and us_states data from spData
data(world)
data(us_states)

# show data sets
plot(world[1])
plot(us_states[1])

# set albers equal area projection string
albers="+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

# transform world to albers then filter for Canada
canada <- world %>%
  st_transform(crs = albers) %>%
  filter(name_long == 'Canada')

# transform us_states to albers then filter for NYS 
nys <- us_states %>%
  st_transform(crs = albers) %>%
  filter(NAME == 'New York')

# determine 10km Canada border buffer
canada_buffer <- st_buffer(canada, 10000)

plot(st_geometry(canada_buffer))
plot(nys, add = TRUE)

# see where NYS intersects with Canada border buffer
border_intersection <- st_intersection(nys, canada_buffer)

# calculate area of 10 km buffer zone
intersection_area <- st_area(border_intersection) %>% set_units(km^2)

#### => Intersection area is 3,495 km^2

# plot NYS and its land area that is within 10km of Canadian border
ggplot(border_intersection) +
  geom_sf(data = nys, fill = 'gray') +
  geom_sf(fill = 'red') +
  labs(
    title = 'New York Land within 10km'
  ) +
  theme(
    legend.position = 'none',
    plot.title = element_text(hjust = 0.5, size = 20)
  )

# transform border_intersection to WGS84 before adding to map (to remove warnings)
m <- leaflet(border_intersection %>% st_transform(crs = '+proj=longlat +datum=WGS84')) %>%
  addTiles() %>%
  addPolygons(
    color = 'black',
    fillColor = 'red',
    stroke = TRUE,
    weight = 1 # change stroke width of polygon boundaries to 1
  )

# display leaflet map
m