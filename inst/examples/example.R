# Titre : Iris analysis
#
# Auteur : Damien Dotta
#
# Date : November 28, 2025
#
# Description : Example file for package quartify


library(dplyr)

## Title 2 ####

### Title 3 ====

# Start of statistical processing
# Counting the number of observations by species

iris |> 
  count(Species)

### Title 3 ====

# Filter the data.frame on Species "setosa"

iris |> 
  filter(Species == "setosa")

#### Title 4 ----

# Select column Species

iris %>% 
  # Select a column
  select(Species)

## Markdown tables in comments ####

# You can include markdown tables in comments:

# | Species    | Count |
# |------------|-------|
# | setosa     | 50    |
# | versicolor | 50    |
# | virginica  | 50    |

iris %>%
  count(Species)
