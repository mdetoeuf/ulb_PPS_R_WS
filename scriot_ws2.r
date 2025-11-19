

# CHAP 3 - DATA TRANSFO ---------------------------------------------------

#** This is the script used during the second workshop for *
#** productive coding in R with the tidyverse for (Post-)docs of ULB *
#** given on 19/11/2025 by Morgane de Toeuf, head of Data Division at P&PS *
#** Because it is dense in information and the WS was a little harder *
#** to follow, I added a lot more comments than for WS1 *


# 1 - Loading packages ----------------------------------------------------

# install.packages("styler")
# install.packages("nycflights13")
# install.packages("Lahman")

library(nycflights13)
library(tidyverse)
library(Lahman)

#** ** Tip ***
#** See that loading the tidyverse overwrites some functions from *
#* *base R (package stats"). If you want to access the function filter() *
#* *from the stats package, you'll then have to be specific by writing *
#* * stats::filter() instead of just filter() *

# 2 - inspect data --------------------------------------------------------

?flights
glimpse(flights)
view(flights)


# 3 - Rows ----------------------------------------------------------------

## 3.1 - Booleans basics --------------------------------------------------------

# What is a boolean? Example
x <- 3
x

x < 5
x > 5
x < 3
x <= 3
x == 3 # For "equals to" as a boolean, double equality sign. "=" is assignment
x != 3 # is not equal to (different)

x = 5
x

# Any boolean: >, >=, <, <=, ==, !=
# But also more complex, example %in%
y <- c(1, 2, 3, 4, 5)
z <- c(6, 7, 8, 9, 10)
x %in% y # "x is in y"
x %in% z
x %in% (z/2)fli

x %in% z
!(x %in% z)


# Combine conditions with & or , ("and"), or with | ("or")
(x < 5) & (x %in% y)
(x < 5) | (x %in% y)
(x > 5) | (x %in% y)
(x > 5) & (x %in% y)


rm(x, y, z)


## 3.2 - filter() ----------------------------------------------------------

## keeping rows based on value of columns
## 1st argument = data frame
## 2nd and + arguments: conditions - must be all TRUE to keep the row

# Find all flights that departed more than 120 minutes late
filter(flights, dep_delay > 120)

flights |>
  filter(dep_delay > 120) # asks each row: "is dep_delay > 120 ?". TRUE --> keep

## combining conditions

# Flights that departed on January 1
flights |> glimpse()
flights |>
  filter(month == 1 & day == 1) # if months chr --> month == "January"

# Flights that departed in January or February
flights |>
  filter(month == 1 | month == 2)

# short cut when 2x same variable with == and an "or" --> %in%
flights |>
  filter(month %in% c(1, 2))

## Filter doesn't modify the original data frame --> assign it to new object
flight_january <- flights |> 
  filter(month == 1)

flight_january_1 <- flight_january |> 
  filter(day == 1)

## Common mistake:
# = instead of ==
flights |> filter(month = 1) # look at warning message

# writing "or" like in english. "or" btw 2 booleans
# check condition "month = 1", then checks condition "2"
flights |>
  filter(month == 1 | 2) # This "works"!, but it doesn't do what we want

flights |>
  filter(month == 1 | month == 2)


## 3.3 arrange() -----------------------------------------------------------

#** keeping rows based on value of columns *
#** 1st argument = data frame *
#** 2nd and + arguments: columns (or expressions) to order by *
#** If more than 1 column --> used to break ties *
#*

# Sort by departure time <=> sort by year, then month, then day, then dep_time
flights |>
  arrange(year, month, day, dep_time)

## use desc() to reorder in descending order
# From most to least delayed
flights |>
  arrange(desc(dep_delay)) # Nb of rows doesn't change


## 3.4 distinct() ----------------------------------------------------------

#** finds all unique rows *
#** but can also distinct combination of variables --> column names *
#*

# Remove duplicate rows, if any
flights |>
  distinct()

# Find all unique origin and destination pairs
flights |>
  distinct(origin, dest) # 2 columns : 224 combinations of origin & dest

# Same, but keep other columns
# !! Keeps the 1st occurence of each new combination --> all in 1st of January
flights |>
  distinct(origin, dest, .keep_all = TRUE)

# If want number of occurences --> use count() instead of distinct
# arrange in descending order of nb of occurrences with sort = TRUE argument
flights |>
  count(origin, dest, sort = TRUE)


