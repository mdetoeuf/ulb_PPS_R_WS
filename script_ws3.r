
# START - loading packages ----------------------------------------------------

library(tidyverse)
library(nycflights13)
#install.packages("arrow")
library(arrow)

# CHAP 5 - TIDYING --------------------------------------------------------

#** This chapter focuses on the package tidyr *
#** which is a part of the core tidyverse *
#*
#*.      * DEF OF TIDY DATA *
#*
#** Each variable is a column; each column is a variable *
#** Each observation is a row; each row is an observation *
#** Each value is a cell; each cell is a single value *


## 5.1 - Definition - examples ---------------------------------------------

#** here are 3 versions of same data frame, not equally useful *

#** table1 --> tidy *
#> # A tibble: 6 × 4
#>   country      year  cases population
#>   <chr>       <dbl>  <dbl>      <dbl>
#> 1 Afghanistan  1999    745   19987071
#> 2 Afghanistan  2000   2666   20595360
#> 3 Brazil       1999  37737  172006362
#> 4 Brazil       2000  80488  174504898
#> 5 China        1999 212258 1272915272
#> 6 China        2000 213766 1280428583

#** table2 --> 2 rows per observation *
#> # A tibble: 12 × 4
#>   country      year type           count
#>   <chr>       <dbl> <chr>          <dbl>
#> 1 Afghanistan  1999 cases            745
#> 2 Afghanistan  1999 population  19987071
#> 3 Afghanistan  2000 cases           2666
#> 4 Afghanistan  2000 population  20595360
#> 5 Brazil       1999 cases          37737
#> 6 Brazil       1999 population 172006362
#> # ℹ 6 more rows

#** table3 --> 2 variables in 1 column / 2 values in some cells *
#> # A tibble: 6 × 3
#>   country      year rate             
#>   <chr>       <dbl> <chr>            
#> 1 Afghanistan  1999 745/19987071     
#> 2 Afghanistan  2000 2666/20595360    
#> 3 Brazil       1999 37737/172006362  
#> 4 Brazil       2000 80488/174504898  
#> 5 China        1999 212258/1272915272
#> 6 China        2000 213766/1280428583


## Because table 1 is tidy, here is how we could easily work with it, 
## with steps we already saw in previous workshops

# First, create table1
# tribble() and tibble() are really useful functions to create small tables,
# typically for testing or building code, see CHAP 7 for proper introduction to it

table1 <- tribble(
  ~country,       ~year, ~cases, ~population,
  "Afghanistan",  1999,     745,    19987071,
  "Afghanistan",  2000,    2666,    20595360,
  "Brazil",       1999,   37737,   172006362,
  "Brazil",       2000,   80488,   174504898,
  "China",        1999,  212258,  1272915272,
  "China",        2000,  213766,  1280428583
)

# Compute rate per 10,000
table1 |>
  mutate(rate = cases / population * 10000)

# Compute total cases per year
table1 |> 
  group_by(year) |> 
  summarize(total_cases = sum(cases))

# Visualize changes over time
ggplot(table1, aes(x = year, y = cases)) +
  geom_point(aes(color = country, shape = country)) +
  geom_line(aes(group = country), color = "grey50") +
  scale_x_continuous(breaks = c(1999, 2000)) # x-axis breaks at 1999 and 2000


## 5.2 - Lengthening data --------------------------------------------------

?billboard # comes with tidyr

billboard # 317 rows x 79 variables
billboard |> head()

### 5.2.1 - data in column names -------------------------------


#** using pivot_longer() *
#** column names become 1 variable *
#** content of those columns become value in a new column *
#*

billboard |> # we get a tibble with 24092 rows and only 5 variables
  pivot_longer(
    cols = starts_with("wk"), # in which columns to take values
    names_to = "week", # names of the columns to become categorical variable
    values_to = "rank" # values within those columns to be stored in a new variable
  ) |> head()

# For argument cols: same syntax as select() --> any helper function is fine
# could also use 
# cols = !c(artist, track, date.entered) 

#> "week" and "rank" quoted because new variable names (don't yet exist)

#** pivot_longer can generate a lot of artificially missing data *
#** due to the former data structure *
#*

# removing NAs
billboard |> # reduced nb of rows to 5307
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank",
    values_drop_na = TRUE
  )

