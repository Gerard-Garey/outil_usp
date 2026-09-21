<role>
Tu interviens comme expert senior en statistique actuarielle, validation quantitative, réglementation Solvabilité II, R, R Shiny et LaTeX.

Le travail s'inscrit dans la préparation d'éléments susceptibles d'être intégrés à un dossier destiné à l'ACPR.

La rigueur statistique, mathématique, bibliographique, réglementaire et la traçabilité entre documentation, code et résultats sont donc prioritaires. </role>

<context>
Nous travaillons sur les paramètres spécifiques dans le cadre de la réglementation Solvabilité II en assurance, en particulier sur le risque de prime.

Au cours de CETTE CONVERSATION, tu as déjà produit et fait évoluer deux livrables :

1. un script R permettant notamment :

   * de calculer le sigma associé aux paramètres propres pour le risque de prime ;
   * d'appliquer plusieurs tests statistiques ;
   * de produire des diagnostics et résultats graphiques ;
   * de réaliser la calibration conduisant au paramètre retenu ;

2. une documentation LaTeX détaillant notamment les tests statistiques utilisés et leur justification.

Ces fichiers ainsi que les échanges précédents de cette conversation constituent le point de départ du présent travail.

Tu dois donc t'appuyer sur :

* les versions les plus récentes des fichiers déjà générés dans cette conversation ;
* les choix méthodologiques effectués précédemment ;
* les explications, conventions, corrections et arbitrages déjà établis dans les échanges antérieurs.

Ne redemande pas les fichiers s'ils sont déjà accessibles dans le contexte de la conversation.

Ne repars pas de zéro : fais évoluer les livrables existants. </context>

<source_of_truth>
Avant toute modification :

1. identifie les versions les plus récentes du script R et de la documentation LaTeX présentes dans la conversation ;
2. relis les éléments précédents de la conversation nécessaires pour comprendre les choix déjà effectués ;
3. considère ces versions comme la référence à modifier ;
4. vérifie la cohérence entre le script, la documentation et les décisions méthodologiques précédemment prises.

Si plusieurs versions d'un même fichier existent dans la conversation, utilise la version la plus récente sauf raison explicite et justifiée de revenir à une version antérieure.

Ne réintroduis pas une ancienne version d'une formule, d'un test ou d'un choix méthodologique qui aurait déjà été corrigé au cours de la conversation.
</source_of_truth>

<objective>
Deux évolutions sont demandées :

A. renforcer la documentation statistique LaTeX sur :

* la nature des p-values ;
* leur caractère exact, asymptotique ou bootstrap / Monte-Carlo ;
* la pertinence de l'utilisation des approximations asymptotiques pour T = 8 ;
* la nature et la vitesse des convergences associées ;

B. transformer le script R existant en une application R Shiny permettant une utilisation interactive, reproductible et auditable.

La taille d'échantillon d'intérêt est :

T = 8.

Cette faible taille d'échantillon doit être explicitement prise en compte dans toutes les conclusions statistiques. </objective>

<task_1_statistical_documentation>
Pars de la documentation LaTeX existante et du script R existant.

Commence par établir la liste exacte des tests statistiques réellement utilisés dans la version actuelle du script.

Pour chacun d'eux, identifie :

* le nom exact du test ;
* les hypothèses H0 et H1 ;
* la statistique de test ;
* la fonction R ou l'implémentation utilisée ;
* la méthode actuellement utilisée pour calculer la p-value ;
* l'existence éventuelle d'une distribution exacte sous H0 ;
* l'existence d'une approximation asymptotique ;
* l'existence ou la pertinence d'une méthode bootstrap / Monte-Carlo ;
* les références déjà présentes dans la documentation.

Ne modifie pas inutilement les développements déjà corrects : complète et corrige la documentation actuelle plutôt que de la réécrire intégralement sans nécessité.
</task_1_statistical_documentation>

<table_1>
Ajoute à la documentation un premier tableau de synthèse comportant au minimum les colonnes suivantes :

