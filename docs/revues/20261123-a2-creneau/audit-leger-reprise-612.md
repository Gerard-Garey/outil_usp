# Audit léger de la reprise du script de mesure de #612 (A2, étape 2)

*Rapport de l'agent `audit` (fiche de base), 23/11/2026, sur le diff `37c7479..3a0b582` de `tests/simulation_jm1_trapeze_t8.R` (359 ajouts, 128 retraits ; md5 `1e320e8e1b765dfd8ff64ad4b97df1ba`). Exécutions dans un worktree détaché à `3a0b582`, retiré ensuite. Versé par la session principale (Q-54-10), en synthèse fidèle.*

## Conclusion : conforme avec réserves

- C1, C2, R1 à R7 et les quatre mineurs de l'audit précédent sont codés et se comportent comme annoncé.
- L'essai complet, après reprise, finit sur INTEGRITE OK, code 0 ; 24 contrôles OK ; aucune régression des contrôles d'intégrité.
- Une réserve majeure, qui demande une décision et non du code (M1), et trois mineures.

## Constats

### Majeur

**M1 : (dc) D en défaut ne déclenche pas R0, contre la lettre de la décision C2.**
- Script : en-tête l. 33-40 ; `controle("(dc) D", …, nature = "constat")` l. 1911-1913 ; `DC_D_KO`, `REGLE_3` / `REGLE_4` l. 2196-2200.
- E-23/11 (étape 2) (`docs/feuille-de-route.md`, l. 4912) : « un défaut d'invariance (inv), ainsi que (o) et (dc), est un défaut de K0 qui déclenche R0 », sans distinguer carré et D.
- Scénario : une ligne admise de D avec `sim_dir != sim_dir_v2` ; le script rend K0 tenu et une règle R-V2 à R-V0, là où la lettre de C2 donne R0 ; seuls (3) et (4) deviennent non évaluables.
- Le commentaire l. 33-40 et le message de commit attribuent cette scission à C2 : inexact, aucune décision ne la consigne.
- Fond défendable, cohérent avec R3.
- Correction : (a) le mainteneur valide la scission, consignée au § 4 ; ou (b) `nature = "k0"` pour (dc) D. **Le mainteneur tranche**, sur avis d'`actuary`.

### Mineurs

- **m1 : refus tardif de `garde_ecrasement()` sous `--ecrire`** (l. 2431, `quitter = TRUE` par défaut) : sortie code 1 sans ligne INTEGRITE ni ECRITURE REFUSEE, contre l'en-tête (l. 97-108). Scénario : une cible de `docs/tableaux/` devient suivie pendant la mesure, sans `--remplacer`. Chemin non exécuté (lecture de `tests/outils_tests.R:739-746`). Correction : `quitter = FALSE` sous `tryCatch`, refus noté, copie seulement sans refus. ADR 0018 : aucun critère.
- **m2 : sonde entièrement non évaluable lue « constat documenté, mineur »** (`evaluer_sonde()`, l. 1040-1048) : toutes lignes à `n_triangles = 0` et p NA donnent `part = NA`, `ratio_max = -Inf`, `regle = FALSE`. Mesuré sur les fonctions extraites. Préexistant en partie. Correction : `regle <- NA` sans `part` fini, `ratio_max` à NA. ADR 0018 : aucun critère.
- **m3 : constat (1) provisoire réécrit et ligne de journal ajoutée à chaque segment interrompu** (l. 1710-1724), une fois S complet : jusqu'à 12 lignes identiques sur L-A, sans effet sur les nombres. ADR 0018 : aucun critère.

## Question pour `actuary`

**Q1 (R5).** Le triangle observé est exclu du numérateur et du dénominateur de la part touchée, compté à part (`obs_touche`), hors de la règle du constat (1). Si seul le triangle observé est touché et |Δp| > 2 err_mc, la règle rend « mineur » (test : `obs_touche = 1`, `part = 0`, `ratio_max = 5` → FALSE). Lecture voulue ? À l'essai, `obs_touche` vaut « non » sur les 35 lignes.

## Vérifications exécutées (`LC_ALL=C.UTF-8`)

| Vérification | Résultat |
|---|---|
| md5 | script `1e320e8e…`, protocole `70176c2e…`, `R/engine.R` `5bffa722…` ; diff vide sur `R/`, `app.R`, `tests/reference/` |
| `parse()` | OK ; 2 443 lignes, 0 non ASCII |
| `--prevol` | 302 s, INTEGRITE OK, code 0 ; (t), (1), (v0), (v2) 13/13 × 6, (u) OK ; L-A, 19,92 h, 12 segments ; empreinte `b83be1f07942eee31e423f579801e3dd` |
| `--essai --bloc S --processus 4 --travail` | 111 s, SEGMENT INTERROMPU, code 3 ; S seul (1 tranche, 26 restantes) ; `constat-1-sonde.md` écrit ; règle « mineur » à B = 199 |
| Reprise sans `--bloc` | 369 s, INTEGRITE OK, code 0 ; une ligne « Reprise » ; tranche S non recalculée |
| Contrôles de l'essai | 24/24 OK ; R1 (78/78 lignes, 78 clés distinctes) ; R2 (24/24 triangles, 16/16 lignes OR/OD) ; (inv), (o), (dc) carré « critère de K0 » ; (dc) D séparé |
| K0, R3, R6 | K0 tenu ; lignes D « non (bloc D, R3) » ; ventilation et descriptif présents |
| Invariance à l'ordre (R4) | md5 de la tranche S identique avant et après reprise (`c0b084b1…`) ; tableau provisoire = tableau final ; (rep) 40 lignes identiques dans un autre état du processus. Établie par lecture et indirectement, sans comparaison directe des deux ordres |
| Fonctions extraites | aiguillage `integrite` / `k0` / `constat` juste ; nature inconnue → `stop()` ; `cle_max` « - » si \|Δp\| nul |
| Dépôt | `git status` vide avant et après ; HEAD `3a0b582` |

## Écarts déclarés

1. ECRITURE REFUSEE vérifié par lecture : acceptable (l. 2420-2443), sauf m1.
2. R7 : acceptable ; agrégation de quelques dizaines de secondes à B = 199, à mesurer à B = 999 au segment final.
3. (c), (oracle), (u) bloquants : acceptable (§ 8 du protocole).
4. Scission de (dc) : acceptable en affichage ; nature « constat » de (dc) D non couverte par C2 (M1).
5. Nouvelle empreinte du pré-vol `b83be1f0…` : attendue, à confirmer par le second pré-vol à l'étape 3.

## Critères ADR 0018

Tous les constats (M1, m1, m2, m3) sont dans le périmètre de #612 ; signalés sans décision d'escalade.
