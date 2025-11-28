library(dplyr)

## Exemple de tableaux Markdown ####

### Données de fruits ====

# Voici un tableau simple de fruits et de prix :

# | fruit  | price  |
# |--------|--------|
# | apple  | 2.05   |
# | pear   | 1.37   |
# | orange | 3.09   |
#
# Ce tableau sera correctement rendu en HTML.

iris %>% 
  head(5)

### Tableau de comparaison ====

# Comparaison des espèces :

# | Species    | Sepal.Length (mean) |
# |------------|---------------------|
# | setosa     | 5.01                |
# | versicolor | 5.94                |
# | virginica  | 6.59                |
#
# Les données ci-dessous permettent de calculer ces moyennes.

iris %>% 
  group_by(Species) %>% 
  summarize(mean_sepal = mean(Sepal.Length))
