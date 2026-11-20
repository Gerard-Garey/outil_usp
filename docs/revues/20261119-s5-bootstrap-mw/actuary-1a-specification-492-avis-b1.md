> *Versé intégralement par la session principale le 19/11/2026 (`actuary-approfondi`, mission de jugement, matrice § 3).*

# Rapport d'actuary : S5, étape 1a (spécification de #492, avis sur B1 de #445)

*Rédigé par l'agent actuary (IA), le 19/11/2026, en lecture seule, sur `claude/bootstrap-merz-wuthrich` à `94b03ac`. Ce commit ne diffère de `e4a8ae4` que par des fichiers `docs/` : les numéros de ligne de `R/engine.R` et du `.tex` sont les mêmes aux deux commits. Je n'ai rien écrit dans le dépôt (`git status` est vide). Mes scripts de mesure sont restés dans le dossier temporaire de la session : `vol3.R` (fixture), `vol2.R` et `vol4.R` (balayage).*

**En bref**
- **#492** : je recommande de compter et d'afficher les réplications écartées, sans seuil de retrait. Le point d'arrêt A n'est donc pas déclenché.
- **B1 de #445** : le retour sur #203 est acceptable sur le fond. Mais B1 est déjà réalisé dans `main` par #513, de même que l'essentiel de B2. Le plan de S5 est périmé sur ce point et le motif d'ordre « #445 d'abord, −20 % » ne tient plus. Il faut une révision d'`architect`, et une décision du mainteneur si l'ordre change.

---

## A. Spécification de #492

### A.0 Constats

- *Vérifié* (lecture de `R/engine.R`, l. 16009-16023). Pour chaque `b`, une réplication passe par quatre étapes :
  - tirage, sinon `next` si le plafond est atteint ;
  - `mw_ajuster()`, sinon `next` ;
  - `.mw_stats()`, sinon `next` ;
  - `sim[b, ] <- sb[noms]`, puis seulement le calcul de `sig[b]`, conditionné à `is.finite(mb$msep) && ab$reserve > 0`.

  Une réplication sans σ* (réserve simulée ≤ 0, MSEP en erreur ou non finie, ou `sqrt(msep)/R` non fini) reste donc dans `stats_boot` et dans les p-values de Monte-Carlo. Elle n'est retirée que de `sigma_boot`, sans être comptée.
- *Vérifié* (l. 17484-17485). L'intervalle `res$ic_bootstrap` de Merz-Wüthrich est formé sur `boot$sigma_boot` s'il contient plus de 20 valeurs, sinon il vaut `NULL`. Cette règle de 21 σ* au minimum existe déjà ; je ne la touche pas.
- *Vérifié* (`readRDS("tests/reference/reserve2.rds")`). Sur `reserve2` : `B` = 999, `B_effectif` = 999 sur les 13 statistiques, `length(sigma_boot)` = 999. **Aucune réplication sans σ***. `cumuls_retires` et `plafond_cumuls` valent `FALSE`.
- **Information manquante.** Le triangle « volatil » de l'issue (script `t3.R` de l'audit, 199 − 123) n'est pas versionné : rien dans `tests/` ni dans `docs/revues/`, aucune trace dans `git log -S`. Je l'ai remplacé par une fixture déterministe que j'ai mesurée.
  - Triangle 8 × 8 d'entiers, `dput` ci-dessous :
    ```
    structure(c(1022, 1190, 1017, 1017, 1126, 1015, 852, 960, 998, 1383, 1132, 1143, 1230, 1121, 927, NA, 1069, 1445, 1128, 1261, 1139, 1053, NA, NA, 1120, 1447, 1119, 1321, 1252, NA, NA, NA, 1266, 1491, 1094, 1291, NA, NA, NA, NA, 1336, 1486, 1228, NA, NA, NA, NA, NA, 1199, 1490, NA, NA, NA, NA, NA, NA, 1179, NA, NA, NA, NA, NA, NA, NA), dim = c(8L, 8L))
    ```
  - Mesure *vérifiée* : `run_engine(methode = "reserve2", segment = 1, annexe = "II", triangle = tri, date_reference = "2025-12-31")`, graine par défaut, `LC_ALL=C.UTF-8`, R 4.3.3, Linux.

  | B | `ok` | R̂ | `B_effectif` (13 statistiques) | `length(sigma_boot)` | Sans σ* | `cumuls_retires`, `plafond_cumuls` | IC 95 % de σ_USP |
  |---|---|---|---|---|---|---|---|
  | 199 | TRUE | 158,57 | 199 | 122 | **77** | FALSE, FALSE | [0,158 ; 11,67] |
  | 999 | TRUE | 158,57 | 999 | 546 | **453** | FALSE, FALSE | [0,159 ; 12,68] |

  Sur ce triangle, σ̂ = 3,82 et σ_USP = 2,29. Mon instrumentation de la boucle ne trouve pas d'autre cause que « R* ≤ 0 », ni sur la fixture ni sur 32 triangles du balayage.