# Now tidy but future computation easier if weeks are numbers, not strings
# using function parse_number()
?parse_number

billboard_longer <- billboard |> 
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank",
    values_drop_na = TRUE
  ) |> 
  mutate(
    week = parse_number(week)
  ) #|> glimpse()

# Visualize ranking of songs over time
billboard_longer |> # very few stay longer than 20 weeks
  ggplot(aes(x = week, y = rank, group = track)) +
  geom_line(alpha = 0.25) +
  scale_y_reverse()

# could have done this in one long pipeline
# only interesting if don't need to use this pivotted table for something else 
billboard |> 
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank",
    values_drop_na = TRUE
  ) |> 
  mutate(
    week = parse_number(week)
  ) |> 
  ggplot(aes(x = week, y = rank, group = track)) +
  geom_line(alpha = 0.25) +
  scale_y_reverse()



### 5.2.2 - how does pivoting work? -----------------------------------------

#** this section is only there to build visuals for the slides *
#** --> go to 5.2.3 *

# create a simple data set: size of 3 kids at birth and at 4 years 
# tribble(): practical to create small data sets, on a per-row approach
# alternative to tribble() is tibble(): on a per-column approach


growth <- tribble(
  ~kid,     ~y0,  ~y4,
  "kid_A",   49,  100,
  "kid_B",   52,  104,
  "kid_C",   51,  108
)

#** we want 3 variables: *
#** kid already exists *
#** age would regroup 0 and 4 years (categorical) --> column "names_to" *
#** size would regroup sizes at all ages --> column "values_to" *
#*

growth |> 
  pivot_longer(
    cols = y0:y4,
    names_to = "age",
    values_to = "size"
  )


### 5.2.3 - many variables in column names ----------------------------------

who2
?who2

#** columns that need pivotting --> cols *
#** info entailed in colnames to become new variable(s) --> names_to *
#** if several infos --> use a vector (!! keep same order)*
#** separator that is between pieces of info in colnames --> names_sep *
#** values to be aligned in one new variable --> values_to *
#*

who2 |> 
  pivot_longer(
    cols = !(country:year),
    names_to = c("diagnosis", "gender", "age"),
    names_sep = "_", # alternative is names_pattern, requires knowledge of regex
    values_to = "count"
  ) 


### 5.2.4 - Data and variable names in the column headers -------------------

?household
household

#** Spoiler: you will probably not remember this by heart *
#** and it's ok. You just need to know where to find it when you need it *

# ".value" is a sentinel: not the name of a variable, 
# but tells pivot_longer() to work differently, i.e.,
# override the usual values_to argument to use: 
# for the first component of the pivoted column name as a variable name
household |> 
  pivot_longer(
    cols = !family,
    names_to = c(".value", "child"),
    names_sep = "_",
    values_drop_na = TRUE # bc one of the families has only one child
  )


## 5.3 - Widening data -----------------------------------------------------

cms_patient_experience

# to see what is in measure_cd and measure_title (see ppt for explanations)
cms_patient_experience |> 
  distinct(measure_cd, measure_title)

#** We will choose to give values from measure_cd as new column names *
#** bc it is suitable for variable name: no space, not too long, ... *
#** whereas measure_title contains spaces and is too long *
#** but CAHPS_GRP_1 is not really meaningful or user friendly, so *
#** in real life, you should probably rename them after pivotting *


# # A tibble: 6 × 2
# measure_cd   measure_title                                                         
# <chr>        <chr>                                                                 
#   1 CAHPS_GRP_1  CAHPS for MIPS SSM: Getting Timely Care, Appointments, and Information
# 2 CAHPS_GRP_2  CAHPS for MIPS SSM: How Well Providers Communicate                    
# 3 CAHPS_GRP_3  CAHPS for MIPS SSM: Patient's Rating of Provider                      
# 4 CAHPS_GRP_5  CAHPS for MIPS SSM: Health Promotion and Education                    
# 5 CAHPS_GRP_8  CAHPS for MIPS SSM: Courteous and Helpful Office Staff                
# 6 CAHPS_GRP_12 CAHPS for MIPS SSM: Stewardship of Patient Resources  

# pivoting
cms_patient_experience |> 
  pivot_wider(
    names_from = measure_cd,
    values_from = prf_rate
  ) # oops. Lots of NA, and no reduction of nb of rows

