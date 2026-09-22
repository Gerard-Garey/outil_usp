---
status: accepted
date: 2026-09-22
---

# La MSEP de la méthode réserve n° 2 est la formule imprimée en D(5), lue sur pièce ; elle coïncide avec Merz-Wüthrich (2008) et il n'y avait rien à arbitrer

## Contexte

L'issue #7 constatait que σ_USP de la méthode du risque de réserve n° 2 (annexe XVII, section D) valait 0,0465566823 sur `tests/donnees/triangle_mw.csv` (T = 8, barème long, σ standard 0,09), et que cette valeur ne correspondait à aucune des deux lectures envisagées du paragraphe D(5) : la « lettre du texte » (σ_USP = 0,0507150172) ou la formule de Merz-Wüthrich (2008) telle que l'implémente `ChainLadder::CDR` (σ_USP = 0,0497764613). La décision M1 de la feuille de route attendait du mainteneur qu'il arbitre entre ces deux lectures, et le présent ADR devait consigner l'arbitrage.

**L'arbitrage n'a pas eu lieu, parce qu'il n'y avait pas lieu d'être.** Le texte officiel, lu sur pièce (captures du JOUE de l'annexe XVII, section D, § 5, fournies par le mainteneur, lues par la session principale et vérifiées numériquement ; issue #7, commentaire « M1 tranché sur pièce »), imprime la formule suivante, où le crochet noté Δ_i apparaît **deux fois** :

```
MSEP = Σ_{i=1}^{I} Ĉ(i,J)² · ( Q̂_{I−i}/C(i,I−i) + Δ_i )
     + 2 · Σ_{i=1}^{I} Σ_{k=i+1}^{I} Ĉ(i,J) · Ĉ(k,J) · Δ_i

Δ_i = Q̂_{I−i}/S_{I−i} + Σ_{j=I−i+1}^{J−1} (C(I−j,j)/S'_j) · (Q̂_j/S_j)
```