### A.1 Réponse à Q1 : compter et afficher, sans seuil de retrait

**Point d'arrêt A : non déclenché.** Je ne recommande pas de seuil, donc l'intervalle affiché ne change sur aucun triangle admis. Pour que le mainteneur puisse passer outre, voici les options que j'ai examinées :

| Option | Contenu | Avis |
|---|---|---|
| (a) **retenue** | compte restitué par le moteur ; phrase « k sur B » sous l'intervalle quand k > 0 ; intervalle inchangé | fidèle au calcul, aucune perte d'information, aucun résultat changé |
| (b) | intervalle retiré au-delà d'un seuil fixe de proportion (5, 10 ou 20 %) | aucune source ni aucune mesure ne fixe le seuil à T = 8 ; cacherait un signal fort (45 % sur la fixture) |
| (c) | seuil déduit des niveaux, avec la convention σ* = +∞ pour R* ≤ 0 : borne à 97,5 % « non bornée » dès que π ≥ 2,5 %, borne à 95 % dès que π ≥ 5 % | cohérent avec la limite σ* → +∞ quand R* → 0⁺. Mais c'est une convention, pas un résultat : R* ↦ σ* n'est pas monotone de part et d'autre de 0, et σ* < 0 n'a pas de sens. Elle changerait l'affichage dès 2,5 % |
| (d) | statu quo plus la seule règle existante (plus de 20 σ*) | ne règle pas le défaut de #492 |

Justification de (a) :
1. **Le conditionnement n'est pas arbitraire** (*vérifié* par lecture, l. 13775-13788 et contrôle M4). Le triangle observé n'est admis que si R̂ > 0. La loi bootstrap de σ* restreinte à R* > 0 est donc l'analogue bootstrap de la loi de σ̂ *conditionnelle à l'admission*. L'intervalle conditionnel a un sens défini ; il lui manquait seulement d'être dit et chiffré.
2. **Erreur de Monte-Carlo (fonction de B).** La part écartée π̂ = k/B estime π* = P*(R* ≤ 0), avec une erreur-type √(π(1−π)/B) (*vérifié*, calcul) :
   - 0,0069 à π = 0,05 et 0,0095 à π = 0,10, pour B = 999 ;
   - 0,016 à π = 0,45 pour B = 999 ;
   - 0,035 à π = 0,39 pour B = 199.

   Un seuil serait franchi ou non au hasard près de sa valeur ; cette erreur-là, B la réduit.
3. **Erreur d'échantillonnage (fonction de T), dominante.** π* dépend du triangle observé (T = 8). Balayage *mesuré* : 60 triangles 8 × 8 tirés d'un même modèle (f = 1,02 puis 1, écart-type de bruit 0,08 ; constat de simulation sur un modèle illustratif, non calibré) :
   - 28 sur 60 ont R̂ ≤ 0, donc seraient refusés par M4 : P(R̂ ≤ 0) ≈ 0,47, intervalle de Clopper-Pearson à 95 % [0,34 ; 0,60] ;
   - sur les 32 triangles admis, π̂ (B = 199) va de 0 à 0,56 (quartiles 0,034 / 0,259 / 0,338).

   Sous un même modèle, la part écartée varie donc de presque rien à plus de la moitié d'un triangle à l'autre, et l'admission la biaise vers le bas. Un seuil sur π̂ serait une décision sur une statistique très bruitée à T = 8, et aucun B ne corrige ce bruit.
