# Title : Analyse des données Iris
#
# Auteur : Jean Dupont
#
# Date : 2025-11-28
#
# Objectif : Ce script analyse le jeu de données iris pour explorer les différences entre les espèces
#

library(dplyr)

## Chargement des données ####

# Le jeu de données iris est inclus dans R

head(iris)

### Statistiques descriptives ====

# Calculer la moyenne de la longueur des sépales par espèce

iris |> 
  group_by(Species) |>
  summarize(mean_sepal_length = mean(Sepal.Length))

### Visualisation ====

# Créer un résumé complet

iris |> 
  group_by(Species) |>
  summarize(
    count = n(),
    mean_sepal = mean(Sepal.Length),
    mean_petal = mean(Petal.Length)
  )
