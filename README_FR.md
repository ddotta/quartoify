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

### Pourquoi quartify plutôt que knitr::spin() ?

Alors que [`knitr::spin()`](https://yihui.org/knitr/demo/stitch/)
convertit les scripts R en R Markdown (.Rmd), `quartify` les convertit
en **Quarto** (.qmd), vous donnant accès à toutes les fonctionnalités
modernes de Quarto :

- ✅ **Système de Publication Moderne** : Exploitez les fonctionnalités
  avancées de Quarto (callouts, tabsets, références croisées, etc.)
- ✅ **Meilleurs Thèmes** : Accès à plus de 25 thèmes HTML modernes avec
  un style cohérent
- ✅ **Interactivité Améliorée** : Support natif pour Observable JS,
  Shiny, et widgets interactifs
- ✅ **Publication Scientifique** : Support intégré pour citations,
  bibliographies, et formatage académique
- ✅ **Diagrammes Mermaid** : Créez des organigrammes et diagrammes
  directement dans votre documentation
- ✅ **Pérennité** : Quarto est le successeur de nouvelle génération de
  R Markdown, activement développé par Posit

**Différence Clé** :
[`knitr::spin()`](https://rdrr.io/pkg/knitr/man/spin.html) utilise `#'`
pour le texte markdown et `#+` pour les options de chunk, tandis que
`quartify` utilise des commentaires R naturels (`#` pour le texte,
sections RStudio pour les titres) rendant vos scripts R plus lisibles et
maintenables même avant conversion.

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
- **Table des matières** : Génération automatique d’une table des
  matières dans le document Quarto avec la profondeur appropriée
- **Génération HTML automatique** : Génère optionnellement le fichier
  HTML à partir du .qmd et l’ouvre dans le navigateur (désactivé par
  défaut)
- **Thèmes personnalisables** : Choisissez parmi 25+ thèmes Quarto pour
  personnaliser l’apparence de vos documents HTML
- **Numéros de ligne source** : Affichage optionnel des numéros de ligne
  originaux du script R dans les chunks de code pour la traçabilité

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
    - Boutons de sélection de langue **EN/FR** (détection automatique de
      la langue de votre session R)
    - Formulaire pour spécifier :
      - Fichier d’entrée (avec explorateur de fichiers)
      - Le chemin du fichier de sortie (avec explorateur de fichiers)
      - Le titre du document et le nom de l’auteur
      - Le thème HTML (25+ thèmes disponibles)
      - Les options de génération
4.  Cliquez sur **GO** pour convertir votre script (ou ↩︎ pour annuler)

L’interface détecte automatiquement les préférences de langue de votre
session R et affiche tous les libellés en anglais ou en français en
conséquence. Vous pouvez changer la langue à tout moment avec les
boutons EN/FR. Le format de sortie est toujours HTML.

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
       theme = "cosmo",          # Thème Quarto (optionnel)
       render = TRUE,            # Générer le HTML 
       open_html = TRUE,         # Ouvrir le HTML dans le navigateur
       number_sections = TRUE)   # Numéroter les sections automatiquement
```

### Utilisation du fichier exemple

Un fichier exemple est inclus dans le package pour tester la fonction :

``` r
# Localiser le fichier exemple
example_file <- system.file("examples", "example.R", package = "quartify")

# Convertir le fichier exemple
rtoqmd(example_file, "test_output.qmd")
```

### Conversion par lots

Convertir tous les scripts R d’un répertoire (y compris les
sous-répertoires) :

``` r
# Convertir tous les scripts R d'un répertoire
rtoqmd_dir("chemin/vers/scripts")

# Convertir et générer tous les scripts
rtoqmd_dir("chemin/vers/scripts", render = TRUE)

# Avec paramètres personnalisés
rtoqmd_dir("chemin/vers/scripts", 
           author = "Équipe Data",
           exclude_pattern = "test_.*\\.R$")
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

> **📝 Note :** Le champ `Description` peut s’étendre sur plusieurs
> lignes. Pour continuer la description, commencez la ligne suivante par
> `#` suivi d’au moins un espace. Les lignes de continuation sont
> automatiquement concaténées. Exemple :
>
> ``` r
> # Description : Cette analyse explore les différences entre les espèces d'iris
> # en utilisant diverses méthodes statistiques et techniques de visualisation
> # pour identifier les patterns et corrélations.
> ```

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

Les commentaires simples avec `#` **en début de ligne (sans espace
avant)** deviennent du texte explicatif :

``` r
# Ceci est un commentaire autonome
# Il devient du texte simple dans le document Quarto
```

> **⚠️ Important :** Pour qu’un commentaire soit converti en texte, la
> ligne doit commencer par `#` **sans espace avant**. Les commentaires
> indentés (avec des espaces avant `#`) restent dans le code.

> **💡 Astuce :** Pour **diviser un long chunk en plusieurs parties**,
> insérez un **commentaire en début de ligne** (sans espace avant `#`)
> entre deux blocs de code. Ce commentaire sera converti en texte et
> créera naturellement deux chunks séparés.

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

#### 5. Callouts (Encadrés)

Les callouts sont des blocs spéciaux qui mettent en évidence des
informations importantes. Cinq types sont supportés : `note`, `tip`,
`warning`, `caution`, `important`.

**Syntaxe dans le script R :**

``` r
# callout-note - Note importante
# Ceci est le contenu du callout.
# Il peut s'étendre sur plusieurs lignes.

# Une ligne vide ou du code termine le callout
x <- 1
```

**Se convertit en Quarto :**

``` markdown
::: {.callout-note title="Note importante"}
Ceci est le contenu du callout.
Il peut s'étendre sur plusieurs lignes.
:::
```

**Sans titre :**

``` r
# callout-tip
# Ceci est un conseil sans titre.
```

Les callouts se terminent lorsqu’on rencontre une ligne vide, du code,
ou une autre section.

#### 6. Diagrammes Mermaid

Créez des organigrammes, des diagrammes de séquence et d’autres
visualisations avec la syntaxe Mermaid, rendus directement dans la
sortie HTML.

**Syntaxe dans le script R :**

``` r
#| mermaid
#| eval: true
flowchart LR
  A[Démarrer] --> B{Décision}
  B -->|Oui| C[Résultat 1]
  B -->|Non| D[Résultat 2]
```

**Se convertit en Quarto :**

``` markdown
```{mermaid}
%%| eval: true
flowchart LR
  A[Démarrer] --> B{Décision}
  B -->|Oui| C[Résultat 1]
  B -->|Non| D[Résultat 2]
```

    Pour plus d'informations : [Documentation Mermaid](https://mermaid.js.org/)

    #### 7. Tabsets (Onglets)

    Organisez du contenu connexe dans des onglets interactifs pour afficher des vues alternatives ou des analyses groupées.

    **Syntaxe dans le script R :**

    ```r
    # tabset
    # tab - Statistiques résumées
    # Voici les statistiques pour iris :
    summary(iris)

    # tab - Structure
    # Structure des données :
    str(iris)

    # tab - Premières lignes
    # Premières observations :
    head(iris)

**Se convertit en Quarto :**

``` markdown
::: {.panel-tabset}

## Statistiques résumées

Voici les statistiques pour iris :

```{r}
summary(iris)
```

## Structure

Structure des données :

`{r} str(iris)`

## Premières lignes

Premières observations :

`{r} head(iris)`

:::

    Pour plus d'informations : [Quarto Tabsets](https://quarto.org/docs/interactive/layout.html#tabset-panel)

    **Règles importantes :**

    - Toujours inclure un espace après `#` pour les commentaires
    - Les en-têtes de section DOIVENT avoir au moins 4 symboles de fin
    - **Les commentaires avec un `#` en début de ligne** → deviennent du texte en dehors des blocs de code
    - **Les commentaires dans le code** → restent à l'intérieur des blocs de code
    - **Callouts** → `# callout-TYPE` ou `# callout-TYPE - Titre`
    - **Mermaid** → `#| mermaid` suivi du contenu du diagramme
    - **Tabsets** → `# tabset` puis `# tab - Titre` pour chaque onglet
    - Les lignes de code consécutives sont regroupées dans le même bloc
    - Les lignes vides entre les blocs sont ignorées

    Ceci suit la [convention des sections de code RStudio](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html) qui fournit une indentation appropriée dans la navigation du plan du document RStudio.

    ## Thèmes Quarto

    Personnalisez l'apparence de vos documents HTML avec les thèmes Quarto. Le package supporte tous les thèmes Bootswatch disponibles :

    **Thèmes clairs** : cosmo, flatly, journal, litera, lumen, lux, materia, minty, morph, pulse, quartz, sandstone, simplex, sketchy, spacelab, united, vapor, yeti, zephyr

    **Thèmes sombres** : darkly, cyborg, slate, solar, superhero

    Exemple :

    ```r
    # Utiliser le thème "flatly"
    rtoqmd("mon_script.R", theme = "flatly")

    # Utiliser le thème sombre "darkly"
    rtoqmd("mon_script.R", theme = "darkly")

Pour plus d’informations sur les thèmes, consultez la [documentation
Quarto](https://quarto.org/docs/output-formats/html-themes.html).

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

## Intégration CI/CD

Utilisez `quartify` dans vos pipelines CI/CD pour générer
automatiquement la documentation :

**GitHub Actions** (`.github/workflows/generate-docs.yml`) :

``` yaml
- name: Générer la documentation
  run: |
    library(quartify)
    rtoqmd_dir("scripts/", render = TRUE, author = "Équipe Data")
  shell: Rscript {0}

- uses: actions/upload-artifact@v4
  with:
    name: documentation
    path: |
      scripts/**/*.qmd
      scripts/**/*.html
```

**GitLab CI** (`.gitlab-ci.yml`) :

``` yaml
generate-docs:
  image: rocker/r-ver:4.5.1
  script:
    - R -e "quartify::rtoqmd_dir('scripts/', render = TRUE, author = 'Équipe Data')"
  artifacts:
    paths:
      - scripts/**/*.qmd
      - scripts/**/*.html
```

📘 **Guide complet CI/CD** avec exemples détaillés : [Intégration
CI/CD](https://ddotta.github.io/quartify/articles/getting-started_FR.html#int%C3%A9gration-cicd)

## Licence

MIT
