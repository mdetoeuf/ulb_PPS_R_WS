# Useful funcitons

# packages ----------------------------------------------------------------

install.packages() # with ""
library() # without ""
?str() # getting help about the function "str" --> looks in loaded packages
??str() # idem, looks also outside of loaded packages

sessionInfo() # gives version info on all packages currently loaded in the session
tidyverse_update() # checks if packages are up to date (tidyverse only)

# To access the vignette, if you need more input
vignette("pivot", package = "tidyr")
# if don't know names of topics, have a look here first --> then rerun with topic
vignette(package = "tidyr")

# File system & directory -------------------------------------------------

getwd()
setwd()

file.mtime("file_path") # gives time of last modification to the file

lubridate::now() # gives the time right now (from the system = in the computer)

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

ggplot(
  data, 
  mapping = aes()
  ) + 
  geom_... + # ex: geom_boxplot, geom_point, etc.
  scale_y_reverse() # reverse scale. Works also for x


# transformation with dplyr -----------------------------------------------

## on rows
filter()
arrange()
distinct()

## on columns
mutate() # compute new variables
select() 
rename()
relocate()
# for select() --> think about helper functions such as
ends_with()
starts_with()
contains()
any_of() # etc. see help of select()

## on groups
group_by() # by one or more variables
summarise() # use .by for per-operation grouping
# incl slice_ family
slice_head()
slice_tail()
slice_max()
slice_min()
slice_sample()
ungroup()

# if else, vectorized
if_else() # 3 arguments: boolean (TRUE/FALSE), what to do if TRUE, what to do if FALSE


# tidying with tidyr ------------------------------------------------------

pivot_longer()
pivot_wider()

parse_number() # extracts first number 
pull() # extract single column as vector (similar to $)

problems() # helps identify rows and columns that have unexpected vallues (see ws on pivot)


# importing with readr ----------------------------------------------------

read_csv() # for comma-separated-values
read_csv2() # for semi-colon separated values
write_csv() # will lose any column type (class, especially factor)

list.files() # needs a pattern, creates a vector of filenames corresponding to pattern

# R-specific file type
read_rds() 
write_rds() # keeps objects with all info --> better for interim storing

# same as rds, but can be used between programming languages
arrow::read_parquet()
arrow::write_parquet()

tibble() # column-wise tibble entry
tribble() # row-wise column entry

# getting help ------------------------------------------------------------

?str() # getting help about the function "str" --> looks in loaded packages
??str() # idem, looks also outside of loaded packages

# copy in clipboard code to reprex, then run
reprex::reprex()

# recreating an object for reprex --> code is ugly, think to use styler package
dput() # then copy-paste input into an object to share


# Quarto - related --------------------------------------------------------

# will render data frame as a table instead of the usual console-like output
knitr::kable(dataframe[range],) 
