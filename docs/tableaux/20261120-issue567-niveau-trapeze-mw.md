## Mesure #567 (S6, étape 5 (b)) : niveau à T = 8 des tests de Merz-Wüthrich sur les trapèzes 8 x 5, 8 x 6 et 8 x 7

### Statut épistémique (spécification, par. 8, reproduit tel quel)

**Statut épistémique**, à écrire en tête des sorties : constat de simulation sous un plan (modèle de Mack ajusté à `reserve2`, T = I + 1 = 8, lois N et E, B = 999), conditionnel à l'admission. Ce n'est pas un résultat général ; il ne se transpose ni à d'autres paramètres ni à d'autres géométries. Aucun théorème ne couvre ces tests bootstrap à T = 8.

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Protocole | docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md, par. 8 (P1 à P8) et 9 ; décisions du mainteneur du 20/11/2026 (D1', Q-2a-1 (c), Q-2a-2, Q-2a-3, Q-2a-5) ; md5 00317e14a9d4c6115a4651f53537fd2b |
| Mode | mesure, niveau L0 (pré-vol, P4) |
| R par (G, loi) (tirés) ; N0 par (G, loi) ; B | 8x5 : 2000, 8x6 : 2000, 8x7 : 1000 ; 20000 ; 999 |
| DGP (P2) | modèle de Mack ajusté à reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv, md5 3e9a584da42443f3816fb63deeffa95b), j = 0..J − 1, première colonne fixée, I = 7 ; 8x5 (J = 4) : f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042) ; σ² = (0,72404 ; 0,712092 ; 0,698141 ; 0,314779) ; σ²_(J−1) vrai = 0,314779 (critère : 0,31478, arrondi conforme) ; 8x6 (J = 5) : f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469) ; σ² = (0,72404 ; 0,712092 ; 0,698141 ; 0,314779 ; 0,0973248) ; σ²_(J−1) vrai = 0,0973248 (critère : 0,097325, arrondi conforme) ; 8x7 (J = 6) : f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469 ; 1,06455) ; σ² = (0,72404 ; 0,712092 ; 0,698141 ; 0,314779 ; 0,0973248 ; 0,189674) ; σ²_(J−1) vrai = 0,189674 (critère : 0,18967, arrondi conforme) |
| Lois | N : stats::rnorm ; E : tirage uniforme dans les 27 valeurs de .mw_pool_residus(aj0, jd0) de reserve2 divisées par leur écart-type de population (0,99879) |
| Chemin (P1) | gen_triangle_h0(DGP_G, loi) sous engine_sous_graine(graine du triangle) ; admission hors MW-04 (mw_valider_triangle(), domaine numérique, mw_ajuster(), mw_msep(), mw_valider_ajustement() ; segment 1, annexe II) ; mw_ajuster() → .mw_ensembles_figes() → mw_bootstrap(aj, B, graine du bootstrap, figes) → mw_tests(aj, boot, α = 0,10, figes) |
| Graines (P3 amendé le 20/11/2026, constat m1, appliquées exactement) | triangle b, loi ℓ : 567 000 000 + 100 000 (ℓ − 1) + b ; bootstrap : 568 000 000 + 1 000 000 (g − 1) + 100 000 (ℓ − 1) + b ; oracle k : 570 500 000 + 100 000 (ℓ − 1) + k ; pré-vol : 571 000 000 + u et 571 050 000 + u ; ℓ = 1 (N), 2 (E) ; g = 1 (8 x 5), 2 (8 x 6), 3 (8 x 7) |
| Chevauchement interne des plages (bloquant, P3 amendé) | aucun |
| Générateur aléatoire | Mersenne-Twister, Inversion, Rejection |
| Oracle | 8x5 N : 20000 tirés, 20000 admis ; 8x5 E : 20000 tirés, 20000 admis ; 8x6 N : 20000 tirés, 20000 admis ; 8x6 E : 20000 tirés, 20000 admis ; 8x7 N : 20000 tirés, 20000 admis ; 8x7 E : 20000 tirés, 20000 admis ; valeurs non versionnées (oracle.tsv du dossier de travail), md5 5bdafe159cd5624fee6ba906896d4f40 |
| Archive ChainLadder (contrôle (c1)) | archive ChainLadder_0.2.21.tar.gz (md5 2a1fc0fcc593ec99529a40399274a088 = attendu), CL_MSEPs lignes 11 à 73 de ChainLadder/R/MWChainLadder.R (md5 53cde7fbc23cc6d2aa8e2b255fdb3bd0, texte md5 afb0d678d823745dd9808b9aa9e10d67), paquet ChainLadder 0.2.21, en-tête d'auteur présent |
| Brut de #297 (K-T6, (r297)) | docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv, md5 01325170c75ccc603707f96332dc1e96 |
| SHA, git rev-parse HEAD (début ; fin) | 425c1c938e973bc0f8c538d299b0cecf6ff9db6b ; 425c1c938e973bc0f8c538d299b0cecf6ff9db6b |
| Commit (commit_depot(), au début) | 425c1c938e973bc0f8c538d299b0cecf6ff9db6b |
| md5 R/engine.R (début ; fin) | faf36c545999c147087759155a2bd38a ; faf36c545999c147087759155a2bd38a |
| Empreinte sans commentaires de R/engine.R (#231 ; début ; fin) | 307e07604e7d87b23173f48daebb9383 ; 307e07604e7d87b23173f48daebb9383 |
| Empreintes md5 du code exécuté | R/engine.R faf36c545999c147087759155a2bd38a ; tests/outils_tests.R chargé (dépôt) cdf8f7da242e2c6281fadcb4108aab63 ; script exécuté (dépôt) d7d1a0e6907953ca9a055a228c21554b |
| Plateforme de calcul | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Locale (LC_CTYPE) | C.UTF-8 → C.UTF-8 |
| Tranches | 1300 (taille 100), triangles tirés et oracles |
| JOURNAL ; valeurs brutes | 20261120-issue567-niveau-trapeze-mw-journal-mesure.md ; 20261120-issue567-niveau-trapeze-mw-brut.tsv (une ligne par triangle tiré, %.17g) |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK |

### Aide à la lecture

Erreurs séparées (P5) : IC de Clopper-Pearson à 95 % sur τ (erreur Monte-Carlo, fonction de R) ; err_mc de chaque p (fonction de B), incluse dans la procédure et dans ρ ; erreur de ρ due à N0 (de l'ordre de 0,002 [H], #206) ; écart τ − ρ, objet mesuré (erreur à T = 8 du test bootstrap à paramètres estimés) ; erreur de substitution (plan et loi au lieu de la vérité), non quantifiée. Population : triangles admis (statut admis ou échec ; un échec du bootstrap ou des tests donne des p absentes, comptées comme non-rejets et à part). Classes et profils calculés mécaniquement, sur les valeurs non arrondies, **sans conclure**.

**Critère (spécification, par. 8, P7), reporté sans modification :**

**P7. Critère**, à reporter sans modification :

> **Critère.** D = 1 si p_mc < α, α ∈ {0,10 ; 0,05} ; une p absente compte comme un non-rejet, comptée à part. τ = k/n sur les triangles admis, IC de Clopper-Pearson à 95 %. Référence ρ(s, α, G, ℓ) : taille lissée du test de Monte-Carlo idéal à B = 999 sur l'oracle de (G, ℓ) (règle de #206 § 4). Classes de #166 et #206, bande fermée [ρ/2 ; 3ρ/2] : compatible ; écart mineur ; non tranché ; distorsion matérielle libérale ou conservatrice ; valeurs non arrondies ; un non tranché reste non tranché.
> - **K1** (principal) : classe des 13 clés de `MW_CATALOGUE_MC` par (G, ℓ, α), G ∈ {8×5, 8×6}.
> - **K-T6** (contrôle d'implémentation, sous (c)) : pour 8×7, classes K1 ; et, par clé et par α, test exact de Fisher bilatéral de τ(8×7) contre τ(8×8, #297, même loi), Holm sur 13 à 0,05.
> - **K3** : témoin oracle, règle bêta-binomiale du 05/11/2026, Holm sur 13.
> - **K4** : p absentes au plus 1 % par (G, ℓ) ; refus au plus 1 %.
> - **K5** (descriptif) : B effectif, motifs ; part des lignes inopérantes (champ `inoperant` de `mw_tests()`) et des statistiques NA par clé et par G.
> - **K-T4** (descriptif, sans critère) : distribution de σ̂²_{J−1} de la règle / σ²_{J−1} vrai et de σ̂²_{J−1,dir} / σ²_{J−1} vrai (vrais : 0,31478 ; 0,097325 ; 0,18967 pour 8×5, 8×6, 8×7) ; rapport des √MSEP règle / direct ; taux de M4.
> - **K-T7** (descriptif) : niveau des p de famille et de la p globale (`engine_p_famille()`).
>
> **Profils pour D2** (`actuary` propose, le mainteneur tranche ; ordre Θ0, Θ5, Θ4, Θ3, Θ2, Θ1) :
>
> | Profil | Condition | Lecture proposée |
> |---|---|---|
> | Θ0 | intégrité, K3 ou K4 en défaut ; ou K-T6 significatif, non expliqué | lecture suspendue ; implémentation à revoir |
> | Θ5 | une clé en distorsion de côtés opposés entre N et E pour une G | niveau non robuste à la loi : documenter ; décision du mainteneur pour la clé |
> | Θ4 | distorsion matérielle libérale d'une clé sur 8×5 ou 8×6, pour une loi | les ALERTE et ECHEC de la clé sur cette géométrie surestiment la preuve. Options : extension avec la clé en diagnostic sur la géométrie, ou refus maintenu. Si la même distorsion existe sur le 8×8 (#297), elle n'est pas propre au trapèze et se lit comme telle |
> | Θ3 | distorsion matérielle conservatrice sur une clé | extension possible ; OK de la clé = preuve faible, écrit par géométrie |
> | Θ2 | aucune distorsion, des non tranchés | extension possible, IC documentés |
> | Θ1 | 13 clés compatibles ou en écart mineur sur 8×5 et 8×6, N et E, aux deux seuils, et K-T6 sans signal | niveau comparable au carré ; le volet « tests » ne s'oppose pas à l'extension |

### Contrôles d'intégrité (P6)

| Contrôle | Résultat | Détail |
| --- | --- | --- |
| (1) | OK | md5 R/engine.R début faf36c545999c147087759155a2bd38a, fin faf36c545999c147087759155a2bd38a, JOURNAL faf36c545999c147087759155a2bd38a ; SHA début 425c1c938e973bc0f8c538d299b0cecf6ff9db6b, fin 425c1c938e973bc0f8c538d299b0cecf6ff9db6b, JOURNAL 425c1c938e973bc0f8c538d299b0cecf6ff9db6b ; empreinte #231 début 307e07604e7d87b23173f48daebb9383, fin 307e07604e7d87b23173f48daebb9383, JOURNAL 307e07604e7d87b23173f48daebb9383 ; contexte (B, SHA, md5 du moteur et du script, empreinte, plateforme) identique dans les 1300 tranche(s) : oui |
| (a) | OK | reserve2 (executer_cas("reserve2"), run_engine() par défaut) contre tests/reference/reserve2.rds, comparer_objets(tol = 0) : 18730 feuilles, 0 différente(s), 0 écart(s), écart maximal 0 : chemin carré intact au seuil 0 |
| (m4) | OK | run_engine(methode = "reserve2", triangle = colonnes 0..J de reserve2) : 8x5 : ok = FALSE, 1 motif(s), MW-04 seul ; 8x6 : ok = FALSE, 1 motif(s), MW-04 seul ; 8x7 : ok = FALSE, 1 motif(s), MW-04 seul ; la garde MW-04 est en place |
| (g) | OK | gen_triangle_h0() (ε tirés par sample(pool)) = .mw_simuler_triangle_etat() sous la même graine (identical(), indicateur complet compris) : 8x5 : 100 / 100 identiques ; pool dilaté 30 fois : 100 / 100 identiques, dont 39 à cumul simulé non fini ou ≤ 0 ; 8x6 : 100 / 100 identiques ; pool dilaté 30 fois : 100 / 100 identiques, dont 41 à cumul simulé non fini ou ≤ 0 ; 8x7 : 100 / 100 identiques ; pool dilaté 30 fois : 100 / 100 identiques, dont 42 à cumul simulé non fini ou ≤ 0 ; 8x8 : 100 / 100 identiques ; pool dilaté 30 fois : 100 / 100 identiques, dont 42 à cumul simulé non fini ou ≤ 0 ; mw_simuler_triangle, .mw_simuler_triangle_etat, .mw_tirer_triangle_valide, .mw_triangle_incomplet, .mw_pool_residus, mw_bootstrap, mw_ajuster, mw_msep, mw_tests, mw_valider_triangle, .mw_ensembles_figes de l'environnement identiques (formals, body) à celles de R/engine.R relu : oui |
| (g') | OK | trapèze G simulé = colonnes 0..J du 8 x 8 simulé sous la même graine (identical()), avant tout tirage du plan : 8x5 : 200 / 200 identiques ; ε dilatés 30 fois : 200 / 200, dont 82 trapèze(s) incomplet(s) ; 8x6 : 200 / 200 identiques ; ε dilatés 30 fois : 200 / 200, dont 85 trapèze(s) incomplet(s) ; 8x7 : 200 / 200 identiques ; ε dilatés 30 fois : 200 / 200, dont 91 trapèze(s) incomplet(s) ; contrôle répété sur chaque triangle tiré (colonne gp, plus bas) ; plan : 10000 / 10000 triangles tirés où le trapèze = troncature du 8 x 8 simulé sous la même graine ; triangles dont la génération a échoué (refus « erreur », troncature non calculée, hors contrôle) : 0 |
| (c1) | OK | critère C1 (par. 1.3) : MSEP et R du moteur contre CL_MSEPs, f, σ²_j et estimateur direct contre la transcription indépendante, tolérance 1e-12 relative ; archive ChainLadder_0.2.21.tar.gz (md5 2a1fc0fcc593ec99529a40399274a088 = attendu), CL_MSEPs lignes 11 à 73 de ChainLadder/R/MWChainLadder.R (md5 53cde7fbc23cc6d2aa8e2b255fdb3bd0, texte md5 afb0d678d823745dd9808b9aa9e10d67), paquet ChainLadder 0.2.21, en-tête d'auteur présent ; trapèzes de reserve2 : 8x5 OK (0.00e+00), 8x6 OK (4.20e-16), 8x7 OK (0.00e+00) ; premier triangle admis de chaque tranche : 100 / 100 tranches, écart maximal 2.92e-16 ; tranches sans triangle admis (contrôle sans objet) : aucune |
| (r297) | OK | docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv, lignes rep, lois N et E, b = 1 et 2, colonnes pR:<clé> contre mw_bootstrap(B = 999) aux graines de #206 : N b = 1 (graines 20840001 et 20870001) : 13 / 13 p_mc identiques ; N b = 2 (graines 20840002 et 20870002) : 13 / 13 p_mc identiques ; E b = 1 (graines 20850001 et 20880001) : 13 / 13 p_mc identiques ; E b = 2 (graines 20850002 et 20880002) : 13 / 13 p_mc identiques (identical()) |
| (o) | OK | 8 x 7 (colonnes 0..6 de reserve2) : statistiques observées des 13 clés identical() à bootstrap$stats_obs de tests/reference/reserve2.rds, chemin de mw_bootstrap() : oui ; chemin de l'oracle (stats_oracle()) : oui |
| (t) | OK | par. 8, P7 (critère et profils, 21 lignes) présent à l'identique ; statut épistémique (par. 8, une ligne) présent à l'identique, dans docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md (md5 00317e14a9d4c6115a4651f53537fd2b) ; vérifié avant la boucle de calcul |
| (graines) | OK | plages de la mesure (triangles, bootstraps des 3 G x 2 lois, oracles, pré-vol ; b ≤ 2000, k ≤ 20000) de 567000001 à 571100000 ; disjointes de #206/#297 MW 20840001-20960000, #297 LN 20260831-20262831, #305 305000000-305939169, #387 387000000-393100000 et de 360 380 123 : oui ; graines de (r297) hors des plages : oui ; maximum ≤ 2^31 − 1 : oui ; 146 littéraux entiers de 8 à 10 chiffres dans 99 fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R ; écriture scientifique non recherchée) ; littéraux L dont [L ; L + 20000] touche une plage : aucun ; littéraux dans [567 000 000 ; 572 000 000[ (plage réservée par P3) : aucun ; déclarations de la plage réservée par P3 [567000000 ; 572000000] (forme exacte PLAGE_<nom> <- c(L1, L2), R21), écartées de la recherche des graines et citées ici : couverture_ic_sigma_mw_imbrique_t8.R, l. 275 (PLAGE_EXT_2A) ; chevauchements internes des plages de la mesure (bloquants, P3 amendé) : aucun |
| (m) | OK | aucune occurrence de « niveau_mw_trapeze » dans R/, app.R et .github/ (18 fichiers lus) ; en défaut : aucun |
| (i1) | OK | statistiques observées par le chemin de l'oracle (stats_oracle()) identical() à bootstrap$stats_obs (validité du témoin K3, #206 par. 6) : 100 / 100 triangles de contrôle au bootstrap abouti (0 triangle(s) de contrôle en échec) |
| (rep) | OK | premier et dernier triangles admis de chaque (G, loi) recalculés : 12 / 12 lignes identiques à celles des tranches, hors durée (8x5 N b = 1, 8x5 N b = 2000, 8x5 E b = 1, 8x5 E b = 2000, 8x6 N b = 1, 8x6 N b = 2000, 8x6 E b = 1, 8x6 E b = 2000, 8x7 N b = 1, 8x7 N b = 1000, 8x7 E b = 1, 8x7 E b = 1000) ; (G, loi) sans triangle admis (sans objet, K4) : aucune |

### Référence ρ et oracle par (G, loi)

ρ : taille lissée à B = 999 du test de Monte-Carlo idéal tirant ses répliques dans l'oracle de (G, loi) (règle de #206, par. 4) ; statistique oracle non finie comptée comme non-rejet ; « approché » au-delà de 1 % de statistiques oracle non finies. Taille du témoin : même règle à B = nombre de statistiques finies.

| G | Loi | Clé (sens) | oracle admis / tirés | non finies | valeurs distinctes | masse du plus gros atome | ρ 0,10 | ρ 0,05 | taille témoin 0,10 | taille témoin 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | Calendrier (bas) | 20000 / 20000 | 0 | 33 | 0,12210 | 0,08132 | 0,03434 | 0,08627 | 0,03310 |
| 8x5 | N | CorrDev (deux) | 20000 / 20000 | 0 | 2432 | 0,00230 | 0,09737 | 0,04753 | 0,09942 | 0,04958 |
| 8x5 | N | BP (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | N | MinP4 (bas) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | N | DW (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x5 | N | Runs (deux) | 20000 / 20000 | 0 | 17 | 0,17430 | 0,06108 | 0,03331 | 0,05603 | 0,03610 |
| 8x5 | N | PenteIntra (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x5 | N | Origine (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | N | HomogF (haut) | 20000 / 20000 | 0 | 10882 | 0,00085 | 0,09896 | 0,04896 | 0,09995 | 0,04996 |
| 8x5 | N | Courbure (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | N | Alpha (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | N | ExpVar (haut) | 20000 / 20000 | 0 | 11105 | 0,00065 | 0,09896 | 0,04897 | 0,09995 | 0,04996 |
| 8x5 | N | KruskalAcc (haut) | 20000 / 20000 | 0 | 4341 | 0,00105 | 0,09889 | 0,04893 | 0,09988 | 0,04993 |
| 8x5 | E | Calendrier (bas) | 20000 / 20000 | 0 | 35 | 0,12660 | 0,08285 | 0,03274 | 0,09299 | 0,03090 |
| 8x5 | E | CorrDev (deux) | 20000 / 20000 | 0 | 2435 | 0,00245 | 0,09738 | 0,04752 | 0,09951 | 0,04956 |
| 8x5 | E | BP (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | E | MinP4 (bas) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | E | DW (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x5 | E | Runs (deux) | 20000 / 20000 | 0 | 15 | 0,17445 | 0,05871 | 0,03327 | 0,05078 | 0,03585 |
| 8x5 | E | PenteIntra (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x5 | E | Origine (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | E | HomogF (haut) | 20000 / 20000 | 0 | 10975 | 0,00080 | 0,09896 | 0,04897 | 0,09995 | 0,04996 |
| 8x5 | E | Courbure (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | E | Alpha (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x5 | E | ExpVar (haut) | 20000 / 20000 | 0 | 10880 | 0,00075 | 0,09896 | 0,04897 | 0,09996 | 0,04996 |
| 8x5 | E | KruskalAcc (haut) | 20000 / 20000 | 0 | 4332 | 0,00105 | 0,09890 | 0,04893 | 0,09989 | 0,04993 |
| 8x6 | N | Calendrier (bas) | 20000 / 20000 | 0 | 76 | 0,08565 | 0,08921 | 0,04530 | 0,09265 | 0,04793 |
| 8x6 | N | CorrDev (deux) | 20000 / 20000 | 0 | 2845 | 0,00215 | 0,09752 | 0,04760 | 0,09950 | 0,04960 |
| 8x6 | N | BP (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | N | MinP4 (bas) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | N | DW (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x6 | N | Runs (deux) | 20000 / 20000 | 0 | 17 | 0,17210 | 0,06778 | 0,02467 | 0,07005 | 0,02255 |
| 8x6 | N | PenteIntra (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x6 | N | Origine (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | N | HomogF (haut) | 20000 / 20000 | 0 | 10882 | 0,00085 | 0,09896 | 0,04896 | 0,09995 | 0,04996 |
| 8x6 | N | Courbure (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | N | Alpha (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | N | ExpVar (haut) | 20000 / 20000 | 0 | 11105 | 0,00065 | 0,09896 | 0,04897 | 0,09995 | 0,04996 |
| 8x6 | N | KruskalAcc (haut) | 20000 / 20000 | 0 | 11750 | 0,00040 | 0,09896 | 0,04897 | 0,09996 | 0,04997 |
| 8x6 | E | Calendrier (bas) | 20000 / 20000 | 0 | 76 | 0,09210 | 0,08907 | 0,04586 | 0,09170 | 0,04792 |
| 8x6 | E | CorrDev (deux) | 20000 / 20000 | 0 | 2831 | 0,00215 | 0,09747 | 0,04759 | 0,09951 | 0,04956 |
| 8x6 | E | BP (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | E | MinP4 (bas) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | E | DW (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x6 | E | Runs (deux) | 20000 / 20000 | 0 | 16 | 0,17690 | 0,06747 | 0,02528 | 0,07070 | 0,02290 |
| 8x6 | E | PenteIntra (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x6 | E | Origine (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | E | HomogF (haut) | 20000 / 20000 | 0 | 10975 | 0,00080 | 0,09896 | 0,04897 | 0,09995 | 0,04996 |
| 8x6 | E | Courbure (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | E | Alpha (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x6 | E | ExpVar (haut) | 20000 / 20000 | 0 | 10880 | 0,00075 | 0,09896 | 0,04897 | 0,09996 | 0,04996 |
| 8x6 | E | KruskalAcc (haut) | 20000 / 20000 | 0 | 11686 | 0,00045 | 0,09896 | 0,04897 | 0,09995 | 0,04996 |
| 8x7 | N | Calendrier (bas) | 20000 / 20000 | 0 | 86 | 0,10265 | 0,09025 | 0,04114 | 0,09472 | 0,04185 |
| 8x7 | N | CorrDev (deux) | 20000 / 20000 | 0 | 2845 | 0,00215 | 0,09752 | 0,04760 | 0,09950 | 0,04960 |
| 8x7 | N | BP (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | N | MinP4 (bas) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | N | DW (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x7 | N | Runs (deux) | 20000 / 20000 | 0 | 18 | 0,16815 | 0,05332 | 0,03156 | 0,04546 | 0,03780 |
| 8x7 | N | PenteIntra (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x7 | N | Origine (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | N | HomogF (haut) | 20000 / 20000 | 0 | 10882 | 0,00085 | 0,09896 | 0,04896 | 0,09995 | 0,04996 |
| 8x7 | N | Courbure (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | N | Alpha (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | N | ExpVar (haut) | 20000 / 20000 | 0 | 11105 | 0,00065 | 0,09896 | 0,04897 | 0,09995 | 0,04996 |
| 8x7 | N | KruskalAcc (haut) | 20000 / 20000 | 0 | 13678 | 0,00045 | 0,09897 | 0,04897 | 0,09996 | 0,04997 |
| 8x7 | E | Calendrier (bas) | 20000 / 20000 | 0 | 86 | 0,10560 | 0,09036 | 0,04128 | 0,09502 | 0,04155 |
| 8x7 | E | CorrDev (deux) | 20000 / 20000 | 0 | 2831 | 0,00215 | 0,09747 | 0,04759 | 0,09951 | 0,04956 |
| 8x7 | E | BP (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | E | MinP4 (bas) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | E | DW (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x7 | E | Runs (deux) | 20000 / 20000 | 0 | 17 | 0,17290 | 0,05483 | 0,02943 | 0,04739 | 0,02815 |
| 8x7 | E | PenteIntra (deux) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 | 0,04995 |
| 8x7 | E | Origine (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | E | HomogF (haut) | 20000 / 20000 | 0 | 10975 | 0,00080 | 0,09896 | 0,04897 | 0,09995 | 0,04996 |
| 8x7 | E | Courbure (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | E | Alpha (haut) | 20000 / 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 | 0,04997 |
| 8x7 | E | ExpVar (haut) | 20000 / 20000 | 0 | 10880 | 0,00075 | 0,09896 | 0,04897 | 0,09996 | 0,04996 |
| 8x7 | E | KruskalAcc (haut) | 20000 / 20000 | 0 | 13724 | 0,00045 | 0,09896 | 0,04897 | 0,09996 | 0,04997 |

### K1 (principal) — 8 x 5 : classe des 13 clés par (loi, α)

| Loi | α | Clé (sens) | n | p absentes | k | τ [IC CP 95 %] | ρ | classe | τ sur p définies |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,10 | Calendrier (bas) | 2000 | 0 | 174 | 0,08700 [0,07501 ; 0,10022] | 0,08132 | compatible | 0,08700 |
| N | 0,10 | CorrDev (deux) | 2000 | 0 | 176 | 0,08800 [0,07595 ; 0,10128] | 0,09737 | compatible | 0,08800 |
| N | 0,10 | BP (haut) | 2000 | 0 | 218 | 0,10900 [0,09567 ; 0,12349] | 0,09897 | compatible | 0,10900 |
| N | 0,10 | MinP4 (bas) | 2000 | 0 | 100 | 0,05000 [0,04086 ; 0,06048] | 0,09897 | écart mineur | 0,05000 |
| N | 0,10 | DW (deux) | 2000 | 0 | 179 | 0,08950 [0,07735 ; 0,10287] | 0,09795 | compatible | 0,08950 |
| N | 0,10 | Runs (deux) | 2000 | 0 | 115 | 0,05750 [0,04770 ; 0,06862] | 0,06108 | compatible | 0,05750 |
| N | 0,10 | PenteIntra (deux) | 2000 | 0 | 177 | 0,08850 [0,07641 ; 0,10181] | 0,09795 | compatible | 0,08850 |
| N | 0,10 | Origine (haut) | 2000 | 0 | 208 | 0,10400 [0,09096 ; 0,11821] | 0,09897 | compatible | 0,10400 |
| N | 0,10 | HomogF (haut) | 2000 | 0 | 183 | 0,09150 [0,07922 ; 0,10499] | 0,09896 | compatible | 0,09150 |
| N | 0,10 | Courbure (haut) | 2000 | 0 | 185 | 0,09250 [0,08016 ; 0,10605] | 0,09897 | compatible | 0,09250 |
| N | 0,10 | Alpha (haut) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09897 | compatible | 0,09850 |
| N | 0,10 | ExpVar (haut) | 2000 | 0 | 189 | 0,09450 [0,08203 ; 0,10817] | 0,09896 | compatible | 0,09450 |
| N | 0,10 | KruskalAcc (haut) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09889 | compatible | 0,09850 |
| N | 0,05 | Calendrier (bas) | 2000 | 0 | 63 | 0,03150 [0,02429 ; 0,04012] | 0,03434 | compatible | 0,03150 |
| N | 0,05 | CorrDev (deux) | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | 0,04753 | compatible | 0,04200 |
| N | 0,05 | BP (haut) | 2000 | 0 | 101 | 0,05050 [0,04132 ; 0,06103] | 0,04897 | compatible | 0,05050 |
| N | 0,05 | MinP4 (bas) | 2000 | 0 | 42 | 0,02100 [0,01518 ; 0,02828] | 0,04897 | écart non tranché | 0,02100 |
| N | 0,05 | DW (deux) | 2000 | 0 | 79 | 0,03950 [0,03139 ; 0,04899] | 0,04795 | compatible | 0,03950 |
| N | 0,05 | Runs (deux) | 2000 | 0 | 66 | 0,03300 [0,02561 ; 0,04179] | 0,03331 | compatible | 0,03300 |
| N | 0,05 | PenteIntra (deux) | 2000 | 0 | 97 | 0,04850 [0,03950 ; 0,05885] | 0,04795 | compatible | 0,04850 |
| N | 0,05 | Origine (haut) | 2000 | 0 | 99 | 0,04950 [0,04041 ; 0,05994] | 0,04897 | compatible | 0,04950 |
| N | 0,05 | HomogF (haut) | 2000 | 0 | 97 | 0,04850 [0,03950 ; 0,05885] | 0,04896 | compatible | 0,04850 |
| N | 0,05 | Courbure (haut) | 2000 | 0 | 95 | 0,04750 [0,03860 ; 0,05776] | 0,04897 | compatible | 0,04750 |
| N | 0,05 | Alpha (haut) | 2000 | 0 | 85 | 0,04250 [0,03409 ; 0,05229] | 0,04897 | compatible | 0,04250 |
| N | 0,05 | ExpVar (haut) | 2000 | 0 | 96 | 0,04800 [0,03905 ; 0,05830] | 0,04897 | compatible | 0,04800 |
| N | 0,05 | KruskalAcc (haut) | 2000 | 0 | 92 | 0,04600 [0,03724 ; 0,05612] | 0,04893 | compatible | 0,04600 |
| E | 0,10 | Calendrier (bas) | 2000 | 0 | 166 | 0,08300 [0,07128 ; 0,09596] | 0,08285 | compatible | 0,08300 |
| E | 0,10 | CorrDev (deux) | 2000 | 0 | 199 | 0,09950 [0,08673 ; 0,11346] | 0,09738 | compatible | 0,09950 |
| E | 0,10 | BP (haut) | 2000 | 0 | 180 | 0,09000 [0,07782 ; 0,10340] | 0,09897 | compatible | 0,09000 |
| E | 0,10 | MinP4 (bas) | 2000 | 0 | 137 | 0,06850 [0,05782 ; 0,08047] | 0,09897 | écart mineur | 0,06850 |
| E | 0,10 | DW (deux) | 2000 | 0 | 204 | 0,10200 [0,08908 ; 0,11610] | 0,09795 | compatible | 0,10200 |
| E | 0,10 | Runs (deux) | 2000 | 0 | 124 | 0,06200 [0,05183 ; 0,07348] | 0,05871 | compatible | 0,06200 |
| E | 0,10 | PenteIntra (deux) | 2000 | 0 | 206 | 0,10300 [0,09002 ; 0,11716] | 0,09795 | compatible | 0,10300 |
| E | 0,10 | Origine (haut) | 2000 | 0 | 218 | 0,10900 [0,09567 ; 0,12349] | 0,09897 | compatible | 0,10900 |
| E | 0,10 | HomogF (haut) | 2000 | 0 | 228 | 0,11400 [0,10040 ; 0,12875] | 0,09896 | écart mineur | 0,11400 |
| E | 0,10 | Courbure (haut) | 2000 | 0 | 173 | 0,08650 [0,07454 ; 0,09968] | 0,09897 | compatible | 0,08650 |
| E | 0,10 | Alpha (haut) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09897 | compatible | 0,09850 |
| E | 0,10 | ExpVar (haut) | 2000 | 0 | 178 | 0,08900 [0,07688 ; 0,10234] | 0,09896 | compatible | 0,08900 |
| E | 0,10 | KruskalAcc (haut) | 2000 | 0 | 218 | 0,10900 [0,09567 ; 0,12349] | 0,09890 | compatible | 0,10900 |
| E | 0,05 | Calendrier (bas) | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | 0,03274 | écart mineur | 0,04200 |
| E | 0,05 | CorrDev (deux) | 2000 | 0 | 86 | 0,04300 [0,03454 ; 0,05283] | 0,04752 | compatible | 0,04300 |
| E | 0,05 | BP (haut) | 2000 | 0 | 100 | 0,05000 [0,04086 ; 0,06048] | 0,04897 | compatible | 0,05000 |
| E | 0,05 | MinP4 (bas) | 2000 | 0 | 65 | 0,03250 [0,02517 ; 0,04124] | 0,04897 | écart mineur | 0,03250 |
| E | 0,05 | DW (deux) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04795 | compatible | 0,05250 |
| E | 0,05 | Runs (deux) | 2000 | 0 | 78 | 0,03900 [0,03095 ; 0,04844] | 0,03327 | compatible | 0,03900 |
| E | 0,05 | PenteIntra (deux) | 2000 | 0 | 102 | 0,05100 [0,04177 ; 0,06157] | 0,04795 | compatible | 0,05100 |
| E | 0,05 | Origine (haut) | 2000 | 0 | 121 | 0,06050 [0,05045 ; 0,07186] | 0,04897 | écart mineur | 0,06050 |
| E | 0,05 | HomogF (haut) | 2000 | 0 | 121 | 0,06050 [0,05045 ; 0,07186] | 0,04897 | écart mineur | 0,06050 |
| E | 0,05 | Courbure (haut) | 2000 | 0 | 87 | 0,04350 [0,03499 ; 0,05338] | 0,04897 | compatible | 0,04350 |
| E | 0,05 | Alpha (haut) | 2000 | 0 | 92 | 0,04600 [0,03724 ; 0,05612] | 0,04897 | compatible | 0,04600 |
| E | 0,05 | ExpVar (haut) | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | 0,04897 | compatible | 0,04200 |
| E | 0,05 | KruskalAcc (haut) | 2000 | 0 | 115 | 0,05750 [0,04770 ; 0,06862] | 0,04893 | compatible | 0,05750 |

### K1 (principal) — 8 x 6 : classe des 13 clés par (loi, α)

| Loi | α | Clé (sens) | n | p absentes | k | τ [IC CP 95 %] | ρ | classe | τ sur p définies |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,10 | Calendrier (bas) | 2000 | 0 | 172 | 0,08600 [0,07408 ; 0,09915] | 0,08921 | compatible | 0,08600 |
| N | 0,10 | CorrDev (deux) | 2000 | 0 | 180 | 0,09000 [0,07782 ; 0,10340] | 0,09752 | compatible | 0,09000 |
| N | 0,10 | BP (haut) | 2000 | 0 | 204 | 0,10200 [0,08908 ; 0,11610] | 0,09897 | compatible | 0,10200 |
| N | 0,10 | MinP4 (bas) | 2000 | 0 | 124 | 0,06200 [0,05183 ; 0,07348] | 0,09897 | écart mineur | 0,06200 |
| N | 0,10 | DW (deux) | 2000 | 0 | 183 | 0,09150 [0,07922 ; 0,10499] | 0,09795 | compatible | 0,09150 |
| N | 0,10 | Runs (deux) | 2000 | 0 | 126 | 0,06300 [0,05275 ; 0,07455] | 0,06778 | compatible | 0,06300 |
| N | 0,10 | PenteIntra (deux) | 2000 | 0 | 212 | 0,10600 [0,09284 ; 0,12032] | 0,09795 | compatible | 0,10600 |
| N | 0,10 | Origine (haut) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09897 | compatible | 0,09850 |
| N | 0,10 | HomogF (haut) | 2000 | 0 | 185 | 0,09250 [0,08016 ; 0,10605] | 0,09896 | compatible | 0,09250 |
| N | 0,10 | Courbure (haut) | 2000 | 0 | 184 | 0,09200 [0,07969 ; 0,10552] | 0,09897 | compatible | 0,09200 |
| N | 0,10 | Alpha (haut) | 2000 | 0 | 188 | 0,09400 [0,08156 ; 0,10764] | 0,09897 | compatible | 0,09400 |
| N | 0,10 | ExpVar (haut) | 2000 | 0 | 189 | 0,09450 [0,08203 ; 0,10817] | 0,09896 | compatible | 0,09450 |
| N | 0,10 | KruskalAcc (haut) | 2000 | 0 | 185 | 0,09250 [0,08016 ; 0,10605] | 0,09896 | compatible | 0,09250 |
| N | 0,05 | Calendrier (bas) | 2000 | 0 | 89 | 0,04450 [0,03589 ; 0,05448] | 0,04530 | compatible | 0,04450 |
| N | 0,05 | CorrDev (deux) | 2000 | 0 | 83 | 0,04150 [0,03319 ; 0,05119] | 0,04760 | compatible | 0,04150 |
| N | 0,05 | BP (haut) | 2000 | 0 | 109 | 0,05450 [0,04496 ; 0,06537] | 0,04897 | compatible | 0,05450 |
| N | 0,05 | MinP4 (bas) | 2000 | 0 | 44 | 0,02200 [0,01603 ; 0,02942] | 0,04897 | écart non tranché | 0,02200 |
| N | 0,05 | DW (deux) | 2000 | 0 | 77 | 0,03850 [0,03050 ; 0,04789] | 0,04795 | écart mineur | 0,03850 |
| N | 0,05 | Runs (deux) | 2000 | 0 | 48 | 0,02400 [0,01775 ; 0,03170] | 0,02467 | compatible | 0,02400 |
| N | 0,05 | PenteIntra (deux) | 2000 | 0 | 95 | 0,04750 [0,03860 ; 0,05776] | 0,04795 | compatible | 0,04750 |
| N | 0,05 | Origine (haut) | 2000 | 0 | 102 | 0,05100 [0,04177 ; 0,06157] | 0,04897 | compatible | 0,05100 |
| N | 0,05 | HomogF (haut) | 2000 | 0 | 100 | 0,05000 [0,04086 ; 0,06048] | 0,04896 | compatible | 0,05000 |
| N | 0,05 | Courbure (haut) | 2000 | 0 | 96 | 0,04800 [0,03905 ; 0,05830] | 0,04897 | compatible | 0,04800 |
| N | 0,05 | Alpha (haut) | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | 0,04897 | compatible | 0,04200 |
| N | 0,05 | ExpVar (haut) | 2000 | 0 | 99 | 0,04950 [0,04041 ; 0,05994] | 0,04897 | compatible | 0,04950 |
| N | 0,05 | KruskalAcc (haut) | 2000 | 0 | 88 | 0,04400 [0,03544 ; 0,05393] | 0,04897 | compatible | 0,04400 |
| E | 0,10 | Calendrier (bas) | 2000 | 0 | 188 | 0,09400 [0,08156 ; 0,10764] | 0,08907 | compatible | 0,09400 |
| E | 0,10 | CorrDev (deux) | 2000 | 0 | 206 | 0,10300 [0,09002 ; 0,11716] | 0,09747 | compatible | 0,10300 |
| E | 0,10 | BP (haut) | 2000 | 0 | 180 | 0,09000 [0,07782 ; 0,10340] | 0,09897 | compatible | 0,09000 |
| E | 0,10 | MinP4 (bas) | 2000 | 0 | 155 | 0,07750 [0,06616 ; 0,09010] | 0,09897 | écart mineur | 0,07750 |
| E | 0,10 | DW (deux) | 2000 | 0 | 202 | 0,10100 [0,08814 ; 0,11505] | 0,09795 | compatible | 0,10100 |
| E | 0,10 | Runs (deux) | 2000 | 0 | 151 | 0,07550 [0,06430 ; 0,08796] | 0,06747 | compatible | 0,07550 |
| E | 0,10 | PenteIntra (deux) | 2000 | 0 | 222 | 0,11100 [0,09756 ; 0,12559] | 0,09795 | compatible | 0,11100 |
| E | 0,10 | Origine (haut) | 2000 | 0 | 228 | 0,11400 [0,10040 ; 0,12875] | 0,09897 | écart mineur | 0,11400 |
| E | 0,10 | HomogF (haut) | 2000 | 0 | 223 | 0,11150 [0,09803 ; 0,12612] | 0,09896 | compatible | 0,11150 |
| E | 0,10 | Courbure (haut) | 2000 | 0 | 171 | 0,08550 [0,07361 ; 0,09862] | 0,09897 | écart mineur | 0,08550 |
| E | 0,10 | Alpha (haut) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09897 | compatible | 0,09850 |
| E | 0,10 | ExpVar (haut) | 2000 | 0 | 170 | 0,08500 [0,07314 ; 0,09809] | 0,09896 | écart mineur | 0,08500 |
| E | 0,10 | KruskalAcc (haut) | 2000 | 0 | 206 | 0,10300 [0,09002 ; 0,11716] | 0,09896 | compatible | 0,10300 |
| E | 0,05 | Calendrier (bas) | 2000 | 0 | 102 | 0,05100 [0,04177 ; 0,06157] | 0,04586 | compatible | 0,05100 |
| E | 0,05 | CorrDev (deux) | 2000 | 0 | 94 | 0,04700 [0,03815 ; 0,05721] | 0,04759 | compatible | 0,04700 |
| E | 0,05 | BP (haut) | 2000 | 0 | 79 | 0,03950 [0,03139 ; 0,04899] | 0,04897 | compatible | 0,03950 |
| E | 0,05 | MinP4 (bas) | 2000 | 0 | 67 | 0,03350 [0,02605 ; 0,04235] | 0,04897 | écart mineur | 0,03350 |
| E | 0,05 | DW (deux) | 2000 | 0 | 114 | 0,05700 [0,04724 ; 0,06808] | 0,04795 | compatible | 0,05700 |
| E | 0,05 | Runs (deux) | 2000 | 0 | 66 | 0,03300 [0,02561 ; 0,04179] | 0,02528 | écart mineur | 0,03300 |
| E | 0,05 | PenteIntra (deux) | 2000 | 0 | 107 | 0,05350 [0,04405 ; 0,06429] | 0,04795 | compatible | 0,05350 |
| E | 0,05 | Origine (haut) | 2000 | 0 | 107 | 0,05350 [0,04405 ; 0,06429] | 0,04897 | compatible | 0,05350 |
| E | 0,05 | HomogF (haut) | 2000 | 0 | 121 | 0,06050 [0,05045 ; 0,07186] | 0,04897 | écart mineur | 0,06050 |
| E | 0,05 | Courbure (haut) | 2000 | 0 | 88 | 0,04400 [0,03544 ; 0,05393] | 0,04897 | compatible | 0,04400 |
| E | 0,05 | Alpha (haut) | 2000 | 0 | 93 | 0,04650 [0,03769 ; 0,05667] | 0,04897 | compatible | 0,04650 |
| E | 0,05 | ExpVar (haut) | 2000 | 0 | 79 | 0,03950 [0,03139 ; 0,04899] | 0,04897 | compatible | 0,03950 |
| E | 0,05 | KruskalAcc (haut) | 2000 | 0 | 112 | 0,05600 [0,04633 ; 0,06700] | 0,04897 | compatible | 0,05600 |

### K-T6 (contrôle d'implémentation, sous (c)) — 8 x 7 : classes K1

| Loi | α | Clé (sens) | n | p absentes | k | τ [IC CP 95 %] | ρ | classe | τ sur p définies |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,10 | Calendrier (bas) | 1000 | 0 | 87 | 0,08700 [0,07027 ; 0,10621] | 0,09025 | compatible | 0,08700 |
| N | 0,10 | CorrDev (deux) | 1000 | 0 | 87 | 0,08700 [0,07027 ; 0,10621] | 0,09752 | compatible | 0,08700 |
| N | 0,10 | BP (haut) | 1000 | 0 | 101 | 0,10100 [0,08302 ; 0,12137] | 0,09897 | compatible | 0,10100 |
| N | 0,10 | MinP4 (bas) | 1000 | 0 | 65 | 0,06500 [0,05052 ; 0,08210] | 0,09897 | écart mineur | 0,06500 |
| N | 0,10 | DW (deux) | 1000 | 0 | 87 | 0,08700 [0,07027 ; 0,10621] | 0,09795 | compatible | 0,08700 |
| N | 0,10 | Runs (deux) | 1000 | 0 | 49 | 0,04900 [0,03647 ; 0,06427] | 0,05332 | compatible | 0,04900 |
| N | 0,10 | PenteIntra (deux) | 1000 | 0 | 120 | 0,12000 [0,10050 ; 0,14177] | 0,09795 | écart mineur | 0,12000 |
| N | 0,10 | Origine (haut) | 1000 | 0 | 92 | 0,09200 [0,07481 ; 0,11164] | 0,09897 | compatible | 0,09200 |
| N | 0,10 | HomogF (haut) | 1000 | 0 | 93 | 0,09300 [0,07572 ; 0,11272] | 0,09896 | compatible | 0,09300 |
| N | 0,10 | Courbure (haut) | 1000 | 0 | 91 | 0,09100 [0,07390 ; 0,11055] | 0,09897 | compatible | 0,09100 |
| N | 0,10 | Alpha (haut) | 1000 | 0 | 85 | 0,08500 [0,06846 ; 0,10403] | 0,09897 | compatible | 0,08500 |
| N | 0,10 | ExpVar (haut) | 1000 | 0 | 99 | 0,09900 [0,08119 ; 0,11921] | 0,09896 | compatible | 0,09900 |
| N | 0,10 | KruskalAcc (haut) | 1000 | 0 | 93 | 0,09300 [0,07572 ; 0,11272] | 0,09897 | compatible | 0,09300 |
| N | 0,05 | Calendrier (bas) | 1000 | 0 | 36 | 0,03600 [0,02534 ; 0,04949] | 0,04114 | compatible | 0,03600 |
| N | 0,05 | CorrDev (deux) | 1000 | 0 | 36 | 0,03600 [0,02534 ; 0,04949] | 0,04760 | compatible | 0,03600 |
| N | 0,05 | BP (haut) | 1000 | 0 | 54 | 0,05400 [0,04082 ; 0,06987] | 0,04897 | compatible | 0,05400 |
| N | 0,05 | MinP4 (bas) | 1000 | 0 | 22 | 0,02200 [0,01384 ; 0,03312] | 0,04897 | écart non tranché | 0,02200 |
| N | 0,05 | DW (deux) | 1000 | 0 | 35 | 0,03500 [0,02450 ; 0,04834] | 0,04795 | compatible | 0,03500 |
| N | 0,05 | Runs (deux) | 1000 | 0 | 21 | 0,02100 [0,01305 ; 0,03192] | 0,03156 | compatible | 0,02100 |
| N | 0,05 | PenteIntra (deux) | 1000 | 0 | 72 | 0,07200 [0,05676 ; 0,08982] | 0,04795 | écart non tranché | 0,07200 |
| N | 0,05 | Origine (haut) | 1000 | 0 | 44 | 0,04400 [0,03215 ; 0,05862] | 0,04897 | compatible | 0,04400 |
| N | 0,05 | HomogF (haut) | 1000 | 0 | 43 | 0,04300 [0,03129 ; 0,05749] | 0,04896 | compatible | 0,04300 |
| N | 0,05 | Courbure (haut) | 1000 | 0 | 41 | 0,04100 [0,02958 ; 0,05521] | 0,04897 | compatible | 0,04100 |
| N | 0,05 | Alpha (haut) | 1000 | 0 | 43 | 0,04300 [0,03129 ; 0,05749] | 0,04897 | compatible | 0,04300 |
| N | 0,05 | ExpVar (haut) | 1000 | 0 | 53 | 0,05300 [0,03995 ; 0,06876] | 0,04897 | compatible | 0,05300 |
| N | 0,05 | KruskalAcc (haut) | 1000 | 0 | 46 | 0,04600 [0,03387 ; 0,06088] | 0,04897 | compatible | 0,04600 |
| E | 0,10 | Calendrier (bas) | 1000 | 0 | 88 | 0,08800 [0,07118 ; 0,10729] | 0,09036 | compatible | 0,08800 |
| E | 0,10 | CorrDev (deux) | 1000 | 0 | 95 | 0,09500 [0,07754 ; 0,11488] | 0,09747 | compatible | 0,09500 |
| E | 0,10 | BP (haut) | 1000 | 0 | 90 | 0,09000 [0,07299 ; 0,10947] | 0,09897 | compatible | 0,09000 |
| E | 0,10 | MinP4 (bas) | 1000 | 0 | 83 | 0,08300 [0,06665 ; 0,10185] | 0,09897 | compatible | 0,08300 |
| E | 0,10 | DW (deux) | 1000 | 0 | 100 | 0,10000 [0,08211 ; 0,12029] | 0,09795 | compatible | 0,10000 |
| E | 0,10 | Runs (deux) | 1000 | 0 | 76 | 0,07600 [0,06034 ; 0,09420] | 0,05483 | écart mineur | 0,07600 |
| E | 0,10 | PenteIntra (deux) | 1000 | 0 | 128 | 0,12800 [0,10791 ; 0,15031] | 0,09795 | écart mineur | 0,12800 |
| E | 0,10 | Origine (haut) | 1000 | 0 | 101 | 0,10100 [0,08302 ; 0,12137] | 0,09897 | compatible | 0,10100 |
| E | 0,10 | HomogF (haut) | 1000 | 0 | 114 | 0,11400 [0,09496 ; 0,13534] | 0,09896 | compatible | 0,11400 |
| E | 0,10 | Courbure (haut) | 1000 | 0 | 77 | 0,07700 [0,06124 ; 0,09530] | 0,09897 | écart mineur | 0,07700 |
| E | 0,10 | Alpha (haut) | 1000 | 0 | 93 | 0,09300 [0,07572 ; 0,11272] | 0,09897 | compatible | 0,09300 |
| E | 0,10 | ExpVar (haut) | 1000 | 0 | 88 | 0,08800 [0,07118 ; 0,10729] | 0,09896 | compatible | 0,08800 |
| E | 0,10 | KruskalAcc (haut) | 1000 | 0 | 109 | 0,10900 [0,09036 ; 0,12998] | 0,09896 | compatible | 0,10900 |
| E | 0,05 | Calendrier (bas) | 1000 | 0 | 42 | 0,04200 [0,03043 ; 0,05635] | 0,04128 | compatible | 0,04200 |
| E | 0,05 | CorrDev (deux) | 1000 | 0 | 44 | 0,04400 [0,03215 ; 0,05862] | 0,04759 | compatible | 0,04400 |
| E | 0,05 | BP (haut) | 1000 | 0 | 44 | 0,04400 [0,03215 ; 0,05862] | 0,04897 | compatible | 0,04400 |
| E | 0,05 | MinP4 (bas) | 1000 | 0 | 37 | 0,03700 [0,02618 ; 0,05064] | 0,04897 | compatible | 0,03700 |
| E | 0,05 | DW (deux) | 1000 | 0 | 55 | 0,05500 [0,04170 ; 0,07099] | 0,04795 | compatible | 0,05500 |
| E | 0,05 | Runs (deux) | 1000 | 0 | 43 | 0,04300 [0,03129 ; 0,05749] | 0,02943 | écart mineur | 0,04300 |
| E | 0,05 | PenteIntra (deux) | 1000 | 0 | 75 | 0,07500 [0,05945 ; 0,09311] | 0,04795 | écart non tranché | 0,07500 |
| E | 0,05 | Origine (haut) | 1000 | 0 | 49 | 0,04900 [0,03647 ; 0,06427] | 0,04897 | compatible | 0,04900 |
| E | 0,05 | HomogF (haut) | 1000 | 0 | 56 | 0,05600 [0,04258 ; 0,07211] | 0,04897 | compatible | 0,05600 |
| E | 0,05 | Courbure (haut) | 1000 | 0 | 42 | 0,04200 [0,03043 ; 0,05635] | 0,04897 | compatible | 0,04200 |
| E | 0,05 | Alpha (haut) | 1000 | 0 | 40 | 0,04000 [0,02873 ; 0,05407] | 0,04897 | compatible | 0,04000 |
| E | 0,05 | ExpVar (haut) | 1000 | 0 | 39 | 0,03900 [0,02788 ; 0,05293] | 0,04897 | compatible | 0,03900 |
| E | 0,05 | KruskalAcc (haut) | 1000 | 0 | 49 | 0,04900 [0,03647 ; 0,06427] | 0,04897 | compatible | 0,04900 |

### K-T6 — 8 x 7 contre 8 x 8 (#297, même loi) : Fisher exact bilatéral, Holm sur 13 à 0,05 par (loi, α)

τ(8 x 8) : lignes rep admises du brut de #297, p_mc du pool redressé (pR:<clé>) < α, p absente comptée comme non-rejet. Classe du 8 x 8 contre ρ de l'oracle du 8 x 7 (descriptive : sous (c), les statistiques observées d'un 8 x 7 sont celles du 8 x 8 dont il est tronqué, critère (o), d'où la même loi oracle ; le contrôle (r297) atteste que le moteur reproduit les p de #297). Les échantillons sont indépendants (graines disjointes).

Dénominateurs : n (8 x 7) compte les triangles admis, échecs compris (N : 0 échec(s) sur n = 1000 ; E : 0 échec(s) sur n = 1000) ; n (8 x 8) compte les lignes rep admises du brut de #297, les lignes rep au statut non « admis » en sont exclues (N : 0 ligne(s) exclue(s), statuts aucun, n = 2000 ; E : 0 ligne(s) exclue(s), statuts aucun, n = 2000).

| Loi | α | Clé (sens) | k / n (8 x 7) | τ 8 x 7 [IC] | k / n (8 x 8, #297) | τ 8 x 8 [IC] | classe du 8 x 8 (ρ du 8 x 7) | p Fisher | p Holm | significatif (0,05) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,10 | Calendrier (bas) | 87 / 1000 | 0,08700 [0,07027 ; 0,10621] | 180 / 2000 | 0,09000 [0,07782 ; 0,10340] | compatible | 0,838 | 1 | non |
| N | 0,10 | CorrDev (deux) | 87 / 1000 | 0,08700 [0,07027 ; 0,10621] | 193 / 2000 | 0,09650 [0,08391 ; 0,11029] | compatible | 0,425 | 1 | non |
| N | 0,10 | BP (haut) | 101 / 1000 | 0,10100 [0,08302 ; 0,12137] | 178 / 2000 | 0,08900 [0,07688 ; 0,10234] | compatible | 0,287 | 1 | non |
| N | 0,10 | MinP4 (bas) | 65 / 1000 | 0,06500 [0,05052 ; 0,08210] | 142 / 2000 | 0,07100 [0,06013 ; 0,08315] | écart mineur | 0,593 | 1 | non |
| N | 0,10 | DW (deux) | 87 / 1000 | 0,08700 [0,07027 ; 0,10621] | 171 / 2000 | 0,08550 [0,07361 ; 0,09862] | compatible | 0,89 | 1 | non |
| N | 0,10 | Runs (deux) | 49 / 1000 | 0,04900 [0,03647 ; 0,06427] | 116 / 2000 | 0,05800 [0,04816 ; 0,06916] | compatible | 0,35 | 1 | non |
| N | 0,10 | PenteIntra (deux) | 120 / 1000 | 0,12000 [0,10050 ; 0,14177] | 223 / 2000 | 0,11150 [0,09803 ; 0,12612] | écart mineur | 0,503 | 1 | non |
| N | 0,10 | Origine (haut) | 92 / 1000 | 0,09200 [0,07481 ; 0,11164] | 176 / 2000 | 0,08800 [0,07595 ; 0,10128] | compatible | 0,734 | 1 | non |
| N | 0,10 | HomogF (haut) | 93 / 1000 | 0,09300 [0,07572 ; 0,11272] | 191 / 2000 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,843 | 1 | non |
| N | 0,10 | Courbure (haut) | 91 / 1000 | 0,09100 [0,07390 ; 0,11055] | 186 / 2000 | 0,09300 [0,08063 ; 0,10658] | compatible | 0,894 | 1 | non |
| N | 0,10 | Alpha (haut) | 85 / 1000 | 0,08500 [0,06846 ; 0,10403] | 191 / 2000 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,384 | 1 | non |
| N | 0,10 | ExpVar (haut) | 99 / 1000 | 0,09900 [0,08119 ; 0,11921] | 191 / 2000 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,793 | 1 | non |
| N | 0,10 | KruskalAcc (haut) | 93 / 1000 | 0,09300 [0,07572 ; 0,11272] | 192 / 2000 | 0,09600 [0,08344 ; 0,10976] | compatible | 0,843 | 1 | non |
| N | 0,05 | Calendrier (bas) | 36 / 1000 | 0,03600 [0,02534 ; 0,04949] | 89 / 2000 | 0,04450 [0,03589 ; 0,05448] | compatible | 0,288 | 1 | non |
| N | 0,05 | CorrDev (deux) | 36 / 1000 | 0,03600 [0,02534 ; 0,04949] | 103 / 2000 | 0,05150 [0,04223 ; 0,06211] | compatible | 0,065 | 0,845 | non |
| N | 0,05 | BP (haut) | 54 / 1000 | 0,05400 [0,04082 ; 0,06987] | 82 / 2000 | 0,04100 [0,03274 ; 0,05064] | compatible | 0,114 | 1 | non |
| N | 0,05 | MinP4 (bas) | 22 / 1000 | 0,02200 [0,01384 ; 0,03312] | 58 / 2000 | 0,02900 [0,02209 ; 0,03733] | écart mineur | 0,282 | 1 | non |
| N | 0,05 | DW (deux) | 35 / 1000 | 0,03500 [0,02450 ; 0,04834] | 91 / 2000 | 0,04550 [0,03679 ; 0,05557] | compatible | 0,209 | 1 | non |
| N | 0,05 | Runs (deux) | 21 / 1000 | 0,02100 [0,01305 ; 0,03192] | 55 / 2000 | 0,02750 [0,02078 ; 0,03565] | compatible | 0,325 | 1 | non |
| N | 0,05 | PenteIntra (deux) | 72 / 1000 | 0,07200 [0,05676 ; 0,08982] | 122 / 2000 | 0,06100 [0,05091 ; 0,07240] | écart mineur | 0,27 | 1 | non |
| N | 0,05 | Origine (haut) | 44 / 1000 | 0,04400 [0,03215 ; 0,05862] | 84 / 2000 | 0,04200 [0,03364 ; 0,05174] | compatible | 0,848 | 1 | non |
| N | 0,05 | HomogF (haut) | 43 / 1000 | 0,04300 [0,03129 ; 0,05749] | 78 / 2000 | 0,03900 [0,03095 ; 0,04844] | écart mineur | 0,623 | 1 | non |
| N | 0,05 | Courbure (haut) | 41 / 1000 | 0,04100 [0,02958 ; 0,05521] | 89 / 2000 | 0,04450 [0,03589 ; 0,05448] | compatible | 0,704 | 1 | non |
| N | 0,05 | Alpha (haut) | 43 / 1000 | 0,04300 [0,03129 ; 0,05749] | 77 / 2000 | 0,03850 [0,03050 ; 0,04789] | écart mineur | 0,554 | 1 | non |
| N | 0,05 | ExpVar (haut) | 53 / 1000 | 0,05300 [0,03995 ; 0,06876] | 92 / 2000 | 0,04600 [0,03724 ; 0,05612] | compatible | 0,417 | 1 | non |
| N | 0,05 | KruskalAcc (haut) | 46 / 1000 | 0,04600 [0,03387 ; 0,06088] | 101 / 2000 | 0,05050 [0,04132 ; 0,06103] | compatible | 0,654 | 1 | non |
| E | 0,10 | Calendrier (bas) | 88 / 1000 | 0,08800 [0,07118 ; 0,10729] | 186 / 2000 | 0,09300 [0,08063 ; 0,10658] | compatible | 0,687 | 1 | non |
| E | 0,10 | CorrDev (deux) | 95 / 1000 | 0,09500 [0,07754 ; 0,11488] | 199 / 2000 | 0,09950 [0,08673 ; 0,11346] | compatible | 0,745 | 1 | non |
| E | 0,10 | BP (haut) | 90 / 1000 | 0,09000 [0,07299 ; 0,10947] | 194 / 2000 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,552 | 1 | non |
| E | 0,10 | MinP4 (bas) | 83 / 1000 | 0,08300 [0,06665 ; 0,10185] | 157 / 2000 | 0,07850 [0,06709 ; 0,09117] | écart mineur | 0,669 | 1 | non |
| E | 0,10 | DW (deux) | 100 / 1000 | 0,10000 [0,08211 ; 0,12029] | 202 / 2000 | 0,10100 [0,08814 ; 0,11505] | compatible | 0,949 | 1 | non |
| E | 0,10 | Runs (deux) | 76 / 1000 | 0,07600 [0,06034 ; 0,09420] | 105 / 2000 | 0,05250 [0,04314 ; 0,06320] | compatible | 0,0117 | 0,153 | non |
| E | 0,10 | PenteIntra (deux) | 128 / 1000 | 0,12800 [0,10791 ; 0,15031] | 221 / 2000 | 0,11050 [0,09709 ; 0,12506] | compatible | 0,165 | 1 | non |
| E | 0,10 | Origine (haut) | 101 / 1000 | 0,10100 [0,08302 ; 0,12137] | 194 / 2000 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,745 | 1 | non |
| E | 0,10 | HomogF (haut) | 114 / 1000 | 0,11400 [0,09496 ; 0,13534] | 178 / 2000 | 0,08900 [0,07688 ; 0,10234] | compatible | 0,0311 | 0,374 | non |
| E | 0,10 | Courbure (haut) | 77 / 1000 | 0,07700 [0,06124 ; 0,09530] | 160 / 2000 | 0,08000 [0,06848 ; 0,09277] | écart mineur | 0,83 | 1 | non |
| E | 0,10 | Alpha (haut) | 93 / 1000 | 0,09300 [0,07572 ; 0,11272] | 194 / 2000 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,743 | 1 | non |
| E | 0,10 | ExpVar (haut) | 88 / 1000 | 0,08800 [0,07118 ; 0,10729] | 190 / 2000 | 0,09500 [0,08250 ; 0,10870] | compatible | 0,549 | 1 | non |
| E | 0,10 | KruskalAcc (haut) | 109 / 1000 | 0,10900 [0,09036 ; 0,12998] | 201 / 2000 | 0,10050 [0,08767 ; 0,11452] | compatible | 0,484 | 1 | non |
| E | 0,05 | Calendrier (bas) | 42 / 1000 | 0,04200 [0,03043 ; 0,05635] | 76 / 2000 | 0,03800 [0,03005 ; 0,04733] | compatible | 0,619 | 1 | non |
| E | 0,05 | CorrDev (deux) | 44 / 1000 | 0,04400 [0,03215 ; 0,05862] | 104 / 2000 | 0,05200 [0,04268 ; 0,06266] | compatible | 0,372 | 1 | non |
| E | 0,05 | BP (haut) | 44 / 1000 | 0,04400 [0,03215 ; 0,05862] | 106 / 2000 | 0,05300 [0,04359 ; 0,06374] | compatible | 0,328 | 1 | non |
| E | 0,05 | MinP4 (bas) | 37 / 1000 | 0,03700 [0,02618 ; 0,05064] | 79 / 2000 | 0,03950 [0,03139 ; 0,04899] | compatible | 0,764 | 1 | non |
| E | 0,05 | DW (deux) | 55 / 1000 | 0,05500 [0,04170 ; 0,07099] | 106 / 2000 | 0,05300 [0,04359 ; 0,06374] | compatible | 0,864 | 1 | non |
| E | 0,05 | Runs (deux) | 43 / 1000 | 0,04300 [0,03129 ; 0,05749] | 45 / 2000 | 0,02250 [0,01646 ; 0,02999] | compatible | 0,00263 | 0,0342 | **oui** |
| E | 0,05 | PenteIntra (deux) | 75 / 1000 | 0,07500 [0,05945 ; 0,09311] | 109 / 2000 | 0,05450 [0,04496 ; 0,06537] | compatible | 0,0294 | 0,353 | non |
| E | 0,05 | Origine (haut) | 49 / 1000 | 0,04900 [0,03647 ; 0,06427] | 95 / 2000 | 0,04750 [0,03860 ; 0,05776] | compatible | 0,857 | 1 | non |
| E | 0,05 | HomogF (haut) | 56 / 1000 | 0,05600 [0,04258 ; 0,07211] | 83 / 2000 | 0,04150 [0,03319 ; 0,05119] | compatible | 0,0802 | 0,882 | non |
| E | 0,05 | Courbure (haut) | 42 / 1000 | 0,04200 [0,03043 ; 0,05635] | 72 / 2000 | 0,03600 [0,02827 ; 0,04512] | écart mineur | 0,419 | 1 | non |
| E | 0,05 | Alpha (haut) | 40 / 1000 | 0,04000 [0,02873 ; 0,05407] | 84 / 2000 | 0,04200 [0,03364 ; 0,05174] | compatible | 0,846 | 1 | non |
| E | 0,05 | ExpVar (haut) | 39 / 1000 | 0,03900 [0,02788 ; 0,05293] | 99 / 2000 | 0,04950 [0,04041 ; 0,05994] | compatible | 0,229 | 1 | non |
| E | 0,05 | KruskalAcc (haut) | 49 / 1000 | 0,04900 [0,03647 ; 0,06427] | 98 / 2000 | 0,04900 [0,03996 ; 0,05939] | compatible | 1 | 1 | non |

Triangles 8 x 7 dont les statistiques observées sont identical() à celles du 8 x 8 simulé sous la même graine (descriptif ; (o) sur triangle tiré) : N 1000 / 1000 (8 x 8 non ajustable : 0) ; E 1000 / 1000 (8 x 8 non ajustable : 0).

### K3 — témoins oracle (règle bêta-binomiale du 05/11/2026, Holm sur 13 par (G, loi, α))

p_or = engine_p_mc(S0, s_obs, sens) contre l'oracle de (G, loi) ; test binomial exact bilatéral de τ_or contre la taille du témoin ; un signal est expliqué si la p de Holm bêta-binomiale sur la région de rejet réalisée de l'oracle est au moins 0,05 (« (i) », ou « (ii) » avec un atome à cheval), non expliqué sinon (seul ce cas met Θ0 en défaut). Limite déclarée (#206) : un seul échantillon oracle sert à tous les triangles mesurés.

| G | Loi | α | Clé (sens) | n | p_or absentes | k | τ_or [IC] | taille | p binomiale | p Holm | m_r / N | p Holm bêta-binomiale | atomes à cheval | K3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 0,10 | Calendrier (bas) | 2000 | 0 | 211 | 0,10550 [0,09237 ; 0,11980] | 0,08627 | 0,0028 | 0,0336 | 1982 / 20000 | 1 | 1 | (ii) |
| 8x5 | N | 0,10 | CorrDev (deux) | 2000 | 0 | 183 | 0,09150 [0,07922 ; 0,10499] | 0,09942 | 0,247 | 1 | 1997 / 20000 | 1 | 2 | — |
| 8x5 | N | 0,10 | BP (haut) | 2000 | 0 | 238 | 0,11900 [0,10513 ; 0,13400] | 0,09997 | 0,00577 | 0,0634 | 1999 / 20000 | 0,121 | 0 | — |
| 8x5 | N | 0,10 | MinP4 (bas) | 2000 | 0 | 210 | 0,10500 [0,09190 ; 0,11927] | 0,09997 | 0,456 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,10 | DW (deux) | 2000 | 0 | 189 | 0,09450 [0,08203 ; 0,10817] | 0,09995 | 0,434 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,10 | Runs (deux) | 2000 | 0 | 72 | 0,03600 [0,02827 ; 0,04512] | 0,05603 | 4,26e-05 | 0,000553 | 722 / 20000 | 1 | 2 | (ii) |
| 8x5 | N | 0,10 | PenteIntra (deux) | 2000 | 0 | 188 | 0,09400 [0,08156 ; 0,10764] | 0,09995 | 0,391 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,10 | Origine (haut) | 2000 | 0 | 217 | 0,10850 [0,09520 ; 0,12296] | 0,09997 | 0,205 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,10 | HomogF (haut) | 2000 | 0 | 195 | 0,09750 [0,08485 ; 0,11135] | 0,09995 | 0,737 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,10 | Courbure (haut) | 2000 | 0 | 199 | 0,09950 [0,08673 ; 0,11346] | 0,09997 | 0,97 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,10 | Alpha (haut) | 2000 | 0 | 201 | 0,10050 [0,08767 ; 0,11452] | 0,09997 | 0,941 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,10 | ExpVar (haut) | 2000 | 0 | 199 | 0,09950 [0,08673 ; 0,11346] | 0,09995 | 0,97 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,10 | KruskalAcc (haut) | 2000 | 0 | 194 | 0,09700 [0,08438 ; 0,11082] | 0,09988 | 0,709 | 1 | 1998 / 20000 | 1 | 1 | — |
| 8x5 | N | 0,05 | Calendrier (bas) | 2000 | 0 | 59 | 0,02950 [0,02253 ; 0,03789] | 0,03310 | 0,416 | 1 | 662 / 20000 | 1 | 1 | — |
| 8x5 | N | 0,05 | CorrDev (deux) | 2000 | 0 | 91 | 0,04550 [0,03679 ; 0,05557] | 0,04958 | 0,44 | 1 | 985 / 20000 | 1 | 2 | — |
| 8x5 | N | 0,05 | BP (haut) | 2000 | 0 | 121 | 0,06050 [0,05045 ; 0,07186] | 0,04997 | 0,0352 | 0,457 | 999 / 20000 | 0,654 | 0 | — |
| 8x5 | N | 0,05 | MinP4 (bas) | 2000 | 0 | 99 | 0,04950 [0,04041 ; 0,05994] | 0,04997 | 1 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,05 | DW (deux) | 2000 | 0 | 87 | 0,04350 [0,03499 ; 0,05338] | 0,04995 | 0,199 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,05 | Runs (deux) | 2000 | 0 | 72 | 0,03600 [0,02827 ; 0,04512] | 0,03610 | 1 | 1 | 722 / 20000 | 1 | 2 | — |
| 8x5 | N | 0,05 | PenteIntra (deux) | 2000 | 0 | 99 | 0,04950 [0,04041 ; 0,05994] | 0,04995 | 1 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,05 | Origine (haut) | 2000 | 0 | 107 | 0,05350 [0,04405 ; 0,06429] | 0,04997 | 0,472 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,05 | HomogF (haut) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04996 | 0,608 | 1 | 998 / 20000 | 1 | 1 | — |
| 8x5 | N | 0,05 | Courbure (haut) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04997 | 0,608 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,05 | Alpha (haut) | 2000 | 0 | 107 | 0,05350 [0,04405 ; 0,06429] | 0,04997 | 0,472 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | N | 0,05 | ExpVar (haut) | 2000 | 0 | 99 | 0,04950 [0,04041 ; 0,05994] | 0,04996 | 1 | 1 | 999 / 20000 | 1 | 1 | — |
| 8x5 | N | 0,05 | KruskalAcc (haut) | 2000 | 0 | 91 | 0,04550 [0,03679 ; 0,05557] | 0,04993 | 0,383 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,10 | Calendrier (bas) | 2000 | 0 | 213 | 0,10650 [0,09331 ; 0,12085] | 0,09299 | 0,0412 | 0,494 | 1952 / 20000 | 1 | 1 | — |
| 8x5 | E | 0,10 | CorrDev (deux) | 2000 | 0 | 204 | 0,10200 [0,08908 ; 0,11610] | 0,09951 | 0,709 | 1 | 1997 / 20000 | 1 | 2 | — |
| 8x5 | E | 0,10 | BP (haut) | 2000 | 0 | 180 | 0,09000 [0,07782 ; 0,10340] | 0,09997 | 0,146 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,10 | MinP4 (bas) | 2000 | 0 | 209 | 0,10450 [0,09143 ; 0,11874] | 0,09997 | 0,502 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,10 | DW (deux) | 2000 | 0 | 207 | 0,10350 [0,09049 ; 0,11769] | 0,09995 | 0,602 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,10 | Runs (deux) | 2000 | 0 | 85 | 0,04250 [0,03409 ; 0,05229] | 0,05078 | 0,0929 | 0,836 | 717 / 20000 | 1 | 2 | — |
| 8x5 | E | 0,10 | PenteIntra (deux) | 2000 | 0 | 207 | 0,10350 [0,09049 ; 0,11769] | 0,09995 | 0,602 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,10 | Origine (haut) | 2000 | 0 | 225 | 0,11250 [0,09898 ; 0,12717] | 0,09997 | 0,0676 | 0,676 | 1999 / 20000 | 0,939 | 0 | — |
| 8x5 | E | 0,10 | HomogF (haut) | 2000 | 0 | 233 | 0,11650 [0,10276 ; 0,13138] | 0,09995 | 0,0153 | 0,199 | 1997 / 20000 | 0,295 | 1 | — |
| 8x5 | E | 0,10 | Courbure (haut) | 2000 | 0 | 180 | 0,09000 [0,07782 ; 0,10340] | 0,09997 | 0,146 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,10 | Alpha (haut) | 2000 | 0 | 201 | 0,10050 [0,08767 ; 0,11452] | 0,09997 | 0,941 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,10 | ExpVar (haut) | 2000 | 0 | 192 | 0,09600 [0,08344 ; 0,10976] | 0,09996 | 0,576 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,10 | KruskalAcc (haut) | 2000 | 0 | 226 | 0,11300 [0,09945 ; 0,12770] | 0,09989 | 0,0525 | 0,577 | 1996 / 20000 | 0,843 | 1 | — |
| 8x5 | E | 0,05 | Calendrier (bas) | 2000 | 0 | 75 | 0,03750 [0,02961 ; 0,04678] | 0,03090 | 0,0926 | 1 | 618 / 20000 | 1 | 1 | — |
| 8x5 | E | 0,05 | CorrDev (deux) | 2000 | 0 | 92 | 0,04600 [0,03724 ; 0,05612] | 0,04956 | 0,503 | 1 | 994 / 20000 | 1 | 2 | — |
| 8x5 | E | 0,05 | BP (haut) | 2000 | 0 | 97 | 0,04850 [0,03950 ; 0,05885] | 0,04997 | 0,798 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,05 | MinP4 (bas) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04997 | 0,608 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,05 | DW (deux) | 2000 | 0 | 102 | 0,05100 [0,04177 ; 0,06157] | 0,04995 | 0,798 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,05 | Runs (deux) | 2000 | 0 | 85 | 0,04250 [0,03409 ; 0,05229] | 0,03585 | 0,117 | 1 | 717 / 20000 | 1 | 2 | — |
| 8x5 | E | 0,05 | PenteIntra (deux) | 2000 | 0 | 104 | 0,05200 [0,04268 ; 0,06266] | 0,04995 | 0,644 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,05 | Origine (haut) | 2000 | 0 | 114 | 0,05700 [0,04724 ; 0,06808] | 0,04997 | 0,151 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,05 | HomogF (haut) | 2000 | 0 | 132 | 0,06600 [0,05551 ; 0,07778] | 0,04996 | 0,0017 | 0,0222 | 999 / 20000 | 0,0412 | 0 | non expliqué |
| 8x5 | E | 0,05 | Courbure (haut) | 2000 | 0 | 94 | 0,04700 [0,03815 ; 0,05721] | 0,04997 | 0,573 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,05 | Alpha (haut) | 2000 | 0 | 107 | 0,05350 [0,04405 ; 0,06429] | 0,04997 | 0,472 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x5 | E | 0,05 | ExpVar (haut) | 2000 | 0 | 86 | 0,04300 [0,03454 ; 0,05283] | 0,04996 | 0,166 | 1 | 998 / 20000 | 1 | 1 | — |
| 8x5 | E | 0,05 | KruskalAcc (haut) | 2000 | 0 | 114 | 0,05700 [0,04724 ; 0,06808] | 0,04993 | 0,15 | 1 | 999 / 20000 | 1 | 1 | — |
| 8x6 | N | 0,10 | Calendrier (bas) | 2000 | 0 | 175 | 0,08750 [0,07548 ; 0,10075] | 0,09265 | 0,464 | 1 | 1853 / 20000 | 1 | 1 | — |
| 8x6 | N | 0,10 | CorrDev (deux) | 2000 | 0 | 183 | 0,09150 [0,07922 ; 0,10499] | 0,09950 | 0,247 | 1 | 1986 / 20000 | 1 | 2 | — |
| 8x6 | N | 0,10 | BP (haut) | 2000 | 0 | 232 | 0,11600 [0,10229 ; 0,13085] | 0,09997 | 0,0188 | 0,244 | 1999 / 20000 | 0,364 | 0 | — |
| 8x6 | N | 0,10 | MinP4 (bas) | 2000 | 0 | 210 | 0,10500 [0,09190 ; 0,11927] | 0,09997 | 0,456 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,10 | DW (deux) | 2000 | 0 | 192 | 0,09600 [0,08344 ; 0,10976] | 0,09995 | 0,576 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,10 | Runs (deux) | 2000 | 0 | 139 | 0,06950 [0,05874 ; 0,08154] | 0,07005 | 0,965 | 1 | 1401 / 20000 | 1 | 2 | — |
| 8x6 | N | 0,10 | PenteIntra (deux) | 2000 | 0 | 199 | 0,09950 [0,08673 ; 0,11346] | 0,09995 | 1 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,10 | Origine (haut) | 2000 | 0 | 216 | 0,10800 [0,09473 ; 0,12243] | 0,09997 | 0,233 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,10 | HomogF (haut) | 2000 | 0 | 195 | 0,09750 [0,08485 ; 0,11135] | 0,09995 | 0,737 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,10 | Courbure (haut) | 2000 | 0 | 199 | 0,09950 [0,08673 ; 0,11346] | 0,09997 | 0,97 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,10 | Alpha (haut) | 2000 | 0 | 200 | 0,10000 [0,08720 ; 0,11399] | 0,09997 | 1 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,10 | ExpVar (haut) | 2000 | 0 | 199 | 0,09950 [0,08673 ; 0,11346] | 0,09995 | 0,97 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,10 | KruskalAcc (haut) | 2000 | 0 | 192 | 0,09600 [0,08344 ; 0,10976] | 0,09996 | 0,576 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,05 | Calendrier (bas) | 2000 | 0 | 90 | 0,04500 [0,03634 ; 0,05503] | 0,04793 | 0,6 | 1 | 928 / 20000 | 1 | 1 | — |
| 8x6 | N | 0,05 | CorrDev (deux) | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | 0,04960 | 0,122 | 1 | 982 / 20000 | 1 | 2 | — |
| 8x6 | N | 0,05 | BP (haut) | 2000 | 0 | 124 | 0,06200 [0,05183 ; 0,07348] | 0,04997 | 0,0158 | 0,205 | 999 / 20000 | 0,333 | 0 | — |
| 8x6 | N | 0,05 | MinP4 (bas) | 2000 | 0 | 99 | 0,04950 [0,04041 ; 0,05994] | 0,04997 | 1 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,05 | DW (deux) | 2000 | 0 | 86 | 0,04300 [0,03454 ; 0,05283] | 0,04995 | 0,166 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,05 | Runs (deux) | 2000 | 0 | 42 | 0,02100 [0,01518 ; 0,02828] | 0,02255 | 0,706 | 1 | 451 / 20000 | 1 | 2 | — |
| 8x6 | N | 0,05 | PenteIntra (deux) | 2000 | 0 | 102 | 0,05100 [0,04177 ; 0,06157] | 0,04995 | 0,798 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,05 | Origine (haut) | 2000 | 0 | 109 | 0,05450 [0,04496 ; 0,06537] | 0,04997 | 0,355 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,05 | HomogF (haut) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04996 | 0,608 | 1 | 998 / 20000 | 1 | 1 | — |
| 8x6 | N | 0,05 | Courbure (haut) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04997 | 0,608 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,05 | Alpha (haut) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04997 | 0,608 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | N | 0,05 | ExpVar (haut) | 2000 | 0 | 99 | 0,04950 [0,04041 ; 0,05994] | 0,04996 | 1 | 1 | 999 / 20000 | 1 | 1 | — |
| 8x6 | N | 0,05 | KruskalAcc (haut) | 2000 | 0 | 95 | 0,04750 [0,03860 ; 0,05776] | 0,04997 | 0,644 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,10 | Calendrier (bas) | 2000 | 0 | 189 | 0,09450 [0,08203 ; 0,10817] | 0,09170 | 0,67 | 1 | 1834 / 20000 | 1 | 1 | — |
| 8x6 | E | 0,10 | CorrDev (deux) | 2000 | 0 | 203 | 0,10150 [0,08861 ; 0,11557] | 0,09951 | 0,765 | 1 | 1993 / 20000 | 1 | 2 | — |
| 8x6 | E | 0,10 | BP (haut) | 2000 | 0 | 175 | 0,08750 [0,07548 ; 0,10075] | 0,09997 | 0,0624 | 0,668 | 1999 / 20000 | 0,853 | 0 | — |
| 8x6 | E | 0,10 | MinP4 (bas) | 2000 | 0 | 209 | 0,10450 [0,09143 ; 0,11874] | 0,09997 | 0,502 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,10 | DW (deux) | 2000 | 0 | 208 | 0,10400 [0,09096 ; 0,11821] | 0,09995 | 0,551 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,10 | Runs (deux) | 2000 | 0 | 163 | 0,08150 [0,06988 ; 0,09436] | 0,07070 | 0,0607 | 0,668 | 1414 / 20000 | 0,87 | 2 | — |
| 8x6 | E | 0,10 | PenteIntra (deux) | 2000 | 0 | 212 | 0,10600 [0,09284 ; 0,12032] | 0,09995 | 0,371 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,10 | Origine (haut) | 2000 | 0 | 230 | 0,11500 [0,10134 ; 0,12980] | 0,09997 | 0,0278 | 0,333 | 1999 / 20000 | 0,471 | 0 | — |
| 8x6 | E | 0,10 | HomogF (haut) | 2000 | 0 | 233 | 0,11650 [0,10276 ; 0,13138] | 0,09995 | 0,0153 | 0,199 | 1997 / 20000 | 0,295 | 1 | — |
| 8x6 | E | 0,10 | Courbure (haut) | 2000 | 0 | 180 | 0,09000 [0,07782 ; 0,10340] | 0,09997 | 0,146 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,10 | Alpha (haut) | 2000 | 0 | 188 | 0,09400 [0,08156 ; 0,10764] | 0,09997 | 0,391 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,10 | ExpVar (haut) | 2000 | 0 | 192 | 0,09600 [0,08344 ; 0,10976] | 0,09996 | 0,576 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,10 | KruskalAcc (haut) | 2000 | 0 | 205 | 0,10250 [0,08955 ; 0,11663] | 0,09995 | 0,709 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,05 | Calendrier (bas) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04792 | 0,346 | 1 | 957 / 20000 | 1 | 1 | — |
| 8x6 | E | 0,05 | CorrDev (deux) | 2000 | 0 | 92 | 0,04600 [0,03724 ; 0,05612] | 0,04956 | 0,503 | 1 | 990 / 20000 | 1 | 2 | — |
| 8x6 | E | 0,05 | BP (haut) | 2000 | 0 | 85 | 0,04250 [0,03409 ; 0,05229] | 0,04997 | 0,136 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,05 | MinP4 (bas) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04997 | 0,608 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,05 | DW (deux) | 2000 | 0 | 118 | 0,05900 [0,04908 ; 0,07024] | 0,04995 | 0,0646 | 0,711 | 998 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,05 | Runs (deux) | 2000 | 0 | 59 | 0,02950 [0,02253 ; 0,03789] | 0,02290 | 0,0518 | 0,621 | 458 / 20000 | 1 | 2 | — |
| 8x6 | E | 0,05 | PenteIntra (deux) | 2000 | 0 | 101 | 0,05050 [0,04132 ; 0,06103] | 0,04995 | 0,878 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,05 | Origine (haut) | 2000 | 0 | 102 | 0,05100 [0,04177 ; 0,06157] | 0,04997 | 0,837 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,05 | HomogF (haut) | 2000 | 0 | 132 | 0,06600 [0,05551 ; 0,07778] | 0,04996 | 0,0017 | 0,0222 | 999 / 20000 | 0,0412 | 0 | non expliqué |
| 8x6 | E | 0,05 | Courbure (haut) | 2000 | 0 | 94 | 0,04700 [0,03815 ; 0,05721] | 0,04997 | 0,573 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,05 | Alpha (haut) | 2000 | 0 | 107 | 0,05350 [0,04405 ; 0,06429] | 0,04997 | 0,472 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x6 | E | 0,05 | ExpVar (haut) | 2000 | 0 | 86 | 0,04300 [0,03454 ; 0,05283] | 0,04996 | 0,166 | 1 | 998 / 20000 | 1 | 1 | — |
| 8x6 | E | 0,05 | KruskalAcc (haut) | 2000 | 0 | 114 | 0,05700 [0,04724 ; 0,06808] | 0,04996 | 0,151 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | Calendrier (bas) | 1000 | 0 | 89 | 0,08900 [0,07208 ; 0,10838] | 0,09472 | 0,589 | 1 | 1959 / 20000 | 1 | 1 | — |
| 8x7 | N | 0,10 | CorrDev (deux) | 1000 | 0 | 90 | 0,09000 [0,07299 ; 0,10947] | 0,09950 | 0,342 | 1 | 1986 / 20000 | 1 | 2 | — |
| 8x7 | N | 0,10 | BP (haut) | 1000 | 0 | 116 | 0,11600 [0,09681 ; 0,13749] | 0,09997 | 0,0917 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | MinP4 (bas) | 1000 | 0 | 108 | 0,10800 [0,08944 ; 0,12890] | 0,09997 | 0,399 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | DW (deux) | 1000 | 0 | 99 | 0,09900 [0,08119 ; 0,11921] | 0,09995 | 0,958 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | Runs (deux) | 1000 | 0 | 38 | 0,03800 [0,02703 ; 0,05179] | 0,04546 | 0,288 | 1 | 902 / 20000 | 1 | 2 | — |
| 8x7 | N | 0,10 | PenteIntra (deux) | 1000 | 0 | 95 | 0,09500 [0,07754 ; 0,11488] | 0,09995 | 0,635 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | Origine (haut) | 1000 | 0 | 105 | 0,10500 [0,08668 ; 0,12568] | 0,09997 | 0,598 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | HomogF (haut) | 1000 | 0 | 93 | 0,09300 [0,07572 ; 0,11272] | 0,09995 | 0,493 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | Courbure (haut) | 1000 | 0 | 102 | 0,10200 [0,08394 ; 0,12245] | 0,09997 | 0,833 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | Alpha (haut) | 1000 | 0 | 94 | 0,09400 [0,07663 ; 0,11380] | 0,09997 | 0,562 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | ExpVar (haut) | 1000 | 0 | 99 | 0,09900 [0,08119 ; 0,11921] | 0,09995 | 0,958 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,10 | KruskalAcc (haut) | 1000 | 0 | 93 | 0,09300 [0,07572 ; 0,11272] | 0,09996 | 0,493 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,05 | Calendrier (bas) | 1000 | 0 | 36 | 0,03600 [0,02534 ; 0,04949] | 0,04185 | 0,386 | 1 | 837 / 20000 | 1 | 1 | — |
| 8x7 | N | 0,05 | CorrDev (deux) | 1000 | 0 | 38 | 0,03800 [0,02703 ; 0,05179] | 0,04960 | 0,0938 | 1 | 982 / 20000 | 1 | 2 | — |
| 8x7 | N | 0,05 | BP (haut) | 1000 | 0 | 65 | 0,06500 [0,05052 ; 0,08210] | 0,04997 | 0,0349 | 0,454 | 999 / 20000 | 0,609 | 0 | — |
| 8x7 | N | 0,05 | MinP4 (bas) | 1000 | 0 | 45 | 0,04500 [0,03301 ; 0,05975] | 0,04997 | 0,514 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,05 | DW (deux) | 1000 | 0 | 41 | 0,04100 [0,02958 ; 0,05521] | 0,04995 | 0,217 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,05 | Runs (deux) | 1000 | 0 | 38 | 0,03800 [0,02703 ; 0,05179] | 0,03780 | 0,934 | 1 | 902 / 20000 | 1 | 2 | — |
| 8x7 | N | 0,05 | PenteIntra (deux) | 1000 | 0 | 49 | 0,04900 [0,03647 ; 0,06427] | 0,04995 | 1 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,05 | Origine (haut) | 1000 | 0 | 51 | 0,05100 [0,03821 ; 0,06651] | 0,04997 | 0,884 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,05 | HomogF (haut) | 1000 | 0 | 49 | 0,04900 [0,03647 ; 0,06427] | 0,04996 | 0,942 | 1 | 998 / 20000 | 1 | 1 | — |
| 8x7 | N | 0,05 | Courbure (haut) | 1000 | 0 | 50 | 0,05000 [0,03734 ; 0,06539] | 0,04997 | 1 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,05 | Alpha (haut) | 1000 | 0 | 52 | 0,05200 [0,03908 ; 0,06764] | 0,04997 | 0,771 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | N | 0,05 | ExpVar (haut) | 1000 | 0 | 49 | 0,04900 [0,03647 ; 0,06427] | 0,04996 | 0,942 | 1 | 999 / 20000 | 1 | 1 | — |
| 8x7 | N | 0,05 | KruskalAcc (haut) | 1000 | 0 | 40 | 0,04000 [0,02873 ; 0,05407] | 0,04997 | 0,167 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,10 | Calendrier (bas) | 1000 | 0 | 96 | 0,09600 [0,07845 ; 0,11597] | 0,09502 | 0,914 | 1 | 1905 / 20000 | 1 | 1 | — |
| 8x7 | E | 0,10 | CorrDev (deux) | 1000 | 0 | 97 | 0,09700 [0,07936 ; 0,11705] | 0,09951 | 0,833 | 1 | 1993 / 20000 | 1 | 2 | — |
| 8x7 | E | 0,10 | BP (haut) | 1000 | 0 | 88 | 0,08800 [0,07118 ; 0,10729] | 0,09997 | 0,225 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,10 | MinP4 (bas) | 1000 | 0 | 116 | 0,11600 [0,09681 ; 0,13749] | 0,09997 | 0,0917 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,10 | DW (deux) | 1000 | 0 | 98 | 0,09800 [0,08028 ; 0,11813] | 0,09995 | 0,874 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,10 | Runs (deux) | 1000 | 0 | 58 | 0,05800 [0,04433 ; 0,07434] | 0,04739 | 0,118 | 1 | 945 / 20000 | 1 | 2 | — |
| 8x7 | E | 0,10 | PenteIntra (deux) | 1000 | 0 | 99 | 0,09900 [0,08119 ; 0,11921] | 0,09995 | 0,958 | 1 | 1998 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,10 | Origine (haut) | 1000 | 0 | 104 | 0,10400 [0,08577 ; 0,12460] | 0,09997 | 0,673 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,10 | HomogF (haut) | 1000 | 0 | 116 | 0,11600 [0,09681 ; 0,13749] | 0,09995 | 0,0916 | 1 | 1997 / 20000 | 1 | 1 | — |
| 8x7 | E | 0,10 | Courbure (haut) | 1000 | 0 | 82 | 0,08200 [0,06575 ; 0,10076] | 0,09997 | 0,0577 | 0,751 | 1999 / 20000 | 0,861 | 0 | — |
| 8x7 | E | 0,10 | Alpha (haut) | 1000 | 0 | 86 | 0,08600 [0,06936 ; 0,10512] | 0,09997 | 0,154 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,10 | ExpVar (haut) | 1000 | 0 | 94 | 0,09400 [0,07663 ; 0,11380] | 0,09996 | 0,562 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,10 | KruskalAcc (haut) | 1000 | 0 | 109 | 0,10900 [0,09036 ; 0,12998] | 0,09996 | 0,342 | 1 | 1999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,05 | Calendrier (bas) | 1000 | 0 | 41 | 0,04100 [0,02958 ; 0,05521] | 0,04155 | 1 | 1 | 831 / 20000 | 1 | 1 | — |
| 8x7 | E | 0,05 | CorrDev (deux) | 1000 | 0 | 38 | 0,03800 [0,02703 ; 0,05179] | 0,04956 | 0,0938 | 0,938 | 990 / 20000 | 1 | 2 | — |
| 8x7 | E | 0,05 | BP (haut) | 1000 | 0 | 47 | 0,04700 [0,03474 ; 0,06201] | 0,04997 | 0,717 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,05 | MinP4 (bas) | 1000 | 0 | 63 | 0,06300 [0,04875 ; 0,07989] | 0,04997 | 0,069 | 0,759 | 999 / 20000 | 0,927 | 0 | — |
| 8x7 | E | 0,05 | DW (deux) | 1000 | 0 | 57 | 0,05700 [0,04345 ; 0,07322] | 0,04995 | 0,309 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,05 | Runs (deux) | 1000 | 0 | 45 | 0,04500 [0,03301 ; 0,05975] | 0,02815 | 0,00283 | 0,0368 | 555 / 20000 | 0,0491 | 2 | non expliqué |
| 8x7 | E | 0,05 | PenteIntra (deux) | 1000 | 0 | 49 | 0,04900 [0,03647 ; 0,06427] | 0,04995 | 1 | 1 | 998 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,05 | Origine (haut) | 1000 | 0 | 47 | 0,04700 [0,03474 ; 0,06201] | 0,04997 | 0,717 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,05 | HomogF (haut) | 1000 | 0 | 67 | 0,06700 [0,05230 ; 0,08431] | 0,04996 | 0,0164 | 0,197 | 999 / 20000 | 0,296 | 0 | — |
| 8x7 | E | 0,05 | Courbure (haut) | 1000 | 0 | 44 | 0,04400 [0,03215 ; 0,05862] | 0,04997 | 0,425 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,05 | Alpha (haut) | 1000 | 0 | 44 | 0,04400 [0,03215 ; 0,05862] | 0,04997 | 0,425 | 1 | 999 / 20000 | 1 | 0 | — |
| 8x7 | E | 0,05 | ExpVar (haut) | 1000 | 0 | 42 | 0,04200 [0,03043 ; 0,05635] | 0,04996 | 0,276 | 1 | 998 / 20000 | 1 | 1 | — |
| 8x7 | E | 0,05 | KruskalAcc (haut) | 1000 | 0 | 49 | 0,04900 [0,03647 ; 0,06427] | 0,04997 | 0,942 | 1 | 999 / 20000 | 1 | 0 | — |

### K4 — p absentes (au plus 1 % par (G, loi)) et refus (au plus 1 %)

| G | Loi | tirés | admis | échecs (bootstrap ou tests) | refus | motifs de refus | part des refus | admis à au moins une p_mc absente | part | K4 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 2000 | 2000 | 0 | 0 | aucun | 0,0000 | 0 | 0,0000 | rempli |
| 8x5 | E | 2000 | 2000 | 0 | 0 | aucun | 0,0000 | 0 | 0,0000 | rempli |
| 8x6 | N | 2000 | 2000 | 0 | 0 | aucun | 0,0000 | 0 | 0,0000 | rempli |
| 8x6 | E | 2000 | 2000 | 0 | 0 | aucun | 0,0000 | 0 | 0,0000 | rempli |
| 8x7 | N | 1000 | 1000 | 0 | 0 | aucun | 0,0000 | 0 | 0,0000 | rempli |
| 8x7 | E | 1000 | 1000 | 0 | 0 | aucun | 0,0000 | 0 | 0,0000 | rempli |

### K5 (descriptif) — B effectif, motifs, lignes inopérantes, statistiques NA

| G | Loi | n admis | B effectif minimal (sur les 13 clés) : min ; q25 ; médiane | part à B effectif < B | retirage (cumuls) ; plafond | n_sans_sigma > 0 |
| --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 2000 | 999 ; 999 ; 999 | 0,0000 | 0 ; 0 | 0 |
| 8x5 | E | 2000 | 999 ; 999 ; 999 | 0,0000 | 0 ; 0 | 0 |
| 8x6 | N | 2000 | 999 ; 999 ; 999 | 0,0000 | 0 ; 0 | 0 |
| 8x6 | E | 2000 | 999 ; 999 ; 999 | 0,0000 | 0 ; 0 | 0 |
| 8x7 | N | 1000 | 999 ; 999 ; 999 | 0,0000 | 0 ; 0 | 0 |
| 8x7 | E | 1000 | 999 ; 999 ; 999 | 0,0000 | 0 ; 0 | 0 |

| G | Clé (sens) | ligne inopérante N ; E (part) | statistique observée NA N ; E (part) | p_mc absente N ; E | motifs des p absentes (N | E) |
| --- | --- | --- | --- | --- | --- |
| 8x5 | Calendrier (bas) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | CorrDev (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | BP (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | MinP4 (bas) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | DW (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | Runs (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | PenteIntra (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | Origine (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | HomogF (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | Courbure (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | Alpha (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | ExpVar (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x5 | KruskalAcc (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | Calendrier (bas) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | CorrDev (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | BP (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | MinP4 (bas) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | DW (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | Runs (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | PenteIntra (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | Origine (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | HomogF (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | Courbure (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | Alpha (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | ExpVar (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x6 | KruskalAcc (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | Calendrier (bas) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | CorrDev (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | BP (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | MinP4 (bas) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | DW (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | Runs (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | PenteIntra (deux) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | Origine (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | HomogF (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | Courbure (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | Alpha (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | ExpVar (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |
| 8x7 | KruskalAcc (haut) | 0,0000 ; 0,0000 | 0,0000 ; 0,0000 | 0 ; 0 | aucun | aucun |

### K-T4 (descriptif, sans critère) — σ̂²_(J−1) de la règle et estimateur direct, rapport des √MSEP, taux de M4

Quantiles 5 %, 25 %, 50 %, 75 %, 95 % (type 7) sur les triangles admis ; σ²_(J−1) vrai du DGP au T0. √MSEP directe : MSEP où σ²_(J−1) et Q_(J−1) sont remplacés par l'estimateur direct (mécanique de mw_sensibilite_sigma2_dernier()), calculée dans ce script seulement, pour information (Q-2a-4).

| G | Loi | n admis | σ̂² règle / σ² vrai | moyenne | σ̂² direct / σ² vrai | moyenne | √MSEP règle / √MSEP directe | refus M4 / tirés |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 2000 | 0,0594 ; 0,4512 ; 0,9891 ; 1,7193 ; 2,9348 | 1,1782 | 0,1153 ; 0,4149 ; 0,7886 ; 1,3756 ; 2,7174 | 1,0114 | 0,7688 ; 0,9245 ; 1,0232 ; 1,1052 ; 1,2083 | 0 / 2000 (0,0000) |
| 8x5 | E | 2000 | 0,1208 ; 0,7414 ; 1,4529 ; 2,0832 ; 2,8865 | 1,4495 | 0,1128 ; 0,5455 ; 0,9840 ; 1,4195 ; 1,9566 | 1,0029 | 0,8263 ; 0,9644 ; 1,0490 ; 1,1247 ; 1,2180 | 0 / 2000 (0,0000) |
| 8x6 | N | 2000 | 0,0227 ; 0,2615 ; 0,9242 ; 2,3490 ; 5,6158 | 1,6317 | 0,0529 ; 0,3035 ; 0,7067 ; 1,4325 ; 2,9988 | 1,0269 | 0,8785 ; 0,9699 ; 1,0087 ; 1,0787 ; 1,1928 | 0 / 2000 (0,0000) |
| 8x6 | E | 2000 | 0,0201 ; 0,4294 ; 1,3319 ; 2,6069 ; 4,7422 | 1,7091 | 0,0437 ; 0,3066 ; 0,8801 ; 1,5316 ; 2,2742 | 0,9796 | 0,9057 ; 0,9743 ; 1,0216 ; 1,0882 ; 1,1763 | 0 / 2000 (0,0000) |
| 8x7 | N | 1000 | 0,0006 ; 0,0167 ; 0,0871 ; 0,3310 ; 0,9519 | 0,2361 | 0,0051 ; 0,1070 ; 0,4500 ; 1,4419 ; 3,8613 | 1,0077 | 0,6383 ; 0,8283 ; 0,9503 ; 1,0042 ; 1,1001 | 0 / 1000 (0,0000) |
| 8x7 | E | 1000 | 0,0004 ; 0,0152 ; 0,1103 ; 0,3325 ; 0,8049 | 0,2204 | 0,0014 ; 0,0998 ; 0,5493 ; 1,5976 ; 3,5837 | 1,0319 | 0,6542 ; 0,8126 ; 0,9403 ; 1,0028 ; 1,0857 | 0 / 1000 (0,0000) |

### K-T7 (descriptif) — niveau des p de famille et de la p globale (engine_p_famille())

τ sur les triangles admis où la ligne de famille est présente (p absente : non-rejet, comptée à part) ; classe contre la référence ρ_F majorante (#297, § 5.3), descriptif : ρ_F = 0,099 ; 0,049, taille du test de Monte-Carlo idéal à B_eff = 999 pour une statistique sans atome, majorant en présence d'atomes (B de cette exécution : 999). Aucun profil n'en dépend.

| G | Loi | Famille | α | admis | ligne présente | p absente | k | τ [IC] | classe (référence ρ_F majorante, descriptive) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | M1 | 0,10 | 2000 | 2000 | 0 | 181 | 0,09050 [0,07828 ; 0,10393] | compatible |
| 8x5 | N | M1 | 0,05 | 2000 | 2000 | 0 | 83 | 0,04150 [0,03319 ; 0,05119] | compatible |
| 8x5 | N | M2 | 0,10 | 2000 | 2000 | 0 | 196 | 0,09800 [0,08532 ; 0,11188] | compatible |
| 8x5 | N | M2 | 0,05 | 2000 | 2000 | 0 | 104 | 0,05200 [0,04268 ; 0,06266] | compatible |
| 8x5 | N | M3 | 0,10 | 2000 | 2000 | 0 | 176 | 0,08800 [0,07595 ; 0,10128] | compatible |
| 8x5 | N | M3 | 0,05 | 2000 | 2000 | 0 | 67 | 0,03350 [0,02605 ; 0,04235] | écart mineur |
| 8x5 | N | M4 | 0,10 | 2000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x5 | N | M4 | 0,05 | 2000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x5 | N | LC | 0,10 | 2000 | 2000 | 0 | 153 | 0,07650 [0,06523 ; 0,08903] | écart mineur |
| 8x5 | N | LC | 0,05 | 2000 | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | compatible |
| 8x5 | E | M1 | 0,10 | 2000 | 2000 | 0 | 185 | 0,09250 [0,08016 ; 0,10605] | compatible |
| 8x5 | E | M1 | 0,05 | 2000 | 2000 | 0 | 96 | 0,04800 [0,03905 ; 0,05830] | compatible |
| 8x5 | E | M2 | 0,10 | 2000 | 2000 | 0 | 174 | 0,08700 [0,07501 ; 0,10022] | compatible |
| 8x5 | E | M2 | 0,05 | 2000 | 2000 | 0 | 87 | 0,04350 [0,03499 ; 0,05338] | compatible |
| 8x5 | E | M3 | 0,10 | 2000 | 2000 | 0 | 196 | 0,09800 [0,08532 ; 0,11188] | compatible |
| 8x5 | E | M3 | 0,05 | 2000 | 2000 | 0 | 92 | 0,04600 [0,03724 ; 0,05612] | compatible |
| 8x5 | E | M4 | 0,10 | 2000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x5 | E | M4 | 0,05 | 2000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x5 | E | LC | 0,10 | 2000 | 2000 | 0 | 162 | 0,08100 [0,06941 ; 0,09383] | écart mineur |
| 8x5 | E | LC | 0,05 | 2000 | 2000 | 0 | 75 | 0,03750 [0,02961 ; 0,04678] | écart mineur |
| 8x6 | N | M1 | 0,10 | 2000 | 2000 | 0 | 175 | 0,08750 [0,07548 ; 0,10075] | compatible |
| 8x6 | N | M1 | 0,05 | 2000 | 2000 | 0 | 85 | 0,04250 [0,03409 ; 0,05229] | compatible |
| 8x6 | N | M2 | 0,10 | 2000 | 2000 | 0 | 210 | 0,10500 [0,09190 ; 0,11927] | compatible |
| 8x6 | N | M2 | 0,05 | 2000 | 2000 | 0 | 114 | 0,05700 [0,04724 ; 0,06808] | compatible |
| 8x6 | N | M3 | 0,10 | 2000 | 2000 | 0 | 176 | 0,08800 [0,07595 ; 0,10128] | compatible |
| 8x6 | N | M3 | 0,05 | 2000 | 2000 | 0 | 69 | 0,03450 [0,02694 ; 0,04346] | écart mineur |
| 8x6 | N | M4 | 0,10 | 2000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x6 | N | M4 | 0,05 | 2000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x6 | N | LC | 0,10 | 2000 | 2000 | 0 | 136 | 0,06800 [0,05736 ; 0,07993] | écart mineur |
| 8x6 | N | LC | 0,05 | 2000 | 2000 | 0 | 64 | 0,03200 [0,02473 ; 0,04068] | écart mineur |
| 8x6 | E | M1 | 0,10 | 2000 | 2000 | 0 | 202 | 0,10100 [0,08814 ; 0,11505] | compatible |
| 8x6 | E | M1 | 0,05 | 2000 | 2000 | 0 | 97 | 0,04850 [0,03950 ; 0,05885] | compatible |
| 8x6 | E | M2 | 0,10 | 2000 | 2000 | 0 | 159 | 0,07950 [0,06802 ; 0,09223] | écart mineur |
| 8x6 | E | M2 | 0,05 | 2000 | 2000 | 0 | 76 | 0,03800 [0,03005 ; 0,04733] | écart mineur |
| 8x6 | E | M3 | 0,10 | 2000 | 2000 | 0 | 215 | 0,10750 [0,09426 ; 0,12190] | compatible |
| 8x6 | E | M3 | 0,05 | 2000 | 2000 | 0 | 100 | 0,05000 [0,04086 ; 0,06048] | compatible |
| 8x6 | E | M4 | 0,10 | 2000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x6 | E | M4 | 0,05 | 2000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x6 | E | LC | 0,10 | 2000 | 2000 | 0 | 172 | 0,08600 [0,07408 ; 0,09915] | compatible |
| 8x6 | E | LC | 0,05 | 2000 | 2000 | 0 | 83 | 0,04150 [0,03319 ; 0,05119] | compatible |
| 8x7 | N | M1 | 0,10 | 1000 | 1000 | 0 | 80 | 0,08000 [0,06394 ; 0,09858] | écart mineur |
| 8x7 | N | M1 | 0,05 | 1000 | 1000 | 0 | 38 | 0,03800 [0,02703 ; 0,05179] | compatible |
| 8x7 | N | M2 | 0,10 | 1000 | 1000 | 0 | 106 | 0,10600 [0,08760 ; 0,12675] | compatible |
| 8x7 | N | M2 | 0,05 | 1000 | 1000 | 0 | 57 | 0,05700 [0,04345 ; 0,07322] | compatible |
| 8x7 | N | M3 | 0,10 | 1000 | 1000 | 0 | 72 | 0,07200 [0,05676 ; 0,08982] | écart mineur |
| 8x7 | N | M3 | 0,05 | 1000 | 1000 | 0 | 32 | 0,03200 [0,02199 ; 0,04488] | écart mineur |
| 8x7 | N | M4 | 0,10 | 1000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x7 | N | M4 | 0,05 | 1000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x7 | N | LC | 0,10 | 1000 | 1000 | 0 | 68 | 0,06800 [0,05319 ; 0,08541] | écart mineur |
| 8x7 | N | LC | 0,05 | 1000 | 1000 | 0 | 34 | 0,03400 [0,02366 ; 0,04719] | écart mineur |
| 8x7 | E | M1 | 0,10 | 1000 | 1000 | 0 | 104 | 0,10400 [0,08577 ; 0,12460] | compatible |
| 8x7 | E | M1 | 0,05 | 1000 | 1000 | 0 | 45 | 0,04500 [0,03301 ; 0,05975] | compatible |
| 8x7 | E | M2 | 0,10 | 1000 | 1000 | 0 | 84 | 0,08400 [0,06755 ; 0,10294] | compatible |
| 8x7 | E | M2 | 0,05 | 1000 | 1000 | 0 | 43 | 0,04300 [0,03129 ; 0,05749] | compatible |
| 8x7 | E | M3 | 0,10 | 1000 | 1000 | 0 | 94 | 0,09400 [0,07663 ; 0,11380] | compatible |
| 8x7 | E | M3 | 0,05 | 1000 | 1000 | 0 | 51 | 0,05100 [0,03821 ; 0,06651] | compatible |
| 8x7 | E | M4 | 0,10 | 1000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x7 | E | M4 | 0,05 | 1000 | 0 | 0 | 0 | — | non évaluable (n = 0) |
| 8x7 | E | LC | 0,10 | 1000 | 1000 | 0 | 93 | 0,09300 [0,07572 ; 0,11272] | compatible |
| 8x7 | E | LC | 0,05 | 1000 | 1000 | 0 | 31 | 0,03100 [0,02116 ; 0,04372] | écart mineur |

### Profils pour D2 (Θ), évalués mécaniquement, sans décision (ordre Θ0, Θ5, Θ4, Θ3, Θ2, Θ1)

| Profil | Condition mécanique | Présent | Cellules |
| --- | --- | --- | --- |
| Θ0 | intégrité, K3 (signal non expliqué) ou K4 en défaut ; ou K-T6 significatif (« non expliqué » : jugement d'actuary) | **oui** | intégrité OK ; K3 non expliqué : 8x5 E HomogF 0,05 ; 8x6 E HomogF 0,05 ; 8x7 E Runs 0,05 ; K4 rempli : oui ; K-T6 significatif : E Runs 0,05 (explication à juger par actuary ; Θ0 acquis par ailleurs : intégrité, K3 ou K4) |
| Θ5 | une clé en distorsion de côtés opposés entre N et E pour une G (un seuil ou l'autre, α de chaque côté indiqué ; 8 x 5 et 8 x 6) | non | — |
| 8 x 7 (descriptif, hors profil) | même condition que Θ5 sur le 8 x 7, contrôle d'implémentation (K-T6, clés du carré) : ne propose aucun profil | — | — |
| Θ4 | distorsion matérielle libérale d'une clé sur 8 x 5 ou 8 x 6, pour une loi ; même clé sur le 8 x 8 de #297 lue contre le ρ du 8 x 7 (et non celui de #297 ; même loi oracle sous (c), hypothèse [H] appuyée sur (o), (g'), (r297) et le taux o8 : N 1000 / 1000 (8 x 8 non ajustable : 0) ; E 1000 / 1000 (8 x 8 non ajustable : 0)) | non | — |
| Θ3 | distorsion matérielle conservatrice sur une clé (8 x 5, 8 x 6) | non | — |
| Θ2 | aucune distorsion, des non tranchés (8 x 5, 8 x 6) | **oui** | 8x5 N MinP4 0,05 ; 8x6 N MinP4 0,05 |
| Θ1 | 13 clés compatibles ou en écart mineur sur 8 x 5 et 8 x 6, N et E, aux deux seuils, et K-T6 sans signal | non | 104 cellules évaluables ; non évaluables : — |
| **Profil proposé (premier présent dans l'ordre)** | **Θ0** | — | lecture d'actuary, décision du mainteneur à D2 |

Bilan : OK

### Exécution (varie d'une exécution à l'autre)

- Lancement (JOURNAL) : 2026-11-20T20:10:25Z ; fin : 2026-11-21T06:14:33Z
- Processus : 4 ; lignes calculées par cette exécution : 1000, 10 tranche(s), 3708 s d'horloge ; tranches reprises : 1290
- Durée cumulée des lignes (somme des processus) : 142501 s ; contrôles (a) et (r297) : 31,7 s ; (rep) : 54,2 s ; durée totale : 3909 s