#** Bc there is redundancy, pivot_wider would not dare to remove the *
#** content in measure_title, and doesn't know how to integrate it in *
#** the table otherwise *
#** 2 ways to solve the issue. Either way, the column measure_title gets lost *
#** but because it is redundant, it is easy to retrieve... *
#** we know the correspondence btw measure_cd and measure_title which are * 
#** synonymous *
#*

# option 1: remove redundant column before pivoting
cms_patient_experience |> 
  select(!measure_title) |> 
  pivot_wider(
    names_from = measure_cd,
    values_from = prf_rate
  )

# option 2: tell pivot_wider which columns 
# have values that uniquely ID each row
cms_patient_experience |> 
  pivot_wider(
    id_cols = starts_with("org"), # again, syntax of helper functions (select())
    names_from = measure_cd,
    values_from = prf_rate
  )


### 5.3.1 - how does pivot_wider() work?  ------------------------------------------------------------------

#** This section is to build visuals for ppt. Just skip to the end: *
#** --> check vignette then go to CHAP 6 *


growth <- tribble(
  ~kid,    ~age,    ~size,
  "kid_A", "y0",       49,
  "kid_A", "y4",      100,
  "kid_A", "y6",      118,
  "kid_B", "y0",       52,
  "kid_B", "y4",      104,
)

growth |> 
  pivot_wider(
    names_from = age,
    values_from = size
  )

#** What does it do? *
#** figure out what goes in rows or columns *

## first, column names = unique values of age
growth |> 
  distinct(age) 

# or see it as vector
growth |> 
  distinct(age) |> 
  pull() # extract a single column --> return as vector

# second, rows: by default: all columns not going into names or values
# are the id_cols argument
growth |> 
  select(!age & !size) |> 
  distinct() 

#** so now we have rows defined by kid_A and kid_B *
#** and we have column names which will be y0, y4, y6 *
#** so that's an empty data frame (below) with missing values. *
#** Then pivot_wider only has to fill in the values that *
#** are given to values_from *
#*

# creating empty data frame
growth |> 
  select(!age & !size) |> 
  distinct() |> # assign kid as first column
  mutate(x = NA, y = NA, z = NA) # add empty columns

# called x, y, z, but can be renamed according to distinct age
# e.g. by assigning this to an object and renaming columns (3 steps):
empty_df <- growth |> 
  select(!age & !size) |> 
  distinct() |>
  mutate(x = NA, y = NA, z = NA)

cols <- growth |> 
  distinct(age) |> 
  pull() # pull turns its input into a vector (check output with / without it)

colnames(empty_df)[2:4] <- cols

empty_df

# repeat the pivot --> see that there is an NA
# pivot_wider can "make" missing values (more infos in Chapter 18)
growth |> 
  pivot_wider(
    names_from = age,
    values_from = size
  )

#** Common issue: if there are 2 measurements for 1 cell *
#** e.g., 2 measurements for kid_A at y4 *
#** then receive output with list-columns *
#** too advanced at this point, but if it happens, *
#** there are indices in the book on how to deal with this *
#** and even more examples and solutions in the vignette *
#*
# To access the vignette, if you need more input
vignette("pivot", package = "tidyr")
# if don't know names of topics, have a look here
vignette(package = "tidyr")



# CHAP 6 - WORKFLOW Scripts and projects ----------------------------------

#** During WS, I promised to look up how to find the version of packages *
#** that are currently being used. We need the function sessioninfo() *

sessionInfo()

## In my case, I had loaded the tidyverse. Output from this function was:
# other attached packages:
#   [1] lubridate_1.9.4 forcats_1.0.1   stringr_1.6.0   dplyr_1.1.4     purrr_1.2.0    
# [6] readr_2.1.5     tidyr_1.3.1     tibble_3.3.0    ggplot2_4.0.0   tidyverse_2.0.0
# 
# loaded via a namespace (and not attached):
#   [1] vctrs_0.6.5        cli_3.6.5          rlang_1.1.6        stringi_1.8.7     
# [5] generics_0.1.4     S7_0.2.0           glue_1.8.0         hms_1.1.3         
# [9] scales_1.4.0       grid_4.5.2         tzdb_0.5.0         lifecycle_1.0.4   
# [13] compiler_4.5.2     RColorBrewer_1.1-3 timechange_0.3.0   pkgconfig_2.0.3   
# [17] rstudioapi_0.17.1  farver_2.1.2       R6_2.6.1           tidyselect_1.2.1  
# [21] pillar_1.11.1      magrittr_2.0.4     tools_4.5.2        withr_3.0.2       
# [25] gtable_0.3.6      

