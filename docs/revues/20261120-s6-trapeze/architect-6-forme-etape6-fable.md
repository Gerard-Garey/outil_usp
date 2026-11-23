Rapport d'`architect-approfondi` sous Fable, 21/11/2026, versé intégralement par la session (consultation autorisée par le mainteneur au point d'arrêt D2, seuil « macro »). Réponses du mainteneur aux questions du § 5 : Q-F1 (a), Q-F2 (a), Q-F3 (a) (E-21/11 (D2), `docs/feuille-de-route.md` § 4). Les fichiers de travail cités en fin de rapport sont hors dépôt et ne sont pas conservés.

# Consultation `architect` (Fable 1 sur 3 pour S6) : forme de l'étape 6, ADR 0005, rattachement de #612

**termine avec questions** (trois décisions du mainteneur, Q-F1 à Q-F3, au § 5). Je n'ai créé ni commit, ni issue, ni branche, et rien écrit sur GitHub.

Pendant la consultation, la tête est passée de `5521213` à `8d6e5bd` (annotation de la spécification 2a, sans code) ; mes lectures du code valent pour les deux.

## 0. Synthèse

- **Étape 6 : quatre commits de code**, et non trois. Un commit `moteur:` de restitution (champs lus par l'application, garde MW-04 maintenue) doit précéder le commit `app:`. L'intention de la fiche est gardée : l'application est prête avant la levée.
- **La levée reste le seul commit qui change un résultat.** Mesure sur une copie hors dépôt où seule la ligne 13148 est neutralisée : l'objet du carré `reserve2` est `identical()` avec et sans garde.
- **`reserve2.rds` change par ajouts** au commit de restitution : la colonne `sigma_residus` est numérique, donc non patchable, donc régénération par la CI. Les cinq autres références ne sont pas touchées. La levée ne change aucune référence existante.
- **Risque principal non prévu par la fiche** : MW-04 servait de filet à l'import. Trois fichiers mal formés passent de « refusé » à « accepté » ; l'avertissement de Q-2a-6 devient leur seul signal.
- **ADR 0005 annoté** (un fichier modifié, non commité).
- **#612** : créneau d'absorption A2, second numéro, libellés `enhancement` et `needs-info`.
- **Aucun ADR d'architecture n'est nécessaire** : le triangle reste une matrice (I+1) × (J+1), l'objet ne reçoit que des feuilles en fin de table.

## 1. Tâche 1 : forme de l'étape 6

### 1.1 Découpage

| N° | Préfixe | Contenu | Change un résultat ? | Références | Vérification |
|---|---|---|---|---|---|
| T0 | `docs:` | quatre textes fixés par `actuary`, renvois contrôlés par `regulatory` (§ 1.6) | non | aucune | sans objet |
| C1 | `moteur:` | restitution des deux σ, mention M6, masque des cellules observées ; garde maintenue | non (feuilles ajoutées) | `reserve2.rds`, mode `regeneration` | `audit` léger |
| C2 | `app:` | grille I × J, lecture, recopie, refus de dimension, aides, second point et légende, texte de la formule | non | aucune | `app-review` léger |
| C3 | `moteur:` | levée de MW-04, avertissement Q-2a-6, commentaires, tests que la levée invalide, cas de référence trapèze si Q-F1 (a) | **oui, le seul** | création de `reserve2_trapeze` (mode `creation`) si Q-F1 (a) | `audit` léger, visa du mainteneur, puis `regulatory` (étape 7) |
| C4 | `tests:` | tests nouveaux (moteur, lecteur, bloc shiny), en-têtes des scripts de mesure | non | aucune | `audit` léger, `app-review` léger sur rendu réel |

- Ordre : annotation de l'ADR 0005 (commit `docs:` de la session) → T0 → C1 → C2 → C3 → C4 → étape 7.
- Fiche : `coder-approfondi`, `effort: "high"`, pour C1 à C4.
- Chaque commit porte les adaptations des tests qu'il invalide, pour que chaque tête soit verte.
- Deux exécutions de la CI si Q-F1 (a), une seule si (b). Les deux modes ne se combinent pas : `creation` exige des md5 inchangés pour les `.rds` existants.

### 1.2 Consignes pour C1 (`moteur:`, restitution sous la garde)

1. **`mw_plots_data()`**, table `facteurs`, deux colonnes en fin, après `sigma_regle_minimum` :
   - `sigma_residus = sqrt(.mw_sigma2_residus(aj))` ;
   - `sigma_residus_direct`, logique, `TRUE` pour j = J−1 quand `aj[["sigma2_Jm1_direct"]]` existe, `FALSE` ailleurs.
   - Le drapeau est posé par la géométrie, jamais par comparaison de deux flottants. Sans lui, l'affichage devrait comparer `sigma` et `sigma_residus` pour savoir où tracer le second point.
2. **Feuille `plots_data$usage_sigma`**, en toute fin de liste (après `boot_reperes` quand il existe) : vecteur nommé de deux chaînes (`sigma`, `sigma_residus`), constante du moteur, identique pour toutes les géométries.
3. **Ligne M6 « Extrapolation de sigma… »** : `estim` inchangé. Pour I > J, le `detail` reçoit une mention conditionnelle (texte T0) qui donne σ̂²_dir (`format(digits = 6, decimal.mark = ".")`) et ses I−J degrés de liberté. Pour un carré, le `detail` reste identique à l'octet.
   - Le `detail` est soumis à la règle des deux phrases et 400 caractères de #514. La mention doit donc être déclarée dans `MENTIONS` (`tests/unitaires/outils_unitaires.R`, l. 204), à la suite de M22.
4. **Fonction nouvelle `mw_cellules_observees(tri)`** : matrice logique `row + col − 2 <= nrow − 1`, de la dimension de `tri`.
   - La règle est aujourd'hui écrite trois fois dans `app.R` et trois fois dans le moteur (l. 13094, 16037, 17615).
   - L'application ne doit plus la porter ; les trois emplois internes du moteur ne sont pas réécrits dans S6.
5. **Ne pas toucher** `mw_ajuster()`, `.mw_sigma2_residus()`, `mw_msep()`, `.mw_simuler_triangle_etat()`, `mw_bootstrap()` : c'est le code mesuré à l'étape 5.
   - Je garde donc `ajustement$sigma2_Jm1_direct` tel que livré à l'étape 3 (présent si I > J seulement).
   - **Écart assumé à la lettre de la spécification 2a, § 4, dernière puce** (« champ commun, NA pour un carré »). Le champ commun à tous les cas est porté par `plots_data$facteurs` (Q-A1, décision postérieure).
   - Motif : la table C1 versée et son script exigent le champ NULL sur un carré. À faire confirmer par `actuary` en T0.
6. **Tests à modifier** :
   - `test_merz_wuthrich.R` l. 645 (noms de `facteurs`) ;
   - `test_merz_wuthrich_trapeze.R`, bloc (s8).
7. **Tests à ajouter** :
   - carrés (reserve2, 5×5, GenIns) : `identical(sigma_residus, sigma)`, drapeau partout `FALSE` ;
   - trapèzes 8×5, 8×6, 8×7 : `sigma_residus[J]` égal à `sqrt(sigma2_Jm1_direct)`, un seul `TRUE` ;
   - mention M6 présente sur trapèze, `verifier_detail()` vert ;
   - `mw_cellules_observees()`.
8. **Référence** : mode `regeneration` sur `reserve2`, motifs attendus `plots_data\$facteurs\$sigma_residus` et `plots_data\$usage_sigma`. Tableau « absent → ajouté », aucune valeur changée.
9. **Critères d'acceptation** :
   - six cas au seuil 0 hors feuilles ajoutées ;
   - `run_engine()` refuse toujours un trapèze ;
   - **preuve que le code mesuré est intact**, à produire par `audit` : sur 8×5, 8×6, 8×7, `identical()` de `mw_ajuster()`, `mw_msep()`, `mw_bootstrap()` et des lignes de `mw_tests()` (hors `detail` de la ligne M6) entre le moteur de `425c1c9` et le nouveau. L'ancien moteur se charge par `git show 425c1c9:R/engine.R` vers un fichier temporaire, puis `charger_moteur(fichier, dans)`. L'empreinte sans commentaires (`307e0760…`) changera forcément : seule cette identité fonctionnelle tient le lien avec la mesure.

### 1.3 Consignes pour C2 (`app:`)

1. **Bloquant d'`app-review`** (`app.R` l. 1401-1428, 1457-1465, 1489-1494) :
   - lignes `seq_len(nrow(tri))`, colonnes `0:(ncol(tri) − 1)` ;
   - cellule saisissable si et seulement si `mw_cellules_observees(tri)` le dit ;
   - `lire_triangle()` rend une matrice de `dim(triangle())` ;
   - la recopie au changement de méthode suit la même boucle. Une seule aide locale pour les deux, qui ne diffèrent que par le sort d'un champ absent (NA, ou valeur stockée).
2. **`refus_dimension_triangle(n_acc, n_dev = n_acc, T_max)`** :
   - libellé « Triangle %d x %d » avec les deux dimensions ;
   - refus si la plus grande dépasse `T_max` ;
   - appels l. 361 et 1631 avec `nrow` et `ncol`. Les tests existants à un argument restent verts.
3. **Aides** :
   - `aide_methode` (l. 1318) : « n années d'accident x m années de développement, n ≥ m » ;
   - `aide_donnees` (l. 1328) : « i + j ≤ I » reste exact dans une grille à J + 1 colonnes. Ajouter qu'un triangle à plus d'années d'accident que de développement s'obtient par import ou fichier de démarrage, et que la réinitialisation charge un carré (voir Q-F2).
   - Commentaires l. 165, 189, 1456 à reformuler.
4. **`triangle_defaut()` et `triangle_vide()`** : inchangés (carrés).
5. **`plot_mw_facteurs()`**, voies base R et plotly :
   - `direct <- d$sigma_residus_direct %in% TRUE` ; colonne absente : aucun point, comme pour un résultat antérieur à #310 ;
   - second point en (j, `sigma_residus`), marque creuse distincte du losange plein ;
   - `ylim_sigma` sur `max(c(d$sigma, d$sigma_residus[direct]))` ;
   - si `any(direct)`, les deux légendes sont lues dans `pd$usage_sigma` ; sinon `.LEGENDE_SIGMA_REGLE` inchangée. Le rendu d'un carré ne bouge pas, et le test « T-5 à la lettre » de `test_rapport_html.R` l. 2914 reste vert.
6. **`texte_formule()`** (`R/display_helpers.R` l. 2498) : affiche « R = somme_i (C^(i,J) − C(i,I−i)) », faux pour un trapèze, où C(i, I−i) n'existe pas pour i < I−J. Variante pour `m$I > m$J` (deux entiers lus dans l'objet), texte T0.
7. **T de crédibilité** : déjà lu dans l'objet (`m$T`, `app.R` l. 1854, 2233, 2325). Rien à faire.
8. **Tests** :
   - fonctions de premier niveau évaluées seules ;
   - graphique sur un `pd` construit par les fonctions internes d'un 8×6 (relevé base R à 395 et 480 px, traces plotly) ;
   - le bloc shiny d'import d'un trapèze ne peut pas tourner avant la levée : il va dans C4.
