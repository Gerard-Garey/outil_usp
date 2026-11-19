> *Rédigé par l'agent actuary (IA).* Étape 1c de S5, issue #246. Lecture seule : aucun fichier modifié, aucune issue, aucun commentaire. Branche `claude/bootstrap-merz-wuthrich`, tête `94b03ac`.
>
> *Versé intégralement par la session principale le 19/11/2026 (`actuary-approfondi`, mission de jugement, matrice § 3 ; relance après l'arrêt de la fiche de base, routage initial corrigé).*

# Protocole de l'outil hors CI de double bootstrap Merz-Wüthrich (#246)

## 0. Synthèse

**Verdict : protocole prêt pour `coder`, sous trois décisions du mainteneur (§ 4).**

Trois constats changent la lettre de l'issue :

1. **Beran (1988) n'a pas pu être relu.** `www.tandfonline.com` et `www.jstor.org` ne sont pas joignables depuis cette session. Seuls un résumé et des citations de seconde main sont accessibles. Le dépôt classe d'ailleurs déjà Beran (1988) parmi les références non relues (`docs/references/inventaire-non-relu.md`, l. 23). **Je recommande de retirer la citation** du script, de sa sortie et du `.tex`. Le principe est décrit par son opération, sans attribution. Rien de ce que l'outil affirme n'a besoin de cette référence : il produit un constat de simulation, et le résultat de Beran est asymptotique.
2. **Le critère « fréquences de #206 retrouvées » ne peut pas tenir pour 4 clés sur 13.** Vérifié : sous E, les p_mc du brut de #206 et du brut de #297 sont identiques sur les 2 000 lignes pour 9 clés (CorrDev, DW, Runs, Origine, HomogF, Courbure, Alpha, ExpVar, KruskalAcc). Elles diffèrent pour les 4 autres : Calendrier (0/2 000 identiques ; sens changé, #276), BP (2/2 000 ; statistique FWr, #301), PenteIntra (17/2 000 ; pente relative, #307), et Grubbs remplacé par MinP4 (#300). L'exemple de l'issue (« 0,0745 pour BP ») porte sur l'ancienne statistique BP et ne vaut plus. Je recommande de lire le critère sur le brut de #297 (`docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv`), qui est le plan de #206 remesuré au catalogue actuel.
3. **Sur `reserve2`, on peut exiger l'identité exacte, plus forte que les intervalles.** J'ai repris les graines du plan de #206 pour la loi E. Le moteur actuel redonne alors au bit près les 13 p_mc des lignes E b = 1 et b = 2 du brut de #297 (`identical()` vrai, § 5). Pour `reserve2`, l'outil doit donc redonner exactement les comptes de ce brut.

## 1. Statut épistémique (à écrire tel quel en tête de la sortie)

La fréquence produite pour chaque clé vaut F̂\*(p_obs) = #{r admis : p\*_r ≤ p_obs} / R_admis. C'est un **constat de simulation**, obtenu sous trois conditions : le modèle de Mack ajusté au triangle donné (f̂, σ̂², première colonne fixée), la loi d'erreurs E, et T = 8. Elle estime la probabilité, dans ce modèle et sous cette loi, que la p de Monte-Carlo du moteur soit au plus égale à la p observée.

Ce qu'elle n'est pas :
- ce n'est pas une p exacte ;
- ce n'est pas une p retenue, et elle n'entre dans aucun verdict ;
- elle ne vaut pas au-delà de ce modèle et de cette loi.

Trois sources d'erreur sont à distinguer :
- (i) l'erreur Monte-Carlo de F̂\*, fonction de R, encadrée par l'intervalle de Clopper-Pearson ;
- (ii) l'erreur Monte-Carlo de p_obs, fonction de B ;
- (iii) l'erreur de substitution : θ̂ remplace θ, et E remplace la vraie loi. L'outil ne quantifie pas (iii).

Aucun résultat exact ni aucune référence relue ne dit que F̂\*(p_obs) est mieux calibrée que p_obs à T = 8. Les mesures de #206 et #297 montrent au contraire que le niveau dépend fortement de la loi des erreurs. Une fréquence élevée n'est pas une preuve d'adéquation : la puissance n'est pas étudiée.

## 2. Protocole numéroté

**P1. Objet et frontières.**
- Script `tests/double_bootstrap_mw.R`, R base + stats (utils et tools, livrés avec R).
- Le moteur est chargé par `source("R/charger_moteur.R"); charger_moteur()`, jamais par `source("R/engine.R")` (ADR 0016).
- Le script ne s'appelle pas `test_*` : il n'est donc lancé ni par `test_unitaires.R`, ni par la CI.
- Il ne modifie ni `R/`, ni `app.R`, ni `tests/reference/`.

**P2. Entrées.**
- Triangle : un CSV au format de `tests/donnees/triangle_mw.csv`. Défaut : `reserve2`.
- `--segment`, `--annexe`, `--date-reference` (obligatoire, sauf pour `reserve2` : défaut `DATE_REFERENCE_TESTS` = 2026-12-31).
- `--seed` : graine du calcul observé, défaut 20260831.
- `--R` (défaut 1 000, plafond 2 000), `--coeurs`, `--essai`, `--ecrire` ou `--sortie DOSSIER`.

**P3. Point observé.**
- Lancer `run_engine(methode = "reserve2", triangle, segment, annexe, seed, date_reference)`.
- Si `ok = FALSE`, arrêt motivé.
- On en lit, pour chaque clé de `MW_CATALOGUE_MC`, `p_obs = bootstrap$p_mc[[k]]` et `err_mc`. On relève aussi, sur la ligne de `mw_tests()`, si la p retenue est cette p_mc (champ `mc_nom`, champ `inoperant`, verdict).
- Les clés et les sens sont lus au catalogue, jamais figés dans le script.

**P4. Modèle ajusté.**
- `AJ0 <- mw_ajuster(tri)`, `JD0 <- .mw_colonnes_degenerees(AJ0)`.
- f̂ et σ̂² sont ceux d'`AJ0`, σ̂² extrapolé compris. La première colonne observée est fixée.

**P5. Loi E (pool redressé), définition de #206 § 2.**
- POOL0 = `.mw_pool_residus(AJ0, JD0)`, POOL_E = POOL0 / sd_pop(POOL0), avec sd_pop l'écart-type de population.
- Tirage : `sample(POOL_E, n, replace = TRUE)`.
- La sortie consigne n, la moyenne, sd_pop, l'asymétrie, l'excès de kurtosis et les bornes du pool. Sur `reserve2`, vérifié : n = 27, sd_pop = 0,99879.
- Écart avec le monde du bootstrap interne : `mw_bootstrap()` tire dans le pool **non réduit**. E en diffère donc par le seul facteur d'échelle sd_pop. Signaler à la sortie |sd_pop − 1| > 0,05. Ce seuil de 0,05 est **une hypothèse** que je propose, à décider (D-3).

**P6. Générateur et admission.**
- Générateur : `gen_triangle_h0()` de `tests/calibration_mc_mw_t8.R` (l. 956), même récursion et même arrêt au premier cumul invalide (#257). Il ne doit jamais s'appeler `mw_simuler_triangle`.
- Admission : `admettre()` du même script (cellule ≤ 0, `mw_valider_triangle()`, `mw_ajuster()`, `mw_msep()`, `mw_valider_ajustement()`), avec les segment et annexe du point observé.
- Un triangle refusé est compté avec son motif, sans nouveau tirage. Au-delà de 1 % de refus, signalement en tête de sortie, comme au § 2 de #206.
- Mise en œuvre : copie de ces deux fonctions, ou mise en commun. C'est à `coder` de choisir, à condition de ne pas modifier `tests/calibration_mc_mw_t8.R`, dont les sorties sont versionnées. Le contrôle (g) de P11 est exigé dans les deux cas.

**P7. Graines** (toutes sous `engine_sous_graine()`). On garde le plan de #206 § 7 pour la loi E :
- triangle r : `20850000 + r` ;
- bootstrap interne r : `20880000 + r` ;
- r ≤ 2 000, dans les plages déclarées par #206.

Effets :
- le triangle `reserve2` reproduit exactement les lignes E du brut de #297 ;
- une ligne ne dépend que de r et de ses graines, donc la sortie ne dépend pas de `--coeurs` ;
- au-delà de R = 2 000, il faut une décision et le contrôle de collision de #206 (annotation du 10/10, point 1).

**P8. Niveau interne.** Pour chaque r admis :
- `boot <- mw_bootstrap(aj_r, B = 999, seed = graine_boot(r))`, avec B en double (voir le commentaire de B_BOOT dans `calibration_mc_mw_t8.R`) ;
- puis `mw_tests(aj_r, boot, alpha = 0.10)`.

On conserve par clé p\*_r, err_mc et B_effectif, plus `cumuls_retires` et `plafond_cumuls`. B = 999 est une donnée du test calibré, pas un levier.

**P9. Rang de la p observée dans sa loi simulée.**
- Par clé, on calcule F̂\*(p_obs) = #{p\*_r ≤ p_obs} / R_admis, en comparaison exacte de doubles, sans tolérance. p_obs et p\*_r sortent de la même fonction (`engine_p_mc()`), sur la grille (1 + k)/(B_eff + 1).
- Une p\*_r absente (NA) compte comme un non-« ≤ », comme la règle « p absente = non-rejet » de #206 § 5. Elle est comptée à part, et la fréquence restreinte aux p définies est donnée en colonne descriptive.
- On donne aussi #{p\*_r < p_obs} : l'écart entre les deux comptes est la masse de l'atome situé en p_obs. Aucun mid-p n'est retenu.
- Intervalle de Clopper-Pearson à 95 % sur F̂\*(p_obs).
- **Bande descriptive** de l'erreur Monte-Carlo de p_obs : F̂\*(p_obs ∓ 2 err_mc), sans coût de calcul. Ce n'est pas un intervalle de confiance. Proposition, à décider (D-3).
- **Produits du même calcul, gratuits** : le niveau du test bootstrap sous le modèle ajusté de ce triangle, soit les fréquences de p\* < α/2 et de p\* < α pour α = 0,10 (règle ECHEC/ALERTE de `add()`) et pour α = 0,05, avec leurs intervalles. Ces niveaux transposent la lecture de #206 au triangle donné.
- Les lignes dont la p retenue observée n'est pas la p_mc (test inopérant, diagnostic) sont marquées : leur fréquence n'y est que descriptive.
- Pas d'ajustement de multiplicité sur les 13 fréquences. La lecture conjointe de #297 est hors périmètre.

**P10. Empreinte #231 et provenance**, en tête de la sortie :
- `empreinte_sans_commentaires(R/engine.R)` (`tests/outils_tests.R` l. 606) ;
- SHA du commit et arbre propre exigé, sauf `--essai` (marqué) ;
- md5 du script et md5 du fichier triangle ;
- `ENGINE_RNG_KIND` ;
- `R.version.string`, plateforme, `Sys.getlocale("LC_CTYPE")` ;
- arguments complets, plan de graines, B, R ;
- moments du pool E, nombre de refus et motifs ;
- durée et débit du pré-vol ;
- date (UTC).

**P11. Contrôles d'intégrité.** Ils passent avant tout tirage du plan, sauf (i2) qui porte sur l'échantillon. Un seul échec donne `INTEGRITE ECHEC` et aucune écriture.
- **(g)** `gen_triangle_h0()` avec ε tirés par `sample(pool)` est `identical()` à `mw_simuler_triangle()` sous la même graine, sur 100 graines (forme de #206 § 6).
- **(i1)** Le point observé : la p_obs lue dans `run_engine()` est `identical()` à celle du chemin direct `mw_bootstrap()` + `mw_tests()`, avec les mêmes ensembles figés et la même graine.
- **(i2)** Identité avec `run_engine()` sur un échantillon : premier r admis, dernier r, et 5 r répartis régulièrement. `run_engine(methode = "reserve2", triangle = tri_r, segment, annexe, seed = graine_boot(r), date_reference)` donne `$tests` et `$bootstrap` `identical()` au chemin du script.
- **(rep)** Reproductibilité à graine égale : deux exécutions `--essai --R 20` avec les mêmes arguments donnent des sorties identiques, hors durées et date. La même chose vaut entre `--coeurs 1` et `--coeurs 4`.
- **(r2)** Sur `reserve2` sous E (critère de `reserve2` retrouvé) :
  - les comptes #{p\*_r ≤ p_obs} des r ≤ R sont **identiques** à ceux recalculés sur les mêmes r du brut de #297, colonnes `pR:<clé>`, lignes `type = rep`, `loi = E` ;
  - à R = 2 000, les fréquences du § 5 ci-dessous sont retrouvées exactement ;
  - pour les 9 clés inchangées depuis #206, l'égalité vaut aussi avec le brut de #206 ;
  - pour Calendrier, BP, MinP4 et PenteIntra, la sortie dit que la comparaison à #206 est sans objet (statistique ou sens changé).
  Ce contrôle prouve que l'outil réalise le plan de #206/#297. Ce n'est pas une validation indépendante de la méthode.
- **(m)** Aucun appel depuis le moteur ni depuis l'application, vérifiable par la commande : `grep -rn "double_bootstrap_mw" R/ app.R .github/` sans résultat.

**P12. Pré-vol (`--prevol`).**
- Sans rien écrire, mesurer sur le triangle donné : la durée de `run_engine()`, puis c_b (`mw_bootstrap()` à B = 999 suivi de `mw_tests()`) sur 3 triangles simulés, et le débit agrégé à 1, 2, 3 et 4 processus. Mécanique de `--prevol` de `calibration_mc_mw_t8.R`.
- En déduire la durée prévue pour R = 1 000 et R = 2 000.
- Le coût dépend des dimensions du triangle : le pré-vol se refait pour chaque triangle.

**P13. Sorties.**
- `--essai` : console seulement, sortie marquée, refusée par `--ecrire`.
- `--ecrire` : arbre propre exigé. Fichiers nouveaux, jamais écrasés (garde d'écrasement de #173), dans `docs/tableaux/` :
  - `<AAAAMMJJ>-issue246-double-bootstrap-<libellé>.md` : provenance, statut épistémique de P1, tableau par clé (p_obs, err_mc, nature de la p retenue observée, F̂\*(p_obs), IC, compte <, NA, bande descriptive, niveaux à 0,10 et 0,05) ;
  - `<AAAAMMJJ>-issue246-double-bootstrap-<libellé>-brut.tsv` : une ligne par r.
- Aucun chemin absolu ni `/tmp` dans les fichiers écrits.
- **Confidentialité** : voir D-2. Seul `reserve2` (données de test publiques) est sans difficulté.

**P14. Ce que l'outil ne fait pas.**
- Il ne corrige aucune p.
- Il ne change ni σ_USP, ni une p retenue, ni un verdict.
- Le moteur et l'application ne lisent jamais sa sortie.

## 3. Coût, d'après une mesure exécutée (pré-vol indicatif)

Mesure *vérifiée*, conteneur de cette session, un seul processus, tête `94b03ac`, avant #445 :
- `run_engine()` sur `reserve2` : 16,3 s ;
- c_b = 14,8 s par triangle simulé, sur deux triangles.

Extrapolation (*hypothèse*) :
- R = 1 000 : environ 4,1 h CPU, soit environ 1,05 h d'horloge à 4 processus avec le débit P4 = 3,917 mesuré par #297 ;
- R = 2 000 : environ 2,1 h ;
- #445 (gain annoncé d'environ 20 %, non mesuré ici) ramènerait R = 1 000 vers 0,85 h.

L'estimation de l'issue (environ 1,5 h à R = 1 000) est donc prudente. Le pré-vol de P12 fait foi.

Précision Monte-Carlo de F̂\*, au voisinage de 0,10 :
- R = 1 000 : demi-largeur à 95 % d'environ ±0,019 ;
- R = 2 000 : environ ±0,013.

## 4. Décisions du mainteneur

- **D-1. Beran (1988)** : (a) retirer la citation, ce que je recommande ; (b) autoriser `www.tandfonline.com` ou `www.jstor.org` dans la session, ou fournir une copie, pour relecture avant toute citation. Bickel et Freedman (1981) ne sont pas cités.
- **D-2. Triangle du dossier dans un dépôt public.** Les données `usp_*` ne sont pas versionnées. La sortie (f̂, σ̂², p_obs, moments du pool) en révèle une partie. Options : (a) sortie du triangle du dossier hors dépôt seulement (`--sortie`), et seule la sortie de `reserve2` versée dans `docs/tableaux/`, ce que je recommande ; (b) versement autorisé.
- **D-3. Paramètres** :
  - R par défaut : 1 000 (recommandé, environ 1 h) ou 2 000 (environ 2 h ; même R que #297) ;
  - seuil d'alerte sur |sd_pop − 1| : 0,05 proposé ;
  - bande descriptive F̂\*(p_obs ∓ 2 err_mc) : oui ou non ;
  - lois N et A de #206 en mode de sensibilité, `--loi N|A`, à coût multiplié par 3 : non recommandé par défaut. Ces lois ne seraient jamais présentées comme une p calibrée.
- **D-4. Critère d'acceptation** : remplacer « fréquences de #206 » par « comptes identiques au brut de #297 sous E ; pour les 9 clés inchangées, identiques aussi à ceux de #206 ».

## 5. Valeurs attendues sur `reserve2` (oracle du contrôle (r2))

*Vérifié*, par commande, à `94b03ac` :
- p_obs de `run_engine()` (seed 20260831, date 2026-12-31) ;
- comptes sur le brut de #297, loi E, R = 2 000, aucune p\* manquante.

| Clé | p_obs | #{p\* ≤ p_obs} / 2 000 | F̂\* |
|---|---|---|---|
| Calendrier | 0,002 | 6 | 0,0030 |
| CorrDev | 0,170 | 330 | 0,1650 |
| BP | 0,285 | 593 | 0,2965 |
| MinP4 | 0,898 | 1 779 | 0,8895 |
| DW | 0,032 | 65 | 0,0325 |
| Runs | 0,374 | 555 | 0,2775 |
| PenteIntra | 0,090 | 202 | 0,1010 |
| Origine | 0,085 | 173 | 0,0865 |
| HomogF | 0,080 | 137 | 0,0685 |
| Courbure | 0,030 | 45 | 0,0225 |
| Alpha | 0,005 | 7 | 0,0035 |
| ExpVar | 0,428 | 842 | 0,4210 |
| KruskalAcc | 0,300 | 612 | 0,3060 |

Ces valeurs sont un constat de simulation sous le modèle ajusté à `reserve2` et la loi E. Elles ne servent ici que d'oracle d'implémentation, et leur lecture actuarielle n'est pas faite dans ce rapport (étape 8). Sous E, le cas de BP rapporté par l'issue (une fréquence inférieure à la p observée) ne se retrouve pas avec la statistique actuelle.

## Retour

- **Statut** : `revue requise`. Le protocole est complet. Il reste les décisions D-1 à D-4, et la source Beran n'a pas été relue.
- **Résultat** : protocole P1 à P14 ; nom proposé du script `tests/double_bootstrap_mw.R` ; verdict : prêt pour l'étape 5 après D-1 à D-4.
- **Preuves** :
  - *Vérifié* :
    - issue #246 et ses deux commentaires lus ;
    - fiche S5, `docs/feuille-de-route.md` l. 4281-4337 ;
    - spécification de #206, § 2, 3, 7, 8 et 10 ;
    - `.mw_pool_residus()` et `mw_bootstrap()` lus dans `R/engine.R` (l. 15959-16060) : le pool n'est pas réduit ;
    - `empreinte_sans_commentaires()`, `tests/outils_tests.R` l. 606 ;
    - par commande (script dans le dossier temporaire de la session, `LC_ALL=C.UTF-8`) : identité au bit près avec le brut de #297 pour E b = 1 et 2, les comptes de § 5, l'identité des p_mc de #206 et #297 sur 9 clés et leur différence sur 4, les durées de § 3.
  - *Hypothèses* : linéarité du débit à 4 processus ; gain de #445 ; seuil de 0,05 sur sd_pop.
  - *Non vérifié* : Beran (1988) dans le texte ; toute propriété du double bootstrap à T = 8.
- **Informations manquantes** : le texte de Beran (1988). C'est un problème d'accès à la source : les domaines `www.tandfonline.com` et `www.jstor.org` doivent être autorisés dans la session, ou une copie fournie.
- **Décisions non résolues** : D-1 à D-4, par le mainteneur.
- **Critères déclenchés** :
  - source introuvable dans la session (accès, pas lecture contestée) ;
  - écart entre le texte de l'issue ou du plan (« #206 », « 0,0745 pour BP ») et l'état actuel du catalogue ;
  - validité à T = 8 qu'aucun résultat exact ni aucune référence relue ne tranche : c'est inhérent à l'outil, déclaré comme constat de simulation ;
  - aucun changement de résultat ;
  - aucun désaccord avec `audit` ni avec un ADR.
- **Constats hors périmètre** :
  - (1) L'exemple « 0,0745 pour BP » du corps de #246, et les fréquences 0,018 / 0,0745 / 0,006 de `docs/specifications/e2e-niveaux-et-documentation.md` § 3, portent sur la statistique BP d'avant #301. Je n'ai pas vérifié si la rubrique 7 de la fiche BP du `.tex` les reprend encore : les motifs `0{,}0745` et `149/2000` n'y donnent rien sur BP. Critère : « aucun », sauf si la fiche du `.tex` les porte encore (E5, affirmation fausse sur le code) : à faire contrôler par `docwriter` à l'étape 7.
  - (2) ADR 0014 l. 14 et 59 évoque Beran (1988) « de seconde main », de façon explicite. Critère : aucun.
- **Prochaine action recommandée** : le mainteneur tranche D-1 à D-4 ; puis étape 5, `coder` (fiche de base) selon P1 à P14, suivi d'un `audit` léger ; `actuary` lit la sortie de `reserve2` à l'étape 8.

Sources consultées : [Exeter ORE (renvoi)](https://ore.exeter.ac.uk/rest/bitstreams/195453/retrieve), [arXiv 2102.04423](https://arxiv.org/pdf/2102.04423), [MaRDI Q3811510](https://portal.mardi4nfdi.de/wiki/Item:Q3811510). Ce sont des pages de seconde main, insuffisantes pour citer Beran (1988). Ni Taylor & Francis ni JSTOR n'étaient joignables.

Fichiers pertinents : `tests/calibration_mc_mw_t8.R`, `docs/specifications/206-calibration-mc-merz-wuthrich.md`, `docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv`, `docs/tableaux/20261011-issue206-calibration-mw-brut.tsv`, `tests/outils_tests.R`, `R/engine.R`.