1. Test
2. Statistique considérée
3. P-value exacte disponible ?
4. P-value asymptotique disponible ?
5. P-value bootstrap / Monte-Carlo disponible ou nécessaire ?
6. Méthode effectivement utilisée dans le script
7. Pour T = 8, la p-value asymptotique peut-elle raisonnablement être retenue ?
8. Recommandation méthodologique pour le dossier ACPR
9. Référence justifiant la conclusion

La colonne concernant T = 8 doit faire l'objet d'une analyse spécifique.

Ne réponds pas uniquement par "oui" ou "non" lorsqu'une nuance est nécessaire.

Utilise, lorsque pertinent, des formulations telles que :

* Oui ;
* Non ;
* Sous conditions ;
* Déconseillée à T = 8 ;
* Absence de justification théorique suffisante ;
* À utiliser uniquement comme analyse complémentaire ;
* Bootstrap recommandé ;
* Distribution exacte à privilégier.

Ne déduis jamais qu'une approximation asymptotique est suffisamment fiable à T = 8 simplement parce qu'elle est standard, couramment utilisée ou implémentée par défaut dans un logiciel.

Distingue explicitement :

* l'existence théorique d'une loi asymptotique ;
* la vitesse de convergence vers cette loi ;
* la qualité pratique de l'approximation pour T = 8.

Lorsque la littérature ne permet pas d'établir de justification suffisamment robuste pour T = 8, indique-le clairement plutôt que de fournir une conclusion artificiellement précise.
</table_1>

<table_2>
Ajoute un second tableau consacré à la nature et à la vitesse de convergence.

Pour chaque test, détermine si l'objet pertinent est :

A. la convergence de la loi de la statistique de test vers une loi limite ;

B. la convergence d'un estimateur numérique de la p-value, notamment bootstrap ou Monte-Carlo ;

C. les deux, lorsqu'ils correspondent à deux phénomènes distincts.

Le tableau doit comporter au minimum :

1. Test
2. Objet qui converge
3. Limite
4. Nature de la convergence
5. Vitesse ou ordre de convergence
6. Hypothèses nécessaires
7. Conséquence pratique pour T = 8
8. Référence bibliographique

Utilise une terminologie mathématiquement précise lorsque pertinente :

* convergence en loi ;
* convergence en probabilité ;
* convergence presque sûre ;
* convergence dans Lp ;
* résultat de type TCL ;
* borne ou résultat de type Berry-Esseen ;
* convergence bootstrap ;
* erreur Monte-Carlo.

Distingue impérativement :

* la convergence en fonction de T ;
* la convergence de l'estimateur de p-value en fonction du nombre B de réplications bootstrap / Monte-Carlo.

Lorsqu'une p-value est estimée par B simulations, traite séparément :

* l'erreur Monte-Carlo associée à B ;
* l'erreur ou l'approximation statistique associée à T.

Ne confonds jamais ces deux sources d'erreur.
</table_2>

<bibliography>
La justification bibliographique doit être suffisamment robuste pour un dossier soumis à revue.

Pour chaque affirmation théorique importante :

* privilégie les articles originaux, ouvrages de référence ou publications académiques reconnues ;
* vérifie que la référence supporte réellement l'affirmation effectuée ;
* ne fabrique aucune référence ;
* ne fabrique aucun résultat, théorème, numéro de page ou vitesse de convergence.

Compare systématiquement la référence pertinente avec celle actuellement utilisée dans la documentation existante.

Si la référence appropriée est différente de celle déjà retenue :

1. indique-le explicitement ;
2. conserve l'ancienne référence si elle reste utile ;
3. ajoute la nouvelle référence dans la bibliographie LaTeX ;
4. explique brièvement pourquoi cette nouvelle référence est nécessaire ou préférable.

Si la référence actuelle suffit, ne la remplace pas uniquement pour produire du changement.

Lorsque la littérature ne fournit pas de résultat suffisamment précis pour conclure à T = 8, indique-le explicitement. </bibliography>

<statistical_rigor>
La distinction suivante doit être systématique :

1. résultat exact ;
2. résultat asymptotique ;
3. approximation numérique ;
4. comportement empirique observé par simulation.

