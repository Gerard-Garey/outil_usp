# S9, #420, #367 et #421 : réponses d'actuary aux dix questions du coder et de l'audit léger

> *Rédigé par l'agent actuary (IA), fiche `actuary`, le 27/11/2026, sur `claude/mesures-t8` (tête `6d7295e`). Versé intégralement par la session principale (Q-54-10). J'ai lu `tests/mesure_correlation_cvm_ad_t8.R` (commit `b8e8672`), le bloc `--grubbs-interieur` de `tests/mesure_b_dossier_t8.R` (l. 93-142 et 339-474, commit `b994b7d`), `R/engine.R` (l. 5481-5485 pour la règle des verdicts de `add()`, l. 7640-7667 pour la ligne Grubbs, l. 2527 pour `usp_parametre(fit, …)`), ainsi que mes avis `actuary-protocoles-etape-1.md` (§ 1.5, 2, 3) et `actuary-questions-421.md`. Je n'ai écrit aucun fichier. Les réponses sont fondées a priori : les seules valeurs que j'ai vues sont les deux bornes d'essai citées par le brief (B = 299), et aucune décision ne s'appuie sur elles. [V] = vérifié (lecture du code ou calcul donné), [H] = hypothèse.*

## #420 : corrélation de W² et A²

### Q1 : le trou du critère § 2.4 est fermé a priori (le code change)
- **Origine du trou** : mon § 2.4 tranche ρ_S sur son estimation (seuils 0,70 et 0,90), mais exige les bornes à 2 ET pour la quasi-redondance. Il ne dit rien du cas où ρ_S ≥ 0,90 sur les deux jeux sans que les deux bornes soient atteintes. C'est une omission de ma part.
- **Décision** : le reste se partage en deux branches, évaluées dans cet ordre, sur J1 et J2.
  1. **P(rejet CvM | rejet AD) estimée < 0,75 à α = 0,10 sur un jeu au moins** → **« Dépendance forte, non quasi redondante (concordance des rejets sous 0,75) »**, PM-3, phrase à nuancer.
     - Justification : c'est la même règle que pour ρ_S, qui se tranche déjà sur l'estimation. Une corrélation des rangs élevée qui ne donne pas des décisions concordantes ne montre pas « deux fois la même information ».
  2. **Sinon**, l'estimation passe le seuil mais au moins une borne à 2 ET le manque (ρ_S − 2 ET < 0,90 ou P(CvM|AD) − 2 ET < 0,75) → **« Quasi-redondance non établie à B = 9 999 »**, PM-3.
     - La phrase « presque deux fois la même information » ne peut pas rester sans réserve dans un dossier ACPR. Elle est remplacée par les valeurs chiffrées (estimation ± ET), sans dire qu'elle est contredite.
- **Pas de relance à B plus grand** une fois le résultat vu : ce serait un choix guidé par les données (M42).
- **Le rapport P(rejet conjoint)/α_eff n'est pas un critère distinct** : il est algébriquement égal à P(rejet conjoint)/P(rejet AD) = P(CvM|AD). Le critère reste écrit sur la probabilité conditionnelle.
- **Ordre de grandeur, pour mémoire** [V, calcul] : à n ≈ 9 999 et α = 0,10, on attend environ 999 rejets AD ; l'ET binomiale d'une conditionnelle voisine de 0,8 vaut √(0,16/999) ≈ 0,013, donc une borne à 2 ET d'environ 0,025 ; le facteur √(299/9 999) = 0,173 du brief est cohérent avec ce calcul.
- **Code** : remplacer la branche « cas non prévu » par ces deux branches (libellés ci-dessus), et tracer l'écart au protocole dans la trace M42 de `synthese.md`.

