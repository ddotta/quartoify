# Fonctionnalités avancées

🇬🇧 **[English version
available](https://ddotta.github.io/quartify/articles/advanced-features.md)**
/ **Version anglaise disponible**

📖 **Voir aussi :** [Guide de
démarrage](https://ddotta.github.io/quartify/articles/getting-started_FR.md)
pour l’utilisation de base

Cette vignette couvre les fonctionnalités avancées de `quartify`,
notamment les options de personnalisation, le traitement par lots, les
livres Quarto, l’intégration de la qualité du code et les
fonctionnalités spéciales.

## Options de personnalisation

Vous pouvez personnaliser le document de sortie avec plusieurs
paramètres :

``` r
library(quartify)

rtoqmd(
  input_file = "mon_script.R",
  output_file = "mon_document.qmd",
  title = "Mon rapport d'analyse",
  author = "Votre nom",
  format = "html",
  theme = "cosmo",
  render_html = TRUE,
  open_html = TRUE,
  code_fold = TRUE,
  number_sections = TRUE,
  show_source_lines = TRUE
)
```

### Paramètres disponibles

- **`input_file`** : Chemin vers votre script R
- **`output_file`** : Chemin pour le document Quarto de sortie
  (optionnel)
- **`title`** : Titre du document (par défaut : “My title”)
- **`author`** : Nom de l’auteur (par défaut : “Your name”)
- **`format`** : Format de sortie - toujours “html” (paramètre conservé
  pour la rétrocompatibilité)
- **`theme`** : Thème HTML Quarto (par défaut : “cosmo”)
- **`render_html`** : Indique s’il faut générer le .qmd en HTML (par
  défaut : TRUE)
- **`output_html_file`** : Chemin personnalisé pour la sortie HTML
  (optionnel)
- **`open_html`** : Indique s’il faut ouvrir le fichier HTML après le
  rendu (par défaut : FALSE)
- **`code_fold`** : Indique s’il faut replier les blocs de code par
  défaut (par défaut : FALSE)
- **`number_sections`** : Indique s’il faut numéroter automatiquement
  les sections (par défaut : TRUE)
- **`show_source_lines`** : Afficher les numéros de ligne originaux dans
  les chunks de code (par défaut : TRUE)
- **`lang`** : Langue pour les éléments d’interface (“en” ou “fr”, par
  défaut : “en”)

### Thèmes HTML

`quartify` supporte plus de 25 thèmes Quarto pour la sortie HTML :

**Thèmes clairs** : cosmo, flatly, litera, lumen, lux, materia, minty,
morph, pulse, quartz, sandstone, simplex, sketchy, spacelab, united,
yeti, zephyr

**Thèmes sombres** : cyborg, darkly, slate, solar, superhero, vapor

**Mixte** : cerulean (clair-sombre)

Essayez différents thèmes pour trouver le look parfait :

``` r
# Moderne et épuré
rtoqmd("script.R", theme = "cosmo")

# Mode sombre
rtoqmd("script.R", theme = "darkly")

# Style académique
rtoqmd("script.R", theme = "litera")
```

## Conversion par lots de répertoires

### Utilisation de rtoqmd_dir()

Convertissez tous les scripts R d’un répertoire (y compris les
sous-répertoires) par programmation :

``` r
# Convertir tous les scripts R d'un répertoire
rtoqmd_dir("chemin/vers/scripts")

# Convertir et générer en HTML
rtoqmd_dir("chemin/vers/scripts", render_html = TRUE)

# Avec auteur personnalisé et préfixe de titre
rtoqmd_dir("chemin/vers/scripts", 
           author = "Votre nom",
           title_prefix = "Projet : ")
```

### Via l’interface Shiny

1.  **Lancez l’addin RStudio** ou
    [`quartify_app()`](https://ddotta.github.io/quartify/reference/quartify_app.md)
2.  **Sélectionnez le mode “Répertoire”** dans l’interface
3.  **Choisissez le répertoire** contenant vos scripts R
4.  **Configurez les options** (auteur, thème, etc.)
5.  **Cliquez sur GENERATE**

Tous les fichiers `.R` seront convertis en fichiers `.qmd`
correspondants dans la même structure de répertoires.

## Création de livres Quarto

`quartify` peut créer automatiquement un livre Quarto à partir d’un
répertoire de scripts R, en générant un fichier `_quarto.yml` avec table
des matières.

### Méthode 1 : Via l’interface Shiny

1.  Lancez l’addin ou
    [`quartify_app()`](https://ddotta.github.io/quartify/reference/quartify_app.md)
2.  Sélectionnez le mode “Répertoire”
3.  Choisissez votre répertoire de scripts
4.  **Cochez “Créer un livre Quarto”**
5.  Cliquez sur GENERATE

### Méthode 2 : Par programmation

``` r
# Créer un livre Quarto avec table des matières
rtoqmd_dir(
  dir_path = "chemin/vers/scripts",
  create_book = TRUE,
  output_dir = "_book",  # Répertoire de sortie
  render_html = TRUE,
  author = "Votre nom"
)
```

### Structure du livre

Le livre généré inclut :

- **`_quarto.yml`** : Configuration du livre avec table des matières
  automatique
- **`index.qmd`** : Page d’accueil du livre
- **Fichiers `.qmd`** : Un pour chaque script R, organisés par structure
  de répertoires
- **Rendu HTML** : Si `render_html = TRUE`, génère le site web complet

La table des matières respecte votre structure de répertoires et inclut
des sections pour chaque sous-répertoire.

## Intégration de la qualité du code

`quartify` s’intègre avec **styler** et **lintr** pour fournir des
vérifications automatiques de la qualité du code et des suggestions de
formatage directement dans votre documentation générée. Ceci est
particulièrement utile pour :

- **Matériel pédagogique** : Montrez aux étudiants à la fois le code
  original et le code correctement formaté
- **Revue de code** : Identifiez automatiquement les problèmes de style
  dans la documentation
- **Meilleures pratiques** : Apprenez le guide de style tidyverse par
  l’exemple
- **Contrôle qualité** : Assurez un style de code cohérent dans tous les
  projets

### Aperçu des fonctionnalités

- **`use_styler = TRUE`** : Affiche le code formaté selon le [guide de
  style tidyverse](https://style.tidyverse.org/)
- **`use_lintr = TRUE`** : Identifie les problèmes de qualité du code et
  les problèmes potentiels
- **`apply_styler = TRUE`** : Applique directement le formatage à votre
  script R original (⚠️ modifie le fichier source)

Lorsque des problèmes de qualité sont détectés, `quartify` crée des
**tabsets interactifs** dans la sortie HTML avec :

- **Code original** : Votre code tel qu’écrit
- **Code stylisé** : Version formatée (affiché uniquement si des
  changements sont nécessaires)
- **Problèmes Lint** : Avertissements de qualité (affiché uniquement si
  des problèmes sont trouvés)

**Tabsets intelligents** : Les tabsets ne sont créés que lorsque
nécessaire. S’il n’y a pas de changements de style ou de problèmes lint,
vous obtenez un chunk de code régulier (pas de tabset).

### Installation

Les fonctionnalités de qualité du code nécessitent des dépendances
optionnelles :

``` r
install.packages(c("styler", "lintr"))
```

Ces packages ne sont chargés que lorsque vous utilisez les
fonctionnalités de qualité du code.

### Utilisation de base

#### Afficher les suggestions de style

``` r
# Afficher le code stylisé dans des tabsets
rtoqmd("script.R", "output.qmd", 
       use_styler = TRUE,
       render_html = TRUE)
```

Cela génère des tabsets montrant à la fois le code original et le code
stylisé côte à côte.

#### Afficher les problèmes Lint

``` r
# Afficher les problèmes de qualité du code
rtoqmd("script.R", "output.qmd", 
       use_lintr = TRUE,
       render_html = TRUE)
```

Cela ajoute un onglet “Problèmes Lint” avec des retours de qualité
détaillés.

#### Vérifications de qualité combinées

``` r
# Afficher à la fois le style et les problèmes lint
rtoqmd("script.R", "output.qmd",
       use_styler = TRUE,
       use_lintr = TRUE,
       render_html = TRUE,
       open_html = TRUE)
```

Cela crée des rapports de qualité complets avec trois onglets : 1. Code
original 2. Code stylisé 3. Problèmes Lint

### Application de styles aux fichiers sources

**⚠️ Avertissement** : `apply_styler = TRUE` **modifie votre fichier de
script R original**. Utilisez toujours le contrôle de version ou créez
des sauvegardes avant d’utiliser cette option.

``` r
# Appliquer le style directement au fichier source
rtoqmd("mon_script.R", "output.qmd",
       use_styler = TRUE,
       apply_styler = TRUE)
```

**Important** : Quand `apply_styler = TRUE` :

1.  Votre fichier R source est modifié avant la conversion
2.  Aucun tabset n’est créé (le source est déjà stylisé)
3.  `use_styler` doit également être TRUE
4.  La conversion utilise le fichier source stylisé

Ceci est utile pour :

- Nettoyer le code avant de le valider dans le contrôle de version
- Formater plusieurs scripts par lots
- Préparer le code pour publication ou enseignement

### Exemple avec qualité du code

Essayez l’exemple inclus qui démontre les fonctionnalités de qualité du
code :

``` r
# Localiser le fichier d'exemple
example_file <- system.file("examples", "example_code_quality.R", 
                           package = "quartify")

# Voir le contenu du fichier pour voir les problèmes de style intentionnels
file.show(example_file)

# Convertir avec les deux vérifications
rtoqmd(example_file, "quality_demo.qmd", 
       use_styler = TRUE, 
       use_lintr = TRUE,
       render_html = TRUE,
       open_html = TRUE)
```

Le fichier d’exemple inclut des problèmes de style intentionnels :

``` r
# Voici du code avec des problèmes de style
x = 3  # Devrait utiliser <- au lieu de =
y <- 2
z<-10  # Espaces manquants autour de <-

# Calculer des statistiques
mean_value<-mean(c(x,y,z)) # Espaces manquants

# Créer un vecteur avec espacement incohérent
my_vector<-c(1,2,3,4,5)
```

### Exemple de sortie

Étant donné du code avec des problèmes de style :

``` r
x = 3  # Devrait utiliser <- au lieu de =
y <- 2
z<-10  # Espaces manquants
```

Avec `use_styler = TRUE` et `use_lintr = TRUE`, vous verrez un tabset :

**Onglet Code original :**

``` r
x = 3  # Devrait utiliser <- au lieu de =
y <- 2
z<-10  # Espaces manquants
```

**Onglet Code stylisé :**

``` r
x <- 3 # Devrait utiliser <- au lieu de =
y <- 2
z <- 10 # Espaces manquants
```

**Onglet Problèmes Lint :** - Ligne 1 : Utilisez `<-` ou `<<-` pour
l’affectation, pas `=`. - Ligne 3 : Mettez des espaces autour de tous
les opérateurs infixes.

### Traitement par lots avec vérifications de qualité

Appliquez des vérifications de qualité du code à des répertoires entiers
:

``` r
# Convertir un répertoire avec vérifications de qualité
rtoqmd_dir(
  dir_path = "mes_scripts/",
  output_html_dir = "documentation/",
  use_styler = TRUE,
  use_lintr = TRUE,
  render_html = TRUE
)
```

Cela applique les vérifications de qualité du code à chaque script R du
répertoire.

### Utilisation dans les applications Shiny

Les trois applications Shiny
([`rtoqmd_addin()`](https://ddotta.github.io/quartify/reference/rtoqmd_addin.md),
[`quartify_app()`](https://ddotta.github.io/quartify/reference/quartify_app.md),
et
[`quartify_app_web()`](https://ddotta.github.io/quartify/reference/quartify_app_web.md))
incluent des cases à cocher pour les options de qualité du code :

- ☑️ **Use styler formatting** (affiche la version stylisée dans les
  onglets)
- ☑️ **Use lintr quality checks** (affiche les problèmes dans les
  onglets)
- ☑️ **Apply styler to source file** (modifie le fichier R original) -
  *Non disponible dans la version web*

Cochez simplement les options souhaitées avant de cliquer sur GENERATE.

### Avantages de l’intégration de la qualité du code

1.  **Apprendre par l’exemple** : Voyez le style de codage R approprié à
    côté de votre code
2.  **Revue de code** : Retour de qualité automatique sans revue
    manuelle
3.  **Outil pédagogique** : Parfait pour le matériel éducatif et les
    tutoriels
4.  **Documentation** : Générez du code propre et bien stylisé dans la
    documentation
5.  **Meilleures pratiques** : Appliquez automatiquement le guide de
    style tidyverse
6.  **Cohérence** : Maintenez un style de code uniforme dans tous les
    projets

### Configuration

styler et lintr utilisent tous deux leurs configurations par défaut.
Pour des paramètres personnalisés :

- **styler** : Créez un fichier `.styler.R` à la racine de votre projet
- **lintr** : Créez un fichier `.lintr` à la racine de votre projet

Voir leur documentation respective : - [Documentation
styler](https://styler.r-lib.org/) - [Documentation
lintr](https://lintr.r-lib.org/)

### Notes de performance

- Les vérifications de qualité du code ajoutent un temps de traitement
  minimal (typiquement \< 1 seconde par chunk)
- Les vérifications ne s’exécutent que lorsque les paramètres sont TRUE
  (par défaut : FALSE)
- Convient aux workflows interactifs et automatisés
- Pour les très grands projets, envisagez la conversion sélective

### Dépannage

**Packages non trouvés :**

``` r
install.packages("styler")  # Pour le formatage
install.packages("lintr")   # Pour le linting
```

**Les vérifications échouent pour des chunks spécifiques :**

Si les vérifications de qualité du code échouent pour un chunk de code
particulier, le code original est affiché sans tabset, et un
avertissement est enregistré. La conversion continue normalement.

## Fonctionnalités spéciales

### Diagrammes Mermaid

`quartify` supporte les diagrammes
[Mermaid](https://mermaid-js.github.io/) dans vos scripts R. Utilisez
des commentaires spéciaux pour inclure des diagrammes dans votre
documentation :

``` r
# mermaid-start
# graph TD
#   A[Début] --> B{Ça fonctionne ?}
#   B -->|Oui| C[Super !]
#   B -->|Non| D[Déboguer]
#   D --> A
# mermaid-end
```

Cela s’affiche comme un organigramme dans votre document Quarto.

### Callouts

Créez des callouts dans vos scripts R en utilisant une syntaxe de
commentaire spéciale :

``` r
# callout-note - Note importante
# Ceci est un callout de note
# Il peut s'étendre sur plusieurs lignes

# callout-warning - Soyez prudent
# Ceci est un callout d'avertissement

# callout-tip - Conseil de pro
# Ceci est un callout de conseil
```

Types de callout supportés : `note`, `warning`, `tip`, `important`,
`caution`

### Snippets RStudio

Installez des snippets de code utiles pour une écriture de script R plus
rapide :

``` r
install_quartify_snippets()
```

Après installation et redémarrage de RStudio, vous pouvez utiliser :

- **`header`** + Tab : Insérer un modèle de métadonnées de document
- **`callout`** + Tab : Insérer un modèle de callout
- **`mermaid`** + Tab : Insérer un modèle de diagramme Mermaid
- **`tabset`** + Tab : Insérer un modèle de tabset

## Conseils et bonnes pratiques

### Structuration de vos scripts

1.  **Commencez par la structure** : Définissez d’abord vos en-têtes de
    section pour créer le plan du document
2.  **Utilisez des niveaux cohérents** : Suivez une hiérarchie logique
    (2 → 3 → 4, ne sautez pas de niveaux)
3.  **Ajoutez du texte explicatif** : Utilisez des commentaires
    réguliers pour expliquer ce que fait votre code
4.  **Groupez le code connexe** : Gardez les opérations liées ensemble
5.  **Naviguez facilement** : Dans RStudio, utilisez le plan du document
    (Ctrl+Shift+O) pour voir votre structure

### Qualité du code

6.  **Utilisez les vérifications de qualité du code pour
    l’enseignement** : Activez `use_styler` et `use_lintr` pour le
    matériel éducatif
7.  **Apprenez du code stylisé** : Examinez les onglets “Code stylisé”
    pour apprendre les meilleures pratiques
8.  **Corrigez les problèmes de manière incrémentale** : Utilisez les
    retours lint pour améliorer progressivement la qualité du code
9.  **Contrôle de version avant apply_styler** : Validez toujours avant
    d’utiliser `apply_styler = TRUE`

### Conversion par lots

10. **Utilisez le mode Répertoire pour les projets** : Convertissez des
    dossiers de projet entiers avec l’option Créer un livre
11. **Excluez les fichiers de test** : Utilisez `exclude_pattern` pour
    ignorer les scripts de test dans la conversion par lots
12. **Organisez par sous-répertoires** : Tirez parti de la conversion
    récursive pour maintenir la structure du projet
13. **Définissez les répertoires de sortie** : Gardez les scripts R
    sources séparés de la documentation générée

### Workflow de documentation

14. **Commentez librement** : Plus de commentaires = meilleure
    documentation
15. **Utilisez les métadonnées** : Ajoutez Titre, Auteur, Date et
    Description en haut des scripts
16. **Testez de manière incrémentale** : Commencez avec un petit script
    pour comprendre le comportement de conversion
17. **Prévisualisez fréquemment** : Utilisez `render_html = TRUE` et
    `open_html = TRUE` pour voir les résultats immédiatement

### Intégration CI/CD

18. **Automatisez la documentation** : Utilisez GitHub Actions ou GitLab
    CI pour générer la documentation lors des validations
19. **Contrôle de version .R uniquement** : Générez les fichiers .qmd et
    .html dans CI/CD, pas dans votre dépôt
20. **Déployez sur GitHub Pages** : Publiez automatiquement la
    documentation à chaque push

## Prochaines étapes

- **Utilisation de base** : Voir [Guide de
  démarrage](https://ddotta.github.io/quartify/articles/getting-started_FR.md)
  pour les fondamentaux
- **Version anglaise** : [English
  version](https://ddotta.github.io/quartify/articles/advanced-features.md)
- **Dépôt GitHub** :
  [ddotta/quartify](https://github.com/ddotta/quartify)
- **Signaler des problèmes** : [GitHub
  Issues](https://github.com/ddotta/quartify/issues)

## Conclusion

Les fonctionnalités avancées de `quartify` permettent des workflows de
documentation sophistiqués, des vérifications de qualité du code à la
génération automatique de livres. Expérimentez avec ces fonctionnalités
pour trouver le meilleur workflow pour vos projets !
