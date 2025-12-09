<!-- badges: start -->
[![Statut R check](https://github.com/ddotta/quartify/workflows/R-CMD-check/badge.svg)](https://github.com/ddotta/quartify/actions/workflows/check-release.yaml)
[![CodeFactor](https://www.codefactor.io/repository/github/ddotta/quartify/badge)](https://www.codefactor.io/repository/github/ddotta/quartify)
<!-- badges: end -->

# :package: `quartify` <img src="man/figures/hex_quartify.png" width=90 align="right"/>

🇬🇧 [English version](https://ddotta.github.io/quartify/index.html)

## Description

`quartify` est un package R qui convertit automatiquement des scripts R en documents Quarto markdown (.qmd).

Le package facilite la transformation de vos analyses R en documents Quarto reproductibles et bien structurés, en préservant la structure logique de votre code grâce aux [sections de code RStudio]((https://docs.posit.co/ide/user/ide/guide/code/code-sections.html)). Il reconnaît la syntaxe standard des sections de code RStudio (`####`, `====`, `----`) pour créer des structures de navigation correctement indentées.

### Différences avec knitr::spin() et les render-scripts de Quarto

[knitr::spin()](https://yihui.org/knitr/demo/stitch/#spin) et la fonctionnalité [render-scripts de Quarto](https://quarto.org/docs/computations/render-scripts.html) permettent déjà de rendre des scripts R, mais reposent tous deux sur l'insertion de structure Markdown directement dans les commentaires (`#'`, titres, options de chunks, etc.).

**quartify adopte une philosophie différente** : il n'impose aucune syntaxe Markdown dans les commentaires et fonctionne sur des scripts R totalement standards. Les commentaires restent des commentaires, le code reste du code.

L'objectif est de conserver des scripts propres et habituels, tout en les rendant convertibles en .qmd — et, lorsque plusieurs scripts sont sélectionnés, de pouvoir les assembler automatiquement en un book Quarto structuré sans aucune réécriture du code source.

### Cas d'usage

Si vous avez un script R fonctionnel qui contient des commentaires, vous pourriez vouloir générer un document Quarto à partir de ce script qui vous permettra de produire automatiquement une documentation HTML affichable. Ceci est particulièrement utile pour :

- **Documentation** : Générez automatiquement de la documentation à partir de votre code commenté
- **Revue de code** : Présentez votre code dans un format plus lisible pour les parties prenantes qui préfèrent les documents formatés aux scripts bruts

## Fonctionnalités

- **Conversion automatique** : Transforme vos scripts R (.R) en documents Quarto (.qmd)
- **Conversion de fichiers multiples** : Convertir des fichiers individuels, plusieurs fichiers, ou des répertoires entiers en une seule fois
- **Création de Quarto Books** : Génération automatique de livres Quarto navigables à partir de répertoires (activé par défaut)
- **Support des sections de code RStudio** : Reconnaît les sections de code RStudio (`####`, `====`, `----`) et les convertit en titres markdown appropriés avec les niveaux d'indentation corrects
- **Préservation des commentaires** : Les commentaires réguliers sont convertis en texte explicatif
- **Organisation du code** : Le code R est automatiquement organisé en blocs exécutables
- **En-tête YAML personnalisable** : Possibilité de définir le titre, l'auteur et d'autres paramètres  
- **Table des matières** : Génération automatique d'une table des matières dans le document Quarto avec la profondeur appropriée
  - Support du français : Affiche "Sommaire" au lieu de "Table of contents" quand la langue est le français
- **Génération HTML automatique** : Génère optionnellement le fichier HTML à partir du .qmd et l'ouvre dans le navigateur
- **Thèmes personnalisables** : Choisissez parmi 25+ thèmes Quarto pour personnaliser l'apparence de vos documents HTML
- **Numéros de ligne source** : Affichage optionnel des numéros de ligne originaux du script R dans les chunks de code pour la traçabilité
- **Intégration qualité du code** : Intégration optionnelle avec [styler](https://styler.r-lib.org/) et [lintr](https://lintr.r-lib.org/) pour afficher les suggestions de formatage et les problèmes de qualité dans des onglets interactifs
- **Support de la documentation roxygen2** : Conversion automatique des blocs de documentation roxygen2 (`#'`) en sections callout-note avec les noms des fonctions
- **Support des snippets RStudio** : Insertion rapide de métadonnées et de structure via des snippets de code personnalisables
- **Fonctionnalités spéciales** : Support des diagrammes Mermaid, des callouts (note, tip, warning, etc.), et des tabsets pour organiser le contenu
- **Personnalisation du répertoire de sortie** : Spécifiez des répertoires de sortie personnalisés pour la génération de livres (par défaut `_book`)
- **Prêt pour déploiement web** : Inclut `quartify_app_web()` pour déploiement sur serveurs web avec capacités d'upload/téléchargement

## Installation

Vous pouvez installer la version de développement de quartify depuis GitHub :

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Utilisation

### 🌐 Essayez l'Application Web en Ligne !

**Aucune installation requise !** Utilisez quartify directement dans votre navigateur :

### **→ [https://quartify.lab.sspcloud.fr/](https://quartify.lab.sspcloud.fr/) ←**

La version web vous permet de :
- ✅ Télécharger **un ou plusieurs scripts R** directement depuis votre ordinateur **OU sélectionner un répertoire** contenant des scripts R pour une conversion par lots
- ✅ **Créer des Quarto Books** automatiquement à partir de plusieurs fichiers avec structure de navigation
- ✅ Configurer les options de conversion (titre, auteur, thème, création de book, etc.)
- ✅ Télécharger les fichiers .qmd et .html générés (ou une archive .zip en mode batch)
- ✅ Aucune installation de R nécessaire !

---

### Interface Shiny Interactive (pour les utilisateurs R)

`quartify` fournit également une interface Shiny interactive qui fonctionne dans n'importe quel environnement R :

#### Option 1 : Application Autonome (fonctionne dans la plupart des IDE)

```r
library(quartify)
quartify_app()  # S'ouvre dans votre navigateur par défaut
```

Cela lance une interface basée sur le navigateur où vous pouvez :
- Convertir **un ou plusieurs fichiers** OU un **répertoire** entier de scripts R
- **Créer des Quarto Books** avec navigation automatique (activé par défaut pour les répertoires)
- Sélectionner un **répertoire de sortie** personnalisé pour la génération de books
- Sélectionner les fichiers/répertoires d'entrée avec un explorateur de fichiers
- Choisir l'emplacement du fichier de sortie pour les fichiers individuels
- Personnaliser le titre du document, l'auteur et le thème
- Activer/désactiver les options de rendu et d'affichage
- Basculer entre l'interface anglaise/française

**Parfait pour les utilisateurs de Positron, VS Code, ou tout IDE supportant R !**

#### Option 2 : Add-in RStudio

Si vous utilisez RStudio, vous pouvez également accéder à la même interface via :

1. Ouvrez votre script R dans RStudio
2. Allez dans le menu **Addins** → **Convert R Script to Quarto**
3. Une fenêtre de dialogue apparaîtra avec les mêmes options que l'application autonome
4. Cliquez sur **GENERATE** pour convertir votre script

L'interface détecte automatiquement les préférences de langue de votre session R et affiche tous les libellés en anglais ou en français en conséquence. Vous pouvez changer la langue à tout moment avec les boutons EN/FR.
Le format de sortie est toujours HTML.

### Exemple basique

```r
library(quartify)

# Convertir un script R en document Quarto et générer le HTML
rtoqmd("mon_script.R", "mon_document.qmd")

# Convertir seulement, sans générer le HTML
rtoqmd("mon_script.R", "mon_document.qmd", render = FALSE)
```

### Personnalisation

```r
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

```r
# Localiser le fichier exemple
example_file <- system.file("examples", "example.R", package = "quartify")

# Convertir le fichier exemple
rtoqmd(example_file, "test_output.qmd")
```

### Conversion par lots

#### Utilisation de l'Interface Web

Dans `quartify_app_web()` (ou l'[application en ligne](https://quartify.lab.sspcloud.fr/)), vous pouvez :

1. **Sélectionner le mode "Batch (multiple files)"**
2. **Choisir votre méthode d'entrée :**
   - **Upload files** : Télécharger plusieurs scripts R en même temps
   - **Select directory** : Parcourir et sélectionner un répertoire contenant vos scripts R
3. L'application convertira tous les scripts R et créera une archive .zip téléchargeable

Parfait pour convertir des projets entiers sans écrire de code R !

#### Utilisation des Fonctions R

Convertir tous les scripts R d'un répertoire (y compris les sous-répertoires) :

```r
# Convertir tous les scripts R d'un répertoire
rtoqmd_dir("chemin/vers/scripts")

# Convertir et générer tous les scripts
rtoqmd_dir("chemin/vers/scripts", render = TRUE)

# Avec paramètres personnalisés
rtoqmd_dir("chemin/vers/scripts", 
           author = "Équipe Data",
           exclude_pattern = "test_.*\\.R$")
```

## Intégration de la qualité du code

`quartify` s'intègre optionnellement avec **styler** et **lintr** pour vous aider à améliorer la qualité du code :

### Fonctionnalités

- **`use_styler`** : Affiche le code formaté selon le [guide de style tidyverse](https://style.tidyverse.org/)
- **`use_lintr`** : Identifie les problèmes de qualité du code et les problèmes potentiels
- **`apply_styler`** : Applique directement le formatage à votre script R original (⚠️ modifie le fichier source)

Lorsque des problèmes de qualité sont détectés, `quartify` crée des **onglets interactifs** dans la sortie HTML avec :
- **Code Original** : Votre code original
- **Code Stylisé** : Version formatée (si `use_styler = TRUE` et des changements détectés)
- **Problèmes Lint** : Avertissements de qualité (si `use_lintr = TRUE` et des problèmes trouvés)

### Installation

Ces packages sont optionnels et nécessaires uniquement si vous souhaitez utiliser les fonctionnalités de qualité du code :

```r
install.packages(c("styler", "lintr"))
```

### Exemples

```r
# Afficher les suggestions de formatage dans des onglets
rtoqmd("mon_script.R", "sortie.qmd", 
       use_styler = TRUE)

# Afficher à la fois le formatage et les problèmes lint
rtoqmd("mon_script.R", "sortie.qmd",
       use_styler = TRUE,
       use_lintr = TRUE)

# Appliquer le formatage directement au fichier source (⚠️ modifie l'original)
rtoqmd("mon_script.R", "sortie.qmd",
       apply_styler = TRUE)
```

### Dans les applications Shiny

Les trois applications Shiny (`rtoqmd_addin()`, `quartify_app()`, et `quartify_app_web()`) incluent des cases à cocher pour ces options dans l'interface.

📖 **Pour des informations détaillées**, consultez :
- [Guide de qualité du code](inst/examples/CODE_QUALITY_README.md)
- [Vignette Fonctionnalités avancées](https://ddotta.github.io/quartify/articles/advanced-features_FR.html) - Guide complet avec exemples
- [Vignettes du package](https://ddotta.github.io/quartify/)

## Format du script R source

Pour que la conversion fonctionne correctement, structurez votre script R en utilisant les sections de code RStudio :

```r
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

Vous pouvez définir les métadonnées directement dans votre script R en utilisant des commentaires spéciaux au début :

- **Titre** : `# Title : Mon titre` ou `# Titre : Mon titre`
- **Auteur** : `# Author : Mon nom` ou `# Auteur : Mon nom`
- **Date** : `# Date : AAAA-MM-JJ`
- **Description** : `# Description : Description de votre script`

**💡 Snippet RStudio :** Créez un snippet pour insérer rapidement les métadonnées (Outils > Modifier les snippets de code > R) :

```
snippet header
	# Titre : ${1}
	#
	# Auteur : ${2}
	#
	# Date : ${3}
	#
	# Description : ${4}
	#
```

Tapez `header` + `Tab` dans votre script pour insérer la structure de métadonnées.

**Comportement :**
- Les métadonnées trouvées dans le script **remplacent** les paramètres de la fonction
- Les lignes de métadonnées sont **retirées** du corps du document (uniquement dans le YAML)
- Si aucune métadonnée dans le script, les paramètres de la fonction sont utilisés

> **📝 Note :** Le champ `Description` peut s'étendre sur plusieurs lignes. Pour continuer la description, commencez la ligne suivante par `#` suivi d'au moins un espace. Les lignes de continuation sont automatiquement concaténées. Exemple :
> ```r
> # Description : Cette analyse explore les différences entre les espèces d'iris
> # en utilisant diverses méthodes statistiques et techniques de visualisation
> # pour identifier les patterns et corrélations.
> ```

`quartify` reconnaît trois types de lignes dans votre script R :

#### 1. Sections de code (En-têtes)

Les sections de code RStudio deviennent des en-têtes markdown. **Critique** : les symboles de fin doivent contenir au moins 4 caractères :

- `## Titre ----` → En-tête de niveau 2 (au moins 4 `#`, `=` ou `-` à la fin)
- `### Titre ----` → En-tête de niveau 3 (au moins 4 `#`, `=` ou `-` à la fin)
- `#### Titre ----` → En-tête de niveau 4 (au moins 4 `#`, `=` ou `-` à la fin)

**Note :** Vous pouvez utiliser `#`, `=`, ou `-` indifféremment comme symboles de fin (ex : `## Titre ====` ou `### Titre ----` fonctionneront).

#### 2. Commentaires réguliers (Texte)

Les commentaires simples avec `#` **en début de ligne (sans espace avant)** deviennent du texte explicatif :

```r
# Ceci est un commentaire autonome
# Il devient du texte simple dans le document Quarto
```

> **⚠️ Important :** Pour qu'un commentaire soit converti en texte, la ligne doit commencer par `#` **sans espace avant**. Les commentaires indentés (avec des espaces avant `#`) restent dans le code.

> **💡 Astuce :** Pour **diviser un long chunk en plusieurs parties**, insérez un **commentaire en début de ligne** (sans espace avant `#`) entre deux blocs de code. Ce commentaire sera converti en texte et créera naturellement deux chunks séparés.

**Astuce :** Utilisez le [raccourci Commenter/Décommenter](https://docs.posit.co/ide/user/ide/guide/productivity/text-editor.html#commentuncomment) de RStudio (`Ctrl+Shift+C` sur Windows/Linux ou `Cmd+Shift+C` sur Mac) pour ajouter ou retirer rapidement des commentaires.

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

#### 5. Callouts (Encadrés)

Les callouts sont des blocs spéciaux qui mettent en évidence des informations importantes. Cinq types sont supportés : `note`, `tip`, `warning`, `caution`, `important`.

**Syntaxe dans le script R :**

```r
# callout-note - Note importante
# Ceci est le contenu du callout.
# Il peut s'étendre sur plusieurs lignes.

# Une ligne vide ou du code termine le callout
x <- 1
```

**Se convertit en Quarto :**

```markdown
::: {.callout-note title="Note importante"}
Ceci est le contenu du callout.
Il peut s'étendre sur plusieurs lignes.
:::
```

**Sans titre :**

```r
# callout-tip
# Ceci est un conseil sans titre.
```

Les callouts se terminent lorsqu'on rencontre une ligne vide, du code, ou une autre section.

#### 6. Diagrammes Mermaid

Créez des organigrammes, des diagrammes de séquence et d'autres visualisations avec la syntaxe Mermaid, rendus directement dans la sortie HTML.

**Syntaxe dans le script R :**

```r
#| mermaid
#| eval: true
flowchart LR
  A[Démarrer] --> B{Décision}
  B -->|Oui| C[Résultat 1]
  B -->|Non| D[Résultat 2]
```

**Se convertit en Quarto :**

```markdown
```{mermaid}
%%| eval: true
flowchart LR
  A[Démarrer] --> B{Décision}
  B -->|Oui| C[Résultat 1]
  B -->|Non| D[Résultat 2]
```
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
```

**Se convertit en Quarto :**

```markdown
::: {.panel-tabset}

## Statistiques résumées

Voici les statistiques pour iris :

```{r}
summary(iris)
```

## Structure

Structure des données :

```{r}
str(iris)
```

## Premières lignes

Premières observations :

```{r}
head(iris)
```

:::
```

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
```

Pour plus d'informations sur les thèmes, consultez la [documentation Quarto](https://quarto.org/docs/output-formats/html-themes.html).

## Sortie et documentation

Le document .qmd généré contient :  
- Un en-tête YAML complet avec configuration de la table des matières  
- Des titres correctement structurés à partir des sections de code RStudio  
- Des explications textuelles à partir de vos commentaires  
- **Chunks de code non exécutables** pour une documentation statique  

📝 **Pour un exemple complet de la sortie générée**, consultez la [vignette Démarrage](https://ddotta.github.io/quartify/articles/getting-started_FR.html#sortie-g%C3%A9n%C3%A9r%C3%A9e)

## Intégration CI/CD

Utilisez `quartify` dans vos pipelines CI/CD pour générer automatiquement la documentation :

**GitHub Actions** (`.github/workflows/generate-docs.yml`) :
```yaml
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
```yaml
generate-docs:
  image: rocker/r-ver:4.5.1
  script:
    - R -e "quartify::rtoqmd_dir('scripts/', render = TRUE, author = 'Équipe Data')"
  artifacts:
    paths:
      - scripts/**/*.qmd
      - scripts/**/*.html
```

📘 **Guide complet CI/CD** avec exemples détaillés : [Intégration CI/CD](https://ddotta.github.io/quartify/articles/getting-started_FR.html#int%C3%A9gration-cicd)

## Licence

MIT