## Naming files

#** During the WS, we worked in new project --> clean script ! *
#** in here, I just go on *

getwd() # "Shared stuff!"

# Type next code --> save it


library(tidyverse)

ggplot(diamonds, aes(x = carat, y = price)) + 
  geom_hex()
ggsave("diamonds.png") # check that it appeared in files pane

## First create new folder called "data" --> use "Files" pane

write_csv(diamonds, "data/diamonds.csv") # check now the structure with path to next folder

## notice that working directory has not changed
## if need to access files in data/ --> always need to write it

#** Quit RStudio --> inspect folder structure in Finder or Windows Explorer, *
#** with new files and with .Rproj file *


# CHAP 7 - IMPORT ---------------------------------------------------------


getwd()


library(tidyverse)


## 7.1 - Read data from file - CSV -----------------------------------------------

#** we start with data from the internet, because we haven't shared files. *
#** To prevent you from accidentaly downloading thing, the call to read_csv() *
#** is set as a comment --> un-comment it if you want to run it *
#** FYI: the path/adress can also be from the working directory, see example below *

## from internet
# students <- read_csv("https://pos.it/r4ds-students-csv")

#> look at message: 
#> delimiter = ","
#> nb of columns
#> specification of columns => organized by type of variables (class) + names
#> 

# if you want to test importing from your local folder, you'll need to first 
# save "students" locally, with write_csv. Normally we look at it later, but
# FYI, you can try with the following code. BTW, if you don't have a folder data,
# R will ask if you want to create one. Answer accordingly
# students |> write_csv("data/students.csv")

# , 
# but just as example: this would be to access the file students/csv 
# that would be in the folder called "data". (only works if you run the call 
# to write_csv hereabove as well)
# students <- read_csv("data/students.csv")




### 7.1.1 - practical advice ------------------------------------------------


#** Same here, call to read_csv() is as comment --> un-comment it *
#** 1st step after import: typically some transformation --> look at it first *
#** See the N/A in favourite.food column --> should be NA (= "not available") *

students
# look at NA --> introduce na option
# students <- read_csv("https://pos.it/r4ds-students-csv", na = c("N/A", ""))
students # see the colour coding that hints that it is not just a string anymore

#** See column names --> some surrounded by ticks *
#** because space --> need to specify start & end of string *
#** (when prepare data, avoid spaces & special characters in variable names) *
#** we need the ticks to refer to them as well, with functions that we know *
#** (if doesn't work with apostrophe --> try back ticks) *

students |> 
  rename(
    students_id = 'Student ID',
    full_name = 'Full Name'
    ) # notice tick marks are gone

## Trick: clean_names function from janitor package
students |> janitor::clean_names()
# notice that it also solved favourite.food and mealPlan
# watch out that pH would become p_h --> janitor not perfect, but super useful

#** See variable types --> what is needed downstream *
#** use the as._ family of functions --> as.character(), as.numeric(), etc. *
#*

## meapl_plan : categorical variable: fixed set of option --> FACTOR !

students |>
  janitor::clean_names() |>
  mutate(meal_plan = factor(meal_plan))
# note: values unchanged, only type (class): <chr> --> <fct>

students |>
  janitor::clean_names() |>
  mutate(meal_plan = as.factor(meal_plan))

## fix age column : saved as <chr> bc of the "five"

# quickly introduce if_else
?if_else()

students |>
  janitor::clean_names() |>
  mutate(
    meal_plan = factor(meal_plan),
    age = if_else(age == "five", "5", age)
  ) # works, but still a character, if want to plot it, need numeric  

# remember parse_number function
?parse_number

students |>
  janitor::clean_names() |>
  mutate(
    meal_plan = factor(meal_plan),
    age = parse_number(if_else(age == "five", "5", age))
  ) # now it works

