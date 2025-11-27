# Démarrage avec quartify

🇬🇧 **[English version
available](https://ddotta.github.io/quartify/articles/getting-started.md)**
/ **Version anglaise disponible**

## Introduction

`quartify` est un package R qui convertit automatiquement des scripts R
en documents Quarto markdown (.qmd). Le package reconnaît les sections
de code RStudio pour créer des documents correctement structurés avec
navigation. Cette vignette vous guidera à travers l’utilisation basique
et les fonctionnalités du package.

## Installation

Vous pouvez installer la version de développement de quartify depuis
GitHub :

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Utilisation basique

La fonction principale du package est
[`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md).
Voici un exemple simple :

``` r
library(quartify)

# Convertir un script R en document Quarto et générer le HTML
rtoqmd("mon_script.R", "mon_document.qmd")

# Convertir seulement, sans générer le HTML
rtoqmd("mon_script.R", "mon_document.qmd", render = FALSE)
```

Par défaut,
[`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md) va
: 1. Créer le fichier .qmd 2. Le générer en HTML avec Quarto 3. Ouvrir
le fichier HTML dans votre navigateur par défaut

## Structurer votre script R

Pour une conversion optimale, vous devez suivre des règles de
commentaires spécifiques dans votre script R. `quartify` reconnaît trois
types de lignes :

### 1. Sections de code (En-têtes)

Utilisez la syntaxe des sections de code RStudio pour créer des en-têtes
à différents niveaux. Ces sections DOIVENT suivre ce modèle exact :

- **Niveau 2** : `## Titre ####` (au moins 4 symboles `#` à la fin)
- **Niveau 3** : `### Titre ====` (au moins 4 symboles `=` à la fin)
- **Niveau 4** : `#### Titre ----` (au moins 4 symboles `-` à la fin)

**Règles importantes :**

- Il doit y avoir au moins un espace entre le texte du titre et les
  symboles de fin
- Les symboles de fin (`####`, `====`, `----`) doivent contenir au moins
  4 caractères
- Ceci suit la [convention des sections de code
  RStudio](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html)

**Exemple :**

``` r
## Chargement des données ####

### Import CSV ====

#### Vérification valeurs manquantes ----
```

### 2. Commentaires réguliers (Texte)

Les commentaires simples avec `#` deviennent du texte explicatif dans le
document Quarto :

``` r
# Ceci est un commentaire régulier
# Il apparaîtra comme texte simple dans la sortie
# Utilisez-les pour expliquer ce que fait votre code
```

**Règles :**

- Commencez par un seul `#` suivi d’un espace
- Plusieurs lignes de commentaires consécutives deviendront chacune un
  paragraphe séparé
- Les lignes de commentaires vides sont ignorées

### 3. Lignes de code

Toute ligne qui N’EST PAS un commentaire devient du code R exécutable :

``` r
library(dplyr)

iris |> 
  filter(Species == "setosa") |>
  summarize(mean_length = mean(Sepal.Length))
```

**Règles :**

- Les lignes de code consécutives sont regroupées dans un seul chunk de
  code
- Les lignes vides entre les blocs de code sont ignorées
- Les blocs de code sont séparés par des commentaires ou des en-têtes de
  section

**Important :** Vous pouvez inclure des commentaires À L’INTÉRIEUR des
blocs de code. Ces commentaires seront préservés dans le chunk de code R
:

``` r
iris %>% 
  # Sélectionner une colonne
  select(Species)
```

Ceci sera rendu comme :

```` markdown
```{.r}
iris %>% 
  # Sélectionner une colonne
  select(Species)
```
````

La différence : - **Commentaires en début de ligne** (autonomes) →
deviennent du texte EN DEHORS des blocs de code - **Commentaires dans le
code** (indentés ou partie d’un pipeline) → restent À L’INTÉRIEUR des
blocs de code

## Exemple complet : example.R

Voici le script R exemple complet inclus dans le package :

``` r
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
```

Ce script démontre :

1.  **Code sans section** :
    [`library(dplyr)`](https://dplyr.tidyverse.org) devient un chunk de
    code
2.  **En-têtes de section** : `## Title 2 ####`, `### Title 3 ====`,
    `#### Title 4 ----`
3.  **Commentaires autonomes** : `# Select column Species` devient du
    texte lisible
4.  **Commentaires en ligne** : `# Select a column` reste dans le bloc
    de code
5.  **Blocs de code** : Séparés par des commentaires autonomes ou des
    sections

## Options de personnalisation

Vous pouvez personnaliser le document de sortie avec plusieurs
paramètres :

``` r
rtoqmd(
  input_file = "mon_script.R",
  output_file = "mon_document.qmd",
  title = "Mon rapport d'analyse",
  author = "Votre nom",
  format = "html"
)
```

### Paramètres

- `input_file` : Chemin vers votre script R
- `output_file` : Chemin pour le document Quarto de sortie (optionnel)
- `title` : Titre du document (par défaut : “My title”)
- `author` : Nom de l’auteur (par défaut : “Damien Dotta”)
- `format` : Format de sortie (par défaut : “html”)
- `render` : Générer le HTML à partir du .qmd (par défaut : TRUE)
- `open_html` : Ouvrir le HTML dans le navigateur (par défaut : TRUE)

## Conversion de l’exemple

Pour convertir le script exemple ci-dessus :

``` r
# Obtenir le chemin du fichier exemple
example_file <- system.file("examples", "example.R", package = "quartify")

# Le convertir
rtoqmd(
  input_file = example_file,
  output_file = "analyse_iris.qmd",
  title = "Analyse du jeu de données Iris",
  author = "Analyste de données"
)
```

### Sortie générée

Ceci produit le document Quarto suivant :

``` markdown
---
title: "Analyse du jeu de données Iris"
author: "Analyste de données"
format: html
toc: true
toc-title: Sommaire
toc-depth: 4  
toc-location: left
output: 
  html_document:
  number_sections: TRUE
  output-file: analyse_iris.html
---

```{.r}
library(dplyr)
```

## Title 2

### Title 3

Start of statistical processing

Counting the number of observations by species

``` r
iris |> 
  count(Species)
```

### Title 3

Filter the data.frame on Species “setosa”

``` r
iris |> 
  filter(Species == "setosa")
```

#### Title 4

Select column Species

``` r
iris %>% 
  # Select a column
  select(Species)
```

    Notez comment :

    - Chaque section de code devient un en-tête markdown approprié
    - Les commentaires autonomes deviennent des paragraphes de texte lisible
    - Les commentaires en ligne (dans le code) sont préservés dans les blocs de code
    - Les blocs de code sont correctement formatés avec coloration syntaxique
    - La table des matières montrera la structure hiérarchique

    **Note importante sur les chunks de code :** Les chunks de code générés utilisent la syntaxe `{.r}`, qui crée des blocs de code **non exécutables**. C'est intentionnel - `quartify` est conçu pour créer une **documentation statique** de votre script R, pas un notebook exécutable. Le code est affiché avec coloration syntaxique à des fins de lecture et de documentation, mais ne sera pas exécuté lors du rendu du document Quarto. Cette approche est idéale pour :

    - Documenter des scripts existants sans modifier leur exécution
    - Créer des références statiques de votre code
    - Partager des exemples de code que les lecteurs peuvent copier et exécuter dans leur propre environnement
    - S'assurer que le processus de documentation n'interfère pas avec le comportement de votre script original

    ## Rendu de la sortie

    ### Rendu automatique (Recommandé)

    Par défaut, `rtoqmd()` génère automatiquement votre document Quarto en HTML :


    ``` r
    # Ceci créera les fichiers .qmd et .html, puis ouvrira le HTML
    rtoqmd(example_file, "analyse_iris.qmd")

La fonction va : 1. Vérifier si Quarto est installé 2. Générer le
fichier .qmd en HTML 3. Ouvrir le fichier HTML dans votre navigateur par
défaut

Si vous ne voulez pas de rendu automatique :

``` r
rtoqmd(example_file, "analyse_iris.qmd", render = FALSE)
```

### Rendu manuel

Vous pouvez également générer manuellement en utilisant Quarto :

``` bash
quarto render analyse_iris.qmd
```

Ou depuis R :

``` r
quarto::quarto_render("analyse_iris.qmd")
```

**Note :** Quarto doit être installé sur votre système. Téléchargez-le
depuis [quarto.org](https://quarto.org/docs/get-started/).

## Cas d’usage

`quartify` est particulièrement utile pour :

1.  **Documentation** : Transformer des scripts de travail en
    documentation professionnelle
2.  **Partage d’analyses** : Créer des rapports lisibles à partir de
    code existant
3.  **Recherche reproductible** : Combiner code et narration de manière
    transparente
4.  **Revue de code** : Présenter le code dans un format plus accessible

## Résumé des règles de commentaires

| Type                     | Syntaxe             | Résultat              | Exemple                      |
|--------------------------|---------------------|-----------------------|------------------------------|
| **En-tête niveau 2**     | `## Titre ####`     | Markdown `## Titre`   | `## Analyse de données ####` |
| **En-tête niveau 3**     | `### Titre ====`    | Markdown `### Titre`  | `### Prétraitement ====`     |
| **En-tête niveau 4**     | `#### Titre ----`   | Markdown `#### Titre` | `#### Supprimer NA ----`     |
| **Commentaire autonome** | `# Texte`           | Paragraphe de texte   | `# Ceci filtre les données`  |
| **Code**                 | Sans préfixe `#`    | Chunk de code R       | `iris %>% filter(...)`       |
| **Commentaire en ligne** | `# Texte` dans code | Reste dans chunk      | `iris %>% # commentaire`     |

**Règles critiques pour éviter les erreurs :**

1.  **Espacement** : Toujours inclure un espace après `#` pour les
    commentaires et en-têtes de section
2.  **Symboles de fin** : Les en-têtes de section DOIVENT avoir au moins
    4 symboles de fin (`####`, `====`, ou `----`)
3.  **Pas de mélange** : Ne mélangez pas la syntaxe des sections (ex :
    n’utilisez pas `## Titre ====`)
4.  **Commentaires Roxygen** : Les lignes commençant par `#'` sont
    ignorées (pour développement de packages)
5.  **Contexte du commentaire** : Les commentaires en début de ligne
    deviennent du texte ; les commentaires dans le code restent dans les
    blocs de code

## Conseils et bonnes pratiques

1.  **Commencez par la structure** : Définissez d’abord vos en-têtes de
    section pour créer le plan du document
2.  **Utilisez des niveaux cohérents** : Suivez une hiérarchie logique
    (2 → 3 → 4, ne sautez pas de niveaux)
3.  **Ajoutez du texte explicatif** : Utilisez des commentaires
    réguliers pour expliquer ce que fait votre code
4.  **Regroupez le code connexe** : Gardez les opérations liées ensemble
    ; elles seront regroupées dans le même bloc de code
5.  **Testez de manière incrémentale** : Commencez avec un petit script
    pour voir comment fonctionne la conversion
6.  **Naviguez facilement** : Dans RStudio, utilisez le plan du document
    (Ctrl+Shift+O) pour voir votre structure
7.  **Commentez généreusement** : Plus de commentaires = meilleure
    documentation dans le document Quarto final

## Conclusion

`quartify` facilite la transformation de vos scripts R en documents
Quarto professionnels sans reformatage manuel. En suivant les
conventions des sections de code RStudio, vous pouvez automatiquement
générer une documentation bien structurée et reproductible à partir de
votre code existant avec une hiérarchie de navigation appropriée.
