# Exigences du projet

Cahier des charges de l'outil de calibrage des USP (Solvabilité II, annexe XVII). Il fixe ce que doivent respecter le code, la documentation et l'application, quelle que soit la personne ou l'agent qui intervient.

## 1. Cadre

- Le travail prépare des éléments destinés à un **dossier soumis à l'ACPR**. La rigueur statistique, mathématique, bibliographique et réglementaire, ainsi que la **traçabilité entre documentation, code et résultats**, sont prioritaires.
- Champ : paramètres propres à l'entreprise, en particulier pour le risque de prime.
- Taille d'échantillon d'intérêt : **T = 8**. Cette faible taille doit être explicitement prise en compte dans **toutes** les conclusions statistiques.
- Les livrables évoluent, ils ne sont pas réécrits : on part toujours de la version la plus récente du code et de la documentation, et des choix méthodologiques déjà arbitrés. Une formule, un test ou un choix déjà corrigé n'est jamais réintroduit dans son ancienne version.
- Avant toute modification, vérifier la cohérence entre le code, la documentation et les décisions méthodologiques antérieures.

## 2. Rigueur statistique

Quatre statuts ne doivent jamais être confondus :

1. résultat exact ;
2. résultat asymptotique ;
3. approximation numérique ;
4. comportement empirique observé par simulation.

En particulier :

- une simulation favorable à T = 8 ne transforme pas une approximation asymptotique en résultat exact ;
- l'existence d'un résultat asymptotique ne garantit pas sa précision à T = 8 ;
- la précision Monte-Carlo liée au nombre B de réplications ne doit pas être confondue avec la qualité de l'approximation statistique liée à T ;
- l'implémentation par défaut d'une fonction R ne constitue pas en elle-même une justification théorique.

Vérifier les hypothèses de chaque résultat théorique invoqué. Si plusieurs variantes d'un test existent, identifier précisément celle qui est utilisée. Si une fonction R change de méthode selon la taille de l'échantillon, la présence d'ex-æquo, ses options ou d'autres conditions, documenter le comportement effectivement pertinent pour notre cas.

Signaler explicitement tout test dont l'usage paraît fragile ou difficile à justifier à T = 8, et proposer si pertinent une alternative ou un complément — sans jamais remplacer silencieusement la méthode existante.

## 3. Documentation statistique (LaTeX)

### 3.1 Inventaire des tests

La documentation établit la liste exacte des tests réellement utilisés dans le code. Pour chacun : nom exact, H0 et H1, statistique de test, fonction R ou implémentation, méthode de calcul de la p-value, existence d'une loi exacte sous H0, d'une approximation asymptotique, pertinence d'une méthode bootstrap / Monte-Carlo, références.

Les développements déjà corrects sont complétés et corrigés, pas réécrits sans nécessité.

### 3.2 Tableau 1 — disponibilité et choix des p-values

Colonnes minimales :

1. Test
2. Statistique considérée
3. P-value exacte disponible ?
4. P-value asymptotique disponible ?
5. P-value bootstrap / Monte-Carlo disponible ou nécessaire ?
6. Méthode effectivement utilisée dans le code
7. Pour T = 8, la p-value asymptotique peut-elle raisonnablement être retenue ?
8. Recommandation méthodologique pour le dossier ACPR
9. Référence justifiant la conclusion

La colonne 7 fait l'objet d'une analyse spécifique et nuancée (« Oui », « Non », « Sous conditions », « Déconseillée à T = 8 », « Absence de justification théorique suffisante », « À utiliser uniquement comme analyse complémentaire », « Bootstrap recommandé », « Distribution exacte à privilégier »…). Une approximation asymptotique n'est jamais jugée fiable à T = 8 au seul motif qu'elle est standard, courante ou implémentée par défaut. Distinguer l'existence théorique d'une loi asymptotique, la vitesse de convergence, et la qualité pratique de l'approximation à T = 8. Quand la littérature ne permet pas de conclure, l'écrire.

### 3.3 Tableau 2 — nature et vitesse des convergences

Pour chaque test, identifier l'objet qui converge : (A) la loi de la statistique vers une loi limite ; (B) un estimateur numérique de la p-value (bootstrap, Monte-Carlo) ; (C) les deux, s'ils correspondent à deux phénomènes distincts.

Colonnes minimales :

