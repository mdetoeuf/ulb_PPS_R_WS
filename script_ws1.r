#| This script contains code for the first workshop in R
#| More info I'd like to share with whoever reads this
#| This pops out because of the contrast of the white colour

# But I could also just do it with a "normal" comment


# Starting a script -------------------------------------------------------

## Some good practices to start a script: make sure that R does make any 
## "assumptions" : nothing saved: 
## ---> no object in the environment, 
## ---> no graphical parameters saved, no packages "silently" loaded
## Here is how to do it

# °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°#
#| In any script:
#| Make sure you run in a new session, with empty environment
#| Have a first section where you load packages, functions, datasets
#| Creating a new section, in Mac Shift + Cmd + R. In Windows: Shift + Ctrl + R
# °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°#


# To run a command (= a line of code): go to the line in question, and
# In Mac: Cmd + Enter
# In Windows: Ctrl + Enter

# empty environment
rm(list = ls())

# Restart R: Got to menu "Session" --> "Restart R"

# 1 - Loading packages --------------------------------------------------------------

# tidyverse = basics
#install.packages("tidyverse")
library(tidyverse)

# additional packages´
library(palmerpenguins) # dataset
library(ggthemes) # colorblind palette



# .----------------------------------------------------------------------
# °°°°° CHAP 1 - DATA VIS °°°°°° ------------------------------------------



# 2 - First steps ---------------------------------------------------------

#| Do penguins with longer flippers weigh more or less than penguins with shorter flippers? 
#| What does the relationship between flipper length and body mass look like? 
#| Is it positive? Negative? Linear? Nonlinear? 
#| Does the relationship vary by the species of the penguin? 
#| How about by the island where the penguin lives? 


# 3 - Looking at data set and its meaning --------------------------------

### The penguins data frame: species, flipper length, body mass, ...
# palmerpenguins::penguins
# Data frame: columns (variables) x rows (observations)

# A few basic commands to understand how your data set is structured
str(penguins)
class(penguins)
class(penguins$body_mass_g)

head(penguins) # first lines of the data frame
head(penguins, 2)
tail(penguins, 2) # last 2 lines of the data frame

glimpse(penguins)
view(penguins) # opens another tab and shows the data frame

nrow(penguins)
ncol(penguins)
colnames(penguins)[1:3]

?palmerpenguins::penguins


# 4 - Step-by-Step towards scatter plot ---------------------------------------------------------

ggplot() # plot object --> add layers to

# first argument = data set --> penguins
ggplot(data = penguins) # only canvas to see. ggplot doesn't know how to plot 

# adding mapping with aesthetics function
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) # now it added axes, but how to represent data?

# define a geom = geometrical objects
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point() ## Check warning message! Are we ok with it?

# adding aesthetics and layers: mapping variables to dimensions
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g,
                     colour = species,
                     shape = species)) +
  geom_point()

# adding smooth curve
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g,
                     colour = species,
                     shape = species)) +
  geom_point() +
  geom_smooth(method = "lm")


# total smooth curve --> how is this not optimal?
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g,
                     colour = species)) +
  geom_point() +
  geom_smooth(method = "lm")

# smooth curve --> consider: should mapping of varibales 
# occur at local or global level?
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(colour = species,
                           shape = species)) +
  geom_smooth(method = "lm")

# "beauty" or "readability" of the plot --> work on labels
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(colour = species,
                           shape = species)) +
  geom_smooth(method = "lm") +
  labs(title = "Body mass vs flipper length",
       subtitle = "names of the 3 species",
       x = "cool axis name",
       y = "Body mass [g]",
       colour = "Species",
       shape = "Species"
  ) +
  scale_color_colorblind()


## 4.1 - exercices series 1 ------------------------------------------------

# Exo nb 3
ggplot(
  data = penguins, 
  aes(x = bill_depth_mm, y = bill_length_mm)) +  
  geom_point(mapping = aes(
    colour = species, shape = species))

# Exo nb 4
ggplot(data = penguins,
       mapping = aes(x = species,
                     y = bill_depth_mm)) +
  geom_point()

# Exo nb 8
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm,
                     y = body_mass_g)) +
  geom_point(mapping = aes(colour = bill_depth_mm)) +
  geom_smooth()


## 4.2 - Tips - calling functions & the pipe -------------------------------

