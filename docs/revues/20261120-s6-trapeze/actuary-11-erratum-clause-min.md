# Avis d'`actuary` : clause numérique de `.mw_simulation_sigma_direct()`, `max` ou `min` (erratum de l'avis actuary-10)

> *Rédigé par l'agent actuary (IA) le 22/11/2026 ; versé intégralement par la session principale.* Origine : constat « important » de `/code-review` (revue finale, règle 10) sur `R/engine.R` l. 13851 (`dba7bfc`). **Vaut erratum de `actuary-10-avis-m1-bootstrap-jm1.md`** (clause numérique, définition de ρ) : `max` devient `min`. L'option (b), les trois conditions et la constante `MW_TOL_SIGMA_SIMULATION = 1e-10` décidées par le mainteneur le 22/11/2026 ne changent pas ; la classe d'entrées qui bascule devient strictement plus petite. Le mainteneur en est informé dans la PR #611. Scripts d'essai hors dépôt : `rho_min.R`, `tests_min.R`.

## 1. Verdict : il faut `min`. `/code-review` a raison, et c'est un défaut de ma propre spécification.

**Raison analytique.** Le simulateur (`.mw_simuler_triangle_etat()`) tire C(i,J) = f·C(i,J−1) + e·σ·√C(i,J−1). La dispersion relative de chaque facteur vaut donc ρ_i = σ / (f·√C(i,J−1)) multiplié par |e|. Elle est la plus forte sur la ligne de **plus petit** cumul.

`.mw_colonne_degeneree()` exige max_i |F(i,J−1) − f̂| / f̂ ≤ 1e-12. Une colonne n'est donc dégénérée que si **toutes** les lignes sont sous la tolérance, y compris la plus dispersée. C'est cette ligne, celle du plus petit cumul, qui décide si la colonne est dégénérée.

- **Ce que garantit `min`.** Si le prédicat est faux (simulation sous la règle), ρ_min dépasse 1e-10. La ligne qui décide garde alors la marge de 1e-2 sur |e| annoncée par le commentaire. Une seule ligne au-dessus de la tolérance suffit à exclure la dégénérescence.
- **Ce que fait `max`.** Il garantit la même chose et davantage, mais bascule à tort sur l'estimateur direct toute la bande τ·f·√C_min < σ ≤ τ·f·√C_max. Dans cette bande, la simulation sous la règle n'est pas dégénérée.
- **Sens de « règle négligeable ».** `min` se lit « dispersion simulée ≤ 1e-10 sur chaque ligne », ce qui est le sens de « négligeable ». `max` se lit « sur la ligne la moins dispersée seulement ».
- **Critère `s2 <= 0`.** Dans `mw_residus()`, ce critère porte sur l'estimateur direct de la réplication (`.mw_sigma2_residus()`). Il ne s'annule que si tous les F(i,J−1) sont égaux, ce qui implique la dégénérescence. Même conclusion.

**Mesure** (`rho_min.R`, 500 réplications par point, graine 1). Cas (s2), où C_max/C_min = 1,09, puis variante où la ligne 0 est multipliée par 100 (C_max/C_min = 96,7). Entrées : nombre de réplications où la colonne J−1 sort dégénérée, sur 500.

| Échelle de ρ | 1e-12 | 1e-11 | 1e-10 | 1e-9 |
|---|---|---|---|---|
| (s2), échelle `max` | 236 | 7 | 0 | 0 |
| (s2), échelle `min` | 250 | 7 | 0 | 0 |
| ×100, échelle `max` | **1** | 0 | 0 | 0 |
| ×100, échelle `min` | **269** | 1 | 0 | 0 |

`s2_dir <= 0` n'apparaît dans aucune réplication.

Sur la variante ×100, la dégénérescence suit l'échelle `min` et non `max`. À ρ_max = 1e-12, une seule réplication sur 500 est dégénérée : à cette échelle, `max` bascule donc sur l'estimateur direct des cas qui ne posaient aucun problème. À ρ_min = 1e-10, il n'y en a aucune dans les deux configurations : la constante 1e-10 tient telle quelle à l'échelle `min`.

Mon calibrage d'origine (`rho.R`) définissait ρ contre C_max. Sur (s2), le rapport 1,09 rend les deux échelles indiscernables à la décade près, ce qui a masqué l'erreur. Ma phrase « ρ est la plus petite dispersion relative simulée » décrivait bien `max`, mais ce n'était pas la bonne quantité.

**Limite.** Aucune des deux formes ne donne une garantie déterministe. Le recentrage par f̂* et l'aplatissement des ex aequo laissent une probabilité, qui dépend du vivier ; elle a été mesurée nulle ici (|e| minimal du vivier : 0,079 et 0,17). C'est la même limite que pour la forme d'origine.

## 2. Ce qu'il faut changer

**Clause du moteur** (`R/engine.R`, `.mw_simulation_sigma_direct()`) :
```r
isTRUE(sqrt(aj$sigma2[J]) <=
         MW_TOL_SIGMA_SIMULATION * aj$f[J] * sqrt(min(aj$tri[seq_len(I - J + 1), J])))
```