## 3.5 Exercises on rows -----------------------------------------------------------

## 1
#Had an arrival delay of two or more hours

flights |> 
  filter(arr_delay >= 120) |> 
  arrange(desc(arr_delay))

#Flew to Houston (IAH or HOU)
flights |> 
  filter(dest == "IAH" | dest == "HOU")
flights |> 
  filter(dest %in% c("IAH", "HOU"))

#Were operated by United, American, or Delta. Hint: check the help menu
flights |> 
  filter(carrier %in% c("UA", "DL", "AA"))

#Departed in summer (July, August, and September)
flights |> 
  filter(month %in% c(7,8,9))

#Arrived more than two hours late but didn’t leave late
flights |> 
  filter(arr_delay > 120 & dep_delay <= 0)

#Were delayed by at least an hour, but made up over 30 minutes in flight
flights |> 
  filter(dep_delay >= 60 & dep_delay - arr_delay > 30)

## 5
# farthest distance
flights |>
  arrange(desc(distance))

# shortest distance
flights |>
  arrange(distance)

## 3
#Sort flights to find the fastest flights. (Hint: Try including a math calculation inside of your function.)
flights |> 
  arrange(desc(distance / air_time))

## 4
flights |> 
  distinct(year, month, day) |>  
  nrow()

flights |> 
  count(year, month, day) |> 
  nrow()

## 6
# no impact on result
# but impact on computing time --> filter first


#  4 - Columns ------------------------------------------------------------


## 4.1 - mutate() ----------------------------------------------------------

# new columns calculated from existing columns
# Computing gain = how much time a delayed flight makes up in the air
# and speed in miles per hour
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60
  ) |> 
  glimpse() # add on right-hand side

# argument .before --> to the left
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .before = 1 # column nb 1
  ) # "." --> argument to the function, not the name of new variable

# for .before and .after: give position of column or name of variable
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .after = day # column nb 1
  )

# argument .keep
?mutate # used --> involved or created in call to mutate()
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )

#** !! with mutate it is extra dangerous to re-assign transformed *
#** data frame onto the same object name as before * 
#** !! If assigned back to flights, especially with .keep argument! *
#** !! --> prefer new object *
#*



## 4.2 - select() ----------------------------------------------------------

## useful when many variables --> zoom in

## select columns by name
flights |> 
  select(
    year, 
    month, 
    day
  )

## select all columns between year and day (inclusive)
flights |> 
  select(year:day)

## Select all columns except those from year to day (inclusive)
flights |> 
  select(!year:day)

## Select all columns that are characters
flights |> 
  select(where(is.character))

#** helper functions --> meant for select() *
#** starts_with("abc") *
#** ends_with("xyz") *
#** contains("ijk") *
#** num_range("x", 1:3) --> matches x1, x2, x3 *

?select 

## Also with function any_of()
variables <- c("year", "month", "day", "dep_delay")
flights |> 
  select(any_of(variables))

## renaming while selecting with "="
flights |> 
  select(tail_num = tailnum)


## 4.3 - rename() ----------------------------------------------------------

## keep all existing variables but rename a few
flights |> 
  rename(tail_num = tailnum)

## For cleaning many variable names, check this function out
?janitor::clean_names()


## 4.4 - relocate() --------------------------------------------------------

## to move variables. Default: to the front
flights |> 
  relocate(time_hour, air_time)

## specify where with .before or .after
flights |> 
  relocate(
    year:dep_time,
    .after = time_hour
    ) |> 
  glimpse()

flights |> 
  relocate(
    starts_with("arr"),
    .before = dep_time
  )

flights |> glimpse()


## 4.5 - Exercises on columns ---------------------------------------------------------


## 2
flights |>
  select(dep_time, dep_delay, arr_time, arr_delay)

flights |>
  select(starts_with("dep"), starts_with("arr"))

flights |> 
  select(
    ends_with("time"), 
    ends_with("delay"), 
    -contains("sched"),
    -contains("air"))

# not seen during WS but useful also
flights |>
  select(dep_time:arr_delay, -contains("sched"))

# with helper for select()
variables <- c("dep_time", "dep_delay", "arr_time", "arr_delay")
flights |> 
  select(any_of(variables))

## 5
flights |> select(contains("TIME", ignore.case = FALSE))

?dplyr::contains

## 6
# Rename air_time to air_time_min to indicate units of measurement and move it to the beginning of the data frame.
flights |> 
  rename(air_time_min = air_time) |> 
  relocate(air_time_min)

