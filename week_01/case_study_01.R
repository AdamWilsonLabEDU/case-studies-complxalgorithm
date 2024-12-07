#install.packages("ggplot2")
library(ggplot2)

# load iris dataset
data(iris)

# sneak peek of iris
head(iris)

# calculate mean petal length, then show the mean
petal_length_mean <- mean(iris$Petal.Length)

## mean length is 3.758
petal_length_mean

## plot histogram of petal length using hist
hist(
  iris$Petal.Length,
  xlab = "Petal Length",
  ylab = "Frequency",
  main = "Distribution of Petal Lengths",
  ylim = c(0, 40),
  color = iris$Species
)

# draw vertical line representing mean petal length
abline(v = petal_length_mean, col='red', lwd = 1)

## plot histogram of petal length using ggplot
p <- ggplot(iris, aes(x=Petal.Length, fill = Species)) +
      geom_histogram(color = 'black') +
      geom_vline(aes(xintercept = petal_length_mean), color = 'red', linewidth=1) +
      labs(x = "Petal Length", y = "Frequency")

p

# save plot as file to png
ggsave(p, filename="petal_length_hist.png")