1. Test
2. Objet qui converge
3. Limite
4. Nature de la convergence
5. Vitesse ou ordre de convergence
6. Hypothèses nécessaires
7. Conséquence pratique pour T = 8
8. Référence bibliographique

Terminologie précise lorsqu'elle est pertinente : convergence en loi, en probabilité, presque sûre, dans Lp ; résultat de type TCL ; borne de type Berry-Esseen ; convergence bootstrap ; erreur Monte-Carlo. Distinguer impérativement la convergence en fonction de T et celle de l'estimateur de p-value en fonction de B ; pour une p-value estimée par simulation, traiter séparément l'erreur Monte-Carlo (liée à B) et l'erreur d'approximation statistique (liée à T).

### 3.4 Bibliographie

- Privilégier les articles originaux, ouvrages de référence et publications académiques reconnues.
- Vérifier que chaque référence soutient réellement l'affirmation.
- Ne fabriquer aucune référence, aucun théorème, numéro de page ou vitesse de convergence.
- Comparer la référence pertinente avec celle déjà utilisée. Si elle diffère : le dire, conserver l'ancienne si elle reste utile, ajouter la nouvelle et expliquer pourquoi elle est nécessaire ou préférable. Si la référence actuelle suffit, la garder.
- Quand la littérature ne fournit pas de résultat assez précis pour conclure à T = 8, l'indiquer.

## 4. Architecture

### 4.1 Moteur unique

**Tous** les calculs statistiques, actuariels, de calibration, de tests, de bootstrap / Monte-Carlo, et plus généralement toute logique quantitative, sont centralisés dans un fichier unique : **`R/engine.R`**. Il contient notamment : préparation et transformation des données, contrôles statistiques et de validité métier, calculs actuariels, calcul du sigma, statistiques descriptives, statistiques de test, p-values, tests, bootstrap, Monte-Carlo, gestion des graines, estimations intermédiaires, calibration, bornes et contraintes, paramètre final retenu, et les quantités nécessaires aux graphiques.

Règle fondamentale : **si un résultat peut être calculé indépendamment de l'interface, son calcul est dans `engine.R`.**

Le moteur n'est pas éclaté en fichiers thématiques (`statistical_tests.R`, `calibration.R`, `bootstrap.R`…) : il reste un fichier quantitatif unique, pour permettre une revue indépendante.

### 4.2 Autonomie du moteur

`engine.R` est utilisable sans Shiny (`source("R/engine.R")` puis appel direct depuis une session R, un script, un test ou une validation externe). Il ne dépend d'aucun objet Shiny (`input$`, `output$`, `reactive()`, `reactiveVal()`, `reactiveValues()`, `observe()`, `observeEvent()`, `eventReactive()`, `render*()`…). Les entrées sont des arguments R explicites ; les sorties sont des objets R standards et auditables (listes, data.frames, vecteurs, matrices). Les fonctions documentent leurs entrées, sorties, hypothèses, paramètres, graines et dépendances.

### 4.3 Orchestration

Une fonction principale, `run_engine()`, lance toute la chaîne de calcul à partir des données, des paramètres utilisateur, des paramètres de simulation et de la graine, et retourne un objet structuré contenant tous les résultats nécessaires à l'application. L'application se limite à : collecter les entrées, appeler `run_engine()`, conserver l'objet retourné, afficher ses éléments — sans reconstruire de résultats à partir de calculs dispersés.

### 4.4 Couche d'affichage

Hors de `engine.R`, le code est de l'interface et de l'affichage.

- **Autorisé** : définition de l'UI, onglets, panneaux, champs de saisie, boutons, édition du tableau des données, lecture des saisies, déclenchement de `run_engine()`, stockage réactif du résultat, mise en forme des tableaux, formatage des nombres, textes, notifications, construction visuelle des graphiques à partir de quantités déjà calculées par le moteur. Les choix purement visuels (titres, axes, décimales, organisation d'une table) restent dans l'affichage.
- **Réservé au moteur** : toute statistique, toute moyenne ou variance faisant partie de la méthodologie, le sigma, les p-values, tout appel à un test statistique, le bootstrap, le Monte-Carlo, l'estimation de paramètres, la calibration, la sélection du paramètre final, toute transformation quantitative déterminante, toute règle métier actuarielle.