Ces quatre éléments ne doivent pas être confondus.

En particulier :

* une simulation favorable pour T = 8 ne transforme pas une approximation asymptotique en résultat exact ;
* l'existence d'un résultat asymptotique ne garantit pas sa précision à T = 8 ;
* la précision Monte-Carlo liée à B ne doit pas être confondue avec la qualité de l'approximation statistique liée à T ;
* l'implémentation par défaut d'une fonction R ne constitue pas en elle-même une justification théorique.

Vérifie les hypothèses nécessaires à chaque résultat théorique invoqué.

Si plusieurs variantes d'un même test existent, identifie précisément celle utilisée dans le script.

Si une fonction R change de méthode selon la taille de l'échantillon, la présence de ties, certaines options ou d'autres conditions, documente précisément le comportement effectivement pertinent pour notre cas.

Signale explicitement tout test dont l'utilisation actuelle paraît fragile ou difficile à justifier pour T = 8.

Dans ce cas, propose une alternative ou un complément méthodologique lorsque cela est pertinent, mais ne remplace jamais silencieusement la méthode existante.
</statistical_rigor>

<task_2_shiny>
Transforme ensuite le script R actuel en application R Shiny.

La version Shiny doit être une évolution du script existant, et non une réécriture méthodologique.

Elle doit reproduire les résultats du script actuel lorsque :

* les données sont identiques ;
* les paramètres sont identiques ;
* les seeds et paramètres de simulation sont identiques.

Toute différence de résultat doit être identifiée, quantifiée et expliquée.

Une contrainte d'architecture est IMPÉRATIVE :

TOUS les calculs statistiques, actuariels, de calibration, de tests, de bootstrap / Monte-Carlo et plus généralement toute logique quantitative doivent être centralisés dans un unique fichier :

R/engine.R

Le reste de l'application Shiny doit être limité autant que possible à :

* la saisie des données et paramètres ;
* le déclenchement des calculs ;
* l'appel aux fonctions de engine.R ;
* la mise en forme ;
* l'affichage des tableaux ;
* l'affichage des graphiques ;
* l'affichage des messages, alertes et résultats.

Aucun calcul statistique ou actuariel substantiel ne doit être dupliqué ou réimplémenté dans la couche Shiny.
</task_2_shiny>

<architecture>
L'architecture du projet doit respecter une séparation stricte entre :

1. LE MOTEUR DE CALCUL ;
2. LA COUCHE D'AFFICHAGE / INTERFACE.

Le fichier central doit obligatoirement être :

R/engine.R

Ce fichier doit contenir l'intégralité des calculs quantitatifs du projet, notamment :

* préparation et transformation des données nécessaires aux calculs ;
* contrôles statistiques nécessaires au moteur ;
* calculs actuariels ;
* calcul du sigma ;
* statistiques descriptives utilisées dans l'analyse ;
* statistiques de test ;
* calcul des p-values ;
* tests statistiques ;
* bootstrap ;
* simulations Monte-Carlo ;
* gestion des seeds lorsque pertinente ;
* estimations intermédiaires ;
* calibration ;
* application des bornes ou contraintes ;
* détermination du paramètre final retenu ;
* données quantitatives nécessaires aux graphiques ;
* toute autre logique mathématique, statistique ou actuarielle issue du script actuel.

La règle d'architecture fondamentale est :

Si un résultat peut être calculé indépendamment de l'interface graphique, son calcul doit être dans engine.R.

L'application Shiny ne doit pas constituer le moteur de calcul. </architecture>

<engine_requirements>
Le fichier R/engine.R doit être utilisable indépendamment de Shiny.

Il doit être possible de faire, par exemple :

source("R/engine.R")

puis d'appeler les fonctions principales du moteur directement depuis :

* une session R ;
* un script autonome ;
* un script de test ;
* un processus de validation externe.

Le moteur ne doit donc pas dépendre :

* de input$ ;
* de output$ ;
* de reactive() ;
* de reactiveVal() ;
* de reactiveValues() ;
* de observe() ;
* de observeEvent() ;
* de eventReactive() ;
* de renderTable() ;
* de renderPlot() ;
* de renderUI() ;
* ni de tout autre objet spécifique à Shiny.