## 7
flights |>
  select(tailnum) |>
  arrange(arr_delay)
#> Error in `arrange()`:
#> ℹ In argument: `..1 = arr_delay`.
#> Caused by error:
#> ! object 'arr_delay' not found
#>

# Problem: we try to arrange according to "arr_delay", but we didn't select it 
# 2 options: select 2 columns, then arrange, or reverse order, see hereunder
flights |>
  arrange(arr_delay) |> 
  select(tailnum)


# 5 - The pipe ------------------------------------------------------------

# Fastest flights to Houston IAH airport
flights |> 
  filter(dest == "IAH") |> 
  mutate(speed = distance / air_time * 60) |> 
  select(year:day, dep_time, carrier, flight, speed, dest) |> 
  arrange(desc(speed))

#** easy to read !!! *
#** because starts with verb at beginning of line *
#*

## Same without the pipe, even with best practice of writing...
# option 1: nest function calls into each other
arrange(
  select(
    mutate(
      filter(
        flights,
        dest == "IAH"
      ),
      speed = distance / air_time *60
    ),
    year:day, dep_time, carrier, flight, speed, dest
  ), 
  desc(speed)
)

# option 2: intermediate objects
flights1 <- filter(flights, dest == "IAH")
flights2 <- mutate(flights1, speed = distance / air_time * 60)
flights3 <- select(flights2, year:day, dep_time, carrier, flight, speed, dest)
arrange(flights3, desc(speed))

#** There may be reasons for intermediate objects or for nesting. *
#** ex: reuse of intermediate step *
#** But less readable and clutters environment *
#*

rm(flights1, flights2, flights3, variables)

# 6 - groups --------------------------------------------------------------


## 6.1 - group_by() --------------------------------------------------------

#** no change to data *
#** but indication of grouping in output *
#** will be used in subsequent verbs that will work by the groups (ex by month) *
#** Changes the behaviour of subsequent verbs, we'll see this with summarize() *

flights |> 
  group_by(month) # no change to data, but see "Groups:   month [12]" in output

# changes the behaviour of subsequent verbs, we'll see this with summarize()


## 6.2 - summarize() -------------------------------------------------------

## Computing average departure delay by month
flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay)
  )# Oops: many NA's bc dep_delay has missing values

?mean()

## use na.rm = TRUE - don't do this lightly
flights |> 
  group_by(month) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )


## using several summaries - think of typical statistics
## like min, max, n() etc.
flights |> 
  group_by(month) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    std_dev_delay = sd(dep_delay, na.rm = TRUE),
    n = n()
  )


## 6.3 - slice_ functions -------------------------------------------------

#** Extracts specific rows, per group *
#** slice_head(n = 1) --> first row *
#** slice_tail(n = 1) *
#** slice_min(x, n = 1) --> row with the smallest value for column x*
#** slice_max(x, n = 1) *
#** slice_sample(n = 1) --> takes a random sample *
#** n to select nb of rows or prop = 0.1 to select 10% of rows *
#*

# flights that are most delayed
flights |> 
  group_by(dest) |> 
  slice_max(arr_delay, n = 1) |> 
  relocate(dest)

#** slice_min() and slice_max() keep tied values *
#** n = 1 <=> give us all rows with highest value *
#** prevent this with argument with_ties = FALSE *
#*
?slice_max

flights |>
  group_by(dest) |>
  slice_max(arr_delay, n = 1, with_ties = FALSE) |>
  relocate(dest)

#** Difference with summarize() using max? *
#** keep the whole row *
#*
flights |>
  group_by(dest) |>
  summarise(max = max(arr_delay, na.rm = TRUE))

# solve the error message
flights |>
  filter(!is.na(arr_delay)) |>
  group_by(dest) |>
  summarise(max = max(arr_delay, na.rm = TRUE))

## 6.4 - grouping by multiple variables ------------------------------------

# make a group for each date --> combine year, month, day
daily <- flights |> 
  group_by(year, month, day)
daily

daily_flights <- daily |> 
  summarise(n = n()) # look at error message
daily_flights # we only have 12 groups. By default it drops the last group

daily |>
  summarise(
    n = n(),
    .groups = "drop_last"
  )
# or other options: "drop" to drop all groups, "keep" to keep all
daily |> 
  summarise(n = n(), .groups = "drop")

