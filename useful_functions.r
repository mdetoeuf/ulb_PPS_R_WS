# Useful funcitons

# packages ----------------------------------------------------------------

install.packages() # with ""
library() # without ""
?str() # getting help about the function "str" --> looks in loaded packages
??str() # idem, looks also outside of loaded packages


# File system & directory -------------------------------------------------

getwd()
setwd()


# Understanding objects ---------------------------------------------------

str()
glimpse()
view()
class()
head()
tail()


# Saving figures ----------------------------------------------------------

ggsave("name of the file") # figures made with ggplot
file.remove("name of the file") # has to be in the current working directory


# vectors -----------------------------------------------------------------

c() # create a vector
seq(from = 1, to = 10, by = 1) # create a vector that is a sequence
rep(c(1,2,3), 5) # repete the sequence 1,2,3; 5 times
sample(1:100, 5) # random sampling of 5 elements between 1 and 100


# visualization -----------------------------------------------------------

ggplot(data, mapping = aes()) + geom_... # ex: geom_boxplot, geom_point, etc.
