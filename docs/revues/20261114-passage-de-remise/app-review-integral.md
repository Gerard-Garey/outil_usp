# Revue intégrale de l'application, KR étape 5 (app-review)

> Rapport d'`app-review` (`model: "opus"`), versé intégralement par la session principale (Q-54-10). Captures, PDF et scripts conservés hors dépôt (scratchpad de la session cloud du 14/11/2026, non versés).

Branche `claude/passage-de-remise`, SHA du gel `a2f9c3a`. `git diff a2f9c3a HEAD -- R/ app.R` est vide et l'arbre est resté propre : rien n'a été écrit dans le dépôt, aucune issue n'a été créée.

Conditions de la revue :
- Paquets aux versions de la CI : `shiny` 1.8.0, `plotly` 4.10.4 (plotly.js 2.11.1), `openxlsx` 4.2.5.2, `zip` 2.3.1, avec R 4.3.3 et `LC_ALL=C.UTF-8`.
- Application lancée en vrai et pilotée sous Chromium avec Playwright, à 1 600 et 960 px.
- Impression A4 portrait et paysage avec `page.pdf`, dans trois configurations WebGL : swiftshader, défaut, puis `--disable-3d-apis`.
- `app.R` et `R/display_helpers.R` relus en entier. Pour la partie la moins risquée de `display_helpers.R` (fonctions de tracé), relecture ciblée.

## Verdict

**Conforme, avec un constat majeur et quatre mineurs. Aucun constat bloquant.**

Les valeurs affichées sont identiques à celles du moteur. Aucun σ_USP ni aucun verdict n'est en cause. Le constat majeur est un défaut de rendu des graphiques plotly, sous la version de plotly utilisée par la CI.

## Points de contrôle

**Disposition — conforme.**
- La zone de restitution est à gauche, le panneau de paramètres à droite, avec le bouton « Relancer les calculs ».
- `run_engine()` n'est appelé qu'en deux endroits, tous deux dans `observeEvent(input$go)` (`app.R:1591` et `app.R:1627`).
- Mesure : après une modification de `x_1`, de B et un aller-retour de méthode, le bloc État affiche toujours « Aucun calcul lance. ».
- Après un calcul, changer α ou `x_1` ne recalcule rien : σ_USP reste inchangé et le signal « α du panneau différent… relancer les calculs » apparaît.

**Onglet Données — conforme**, sauf le mineur m2.
- Saisie, ajout et retrait de lignes, et réinitialisation fonctionnent.
- Imports refusés, chacun avec un motif explicite et les données courantes conservées : `texte.csv` (« colonne xt : ligne(s) de donnees 2 »), CSV ayant plus de champs que l'en-tête, `corrompu.xlsx`, triangle contenant une cellule textuelle (« (i = 1, j = 1) »).
- Import d'un fichier hors contrôles (`negatif.csv`) : les données sont chargées avec le motif du moteur, sans modification silencieuse.
- Import de `series9.xlsx` (9 années) : T passe à 9 ; avec T = 8, la troncature est signalée dans Calibration.
- Le triangle exporté en xlsx se réimporte à l'identique.

**Onglet Tests — conforme**, sauf l'observation m4.
- Synthèse confrontée au moteur ligne par ligne (verdict, p retenue, nom du test) : `premium` 46 lignes sur 46 concordantes ; `reserve2` 23 sur 23.
- La règle des verdicts au α du résultat, le repère T = 8, les badges de nature et les types « diagnostic », « test inopérant » et « non applicable » sont présents.
- Les badges lisent les champs du résultat, jamais le texte du `detail` (`type_ligne()`, `display_helpers.R:327-337`).
- Impression A4 de la vue Détail : 18 pages en portrait, 17 en paysage (`premium`) ; 14 pages en `reserve2`. Les 16 colonnes tiennent sans mise à l'échelle.