daily |> 
  summarise(n = n(), .groups = "keep")


## 6.5 - ungrouping --------------------------------------------------------

daily |> ungroup()

# summarize ungrouped data frame
daily |> 
  ungroup() |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    flights = n()
  ) # get a single row --> equivalent to group = whole data frame


## 6.6 - .by ---------------------------------------------------------------

# grouping per operation --> output is not grouped
flights |> 
  summarise(
    delay = mean(dep_delay, na.rm = TRUE),
    n = n(),
    .by = month
  )
# same, by multiple variables --> use c()
flights |> 
  summarise(
    delay = mean(dep_delay, na.rm = TRUE),
    n = n(),
    .by = c(origin, dest)
  )

#** works with all verbs *
#** no need to ungroup after or use the *
#** .groups argument to suppress error message *

## 6.7 - Exercises on groups ---------------------------------------------------------

## 1
# Which carrier has the worst average delays?
flights |> 
  group_by(carrier) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()) |> 
  arrange(desc(avg_delay)) # answer: F9

flights |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n(),
    .by = carrier) |> 
  arrange(desc(avg_delay))

## 2
# Find the flights that are most delayed upon departure from 
# each destination.

# First try, but wrong answer --° no information is kept to identify flights!
flights |>
  filter(!is.na(dep_delay)) |>
  group_by(dest) |>
  summarise(latest = max(dep_delay))

# proposition of a participant. good selection of rows, but same: no ID of flights
flights |> 
  filter(!is.na(dep_delay)) |> 
  summarise(
    avg_delay = max(dep_delay, na.rm = TRUE),
    n = n(),
    .by = dest) |> 
  arrange(desc(avg_delay))

# better answer with slice_
flights |> 
  group_by(dest) |> 
  slice_max(dep_delay, n = 3, with_ties = FALSE) |> 
  relocate(dest, dep_delay)

# same, but with local grouping with .by
flights |> 
  slice_max(dep_delay, n = 3, with_ties = FALSE, by = dest) |> 
  relocate(dest, dep_delay)

# other option
flights |>
  group_by(dest) |>
  arrange(dest, desc(dep_delay)) |>
  slice_head(n = 3) |>
  relocate(dest, dep_delay)


## 3
# How do delays vary over the course of the day? 
# Illustrate your answer with a plot.

# could do this but
# takes a while to compute
# so much noise that the curve appears flat. We are in minutes --> not so flat!
flights |> 
  ggplot(aes(x = hour, y = dep_delay)) +
  geom_point(alpha = 0.01) +
  geom_smooth() +
  ylim(c(0,50))

# in this case, better to first compute some sort of mean
flights |> 
  group_by(hour) |> 
  summarise(avg_delay = mean(dep_delay, na.rm = TRUE)) |> 
  ggplot(aes(x = hour, y = avg_delay)) +
  # geom_point() +
  geom_smooth() 

# if aggregate at minute instead of hour, realize that late part of the curve
# has moved quite a bit: there are less late flights, thus more variation 
# between per-hour and per-minute means
flights |>
  group_by(hour, minute) |>
  summarise(avg_delay = mean(dep_delay, na.rm = TRUE)) |>
  ggplot(aes(x = hour, y = avg_delay)) +
  geom_smooth()

# same with seeing individual points
flights |>
  group_by(hour, minute) |>
  summarise(avg_delay = mean(dep_delay, na.rm = TRUE)) |>
  ggplot(aes(x = hour, y = avg_delay)) +
  geom_point() +
  geom_smooth()

## 5 
# Explain what count() does in terms of the dplyr verbs you just learned. 
# What does the sort argument to count() do?
flights |>
  count(carrier, sort = TRUE)

# it the same as the following pipeline
flights |>
  group_by(carrier) |>
  summarise(n = n()) |>
  arrange(desc(n))

##6
df <- tibble(
  x = 1:5,
  y = c("a", "b", "a", "a", "b"),
  z = c("K", "K", "L", "L", "K")
)

df |> group_by(y) # groups df by y, the data frame is unchanged
df |> arrange(y) # arranges df in ascending order of the value of y

# groups df by y and then calculates the average value of x for each group.
df |> 
  group_by(y) |> 
  summarise(mean(x))

# groups df by y and z, and then calculates the average value of x
# for each group combination. The resulting data frame is grouped by y
df |> 
  group_by(y, z) |> 
  summarise(mean(x))