9. **`app-review` léger sur rendu réel avant la levée** : lancer l'application sur une copie hors dépôt du moteur où seule la ligne 13148 est neutralisée (technique éprouvée dans cette consultation). Parcours import d'un 8×6 et d'un 8×7 → grille → calcul → onglets → rapport figé.
   - Points à regarder : avertissement visible sans défilement après l'import ; trois entrées de légende qui tiennent à 395 px ; aucune erreur R brute.

### 1.4 Consignes pour C3 (`moteur:`, levée)

1. **`mw_valider_triangle()`** :
   - retirer le bloc MW-04 (l. 13145-13154) ;
   - ajouter l'avertissement de Q-2a-6 si I > J, en tête des avertissements du bloc `if (!length(err))`, texte T0, `sprintf` avec `nrow` et `ncol`.
   - Source unique : pas de copie dans `avertissements_lecture`, que #518 réserve à ce que la validation de la saisie ne peut pas voir.
2. **Pas de renumérotation** de MW-05 à MW-08. MW-04 est marqué « retiré (#567) » là où une liste existe.
3. **Commentaires** (m4 de l'audit léger de l'étape 3) :
   - en-tête de section, l. 13064-13076 : à réécrire (domaine I ≥ J, convention (B), forme consolidée seule, ADR 0005 annoté le 21/11/2026) ;
   - l. 13330-13331 ; l. 13420 (« impose … I = J ») ; l. 13428-13435 ; l. 13579 ; l. 14360 ; l. 15520 ; l. 16030-16035 ;
   - lecteur, l. 8205 : la règle du bord gauche ne « tient plus lieu » de MW-04 ;
   - lecteur, l. 8261 ; en-tête d'`engine_lire_triangle()`.
4. **Inventaire obligatoire des refus qui tenaient à MW-04** : pour chaque test contenant « non carre », donner le motif avant, le motif après, et dire si `ok = FALSE` persiste.
   - Emplacements : `test_controles_entree.R` l. 1642, 1702, 2207, 4962, 5569-5576 ; `test_application.R` l. 2037 ; `test_merz_wuthrich_trapeze.R` l. 315-323 et 399-405.
   - **Tout fichier mal formé qui passe de refusé à accepté est rapporté à la session, jamais absorbé en adaptant le test.**
5. **Si Q-F1 (a)** :
   - fichier `tests/donnees/triangle_mw_trapeze.csv` (colonnes j0 à j5 de `triangle_mw.csv`, égalité testée) ;
   - cas `reserve2_trapeze` dans `CAS` ;
   - référence créée par la CI en mode `creation`.
6. **Critères d'acceptation** :
   - `reserve2` et les cinq autres cas au seuil 0, md5 des `.rds` existants inchangés ;
   - trapèzes calculés ; I < J toujours refusé par MW-03 seul ;
   - visa du mainteneur sur le tableau.

### 1.5 Consignes pour C4 (`tests:`) et tableau avant / après

**Tests du moteur** :
- `run_engine()` sur 8×5, 8×6, 8×7, 6×5, 10×5 et GenIns tronqué ;
- σ_USP recomposé depuis les valeurs C1 écrites en dur (MSEP, R̂) ;
- `metadata$T = I + 1` ;
- `identical()` de deux appels à graine égale ;
- avertissement présent une fois ;
- R̂ ≤ 0 sur trapèze refusé (M4).

**Tests du lecteur** :
- aller-retour export CSV et xlsx → import, `identical()` ;
- carré privé de sa dernière colonne : accepté avec l'avertissement ;
- rectangle rempli : les deux avertissements.

**Bloc shiny** :
- import d'un trapèze ;
- identifiants `c_i_j` présents pour les seules cellules observées ;
- `lire_triangle()` identique à l'import ;
- recopie au changement de méthode ;
- clic et résultat ;
- refus 41 × 8.
- Critère de la fiche : bloc vu à la CI (job de parité) avant de cocher.

**Scripts de mesure** :
- `tests/niveau_mw_trapeze_t8.R` (contrôle (m4), l. 933-942) et `tests/msep_trapeze_mw.R` affirment la garde en place. Ils ne sont plus rejouables tels quels après la levée.
- Annoter leurs en-têtes (commit de la mesure, `425c1c9` et `766b9de`), sans changer la logique.
- Aucun test ni workflow ne les lance (vérifié par `grep`).

**Tableau avant / après** (`docs/tableaux/<date>-issue567-levee-mw04.md`, joint à la PR) :
- avant : `ok = FALSE`, MW-04 seul ;
- après : σ_USP, σ estimé, R̂, √MSEP, c, T, σ²_{J−1} de la règle et direct avec ses degrés de liberté, intervalle bootstrap, verdict et p retenue des 25 lignes, avertissements ;
- plus la ligne `reserve2` « identique au bit ».
- `comparer_references.R` ne couvre que les cas de référence : le tableau des trois trapèzes est produit à part par la session, au commit de la branche éphémère. Si Q-F1 (a), la valeur de la CI fait foi pour 8×6.

**Valeurs observées aujourd'hui** (copie hors dépôt, machine de la session, B = 999, graine par défaut, segment II-1) :

| Trapèze | σ_USP | σ estimé | c | Verdicts |
|---|---|---|---|---|
| 8×7 | 0,0467061159 | 0,0166205355 | 0,59 | 3 ALERTE, 4 ECHEC, 13 INFO, 5 OK |
| 8×6 | 0,0475797067 | 0,0181011978 | 0,59 | 3 ALERTE, 4 ECHEC, 13 INFO, 5 OK |
| 8×5 | 0,0494854180 | 0,0213312169 | 0,59 | 3 ALERTE, 5 ECHEC, 13 INFO, 4 OK |

Les σ estimés recoupent le script de `regulatory` (0,016621 ; 0,018101 ; 0,021331).

### 1.6 Textes à fixer en T0 (projets de forme ; le fond revient à `actuary`, les renvois à `regulatory`)

Sans eux, `coder` inventera des chaînes qui seront reprises.

```
(t1) Triangle a %d annees d'accident et %d annees de developpement (I > J) : verifier qu'aucune annee de developpement ne manque en fin de tableau (un triangle carre prive de ses dernieres colonnes est recevable et ne se distingue pas d'un tel triangle). Le calcul tient pour acheve a l'annee de developpement J le developpement des annees d'accident 0 a I - J (reserve nulle pour ces annees) : hypothese a justifier par l'entreprise.
(t2) Triangle a I > J : la regle de minimum s'applique par prescription du texte, alors qu'un estimateur direct de sigma2_(J-1) existe ; estimateur direct, pour information : %s (%d degre(s) de liberte), employe pour les residus de la colonne J-1, non retenu pour la MSEP.
(t3) sigma         : sigma_(J-1) retenu : regle de minimum (annexe XVII, D(5)(d)(ii)) ; MSEP, simulation du bootstrap, sigma_USP
     sigma_residus : sigma_(J-1) des residus : estimateur direct ; residus de Mack, influence, tests et vivier du bootstrap
(t4) ou R = somme_i (C^(i,J) - C(i, min(I-i, J))) est la reserve chain-ladder totale (annees d'accident 0 a I-J observees jusqu'a J : reserve nulle)
```

- Point d'attention pour (t1) : D(2)(d) ne vise que la première année d'accident (texte courant du consolidé relu). Un renvoi à D(2)(d) pour les années 1 à I−J prêterait au règlement ce qu'il ne dit pas (critère E4).
- (t1) apparaît dans le tableau soumis au visa.

### 1.7 Contrats partagés (§ 4.2)

**Touchés** :
- l'objet `usp_engine` et `res$plots_data` : deux colonnes de `facteurs`, feuille `usage_sigma`, `ajustement$sigma2_Jm1_direct` pour I > J, avertissement nouveau ;
- le domaine de `run_engine()` ;
- `CAS` et `tests/reference/` si Q-F1 (a).

**Non touchés** : la structure d'`add()`, `MW_CATALOGUE_MC`, `GROUPES`, `comparer_objets()` et `TOLERANCE`, les graines, les données réglementaires, la section 7ter.

### 1.8 Risques d'interface non prévus par la fiche

1. **MW-04 était un filet à l'import.** Sur huit fichiers sondés, trois passent de refusé à accepté :
   - carré privé de sa dernière colonne ;
   - carré dont la cellule (0, J) est vide et sans en-tête ;
   - rectangle 8×6 entièrement rempli (avec l'avertissement « sous la diagonale »).
   - Deux restent refusés, par un motif moins parlant (« Cellule observée manquante ») : colonne 0 perdue avec colonne i ; ligne « Total ».
   - Le sondage n'est pas exhaustif, d'où l'inventaire de C3.
2. **L'avertissement de Q-2a-6 n'est pas dans `avertissements_lecture`.** La notification d'import ne le portera donc pas ; il apparaît dans l'aperçu `validation_live` et dans le résultat. À vérifier par `app-review` sur rendu réel.
3. **Règle des deux phrases de #514** contre la phrase de Q-2a-4 : mention conditionnelle à déclarer (C1).
4. **`texte_formule()`** faux pour un trapèze (C2).
5. **Légende à trois entrées** : la coupure plotly par `sub("regle de minimum ", …)` ne s'applique pas aux nouveaux libellés ; les marges basses sont calées pour deux entrées.
6. **Scripts de mesure non rejouables** après la levée (C4).
7. **Aucun moyen de saisir un trapèze à la main** : la réinitialisation ne produit que des carrés (Q-F2).
8. **Deux emplois successifs de `claude/regeneration-567`** : en session cloud, la suppression de la branche distante échoue. Le mainteneur doit la supprimer entre les deux exécutions.
9. **« Six cas »** est écrit dans de nombreux tests, dans `.claude/rules/moteur.md` et probablement dans le `.tex`. Un septième cas allonge `test_reproductibilite.R` d'environ 35 s (deux appels d'environ 18 s) et demande une passe de `docwriter`.

## 2. Tâche 2 : ADR 0005

Fichier modifié, non commité : `/home/user/outil_usp/docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md` (+47 lignes, 4 lignes retouchées).

**Annotation ajoutée en fin de fichier**, « Annotation du 21 novembre 2026 — géométrie I > J : extension retenue, lecture (B) sous la forme consolidée seule ; le refus MW-04 est levé », dans la forme des annotations du 13/11 :
- Origine ;
- Ce qui est établi (dix points) ;
- Décision (sept points) ;
- Limites à dire dans le dossier ;
- Ce qui ne change pas ;
- Lecture du corps ;
- Issues.

**Quatre renvois en ligne** : puce « Géométrie I > J » du corps ; « Décision » du 13/11 ; « Qualification commune corrigée » et « Texte du motif MW-04 » du 13/11 (bis).

**Trois points où j'ai précisé le brief** :
- **Points 1 à 3 de la qualification** : j'écris qu'ils « ne qualifient plus un refus », et non « sans objet » en bloc.
  - Le point 1 reste exact comme constat sur la lettre : c'est lui qui rend la convention (B) nécessaire.
  - Le point 2 n'est plus vrai.
  - Le point 3 est sans objet.
- **(A) / (B)** sont dites lectures de D(4) et D(5), D(2)(e) n'en ayant qu'une (complément de `regulatory`).
- **La levée est écrite comme décidée et non encore réalisée** : « jusqu'à ce commit, MW-04 est toujours émis ». Si le visa du tableau était refusé, l'annotation serait à amender.

**`CONTEXT.md` non modifié.** Les termes nouveaux (trapèze, convention (B), estimateur direct, σ des résidus) décriraient un état que le code n'a pas encore, et leurs libellés dépendent de T0. À écrire par `architect` en routine après C3.

## 3. Tâche 3 : rattachement de #612

- **Tri (ADR 0018)** : gardée, critères E3 et G (majeur d'`actuary`). **Courante**, non urgente : aucune entrée admissible de l'état en service n'est touchée (la dernière étiquette refuse le trapèze), et la réserve est documentée par décision (a′).
- **Placement** : § 5.2 ne trouve aucune branche prévue après S6 qui touche `mw_bootstrap()` avec moins de cinq numéros.
  - S7 : application et `usp_bootstrap()`.
  - S8 et S9 : cinq numéros chacune.
  - S10 : lognormale. S11 : références.
  - Donc § 5.3 : **créneau A2, second numéro avec #608**.
- **Forme** (calquée sur #610) : spécification et protocole d'`actuary-approfondi` (comparaison appariée moteur contre témoin, constat m3) → script hors CI → mesure (10 à 16 h annoncées) → point d'arrêt du mainteneur → circuit 1 seulement si la simulation change.
- **Libellés** : ajouter `enhancement` ; `needs-triage` → `needs-info` (spécification attendue), puis `ready-for-agent` après le protocole.
- **Dépendances ajoutées** :
  - #612 → fusion de S6 ;
  - décision sur Q-2a-2 → mesure ;
  - si Q-F1 (a), `reserve2_trapeze` sera régénérée si la simulation change.
- **Dette** : deux issues gardées en attente (#608, #612), sous le seuil de cinq.

**À écrire par la session dans `docs/feuille-de-route.md`** (je ne l'ai pas édité) :
1. § 4, entrée « E-21/11 (D2) », absente à ce jour (`grep` vide) : les décisions de D2, puis les réponses à Q-F1 à Q-F3.
2. § 3, fiche S6 :
   - ligne D2 : décidée (a′) ;
   - ligne 6 : découpage T0, C1 à C4 ; C1 `moteur:` de restitution avant `app:` ;
   - ligne 6b : sans objet (D3 (a)) ;
   - Fable : 1 sur 3.
3. § 3, vue d'ensemble, et § 5, tableau (l. 7422) : A2 = #608, #612 ; les dépendances ci-dessus.
4. Sur #612 : un commentaire de rattachement et les deux libellés.

## 4. Retour

**Statut** : `revue requise` (Q-F1 à Q-F3 ; textes T0 à fixer).

**Couverture du lot**

| Issue | Tâche | Branche |
|---|---|---|
| #567 | étape 6 : T0, C1 à C4, puis 7 à 12 | S6 |
| #610 | constat seul (D3 (a)) ; 6b sans objet | S6 |
| #612 | réexamen de Q-2a-2 par une mesure | A2 (proposé) |

Règle d'entrée de #612 : ADR 0018, § 5.3. Le compte des gardés et des mineurs écartés est à établir au point d'étape qui suivra la fusion.

**Preuves**

*Vérifiées* :
- carré `identical()` avec et sans la garde ; valeurs des trois trapèzes ; huit cas de lecteur (`Rscript` sur copie hors dépôt, `LC_ALL=C.UTF-8`) ;
- six cas, dont un seul triangle (`tests/outils_tests.R` l. 98-128) ;
- patch limité au non numérique (`tests/patcher_reference.R`, en-tête) ;
- `detail` de M6 soumis à #514 (`R/engine.R` l. 13692 ; `outils_unitaires.R` l. 151-152) ;
- texte de D(2)(d) (texte courant du consolidé) ;
- #612 lue, libellé `needs-triage` seul.

*Hypothèses* :
- durée de la mesure de #612 (annoncée par `actuary`) ;
- tenue de la légende à trois entrées.

*Non vérifiées* :
- mentions « six cas » du `.tex` ;
- géométrie du trapèze du dossier.

**Informations manquantes** : les quatre textes de T0 ; la confirmation par `actuary` de l'écart du § 1.2, point 5.

**Critères déclenchés** (§ 4) :
- contrat partagé (`usp_engine`, `plots_data`) ;
- changement de résultat (σ_USP et verdicts sur une classe d'entrées, visa) ;
- ADR 0005 annoté ;
- seuil « macro » déjà traité par cette consultation ;
- aucun désaccord entre agents.

**Constats hors périmètre** (la session trie) :
- *Critère E1 à apprécier* : un carré dont la colonne 0 est perdue, sans colonne i ni colonne vide, est lu comme un carré 7×7 valide. C'est déjà le cas avant la levée (sonde : `ok = TRUE`). Les en-têtes j1 à j7 ne sont pas interprétés. Possiblement déjà arbitré par #520 (non vérifié).
- *Mineur, aucun critère* : le masque des cellules observées reste écrit trois fois dans le moteur.

**Prochaine action recommandée** :
1. Commiter l'annotation de l'ADR 0005 (`docs:`).
2. Porter Q-F1 à Q-F3 au mainteneur.
3. T0 par `actuary` et `regulatory`.
4. C1 par `coder-approfondi`.
5. Tracer dans la PR la ligne « Fable 1 sur 3 ».

## 5. Questions pour le mainteneur

- **Q-F1 — Cas de référence trapèze.**
  - *(a), recommandé* : `reserve2_trapeze`, troncature 8×6 de `triangle_mw.csv`, créé par la CI au commit de la levée. Sans lui, aucune p-value ni aucun verdict d'un trapèze n'est protégé contre une régression, alors qu'un trapèze est prévu au dossier. Je préfère 8×6 à 8×7 : ses statistiques observées diffèrent de celles du carré, et sa colonne J−1 (trois facteurs) entre dans les lignes à n ≥ 3.
  - *(b)* : aucun cas ; tests unitaires seuls (σ_USP en dur, `identical()` à graine égale). Une exécution de CI de moins, pas de passe « six → sept ».
  - Si la géométrie du trapèze du dossier est connue, la prendre.
- **Q-F2 — Saisie d'un trapèze.**
  - *(a), recommandé* : par import ou fichier de démarrage seulement ; l'aide le dit.
  - *(b)* : un contrôle d'ajout et de retrait d'une année de développement. C'est une exigence nouvelle du § 5.2, hors S6.
- **Q-F3 — Place de #612.**
  - *(a), recommandé* : A2, second numéro, ordre inchangé.
  - *(b)* : A2 avancé devant S7, si le trapèze du dossier a I − J = 1, géométrie où la réserve PenteIntra a été mesurée.

## Fichiers modifiés

- `/home/user/outil_usp/docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md` (seul fichier du dépôt modifié ; non commité).

Fichiers de travail hors dépôt, dans `/tmp/claude-0/-home-user-outil-usp/45d0bf23-bb8a-56cb-8f97-92627ff53473/scratchpad/arch/` :
- `/tmp/claude-0/-home-user-outil-usp/45d0bf23-bb8a-56cb-8f97-92627ff53473/scratchpad/arch/engine_sans_mw04.R`
- `/tmp/claude-0/-home-user-outil-usp/45d0bf23-bb8a-56cb-8f97-92627ff53473/scratchpad/arch/obs.R`

**termine avec questions** : Q-F1, Q-F2, Q-F3.
