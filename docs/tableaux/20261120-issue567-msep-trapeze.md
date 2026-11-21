## Mesure #567 (S6, étape 5 (a)) : MSEP de Merz-Wüthrich sur un trapèze I > J, confrontée à CL_MSEPs (ChainLadder 0.2.21), critère C1

### Statut

Concordance numérique entre deux implémentations et une transcription : le moteur (fonctions internes, garde MW-04 en place), CL_MSEPs, fonction interne de ChainLadder 0.2.21 portant l'en-tête « Author: Mario Wuthrich » (implémentation de l'auteur, **non formule publiée** ; aucune source imprimant le cas I > J n'a été relue, spécification 2a, par. 1.1), et une transcription de D(4)(c) et D(5)(d)(ii) écrite dans ce script sans lire le moteur. Approximation numérique au sens de l'arithmétique flottante (écarts relatifs mesurés), non résultat exact ; elle établit que le moteur calcule la convention (B) de CL_MSEPs, pas que cette convention est celle du règlement (lecture de `regulatory`, étape 1).

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Protocole | docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md, par. 1.3 (critère C1, tolérance 1e-12 relative) ; décision Q-2a-5 du mainteneur (20/11/2026) ; md5 0495f005ad9aa1d61c40f3dcafdb70c5 |
| Archive CRAN | ChainLadder_0.2.21.tar.gz, md5 2a1fc0fcc593ec99529a40399274a088 (attendu 2a1fc0fcc593ec99529a40399274a088), lue en argument, jamais copiée dans le dépôt |
| Fonction lue | CL_MSEPs, ChainLadder/R/MWChainLadder.R (md5 53cde7fbc23cc6d2aa8e2b255fdb3bd0), lignes 11 à 73, texte md5 afb0d678d823745dd9808b9aa9e10d67 ; paquet 0.2.21, publié 2026-02-18 08:30:02 UTC |
| Jeux | tests/donnees/triangle_mw.csv (reserve2, md5 3e9a584da42443f3816fb63deeffa95b) : 8 x 8, et 8 x 7, 8 x 6, 8 x 5 par retrait des dernières colonnes ; GenIns (Taylor et Ashe 1983) : 10 x 10, 10 x 9, 10 x 7, 10 x 5 |
| Paramètres passés à CL_MSEPs | transcription indépendante : f_j (D(4)(c)), σ²_j (première ligne de D(5)(d)(ii), j ≤ J − 2), σ²_(J−1) de la règle de minimum, Q_j = σ²_j / f_j², α_j = C(I − j, j) / S′_j, triangle complété par les f_j ; estimateur direct de σ²_(J−1) : première ligne de D(5)(d)(ii) en j = J − 1 (I > J) |
| Moteur | mw_ajuster(), mw_msep() (charger_moteur(), ADR 0016) ; run_engine() refuse un trapèze (MW-04) jusqu'à D2 |
| SHA, git rev-parse HEAD (début ; fin) | 766b9de1c0bc1e8a91797e37a5ca319c92b65152 ; 766b9de1c0bc1e8a91797e37a5ca319c92b65152 |
| Commit (commit_depot()) | 766b9de1c0bc1e8a91797e37a5ca319c92b65152 |
| md5 R/engine.R | faf36c545999c147087759155a2bd38a |
| Empreinte sans commentaires de R/engine.R (#231) | 307e07604e7d87b23173f48daebb9383 |
| Empreintes md5 du code exécuté | R/engine.R faf36c545999c147087759155a2bd38a ; tests/outils_tests.R chargé (dépôt) cdf8f7da242e2c6281fadcb4108aab63 ; script exécuté (dépôt) 6e74e6c998252c2a89bf2ee3483a35f1 |
| Plateforme de calcul | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Locale (LC_CTYPE) | C.UTF-8 → C.UTF-8 |
| Date (UTC) | 2026-11-20T10:42:56Z |
| Versionnable (--ecrire) | oui |

### Résultats (critère C1, écarts relatifs, tolérance 1e-12)

| Jeu | MSEP, moteur | MSEP, CL_MSEPs | écart MSEP | R, moteur | écart R (CL_MSEPs) | écart f (transcription) | écart σ²_j, j = 0..J−1 (transcription) | σ²_(J−1), règle | σ²_(J−1), direct | écart direct (transcription) | écart max. au tableau du par. 1.3 | C1 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| triangle_mw 8x8 | 39798.0296160152 | 39798.0296160152 | 1.83e-16 | 9140.84343795463 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.0973247604368617 | — (carré : champ absent) | 0.00e+00 (champ NULL exigé) | — (hors tableau) | OK |
| triangle_mw 8x7 | 19915.3947059509 | 19915.3947059509 | 0.00e+00 | 8490.81633282289 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.0300913181729469 | 0.189673662669698 | 0.00e+00 | 2.19e-15 | OK |
| triangle_mw 8x6 | 17334.2597283566 | 17334.2597283566 | 4.20e-16 | 7273.53169003966 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.14192783039125 | 0.0973247604368617 | 0.00e+00 | 3.13e-15 | OK |
| triangle_mw 8x5 | 15763.5410314709 | 15763.5410314709 | 0.00e+00 | 5885.87803675476 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.684464137043688 | 0.314778798976253 | 0.00e+00 | 3.53e-16 | OK |
| GenIns 10x10 | 3164725947271.91 | 3164725947271.91 | 0.00e+00 | 18680855.6119243 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 446.616550105352 | — (carré : champ absent) | 0.00e+00 (champ NULL exigé) | — (hors tableau) | OK |
| GenIns 10x9 | 2764721031511.53 | 2764721031511.53 | 1.77e-16 | 17825075.6984623 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 24.3674453780781 | 1147.36596842866 | 0.00e+00 | 2.30e-15 | OK |
| GenIns 10x7 | 2220973209004.33 | 2220973209004.33 | 2.20e-16 | 12983205.6743162 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 12418.5249545645 | 8185.77162000963 | 0.00e+00 | 1.76e-15 | OK |
| GenIns 10x5 | 1405527865679.78 | 1405527865679.78 | 0.00e+00 | 8599219.11811852 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 37736.8550479964 | 15182.9026809764 | 0.00e+00 | 2.40e-15 | OK |

Écarts : |a − b| / max(|a|, |b|), 0 si a = b ; maximum sur les composantes pour f et σ²_j ; ∞ si une valeur est absente ou non finie. Les valeurs du tableau du par. 1.3 sont à 15 chiffres significatifs.

### Contrôles

| Contrôle | Résultat | Détail |
| --- | --- | --- |
| archive | OK | ChainLadder_0.2.21.tar.gz (md5 2a1fc0fcc593ec99529a40399274a088 = attendu) ; paquet ChainLadder 0.2.21 (DESCRIPTION, publié 2026-02-18 08:30:02 UTC) ; R/MWChainLadder.R md5 53cde7fbc23cc6d2aa8e2b255fdb3bd0 ; CL_MSEPs lignes 11 à 73 (texte md5 afb0d678d823745dd9808b9aa9e10d67), en-tête « Author: Mario Wuthrich » : présent ; fonction évaluée dans un environnement fils de baseenv(), extraction dans un dossier temporaire supprimé |
| GenIns | OK | matrice GenIns du script (celle de tests/unitaires/test_merz_wuthrich_trapeze.R) identical() à data/GenIns.RData de l'archive (valeurs, dimensions 10 x 10) : oui |
| C1 | OK | 8 jeu(x) sur 8 dans la tolérance 1e-12 relative (moteur contre CL_MSEPs et contre la transcription ; six trapèzes aussi contre le tableau du par. 1.3) |
| contexte | OK | md5 R/engine.R début faf36c545999c147087759155a2bd38a, fin faf36c545999c147087759155a2bd38a ; SHA début 766b9de1c0bc1e8a91797e37a5ca319c92b65152, fin 766b9de1c0bc1e8a91797e37a5ca319c92b65152 |

Critère C1 : OK (8 jeu(x) sur 8). Durée : 2.5 s.