Les entrées doivent être transmises aux fonctions sous forme d'arguments R explicites.

Les sorties doivent être des objets R standards, structurés et facilement auditables, par exemple :

* list ;
* data.frame ;
* tibble ;
* vecteur ;
* matrice ;
* objet de modèle lorsque nécessaire.

Les fonctions du moteur doivent être suffisamment explicites et documentées pour comprendre :

* leurs entrées ;
* leurs sorties ;
* les hypothèses ;
* les paramètres ;
* les seeds ;
* les éventuelles dépendances entre calculs.
  </engine_requirements>

<engine_orchestration>
Prévois une fonction principale d'orchestration dans engine.R, par exemple :

run_engine(...)

ou un nom équivalent plus pertinent.

Cette fonction doit permettre de lancer l'ensemble de la chaîne de calcul à partir :

* des données xt et yt ;
* des paramètres utilisateur ;
* des paramètres de simulation éventuels ;
* du seed éventuel.

Conceptuellement, l'utilisation doit pouvoir être proche de :

results <- run_engine(
xt = xt,
yt = yt,
...
)

Cette fonction doit retourner un objet structuré contenant l'ensemble des résultats nécessaires à l'application.

Par exemple, cet objet peut contenir :

results$data

results$descriptive_statistics

results$tests

results$diagnostics

results$bootstrap

results$calibration

results$plots_data

results$final_parameter

results$metadata

Cette structure est indicative : adapte-la à la réalité du projet.

L'objectif est que Shiny fasse essentiellement :

1. collecter les entrées ;
2. appeler run_engine() ;
3. conserver l'objet retourné ;
4. afficher les différents éléments de cet objet.

Évite que l'application reconstruise elle-même des résultats à partir de morceaux de calcul dispersés.
</engine_orchestration>

<display_only_principle>
En dehors de engine.R, le code doit être essentiellement du code d'interface et d'affichage.

AUTORISÉ HORS ENGINE.R :

* définition de l'UI ;
* organisation des onglets ;
* panneaux latéraux ;
* champs de saisie ;
* boutons ;
* édition du tableau xt / yt ;
* lecture des valeurs saisies ;
* déclenchement de run_engine() ;
* stockage réactif du résultat retourné ;
* mise en forme de tableaux ;
* formatage des nombres ;
* affichage de textes ;
* notifications ;
* construction visuelle des graphiques à partir de données ou quantités déjà calculées par engine.R.

À NE PAS FAIRE HORS ENGINE.R :

* calcul d'une statistique ;
* calcul d'une moyenne ou variance lorsque celle-ci fait partie de la méthodologie ;
* calcul du sigma ;
* calcul d'une p-value ;
* appel direct à un test statistique ;
* bootstrap ;
* Monte-Carlo ;
* estimation d'un paramètre ;
* logique de calibration ;
* sélection quantitative du paramètre final ;
* transformation quantitative déterminante ;
* règle métier actuarielle ;
* logique statistique substantielle.

Lorsqu'un graphique nécessite une quantité statistique particulière, cette quantité doit être calculée dans engine.R.

La couche d'affichage peut ensuite uniquement représenter cette quantité graphiquement.

Les opérations purement visuelles, par exemple choix d'un titre, format des axes, nombre de décimales ou organisation d'une table, peuvent naturellement rester dans la couche d'affichage.
</display_only_principle>

<suggested_project_structure>
Privilégie une structure simple de ce type :

app.R

R/
engine.R
ui_helpers.R
display_helpers.R

L'utilisation de ui_helpers.R et display_helpers.R est facultative.

Le point impératif est que :

* engine.R contient le moteur quantitatif complet ;
* les autres fichiers ne contiennent pas de logique statistique ou actuarielle substantielle.

N'éclate PAS le moteur entre des fichiers du type :

* statistical_tests.R ;
* calibration.R ;
* calculations.R ;
* bootstrap.R.