# groups df by y and z, and then calculates the average value of x
# for each group combination. The resulting data frame is not grouped
df |> 
  group_by(y, z) |> 
  summarise(mean(x), .groups = "drop")

# groups df by y and z, and then calculates the average value of x
# for each group combination.
# With summarize() 
#   the resulting data frame has one row per group combination
#   the value in mean(x) is the mean of the value x for the group
# while with mutate() 
#   the resulting data frame has the same number of rows as the original df.
#   the value in mean(x) is same as above: the mean of the value x for the group
#   as a consequence, the same "mean(x)" is repeated if for the groups that 
#   represent several lines
df |>
  group_by(y, z) |>
  summarize(mean_x = mean(x))
df |>
  group_by(y, z) |>
  mutate(mean_x = mean(x))

# 7 - Case study: aggregates and sample size ----------------------------------------------------------

#** !! we did not cover this in the WS for lack of time *
#** it is a nice way to review a bit of everything from the workshop *
#** so I highly recommend having a look at it !! *
#** if the script is not detailed enough, the original info is here: *
#** https://r4ds.hadley.nz/data-transform.html#sec-sample-size *


#** When we aggregate: always include n() *
#** --> no conclusions on small nb of observations *
#** Here example where variables are short and cryptic *
#** I would have prefered more explicit names *
#** Typically I would go through a preliminary step of tidying --> see next week *

# Variable H: player gets a hit
# Variable AB: player tries to put the ball in play

?Batting
Batting |> glimpse()

# per batter: average of times they got a hit (performance):
# how many times they hit / how many opportunities they got
batters <- Lahman::Batting |>
  group_by(playerID) |>
  summarise(
    performance = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    n = sum(AB, na.rm = TRUE)
  )
batters

# plot it --> 2 obs
# variation of perf ++ for players with fewer times at the bat
# = law of large numbers
# positive correlation between skill and opportunities :
# teams give more opportunities to best batters
batters |>
  filter(n > 100) |>
  ggplot(aes(x = n, y = performance)) + # notice switch from |>  to +
  geom_point(alpha = 1 / 10) +
  geom_smooth(se = FALSE)

#** !! implications on rating **
#** sort by desc(performance) will give randomly lucky ones *
#*

batters |>
  arrange(desc(performance))

# . ------------------------------------------
# CHAP 4 - WORKFLOW - STYLE --------------------------------------------------------

# install.packages("styler")
#** Cmd/Ctrl + Shift + P *
#** type the word "styler" --> see options *
#*

# example --> type something unstyled
batters |> filter(n>100) |> ggplot(aes(x=n,y=performance))+geom_point(alpha=1/10)+geom_smooth(se=FALSE)

# styled version: style selection
batters |>
  filter(n > 100) |>
  ggplot(aes(x = n, y = performance)) +
  geom_point(alpha = 1 / 10) +
  geom_smooth(se = FALSE)


#** For best practices on name, space, pipes, ggplot2, *
#** see powerpoint presentation and original ebook: *
#** https://r4ds.hadley.nz/data-transform.html#sec-sample-size *

# Exercises on style ---------------------------------------------------------------

# Restyle the following 2 commands.
# Hint: try it by hand to automate best practices, 
# then use the styler to see if you missed anything
flights|>filter(dest=="IAH")|>group_by(year,month,day)|>summarize(n=n(),
                                                                  delay=mean(arr_delay,na.rm=TRUE))|>filter(n>10)

flights|>filter(carrier=="UA",dest%in%c("IAH","HOU"),sched_dep_time>
                  0900,sched_arr_time<2000)|>group_by(flight)|>summarize(delay=mean(
                    arr_delay,na.rm=TRUE),cancelled=sum(is.na(arr_delay)),n=n())|>filter(n>10)

# Correction
# Done with styler: Cmd/Ctrl + Shift + P
flights |>
  filter(dest == "IAH") |>
  group_by(year, month, day) |>
  summarize(
    n = n(),
    delay = mean(arr_delay, na.rm = TRUE)
  ) |>
  filter(n > 10)

flights |>
  filter(carrier == "UA", dest %in% c("IAH", "HOU"), sched_dep_time >
           0900, sched_arr_time < 2000) |>
  group_by(flight) |>
  summarize(delay = mean(
    arr_delay,
    na.rm = TRUE
  ), cancelled = sum(is.na(arr_delay)), n = n()) |>
  filter(n > 10)
