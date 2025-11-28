# 📦 quartify

[![Statut R
check](https://github.com/ddotta/quartify/workflows/R-CMD-check/badge.svg)](https://github.com/ddotta/quartify/actions/workflows/check-release.yaml)
[![CodeFactor](https://www.codefactor.io/repository/github/ddotta/quartify/badge)](https://www.codefactor.io/repository/github/ddotta/quartify)

🇬🇧 [English version](https://ddotta.github.io/quartify/index.html)

## Description

`quartify` est un package R qui convertit automatiquement des scripts R
en documents Quarto markdown (.qmd).

Le package facilite la transformation de vos analyses R en documents
Quarto reproductibles et bien structurés, en préservant la structure
logique de votre code grâce aux [sections de code RStudio](NA). Il
reconnaît la syntaxe standard des sections de code RStudio (`####`,
`====`, `----`) pour créer des structures de navigation correctement
indentées.

### Cas d’usage

Si vous avez un script R fonctionnel qui contient des commentaires, vous
pourriez vouloir générer un document Quarto à partir de ce script qui
vous permettra de produire automatiquement une documentation HTML
affichable. Ceci est particulièrement utile pour :

- **Documentation** : Générez automatiquement de la documentation à
  partir de votre code commenté
- **Revue de code** : Présentez votre code dans un format plus lisible
  pour les parties prenantes qui préfèrent les documents formatés aux
  scripts bruts

## Fonctionnalités

- **Conversion automatique** : Transforme vos scripts R (.R) en
  documents Quarto (.qmd)
- **Support des sections de code RStudio** : Reconnaît les sections de
  code RStudio (`####`, `====`, `----`) et les convertit en titres
  markdown appropriés avec les niveaux d’indentation corrects
- **Préservation des commentaires** : Les commentaires réguliers sont
  convertis en texte explicatif
- **Organisation du code** : Le code R est automatiquement organisé en
  blocs exécutables
- **En-tête YAML personnalisable** : Possibilité de définir le titre,
  l’auteur et d’autres paramètres  
- - **Table des matières** : Génération automatique d’une table des
    matières dans le document Quarto avec la profondeur appropriée
- **Génération HTML automatique** : Génère optionnellement le fichier
  HTML à partir du .qmd et l’ouvre dans le navigateur (désactivé par
  défaut)

## Installation

Vous pouvez installer la version de développement de quartify depuis
GitHub :

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Utilisation

### Add-in RStudio

La façon la plus simple d’utiliser `quartify` est via l’add-in RStudio
avec son interface Shiny interactive :

1.  Ouvrez votre script R dans RStudio
2.  Allez dans le menu **Addins** → **Convert R Script to Quarto**
3.  Une fenêtre de dialogue apparaîtra avec :
    - Boutons de sélection de langue **EN/FR** en haut à droite
    - Formulaire pour spécifier :
      - Le chemin du fichier de sortie
      - Le titre du document et le nom de l’auteur
      - Les options de génération
4.  Cliquez sur **GO** pour convertir votre script (ou ↩︎ pour annuler)

L’interface s’adapte à votre choix de langue, affichant tous les
libellés en anglais ou en français. Le format de sortie est toujours
HTML.

### Exemple basique

``` r
library(quartify)

# Convertir un script R en document Quarto et générer le HTML
rtoqmd("mon_script.R", "mon_document.qmd")

# Convertir seulement, sans générer le HTML
rtoqmd("mon_script.R", "mon_document.qmd", render = FALSE)
```

### Personnalisation

``` r
# Avec personnalisation du titre et de l'auteur
rtoqmd("mon_script.R", 
       output_file = "mon_document.qmd",
       title = "Mon analyse statistique",
       author = "Votre nom",
       format = "html",
       render = TRUE,            # G\u00e9n\u00e9rer le HTML 
       open_html = TRUE,         # Ouvrir le HTML dans le navigateur
       number_sections = TRUE)   # Num\u00e9roter les sections automatiquement
```

### Utilisation du fichier exemple

Un fichier exemple est inclus dans le package pour tester la fonction :

``` r
# Localiser le fichier exemple
example_file <- system.file("examples", "example.R", package = "quartify")

# Convertir le fichier exemple
rtoqmd(example_file, "test_output.qmd")
```

## Format du script R source

Pour que la conversion fonctionne correctement, structurez votre script
R en utilisant les sections de code RStudio :

``` r
# Titre : Analyse des données Iris
#
# Auteur : Jean Dupont
#
# Date : 2025-11-28
#
# Description : Explorer les différences entre les espèces d'iris
#

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

#### 0. Métadonnées du document (Optionnel)

Vous pouvez définir les métadonnées directement dans votre script R en
utilisant des commentaires spéciaux au début :

- **Titre** : `# Title : Mon titre` ou `# Titre : Mon titre`
- **Auteur** : `# Author : Mon nom` ou `# Auteur : Mon nom`
- **Date** : `# Date : AAAA-MM-JJ`
- **Description** : `# Description : Description de votre script`

**💡 Snippet RStudio :** Créez un snippet pour insérer rapidement les
métadonnées (Outils \> Modifier les snippets de code \> R) :

    snippet header
        # Titre : ${1}
        #
        # Auteur : ${2}
        #
        # Date : ${3}
        #
        # Description : ${4}
        #

Tapez `header` + `Tab` dans votre script pour insérer la structure de
métadonnées.

**Comportement :** - Les métadonnées trouvées dans le script
**remplacent** les paramètres de la fonction - Les lignes de métadonnées
sont **retirées** du corps du document (uniquement dans le YAML) - Si
aucune métadonnée dans le script, les paramètres de la fonction sont
utilisés

`quartify` reconnaît trois types de lignes dans votre script R :

#### 1. Sections de code (En-têtes)

Les sections de code RStudio deviennent des en-têtes markdown.
**Critique** : les symboles de fin doivent contenir au moins 4
caractères :

- `## Titre ----` → En-tête de niveau 2 (au moins 4 `#`, `=` ou `-` à la
  fin)
- `### Titre ----` → En-tête de niveau 3 (au moins 4 `#`, `=` ou `-` à
  la fin)
- `#### Titre ----` → En-tête de niveau 4 (au moins 4 `#`, `=` ou `-` à
  la fin)

**Note :** Vous pouvez utiliser `#`, `=`, ou `-` indifféremment comme
symboles de fin (ex : `## Titre ====` ou `### Titre ----`
fonctionneront).

#### 2. Commentaires réguliers (Texte)

Les commentaires simples avec `#` **en début de ligne** deviennent du
texte explicatif :

``` r
# Ceci est un commentaire autonome
# Il devient du texte simple dans le document Quarto
```

**Astuce :** Utilisez le [raccourci
Commenter/Décommenter](https://docs.posit.co/ide/user/ide/guide/productivity/text-editor.html#commentuncomment)
de RStudio (`Ctrl+Shift+C` sur Windows/Linux ou `Cmd+Shift+C` sur Mac)
pour ajouter ou retirer rapidement des commentaires.

#### 3. Lignes de code

Les lignes non commentées deviennent des chunks de code R exécutables :

``` r
iris |> filter(Species == "setosa")
```

#### 4. Commentaires en ligne (À l’intérieur du code)

Les commentaires **à l’intérieur des blocs de code** sont préservés dans
le chunk de code R :

``` r
iris %>% 
  # Ce commentaire reste dans le bloc de code
  select(Species)
```

**Règles importantes :**

- Toujours inclure un espace après `#` pour les commentaires
- Les en-têtes de section DOIVENT avoir au moins 4 symboles de fin
- **Les commentaires avec un `#` en début de ligne** → deviennent du
  texte en dehors des blocs de code
- **Les commentaires dans le code** → restent à l’intérieur des blocs de
  code
- Les lignes de code consécutives sont regroupées dans le même bloc
- Les lignes vides entre les blocs sont ignorées

Ceci suit la [convention des sections de code
RStudio](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html)
qui fournit une indentation appropriée dans la navigation du plan du
document RStudio.

## Sortie et documentation

Le document .qmd généré contient :  
- Un en-tête YAML complet avec configuration de la table des matières  
- Des titres correctement structurés à partir des sections de code
RStudio  
- Des explications textuelles à partir de vos commentaires  
- **Chunks de code non exécutables** pour une documentation statique

📝 **Pour un exemple complet de la sortie générée**, consultez la
[vignette
Démarrage](https://ddotta.github.io/quartify/articles/getting-started_FR.html#sortie-g%C3%A9n%C3%A9r%C3%A9e)

## Licence

MIT
