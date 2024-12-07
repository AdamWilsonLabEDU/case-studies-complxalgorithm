##install.packages("reshape2")

# import packages
library("tidyverse")
library("ggplot2")
library("dplyr")
library("reshape2")

# define col names to be used in dataframes
cols = c("YEAR","JAN","FEB","MAR", 
         "APR","MAY","JUN","JUL",  
         "AUG","SEP","OCT","NOV",  
         "DEC","DJF","MAM","JJA",  
         "SON","metANN")

# define the link to the data - you can try this in your browser too.  Note that the URL ends in .txt.
buffalo_dataurl <- "https://data.giss.nasa.gov/tmp/gistemp/STATIONS_v4/tmp_USW00014733_14_0_1/station.csv"

# the next line tells the NASA site to create the temporary file
httr::GET("https://data.giss.nasa.gov/cgi-bin/gistemp/stdata_show_v4.cgi?id=USW00014733&ds=14&dt=1")

# download buffalo data
buffalo_df <- read_csv(buffalo_dataurl, 
              na="999.90", # tell R that 999.90 means missing in this dataset
              skip=1, # we will use our own column names as below so we'll skip the first row
              col_names = cols)

# open df table
View(buffalo_df)

## calculate mean summer temp
buffalo_summer_temp_mean <- mean(buffalo_df$JJA, na.rm = TRUE)

buffalo_summer_temp_mean

## plot mean summer temp in buffalo, ny
## with mean line and loess smooth line
buffalo_plt <- ggplot(buffalo_df, mapping = aes(x = YEAR, y = JJA),
    color = 'red',
    linewidth = 0.75
  ) +
  geom_line() +
  geom_hline(
    aes(yintercept = buffalo_summer_temp_mean),
    color = 'blue',
    linewidth = 0.25
  ) +
  ggtitle('Mean Summer Temperature in Buffalo, New York (1883 - 2024)',
          subtitle = '(Summer Months = June, July, and August)'
  ) +
  labs(
    caption = 'Red line is a LOESS smooth.\nBlue line is mean summer temp.\n\nData from the Global Historical Climate Network'
  ) +
  xlab('Year') +
  ylab('Mean Temperature (C)') +
  geom_smooth(method = 'loess', color = 'red', linewidth = unit(0.75, 'mm')) +
  theme(
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, size = unit(10, 'pt'))
  )

buffalo_plt

## ANSWER TO MAIN QUESTION
##########################
# While there were summers during the 1920s that were as warm as more recent summers,
# the average summer has gotten around 1.5 degrees C hotter compared to the 1920s.
# i.e., You can expect a contemporary summer season to be hotter now than in the 1920s.
##

######################################################
## Plot multiple cities (Buffalo, Ljubljana, & Madrid)
######################################################

# set url to ljubljana csv
ljubljana_dataurl <- "https://data.giss.nasa.gov/tmp/gistemp/STATIONS_v4/tmp_SIM00014015_14_0_1/station.csv"
httr::GET("https://data.giss.nasa.gov/cgi-bin/gistemp/stdata_show_v4.cgi?id=SIM00014015&dt=1&ds=14")

# download ljulbjana data
ljubljana_df <- read_csv(ljubljana_dataurl, 
                         na="999.90", # tell R that 999.90 means missing in this dataset
                         skip=1, # we will use our own column names as below so we'll skip the first row
                         col_names = cols)

# open ljubljana table and generate summary
View(ljubljana_df)
summary(ljubljana_df)

# calculate mean summer temp
ljubljana_summer_temp_mean <- mean(ljubljana_df$JJA, na.rm = TRUE)

ljubljana_summer_temp_mean

# set url to madrid csv
madrid_dataurl = 'https://data.giss.nasa.gov/tmp/gistemp/STATIONS_v4/tmp_SPE00120287_14_0_1/station.csv'
httr::GET("https://data.giss.nasa.gov/cgi-bin/gistemp/stdata_show_v4.cgi?id=SPE00120287&dt=1&ds=14")

# download madrid data
madrid_df <- read_csv(madrid_dataurl, 
                         na="999.90", # tell R that 999.90 means missing in this dataset
                         skip=1, # we will use our own column names as below so we'll skip the first row
                         col_names = cols)

# open df table
View(madrid_df)