### Q2 : égalité par construction, critère sur le minimum (le code change légèrement)
- [V, argument] Sans ex aequo, les rangs sont une permutation de 1..n, et les p laisser-un-de-côté prennent chacune des valeurs k/n exactement une fois. Chaque statistique compte donc ⌈nα⌉ − 1 rejets, et sum(rw) = sum(ra) sont des entiers égaux. Les deux conditionnelles sont alors identiques, sur l'échantillon entier comme dans chaque sous-échantillon jackknife. Avec des ex aequo (`ties.method = "min"`), les comptes peuvent différer.
- **Décision** :
  - le critère porte sur **min(P(CvM|AD), P(AD|CvM))**, qui se confond avec l'une ou l'autre en l'absence d'ex aequo ;
  - le libellé dit : « égales par construction en l'absence d'ex aequo (T1) ; sinon, critère sur la plus petite des deux » ;
  - T3 n'affiche qu'une ligne si les ex aequo sont nuls sur le jeu, et les deux sinon ;
  - ajouter un contrôle : ex aequo nuls ⇒ `identical()` des deux conditionnelles.

### Q3 : jackknife à 20 groupes inégaux, formule non pondérée : acceptable, sans changement
- Les tailles 499 et 500 ne diffèrent que de 0,2 %. L'écart de la formule non pondérée à une formule pondérée est d'un ordre bien inférieur à l'incertitude de l'ET lui-même [V, argument].
- Avec G = 20, l'ET jackknife a environ 19 degrés de liberté. Son erreur relative est d'environ 1/√38 ≈ 16 % [H : approximation du χ²]. La borne « − 2 ET » est donc une convention à ±0,3 ET près. Cela doit être écrit sous T5, à côté des seuils déclarés.
- **Réserve [H, sans référence vérifiée dans cette consultation]** : la conditionnelle dépend d'un seuil de rang (un quantile empirique), qui n'est pas une fonction lisse de moyennes ; le jackknife qui retire une observation à la fois est connu pour mal se comporter sur les quantiles. Ici, chaque groupe retiré fait environ 5 % de l'échantillon, et je tiens l'ET pour une approximation raisonnable, sans garantie théorique citée ; je ne demande pas de méthode de rechange, car le critère est une convention déclarée.

### Q4 : « — (par construction) » pour les taux marginaux : d'accord (le code change)
- Sans ex aequo, le taux marginal vaut exactement (⌈nα⌉ − 1)/n. Son ET jackknife ne reflète que les tailles de sous-échantillon 499 ou 500 : c'est un artefact.
- **Code** : si les ex aequo sont nuls sur le jeu, afficher « (⌈nα⌉ − 1)/n — par construction » sans ET ; sinon, garder l'ET ; l'ET du taux conjoint, lui, est réel : le garder.

### Q5 : `stop()` si un sous-échantillon n'a aucun rejet : d'accord, sans changement
- Sans ex aequo, ce cas est impossible dès que (n − n_g)·α ≥ 1. C'est vrai même à l'essai : 284 × 0,05 ≈ 14 rejets [V, calcul].
- S'il survient, le jackknife est dégénéré, et aucune lecture ne doit être imprimée. Un `stop()` explicite, avec message, convient.

## #367 : Grubbs sur `premium_interieur`

### Q6 : agrégat sous Clopper–Pearson à 99 % : légitime, avec un diagnostic à ajouter
- [V, argument] Pour chaque graine, conditionnellement à N_s, les tirages retenus par acceptation-rejet sont i.i.d. sous la loi conditionnelle au régime intérieur. Donc K_s | N_s ~ Bin(N_s, p_∞). C'est vrai aussi bien quand l'arrêt survient à B retenus que quand le plafond de 25 (B + 1) tirages est atteint (N_s est alors aléatoire, mais le conditionnement suffit).
- Si les flux sont indépendants, K_tot | (N_s) ~ Bin(N_tot, p_∞). Clopper–Pearson est alors exact et conservateur.
- L'indépendance de flux Mersenne-Twister issus de dix graines distinctes est une **hypothèse d'usage**. Elle n'est pas démontrable ici et doit rester déclarée telle quelle (c'est le cas). Le risque pratique est un chevauchement des flux ; je le tiens pour négligeable à ces longueurs [H].
- **Ajout recommandé, non bloquant** : un test d'homogénéité des K_s/N_s entre graines (χ² à 2 lignes × (nombre de graines) colonnes), rapporté comme constat, sans effet sur la lecture. Il a peu de puissance contre une corrélation entre flux, mais il détecte une anomalie grossière : loi différente d'une graine à l'autre, ou erreur de comptage. Effectifs attendus d'environ 900 par cellule : l'approximation du χ² est sans objet.