**Onglets graphiques — écart M1** ; le reste est conforme.
- Tous les tracés lisent `res$plots_data`.
- Le seul « calcul » de l'affichage est le regroupement en classes des histogrammes, ce qui relève de la construction visuelle.
- Surface objectif (#576), impression : avec WebGL (swiftshader ou défaut), une image PNG de 1 340 × 1 040 est intégrée au PDF, en portrait comme en paysage ; sans WebGL, la mention « Graphique interactif non reproduit à l'impression. » est imprimée ; après impression, l'écran est restauré (aucun `.impr-gl` ni `data-impr-gl` restant).

**Onglet Calibration — conforme**, sauf le mineur m1.
- σ_USP, intervalles, valeurs candidates (retenue marquée OUI et en rouge) et formule propre à chaque méthode sont présents.
- Les formules affichées sont celles appliquées par `usp_parametre()` (`engine.R:2113-2125`) et `mw_parametre()` (`engine.R:11241-11254`).
- σ_USP affiché = moteur : 0,11145 (`premium`), 0,10735 (`reserve1`), 0,04978 (`reserve2`, moteur 0,04977646).

**Aucun calcul hors du moteur — conforme.** Seuls subsistent des décomptes de mise en forme (`table(verdict)`, `sum(fort_levier)`), des cadrages d'axes et les droites tracées à partir des coefficients du moteur.

**Messages — conformes**, sauf le mineur m3.
- Les quatre bandeaux (non lancé, refusé, défaut, usage) fonctionnent ; les messages R bruts ne vont qu'au journal du serveur.
- Motif de refus de `reserve1` après #573, sur des données proportionnelles : le texte est conforme au visa (forme 1, art. 220(1)(b)) et ne contient plus « reste ouverte ».

**Console du navigateur — sans erreur** (seulement des avertissements de performance de Chromium : Canvas2D, ReadPixels).

**Exports — conformes.** Données CSV et xlsx, tests CSV, calibration CSV et rapport figé HTML (4,3 Mo, aucune ressource chargée par URL). Le rapport porte « Version de l'outil (DESCRIPTION) 2.1.0 » et les md5 `818f276d8941e5780468382c640f8cfa` (`R/engine.R`) et `5ed6226c768d5ad781ea03a7306ccc11` (`R/charger_moteur.R`), identiques à `md5sum`.

## Constats

### M1 — majeur : la légende recouvre la zone de tracé
- **Graphiques touchés :** histogramme bootstrap (`g_boot`, et `mw_boot` de l'onglet M5) ; ratio (`g_ratio`).
- **Emplacement :** `R/display_helpers.R:1605-1611` et `:839-842`.
- **Cause :** ces légendes sont ancrées par `legend = list(yref = "container", y = 0, …)`. plotly.js 2.11.1, livré avec plotly 4.10.4 (version de la CI), n'a pas d'attribut `legend.yref` : il l'ignore et place la légende à y = 0 de la zone de tracé. Le commentaire du code cite des mesures faites sous plotly.js 2.25.2.
- **Mesure (DOM, bas de la légende = bas de la zone de tracé) :**

| Graphique | Largeur fenêtre | Légende (haut-bas, px) | Zone de tracé (haut-bas, px) | Effet |
|---|---|---|---|---|
| `g_boot` | 1 600 | 508-537 | 286-537 | bas des barres masqué |
| `g_boot` | 960 | 546-604 | 353-604 | 58 px masqués |
| `mw_boot` | 1 600 | — | — | environ 60 % de la hauteur masquée |
| rapport figé interactif | — | 26410-26439 | 26188-26439 | même défaut |

- **Conséquence :** le bas de l'histogramme et sa ligne de base sont masqués ; sur le ratio, la légende peut recouvrir des points selon les données.

### Mineurs
- **m1 — titre de section inexact en `reserve2`.** Le titre « Chaine de calibration (annexe XVII, sections B/C et G) » est fixe (`app.R:842`) et s'affiche aussi en Merz-Wüthrich, qui relève de la section D. La formule juste en dessous cite bien « section D, paragraphe 4 ».
- **m2 — libellés « t = k » décalés.** Le même `padding-top:26px` s'applique à toutes les lignes (`app.R:1316`), alors que seule la première ligne porte l'étiquette x_t/y_t au-dessus de son champ. À partir de t = 2, le libellé tombe sous son champ, entre deux lignes. Mesure à 1 600 px : milieu du texte « t = 2 » à 535, champ de la ligne 2 entre 499 et 533, champ de la ligne 3 à partir de 548 ; même décalage à 960 px.
- **m3 — notation R visible dans un message.** Avec B = 10 saisi, le bandeau affiche « B = 10L : … ; en appel direct, un nombre seul, sans attribut ». L'application transmet `input$B` entier (`app.R:1594`, `:1630`), et `.engine_saisie()` le cite avec `keepInteger` (`engine.R:485`) ; le texte d'appel direct est restitué tel quel. De même, « alpha = 0.3 » s'affiche avec un point décimal.
- **m4 — observation sur la vue Détail.** La vue Détail n'a ni verdict, ni statistique observée, ni p retenue, ni nature (`display_helpers.R:635-672`). Imprimée seule (comme le conseille l'aide de l'onglet), elle ne permet pas de conclure test par test ; il faut aussi la Synthèse.

### Observations, sans écart au cahier des charges
- **Version et md5 absents de l'écran.** La Version et les md5 ne figurent que dans le rapport figé (`IDENTITE_CODE`, `app.R:33`, n'est lu que par `rapport_html()`), pas à l'écran ni dans le journal d'exécution. Le relevé des md5 « affichés par l'application » à l'étape 3 suppose donc un calcul abouti puis le téléchargement d'un rapport. Le § 5.6 ne demande que le rapport.
- **Message plotly sans WebGL.** Sans WebGL, l'écran affiche le message natif de plotly, en anglais et avec une URL (« WebGL is not supported… get.webgl.org »).

## Issues proposées (à créer sur accord du mainteneur)

Aucune issue ouverte ne couvre ces constats ; les 32 issues ouvertes ont été listées.

**1.** Titre : `app: légende plotly ancrée au conteneur ignorée par plotly 4.10.4 (plotly.js 2.11.1), histogramme bootstrap et ratio recouverts`. Libellés : `bug`, `needs-triage`.
> *Rédigé par l'agent app-review (IA).*
> Revue intégrale de KR (SHA du gel `a2f9c3a`), versions de la CI. `plot_boot_sigma()` (`R/display_helpers.R:1605-1611`) et `plot_ratio()` (`:839-842`) posent `legend.yref = "container"`. Cet attribut est inconnu de plotly.js 2.11.1, livré par plotly 4.10.4 : la légende est placée au bas de la zone de tracé. Mesures (DOM, Chromium) : `g_boot` 1 600 px, légende 508-537, zone de tracé 286-537 ; 960 px, légende 546-604, zone 353-604 ; `mw_boot` (onglet M5), environ 60 % de la hauteur masquée ; même défaut dans le rapport figé interactif. Effet : le bas de l'histogramme bootstrap de σ_USP et sa ligne de base sont masqués ; sur le ratio, des points peuvent l'être. Aucun nombre n'est touché. Pistes : un ancrage valable sous plotly.js 2.11.1 (`y` négatif en coordonnées papier, marge basse adaptée), ou une version minimale de plotly déclarée et contrôlée. Refs #392, #500.

**2.** Titre : `app: trois défauts d'affichage relevés par la revue intégrale de KR (titre de calibration en reserve2, libellés t décalés, « 10L » dans le motif d'usage)`. Libellés : `bug`, `needs-triage`.
> *Rédigé par l'agent app-review (IA).*
> (a) `app.R:842` : le titre « sections B/C et G » est affiché aussi pour Merz-Wüthrich (section D). (b) `app.R:1316` : `padding-top:26px` uniforme ; à partir de t = 2, le libellé tombe entre deux lignes de la grille (mesure : milieu de « t = 2 » à 535 px, champ de la ligne 2 entre 499 et 533, champ suivant à partir de 548). (c) Avec B = 10, le bandeau affiche « B = 10L … en appel direct, un nombre seul, sans attribut » : `input$B` est transmis entier et `.engine_saisie()` le cite avec `keepInteger` ; idem « alpha = 0.3 » avec un point décimal. Refs #133, #236, #527.

**3.** Titre : `app: vue Détail des tests sans verdict ni statistique ; identité du code visible seulement dans le rapport figé`. Libellés : `enhancement`, `needs-triage`.
> *Rédigé par l'agent app-review (IA).*
> La vue Détail (`table_detail_groupe()`, `R/display_helpers.R:635-672`) n'a ni Verdict, ni Statistique, ni p retenue, ni Nature ; imprimée seule, elle ne permet pas de conclure par test (exigences § 5.3). La Version et les md5 (`IDENTITE_CODE`, `app.R:33`) ne sont visibles que dans le rapport figé ; les afficher dans le journal d'exécution faciliterait le relevé sur poste (KR, étape 3). Refs #178, #525.

## Limites
- **Pas d'impression réelle.** Pas de dialogue d'impression d'un navigateur de bureau : le PDF vient de `page.pdf`, sans arrière-plans, donc badges sans couleur de fond. Pas de Firefox, de Windows ni d'Excel du poste.
- **Graphiques en base R non exercés.** La branche base R des graphiques (`usp.graphiques_base`, sans plotly) n'a pas été pilotée à l'écran, seulement lue. Le rapport en mode PNG n'a pas été produit.
- **Parcours non exercés :** annexe XIV ; saisie manuelle de σ standard ; marge Δ a priori ; défaut de calcul intercepté (TITRE_DEFAUT) ; échec d'écriture xlsx sans `zip` ; données réelles (non versionnées) ; triangle de plus de 8 années.
- **Pas de comparaison au bit près.** La comparaison avec le moteur porte sur le verdict, la p retenue formatée, σ_USP et la chaîne de calibration, pas sur toutes les colonnes de la vue Détail.