# calculate mean summer temp
madrid_summer_temp_mean <- mean(madrid_df$JJA, na.rm = TRUE)

madrid_summer_temp_mean

## create empty all_df using cols in city data dfs
# number of rows is the number of cols
# set the column names using cols
all_df <- data.frame(matrix(, nrow = 0, ncol = length(cols)))
colnames(all_df) = cols

##all_df

# merge dataframes into all_df, adding a suffix for each city's data
all_df <- merge(all_df, buffalo_df, all.x=FALSE, all.y=TRUE)
all_df <- merge(all_df, ljubljana_df, by='YEAR', suffixes = c("", "_ljubljana"))
all_df <- inner_join(all_df, madrid_df, by='YEAR', suffix = c("_buffalo", "_madrid"))

View(all_df)

# melt all_df using Year as reference columns
# creates a dataframe of variables (different col names) matched to its value in a given year
melt_df = melt(all_df, id = 'YEAR')

View(melt_df)

# filter out all variables that don't contain JJA
# reset index of rows (row names)
full_plt_df = melt_df[grepl('JJA', melt_df$variable), ]
row.names(full_plt_df) <- NULL

View(full_plt_df)

## plot mean summer temp in buffalo, ny, ljubljana, sl, and madrid, es
full_plt <- ggplot(full_plt_df, aes(x = YEAR, y = value, color = variable)) +
  geom_line(
    linewidth = 0.25,
    alpha = 0.5,
    show.legend = TRUE
  ) +
  geom_smooth(linewidth = 0.75) + # toggle comment on this line if needed
  ggtitle('Mean Summer Temperature in Select Cities (1883 - 2024)',
          subtitle = '(Summer Months = June, July, and August)'
  ) +
  labs(
    caption = 'Dark lines are LOESS smooths.\n\nData from the Global Historical Climate Network'
    ##caption = 'Data from the Global Historical Climate Network'
  ) +
  xlab('Year') +
  ylab('Mean Temperature (C)') +
  scale_color_manual(
    labels = c('Buffalo, NY', 'Ljubljana, SL', 'Madrid, ES'),
    values = c('blue', 'red', 'darkgreen')
  ) +
  theme(
    panel.background = element_rect(fill = 'grey92'),
    legend.position = c(0.15, 0.825),
    legend.title = element_blank(),
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(size = unit(10, 'pt'), hjust = 0.5),
    plot.caption = element_text(size = unit(8, 'pt'))
  )

full_plt

## Another possible solution
## This will not plot properly without scale_color_manual()
#
# set colors and labels to use in legend
# legend_colors = c('blue', 'darkgreen', 'red')
# legend_labels = c('Buffalo, NY', 'Madrid, ES', 'Ljubljana, SL')
#
## plot mean summer temp in buffalo, ny, ljubljana, sl, and madrid, es
# other_full_plt <- ggplot(all_df, aes(x = YEAR)) +
#   geom_line(
#     aes(y = JJA_buffalo, color = 'blue'),
#     linewidth = 0.75,
#     show.legend = TRUE
#   ) +
#   geom_line(
#     aes(y = JJA_ljubljana, color = 'red'),
#     linewidth = 0.75,
#     show.legend = TRUE
#   ) +
#   geom_line(
#     aes(y = JJA_madrid, color = 'darkgreen'),
#     linewidth = 0.75,
#     show.legend = TRUE
#   ) +
#   ggtitle('Mean Summer Temperature in Select Cities (1883 - 2024)',
#           subtitle = '(Summer Months = June, July, and August)'
#   ) +
#   labs(
#     caption = 'Data from the Global Historical Climate Network'
#   ) +
#   xlab('Year') +
#   ylab('Mean Temperature (C)') +
#   scale_color_manual(values = legend_colors, labels = legend_labels) +
#   theme(
#     panel.background = element_rect(fill = 'grey92'),
#     legend.position = c(0.15, 0.825),
#     legend.title = element_blank(),
#     plot.subtitle = element_text(size = unit(10, 'pt')),
#     plot.caption = element_text(size = unit(8, 'pt'))
#   )
#
# other_full_plt

###################################################


## save generated plots as png files
ggsave(buffalo_plt, filename = "buffalo_mean_summer_temp.png")
ggsave(
  full_plt,
  filename = "world_cities_mean_summer_temp.png",
  units = 'px',
  height = 1500,
  width = 2500
)