# Sparing text --> readability & time saving
# if arguments in right order, skip the "data = ", ...
ggplot(data = penguins,
       mapping = aes(x = body_mass_g, y =bill_length_mm)) +
  geom_point()

# code above is the same as the following
ggplot(penguins,
       aes(x = body_mass_g, y =bill_length_mm)) +
  geom_point()

# same thing, but using the pipe
penguins |> ggplot(aes(x = body_mass_g, y =bill_length_mm)) +
  geom_point()

# Other example for the pipe:
str(penguins)
# same as
penguins |> str()


# 5 - Distributions -------------------------------------------------------

## 5.1 - Categorical variable --> barplot ----------------------------------

ggplot(penguins,
       aes(x = species)) +
  geom_bar() # non-ordered levels

# ordering levels of the x variable
ggplot(penguins,
       aes(x = (fct_infreq(species)))) +
  geom_bar() 

## 5.2 - Numerical variable --> histogram / density ------------------------

# Historgrams
ggplot(penguins,
       aes(x = body_mass_g)) +
  geom_histogram()

# playing with bins --> always recommended
ggplot(penguins,
       aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200) # binwidths, test 20 and 2000 also

ggplot(penguins,
       aes(x = body_mass_g)) +
  geom_histogram(bins = 20) # bins, test 10 and 40

# density curve
ggplot(penguins,
       aes(x = body_mass_g)) +
  geom_density()


## 5.3 - Exercises series 2 ------------------------------------------------

# exercise #1 - horizontal barplot
ggplot(penguins,
       aes(y = (fct_infreq(species)))) +
  geom_bar()

# exercise #2 - fill vs colour for surfaces
ggplot(penguins, aes(x = species)) +
  geom_bar(color = "red")

ggplot(penguins, aes(x = species)) +
  geom_bar(fill = "red")


# exercise #4 - histogram of carat variable of diamonds dataset (tidyverse)

# new data set --> explore it first
diamonds |> view()
diamonds[1] |> view()
diamonds$carat |> str()
diamonds$carat |> class()

# histograms + play with bins
diamonds |> ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 1)

diamonds |> ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 0.1)
  xlim(c(0,3.5)) # if want to limit range of the graph

diamonds |> ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

# density curve
diamonds |> ggplot(aes(x = carat)) +
  geom_density()


# 6 - Relationships -------------------------------------------------------

## 6.1 - Numerical x categorical -------------------------------------------

# distribution of body mass per species
# Boxplots
ggplot(penguins,
       aes(x = species,
           y = body_mass_g)) +
  geom_boxplot()

# violin plot
ggplot(penguins,
       aes(x = species,
           y = body_mass_g)) +
  geom_violin()

?geom_violin

# density curves
ggplot(penguins, 
       aes(x = body_mass_g,
           colour = species)) +
  geom_density(linewidth = 0.75)

# fill with curves
ggplot(penguins, 
       aes(x = body_mass_g,
           colour = species,
           fill = species)) +
  geom_density(linewidth = 0.75,
               alpha = 0.2)


## 6.2 - 2 categorical variables -------------------------------------------

## Distribution within a distribution
# Stacked barplot
ggplot(penguins,
       aes(x = island,
           fill = species)) +
  geom_bar() # no idea of percentage

ggplot(penguins,
       aes(x = island,
           fill = species)) +
  geom_bar(position = "fill")

## 6.3 - 2 Numerical variables ---------------------------------------------

# 2 variables --> Scatter plot (see above)
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()

## 6.4 - 3 or more variables -----------------------------------------------
# mapping colours and shapes to categorical variables 
# --> not recommended to have >3 dimensions on a single plot
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(colour = species,
                 shape = island))

# Instead: use facetting

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(colour = species)) +
  facet_wrap(~island )

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(colour = island)) +
  facet_wrap(~species )

# mapping colour to numerical variable
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(colour = bill_depth_mm))

## 6.5 - Exercices ---------------------------------------------------------
#1 --> together
glimpse(mpg)
?mpg
str(mpg)

#7 --> together
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill")
ggplot(penguins, aes(x = species, fill = island)) +
  geom_bar(position = "fill")

#5 --> work alone
ggplot(penguins, 
       aes(x = bill_depth_mm, y = bill_length_mm, colour = species)) + 
  geom_point()

ggplot(penguins, 
       aes(x = bill_depth_mm, y = bill_length_mm, colour = species)) + 
  geom_point() +
  facet_wrap(~species)



