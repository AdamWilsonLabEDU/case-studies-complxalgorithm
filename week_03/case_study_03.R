# import libraries
library(ggplot2)
library(gapminder)
library(dplyr)

# preview gapminder
head(gapminder)

# filter out kuwait
country_df <- gapminder %>% filter(country != 'Kuwait')
colnames(country_df) <- c('country', 'continent', 'year', 'lifeExp', 'population', 'gdpPercap')

head(country_df)

##########################################

# create first plot
country_plt <- ggplot(country_df, aes(x = lifeExp, y = gdpPercap, color = continent)) +
  geom_point(aes(size = population/100000)) +
  facet_wrap(~year, nrow = 1) +
  scale_y_continuous(trans = 'sqrt') +
  theme_bw() +
  labs(
    title = 'Wealth and Life Expectancy Through Time by Continent',
    x = 'Life Expectancy',
    y = 'GDP per capita',
    size = 'Population (100k)',
    color = 'Continent'
  )

country_plt

##########################################

# group by continent and year, then calculate gdp per capita weighted mean
# and total population of each year, and save to gapminder_continent object
# then view new object
gapminder_continent <- country_df %>% group_by(continent, year) %>%
  summarize(
    gdpPercapweighted = weighted.mean(x = gdpPercap, w = population),
    population = sum(as.numeric(population))
  )

head(gapminder_continent)

# create second plot
continent_plt <- ggplot(country_df, aes(year, gdpPercap, color = continent)) +
  geom_line(aes(group = country)) +
  geom_point(aes(size = population/100000)) +
  geom_line(
    data = gapminder_continent,
    mapping = aes(
      x = year, 
      y = gdpPercapweighted),
    inherit.aes = FALSE
    ) +
  geom_point(
    data = gapminder_continent,
    mapping = aes(
      x = year, 
      y = gdpPercapweighted, 
      size = population/100000),
    inherit.aes = FALSE
    ) +
  facet_wrap(~continent, nrow = 1) +
  theme_bw() +
  labs(
    title = 'GDP Per Capita by Continent',
    x = 'Year', 
    y = 'GDP Per Capita',
    size = 'Population (100k)',
    color = 'Continent'
  )

continent_plt

##########################################

# save plots as images
ggsave(
  country_plt,
  filename = 'wealth_life_expectancy_by_continent.png',
  units = 'in',
  width = 15
)
ggsave(
  continent_plt,
  filename = 'gdp_per_capita_by_continent.png',
  units = 'in',
  width = 15
)