## store it. Now we replace by itself, but source of truth = file
students <- students |>
  janitor::clean_names() |>
  mutate(
    meal_plan = factor(meal_plan),
    age = parse_number(if_else(age == "five", "5", age))
  ) 

## in real life, i would rather add the cleaning pipeline directly in the import
## like this

students <- read_csv("data/students.csv", na = c("N/A", "")) |> 
  janitor::clean_names() |>
  mutate(
    meal_plan = factor(meal_plan),
    age = parse_number(if_else(age == "five", "5", age))
  ) # but watch out: error message from import with read_csv, not including next steps!

students


### 7.1.2 - other arguments to read_csv() -----------------------------------

# typing in csv-like table
read_csv(
  "a,b,c
  1,2,3
  4,5,6"
) # default: 1st line = headers

# skip n lines (e.g., file from spectro)
read_csv(
  "The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3",
  skip = 2
)

# skip comment lines
read_csv(
  "# A comment I want to skip
  x,y,z
  1,2,3",
  comment = "#"
)

# argument col_names if no headers
read_csv(
  "1,2,3
  4,5,6",
  col_names = FALSE
)

# argument col_names to add headers
read_csv(
  "1,2,3
  4,5,6",
  col_names = c("x", "y", "z")
)

# see help menu for more arguments if needed
?read_csv()


### Exercises ---------------------------------------------------------------

#1
# read_delim(
#   delim = "|"
#   )

#4 # intro: \n = going to the line
read_csv(
  "x,y\n1,'a,b'",
  quote = "'"
) # in solution book: quote = "\'" --> both work

#5 
# interesting: see how R forces a solution but warns of issues
# one variable name seems to be misssing
read_csv("a,b\n1,2,3\n4,5,6")
# here also, nb of values per line != nb of variables
read_csv("a,b,c\n1,2\n1,2,3,4")
# so it looks like missing values is fine --> NA
# but missing variables = too many values --> will be merged

# each column has numerical and string values --> coerced into <chr>
read_csv("a,b\n1,2\na,b")

# here, should be reav_csv2 because semi-colon
read_csv("a;b\n1;3")

#6 

annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)


annoying |> select('1')

## in previous call, apostrophe worked, but here, 
# just with "apostrophe", doesn't know that we do not refer to the string "1" 
# (so it plotted a graph o x = 1 and y = 2 --> just one dot)
# now we need to use backticks ("accent grave") to solve this issue
annoying |> 
  ggplot(aes(x = `1`, y = `2`)) +
  geom_point()

annoying |> 
  mutate(
    `3` = `2` / `1` 
  )

annoying |> 
  mutate(
    `3` = `2` / `1` 
  ) |> 
  rename(
    one = `1`,
    two = `2`,
    three = `3`
  )

## 7.2 - Controlling column types ----------------------------------------

#** illustration of heuristics for attribution of column types *