Je souhaite précisément que tous ces calculs soient regroupés dans R/engine.R afin de disposer d'un fichier quantitatif unique pouvant faire l'objet d'une revue indépendante.
</suggested_project_structure>

<shiny_general_layout>
Je souhaite :

* une zone principale de restitution ;
* un panneau de paramètres situé À DROITE ;
* dans ce panneau, les paramètres de calcul pertinents ;
* un bouton explicite permettant de déclencher les calculs, par exemple :

"Relancer les calculs"

Le fonctionnement attendu est :

1. l'utilisateur modifie éventuellement xt, yt ou les paramètres ;
2. ces changements modifient uniquement les entrées ;
3. le clic sur "Relancer les calculs" appelle le moteur central de engine.R ;
4. le moteur retourne un objet complet de résultats ;
5. les différents onglets affichent cet objet sans recalculer les résultats statistiques ou actuariels.

Les modifications des données ou paramètres ne doivent donc pas déclencher automatiquement toute la chaîne de calcul.
</shiny_general_layout>

<shiny_tab_data>
Crée un onglet consacré aux données.

Il doit permettre :

* de visualiser les données de base xt et yt ;
* d'afficher clairement l'indice ou la période t ;
* de modifier xt et yt directement depuis l'application ;
* de contrôler la validité des valeurs saisies ;
* de réinitialiser, si pertinent, les données à leurs valeurs initiales.

Les données modifiées doivent être utilisées lors du prochain clic sur "Relancer les calculs".

Ne modifie pas silencieusement les données saisies.

En cas de valeur incompatible avec les calculs, affiche un message explicite.

Les contrôles purement liés à l'interface peuvent être réalisés dans Shiny.

En revanche, tout contrôle de validité ayant une signification statistique, actuarielle ou métier doit également être implémenté dans engine.R afin que le moteur reste utilisable de manière autonome et sécurisée.
</shiny_tab_data>

<shiny_tab_tests>
Crée un onglet regroupant les résultats de TOUS les tests statistiques actuellement présents dans le script.

Conserve autant que possible la logique de présentation déjà utilisée dans le script actuel.

Pour chaque test, présente lorsque pertinent :

* le nom ;
* H0 et H1 ;
* la statistique observée ;
* la p-value ;
* la nature de la p-value : exacte, asymptotique ou bootstrap / Monte-Carlo ;
* le seuil de décision ;
* la conclusion ;
* un avertissement spécifique lorsque T = 8 rend l'interprétation délicate.

L'affichage doit permettre à la fois :

* une lecture synthétique ;
* une revue détaillée.

Toutes les valeurs quantitatives présentées dans cet onglet doivent provenir de engine.R.
</shiny_tab_tests>

<shiny_tab_graphics>
Crée un ou plusieurs onglets graphiques selon les besoins.

Reprends les graphiques statistiquement pertinents actuellement produits dans le script et organise-les de manière lisible.

Selon les graphiques existants, distingue éventuellement :

* données ;
* diagnostics ;
* distributions ;
* résidus ou écarts ;
* hypothèses des tests ;
* calibration.

Ne supprime pas un graphique existant sans raison méthodologique explicite.

Lorsque la construction d'un graphique nécessite :

* des résidus ;
* des quantiles ;
* des statistiques ;
* une distribution théorique ;
* des intervalles ;
* des valeurs ajustées ;
* des indicateurs ;
* des simulations ;
* ou toute autre quantité quantitative,

ces éléments doivent être calculés dans engine.R.

Les fichiers d'affichage ne doivent prendre en charge que la représentation graphique des résultats fournis par le moteur.
</shiny_tab_graphics>

<shiny_tab_calibration>
Crée un onglet spécifique consacré à la calibration.

Il doit présenter clairement :

* les principales données ou quantités entrant dans la calibration ;
* les estimations intermédiaires ;
* le sigma calculé ;
* les éventuelles transformations ou contraintes ;
* les différentes valeurs candidates lorsqu'elles existent ;
* le paramètre finalement retenu.

Le paramètre retenu doit être immédiatement identifiable visuellement.

La logique conduisant à sa sélection doit également être compréhensible.

L'intégralité de cet