Structure : `app.R`, `R/engine.R`, et facultativement `R/ui_helpers.R` et `R/display_helpers.R`, sans logique quantitative substantielle.

### 4.5 Reproductibilité

L'application reproduit les résultats du moteur à données, paramètres, graines et paramètres de simulation identiques. Toute différence de résultat est identifiée, quantifiée et expliquée.

## 5. Application Shiny

### 5.1 Disposition générale

- Une zone principale de restitution et un **panneau de paramètres à droite**, contenant les paramètres de calcul pertinents.
- Un bouton explicite, **« Relancer les calculs »**. Modifier les données ou les paramètres ne change que les entrées ; seul le clic appelle le moteur, qui retourne un objet complet ; les onglets affichent cet objet sans recalculer. Les modifications ne déclenchent jamais automatiquement la chaîne de calcul.

### 5.2 Onglet Données

- Visualiser les données de base (xt, yt) avec l'indice ou la période t ;
- modifier xt et yt directement dans l'application ;
- contrôler la validité des valeurs saisies, avec un message explicite en cas de valeur incompatible — sans jamais modifier silencieusement les données ;
- réinitialiser, si pertinent, aux valeurs initiales.

Les données modifiées sont utilisées au prochain clic sur « Relancer les calculs ». Les contrôles purement liés à l'interface peuvent rester dans Shiny ; tout contrôle ayant une signification statistique, actuarielle ou métier est **aussi** implémenté dans `engine.R`.

### 5.3 Onglet Tests

Regroupe les résultats de **tous** les tests présents dans le code, en conservant autant que possible la logique de présentation existante. Pour chaque test, lorsque pertinent : nom, H0 et H1, statistique observée, p-value, nature de la p-value (exacte, asymptotique, bootstrap / Monte-Carlo), seuil de décision, conclusion, et un avertissement lorsque T = 8 rend l'interprétation délicate. L'affichage permet une lecture synthétique et une revue détaillée. Toutes les valeurs proviennent de `engine.R`.

### 5.4 Onglets graphiques

Reprennent les graphiques statistiquement pertinents, organisés lisiblement (données, diagnostics, distributions, résidus ou écarts, hypothèses des tests, calibration…). Aucun graphique existant n'est supprimé sans raison méthodologique explicite. Résidus, quantiles, statistiques, distributions théoriques, intervalles, valeurs ajustées, indicateurs et simulations sont calculés dans `engine.R` ; l'affichage ne fait que les représenter.

### 5.5 Onglet Calibration

Présente clairement :

- les principales données ou quantités entrant dans la calibration ;
- les estimations intermédiaires ;
- le sigma calculé ;
- les éventuelles transformations ou contraintes ;
- les différentes valeurs candidates lorsqu'elles existent ;
- le paramètre finalement retenu.

Le paramètre retenu est immédiatement identifiable visuellement, et la logique conduisant à sa sélection est compréhensible.

### 5.6 Rapport figé

Un bouton de l'application produit un **document HTML autonome** : un seul fichier, lisible hors ligne, sans aucune ressource externe (script, feuille de style, police ou image chargée par URL). Le rapport fige un résultat du moteur :

- il est construit à partir de l'objet retourné par `run_engine()` au dernier clic sur « Relancer les calculs », et **jamais** à partir de la saisie courante ; il n'est proposé que si le moteur a accepté les données ;
- il ne fait aucun calcul : toutes les valeurs, y compris les empreintes, proviennent de `engine.R` ;
- un en-tête identifie le calcul : horodatage, méthode, annexe et segment, T, B, α, graine, barème de crédibilité, σ standard, version de R, version de l'outil (`DESCRIPTION`), empreinte md5 de `R/engine.R`, empreintes des données et du résultat ; il indique que l'empreinte du résultat dépend de la plateforme ;
- il restitue les données et leurs contrôles, le paramètre retenu et sa calibration, les tests, les graphiques et les notes, avec l'avertissement lié à T = 8 ;
- les tests restitués sont ceux que retient la personnalisation de l'onglet Tests, selon la même règle ; un encadré rappelle que cette sélection est une personnalisation de la restitution, sans effet sur le calcul, et les tests exclus sont listés en annexe avec leur verdict ;
- les graphiques sont interactifs par défaut ; une option les fige en images intégrées au fichier, et leur absence éventuelle est signalée explicitement.