Points de lecture relevés sur le texte : bornes de la seconde somme `k = i+1..I` ; crochet indexé par `I−i` ; facteur 2 devant la double somme ; exposant 1 sur `C(I−j,j)/S'_j` ; grandeur nommée « l'erreur quadratique moyenne de prédiction ». Les définitions de `S_j`, `S'_j`, `Q̂_j`, `σ̂_j²` et de l'extrapolation `σ̂²_{J−1} = min(σ̂²_{J−2}, σ̂²_{J−3}, (σ̂²_{J−2})²/σ̂²_{J−3})` sont confirmées telles que le moteur les appliquait déjà.

Or, pour `k > i`, le crochet indexé par `i` est le crochet indexé par `min(i,k)`, et `2·Σ_{i<k}` est exactement la double somme complète hors diagonale ; la première somme contient les termes diagonaux `Ĉ(i,J)² Δ_i`. **La lettre du règlement est donc la formule de Merz-Wüthrich.** Il n'existe pas de « lecture (a) » ; la valeur 0,0507150172 ne correspond à aucun texte.

**Pourquoi deux transcriptions internes divergeaient.** Aucune des deux ne venait du texte au moment où la question a été posée ; toutes deux étaient fausses, et différemment :

| Transcription | Ce qu'elle affirmait | Ce qui manquait par rapport au texte |
|---|---|---|
| `docs/latex/doc_tests_usp.tex`, l. 3852-3857 (« transcription littérale ») | `Σ_i Ĉ² Q̂/C + Σ_i Σ_{k=i+1}^{I} ĈĈ Δ_i` | le facteur 2, et le crochet Δ_i dans la première somme — copie exacte de la formule du moteur |
| `tests/unitaires/test_merz_wuthrich.R`, l. 134-151 (première version de `msep_reglement()`) | double somme `i = 1..I`, `k = 1..I`, crochet en `i`, sans facteur 2 | ce n'est pas ce qui est imprimé ; c'est cette transcription qui a produit la « lecture (a) » de l'issue |

Le moteur (`mw_msep()`, avant le commit `cb7f497`) calculait `t1 + Σ_{i<k} ĈĈ Δ_i` : termes diagonaux omis et facteur 2 omis, soit 43,8 % de la MSEP manquante sur le triangle de test (25 à 27 % sur les deux autres triangles examinés), et un σ_USP sous-estimé **dans le sens favorable à l'entreprise**. La documentation reproduisant la formule du moteur, la « double implémentation indépendante » qu'elle invoquait comme validation de la MSEP à un an partageait la même erreur, ce qui explique qu'elle n'ait rien détecté. Le constat mathématique des agents `regulatory` et `actuary` (deux dérivations indépendantes aboutissant à `Δ_{min(i,k)}`, corroborées par la valeur `ChainLadder::CDR` consignée) était exact ; il ne pouvait pas trancher seul, parce que la question posée était « qu'est-ce qui est imprimé », et qu'aucun des deux n'avait accès au texte.

**Sur la source.** La pagination « JOUE L 12/277-278 » qui circule dans le dépôt (issue #7, en-tête de `mw_msep()`, commentaire de `msep_reglement()`, feuille de route) **n'a jamais été vérifiée** : elle descend d'une source interne à l'autre. La source de la transcription retenue est « captures du JOUE fournies par le mainteneur, lues et vérifiées numériquement », pas une citation du Journal officiel avec page. À confirmer sur le PDF avant remise.

## Décision

1. **Ce qui relève du texte** : `mw_msep()` implémente la formule imprimée en D(5), terme par terme et sous la forme imprimée (première somme avec `Q̂/C + Δ_i`, double somme `k = i+1..I` affectée du facteur 2), et non sous une forme algébriquement équivalente (`Δ_{min(i,k)}` sur `k = 1..I`). Le code et le test unitaire `msep_reglement()` transcrivent le texte ; l'équivalence avec Merz-Wüthrich est **testée**, jamais présumée.
2. **Ce qui relève du calcul** : la coïncidence avec la référence externe est un fait vérifié, pas une lecture. La formule réimplémentée telle qu'imprimée donne, sur Taylor & Ashe (1983), √MSEP = 1 778 967,66336 contre la valeur `ChainLadder::CDR` consignée dans `tests/unitaires/test_merz_wuthrich.R`, 1 778 967,66335758 (écart relatif −2,7e-15). Ce test unitaire devient un test ordinaire et constitue désormais la vérification **réellement** indépendante de la MSEP ; les deux `echec_attendu()` de l'issue #7 sont retirés, la transcription réglementaire et la valeur externe coïncidant.
3. **Ce qui relève d'un choix de restitution** : `mw_msep()` renvoie `terme_variance = Σ_i Ĉ(i,J)² Q̂_{I−i}/C(i,I−i)` (variance de processus seule) et `terme_covariance = Σ_i Ĉ(i,J)² Δ_i + 2 Σ_{i<k} Ĉ(i,J)Ĉ(k,J) Δ_i` (erreur d'estimation, termes diagonaux compris). Le texte ne prescrit aucun découpage ; celui-ci est la décomposition processus / estimation de la dérivation de Merz-Wüthrich, il a un sens statistique, et il laisse à `terme_variance` le sens qu'il avait, dont dépend `mw_contributions()` comme dénominateur des parts par année (`plots_data$contributions` inchangé). L'en-tête de `mw_msep()` le documente comme un choix de présentation, non comme une prescription.
4. **La « lecture (a) »** (double somme `k = 1..I` avec crochet en `i`, σ_USP = 0,0507) **ne doit plus être citée nulle part comme « lettre du texte »** ; les commentaires 1 à 4 de l'issue #7 la décrivent comme telle et sont, sur ce point, annulés par le commentaire « M1 tranché sur pièce ».
5. La décision M1 de la feuille de route est close **sans objet** ; J3 est ramené à une correction de conformité (circuit `coder` → `audit` → `regulatory` → `docwriter`), avec visa du mainteneur sur le changement de σ_USP (décision M3).

## Considered Options

- **Arbitrer entre les deux lectures sur la base des deux rapports, sans lire le texte** : écarté. Les rapports concordaient sur la mathématique et étaient explicites sur le fait qu'ils n'avaient pas lu le texte ; trancher sans pièce aurait consigné dans le dossier ACPR une « lettre du texte » qui n'existait pas.
- **Implémenter la forme `Δ_{min(i,k)}` sur `k = 1..I`** (forme de Merz-Wüthrich, plus compacte) plutôt que la forme imprimée : écarté. Le texte opposable est la forme imprimée ; un relecteur doit pouvoir comparer le code au règlement ligne à ligne. L'équivalence est vérifiée par le test unitaire au lieu d'être supposée.
- **Ranger les termes diagonaux `Ĉ(i,J)² Δ_i` dans `terme_variance`** (« MSEP propre à l'année i » complète) : écarté. Cela mêlerait variance de processus et erreur d'estimation dans une quantité qui n'a plus de nom, changerait `plots_data$contributions` sans raison méthodologique, et le texte ne le demande pas davantage que l'autre découpage.
- **Renommer `terme_covariance` dans la même PR** (le nom est désormais impropre : le champ contient de la variance d'estimation, pas seulement de la covariance) : écarté pour cette PR, comme le recommande `audit`. Le changement de structure de l'objet imposerait une régénération des références qui masquerait, dans le tableau avant / après, le changement de valeur que le mainteneur doit viser. Renommage dans une PR ultérieure à valeurs identiques.
- **Retenir la double somme `k = 1..I` avec crochet en `i` comme lecture « prudente »** : écarté deux fois. D'abord parce qu'elle n'est pas imprimée ; ensuite parce que, comme `actuary` l'a établi par contre-exemples (triangles simulés à profil σ²_j croissant), elle n'est ni une MSEP ni une borne de la MSEP : elle est supérieure à Merz-Wüthrich sur les triangles du dépôt par une propriété des données, pas de la formule.

## Conséquences

**Résultats** (triangle de test, `reserve2.rds` régénéré une première fois, tableau avant / après joint à la PR et soumis au visa du mainteneur) : σ_USP réserve n° 2 passe de 0,0465566823 à **0,0497764613** (+6,92 %) ; √MSEP de 149,610545 à 199,494435 (+33,34 %) ; `sigma_estime`, `variation_relative`, les tables `calibration` et `candidats`, `bootstrap$sigma_boot` et `ic_bootstrap` (déplacé de +2,9 % à +8,7 % selon le quantile) changent. **Aucun verdict, aucune p-value Monte-Carlo** : les statistiques simulées sont calculées avant `mw_msep()` dans `mw_bootstrap()` et n'en dépendent pas ; le flux du générateur est intact. `premium.rds` et `reserve1.rds` inchangés. Le sens de l'erreur corrigée (σ_USP sous-estimé, allègement de capital) doit figurer dans le dossier tel quel.

**Tests** : `msep_reglement()` réécrite d'après le texte ; les deux échecs attendus deviennent des tests ordinaires ; un test protège le découpage restitué (`terme_variance` = variance de processus seule, somme des deux termes = MSEP). L'implémentation par matrice de coefficients de `actuary` (§ 1.1 de son avis), qui ne passe pas par Δ, reste une vérification indépendante candidate à ajouter.

**Dette documentaire, à traiter par `docwriter` sur la même branche, après le code** :
- `docs/latex/doc_tests_usp.tex`, formule l. 3852-3857 : à réécrire d'après le texte (facteur 2, crochet dans la première somme) ; ne plus la présenter comme « transcription littérale » tant qu'elle ne l'est pas.
- Les passages qui fondent la validation de la MSEP à un an sur une « double implémentation indépendante » (tableau l. 4771, encadré « Réserve sur la validation » l. 4790-4797, liste l. 5164-5167) : elle n'en était pas une. La validation repose désormais sur la transcription du texte (`msep_reglement()`) et sur la référence externe `ChainLadder::CDR` ; l'encadré doit dire qu'une comparaison externe **existe**, à −2,7e-15, et non plus qu'aucune n'a été identifiée. La valeur 1 519 876 du tableau (l. 4773) est celle de la formule fausse et devient 1 778 968 (l'inégalité « erreur à un an < erreur ultime » reste vérifiée).
- Toute mention de la pagination « L 12/277-278 » (code, tests, feuille de route) est à qualifier de non vérifiée ou à retirer jusqu'à confirmation sur le PDF.

**Dette de nommage** : `terme_covariance` à renommer (par exemple en terme d'erreur d'estimation) dans une PR ultérieure, avec régénération des références à valeurs identiques (changement de structure sans changement de valeur).

**Ce qui reste ouvert** (hors du présent ADR, décisions du mainteneur) :
- **`σ̂²_{J−1}` quand `σ̂²_{J−3} = 0`** : le texte impose `min(σ̂²_{J−2}, σ̂²_{J−3}, (σ̂²_{J−2})²/σ̂²_{J−3})` et ne prévoit rien pour un dénominateur nul ; lu littéralement, le minimum vaut 0. `mw_ajuster()` pose alors `σ̂²_{J−2}`, sans le signaler, et la ligne M6 affiche cette valeur sous le libellé « règle min(...) du règlement ». `actuary` recommande la valeur littérale 0 avec alerte visible, à défaut le refus du calcul, et en aucun cas le maintien silencieux de `σ̂²_{J−2}` ; sensibilité de l'ordre de 4 % sur σ_USP. Le triangle de test n'est pas dégénéré (aucune référence touchée) ; la convention retenue devra être consignée, dans un ADR si elle s'écarte de la lettre.
- **Réserve ≤ 0 ou MSEP non finie** (décision M4, jalon J7) : D(4) divise par la réserve sans conditionner au signe ; `actuary` recommande le refus (`ok = FALSE`).
- **Géométrie I > J** : le moteur impose un triangle carré, convention non prescrite, déjà documentée ; rien à arbitrer tant qu'aucun dossier ne présente un trapèze.

Issues : #7 (partie bloquante). Feuille de route : jalon J3 ; décision M1 close sans objet ; M3 (visa du tableau) ; J6 et J7 débloqués après fusion. Voir `CONTEXT.md` (référence de non-régression).