### Q7 : graine du dossier présentée à part, lecture sur les quatre secondaires (le code change)
- [V, l. 127-128] À B = 9 999, la graine du dossier reprend le tirage principal, dont les 999 et 4 999 premiers tirages ont fait naître #367 : un verdict qui bascule de OK à ALERTE. Ces tirages ont été choisis *parce que* leur K tombait près du seuil. L'effet est faible, mais il est réel, et rien ne le borne simplement.
- **Décision** : la lecture du § 3.4 porte sur l'agrégat des **quatre graines secondaires**.
  - Coût [V, calcul] : N ≈ 40 000 au lieu de 50 000, soit une demi-largeur à 99 % d'environ 2,576 × √(0,09 × 0,91/40 000) ≈ 0,0037, contre 0,0033. Le prix en précision est négligeable.
  - La graine du dossier reste exécutée et rapportée, dans une ligne de T à part (contexte).
  - L'agrégat à cinq graines est imprimé à titre d'information, sans lecture.
  - Si sa classification diffère de celle des quatre secondaires, la discordance est signalée telle quelle ; la lecture des secondaires fait foi.
- C'est un écart à mon § 3.2, décidé avant toute exécution complète, à tracer dans la trace M42.

### Q8 : ajouter le seuil 0,05 : d'accord (le code change)
- [V, `R/engine.R` l. 5484-5485] Pour le sens « ne pas rejeter », le verdict est ECHEC si p < α/2, ALERTE si α/2 ≤ p < α, OK si p ≥ α.
- La ligne Grubbs (l. 7641) ne pose pas `sens`. **À vérifier par un contrôle** que son `sens` vaut « ne pas rejeter » (à ajouter à (g1) ou à (g3)) : je ne l'ai pas lu dans `engine_table_tests()`.
- **Lecture complète**, sur l'IC à 99 % de p_∞ (agrégat des quatre secondaires, voir Q7) :