4. **La couverture de l'intervalle n'est pas mesurée en Merz-Wüthrich** (#387, étape 4). Un seuil de retrait ne serait calibré sur rien. Si la mesure de #387 montre une couverture qui se dégrade avec π, le seuil pourra être posé sur preuve au point D2.
5. **L'affichage de « k sur B » répond à la demande « proportion affichée ».** Il donne la proportion sans aucune division dans `display_helpers.R`.

*Hypothèse, non vérifiée par une mesure de couverture* : quand π est grand, la queue droite de σ* conditionnel est lourde (R* proche de 0⁺). Sur la fixture à B = 999, le maximum de σ* vaut 7,1·10⁴ et la borne à 97,5 % passe de 11,67 à 12,68 entre B = 199 et B = 999. Les bornes hautes y sont donc à la fois instables (erreur de Monte-Carlo) et de couverture inconnue (erreur à T).

### A.2 Forme du compte (contrat partagé)

- **Nom** : `n_sans_sigma`. Il reprend l'expression de l'issue (« réplications sans σ* ») et suit le précédent `bootstrap$n_echec_restreint`, entier compté dans la boucle (`usp_bootstrap()`, l. 5697 et 5839 ; *vérifié* : `int 0` dans `premium.rds`).
- **Type** : entier scalaire, jamais `NA`, compris entre 0 et B.
- **Valeur sans tirage** : `0L`. C'est aussi la valeur si aucune réplication n'aboutit aux statistiques, et elle est atteinte sans boucle à B = 0 (appel direct seulement, `run_engine()` refusant B < 99).
- **Définition** : nombre de `b` pour lesquels `sim[b, ] <- sb[noms]` a été exécuté et `sig[b]` n'est pas fini en fin d'itération. Mise en œuvre : `n_sans_sigma <- 0L` avant la boucle, puis `if (!is.finite(sig[b])) n_sans_sigma <- n_sans_sigma + 1L` juste après le bloc de `sig[b]`. La condition `is.finite` doit être la même que celle du filtre `sig[is.finite(sig)]`.
- **Invariant** : `n_sans_sigma + length(sigma_boot)` = nombre de réplications à statistiques calculées.
- **Un seul compteur, sans ventilation par cause.** Je n'ai mesuré que la cause « R* ≤ 0 ». *Hypothèse* : une MSEP négative est inatteignable à cumuls positifs, puisque tous les termes de `mw_msep()` (l. 13677-13712) sont des produits de quantités positives ou nulles si Q ≥ 0, ce qui reste à confirmer par la lecture de `mw_ajuster()`. Une MSEP NaN reste possible sur une réplication dégénérée. La phrase du code et de la documentation nomme les deux causes ; elle reste exacte.
- **Position** : juste après `plafond_cumuls`, avec les autres champs de traçabilité ; `stats_boot` reste le dernier élément (commentaire l. 16062-16066, `.tex` l. 1631).
  - *Vérifié* : deux tests figent `tail(names(b), 4)` sur `c("cumuls_retires", "plafond_cumuls", "p_min_mc", "stats_boot")` (`tests/unitaires/test_retirage_mw.R` l. 266 et 276). Toute position les fait échouer ; il faut les mettre à jour dans le commit `tests:`.
- **Aucun aléa en plus ni en moins** : `sim`, `sig`, `p_mc` et `stats_boot` restent identiques au bit près.
- **Références** : seul `reserve2.rds` gagne le champ (`0L`) ; les cinq cas lognormaux ne bougent pas. Régénération par la CI (`references.yml`, ADR 0011), ou patch si la skill `verifier-reproductibilite` l'admet pour un champ nouveau sans changement de valeur existante.
- **Décision D1-3 (a) non rouverte.** Les booléens du retirage des triangles à cumul non positif restent sans compte de tirages. `n_sans_sigma` porte sur une autre exclusion, en aval du tirage.
- `mw_tests()` ne lit pas ce champ : aucune phrase n'est ajoutée au `detail` (règle #76 respectée).

### A.3 Phrase de l'affichage

Elle est lue dans les champs `res$bootstrap$n_sans_sigma` et `res$bootstrap$B`, sans aucun calcul, et sans `length(sigma_boot)` dans `display_helpers.R`. Elle va dans la note de `textes_ic_bootstrap()` (l. 2519), branche `reserve2`, avant la phrase de couverture actuelle :

> « Intervalle conditionnel à une réserve simulée strictement positive. Réplications sans σ simulé (réserve simulée négative ou nulle, ou MSEP simulée non finie ou négative), écartées de l'intervalle mais non des p-values de Monte-Carlo : {k} sur B = {B}. Couverture à T = 8 non mesurée pour cette méthode. »

- Si k = 0, ou si le champ est absent (objet antérieur, `NULL`) : la note reste exactement celle d'aujourd'hui. L'affichage des six cas de référence ne change donc pas.
- Les entiers sont imprimés sans décimale ; le séparateur des milliers suit la convention de l'application. La forme « {k} sur B = {B} » évite les accords au singulier.
- La phrase passe aussi dans le rapport figé, par la même fonction.
- **Option laissée à `app-review` et au mainteneur, hors minimum** : le graphique de la distribution bootstrap de σ_USP est lui aussi conditionnel. Sur la fixture, il porte 546 réplications sur 999 sans le dire. Le dire en sous-titre passerait par `plots_data`, sur le modèle de `regime_boot_motif` (l. 1548-1550) : c'est un contrat de plus, donc une régénération de plus.

### A.4 Phrases du `.tex` à aligner (relocalisées à `94b03ac`)

1. **l. 6129-6135** (`sec:controles`, encadré « Différence de nature »), ancienne l. 5588. Remplacer « en écarte, sans en restituer le nombre, les réplications… » et « la part des réplications écartées, qui n'est pas affichée, peut ne pas être négligeable » par : elle les écarte de `sigma_boot`, en restitue le nombre (`bootstrap\$n\_sans\_sigma`), et ce nombre est affiché sous l'intervalle quand il n'est pas nul. Garder « Ces réplications restent dans le calcul des statistiques simulées et des p-values de Monte-Carlo ». Garder « non finie ou négative » : le filtre du code exclut bien une MSEP négative (NaN), même si ce cas est peut-être inatteignable.
2. **l. 14389-14393** (`fiche:ic-bootstrap`), ancienne l. 13498. Remplacer « sans en restituer le nombre » par la restitution et l'affichage. Remplacer « restituer ce nombre et mesurer cette couverture sont un travail postérieur à la remise » par « sa couverture n'est pas mesurée » ; `docwriter` intégrera le résultat de #387 en fin de branche. Aucun numéro d'issue dans le `.tex` (CONVENTIONS).
3. **l. 1629-1633** (index des fonctions, ligne `mw\_bootstrap()`) : ajouter `n\_sans\_sigma` après `plafond\_cumuls`, avec sa définition. Probablement exigé par `concordance_doc_moteur.R --strict` : exception M32 (commit `docs:` minimal avant le push) si l'écart apparaît.
4. **l. 6547-6550** (traçabilité du retirage) : « le nombre de triangles écartés n'est pas restitué » reste vrai (D1-3 (a)). Je recommande une précision qui distingue ce retirage de `n\_sans\_sigma`, pour qu'un relecteur ne confonde pas les deux exclusions.
5. **Limite au sens de A.5** : une phrase dans la fiche de l'intervalle ou dans la section « Nature des p-values et validité à T = 8 », sauf si la mesure de 1b la lève.

### A.5 Calibration des p-values de Monte-Carlo conditionnellement à R̂ > 0

- **Nature du problème** (*vérifié* par lecture). Les 13 p-values de Monte-Carlo de Merz-Wüthrich sont calculées sur toutes les réplications à statistiques calculées, y compris celles où R* ≤ 0. Or le triangle observé n'est soumis aux tests que si R̂ > 0 (M4). La loi de référence n'est pas conditionnée par la règle d'admission ; le niveau effectif, P(rejet | R̂ > 0), n'est donc pas garanti égal au niveau mesuré sans condition. L'écart s'ajoute à l'erreur d'approximation propre au bootstrap ; il est nul si la statistique est indépendante de l'événement {R > 0}. C'est un argument élémentaire ; je ne cite aucune source, et je n'en connais aucune qui chiffre cet effet à T = 8.
- **Portée sur le plan de #206** : sans portée en pratique. Sur `reserve2`, aucune réplication sur 999 n'a R* ≤ 0 (*vérifié*). Par la règle de trois, P*(R* ≤ 0) < 0,3 % environ à 95 % (*hypothèse* de calcul : tirages i.i.d. sous la loi bootstrap). Les niveaux mesurés par #206 valent donc conditionnellement à R̂ > 0 pour ce plan.
- **Recommandation** :
  - (i) **limite écrite**, dans tous les cas : niveau conditionnel non mesuré quand `n_sans_sigma` n'est pas négligeable ;
  - (ii) **mesure versée dans le protocole de #387 (1b), en sous-produit sans tirage supplémentaire**. Le script de couverture appelle déjà `mw_bootstrap()` pour chaque triangle simulé, donc les p-values de Monte-Carlo sont disponibles. Il faut un profil « volatil » où P(R̂ ≤ 0) est élevé (la fixture de A.0, prise comme modèle générateur, donne π* ≈ 0,45). Sur ce profil :
    - triangles à R̂ ≤ 0 écartés et comptés, comme M4 ;
    - sur les triangles admis : taux de rejet des 13 p-values à 0,10 et 0,05, avec intervalles de Clopper-Pearson, et distribution de `n_sans_sigma/B` ;
    - en option, la p conditionnelle (loi de référence restreinte aux réplications à σ* fini), calculée **dans le script** par une boucle instrumentée et jamais dans le moteur, pour chiffrer l'écart.

  Ordres de grandeur : avec N = 500 triangles admis, l'erreur de Monte-Carlo du taux de rejet vaut 0,013 à α = 0,10 (erreur en N) ; l'erreur de chaque p, de l'ordre de 0,0095 près de 0,10 à B = 999, est une erreur en B. L'écart au niveau nominal est, lui, l'erreur à T qu'on cherche à mesurer. Le critère est fixé par 1b avant tout tirage. Si 1b juge ce volet hors périmètre, seule la limite (i) reste.
- La p conditionnelle changerait des p-values : **elle est hors de S5** et serait une décision ultérieure.

### A.6 Commentaires du code à rectifier

1. **l. 16003-16006** : garder « Deux booléens seuls sont restitués (D1-3 (a)) : aucun compte de tirages » pour le *retirage*. Ajouter que les réplications à statistiques calculées mais sans σ* fini restent dans `sim` (statistiques et p-values) et ne sont retirées que de `sigma_boot`, comptées dans `n_sans_sigma`.
2. **l. 13786-13788** (applicabilité M4) : « mw_bootstrap() ecarte deja toute replication dont la reserve simulee est <= 0 » est inexact. Écrire : les écarte de `sigma_boot`, donc de l'intervalle bootstrap, et non des statistiques simulées. Constat de même nature que #492, que je rattache à son périmètre (critère E5 de l'ADR 0018 : le commentaire énonce une règle de calcul que le code n'applique pas telle quelle).
3. **l. 16056-16058** : compléter le commentaire de traçabilité avec le nouveau champ.

### A.7 Critères d'acceptation

1. **Fixture volatile versionnée** (proposée en A.0, ou le triangle de `t3.R` s'il est retrouvé), à B = 199 et graine par défaut : `n_sans_sigma` = **77** = `B_effectif` (199 sur les 13 statistiques) − `length(sigma_boot)` (122). En contrôle : 453 à B = 999. Ces valeurs ont été mesurées sous Linux, R 4.3.3 ; la CI les confirme.
2. **`reserve2`** : `n_sans_sigma` vaut `0L` = 999 − 999.
3. **Oracle indépendant** : une boucle instrumentée dans le test, sur le modèle de mon script `vol2.R`, compte les réplications à statistiques calculées sans σ* fini et retrouve le champ, sur la fixture et sur au moins un triangle où des réplications échouent ou atteignent le plafond. Dans ce dernier cas, `B − length(sigma_boot)` ≠ `n_sans_sigma`, ce qui montre que le compteur ne confond pas les causes.
4. **Toutes les autres feuilles du résultat sont `identical()` avant et après** sur la fixture et les six cas ; `comparer_references.R --seuil 0` passe hors champ nouveau.
5. **Type** : `is.integer`, longueur 1, non `NA`, entre 0 et B.
6. **Affichage** : avec k = 77 et B = 199, la note contient « 77 sur B = 199 » ; avec k = 0 ou un champ absent, la note est identique à celle de `e4a8ae4`. `app-review` vérifie que `display_helpers.R` ne calcule rien.
7. **Tests T257 mis à jour** (`test_retirage_mw.R` l. 266 et 276) ; batteries vertes sous `LC_ALL=C.UTF-8`.
8. **Tableau avant / après de structure** ; σ_USP, p-values et verdicts inchangés sur les six cas. Visa d'`actuary`.

---

## B. Avis sur la piste B1 de #445

**Verdict : retour acceptable sur le fond, mais sans objet dans S5, car il est déjà réalisé.**

- *Vérifié*. À `e4a8ae4`, `mw_test_ordonnee_origine()` (l. 15062) appelle `.mw_coefs_origine()` (l. 15036, appel l. 15093). Cette fonction fait `stats::lm.wfit` plus la transcription de `summary.lm`. Elle a été introduite par **#513** (C3 ; issue fermée `completed` le 09/11, PR #511 de K1 fusionnée).
  - `.mw_summary_lm()` (l. 14868) n'est plus appelée par le moteur ; elle reste pour `tests/calibration_mc_mw_t8.R` et pour son test.
  - Le test différentiel `tests/unitaires/test_ordonnee_wls.R` confronte la nouvelle fonction à l'ancienne implémentation par `lm()` (oracle) : cas nominaux, ajustement parfait, rang 1, NA et NaN, poids nuls, 0 degré de liberté, échelles de 1e-8 à 1e46. Je l'ai exécuté : 3 assertions sur 3, OK.
  - Le `.tex` le documente déjà (l. 1974, 1983, 16324).
- *Vérifié*, l'essentiel de **B2** est fait aussi (C4 de #513) : `.MW_DF_VIDE_J_N` (l. 14883), `.MW_DF_VIDE_I_J` (l. 17747), `structure()` dans `.mw_table_non_identifiables()` (l. 15005). Il peut rester des `data.frame()` dans le chemin des réplications (l. 15566, par exemple) ; c'est à mesurer.
- **Sur le fond** :
  - L'estimateur est le même : `lm()` avec poids appelle `lm.wfit`, avec la même tolérance, la même matrice et le même pivot.
  - La loi de référence est la même : t de Student à n − 2 degrés de liberté par colonne, combinaison de Fisher, puis p de Monte-Carlo retenue.
  - *Vérifié* sur `stats:::summary.lm` de R 4.3.3 : `rss <- sum(w * r^2)` dans le cas pondéré, `resvar <- rss/rdf`, `se <- sqrt(diag(chol2inv(R)) * resvar)`, ce que transcrit `.mw_coefs_origine()`.
  - La seule perte est l'avertissement « essentially perfect fit », déjà intercepté par #203, et dont le critère dépend de l'unité (#185) : aucune information statistique n'est perdue.
  - Le prix du retour : l'identité au bit près, garantie « par construction » avec #203, n'est plus garantie que par mesure, pour une version donnée de `summary.lm`. Le risque est couvert parce que l'oracle du test différentiel appelle le `summary.lm` installé : un changement de R serait détecté.
  - C'est la même méthode que `.usp_mco_qr()` (#237, Q-229-3). Aucune p-value ni aucun verdict n'est en cause.
- **Conséquence pour le plan** (feuille de route l. 4283, 4287, 4301, 4316, 4328) :
  - Retirer B1 et B2 de l'étape 2, avec le motif « déjà réalisé par #513 ».
  - La phrase « #445 d'abord : il réduit d'environ 20 % la durée des mesures de #387 et de #246 » est périmée : le gain mesuré par l'issue a été encaissé par #513 (`reserve2` de 18,6 à 14,2 s selon #513). Pour B3 et B4, le gain est inconnu (*hypothèse* : moindre). Il faut un nouveau profilage avant de garder « #445 d'abord ».

---

## Retour

- **Statut** : `revue requise`.
  - Partie A (#492) : complète, point d'arrêt A non déclenché, l'issue peut passer en `ready-for-agent` sur décision de la session.
  - Partie B : la piste B1 et l'essentiel de B2 sont déjà réalisés par #513, ce qui contredit le plan décidé (Q-70-1). Il faut une révision du plan par `architect`, et une décision du mainteneur si l'ordre change.
- **Résultat** :
  - #492 : compte `n_sans_sigma` (entier, `0L`), phrase « {k} sur B = {B} » quand k > 0, intervalle inchangé, aucun seuil ;
  - calibration conditionnelle : limite écrite, plus une mesure en sous-produit proposée à 1b ;
  - B1 : acceptable, déjà fait.
- **Preuves** :
  - *Vérifiées* :
    - lecture de `R/engine.R` (l. 13775-13788, 15036-15100, 16003-16066, 17484-17485) et de `R/display_helpers.R` (l. 2519-2549) ;
    - `reserve2.rds` (0 sur 999) ;
    - fixture volatile par `run_engine()` (77 sur 199, 453 sur 999) ;
    - balayage de 60 triangles (28 refusés ; π̂ de 0 à 0,56) ;
    - `test_ordonnee_wls.R` OK ;
    - source de `summary.lm` (R 4.3.3) ;
    - #513 fermée `completed` ;
    - tests T257 qui figent la fin des noms du bootstrap.
  - *Hypothèses* : MSEP négative inatteignable à cumuls positifs ; queue lourde et couverture dégradée quand π est grand ; gain résiduel moindre de B3 et B4 ; règle de trois sur `reserve2`.
  - *Non vérifiés* :
    - la portabilité des comptes 77 et 453 hors Linux ;
    - le profil de durée actuel ;
    - si le `.tex` documente la règle « plus de 20 σ* » et le silence de l'affichage quand `ic_bootstrap` vaut `NULL` (non trouvé par `grep`, non conclu).
- **Informations manquantes** : le triangle « volatil » de l'issue (`t3.R`, non versionné) ; je l'ai remplacé par une fixture.
- **Décisions non résolues** :
  - révision du plan sur #445 (B1 et B2 retirés, ordre et motif « −20 % ») : `architect`, puis le mainteneur ;
  - sous-titre du graphique bootstrap de Merz-Wüthrich (option de A.3) : `app-review` et le mainteneur ;
  - mesure de calibration conditionnelle dans le protocole de #387 : `actuary-approfondi` en 1b, puis le mainteneur.
- **Critères déclenchés** (`routage.md`, § 4) :
  - désaccord avec le plan décidé (B1 et B2 déjà réalisés) ;
  - contrat partagé (objet `bootstrap` de `usp_engine`) et régénération des références ;
  - changement d'un affichage hors σ_USP, p-value et verdict (phrase quand k > 0 ; aucun cas de référence touché) ;
  - validité à T = 8 qu'aucun résultat exact ni aucune simulation ne tranche (niveau des p-values de Monte-Carlo conditionnellement à R̂ > 0 sur un triangle volatil).
- **Constats hors périmètre** :
  1. Commentaire inexact `R/engine.R` l. 13786-13788, critère **E5**. Je l'ai rattaché au périmètre de #492 (point A.6-2).
  2. Le graphique de la distribution bootstrap de σ_USP en Merz-Wüthrich est conditionnel sans le dire (`display_helpers.R` l. 1540-1550 ; *mesuré* sur la fixture : 546 réplications sur 999). Critère : aucun formellement (aucun texte faux, une omission) ; proche de #492, proposé en option.
  3. Corps de #445 périmé (B1 et B2), critère : aucun (vie du dépôt) ; un commentaire de la session suffit.
  4. Pas de motif affiché quand `res$ic_bootstrap` vaut `NULL` (21 σ* au minimum), *non vérifié* ; critère : aucun établi.
- **Prochaine action recommandée** :
  1. La session soumet à `architect` la révision de l'étape 2 (B1 et B2 retirés, nouveau profilage avant B3 et B4, ordre réexaminé), puis au mainteneur si l'ordre change.
  2. #492 passe en `ready-for-agent` : étape 3 selon A.2 à A.7.
  3. 1b reprend A.5 (ii) dans le protocole de #387.
