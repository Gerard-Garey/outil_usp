## Mesure #276 : test calendaire de Mack à T = 8, forme bilatérale (« deux ») contre forme unilatérale (« bas »)

Statut : **constat de simulation sous un plan** (modèle de Mack ajusté à reserve2, DGP de #206), pas un résultat général ; il ne se transpose ni à une autre géométrie de triangle ni à un autre paramétrage. Aucun théorème ne couvre ce test bootstrap à T = 8. Protocole : docs/specifications/fd-test-calendaire.md, par. 2.3. Les deux formes sont calculées par engine_p_mc() sur les mêmes réplications, reproduction de la boucle de mw_bootstrap() : identité vérifiée par (i2) sur un triangle sur 50 ; écart possible non couvert : erreur d'une autre statistique de .mw_stats() (mesuré à l'audit : 0 sur 41 958 réplications) ; la forme « bas » est une copie locale de l'entrée Calendrier du catalogue, moteur inchangé. IC : Clopper-Pearson à 95 %, incertitude sur le taux (fonction de R), distincte de l'erreur de ρ (fonction de N0) et de err_mc (fonction de B). Bande de Bradley : convention de lecture (#166), pas théorème.

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Commit | 6af2005b94ad09e95415447ba6b62e72974dd4d3 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Empreintes md5 du code exécuté | R/engine.R d63c785f687003de54b4feb382857cc5 ; tests/outils_tests.R chargé (dépôt) c52a2046ac2d98d8a7d036191353da76 ; script exécuté (dépôt) 68bbcc77a0b0d84a96363ee5ef54cf01 ; docs/specifications/fd-test-calendaire.md 60ece20b0943a8cad6f14688a95324ba ; docs/specifications/206-calibration-mc-merz-wuthrich.md 0bef6cde9d64fd6ab053ef2a015dc405 |
| Empreinte sans commentaires de R/engine.R (#231) | 0039d3153e0a5afdb7a28ff94dedd23b |
| Locale LC_CTYPE (origine → travail) | C.UTF-8 → C.UTF-8 |
| DGP (#206, par. 2) | modèle de Mack ajusté à reserve2 (tests/donnees/triangle_mw.csv), I = J = 7, première colonne fixée ; f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469 ; 1,06455 ; 1,02841) ; σ̂² = (0,72404 ; 0,71209 ; 0,69814 ; 0,31478 ; 0,097325 ; 0,18967 ; 0,097325) ; lois N (stats::rnorm), E (loi uniforme sur les 27 valeurs de .mw_pool_residus(aj0, jd0) divisées par leur écart-type de population 0,9988), A ((G − 2)/√2, G ~ Gamma(2) par inversion) ; alternatives : effet multiplicatif sur les incréments de l'exercice t = i + k (i, k à partir de 0, première colonne comprise), puis recumul (spec par. 2.2) |
| Plan (spec par. 2.3) | H0, loi N R = 2000 ; H0, loi E R = 2000 ; H0, loi A R = 1000 ; dernier exercice (t = 7), θ = 0,05 R = 1000 ; dernier exercice (t = 7), θ = 0,10 R = 1000 ; exercice médian (t = 4), θ = 0,05 R = 1000 ; exercice médian (t = 4), θ = 0,10 R = 1000 ; dérive à partir de t = 4, g = 0,03 R = 1000 ; dérive à partir de t = 4, g = 0,05 R = 1000 ; compensation (t = 6, alternée, ligne 0 : 1 + θ), θ = 0,10 R = 1000 ; N0 = 20000 par loi (N, E, A) ; B = 999 ; seuils 0,10 et 0,05 ; α des verdicts 0,10 |
| Graines | triangle b, cellule c : 21000000 + 10000 (c − 1) + b ; bootstrap : 21100000 + 10000 (c − 1) + b ; oracle k, loi ℓ : 21200000 + 20000 (ℓ − 1) + k (ℓ = 1 N, 2 E, 3 A) ; c = rang de la cellule : 1 H0-N, 2 H0-E, 3 H0-A, 4 dernier-005, 5 dernier-010, 6 median-005, 7 median-010, 8 derive-003, 9 derive-005, 10 compensation-010 ; contrôles sur reserve2 : 20260831 ; toutes sous engine_sous_graine() |
| Graines : recherche des collisions | plages triangles 21000001-21092000, bootstrap 21100001-21192000, oracle 21200001-21260000 (disjointes : oui) ; plage de #206 20840001-20960000 disjointe : oui ; 26 littéraux de graine dans 65 fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R), de 20260831 à 23700237 ; littéraux L dont [L ; L + 20000] ou L + 539169 (flux de régime) touche une plage : aucun ; SEED_LOI_NULLE_SW 20260901, graine de reserve2 20260831 et réseau 20260831 + 1000 k ≤ 20760831 de tests/puissance_t8.R hors des plages : oui |
| Triangles refusés | H0-N 0 / 2000 ; H0-E 0 / 2000 ; H0-A 0 / 1000 ; dernier-005 0 / 1000 ; dernier-010 0 / 1000 ; median-005 0 / 1000 ; median-010 0 / 1000 ; derive-003 0 / 1000 ; derive-005 0 / 1000 ; compensation-010 0 / 1000 ; oracle N 0 / 20000 ; oracle E 0 / 20000 ; oracle A 0 / 20000 |
| B effectif (forme deux et bas : mêmes réplications) | minimum 999 ; part des triangles admis à B effectif < B : 0,00000 ; triangles à cumul retiré (#257) : 0 ; plafond atteint : 0 |
| Échantillons oracle (non versionnés, régénérables par leurs graines) : md5 des valeurs | N bda4b411383cddc2441ad375501674bc ; E e3a92860bc8b65e427ec8f730c088fde ; A c64e32940a9f6624bf1a8c663726c789 |
| Reprise | aucune tranche reprise |
| Durée | contrôles généraux 26 s ; calcul des tranches 5100 s d'horloge sur 4 cœur(s) (300 tranche(s) calculée(s), 0 reprise(s)) ; somme des durées des tranches 20391 s CPU ; par triangle admis (B = 999) : 1,267 s sans (i2), 21,583 s avec (i2) ; par triangle oracle : 0,0051 s ; estimation du plan complet (B = 999, 12000 triangles, 3 × 20000 oracle) : 5,66 h CPU, soit 1,42 h d'horloge sur 4 cœurs (efficacité parallèle supposée 1) |
| Valeurs brutes | 20261016-issue276-calendaire-brut.tsv : md5 ec4c9716c2c200cd7ba4b56d20061587, 12000 lignes |
| Versionnable (--ecrire) | oui |
| Critère K1 (texte recopié tel quel, fixé avant exécution) | **K1, décisif** : pour la forme « bas », sous N et sous E, aux deux seuils, classe *compatible* ou *écart mineur* par rapport à ρ_bas (classes de #166). Une *distorsion matérielle libérale* ⇒ **arrêt au point D2-Fd** : #276 n'est pas implémentée, et le mainteneur décide sur le tableau. Une distorsion conservatrice est documentée sans arrêt. |
| Précision d'actuary sur K1 (fixée avant exécution, distincte du texte de K1) | Précision d'actuary du 16/10/2026, avant exécution : pour chaque cellule « bas » (N, E, deux seuils) en écart non tranché, le côté est lu en comparant le taux à ρ_bas. Côté libéral (taux > ρ_bas) : point d'arrêt D2-Fd (écart non tranché, côté libéral), soumis à la lecture d'actuary et à la décision du mainteneur. Côté conservateur (taux < ρ_bas) : documenté sans arrêt. |
| K1 : évaluation mécanique | **rempli** (N 0,10 : compatible ; N 0,05 : écart mineur ; E 0,10 : compatible ; E 0,05 : compatible) |
| Contrôles | (graines) plages triangles 21000001-21092000, bootstrap 21100001-21192000, oracle 21200001-21260000 (disjointes : oui) ; plage de #206 20840001-20960000 disjointe : oui ; 26 littéraux de graine dans 65 fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R), de 20260831 à 23700237 ; littéraux L dont [L ; L + 20000] ou L + 539169 (flux de régime) touche une plage : aucun ; SEED_LOI_NULLE_SW 20260901, graine de reserve2 20260831 et réseau 20260831 + 1000 k ≤ 20760831 de tests/puissance_t8.R hors des plages : oui : OK ; (a) reserve2 (seed 20260831, B = 999) : p_mc « deux » du script 0.004, référence 0.004 ; p_min_mc « deux » du script 0.002, référence 0.002 (tests/reference/reserve2.rds, md5 561efb5ea15528322615b9307ca3e5a2 ; attendu 0,004 et 0,002) ; forme « bas » : p_mc 0.002, p_min_mc 0.001 ; B effectif 999 : OK ; (i2) reserve2 : p « deux », p_min_mc « deux » et B effectif du script identiques (identical()) à mw_bootstrap(aj, 999, 20260831) du moteur, clé Calendrier : p oui, p_min_mc oui, B_eff oui : OK ; (i2) premier triangle admis de chaque tranche de 50 (240 triangles du plan) : p « deux », p_min_mc « deux » et B effectif du script identiques (identical()) à mw_bootstrap(aj, B, graine) du moteur : OK ; (d) B effectif ≤ B ; p « deux » sur la grille 2k/(B_eff + 1) (plafonnée à 1), p « bas » sur k/(B_eff + 1) ; p_min_mc ≤ p_mc dans chaque forme : OK |

### T1 — niveau sous H0 (loi × forme × seuil)

Taux de rejet k / n (p_mc < α) sur les triangles admis, p absente comptée comme non-rejet ; IC de Clopper-Pearson à 95 % ; ρ : taille lissée à B du test de Monte-Carlo idéal tirant ses répliques dans la loi oracle F0 (règle de #206, forme de la ligne) ; classe de #166 contre ρ (côté en gras si l'IC est disjoint de la bande [ρ/2 ; 3ρ/2]), calculée sur les valeurs non arrondies. K1 lit les lignes « bas » sous N et E ; la loi A est descriptive.

| Loi | Forme | Seuil | n | p absentes | k | taux [IC 95 %] | ρ | classe |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | deux | 0,10 | 2000 | 0 | 162 | 0,08100 [0,06941 ; 0,09383] | 0,08646 | compatible |
| N | deux | 0,05 | 2000 | 0 | 74 | 0,03700 [0,02916 ; 0,04623] | 0,04235 | compatible |
| N | bas | 0,10 | 2000 | 0 | 167 | 0,08350 [0,07174 ; 0,09649] | 0,08939 | compatible |
| N | bas | 0,05 | 2000 | 0 | 61 | 0,03050 [0,02341 ; 0,03901] | 0,04124 | écart mineur |
| E | deux | 0,10 | 2000 | 0 | 152 | 0,07600 [0,06476 ; 0,08850] | 0,08634 | compatible |
| E | deux | 0,05 | 2000 | 0 | 81 | 0,04050 [0,03229 ; 0,05009] | 0,04140 | compatible |
| E | bas | 0,10 | 2000 | 0 | 182 | 0,09100 [0,07875 ; 0,10446] | 0,09126 | compatible |
| E | bas | 0,05 | 2000 | 0 | 73 | 0,03650 [0,02872 ; 0,04568] | 0,04110 | compatible |
| A | deux | 0,10 | 1000 | 0 | 83 | 0,08300 [0,06665 ; 0,10185] | 0,08517 | compatible |
| A | deux | 0,05 | 1000 | 0 | 35 | 0,03500 [0,02450 ; 0,04834] | 0,04136 | compatible |
| A | bas | 0,10 | 1000 | 0 | 84 | 0,08400 [0,06755 ; 0,10294] | 0,09038 | compatible |
| A | bas | 0,05 | 1000 | 0 | 37 | 0,03700 [0,02618 ; 0,05064] | 0,04003 | compatible |

**Loi oracle F0 de la statistique observée (N0 triangles par loi, sans bootstrap).**

| Loi | N0 | admis | statistiques finies | valeurs distinctes | masse du plus gros atome | ρ deux 0,10 | ρ deux 0,05 | ρ bas 0,10 | ρ bas 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 20000 | 20000 | 20000 | 83 | 0,09845 | 0,08646 | 0,04235 | 0,08939 | 0,04124 |
| E | 20000 | 20000 | 20000 | 86 | 0,10340 | 0,08634 | 0,04140 | 0,09126 | 0,04110 |
| A | 20000 | 20000 | 20000 | 86 | 0,10115 | 0,08517 | 0,04136 | 0,09038 | 0,04003 |

### T2 — puissance (scénario × forme × seuil), loi N

Taux de rejet k / n [IC de Clopper-Pearson à 95 %] ; paires discordantes sur les mêmes triangles et les mêmes réplications (« bas seul » : la forme bas rejette, la forme deux non ; « deux seul » : l'inverse) ; McNemar exact bilatéral (binomiale de paramètre 1/2 sur les paires discordantes). K2 : descriptif, aucun seuil.

| Scénario | Seuil | n | taux deux [IC] | taux bas [IC] | bas seul / deux seul | McNemar p |
| --- | --- | --- | --- | --- | --- | --- |
| dernier exercice (t = 7), θ = 0,05 | 0,10 | 1000 | 0,15700 [0,13499 ; 0,18105] | 0,23500 [0,20903 ; 0,26254] | 96 / 18 | 4,72e-14 |
| dernier exercice (t = 7), θ = 0,05 | 0,05 | 1000 | 0,09500 [0,07754 ; 0,11488] | 0,13900 [0,11815 ; 0,16200] | 51 / 7 | 2,4e-09 |
| dernier exercice (t = 7), θ = 0,10 | 0,10 | 1000 | 0,23300 [0,20712 ; 0,26047] | 0,40100 [0,37045 ; 0,43213] | 172 / 4 | 8,26e-46 |
| dernier exercice (t = 7), θ = 0,10 | 0,05 | 1000 | 0,14000 [0,11908 ; 0,16307] | 0,22900 [0,20329 ; 0,25632] | 89 / 0 | 3,23e-27 |
| exercice médian (t = 4), θ = 0,05 | 0,10 | 1000 | 0,11300 [0,09404 ; 0,13427] | 0,21800 [0,19277 ; 0,24490] | 115 / 10 | 9,12e-24 |
| exercice médian (t = 4), θ = 0,05 | 0,05 | 1000 | 0,06800 [0,05319 ; 0,08541] | 0,10300 [0,08485 ; 0,12352] | 38 / 3 | 1,05e-08 |
| exercice médian (t = 4), θ = 0,10 | 0,10 | 1000 | 0,18500 [0,16139 ; 0,21048] | 0,31900 [0,29018 ; 0,34889] | 136 / 2 | 5,51e-38 |
| exercice médian (t = 4), θ = 0,10 | 0,05 | 1000 | 0,11400 [0,09496 ; 0,13534] | 0,18300 [0,15950 ; 0,20839] | 69 / 0 | 3,39e-21 |
| dérive à partir de t = 4, g = 0,03 | 0,10 | 1000 | 0,08400 [0,06755 ; 0,10294] | 0,16200 [0,13969 ; 0,18632] | 88 / 10 | 9,94e-17 |
| dérive à partir de t = 4, g = 0,03 | 0,05 | 1000 | 0,04600 [0,03387 ; 0,06088] | 0,07400 [0,05855 ; 0,09201] | 30 / 2 | 2,46e-07 |
| dérive à partir de t = 4, g = 0,05 | 0,10 | 1000 | 0,10400 [0,08577 ; 0,12460] | 0,20500 [0,18038 ; 0,23137] | 107 / 6 | 5,15e-25 |
| dérive à partir de t = 4, g = 0,05 | 0,05 | 1000 | 0,06600 [0,05141 ; 0,08321] | 0,09800 [0,08028 ; 0,11813] | 34 / 2 | 1,94e-08 |
| compensation (t = 6, alternée, ligne 0 : 1 + θ), θ = 0,10 | 0,10 | 1000 | 0,10900 [0,09036 ; 0,12998] | 0,01700 [0,00993 ; 0,02708] | 14 / 106 | 1,16e-18 |
| compensation (t = 6, alternée, ligne 0 : 1 + θ), θ = 0,10 | 0,05 | 1000 | 0,04800 [0,03560 ; 0,06314] | 0,00300 [0,00062 ; 0,00874] | 3 / 48 | 1,97e-11 |

### T3 — règle de Mack (1997) appliquée à toutes les diagonales (descriptif, #275)

Part des triangles admis où au moins une diagonale retenue (n_k ≥ 2) a P(Z_k ≤ z_k) ≤ 10 % sous Binomiale(n_k, 1/2), sans correction de multiplicité ; nombre moyen de diagonales signalées ; diagonales pouvant porter le repère (n_k ≥ 5).

| Cellule | n | ≥ 1 diagonale signalée [IC] | diagonales signalées (moyenne) | diagonales à n_k ≥ 5 (médiane) |
| --- | --- | --- | --- | --- |
| H0, loi N | 2000 | 0,10050 [0,08767 ; 0,11452] | 0,107 | 2 |
| H0, loi E | 2000 | 0,10750 [0,09426 ; 0,12190] | 0,116 | 2 |
| H0, loi A | 1000 | 0,09700 [0,07936 ; 0,11705] | 0,106 | 2 |
| dernier exercice (t = 7), θ = 0,05 | 1000 | 0,28300 [0,25525 ; 0,31203] | 0,323 | 2 |
| dernier exercice (t = 7), θ = 0,10 | 1000 | 0,55200 [0,52056 ; 0,58313] | 0,631 | 2 |
| exercice médian (t = 4), θ = 0,05 | 1000 | 0,14800 [0,12655 ; 0,17154] | 0,153 | 2 |
| exercice médian (t = 4), θ = 0,10 | 1000 | 0,16200 [0,13969 ; 0,18632] | 0,171 | 2 |
| dérive à partir de t = 4, g = 0,03 | 1000 | 0,16200 [0,13969 ; 0,18632] | 0,169 | 2 |
| dérive à partir de t = 4, g = 0,05 | 1000 | 0,22200 [0,19659 ; 0,24906] | 0,225 | 2 |
| compensation (t = 6, alternée, ligne 0 : 1 + θ), θ = 0,10 | 1000 | 0,02400 [0,01544 ; 0,03550] | 0,025 | 2 |

### T4 — plancher Monte-Carlo p_min_mc des deux formes

Maximum de p_min_mc sur les triangles admis à p_mc finie, et parts > α/2 et > α (α = 0,10, α des verdicts ; entre parenthèses, parts ≥, comparaison de la règle R1 d'add()).

| Cellule | Forme | n (p_min_mc finie) | maximum | part > α/2 (≥) | part > α (≥) |
| --- | --- | --- | --- | --- | --- |
| H0, loi N | deux | 2000 | 0,0040 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| H0, loi N | bas | 2000 | 0,0020 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| H0, loi E | deux | 2000 | 0,0060 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| H0, loi E | bas | 2000 | 0,0030 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| H0, loi A | deux | 1000 | 0,0040 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| H0, loi A | bas | 1000 | 0,0020 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| dernier exercice (t = 7), θ = 0,05 | deux | 1000 | 0,0060 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| dernier exercice (t = 7), θ = 0,05 | bas | 1000 | 0,0030 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| dernier exercice (t = 7), θ = 0,10 | deux | 1000 | 0,0040 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| dernier exercice (t = 7), θ = 0,10 | bas | 1000 | 0,0020 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| exercice médian (t = 4), θ = 0,05 | deux | 1000 | 0,0060 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| exercice médian (t = 4), θ = 0,05 | bas | 1000 | 0,0030 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| exercice médian (t = 4), θ = 0,10 | deux | 1000 | 0,0040 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| exercice médian (t = 4), θ = 0,10 | bas | 1000 | 0,0020 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| dérive à partir de t = 4, g = 0,03 | deux | 1000 | 0,0040 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| dérive à partir de t = 4, g = 0,03 | bas | 1000 | 0,0020 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| dérive à partir de t = 4, g = 0,05 | deux | 1000 | 0,0060 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| dérive à partir de t = 4, g = 0,05 | bas | 1000 | 0,0030 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| compensation (t = 6, alternée, ligne 0 : 1 + θ), θ = 0,10 | deux | 1000 | 0,0040 | 0,00000 (0,00000) | 0,00000 (0,00000) |
| compensation (t = 6, alternée, ligne 0 : 1 + θ), θ = 0,10 | bas | 1000 | 0,0020 | 0,00000 (0,00000) | 0,00000 (0,00000) |

### T5 — transitions de verdict « deux » → « bas » (descriptif)

Règle d'add() à α = 0,10 : ECHEC si p < α/2, ALERTE si p < α, OK sinon ; TEST INOPERANT si p_min_mc ≥ α (règle R1, branche Monte-Carlo) ; INFO si la p Monte-Carlo manque. Ligne : verdict de la forme deux ; colonne : verdict de la forme bas ; effectifs de triangles admis.

**H0, loi N** (n = 2000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 1732 | 106 | 0 |
| ALERTE | 58 | 0 | 30 |
| ECHEC | 43 | 0 | 31 |

**H0, loi E** (n = 2000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 1739 | 109 | 0 |
| ALERTE | 36 | 0 | 35 |
| ECHEC | 43 | 0 | 38 |

**H0, loi A** (n = 1000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 870 | 47 | 0 |
| ALERTE | 30 | 0 | 18 |
| ECHEC | 16 | 0 | 19 |

**dernier exercice (t = 7), θ = 0,05** (n = 1000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 747 | 96 | 0 |
| ALERTE | 11 | 0 | 51 |
| ECHEC | 7 | 0 | 88 |

**dernier exercice (t = 7), θ = 0,10** (n = 1000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 595 | 172 | 0 |
| ALERTE | 4 | 0 | 89 |
| ECHEC | 0 | 0 | 140 |

**exercice médian (t = 4), θ = 0,05** (n = 1000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 772 | 115 | 0 |
| ALERTE | 7 | 0 | 38 |
| ECHEC | 3 | 0 | 65 |

**exercice médian (t = 4), θ = 0,10** (n = 1000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 679 | 136 | 0 |
| ALERTE | 2 | 0 | 69 |
| ECHEC | 0 | 0 | 114 |

**dérive à partir de t = 4, g = 0,03** (n = 1000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 828 | 88 | 0 |
| ALERTE | 8 | 0 | 30 |
| ECHEC | 2 | 0 | 44 |

**dérive à partir de t = 4, g = 0,05** (n = 1000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 789 | 107 | 0 |
| ALERTE | 4 | 0 | 34 |
| ECHEC | 2 | 0 | 64 |

**compensation (t = 6, alternée, ligne 0 : 1 + θ), θ = 0,10** (n = 1000).

| deux (ligne) / bas (colonne) | OK | ALERTE | ECHEC |
| --- | --- | --- | --- |
| OK | 877 | 14 | 0 |
| ALERTE | 58 | 0 | 3 |
| ECHEC | 48 | 0 | 0 |

### T6 — niveau des p asymptotiques sous H0

p bilatérale 2(1 − Φ(|Z*|)) (forme actuelle du moteur) et p unilatérale Φ(Z*) (Q-Fd-3) : taux de rejet k / n [IC 95 %] sur les triangles mesurés, et taux sur l'échantillon oracle (N0 triangles, statistique seule ; dénominateur : triangles oracle admis).

| Loi | Forme | Seuil | n | taux [IC] | taux oracle (N0) |
| --- | --- | --- | --- | --- | --- |
| N | deux | 0,10 | 2000 | 0,11850 [0,10465 ; 0,13348] | 0,11815 |
| N | deux | 0,05 | 2000 | 0,08750 [0,07548 ; 0,10075] | 0,09390 |
| N | bas | 0,10 | 2000 | 0,15400 [0,13845 ; 0,17057] | 0,16325 |
| N | bas | 0,05 | 2000 | 0,05800 [0,04816 ; 0,06916] | 0,06630 |
| E | deux | 0,10 | 2000 | 0,10950 [0,09614 ; 0,12401] | 0,11760 |
| E | deux | 0,05 | 2000 | 0,08850 [0,07641 ; 0,10181] | 0,09335 |
| E | bas | 0,10 | 2000 | 0,16950 [0,15330 ; 0,18667] | 0,16160 |
| E | bas | 0,05 | 2000 | 0,06350 [0,05321 ; 0,07509] | 0,06450 |
| A | deux | 0,10 | 1000 | 0,11600 [0,09681 ; 0,13749] | 0,11670 |
| A | deux | 0,05 | 1000 | 0,08300 [0,06665 ; 0,10185] | 0,09240 |
| A | bas | 0,10 | 1000 | 0,14300 [0,12188 ; 0,16625] | 0,16180 |
| A | bas | 0,05 | 1000 | 0,06000 [0,04610 ; 0,07656] | 0,06395 |

