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

### Comparaison avec knitr::spin()

Si vous connaissez
[`knitr::spin()`](https://yihui.org/knitr/demo/stitch/), vous vous
demandez peut-être en quoi `quartify` diffère :

| Fonctionnalité               | knitr::spin()             | quartify                      |
|------------------------------|---------------------------|-------------------------------|
| **Format de sortie**         | R Markdown (.Rmd)         | Quarto (.qmd)                 |
| **Syntaxe texte**            | `#'` pour markdown        | `#` (commentaires R naturels) |
| **Options de chunk**         | Préfixe `#+`              | Sections de code RStudio      |
| **Fonctionnalités modernes** | Limité à R Markdown       | Toutes les capacités Quarto   |
| **Encadrés**                 | HTML/CSS manuel           | Callouts Quarto natifs        |
| **Diagrammes**               | Outils externes           | Support Mermaid natif         |
| **Thèmes**                   | Thèmes R Markdown limités | 25+ thèmes Quarto modernes    |

**Pourquoi choisir quartify ?**

1.  **Écosystème Quarto Moderne** : Bénéficiez des fonctionnalités de
    nouvelle génération de Quarto (callouts, tabsets, références
    croisées, Observable JS, etc.)
2.  **Scripts R Plus Propres** : Utilisez des commentaires R naturels
    sans syntaxe spéciale `#'` ou `#+` - vos scripts restent lisibles
    comme du code R autonome
3.  **Meilleurs Thèmes** : Accès à des thèmes HTML modernes et
    responsives avec un style cohérent
4.  **Pérennité** : Quarto est activement développé par Posit comme
    successeur de R Markdown

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
le fichier HTML dans votre navigateur (si `open_html = TRUE`)

### Emplacement des fichiers de sortie

Comprendre où les fichiers sont créés :

- **Si vous spécifiez un chemin `output_file`** : Le fichier .qmd est
  créé à cet emplacement exact, et le fichier .html (si rendu) est créé
  dans le même répertoire avec le même nom de base.

``` r
# Crée : /chemin/vers/mon_analyse.qmd et /chemin/vers/mon_analyse.html
rtoqmd("script.R", "/chemin/vers/mon_analyse.qmd")
```

- **Si vous ne spécifiez pas `output_file`** : Le fichier .qmd est créé
  dans le même répertoire que votre script R d’entrée, avec l’extension
  `.R` remplacée par `.qmd`.

``` r
# Si script.R est dans /home/utilisateur/scripts/
# Crée : /home/utilisateur/scripts/script.qmd et /home/utilisateur/scripts/script.html
rtoqmd("/home/utilisateur/scripts/script.R")
```

- **Chemins relatifs** : Si vous utilisez des chemins relatifs, les
  fichiers sont créés relativement à votre répertoire de travail actuel
  (vérifiez avec [`getwd()`](https://rdrr.io/r/base/getwd.html)).

``` r
# Crée les fichiers dans votre répertoire de travail actuel
rtoqmd("script.R", "sortie.qmd")
```

## Utiliser l’Addin RStudio

`quartify` fournit un addin RStudio interactif pour une conversion
facile sans écrire de code. C’est parfait pour des conversions rapides
en travaillant dans RStudio.

### Accéder à l’Addin

Pour utiliser l’addin :

1.  **Depuis le menu RStudio** : Allez dans **Addins** \> **“Convert R
    to Quarto (rtoqmd)”**
2.  L’interface interactive s’ouvrira dans une nouvelle fenêtre

**Astuce :** Vous pouvez également lier un raccourci clavier à l’addin
pour un accès encore plus rapide. Allez dans **Tools** \> **Modify
Keyboard Shortcuts** et recherchez “quartify” pour attribuer votre
raccourci préféré.

### Aperçu de l’Interface

L’addin présente une interface moderne et intuitive avec :

- **Barre de titre bleue** avec sélecteur de langue (drapeaux EN/FR)
- **Bouton GENERATE** placé en évidence en haut sous la barre de titre,
  à côté du logo quartify
- **Sélecteur de mode** pour choisir entre conversion d’un fichier
  unique ou d’un répertoire
- **Navigateur de fichiers/répertoires** pour une sélection facile
- **Validation en temps réel** et messages d’erreur

### Mode Fichier Unique

Parfait pour convertir un script R à la fois :

1.  **Sélectionner le mode** : Choisissez “Mode Fichier Unique”
2.  **Parcourir pour l’entrée** : Cliquez sur “Parcourir” pour
    sélectionner votre script R
3.  **Définir l’emplacement de sortie** : Spécifiez optionnellement où
    enregistrer le fichier .qmd (par défaut dans le même répertoire que
    l’entrée)
4.  **Configurer les options** :
    - **Générer le HTML** : Cochez pour générer automatiquement la
      sortie HTML
    - **Ouvrir le HTML** : Cochez pour ouvrir le résultat dans votre
      navigateur
5.  **Cliquez sur GENERATE** : Le bouton bleu GENERATE en haut démarre
    la conversion

L’addin affichera des messages de succès/erreur et fournira des liens
cliquables vers les fichiers de sortie.

### Mode Répertoire

Convertir tous les scripts R d’un répertoire en une seule fois :

1.  **Sélectionner le mode** : Choisissez “Mode Répertoire”
2.  **Parcourir le répertoire d’entrée** : Sélectionnez le dossier
    contenant vos scripts R
3.  **Configurer les options** :
    - **Récursif** : Cochez pour inclure les sous-répertoires
    - **Générer le HTML** : Générer le HTML pour tous les fichiers
    - **Créer un livre** : Créer automatiquement un fichier
      `_quarto.yml` pour combiner tous les documents en un livre Quarto
4.  **Répertoire de sortie** (Optionnel) : Choisissez où enregistrer les
    fichiers convertis (par défaut au même emplacement que les fichiers
    d’entrée)
5.  **Cliquez sur GENERATE** : Démarrer la conversion en lot

**Fonction Créer un Livre** : Lorsqu’elle est activée, cette option crée
un fichier de configuration `_quarto.yml` dans le répertoire de sortie,
vous permettant de générer tous les documents convertis comme un livre
Quarto unifié avec navigation automatique et style cohérent. Ceci est
idéal pour la documentation de projet ou les collections d’analyses.

### Fonctionnalités Avancées

L’addin inclut plusieurs améliorations de qualité de vie :

- **Gestion des volumes** : Naviguez facilement entre différents
  lecteurs et emplacements réseau
- **Validation du chemin** : Vérifications en temps réel pour les
  chemins de fichiers/répertoires valides
- **Interface bilingue** : Basculez entre français et anglais
  instantanément
- **Paramètres persistants** : Votre dernière sélection de mode est
  mémorisée
- **Retour détaillé** : Messages de succès/erreur clairs avec comptes de
  fichiers et emplacements

### Quand Utiliser l’Addin

L’addin RStudio est idéal pour :

- **Exploration interactive** : Tester la conversion sur des scripts
  exemples
- **Conversions ponctuelles** : Génération rapide de documents sans
  script
- **Retour visuel** : Voir les résultats immédiatement avec l’interface
  graphique
- **Apprentissage du package** : Comprendre les options avant
  d’automatiser
- **Enseignement** : Démontrer les fonctionnalités de quartify aux
  collègues

Pour le traitement par lots ou les pipelines CI/CD, considérez plutôt
l’utilisation des fonctions programmatiques
([`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md),
[`rtoqmd_dir()`](https://ddotta.github.io/quartify/reference/rtoqmd_dir.md)).

## Utiliser l’Application Shiny Autonome

Pour les utilisateurs travaillant en dehors de RStudio ou souhaitant
partager un outil de conversion avec leur équipe, `quartify` fournit une
application Shiny autonome.

### Lancer l’Application

Exécutez simplement :

``` r
library(quartify)
quartify_app()
```

Cela ouvre la même interface intuitive que l’addin RStudio, mais dans
une fenêtre de navigateur standard. L’application peut fonctionner sur
n’importe quel système avec R installé, ce qui la rend parfaite pour :

- **Environnements hors RStudio** : Utiliser avec VS Code, Jupyter ou
  d’autres IDE
- **Outils d’équipe partagés** : Déployer sur RStudio Connect ou Shiny
  Server pour un accès en équipe
- **Démonstrations** : Montrer les fonctionnalités de quartify sans
  nécessiter RStudio
- **Travail à distance** : Accéder depuis n’importe quel navigateur si
  hébergé sur un serveur

### Fonctionnalités

L’application autonome inclut toutes les mêmes fonctionnalités que
l’addin RStudio :

- **Mode Fichier Unique** : Convertir des scripts R individuels avec
  contrôle total sur l’emplacement de sortie et les options de
  génération
- **Mode Répertoire** : Convertir par lots des dossiers entiers avec
  analyse récursive des répertoires
- **Créer un Livre** : Générer la configuration `_quarto.yml` pour les
  projets de livres Quarto
- **Interface Bilingue** : Basculer entre français et anglais avec les
  boutons drapeaux
- **Interface Moderne** : Barre de titre bleue, bouton GENERATE en
  évidence et mise en page intuitive

### Comparaison avec l’Addin

| Fonctionnalité                 | Addin RStudio             | Application Autonome                                                            |
|--------------------------------|---------------------------|---------------------------------------------------------------------------------|
| **Nécessite RStudio**          | Oui                       | Non                                                                             |
| **Méthode de Lancement**       | Menu Addins               | [`quartify_app()`](https://ddotta.github.io/quartify/reference/quartify_app.md) |
| **Interface**                  | Fenêtre gadget            | Fenêtre navigateur                                                              |
| **Navigateur de Fichiers**     | Système de fichiers natif | Système de fichiers natif                                                       |
| **Toutes les Fonctionnalités** | ✓                         | ✓                                                                               |
| **Partageable**                | Non                       | Oui (peut déployer)                                                             |

### Options de Déploiement

L’application autonome peut être déployée pour un accès en équipe :

**Réseau Local :**

``` r
# Exécuter sur un port spécifique accessible à votre réseau
shiny::runApp(system.file("shiny", "quartify_app", package = "quartify"), 
              host = "0.0.0.0", port = 3838)
```

**RStudio Connect / Shiny Server :** Déployer comme une application
Shiny standard pour un accès à l’échelle de l’entreprise.

### Version Web

Pour les environnements où l’accès au système de fichiers est restreint
(déploiements cloud, environnements sandboxés), utilisez la version web
:

``` r
quartify_app_web()
```

Cette version propose :

- **Upload de fichiers** : Téléverser des scripts R directement depuis
  votre ordinateur (un ou plusieurs fichiers)
- **Téléchargement** : Télécharger les fichiers générés sous forme
  d’archives .zip avec structure organisée
- **Structure ZIP** :
  - Dossier `qmd/` avec tous les fichiers Quarto markdown et la
    configuration
  - Dossier `html/` avec le livre complet rendu (incluant `index.html`
    et toutes les ressources)
- **Conversion par lots** : Téléverser plusieurs fichiers pour créer un
  livre Quarto complet
- **Visualisation hors ligne** : Le ZIP téléchargé contient tout le
  nécessaire pour voir le livre hors ligne
- **Même logique de conversion** : Toutes les fonctionnalités de
  quartify disponibles

Parfait pour les déploiements cloud où l’accès direct au système de
fichiers n’est pas disponible. Le ZIP téléchargé est prêt à extraire et
visualiser immédiatement dans n’importe quel navigateur.

## Structurer votre script R

Pour une conversion optimale, vous devez suivre des règles de
commentaires spécifiques dans votre script R. `quartify` reconnaît trois
types de lignes :

### 0. Métadonnées du document (Optionnel)

Vous pouvez définir les métadonnées de votre document directement dans
votre script R en utilisant des commentaires spéciaux au début du
fichier. Ces métadonnées apparaîtront dans l’en-tête YAML du document
Quarto généré.

**Métadonnées reconnues :**

- **Titre** : `# Title : Mon titre` ou `# Titre : Mon titre`
- **Auteur** : `# Author : Mon nom` ou `# Auteur : Mon nom`  
- **Date** : `# Date : 2025-11-28`
- **Description** : `# Description : Description de votre script`

**Astuce - Snippets RStudio :** Pour gagner du temps, vous pouvez créer
un [snippet
RStudio](https://docs.posit.co/ide/user/ide/guide/productivity/snippets.html)
pour insérer automatiquement cet en-tête de métadonnées. Ajoutez ce
snippet dans vos snippets R (Tools \> Edit Code Snippets \> R) :

    snippet header
        # Title : ${1}
        #
        # Auteur : ${2}
        #
        # Date : ${3}
        #
        # Description : ${4}
        #

Une fois défini, tapez `header` suivi de `Tab` dans votre script R pour
insérer automatiquement la structure de métadonnées.

**Exemple complet avec métadonnées :**

``` r
# Title : Analyse des données Iris
#
# Auteur : Jean Dupont
#
# Date : 2025-11-28
#
# Description : Explorer les différences entre espèces d'iris
#

library(dplyr)

## Analyse descriptive ####

# Calculer les statistiques par espèce

iris |> 
  group_by(Species) |>
  summarize(mean_sepal = mean(Sepal.Length))
```

**Comportement :**

- Si des métadonnées sont trouvées dans le script, elles **remplacent**
  les paramètres de la fonction
  [`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md)
- Si aucune métadonnée n’est trouvée, les paramètres `title` et `author`
  de la fonction sont utilisés
- Les lignes de métadonnées sont **automatiquement retirées** du corps
  du document (elles n’apparaissent que dans le YAML)
- Les métadonnées `Date` et `Description` sont optionnelles

**Règles pour les descriptions multi-lignes :**

Le champ `Description` peut s’étendre sur plusieurs lignes. Pour
continuer la description sur une nouvelle ligne :

- Commencez la ligne suivante par `#` suivi d’**au moins un espace** et
  du texte de continuation
- Les lignes de continuation sont automatiquement concaténées avec un
  espace
- Une ligne vide (ou tout autre type de commentaire) termine la
  description

**Exemple :**

``` r
# Title : Analyse des données Iris
#
# Author : Jean Dupont
#
# Date : 2025-11-28
#
# Description : Cette analyse explore les différences entre les espèces d'iris
# en utilisant diverses méthodes statistiques et techniques de visualisation
# pour identifier les patterns et corrélations.
#

library(dplyr)
```

Ceci produira dans le YAML :

``` yaml
description: Cette analyse explore les différences entre les espèces d'iris en utilisant diverses méthodes statistiques et techniques de visualisation pour identifier les patterns et corrélations.
```

### 1. Sections de code (En-têtes)

Utilisez la syntaxe des sections de code RStudio pour créer des en-têtes
à différents niveaux. Ces sections DOIVENT suivre ce modèle exact :

- **Niveau 2** : `## Titre ####` (au moins 4 symboles `#` à la fin)
- **Niveau 3** : `### Titre ====` (au moins 4 symboles `=` à la fin)
- **Niveau 4** : `#### Titre ----` (au moins 4 symboles `-` à la fin)

**Règles importantes :**

- Il doit y avoir au moins un espace entre le texte du titre et les
  symboles de fin
- Les symboles de fin doivent contenir au moins 4 caractères
- Vous pouvez utiliser `#`, `=`, ou `-` indifféremment (ex :
  `## Titre ====` fonctionne), mais il est recommandé de suivre la
  convention RStudio pour la cohérence
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

- Commencez par un seul `#` **suivi d’un espace** (pas d’espace avant le
  `#`)
- Plusieurs lignes de commentaires consécutives sont regroupées ensemble
  (sans ligne vide entre elles)
- Les lignes de commentaires vides séparent les blocs de commentaires
- **Tableaux Markdown** : Vous pouvez inclure des tableaux Markdown dans
  les commentaires. Les lignes consécutives de commentaires seront
  préservées ensemble, permettant un rendu correct des tableaux

**⚠️ Important pour la conversion en texte :**

Pour qu’un commentaire soit correctement converti en texte Quarto, la
ligne doit commencer par `#` **sans espace avant**. Si vous avez des
espaces d’indentation avant le `#`, le commentaire sera ignoré et
restera dans le chunk de code.

**Exemple correct :**

``` r
# Ceci sera converti en texte
result <- mean(x)
```

**Exemple incorrect (commentaire dans le code) :**

``` r
if (condition) {
  # Ceci restera un commentaire R dans le chunk
  result <- mean(x)
}
```

Vous pouvez utiliser cette règle pour **diviser un long chunk de code en
plusieurs parties**. En insérant un commentaire **en début de ligne**
(sans espace avant le `#`) entre deux blocs de code, ce commentaire sera
converti en texte et créera naturellement deux chunks séparés :

``` r
data <- read.csv("file.csv")
data_clean <- na.omit(data)

# Ce commentaire divise le chunk en deux parties

result <- mean(data_clean$value)
plot(result)
```

Ceci créera deux chunks séparés au lieu d’un seul grand chunk.

**Important pour les tableaux Markdown :** Les lignes formant un tableau
doivent être **isolées des autres commentaires** par une ligne vide
avant et après le tableau. Cela garantit que le tableau est traité comme
un bloc séparé et sera correctement rendu.

**Exemple de tableau Markdown :**

``` r
# Résultats de l'analyse :

# | fruit  | prix   |
# |--------|--------|
# | pomme  | 2.05   |
# | poire  | 1.37   |
# | orange | 3.09   |
#
# Le tableau ci-dessus est correctement isolé.
```

**Astuce :** Utilisez le [raccourci
Commenter/Décommenter](https://docs.posit.co/ide/user/ide/guide/productivity/text-editor.html#commentuncomment)
de RStudio (`Ctrl+Shift+C` sur Windows/Linux ou `Cmd+Shift+C` sur Mac)
pour ajouter ou retirer rapidement des commentaires de votre code.

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

Cela sera rendu comme :

```` markdown
``` r
iris %>% 
  # Sélectionner une colonne
  select(Species)
```
````

La différence :  
- **Commentaires en début de ligne** → deviennent du texte EN DEHORS des
blocs de code  
- **Commentaires dans le code** (indentés ou partie d’un pipeline) →
restent À L’INTÉRIEUR des blocs de code

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
- `author` : Nom de l’auteur (par défaut : “Your name”)
- `format` : Format de sortie (par défaut : “html”)
- `render` : Générer le HTML à partir du .qmd (par défaut : TRUE)
- `open_html` : Ouvrir le HTML dans le navigateur (par défaut : FALSE)
- `code_fold` : Replier les blocs de code par défaut (par défaut :
  FALSE)
- `number_sections` : Numéroter les sections automatiquement (par défaut
  : TRUE)

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

```` markdown
---
title: "Analyse du jeu de données Iris"
author: "Analyste de données"
format:
  html:
    embed-resources: true
    code-fold: false
toc: true
toc-title: Sommaire
toc-depth: 4  
toc-location: left
execute: 
  eval: false
  echo: true
output: 
  html_document:
  number_sections: TRUE
  output-file: analyse_iris.html
---


``` r
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

Filter the data.frame on Species "setosa"


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
````

Notez comment :

- Chaque section de code devient un titre markdown approprié
- Les commentaires deviennent des paragraphes de texte lisible
- Les commentaires en ligne (dans le code) sont préservés dans les blocs
  de code
- Les blocs de code sont correctement formatés avec coloration
  syntaxique
- La table des matières montrera la structure hiérarchique

**Note importante sur les chunks de code :**  
Les chunks de code générés utilisent des chunks R standard.  
L’en-tête YAML inclut des options globales `execute` (`eval: false` et
`echo: true`), qui créent des blocs de code **non exécutables**.  
De plus, le format HTML utilise `embed-resources: true` pour créer des
**fichiers HTML autonomes** (voir la [documentation
Quarto](https://quarto.org/docs/output-formats/html-basics.html#self-contained)).  
C’est intentionnel - `quartify` est conçu pour créer une **documentation
statique** de votre script R, pas un notebook exécutable.  
Le code est affiché avec coloration syntaxique à des fins de lecture et
de documentation, mais ne sera pas exécuté lors du rendu du document
Quarto.

Cette approche est idéale pour :

- Documenter des scripts existants sans modifier leur exécution
- Partager des exemples de code que les lecteurs peuvent copier et
  exécuter dans leur propre environnement
- S’assurer que le processus de documentation n’interfère pas avec le
  comportement de votre script original

## Rendu de la sortie

### Rendu automatique (Recommandé)

Par défaut,
[`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md)
génère automatiquement votre document Quarto en HTML :

``` r
# Ceci créera les fichiers .qmd et .html, puis ouvrira le HTML
rtoqmd(example_file, "analyse_iris.qmd")
```

La fonction va : 1. Vérifier si Quarto est installé (par défaut)  
2. Générer le fichier .qmd en HTML (par défaut)  
3. Ouvrir le fichier HTML dans votre navigateur par défaut (si
`open_html = TRUE`)

Si vous ne voulez pas de rendu automatique en HTML, définissez
`render = FALSE` :

``` r
rtoqmd(example_file, "analyse_iris.qmd", render = FALSE)
```

### Rendu manuel

Vous pouvez bien sûr également générer manuellement le fichier HTML en
utilisant :

``` bash
quarto render analyse_iris.qmd
```

Ou depuis R :

``` r
quarto::quarto_render("analyse_iris.qmd")
```

**Note :** Quarto doit être installé sur votre système. Téléchargez-le
depuis [quarto.org](https://quarto.org/docs/get-started/).

## Conversion de répertoires entiers

## Conversion par Lots de Répertoires

`quartify` v0.0.7 introduit des capacités puissantes de conversion par
lots à travers plusieurs interfaces. Choisissez la méthode qui
correspond le mieux à votre flux de travail.

### Utilisation de l’Addin RStudio ou de l’Application Autonome

La façon la plus intuitive de convertir des fichiers par lots est via le
**Mode Répertoire** dans l’addin RStudio ou l’application autonome :

``` r
# Lancer l'application autonome
quartify_app()

# Ou utiliser l'addin RStudio : Addins > "Convert R to Quarto (rtoqmd)"
```

**Fonctionnalités du Mode Répertoire (v0.0.7) :**

1.  **Parcourir le répertoire** : Sélectionnez le dossier contenant vos
    scripts R
2.  **Option récursive** : Inclure ou exclure les sous-répertoires
3.  **Répertoire de sortie** : Spécifiez optionnellement un emplacement
    différent pour les fichiers convertis (nouveau dans v0.0.7 !)
4.  **Case Créer un Livre** : Générer automatiquement `_quarto.yml` pour
    combiner tous les documents en un livre Quarto (nouveau dans v0.0.7
    !)
5.  **Option de génération** : Choisissez si vous souhaitez générer les
    fichiers HTML pour tous les scripts
6.  **Conversion en un clic** : Cliquez sur le bouton GENERATE en haut
    pour convertir tous les fichiers

**Nouveau dans v0.0.7** : La fonctionnalité de répertoire de sortie vous
permet de garder vos scripts R sources séparés des fichiers .qmd
générés. Combinée avec l’option “Créer un Livre”, vous pouvez
instantanément créer un projet de livre Quarto complet à partir d’une
collection de scripts R.

**Exemple de flux de travail :**

- Répertoire d’entrée : `~/mon-projet/scripts/` (contient 10 scripts R)
- Répertoire de sortie : `~/mon-projet/docs/` (où vous voulez les
  fichiers .qmd)
- Activer “Créer un Livre” : Génère `~/mon-projet/docs/_quarto.yml`
- Résultat : Livre Quarto complet prêt à générer avec `quarto render`

### Utilisation de l’Interface Web

Pour les environnements sans accès direct au système de fichiers :

``` r
quartify_app_web()
```

En mode batch, vous pouvez : - **Télécharger plusieurs fichiers R** en
même temps - **Sélectionner un répertoire** contenant vos scripts R

L’interface convertira tous les fichiers et fournira une archive .zip
téléchargeable.

### Utilisation des Fonctions R

Pour convertir tous les scripts R d’un répertoire (y compris les
sous-répertoires) de manière programmatique, utilisez
[`rtoqmd_dir()`](https://ddotta.github.io/quartify/reference/rtoqmd_dir.md)
:

``` r
# Convertir tous les scripts R d'un répertoire
rtoqmd_dir("chemin/vers/scripts")

# Convertir et générer les fichiers HTML
rtoqmd_dir("chemin/vers/scripts", render = TRUE)

# Avec auteur personnalisé et préfixe de titre
rtoqmd_dir("chemin/vers/scripts", 
           title_prefix = "Analyse : ",
           author = "Équipe Data")

# Exclure certains fichiers (ex : fichiers de test)
rtoqmd_dir("chemin/vers/scripts", 
           exclude_pattern = "test_.*\\.R$")

# Non récursif (seulement le répertoire courant)
rtoqmd_dir("chemin/vers/scripts", recursive = FALSE)
```

Cette fonction : - Recherche récursivement tous les fichiers `.R` dans
le répertoire - Convertit chaque fichier en `.qmd` dans le même
emplacement - Affiche un résumé de la conversion avec le nombre de
succès/échecs - Retourne un data frame avec les résultats pour chaque
fichier

## Intégration CI/CD

Vous pouvez utiliser `quartify` dans vos pipelines CI/CD pour générer
automatiquement la documentation à partir de vos scripts R. Ceci est
utile pour :

- Versionner uniquement les scripts R (pas la documentation générée)
- Générer automatiquement les fichiers `.qmd` et `.html` en CI/CD
- Fournir des artefacts de documentation pour chaque commit/merge
  request

### GitHub Actions

Créez `.github/workflows/generate-docs.yml` :

``` yaml
name: Générer la Documentation

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  generate-docs:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.5.1'
      
      - name: Installer Quarto
        uses: quarto-dev/quarto-actions/setup@v2
      
      - name: Installer les dépendances R
        run: |
          install.packages(c("remotes", "dplyr"))
          remotes::install_github("ddotta/quartify")
        shell: Rscript {0}
      
      - name: Convertir les scripts R en Quarto
        run: |
          library(quartify)
          # Convertir tous les scripts R d'un répertoire
          rtoqmd_dir("scripts/", render = TRUE, author = "Équipe Data")
        shell: Rscript {0}
      
      - name: Télécharger les artefacts
        uses: actions/upload-artifact@v4
        with:
          name: documentation
          path: |
            scripts/**/*.qmd
            scripts/**/*.html
```

### GitLab CI

Créez `.gitlab-ci.yml` :

``` yaml
generate-docs:
  image: rocker/r-ver:4.5.1
  
  before_script:
    # Installer Quarto
    - apt-get update
    - apt-get install -y curl
    - curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb
    - dpkg -i quarto-linux-amd64.deb
    
    # Installer les packages R
    - R -e "install.packages(c('remotes', 'dplyr'))"
    - R -e "remotes::install_github('ddotta/quartify')"
  
  script:
    # Convertir tous les scripts R en Quarto et générer le HTML
    - R -e "quartify::rtoqmd_dir('scripts/', render = TRUE, author = 'Équipe Data')"
  
  artifacts:
    paths:
      - scripts/**/*.qmd
      - scripts/**/*.html
    expire_in: 30 days
  
  only:
    - main
    - merge_requests
```

### Conversion d’un fichier unique en CI/CD

Pour convertir un seul script R :

``` yaml
# GitHub Actions
- name: Convertir un script unique
  run: |
    library(quartify)
    rtoqmd("analyse.R", "analyse.qmd", 
           title = "Mon Analyse",
           author = "Équipe Data",
           render = TRUE)
  shell: Rscript {0}

# GitLab CI
script:
  - R -e "quartify::rtoqmd('analyse.R', 'analyse.qmd', title = 'Mon Analyse', author = 'Équipe Data', render = TRUE)"
```

### Bonnes pratiques pour le CI/CD

1.  **Ajouter au .gitignore** : Exclure les fichiers générés du contrôle
    de version

        # .gitignore
        *.qmd
        *.html
        *_files/

2.  **Rétention des artefacts** : Définir une expiration appropriée pour
    les artefacts

    - Courte durée (7 jours) pour les branches de fonctionnalités
    - Longue durée (90+ jours) pour la branche principale

3.  **Exécution conditionnelle** : Générer la documentation uniquement
    si les scripts R changent

    ``` yaml
    # GitHub Actions
    on:
      push:
        paths:
          - 'scripts/**/*.R'
    ```

4.  **Gestion des erreurs** : Utiliser `render = FALSE` pour déboguer
    les problèmes de conversion

    ``` r
    # D'abord convertir sans générer
    rtoqmd_dir("scripts/", render = FALSE)
    # Puis générer séparément si nécessaire
    ```

## Cas d’usage

`quartify` est particulièrement utile pour :

1.  **Documentation** : Transformer des scripts de travail en
    documentation
2.  **Revue de code** : Présenter le code dans un format plus accessible
3.  **Conversion en masse** : Convertir automatiquement tous les scripts
    d’un projet

## Callouts (Encadrés)

Les callouts sont des blocs spéciaux qui mettent en évidence des
informations importantes dans vos documents Quarto. `quartify` supporte
la conversion automatique des commentaires callout.

### Syntaxe

Dans votre script R, utilisez cette syntaxe :

``` r
# callout-note - Note importante
# Ceci est le contenu de la note.
# Il peut s'étendre sur plusieurs lignes.

# Le code ou une ligne vide termine le callout
x <- 1
```

Ceci se convertit en :

``` markdown
::: {.callout-note title="Note importante"}
Ceci est le contenu de la note.
Il peut s'étendre sur plusieurs lignes.
:::
```

### Types de callouts

Cinq types de callouts sont supportés :

- `# callout-note` - Boîte d’information bleue
- `# callout-tip` - Boîte de conseil verte
- `# callout-warning` - Boîte d’avertissement orange
- `# callout-caution` - Boîte de précaution rouge
- `# callout-important` - Boîte importante rouge

### Avec ou sans titre

**Avec titre :**

``` r
# callout-tip - Conseil utile
# Utilisez les callouts pour mettre en évidence les informations clés.
```

**Sans titre :**

``` r
# callout-tip
# Utilisez les callouts pour mettre en évidence les informations clés.
```

### Exemples

``` r
# callout-note - Exigences des données
# Les données d'entrée doivent contenir les colonnes : Species, Sepal.Length, Petal.Length

# callout-warning
# Cette opération peut prendre plusieurs minutes avec de gros jeux de données

# callout-tip - Optimisation des performances
# Utilisez data.table pour les jeux de données de plus de 1 Go

library(dplyr)
iris %>% head()
```

### Règles

- Le callout commence par `# callout-TYPE` (suivi optionnellement de
  `- Titre`)
- Toutes les lignes de commentaires suivantes font partie du contenu du
  callout
- Le callout se termine lorsqu’on rencontre :
  - Une ligne vide
  - Une ligne de code
  - Une autre section ou callout
- Le titre est optionnel (omettre la partie `- Titre`)

**Conseil :** Créez des snippets RStudio pour les callouts pour
accélérer votre flux de travail :

    snippet callout
        # callout-${1:note} - ${2:Titre}
        # ${0}

Tapez `callout` suivi de `Tab` pour insérer le modèle.

## Diagrammes Mermaid

Créez des organigrammes, des diagrammes de séquence et d’autres
visualisations avec la syntaxe Mermaid. Les diagrammes Mermaid sont
rendus directement dans la sortie HTML.

### Syntaxe

Dans votre script R, commencez par `#| mermaid`, ajoutez des options
avec `#|`, puis le contenu du diagramme :

``` r
#| mermaid
#| eval: true
flowchart TD
    A[Début] --> B[Traiter les données]
    B --> C{Valide ?}
    C -->|Oui| D[Sauvegarder]
    C -->|Non| E[Erreur]
    D --> F[Fin]
    E --> F
```

Ceci se convertit en un chunk Mermaid Quarto qui se rend comme un
diagramme interactif en HTML.

### Types de diagrammes

Mermaid supporte de nombreux types de diagrammes :

**Organigrammes :**

``` r
#| mermaid
#| eval: true
flowchart LR
    A[Entrée] --> B[Traitement]
    B --> C[Sortie]
```

**Diagrammes de séquence :**

``` r
#| mermaid
#| eval: true
sequenceDiagram
    participant Utilisateur
    participant API
    participant BDD
    Utilisateur->>API: Demande
    API->>BDD: Requête
    BDD-->>API: Résultats
    API-->>Utilisateur: Réponse
```

**Diagrammes de classes :**

``` r
#| mermaid
#| eval: true
classDiagram
    class Animal {
        +String nom
        +int age
        +faireUnSon()
    }
    class Chien {
        +String race
        +aboyer()
    }
    Animal <|-- Chien
```

### Règles

- Commencer par le commentaire `#| mermaid`
- Ajouter les options de chunk avec le préfixe `#|` (ex:
  `#| eval: true`)
- Le contenu du diagramme suit **sans préfixe `#`**
- Le chunk se termine à la première ligne vide ou ligne de commentaire
- Les options sont automatiquement converties au format Quarto (`%%|`)

### Exemple complet

Voir le fichier d’exemple complet avec plusieurs types de diagrammes :

``` r
# Localiser le fichier exemple Mermaid
mermaid_file <- system.file("examples", "example_mermaid.R", package = "quartify")

# Convertir et rendre
rtoqmd(mermaid_file, render = TRUE, open_html = TRUE)
```

**Plus de ressources Mermaid :**

- [Documentation Mermaid](https://mermaid.js.org/)
- [Éditeur Mermaid en ligne](https://mermaid.live/) - Testez vos
  diagrammes
- [Guide Quarto
  Mermaid](https://quarto.org/docs/authoring/diagrams.html)

## Tabsets (Onglets)

Les tabsets vous permettent d’organiser du contenu connexe dans des
onglets interactifs, parfait pour afficher des vues alternatives,
différentes analyses ou des visualisations groupées. Cette
fonctionnalité utilise la même syntaxe intuitive que les callouts.

### Syntaxe de base

Pour créer un tabset :

1.  **Démarrer le conteneur tabset** : Utilisez `# tabset` sur une ligne
    seule
2.  **Définir chaque onglet** : Utilisez `# tab - Titre de l'onglet` sur
    une ligne seule
3.  **Ajouter du contenu** : Ajoutez des commentaires et du code pour
    chaque onglet
4.  **Fermeture automatique** : Le tabset se ferme au prochain en-tête
    de section

**Syntaxe dans le script R :**

``` r
# tabset
# tab - Statistiques résumées
# Voici les statistiques résumées pour le jeu de données iris :
summary(iris)

# tab - Structure des données
# Examinons la structure des données :
str(iris)

# tab - Premières lignes
# Voici les premières lignes :
head(iris)
```

**Quarto résultant :**

``` markdown
::: {.panel-tabset}

## Statistiques résumées

Voici les statistiques résumées pour le jeu de données iris :


``` r
summary(iris)
#>   Sepal.Length    Sepal.Width     Petal.Length    Petal.Width   
#>  Min.   :4.300   Min.   :2.000   Min.   :1.000   Min.   :0.100  
#>  1st Qu.:5.100   1st Qu.:2.800   1st Qu.:1.600   1st Qu.:0.300  
#>  Median :5.800   Median :3.000   Median :4.350   Median :1.300  
#>  Mean   :5.843   Mean   :3.057   Mean   :3.758   Mean   :1.199  
#>  3rd Qu.:6.400   3rd Qu.:3.300   3rd Qu.:5.100   3rd Qu.:1.800  
#>  Max.   :7.900   Max.   :4.400   Max.   :6.900   Max.   :2.500  
#>        Species  
#>  setosa    :50  
#>  versicolor:50  
#>  virginica :50  
#>                 
#>                 
#> 
```

## Structure des données

Examinons la structure des données :

``` r
str(iris)
#> 'data.frame':    150 obs. of  5 variables:
#>  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
#>  $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
#>  $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
#>  $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
#>  $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
```

## Premières lignes

Voici les premières lignes :

``` r
head(iris)
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa
```

:::

    ### Règles

    - `# tabset` doit être sur une ligne seule (avec des espaces optionnels au début/fin)
    - Chaque onglet commence par `# tab - Titre` où `Titre` est le label de l'onglet
    - Le contenu de l'onglet inclut tous les commentaires et code jusqu'au prochain onglet ou fin du tabset
    - Les tabsets se ferment automatiquement aux en-têtes de section RStudio (`##`, `###`, `####`)
    - Vous pouvez avoir plusieurs tabsets dans le même document
    - Les lignes vides dans les onglets sont préservées

    ### Exemple complet

    Voir le fichier exemple complet avec plusieurs tabsets :

    ```r
    # Localiser le fichier exemple tabset
    tabset_file <- system.file("examples", "example_tabset.R", package = "quartify")

    # Convertir et rendre
    rtoqmd(tabset_file, render = TRUE, open_html = TRUE)

**Plus de ressources sur les tabsets :**

- [Documentation Quarto
  Tabset](https://quarto.org/docs/interactive/layout.html#tabset-panel)
- Combinez les tabsets avec les callouts pour une documentation riche et
  organisée

## Résumé des règles de commentaires

| Type                     | Syntaxe                     | Résultat                | Exemple                      |
|--------------------------|-----------------------------|-------------------------|------------------------------|
| **En-tête niveau 2**     | `## Titre ####`             | Markdown `## Titre`     | `## Analyse de données ####` |
| **En-tête niveau 3**     | `### Titre ====`            | Markdown `### Titre`    | `### Prétraitement ====`     |
| **En-tête niveau 4**     | `#### Titre ----`           | Markdown `#### Titre`   | `#### Supprimer NA ----`     |
| **Commentaire**          | `# Texte`                   | Paragraphe de texte     | `# Ceci filtre les données`  |
| **Callout**              | `# callout-TYPE - Titre`    | Bloc callout Quarto     | `# callout-note - Important` |
| **Diagramme Mermaid**    | `#| mermaid`                | Chunk diagramme Mermaid | `#| mermaid` + contenu       |
| **Tabset**               | `# tabset`, `# tab - Titre` | Panneau à onglets       | `# tabset` + onglets         |
| **Code**                 | Sans préfixe `#`            | Chunk de code R         | `iris %>% filter(...)`       |
| **Commentaire en ligne** | `# Texte` dans code         | Reste dans chunk        | `iris %>% # commentaire`     |

**Règles critiques pour éviter les erreurs :**

1.  **Espacement** : Toujours inclure un espace après `#` pour les
    commentaires et en-têtes de section
2.  **Symboles de fin** : Les en-têtes de section DOIVENT avoir au moins
    4 symboles de fin
3.  **Flexibilité des symboles** : Vous pouvez utiliser `#`, `=`, ou `-`
    indifféremment pour les symboles de fin, mais suivre la convention
    RStudio est recommandé
4.  **Commentaires Roxygen** : Les lignes commençant par `#'` sont
    ignorées (pour développement de packages)
5.  **Contexte du commentaire** : Les commentaires en début de ligne
    deviennent du texte ; les commentaires dans le code restent dans les
    blocs de code
6.  **Raccourci clavier** : Utilisez `Ctrl+Shift+C` (Windows/Linux) ou
    `Cmd+Shift+C` (Mac) pour commenter/décommenter rapidement

## Conseils et bonnes pratiques

1.  **Commencez par la structure** : Définissez d’abord vos titres de
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
Quarto sans reformatage manuel. En suivant les conventions des sections
de code RStudio, vous pouvez automatiquement générer une documentation
bien structurée et reproductible à partir de votre code existant avec
une hiérarchie de navigation appropriée.