**Commentaire de l'en-tête, condition 3** (texte proposé) : « sigma_(J-1) <= MW_TOL_SIGMA_SIMULATION * f_(J-1) * racine(min_i C(i,J-1)), i = 0..I-J, c'est-a-dire une dispersion relative simulee sigma_(J-1) / (f_(J-1) racine(C(i,J-1))) de F(i,J-1) d'au plus MW_TOL_SIGMA_SIMULATION sur chaque ligne ; la plus dispersee est celle du plus petit cumul, et c'est elle qui gouverne .mw_colonne_degeneree() (ecart maximal sur les lignes) : predicat faux, elle garde une dispersion relative superieure a 1e-10, cent fois la tolerance 1e-12. »

**Commentaire de la mesure** (texte proposé) : « ... refaite le 22/11/2026 a l'echelle du plus petit cumul : cas (s2) (C_max/C_min = 1,09), 250 / 7 / 0 replications degenerees sur 500 a 1e-12 / 1e-11 / 1e-10 ; variante a ligne 0 multipliee par 100 (C_max/C_min = 97), 269 / 1 / 0, contre 1 / 0 / 0 a l'echelle du plus gros cumul, qui ne gouverne pas la degenerescence. »

**Tests** (`tests/unitaires/test_merz_wuthrich_trapeze.R`) :
- l. 455 et 462 : remplacer `max` par `min`.
- **Sans cette correction, le test des bornes 0,99 / 1,01 échoue.** Sur le 8×6, C_max/C_min = 1,126 : 0,99 × seuil_max² dépasse seuil_min², donc le prédicat sort faux.
- Le cas `num` reste vrai : σ = 2,2e-15 pour un seuil `min` de 5,0e-9.
- Témoin à ajouter : le 8×6 avec σ²_(J−1) = seuil_min × seuil_max, strictement entre les deux seuils. Le prédicat doit valoir FALSE, alors qu'il valait TRUE sous `max`. C'est le cas soulevé par `/code-review`.

**Tableau `docs/tableaux/20261122-issue567-m1-simulation-jm1.md`** : aucun effet. Sur (s2) et sur la variante J−2, la règle est exactement 0, et c'est la clause `degeneree` qui décide (sur (s2), le prédicat vaut TRUE à toutes les échelles mesurées). Le tableau ne mentionne pas la forme de la clause. Références : aucun effet, puisque `reserve2_trapeze` est en cas « general » avec ρ = 6,8e-3.

**`.tex`** : deux occurrences à changer en `\sqrt{\min_{0 \le i \le I-J} C(i,J-1)}`, l. 1784 et l. 6543 (sec:boot-mw). Le contre-exemple « colonne dont les cumuls varient d'un facteur 100 » montre que la documentation doit dire « sur chaque ligne ». C'est pour `docwriter`, au passage de fin de branche.

**Avis versé** (`actuary-10-avis-m1-bootstrap-jm1.md`, l. 61, et la définition de ρ) : il écrit `max`. Je recommande un erratum daté qui renvoie au présent avis, sans réécrire l'avis ; à la session de trancher. *(Session : le présent fichier en tient lieu, et l'avis actuary-10 reçoit un renvoi en tête.)*

## 3. Décision du mainteneur

- La constante 1e-10 n'est pas touchée : elle reste validée à l'échelle `min`.
- Les trois conditions et l'option (b) ne bougent pas.
- La classe d'entrées qui bascule devient strictement plus petite (seuil_min ≤ seuil_max). Les verdicts changés restent donc dans la classe déjà acceptée.
- En revanche, le libellé exact du prédicat cité dans la décision change. À mon avis, le fond de la décision n'est pas affecté. Le mainteneur doit toutefois en être informé (une ligne dans la PR), et c'est à lui de dire s'il veut statuer à nouveau.

## Retour

- **Statut** : `complet`.
- **Résultat** : remplacer `max` par `min` ; textes de la clause, des commentaires, des tests et du `.tex` ci-dessus. La décision du mainteneur n'est pas affectée sur le fond, il faut seulement l'informer.
- **Preuves** — *vérifié* : le code de `.mw_colonne_degeneree()` et `.mw_ecart_facteurs()` (écart maximal sur les lignes), `.mw_simuler_triangle_etat()` (forme e·σ·√C) et `mw_residus()` (exclusion `s2 <= 0` sur l'estimateur direct) ; `rho_min.R` (tableau du § 1) ; `tests_min.R` (seuils des jeux de test, C_max/C_min de 1,06 à 1,69 sur les trapèzes de test) ; `grep` du `.tex` (l. 1784 et 6543). *Hypothèse* : la marge de 1e-2 sur |e| suffit pour tout vivier (mesurée sur deux configurations, non démontrée). *Non vérifié* : la batterie complète après le changement.
- **Critères déclenchés** : accord avec `/code-review`, aucun désaccord. Changement de résultat seulement sur des entrées hors références et hors tableau, dans la bande entre les deux seuils, qu'aucun cas de `CAS` n'atteint.
- **Constats hors périmètre** : aucun nouveau.
