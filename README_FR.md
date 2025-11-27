<!-- badges: start -->
[![Statut R check](https://github.com/ddotta/quartify/workflows/R-CMD-check/badge.svg)](https://github.com/ddotta/quartify/actions/workflows/check-release.yaml)
<!-- badges: end -->

# :package: `quartify` <img src="man/figures/hex_quartify.png" width=90 align="right"/>

[English version](README.md)

## Description

`quartify` est un package R qui convertit automatiquement des scripts R en documents Quarto markdown (.qmd).

Le package facilite la transformation de vos analyses R en documents Quarto reproductibles et bien structurés, en préservant la structure logique de votre code grâce aux sections de code RStudio. Il reconnaît la syntaxe standard des sections de code RStudio (`####`, `====`, `----`) pour créer des structures de navigation correctement indentées.

### Cas d'usage typique

Si vous avez un script R fonctionnel qui contient des commentaires, vous pourriez vouloir générer un document Quarto à partir de ce script qui vous permettra de produire automatiquement une documentation HTML affichable. Ceci est particulièrement utile pour :

- **Partager des analyses** : Transformez vos scripts de travail en rapports professionnels sans tout réécrire
- **Documentation** : Générez automatiquement de la documentation à partir de votre code commenté
- **Recherche reproductible** : Créez des analyses auto-documentées où code et explications sont intégrés de manière transparente
- **Revue de code** : Présentez votre code dans un format plus lisible pour les parties prenantes qui préfèrent les documents formatés aux scripts bruts

## Fonctionnalités

- **Conversion automatique** : Transforme vos scripts R (.R) en documents Quarto (.qmd)
- **Support des sections de code RStudio** : Reconnaît les sections de code RStudio (`####`, `====`, `----`) et les convertit en en-têtes markdown appropriés avec les niveaux d'indentation corrects
- **Préservation des commentaires** : Les commentaires réguliers sont convertis en texte explicatif
- **Organisation du code** : Le code R est automatiquement organisé en blocs exécutables
- **En-tête YAML personnalisable** : Possibilité de définir le titre, l'auteur et le format de sortie
- **Table des matières** : Génération automatique d'une table des matières dans le document Quarto avec la profondeur appropriée

## Installation

Vous pouvez installer la version de développement de quartify depuis GitHub :

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Utilisation

### Add-in RStudio (Recommandé)

La façon la plus simple d'utiliser `quartify` est via l'add-in RStudio :

1. Ouvrez votre script R dans RStudio
2. Allez dans le menu **Addins** → **Convert R Script to Quarto**
3. Suivez les instructions pour spécifier le fichier de sortie, le titre et l'auteur
4. Le document Quarto sera créé et optionnellement ouvert

### Exemple basique

```r
library(quartify)

# Convertir un script R en document Quarto
rtoqmd("mon_script.R", "mon_document.qmd")
```

### Personnalisation

```r
# Avec personnalisation du titre et de l'auteur
rtoqmd("mon_script.R", 
       output_file = "mon_document.qmd",
       title = "Mon analyse statistique",
       author = "Votre nom",
       format = "html")
```

### Utilisation du fichier exemple

Un fichier exemple est inclus dans le package pour tester la fonction :

```r
# Localiser le fichier exemple
example_file <- system.file("examples", "example.R", package = "quartify")

# Convertir le fichier exemple
rtoqmd(example_file, "test_output.qmd")
```

## Format du script R source

Pour que la conversion fonctionne correctement, structurez votre script R en utilisant les sections de code RStudio :

```r
library(dplyr)

## Titre 2 ####

### Titre 3 ====

# Début du traitement statistique
# Comptage du nombre d'observations par espèce

iris |> 
  count(Species)

### Titre 3 ====

# Filtrer le data.frame sur l'espèce "setosa"

iris |> 
  filter(Species == "setosa")

#### Titre 4 ----

# Sélectionner la colonne Species

iris %>% 
  # Sélectionner une colonne
  select(Species)
```

### Règles de commentaires

`quartify` reconnaît trois types de lignes dans votre script R :

#### 1. Sections de code (En-têtes)

Les sections de code RStudio deviennent des en-têtes markdown. **Critique** : les symboles de fin doivent contenir au moins 4 caractères :

- `## Titre ####` → En-tête de niveau 2 (au moins 4 `#` à la fin)
- `### Titre ====` → En-tête de niveau 3 (au moins 4 `=` à la fin)
- `#### Titre ----` → En-tête de niveau 4 (au moins 4 `-` à la fin)

#### 2. Commentaires réguliers (Texte)

Les commentaires simples avec `#` **en début de ligne** deviennent du texte explicatif :

```r
# Ceci est un commentaire autonome
# Il devient du texte simple dans le document Quarto
```

#### 3. Lignes de code

Les lignes non commentées deviennent des chunks de code R exécutables :

```r
iris |> filter(Species == "setosa")
```

#### 4. Commentaires en ligne (À l'intérieur du code)

Les commentaires **à l'intérieur des blocs de code** sont préservés dans le chunk de code R :

```r
iris %>% 
  # Ce commentaire reste dans le bloc de code
  select(Species)
```

**Règles importantes :**

- Toujours inclure un espace après `#` pour les commentaires
- Les en-têtes de section DOIVENT avoir au moins 4 symboles de fin
- **Commentaires autonomes** (en début de ligne) → deviennent du texte en dehors des blocs de code
- **Commentaires en ligne** (dans le code) → restent à l'intérieur des blocs de code
- Les lignes de code consécutives sont regroupées dans le même bloc
- Les lignes vides entre les blocs sont ignorées

Ceci suit la [convention des sections de code RStudio](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html) qui fournit une indentation appropriée dans la navigation du plan du document RStudio.

## Structure du document Quarto généré

Le document .qmd généré contient :

- Un en-tête YAML complet avec configuration de la table des matières
- Des en-têtes correctement structurés à partir des sections de code RStudio
- Des explications textuelles à partir de vos commentaires réguliers
- Des blocs de code R formatés et exécutables

## Exemple de sortie

À partir du script R exemple montré ci-dessus, `quartify` génère :

```markdown
---
title: "Mon titre"
author: "Damien Dotta"
format: html
toc: true
toc-title: Sommaire
toc-depth: 4  
toc-location: left
output: 
  html_document:
  number_sections: TRUE
  output-file: example.html
---

```{.r}
library(dplyr)
```

## Titre 2

### Titre 3

Début du traitement statistique
Comptage du nombre d'observations par espèce

```{.r}
iris |> 
  count(Species)
```

### Titre 3

Filtrer le data.frame sur l'espèce "setosa"

```{.r}
iris |> 
  filter(Species == "setosa")
```

#### Titre 4

Sélectionner la colonne Species

```{.r}
iris %>% 
  # Sélectionner une colonne
  select(Species)
```
```

Le document généré inclut :
- Une table des matières navigable avec hiérarchie appropriée
- Du code organisé en blocs réutilisables
- Des commentaires en ligne préservés dans les blocs de code
- Une documentation claire entre les sections de code
- **Chunks de code non exécutables** (syntaxe `{.r}`) pour une documentation statique
- Prêt pour HTML, PDF ou d'autres formats supportés par Quarto

**Note :** Les chunks de code sont intentionnellement non exécutables pour fournir une documentation statique de votre script R sans exécuter le code lors du rendu.

## Licence

MIT
