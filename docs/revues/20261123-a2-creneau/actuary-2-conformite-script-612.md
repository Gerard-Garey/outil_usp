# Conformité du script de mesure de #612 au protocole (A2, étape 2)

*Rapport de l'agent `actuary` (routine), 23/11/2026, sur `tests/simulation_jm1_trapeze_t8.R` (`22ec8a9`, md5 `b21d58c9489681cde8432b310aa6311e`) ; protocole `actuary-1-protocole-612.md` (md5 `70176c2e3ded10922eeb81971b533ae7`, PA-1). Versé par la session principale (Q-54-10), en synthèse fidèle.*

## Verdict : conforme avec réserves

**Conforme, vérifié par lecture :**
- le § 4 est repris au bit (17 lignes, `identical()` TRUE) ;
- K0 à K4 et les règles R0 à Défaut sont évalués comme écrit, sans conclure : McNemar exact, intervalle conditionnel, TOST, Holm, marges δ ;
- le témoin K3 de #567 est repris à l'identique : copies conformes à `niveau_mw_trapeze_t8.R` l. 1320-1344, 1427-1428, 1474 ;
- blocs, comptes et graines sont conformes (§§ 3, 6, 9), de même que les cibles de couverture : σ_A^règle = 0,021331 / 0,018101 / 0,016621.

**Point de lecture pour l'étape 4, non bloquant.** Si K1 et K3 sont tous deux en défaut, le script rend R-V0, et non « Défaut ». Les deux lectures mènent à V0.

**Erratum du protocole, à consigner à l'étape 4.** Le fichier lui-même n'est pas modifié, car son md5 a été approuvé à PA-1. Au § 1, les valeurs 0,684464 / 0,141928 / 0,030091 et 0,314779 / 0,0973248 / 0,189674 sont des σ²_{J−1} (règle, puis direct), et non des σ_A. La définition de σ_A^règle (√MSEP/R du générateur), elle, est juste, et le script l'applique.

## Les dix écarts déclarés par `coder-approfondi`

Tous sont acceptables. Deux portent une réserve :

| # | Écart | Verdict |
|---|---|---|
| 1 | V0 recalculé à B = 199 en essai | acceptable |
| 2 | (oracle) sans objet en essai | acceptable, réserve R1 |
| 3 | balayage à 10 points (1 200 bootstraps), imposé par le contrôle bloquant du § 5 (2) ; le 840 du § 9 est incohérent avec le § 5 | acceptable |
| 4 | budget de 13 × 1,8 h et borne P_k ≤ k | acceptable |
| 5 | carré et D en une seule exécution, avec la preuve (dc) | acceptable |
| 6 | (rep) limité aux blocs à triangles | acceptable, réserve R2 |
| 7 | triangles sans intervalle exclus de K4 et comptés à part | acceptable |
| 8 | définitions de la sonde | acceptable |
| 9 | graines du bootstrap de D : 661 500 000 + 100 000 (ℓ − 1) + b | acceptable |
| 10 | (c) compare des σ² | acceptable ; l'erreur est dans le protocole |

## Réponses aux questions de `coder-approfondi`

- **Q1.** (inv) doit être un défaut de K0 qui déclenche R0, et non un INTEGRITE ECHEC : les sorties restent versionnables. INTEGRITE garde les contrôles de code et de reproductibilité. C'est la lecture de l'auteur du protocole, qui s'oppose à la phrase du § 8 « tous les contrôles sont bloquants ». **Correction exigée C2.**
- **Q2.** En K4, les triangles sans intervalle sont exclus. Recommandé R6 : ventiler par variante, et donner en descriptif la version qui les compte comme non-couverture.
- **Q3.** Budget et borne conformes à PA-1. Recommandé R7 : prévoir une marge pour l'agrégation finale au dernier segment, par exemple `--duree-max 1.6`.
- **Q4.** Les 1 200 bootstraps du balayage sont acceptables (environ +18 min).
- **Q5.** Les définitions de la sonde sont acceptables. Recommandé R5 : retirer le triangle observé du dénominateur de la part touchée. Recommandé R4 : lancer `--bloc S` en premier (environ 4 min). À B = 999, err_mc baisse d'environ √5 alors que Δp ne baisse pas : la règle du constat (1) pourrait se déclencher (*hypothèse*). Le mainteneur saurait alors avant la mesure longue s'il faut une correction `moteur:`.
- **Q6.** La prémisse de la question est inexacte : le md5 du protocole n'a pas changé (`70176c2e…`). C'est le md5 du moteur cité dans le protocole qui a changé. **Correction exigée C1** : rendre bloquant `md5 == MD5_PROTOCOLE_PA1`.

## Corrections avant lancement

**Exigées :**
- **C1** : (t) bloquant sur le md5 du protocole approuvé à PA-1 ;
- **C2** : (inv) sorti d'INTEGRITE et rendu défaut de K0, qui déclenche R0.

C1 et C2 changent le md5 du script : il faut donc refaire les deux pré-vols, l'essai et l'audit léger du diff.

**Recommandées :**
- **R1** : lecture du tableau de (oracle) sous `--essai` ;
- **R2** : (rep) sur OR et OD ;
- **R3** : retirer D du verdict K0 sur les refus et les p absentes ;
- **R4** : bloc S en premier ;
- **R5** : dénominateur de la sonde ;
- **R6** : ventilation des triangles sans intervalle par variante ;
- **R7** : marge du dernier segment ;
- **R8** : traiter (o) et (dc) comme (inv).