| Position de l'IC | Lecture |
|---|---|
| borne haute < α/2 | **ECHEC à B infini** |
| dans [α/2 ; α[ | **ALERTE à B infini** |
| borne basse ≥ α | **OK confirmé** |
| contient α/2 | indécidable ECHEC/ALERTE |
| contient α | indécidable ALERTE/OK |

- Calculer α/2 depuis `meta$alpha` (contrôlé par (g3)), et non le coder en dur.
- **Conséquences** : ALERTE : inchangée par rapport au § 3.4 (signalée au mainteneur, Q-Ff-5, pas de PM-3) ; ECHEC ou indécidable ECHEC/ALERTE : **signalé au mainteneur** avec mention expresse que le verdict à B infini s'écarte de deux niveaux de l'OK du dossier. Que la phrase du `.tex` doive changer ou non est une décision hors S9 ; a priori, une issue en ECHEC est peu probable (pronostic [H], sans effet sur la règle).

### Q9 : (g2) étendu à l'ajustement : d'accord, et à σ_USP (le code change)
- [V, l. 2527] `usp_parametre(fit, sigma_standard, bareme)` ne dépend pas du bootstrap. δ̂, γ̂, σ̂ et σ_USP sont des fonctions déterministes des données. Sur une même machine, ils doivent être identiques au bit près entre les graines.
- **Code** : (g2) exige `identical()` entre les graines de g_obs, de δ̂, de γ̂, de σ̂ (champs de `res$ajustement`) et de σ_USP.
- Un écart signale un aléa non maîtrisé en amont du bootstrap : c'est un défaut de reproductibilité, qui rend l'agrégat illégitime.

## #421

### Q10 : correction de l'exemple confirmée ; deux non-rejets donnent bien un désaccord
- [V, calcul] Avec p0 = 1 − 1e-9 et N = 4e5, on a p0^N = e^(−4e-4) = 0,99960.
  - **Taux simulé de 1** (X = N) : P(X ≥ N) = 0,9996 et P(X ≤ N) = 1. La p bilatérale vaut min(1 ; 2 × 0,9996) = **1**, et non 0,9996 : accord.
  - **Un non-rejet** (X = N − 1) : P(X ≤ N − 1) = 1 − e^(−4e-4) ≈ 4,0e-4. La p bilatérale vaut ≈ **8,0e-4**, et non 4,0e-4. Elle est sous 2,700e-3 et au-dessus de 6,334e-5 : cellule **signalée**, sans désaccord.
  - Le classement est inchangé. Les valeurs de mon point 2 (0,9996 et 4,0e-4) étaient unilatérales, en contradiction avec la règle bilatérale que j'ai moi-même prescrite. Le code a raison ; la synthèse et l'avis sont à corriger par note.
- [V, calcul] **Deux non-rejets** (X = N − 2) : P(X ≤ N − 2) ≈ λ²/2 = 8,0e-8, avec λ = 4e-4. La p bilatérale vaut ≈ **1,6e-7** < 6,334e-5 : **désaccord**. Si la cellule porte sur un T ou un ρ cité par le `.tex`, le désaccord déclenche **PM-3** (§ 1.5, K421-2). Sinon, il compte dans la règle « plus de 2 signalées ».
- **Réserve pour la lecture, sans changer la règle** : quand Imhof vaut 1 tronqué, le plancher 1 − 1e-9 suppose un déficit réel ≤ 1e-9. Or l'erreur de `integrate()` est estimée à environ 1e-10, ce n'est pas une borne (avis 421, point 1) ; si le déficit réel atteignait 1e-6, deux non-rejets sur 4e5 seraient banals (λ = 0,4). Un désaccord dans une cellule tronquée doit donc être lu comme « simulation ou quadrature », et non comme un défaut de la simulation. La phrase PM-3 doit le dire.

## Retour
- **Statut** : complet pour Q1 à Q10, avec deux points à confirmer dans le code (sens de la ligne Grubbs, Q8 ; champs de `res$ajustement`, Q9).
- **Preuves** : vérifiées : lecture des scripts aux commits cités, de `R/engine.R` (l. 5481-5485, 7641-7667, 2527) et des avis du dossier ; calculs binomiaux et d'ET donnés dans le texte. Hypothèses : indépendance des flux MT ; qualité de l'ET jackknife sur une conditionnelle fondée sur un quantile (aucune référence vérifiée dans cette consultation) ; incertitude de l'ET à 19 degrés de liberté. Non vérifiés : `sens` effectif de la ligne Grubbs ; noms des champs δ̂, γ̂, σ̂ dans `res$ajustement`.
- **Décisions non résolues** : trace dans la réserve M42 des écarts au protocole (Q1, Q2, Q7, Q8) : mainteneur ; conséquence pour le dossier d'une issue ALERTE ou ECHEC à B infini sur Grubbs (Q-Ff-5) : mainteneur, hors S9.
- **Critères déclenchés** : écart au protocole écrit (Q1, Q7, Q8), décidé avant toute exécution complète, dans le périmètre de la réserve M42. Aucun résultat du moteur n'est changé.
- **Constats hors périmètre** : erreur d'exemple de mon avis 421, point 2 (valeurs unilatérales) : aucun critère G ni E1 à E6 (classement inchangé), donc mineur au sens de l'ADR 0018, corrigé ici ; omission du cas résiduel dans mon § 2.4 : aucun critère, donc mineur, corrigé par Q1.
- **Prochaine action recommandée** : `coder-approfondi` applique Q1, Q2, Q4, Q7, Q8 et Q9 (et le χ² de Q6 s'il est retenu), puis relance les essais. `audit` léger sur le diff. La session verse cet avis et complète la trace M42 avant l'exécution complète de l'étape 6.