# 7 - Saving plots -------------------------------------------------------------------------


## 7.1 - working directory -------------------------------------------------


# Where to save or read files? 

# Current working directory --> "get working directory"
getwd()
# in my computer, this is what appears in the console:
# [1] "/Users/Admin/Nextcloud/PhD/01_Code/HandsOn_R_WS_2025"

# Setting working directory = telling the computer to go work somewhere else
setwd("/Users/Admin/Nextcloud/PhD/01_Code/HandsOn_R_WS_2025/Shared_stuff")
getwd()
# this is now the new "answer" that appears in the console (it changed indeed):
# [1] "/Users/Admin/Nextcloud/PhD/01_Code/HandsOn_R_WS_2025/Shared_stuff"


## 7.2 - ggsave() and file.remove() ----------------------------------------


# let's plot again something from earlier:
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()

## ggsave() will save, by default: 
# --> the last plot that was plotted
# --> in the current working directory 
# --> in the dimensions of the current plotting device (usually "plot" panel)

# this will save a plot called "plot1.png" in the working directory
ggsave("plot1.png")

# same, but pdf
ggsave("plot1.pdf")

# the following to lines will do the same job: 
# --> going back 1 step in previous working directory
# --> adding a folder path before the file name to enter a folder
setwd("/Users/Admin/Nextcloud/PhD/01_Code/HandsOn_R_WS_2025")
ggsave("Shared_stuff/plot1.png")

# You can also remove files with following command
file.remove("Shared_stuff/plot1.png")



# .-----------------------------------------------------------------------
# °°°°°° CHAP 2 - WORKFLOW BASICS °°°°°° ----------------------------------

# 8 - Coding basics (reminder) -------------------------------------------------------


## 8.1 - operations, vectors, objects --------------------------------------

## math calculations
1 / 200 * 30
(59 + 73 + 2) / 3
sin(pi / 2)

## Create objects with "assign" operator
x <- 3 * 4 # not printed, just stored in the environment
x # prints it

# Vector c for combine
x <- c(1,2,3,4,5)

# arithmetic on vectors: acts on each item
x * 2 # Use spaces! = good practice: more readable

# you can store bits of data frame in an object, like a column (or variable)
body_mass <- penguins$body_mass_g
body_mass
head(body_mass)
class(body_mass)


## 8.2 - tips: names and order of arguments -----------------------------------------------------


# naming objects: descriptive & long >> short & cryptic
this_is_a_really_long_name <- 2.5
t_i_a_r_l_n <- 2.5 # in 2 months, you don't know what the initials stand for!

# examples with the seq funciton. First, check out what the function does
?seq() # arguments are from, to, by (in that order)

# missing arguments will go to default value
seq(0, 1) # Here, no argument "by" is missing --> default: by = 1
seq(0, 1, 0.1) # same "from" and "to", different "by"

## order of arguments matter, unless you write "argument ="
a <- 1
b <- 10
c <- 2


seq(from = a,
    to = b,
    by = c) # order matters
# same as above, because order is respected
seq(a,b,c)

# error: check the message. It is trying to go from b to a by c
seq(b,a,c)
# here, no error message: it renders something, 
# but bc order is changed, the result changed
seq(b,a,-c) # only if argument name not mentioned

# if you are explicit with "from =", then the order does not matter
# the following 3 lines do the exact same thing
seq(a,b,c)
seq(from = a, to = b, by = c)
seq(by = c, from = a, to = b)


## 8.3 - Class of objects --------------------------------------------------

# often you will have error messages linked to 
# objects being stored in the wrong "class"

# typical classes are, e.g., numerical, character, factor
# we will understand more about factors over the next weeks

## numerical
x <- 3
x
class(x) 

## character
y <- "5" # because of the "", this is not a numeric
y
class(y)
y |> class() # same, just getting used to the pipe

# error message: can't add numeric and character
x + y

# "magical" functions. If R can recognize what it should be, 
# you can coerce new classes. 
# e.g., "5" could become 5, 
# but R wouldn't know how to coerce "Hello" to numeric

# solve the issue with as.numeric()
z <- as.numeric(y)
z |> class()

x + z # now it works. same as:
x + as.numeric(y)
class(x + z)
(x + z) |> class()

# There is a whole series of such functions:
# as.character()
# as.factor()
# etc.