read_csv("
  logical,numeric,date,string
  TRUE,1,2021-01-15,abc
  false,4.5,2021-02-15,def
  T,Inf,2021-02-16,ghi
")

#** failures in column detection --> spotting unexpected values *

# 1-column csv to illustrate
simple_csv <- "
  x
  10
  .
  20
  30"

# attempt to read it without additional arguments --> <chr>
read_csv(simple_csv)

# try to enforce col_type:
read_csv(
  simple_csv,
  col_types = list(x = col_double())
) # replaced unexpected value with NA

# but we may want to find unexpected value and decide what to do about it
# bc in bigger data frame, the issu may not be as obvious
# store it into an object so we can call problems() as suggested by warning
df <- read_csv(
  simple_csv,
  col_types = list(x = col_double())
)
problems(df)
# gives row and col where issue, and says what it expected vs what it found

# we could decide to add . as a possible NA
read_csv(simple_csv, na = ".") 
# same result as above, but explicit and we are sure (imagine big data table)

# column types listed in ppt, but also listed in help menu
?col_types 

## override default heuristic 
# default column type
another_csv <- "
x,y,z
1,2,3"

read_csv(
  another_csv, 
  col_types = cols(.default = col_character())
)

# only select some columns & give it a column type
read_csv(
  another_csv,
  col_types = cols_only(x = col_character())
)



## 7.3 - Reading data from multiple files ----------------------------------

#** only works if files have same structure *
#** here an example with my own data *
#** bc it's my own files and it will not work on other computer, I *
#**       - Add here as comment the output from my computer *
#**       - Add below the original code from the book (not covered during *
#**         the WS, but so you can test it yourself *
#** first, look at files panel --> slake files *
#** share a common structure --> all start with "slake", then numbers *
#** open one file --> notice semi-colon as separator --> read_csv2() *
#*
#** FYI, just good to know that it is possible*
#** and figure out regex if it is useful for you *
#*
# create a vector with file names of files corresponding to pattern
slake_files <- list.files(
  "Shared_stuff/data", # path where to find files
  pattern = "slake", # pattern to select files
  full.names = TRUE # full name with path
)
slake_files # is just a vector with the names (incl paths) of the files). 
# Here only 2 but it will take all files in the directory that fit the pattern
# Notice the files have the .txt extension. If the structure is like a csv, 
# read_csv() or read_csv2() will work, even if plain text (csv is just a special
# case of plain text) 
# [1] "Shared_stuff/data/slake_1_data_20240326152907.txt"
# [2] "Shared_stuff/data/slake_1_data_20240326155515.txt"


# look at the files
read_csv2(slake_files[1]) # 10 rows
# A tibble: 10 × 7
#       i campaign serie sample    slake time                mass 
#   <dbl> <chr>    <dbl> <chr>     <dbl> <dttm>              <chr>
# 1     1 agric     2023 TST_FP_M1     1 2024-03-26 15:29:19 0.08 
# 2     2 agric     2023 TST_FP_M1     1 2024-03-26 15:29:19 0    
# 3     3 agric     2023 TST_FP_M1     1 2024-03-26 15:29:19 0    
# 4     4 agric     2023 TST_FP_M1     1 2024-03-26 15:29:19 1.15 
# 5     5 agric     2023 TST_FP_M1     1 2024-03-26 15:29:19 6.32 
# 6     6 agric     2023 TST_FP_M1     1 2024-03-26 15:29:19 3.2  
# 7     7 agric     2023 TST_FP_M1     1 2024-03-26 15:29:19 0    
# 8     8 agric     2023 TST_FP_M1     1 2024-03-26 15:29:20 1.89 
# 9     9 agric     2023 TST_FP_M1     1 2024-03-26 15:29:20 5.81 
# 10    10 agric    2023 TST_FP_M1     1 2024-03-26 15:29:20 0.75 
read_csv2(slake_files[2]) # 200 rows --> same structure

# in real life, I have 150 such files... so next command really useful
# notice added 1st column with file names, and we now have 210 rows = sum of other 2
read_csv2(slake_files, id = "file") # look at file column
# # A tibble: 210 × 8
#   file                                i campaign serie sample slake time                mass 
#   <chr>                           <dbl> <chr>    <dbl> <chr>  <dbl> <dttm>              <chr>
# 1  Shared_stuff/data/slake_1_data…     1 agric     2023 TST_F…     1 2024-03-26 15:29:19 0.08 
# 2  Shared_stuff/data/slake_1_data…     2 agric     2023 TST_F…     1 2024-03-26 15:29:19 0    
# 3  Shared_stuff/data/slake_1_data…     3 agric     2023 TST_F…     1 2024-03-26 15:29:19 0    
# 4  Shared_stuff/data/slake_1_data…     4 agric     2023 TST_F…     1 2024-03-26 15:29:19 1.15 
# 5  Shared_stuff/data/slake_1_data…     5 agric     2023 TST_F…     1 2024-03-26 15:29:19 6.32 
# 6  Shared_stuff/data/slake_1_data…     6 agric     2023 TST_F…     1 2024-03-26 15:29:19 3.2  
# 7  Shared_stuff/data/slake_1_data…     7 agric     2023 TST_F…     1 2024-03-26 15:29:19 0    
# 8  Shared_stuff/data/slake_1_data…     8 agric     2023 TST_F…     1 2024-03-26 15:29:20 1.89 
# 9  Shared_stuff/data/slake_1_data…     9 agric     2023 TST_F…     1 2024-03-26 15:29:20 5.81 
# 10 Shared_stuff/data/slake_1_data…    10 agric     2023 TST_F…     1 2024-03-26 15:29:20 0.75 
# # ℹ 200 more rows
# # ℹ Use `print(n = ...)` to see more rows

#** here is an example you can run, with files from the internet *
#** sales from january, february and march *
#** id = name of a column where to store file path *
#** don't want to force you to load data from internet unwillingly* 
#** If you want to use it --> un-comment next bit of code *
#** Reminder: select lines, then press Shift + Cmd (Ctrl) + C *

# sales_files <- c(
#   "https://pos.it/r4ds-01-sales",
#   "https://pos.it/r4ds-02-sales",
#   "https://pos.it/r4ds-03-sales"
# )
# read_csv(sales_files, id = "file")


## 7.4 - Writing to a file -------------------------------------------------

# if you don't have a folder called "data", R will propose to create one
write_csv(students, "data/students_2.csv")

#** variable & value correction kept, *
#** but csv format doesn't store info on column type (class)*
#** So if read csv --> lost *

students # see that object students stored it
read_csv("data/students_2.csv") # but not the csv bc plain text file again

#** so csv not best format for storing interim results *
#** prefer rds for use in R (not only for table objects) *
#** or parquet files (arrow package) for files shared across languages *

## RDS format
# I use this between single steps of my analysis
# e.g., one "tidy data" rds file can be fed 
# in several scripts that do different analyses
write_rds(students, "data/students.rds")
read_rds("data/students.rds") # see that all info is preserved

## parquet format 
# faster than RDS and works out of R, but requires arrow package
# in real life, if I kept this script, I would cut-paste the package loading 
# (call to library()) to the top of this script
library(arrow)
write_parquet(students, "data/students.parquet")
read_parquet("data/students.parquet")


## 7.5 - Data entry (manual) -----------------------------------------------

#** Manual entry of simple data frames (tibbles) can be really useful *
#** to test little bits of code or to make a reprex (see below) *
#** the next 2 approaches create the exact same tibble *
#** sometimes row-wise entry is just more convenient * 

# column-wise entry
tibble(
  x = c(1, 2, 5), 
  y = c("h", "m", "g"),
  z = c(0.08, 0.83, 0.60)
)

# row-wise entry
tribble(
  ~x, ~y, ~z,
  1, "h", 0.08,
  2, "m", 0.83,
  5, "g", 0.60
)


# CHAP 8 - WORKFLOW - HELP ------------------------------------------------


## 8.1 - Reprex ------------------------------------------------------------------

# copy next 2 lines in clipboard, then run 3rd line (reprex)
y <- 1:4
mean(y)

reprex::reprex()

#** Viewer panel shows reprex as html preview display *
#** The reprex output is also automatically copied to your clipboard *
#** --> can be pasted in websites like Stack Overflow or GitHub *
#** text formated in Markdown format (see WS4 for more info)*
#*

# check for updates to packages (can sometimes be enough to debug), also to 
# communicate which versions you use when you ask for help
tidyverse_update() # check out message and follow steps if appropriate

#** dput() gives as output the code to reconstitute an object *
#** If you copy-paste the output of dput into an object, you'll have *
#** an object definition to share with a reprex *
#** but test this with big data table (e.g. billboard) --> It's too long ! *
#** better to take the smallest subset of data *
#** that reveals the problem to solve *

# here, tiny tibble, the output of dput is quite small...
students
dput(students)

# I copy-pasted and used styler to restructure the code (see WS2)
students_for_reprex <- structure(list(student_id = c(1, 2, 3, 4, 5, 6), full_name = c(
  "Sunil Huffmann",
  "Barclay Lynn", "Jayendra Lyne", "Leon Rossini", "Chidiegwu Dunkel",
  "Güvenç Attila"
), favourite_food = c(
  "Strawberry yoghurt",
  "French fries", NA, "Anchovies", "Pizza", "Ice cream"
), meal_plan = structure(c(
  2L,
  2L, 1L, 2L, 1L, 2L
), levels = c("Breakfast and lunch", "Lunch only"), class = "factor"), age = c(4, 5, 7, NA, 5, 6)), row.names = c(
  NA,
  -6L
), class = c("tbl_df", "tbl", "data.frame"))
students_for_reprex # see that both objects contain the same info

# copy only last line (call to 
# students_for_reprex) then run reprex --> see error message (definition of 
# students_for_reprex is missing)
# same thing, but copy definition of object + running of object --> works
reprex::reprex()

# test same steps with bigger data table
# See that it works, but nobody will read this and help you on Stack Overflow
mtcars
dput(mtcars)

# paste output from last line into new object "mtcars_for_reprex"
mtcars_for_reprex <- structure(list(
  mpg = c(
    21, 21, 22.8, 21.4, 18.7, 18.1, 14.3,
    24.4, 22.8, 19.2, 17.8, 16.4, 17.3, 15.2, 10.4, 10.4, 14.7, 32.4,
    30.4, 33.9, 21.5, 15.5, 15.2, 13.3, 19.2, 27.3, 26, 30.4, 15.8,
    19.7, 15, 21.4
  ), cyl = c(
    6, 6, 4, 6, 8, 6, 8, 4, 4, 6, 6, 8,
    8, 8, 8, 8, 8, 4, 4, 4, 4, 8, 8, 8, 8, 4, 4, 4, 8, 6, 8, 4
  ),
  disp = c(
    160, 160, 108, 258, 360, 225, 360, 146.7, 140.8,
    167.6, 167.6, 275.8, 275.8, 275.8, 472, 460, 440, 78.7, 75.7,
    71.1, 120.1, 318, 304, 350, 400, 79, 120.3, 95.1, 351, 145,
    301, 121
  ), hp = c(
    110, 110, 93, 110, 175, 105, 245, 62, 95,
    123, 123, 180, 180, 180, 205, 215, 230, 66, 52, 65, 97, 150,
    150, 245, 175, 66, 91, 113, 264, 175, 335, 109
  ), drat = c(
    3.9,
    3.9, 3.85, 3.08, 3.15, 2.76, 3.21, 3.69, 3.92, 3.92, 3.92,
    3.07, 3.07, 3.07, 2.93, 3, 3.23, 4.08, 4.93, 4.22, 3.7, 2.76,
    3.15, 3.73, 3.08, 4.08, 4.43, 3.77, 4.22, 3.62, 3.54, 4.11
  ), wt = c(
    2.62, 2.875, 2.32, 3.215, 3.44, 3.46, 3.57, 3.19,
    3.15, 3.44, 3.44, 4.07, 3.73, 3.78, 5.25, 5.424, 5.345, 2.2,
    1.615, 1.835, 2.465, 3.52, 3.435, 3.84, 3.845, 1.935, 2.14,
    1.513, 3.17, 2.77, 3.57, 2.78
  ), qsec = c(
    16.46, 17.02, 18.61,
    19.44, 17.02, 20.22, 15.84, 20, 22.9, 18.3, 18.9, 17.4, 17.6,
    18, 17.98, 17.82, 17.42, 19.47, 18.52, 19.9, 20.01, 16.87,
    17.3, 15.41, 17.05, 18.9, 16.7, 16.9, 14.5, 15.5, 14.6, 18.6
  ), vs = c(
    0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1
  ), am = c(
    1,
    1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
    0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1
  ), gear = c(
    4, 4, 4, 3,
    3, 3, 3, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 4, 4, 4, 3, 3, 3,
    3, 3, 4, 5, 5, 5, 5, 5, 4
  ), carb = c(
    4, 4, 1, 1, 2, 1, 4,
    2, 2, 4, 4, 3, 3, 3, 4, 4, 4, 1, 2, 1, 1, 2, 2, 4, 2, 1,
    2, 2, 4, 6, 8, 2
  )
), row.names = c(
  "Mazda RX4", "Mazda RX4 Wag",
  "Datsun 710", "Hornet 4 Drive", "Hornet Sportabout", "Valiant",
  "Duster 360", "Merc 240D", "Merc 230", "Merc 280", "Merc 280C",
  "Merc 450SE", "Merc 450SL", "Merc 450SLC", "Cadillac Fleetwood",
  "Lincoln Continental", "Chrysler Imperial", "Fiat 128", "Honda Civic",
  "Toyota Corolla", "Toyota Corona", "Dodge Challenger", "AMC Javelin",
  "Camaro Z28", "Pontiac Firebird", "Fiat X1-9", "Porsche 914-2",
  "Lotus Europa", "Ford Pantera L", "Ferrari Dino", "Maserati Bora",
  "Volvo 142E"
), class = "data.frame")

mtcars_for_reprex
reprex::reprex()



