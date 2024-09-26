# import libraries
library(tidyverse)
library(nycflights13)

# vector of nyc airports
nyc_airports = c('JFK', 'LGA')

# join flights with airports, adding origin and dest suffixes to columns
flights_joined <- flights %>%
  inner_join(airports[c('faa', 'name')], keep = FALSE, by = join_by(origin == faa)) %>%
  inner_join(airports[c('faa', 'name')], keep = FALSE, by = join_by(dest == faa), suffix = c('_origin', '_dest'))

# make sure joining worked by previewing subset of flights_joined
head(flights_joined[c('origin', 'name_origin', 'dest', 'name_dest')])

# filter for flights originating at nyc airports, and arrange from longest to shortest distance
dist_df <- flights_joined %>%
  filter(origin %in% nyc_airports) %>%
  subset(select = c('origin', 'name_origin', 'dest', 'name_dest', 'distance')) %>%
  arrange(desc(distance))

# get name_dest with maximum distance from dist_df then
# store it as character in farthest_airport
farthest_airport <- as.character(dist_df[which.max(dist_df$distance), 'name_dest'])

farthest_airport
