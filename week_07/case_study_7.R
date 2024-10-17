# load libraries
library(tidyverse)
library(reprex)
library(sf)
library(spData)

# load world dataset
data(world)

# plot gdp per capita
ggplot(world, aes(x=gdpPercap, y=continent, color=continent)) +
  geom_density(alpha=0.5, color=F)

reprex(venue='gh')
