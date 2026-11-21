# S6, étape 2b (#610) : spécification et protocole d'un intervalle de σ en Merz-Wüthrich à couverture proche du nominal

> *Rédigé par l'agent actuary (IA).* S6, étape 2b, issue #610 : spécification et protocole d'un intervalle de σ en Merz-Wüthrich dont la couverture approche le nominal à T = 8. Consultation en lecture seule sur `claude/merz-wuthrich-trapeze` (tête `804a45b` ; md5 de `R/engine.R` `d94de7dcd2e188b70acc8571e0d4415d`, le même que `main` `c8840d4`). Je n'ai rien écrit dans le dépôt : ni fichier, ni issue, ni commentaire. Mes scripts sont dans le dossier temporaire de la session, `…/scratchpad/p610/` ; le pilote est recopié en annexe A pour que le versement le conserve. **Aucune couverture d'intervalle candidat n'a été calculée.** J'ai fait deux choses seulement : (1) relu le monde de #387 sous **ses propres graines** (P1 et P2, r ≤ 2 000 : mêmes triangles, mêmes σ\*), donc sans aucun tirage nouveau dans la population de mesure ; (2) mesuré des coûts sur des graines hors des plages de mesure.
>
> *Note de versement (session principale) : rapport versé intégralement, tel que rendu (seul le préfixe du dossier temporaire de la session est abrégé en `…/scratchpad/`). Le contenu de ce dossier (`pilote.R`, `pilote2.R`, `verif.R`, `ana.R`, `cout_imbrique.R`, journaux et sorties brutes `u_P*.tsv`, `w_P*.tsv`) est versé sans modification dans `actuary-2b-pilote/` ; les md5 cités ci-dessous y sont vérifiables.*

## 0. Synthèse

**Verdict : protocole prêt pour `coder-approfondi` (étape 4), sous les décisions Q-2b-1 à Q-2b-7 du mainteneur (§ 6).**

Quatre constats modifient la lettre de l'issue ou du plan.

1. **Le percentile calibré par bootstrap imbriqué, premier candidat de l'issue, est exclu par construction** (*vérifié*, relecture de #387, § 1.1). Dans le monde de #387, σ_A dépasse **le maximum des 999 σ\*** :
   - P1 : 379 triangles sur 2 000, soit 0,1895 [0,1725 ; 0,2074] ;
   - P2 : 328 sur 2 000, soit 0,164 [0,148 ; 0,181].

   Les bornes d'un intervalle tiré des quantiles des σ\* restent dans [min σ\* ; max σ\*]. C'est le cas du percentile, qu'il soit calibré ou non, et de BC et BCa. Pour un tel intervalle, le manque au-dessus de la borne haute vaut donc au moins ce taux. Sur P1, la borne basse de Clopper-Pearson de ce plancher (0,1725) dépasse déjà la limite de la bande (0,15) : une distorsion matérielle libérale y est acquise, quel que soit le niveau calibré. **Je remplace ce candidat par l'intervalle « basic » logarithmique I4 calibré par bootstrap imbriqué (C1).** Le plafond de I4, σ̂²/min σ\*, n'est dépassé que dans 1,6 % (P1) et 2,5 % (P2) des triangles. Le percentile calibré reste mesuré à titre descriptif (C0), sans surcoût.
2. **Le second candidat de l'issue est retenu : l'intervalle studentisé sur log σ, avec une variance interne par bootstrap imbriqué (C2).** Le jackknife est écarté : la colonne J−1 d'un triangle 8×8 ne compte qu'un facteur de développement, et le supprimer rend f_{J−1} inestimable (§ 2.4). Mesuré, en faveur de C2 (*hypothèse* sur son effet, mécanisme *vérifié*) : la dispersion bootstrap suit le niveau. La corrélation entre log σ̂ et sd(log σ\*) vaut 0,78 (P1) et 0,68 (P2). Par tiers de σ̂/σ_A, la médiane de sd(log σ\*) vaut 0,148, 0,177 et 0,292 (P1). C'est exactement ce qu'une studentisation corrige, et ses bornes ne sont pas limitées à l'étendue des σ\*.
3. **Coût réel inférieur à l'annonce de l'issue** (*vérifié*) : 0,262 ms par ajustement interne. Un triangle mesuré à B1 = 999 et B2 = 199 coûte donc environ 53 s, contre 80 s annoncés. Niveau recommandé : N = 1 000 triangles par profil principal, soit **7,8 h d'horloge sur 4 processus au débit 3,82, et 10,9 h au débit 2,72**. C'est au-delà du budget de 3 h de #387 : une décision s'impose (Q-2b-2), avec reprise par tranches (M42) et une branche de sauvegarde (Q-2b-7).
4. **Plage de graines** : 610 000 001 à 644 999 999. Elle évite la plage réservée par 2a (567·10⁶ à 572·10⁶), celles de #206/#297, #305 et #387, et 360 380 123 (§ 3, P6).

## 1. Constats préalables (relecture du monde de #387 ; aucun candidat calculé)

### 1.1 Où tombe σ_A dans la loi bootstrap d'un triangle simulé

*Vérifié* par commande (`pilote2.R`, annexe A ; `ana.R`). Conditions : R 4.3.3, Linux, moteur `d94de7d`, graines de #387 (triangle 387 000 000 + 10⁶(p−1) + r, bootstrap 387 500 000 + 10⁶(p−1) + r), boucle allégée de #387 à B = 999.

**Filiation avec #387** (*vérifiée*) :
- σ̂ des 2 000 triangles de chaque profil égal au brut versé de #387 à 4·10⁻¹⁵ près en relatif. Ce n'est pas `identical()` : le moteur `d94de7d` diffère de `e6547ad`, et le brut passe par `%.17g`.
- Part des triangles où σ_A dépasse q_0,95 : 0,426 (P1) et 0,382 (P2) dans le pilote, contre un manque haut de I1 à 90 % de 0,427 et 0,383 dans #387. Le petit écart vient du seuil (« u > 0,95 » contre le quantile de type 7).

| Grandeur (n = 2 000, cible σ_A) | P1 (loi E) | P2 (loi N) |
|---|---|---|
| σ_A > max(σ\*), avec IC de Clopper-Pearson | 0,1895 [0,1725 ; 0,2074] | 0,164 [0,148 ; 0,181] |
| σ_A < min(σ\*) | 0 | 0 |
| σ_A > σ̂²/min(σ\*) (plafond de I4) | 0,016 [0,011 ; 0,0225] | 0,025 [0,0186 ; 0,0328] |
| Quantiles 1 / 2,5 / 5 / 10 % de v = Ĝ\*(σ̂²/σ_A) | 0 / 0,001 / 0,004 / 0,011 | 0 / 0,001 / 0,002 / 0,009 |
| z = (log σ_A − log σ̂)/sd(log σ\*), quantiles 5 / 50 / 95 % | −0,77 / 0,92 / 3,35 | −0,78 / 0,90 / 3,47 |
| cor(log σ̂, sd log σ\*) | 0,780 | 0,677 |
| Médiane de σ̂/σ_A | 0,845 | 0,845 |

Lecture :
- **Percentile calibré** (*vérifié*, argument d'ordre). Les bornes [Q\*(a_B) ; Q\*(a_H)] vérifient Q\*(a_H) ≤ Q\*(1) = max σ\*. Le manque haut est donc au moins égal à P(σ_A > max σ\*). Le profil Θ1 exige un candidat compatible ou en écart mineur sur P1 **et** P2 (§ 4) : C0 ne peut pas l'atteindre sur P1, pour aucun B2.
- **I4 calibré (C1)** : faisable, mais sous condition. Pour ramener son manque haut à 5 %, le niveau de sa borne haute doit tomber au 5e centile de v, soit 0,004 (P1) et 0,002 (P2). Autrement dit, la borne haute doit se placer entre la 2e et la 4e plus petite des 999 valeurs σ\* (*vérifié* comme oracle du monde de `reserve2`). Le double bootstrap d'un triangle r ne connaît pas cet oracle. Il l'estime à θ̂_r, où le biais vu est environ moitié moindre (#387, 1,055 contre 1,13). Le risque d'une calibration insuffisante est donc réel (*hypothèse*, objet de la mesure).
- **Studentisé (C2)** : il faudrait une queue basse de t\* proche de −3,4 en unités de sd(log σ\*), au lieu de −1,645 pour un pivot normal. La forte corrélation niveau-dispersion la rend plausible, puisque σ\*_b petit va avec ŝe\*_b petit, donc avec t\*_b très négatif (*hypothèse*).

### 1.2 Coût mesuré (machine de cette session : Linux, 4 cœurs, R 4.3.3)

*Vérifié* par `cout_imbrique.R` (annexe A), avec deux autres processus R actifs pendant la mesure, donc une valeur prudente.
- Bootstrap interne : 7 960 ajustements (40 réplications externes de `reserve2` × 199) en 2,09 s, soit **0,262 ms par ajustement**. `.mw_ensembles_figes()` coûte 1,1 ms par réplication externe.
- **La boucle interne est `identical()` à `mw_bootstrap(ab, 199, seed)$sigma_boot`** sur la réplication testée. Le contrôle 4 du § 3 est donc réalisable.
- Boucle allégée externe : 0,214 s par triangle simulé à B = 999 (moyenne sur 2 000 triangles).
- `run_engine(reserve2)` : 15,4 s, cohérent avec les 13,76 s de `mw_bootstrap()` relevés par 2a.
- Débit à 4 processus : 3,82 (pré-vol de #246, 19/11) et 2,72 (1b de #387). Je retiens les deux comme bornes.

## 2. Candidats : spécification et verdicts

Notation pour un triangle r, qui joue le rôle du triangle observé dans la procédure :
- σ̂ = √MSEP/R̂ ;
- σ\*_b (b ≤ B1) : le `sigma_boot` du moteur, de graine G_EXT ;
- θ̂\*_b : l'ajustement de la réplication externe b ;
- σ\*\*_{b,k} (k ≤ B2) : le bootstrap du moteur appliqué à θ̂\*_b (vivier et ensembles figés de θ̂\*_b, graine G_INT) ;
- n_b : le nombre de σ\*\*_{b,·} finis ; une réplication b n'entre que si n_b > 20 (règle du moteur, l. 17484 à `e6547ad`), sinon elle est comptée.

Quantiles de type 7, comme pour `ic_bootstrap`.

### 2.1 C1 : I4 calibré par bootstrap imbriqué, queues calibrées séparément

- w_b = (1/n_b) · #{k : σ\*\*_{b,k} ≤ σ\*_b²/σ̂}.
  - Dans le monde externe, la vérité est σ̂. L'I4 interne de niveau a, [σ\*_b²/q\*\*_{1−a} ; σ\*_b²/q\*\*_a], manque en haut si et seulement si w_b < a, et en bas si et seulement si w_b > 1 − a (à la discrétisation près).
- Niveaux calibrés : a_H = Q_w(α) et 1 − a_B = Q_w(1 − α), les Q_w étant les quantiles de type 7 des w_b admis.
- **C1 = [σ̂²/Q\*(Q_w(1 − α)) ; σ̂²/Q\*(Q_w(α))]**, où Q\* désigne les quantiles des σ\* externes, c'est-à-dire du `sigma_boot` du moteur. C'est la formule de I4 (#387), niveaux remplacés.
- Q_w(α) = 0 donne la borne haute σ̂²/min σ\*. Ce cas, dit **saturation**, est compté.
- **Fondement** (*vérifié*, sources relues ce jour en rendu graphique) : calibration du niveau d'une borne par la proportion de réplications de second niveau couvertes. Chang et Hall (arXiv:1408.6327v1, 2014), éq. (9)-(11), p. 6, pour l'intervalle unilatéral fondé sur une racine non studentisée R = n^{1/2}(θ̂ − θ). Zrimšek et Štrumbelj (arXiv:2403.20182v3, 2025), § 2.1.8, p. 8 : α_DB = quantile d'ordre α des proportions internes. Appliquer une calibration à chaque borne d'un intervalle bilatéral est **ma construction**. La racine log σ̂ − log σ (I4) remplace le percentile pour le motif du § 1.1.
- **Verdict : à compléter.** Faisable, mais les niveaux requis sont extrêmes (0,2 à 0,4 %), sensibles à B1 et B2, et exposés à une calibration insuffisante si la non-pivotalité persiste au second niveau. Seule la mesure tranche.

### 2.2 C2 : intervalle studentisé sur log σ, écart-type par bootstrap imbriqué

- ŝe = sd(log σ\*_b) sur les σ\* externes finis.
- ŝe\*_b = sd_k(log σ\*\*_{b,k}) et t\*_b = (log σ\*_b − log σ̂)/ŝe\*_b.
- **C2 = [σ̂ · exp(−ŝe · Q_t(1 − α)) ; σ̂ · exp(−ŝe · Q_t(α))]**. Un ŝe\*_b non fini ou ≤ 10⁻¹² est exclu et compté.
- **Fondement** :
  - Studentisation par un écart-type obtenu par bootstrap interne : Zrimšek et Štrumbelj (2025), § 2.1.7, p. 8 (θ̂_{B−t}[α] = θ̂ − σ̂ T_{1−α}, T\* = (θ̂\* − θ̂)/σ̂\*, σ̂\* par un bootstrap interne sur chaque réplication externe) (*vérifié*, lu ce jour).
  - Racine studentisée et σ̂\*_b de la réplication : Chang et Hall (2014), éq. (5)-(7), p. 5, et p. 6 : l'algorithme ne serait pas d'ordre deux si σ̂ remplaçait σ̂\* (*vérifié*).
  - Variante sur l'échelle logarithmique : Davison et Hinkley (1997), § 5.7, tableau 5.8, d'après le relevé S2.3 du dépôt, *non relu par moi*. À n = 10 (bootstrap non paramétrique, rapport de moyennes gamma), la variante studentisée sur l'échelle log donne 5,6 % et 6,3 % de manques, pour 5 % de chaque côté.
- **Risque écrit** (*vérifié* dans la source) : McCarthy et al. (arXiv:1511.00273v3, 2017, p. 5) observent que le double bootstrap-t « can be erratic at times » quand un écart-type bootstrap très petit ou dégénéré apparaît au dénominateur, « particularly acute when sample sizes are small ». Sur P1 et P2, π̂ = 0 : risque faible (*hypothèse*). Les ŝe\*_b dégénérés sont comptés.
- **Verdict : candidat le plus pertinent** (*hypothèse*, § 1.1). Ses bornes ne sont pas limitées à l'étendue des σ\*, et la studentisation vise le mécanisme mesuré (dispersion liée au niveau).

### 2.3 Variantes descriptives, gratuites (mêmes tirages)

- **C0** : percentile calibré queue par queue, avec u_b = Ĝ\*\*_b(σ̂) et C0 = [Q\*(Q_u(α)) ; Q\*(Q_u(1 − α))]. Il documente le plancher du § 1.1 et justifie l'écart à la lettre de l'issue.
- **C1-99** et **C2-50** : C1 calculé sur les 99 premiers σ\*\* de chaque b, C2 sur les 50 premiers. Ce sont les procédures à B2 réduit, utiles si une restitution doit alléger le coût (D3).
- **I1 et I4** recalculés sur les triangles nouveaux, en regard : c'est la référence de la comparaison.

### 2.4 Options écartées

- **Jackknife pour la variance interne** : écarté (*vérifié* par la géométrie). La colonne j compte I − j facteurs de développement : la colonne 6 d'un 8×8 n'en a qu'un. Le supprimer rend f_6 inestimable, et σ²₆ vient de la règle de minimum. Les cumuls sont en outre dépendants. Aucune source relue ne fonde un jackknife de σ̂ = √MSEP/R̂ dans ce modèle.
- **BC et BCa** : écartés.
  - Leurs bornes sont des quantiles des σ\* : le plancher du § 1.1 s'applique (*vérifié*).
  - ẑ₀ « measures the median bias of θ̂\* » (Efron et Tibshirani (1993), (14.14), relevé R27.5 du dépôt, non relu par moi) : il mesure le biais que voit le bootstrap, soit la moitié du biais réel (#387).
  - L'accélération demanderait un jackknife (point précédent).
- **Percentile calibré à λ symétrique** (McCarthy et al. (2017), étapes 1-5, p. 4, *vérifié*) : écarté. Même plancher, et il élargirait la queue basse, qui ne manque jamais (#387 : 0,000).
- **Double bootstrap « warp-speed »** (C = 1) : écarté. Selon Chang et Hall (2014, p. 2, *vérifié*), « the warp-speed bootstrap does not reduce the order of magnitude of coverage error of a confidence interval ». Dans leur figure 2 (n = 20), il est aussi moins exact que le double bootstrap conventionnel.

### 2.5 Ce que la littérature relue dit, et ne dit pas, à T = 8

- Chang et Hall (2014, p. 1, *vérifié*) : le double bootstrap réduit l'erreur de couverture d'un facteur O(n^{−1/2}) en unilatéral et O(n^{−1}) en bilatéral. Ce sont des **ordres asymptotiques**, qui ne disent rien à T = 8. Ils ne s'appliquent même pas directement ici : la statistique n'est pas une fonction lisse d'une moyenne de n vecteurs i.i.d. (leur cadre (1)-(2), p. 2-3).
- Chang et Hall, figure 2, p. 9, n = 20, bootstrap non paramétrique de la moyenne, intervalle bilatéral à 90 %, valeurs lues sur le graphique à 0,01 près :
  - loi lognormale : percentile simple ≈ 0,79, double ≈ 0,86, double bootstrap-t ≈ 0,87-0,88 ;
  - loi exponentielle : ≈ 0,84, 0,89 et 0,90-0,91.

  Le double bootstrap améliore la couverture sans atteindre le nominal dans le cas lognormal. Ce n'est pas transposable.
- Zrimšek et Štrumbelj (2025, p. 16, *vérifié* ; prépublication, statut d'évaluation non vérifié) : « DB … can perform relatively poorly when n = 4, 8 » (bootstrap non paramétrique ; moyenne, variance, quartiles, corrélation).
- **Aucune source relue ne chiffre la couverture d'un intervalle de σ = √MSEP/R̂ en Merz-Wüthrich, ni d'aucun double bootstrap paramétrique à T = 8.** La mesure est la seule preuve visée.
- **Non relus, donc non cités sur le fond** :
  - Davison et Hinkley (1997), § 5.6 « Double bootstrap methods » : Google Books refusé par le proxy de la session (HTTP 403 sur le CONNECT), Cambridge Core payant ;
  - Beran (1987, 1988), Hall et Martin (1988), Booth et Hall (1994), Lee et Young (1999) ;
  - DiCiccio et Efron (1996) (Project Euclid, 403) ; Davison, Hinkley et Young (2003) (page de l'auteur, 403).

  Le choix C = ⌊10 B^{1/2}⌋ est attribué par Chang et Hall (p. 7) à Booth et Hall (1994) puis à Lee et Young (1999). Je ne le reprends qu'à ce titre de seconde main.

## 3. Protocole numéroté (P1 à P11, sur le modèle de 1b)

**P1. Objet et frontières.**
- Script nouveau `tests/couverture_ic_sigma_mw_imbrique_t8.R`, nom à confirmer ; une mesure nouvelle se fait dans un script nouveau (Q-42-14).
- R base + stats, `parallel`, `utils`, `tools`. Moteur chargé par `tests/outils_tests.R` (ADR 0016).
- Le nom ne commence pas par `test_`. Le script ne modifie ni `R/`, ni `app.R`, ni `tests/reference/`.
- C0, C1 et C2 sont calculés dans le script seulement. Aucun effet sur σ_USP, sur les p-values ni sur les verdicts.

**P2. Générateur, lois, admission.**
- Ceux de #387 : `preparer_generateur()`, `gen_triangle_h0()`, `admettre()` et `boucle_allegee()` de `tests/couverture_ic_sigma_mw_t8.R`, copiés ou mis en commun sans modifier ce script versionné.
- Profils :
  - **P1** (`reserve2`, loi E) et **P2** (`reserve2`, loi N) : critère principal ;
  - **P3** (`reserve2`, loi A) : descriptif, selon Q-2b-3 ;
  - P4 et P5 (fixture volatile) **exclus par défaut** (Q-2b-3).
- La boucle interne est celle de la boucle allégée appliquée à θ̂\*_b, avec `.mw_ensembles_figes(θ̂*_b)`. Le chemin est le même que `mw_bootstrap()` (contrôle 4).
- Si l'étape 3 de #567 précède la mesure, le chemin I = J reste identique au bit (plan, Forme (i)). Le script consigne md5 et empreinte.

**P3. Cible.**
- σ_A, cible principale, comme Q-1b-1 (A) : 0,02182451 sur P1 à P3. σ_B descriptive, calculée par `recomposer()` de #387.
- Échelle σ : l'application affine croissante vers σ_USP conserve la couverture (raisonnement de #387, P3).

**P4. Intervalles mesurés.**
- I1, I4 (références), **C1 et C2 (candidats)**, C0, C1-99 et C2-50 (descriptifs), à 90 % (principal) et à 95 %.
- Un intervalle n'est formé que si plus de 20 σ\* externes sont finis et si plus de 20 réplications b sont admises.
- Couverture : borne basse ≤ σ_A ≤ borne haute.

**P5. Admission.**
- Conditionnelle à R̂ > 0 (M4) et à R\* > 0. Sur P1 et P2, 0 refus attendu (#387).
- Comptes à restituer : réplications b exclues (n_b ≤ 20), ŝe\*_b dégénérés, saturations de C1 et C0.

**P6. Graines.** Toutes passent par `engine_sous_graine()`. p désigne le profil (1 = P1, 2 = P2, 3 = P3), r ≤ 2 000, b ≤ 999.
- Triangle : G_TRI(p, r) = 610 000 000 + 1 000 000 (p − 1) + r.
- Bootstrap externe : G_EXT(p, r) = 610 500 000 + 1 000 000 (p − 1) + r.
- Bootstrap interne : G_INT(p, r, b) = 620 000 000 + 4 000 000 (p − 1) + 1 000 (r − 1) + b. Maximum 629 999 999.
- Pré-vol : triangles 640 000 000 + 10 000 (p − 1) + u ; externe 640 050 000 + 10 000 (p − 1) + u ; interne 641 000 000 + 100 000 (p − 1) + 1 000 (u − 1) + b, avec u ≤ 50.
- Sous-plage réservée au trapèze (Q-2b-6) : 642 000 001 à 644 999 999.
- Disjonction : de 567 000 000-572 000 000 (2a), 20 840 001-20 960 000 (#206 et #297), 20 260 831-20 262 831 (#297 lognormale), 305 000 000-305 939 169 (#305), 387 000 000-393 100 000 (#387) et 360 380 123. Contrôle des littéraux [L ; L + 20 000] repris de #387. Maximum inférieur à 2³¹ − 1.

**P7. Nombre de triangles, B1, B2.**
- B1 = 999, en double. C'est le B du moteur : les σ\* externes sont le `sigma_boot` restitué.
- **B2 = 199** pour C1 (résolution de w de 1/199 ≈ 0,005, à rapprocher des niveaux requis de 0,002 à 0,004, § 1.1) ; C2 utilise les mêmes 199 tirages.
- R est un nombre de triangles **tirés**, fixé avant l'exécution et écrit au JOURNAL. Niveaux et budget : § 5. Règle : le premier niveau dont la durée prévue au pré-vol tient dans le budget fixé par Q-2b-2. Au-dessous du dernier niveau, retour au mainteneur.

**P8. Tranches et reprise (M42 (b)).**
- Tranches de 20 triangles, soit environ 18 min CPU par tranche à B2 = 199. Une interruption ne coûte au plus qu'une tranche par processus.
- Contexte comparé entre tranches (B1, B2, SHA, md5, empreinte, plateforme). Mécanique de `couverture_ic_sigma_mw_t8.R`.

**P9. Modes.**
- `--essai` : R = 3 par profil, B1 = 199, B2 = 49 ; sorties marquées ; `--ecrire` refusé.
- `--prevol` : coût d'un triangle (externe et interne) à 1, 2, 3 et 4 processus ; **coût additionnel du calcul de C1 et C2 sur `reserve2` dans les conditions de `run_engine()`**, critère d'acceptation de l'issue ; choix du niveau ; rien d'écrit.
- Mesure : `--niveau`, `--processus`, `--travail`, `--ecrire`.

**P10. Sorties.** Fichiers nouveaux, jamais patchés :
- `docs/tableaux/<AAAAMMJJ>-issue610-couverture-ic-sigma-mw-imbrique.md` ;
- `…-brut.tsv` : une ligne par triangle tiré, `%.17g`, toutes les bornes, w et t\* résumés (quantiles 0,05 et 0,95), comptes ;
- `…-journal-mesure.md`.

Critères de #242 (échappements `\u`, aucun chemin absolu). Dernière ligne de la console : `INTEGRITE OK` ou `INTEGRITE ECHEC`.

**P11. Contrôles d'intégrité.** Un seul échec donne `INTEGRITE ECHEC`.
1. md5 de `R/engine.R`, SHA et empreinte #231 identiques au début, à la fin, au JOURNAL et dans chaque tranche.
2. σ_A de P1 égal à `parametre_final$sigma_estime` de `reserve2.rds`, à `TOLERANCE` près.
3. σ\* externes `identical()` à `mw_bootstrap(aj_r, 999, G_EXT)$sigma_boot` sur le premier triangle admis de chaque tranche.
4. σ\*\* internes `identical()` à `mw_bootstrap(θ̂*_b, 199, G_INT)$sigma_boot` sur la première réplication b admise du premier triangle de chaque tranche (faisabilité *vérifiée*, § 1.2).
5. Écriture indépendante de C0, C1 et C2 (statistiques d'ordre en clair, comme `q7_clair()` de #387) sur le premier triangle de chaque tranche, à 10⁻¹² en relatif.
6. Contrôle (g) de #387 : identité du générateur sur 100 graines.
7. **Filiation** : sous les graines de #387 (P1, r ≤ 20), σ̂, I1 et I4 égaux au brut versé de #387 à 10⁻¹² en relatif. Le pilote donne 4·10⁻¹⁵.
8. Disjonction des graines (P6), littéraux compris.
9. Contrôle (t610) : le critère et les profils du § 4 sont présents à l'identique dans le rapport versé (`docs/revues/20261120-s6-trapeze/`).
10. `grep -rn couverture_ic_sigma_mw_imbrique R/ app.R .github/` ne renvoie rien.
11. Comptes cohérents : tirés = admis + refusés ; b admis + b exclus = σ\* finis.

**Statut épistémique (à écrire tel quel en tête de la sortie).** La couverture mesurée est un **constat de simulation**. Elle vaut sous le modèle de Mack ajusté au triangle de contrôle (f̂, σ̂² extrapolé compris, première colonne fixée), pour une loi d'erreurs donnée, à T = 8. Elle porte sur la procédure entière à B1 = 999 et B2 = 199, conditionnellement à l'admission (R̂ > 0) et à R\* > 0. Ce n'est pas un résultat général : aucun théorème ne couvre ces intervalles à triangle fixe, et les ordres asymptotiques du double bootstrap (Chang et Hall, 2014) ne fondent rien à T = 8. Erreurs à distinguer :
- l'erreur Monte-Carlo en N, encadrée par Clopper-Pearson ;
- les effets de B1 et B2, inclus dans la procédure mesurée et non isolés (C1-99 et C2-50 en donnent seulement un éclairage) ;
- l'écart au nominal, qui est l'objet mesuré ;
- l'erreur de substitution (plan et loi au lieu de la vérité), non quantifiée.

## 4. Critère et profils, fixés avant toute exécution (à reporter sans modification dans le script et au T0)

> **Critère.** Taux de non-couverture τ de chaque (profil, intervalle, niveau), cible σ_A, comparé au nominal ρ = 0,10 (90 %) ou 0,05 (95 %). Classes de #166, #206, Fk, #305 et #387, bande **fermée** [ρ/2 ; 3ρ/2] : *compatible* (ρ ∈ IC(τ)) ; *écart mineur* (τ̂ dans la bande, sans être compatible) ; *non tranché* (τ̂ hors de la bande, IC qui la recoupe) ; *distorsion matérielle libérale* (IC disjoint de la bande, au-dessus) ; *distorsion matérielle conservatrice* (IC disjoint, au-dessous). IC de Clopper-Pearson à 95 % ; classes sur les valeurs non arrondies ; une estimation sur un bord est dans la bande ; **aucune extension de R après lecture** ; un « non tranché » reste non tranché.
> - **K-610-1** (principal) : classe à 90 % de C1 et de C2 sur P1 et sur P2.
> - **K-610-2** (descriptif) : 95 % ; queues séparées contre ρ/2 (bande [ρ/4 ; 3ρ/4]) ; cible σ_B ; I1 et I4 recalculés, en regard, et comparés aux classes de #387 ; C0, C1-99, C2-50 ; P3 si mesuré ; largeur médiane / σ_A et rapport à la largeur de I1 ; couverture par tiers de σ̂/σ_A ; part de σ_A > max σ\* et > σ̂²/min σ\* (reproduction du § 1.1 sur graines nouvelles) ; saturations de C1 et C0 ; part des bornes de C2 hors de [min σ\* ; max σ\*] ; quantiles de Q_w(α), Q_w(1 − α) et de Q_t.
> - **K-610-3** (intégrité) : contrôles 1 à 11 de P11.
> - **K-610-4** (frontière, descriptif) : l'IC touche-t-il un bord de la bande.
>
> **Profils de lecture pour D3** (`actuary` propose, le mainteneur tranche ; ordre : Θ0, Θ4, Θ1 à Θ3, puis modificateur W) :
>
> | Profil | Condition | Lecture proposée |
> |---|---|---|
> | Θ0 | K-610-3 en défaut ; ou, sur P1 ou P2, refus, triangles sans intervalle ou réplications b exclues au-delà de 1 % | lecture suspendue ; mesure à reprendre |
> | Θ4 | un candidat en distorsion de côtés opposés entre P1 et P2 | décision du mainteneur ; aucune restitution de ce candidat |
> | Θ1 | C1 ou C2 compatible ou en écart mineur sur P1 **et** P2 | **candidat éligible** ; D3 : restitution **en regard du percentile, jamais à sa place** (Q-42-10), textes tranchés à D3. Si les deux sont éligibles, préférence fixée d'avance : (i) celui dont les deux queues à 90 % sont dans [ρ/4 ; 3ρ/4] sur P1 et P2 ; (ii) à égalité, celui de moindre coût par `run_engine()` au pré-vol ; le mainteneur décide en dernier ressort |
> | Θ2 | aucun candidat éligible, au moins un « non tranché » sur P1 ou P2 | constat seul ; aucune restitution par défaut ; note inchangée |
> | Θ3 | C1 et C2 chacun en distorsion matérielle sur au moins un profil principal, sans Θ4 | constat seul ; note inchangée (« aucun intervalle mesuré ne rétablit ce niveau » reste vrai) ; fiche complétée par `docwriter` |
>
> **Modificateur W**, sous Θ1, pour le candidat retenu. W-a : bornes dégénérées, saturations et b exclus au plus 1 % sur P1 et P2 : aucune limite de plus. W-b : au-delà de 1 % : limite écrite dans la fiche, et décision du mainteneur sur la restitution.
>
> **Portée écrite d'avance** : un Θ1 vaut pour le triangle de contrôle sous E et N seulement. Le profil volatil (P4) n'est pas mesuré : la restitution porterait la mention de ce domaine.

## 5. Budget de calcul chiffré (machine : session cloud Linux, 4 processus)

Coût par triangle mesuré, en un processus (*vérifié* : 0,262 ms par ajustement interne, 1,1 ms par appel de `.mw_ensembles_figes()`, 0,214 s pour l'externe) :
- B2 = 199 : environ 53,4 s ;
- B2 = 99 : environ 27,2 s ;
- B2 = 50 : environ 14,4 s ;
- B2 = 999 : environ 263 s.

Le débit d'horloge à 4 processus est encadré par 3,82 et 2,72. Durées *estimées* (le pré-vol fait foi) :

| Niveau | Contenu | CPU | Horloge, débit 3,82 | Horloge, débit 2,72 | Demi-largeur CP à τ = 0,10 | Effet sur la précision |
|---|---|---|---|---|---|---|
| M0 | P1, P2 : N = 2 000 ; B2 = 199 | 213 600 s | 15,5 h | 21,8 h | ≈ 0,013 | référence |
| **M1 (recommandé)** | P1, P2 : N = 1 000 ; B2 = 199 | 106 800 s | **7,8 h** | **10,9 h** | ≈ 0,019 | classe tranchée sauf si τ est à moins d'environ 0,02 d'un bord de bande |
| M1 + P3 | + P3 descriptif, N = 500 | + 26 700 s | + 1,9 h | + 2,7 h | P3 : ≈ 0,027 | descriptif |
| M2 | P1, P2 : N = 1 000 ; B2 = 99 | 54 400 s | 4,0 h | 5,6 h | ≈ 0,019 | **C1 dégradé** : résolution de w de 0,010, au-dessus des niveaux requis de 0,002 à 0,004 ; saturations fréquentes ; C2 : bruit de ŝe\* d'environ 7 % au lieu de 5 % (*hypothèse*, ordre de grandeur pour une loi proche de la normale) |
| M3 | P1, P2 : N = 500 ; B2 = 199 | 53 400 s | 3,9 h | 5,5 h | ≈ 0,027 | zone « non tranché » élargie ; τ = 0,20 reste en distorsion, τ = 0,10 compatible |
| M4 (repli) | C2 seul, B2 = 50 ; P1, P2 : N = 1 000 | 28 800 s | 2,1 h | 2,9 h | ≈ 0,019 | pas de C1 ; seul niveau qui tient dans les 3 h de #387 |

- L'annonce de l'issue (80 s par triangle, « quelques dizaines d'heures » pour 2 000 triangles) est dépassée : pour 2 000 triangles au total (M1), 7,8 à 10,9 h (*vérifié* sur le coût unitaire ; débit à confirmer au pré-vol).
- **Coût par `run_engine()` en cas de restitution** (*estimé*, à mesurer au pré-vol) :
  - C1 et C2 à B2 = 199 : environ +53 s par appel en un processus, contre 15,4 s aujourd'hui, soit environ × 4,5 ;
  - C2 seul à B2 = 50 : environ +14 s, soit × 1,9.

  Effet sur l'application et sur la durée des batteries : à trancher à D3, hors de 2b.

## 6. Décisions du mainteneur (avant tout tirage)

- **Q-2b-1. Candidats.**
  - (a, recommandée) C1 = I4 calibré par bootstrap imbriqué, queues calibrées séparément, et C2 = studentisé sur log σ avec écart-type interne ; C0 descriptif.
  - (b) Percentile calibré comme candidat principal, à la lettre de l'issue : écartée, le plancher vérifié du § 1.1 le met en distorsion sur P1.
  - (c) C2 seul : retenue seulement en repli budgétaire (M4), car C1 est gratuit dès que B2 = 199.
- **Q-2b-2. Niveau et budget.**
  - (a, recommandée) M1, budget de **12 h d'horloge sur 4 processus** ; règle du pré-vol (P7) ; tranches de 20 (M42 (b)).
  - (b) M0 : écartée, le gain de précision (0,019 → 0,013) ne justifie pas un temps doublé vu la largeur des bandes.
  - (c) M2 : écartée, elle dégrade C1.
  - (d) M4, si le budget est refusé.
- **Q-2b-3. Profils.**
  - (a, recommandée) P1 et P2 principaux ; P3 descriptif seulement si le budget le permet (M1 + P3) ; P4 et P5 exclus, limite écrite.
  - (b) P4 descriptif réduit (N ≈ 500 tirés, environ 290 admis) : écartée par défaut, car le bootstrap interne y rencontre R\*\* ≤ 0 et des ŝe\* dégénérés (risque relevé par McCarthy et al.). Coût à mesurer.
- **Q-2b-4. Critère** : K-610-1 à K-610-4, Θ0 à Θ4, la règle de préférence et W, approuvés tels quels avant toute exécution.
- **Q-2b-5. Pilote.**
  - (a, recommandée) Ce rapport et son annexe A sont versés. Les chiffres du § 1.1 peuvent être cités à la lecture comme « relecture du monde de #387 ». Le script de mesure les reproduit sur les graines nouvelles (K-610-2) et contrôle la filiation (contrôle 7).
  - (b) Ne rien citer avant la mesure : écartée, car le § 1.1 fonde l'écart à la lettre de l'issue.
- **Q-2b-6. Trapèze (#567).**
  - (a, recommandée) Aucune mesure de couverture de #610 sur trapèze dans S6, sauf si D2 étend #567 **et** si D3 restitue un candidat. Dans ce cas : pilote de structure du § 1.1 sur un générateur trapèze du plan de 2a (quelques minutes, sous-plage 642·10⁶), puis mesure descriptive réduite (N = 500, loi E, environ 2 à 3 h).
  - (b) Mesure complète sur trapèzes dès maintenant : écartée (coût ; dépendance à D2 et à l'option (c) de 2a pour la colonne J−1).
  - (c) Aucune mesure, même si un candidat est restitué sur trapèze : écartée.
- **Q-2b-7. Exécution longue.** Une mesure de plus de 2 h en session cloud appelle, par analogie avec Q-42-11, l'autorisation d'avance d'une branche `claude/sauvegarde-610` (ADR 0007, exécution selon M42), sous condition que le pré-vol dépasse 2 h.

## 7. Avis sur l'extension des candidats au trapèze (#567)

- **Construction** : elle s'étend mécaniquement (*vérifié* par lecture de la définition). C1 et C2 n'emploient que le mécanisme de `mw_bootstrap()` (générer depuis l'ajustement, réajuster, σ = √MSEP/R̂), appliqué à deux niveaux. Une fois les fonctions internes généralisées sous la garde MW-04 (étape 3), aucune spécification propre au trapèze n'est nécessaire. Le script doit appeler ces fonctions internes, et non un prototype (Forme (vi), Q-71-3).
- **Couverture** : non transposable (*hypothèse*).
  1. Dans un trapèze, la colonne J−1 a I − J + 1 ≥ 2 facteurs de développement, et les estimateurs de σ²_j ont plus de degrés de liberté. Le biais de σ̂, première cause mesurée en 8×8, peut y être moindre, et le percentile s'y comporter autrement.
  2. Avec l'option (c) de 2a, la simulation emploie le σ de la règle de minimum pour J−1 : σ\*, C1, C2 et la cible σ_A dépendent de cette règle, et la convention de vérité doit le dire.
  3. La même règle doit s'appliquer à chaque niveau du bootstrap imbriqué. C'est le cas si les fonctions internes sont généralisées une fois pour toutes, à vérifier par le contrôle 4 sur un trapèze.
- **Recommandation** : Q-2b-6 (a). Le plancher du § 1.1, qui exclut le percentile calibré, est à revérifier sur trapèze avant toute affirmation.

## Retour

- **Statut** : `revue requise`. Le protocole est complet, mais il reste les décisions Q-2b-1 à Q-2b-7, dont un écart à la lettre de l'issue (Q-2b-1) et un budget au-delà du précédent de 3 h (Q-2b-2).
- **Résultat** :
  - percentile calibré : **à remplacer** (plancher structurel vérifié) ;
  - C1, I4 calibré : **à compléter** (mesure requise ; niveaux extrêmes) ;
  - C2, studentisé log avec écart-type interne : **candidat le plus pertinent** (mécanisme vérifié, effet supposé) ;
  - jackknife, BC, BCa, λ symétrique, warp-speed : écartés ;
  - protocole P1 à P11, critère et profils du § 4 écrits avant tout tirage ;
  - budget M1 : 7,8 à 10,9 h sur 4 processus.
- **Preuves** :
  - *Vérifiées* :
    - issue #610 et son commentaire ; plan de S6, Forme (vi) et étape 2b ; rapports 1b, 1c, 4 et 8 de S5 et la décision D2 (b) ; script `tests/couverture_ic_sigma_mw_t8.R` (l. 340-614) ; JOURNAL et T0 de #387 ;
    - relecture du monde de #387 sur 2 000 triangles par profil (filiation à 4·10⁻¹⁵ ; manque haut de I1 retrouvé) ;
    - chiffres du § 1.1 et coûts du § 1.2 (commandes `pilote2.R`, `ana.R`, `cout_imbrique.R`, md5 `2609c79a…`, `8bdbd95f…`, `f9a1d821…`) ; identité de la boucle interne avec `mw_bootstrap()` ;
    - sources lues ce jour en rendu graphique : Chang et Hall (arXiv:1408.6327v1, p. 1-3 et 5-9) ; McCarthy et al. (arXiv:1511.00273v3, p. 1-2 et 4-6, numérotation imprimée) ; Zrimšek et Štrumbelj (arXiv:2403.20182v3, p. 1, 8 et 16).
  - *Vérifiées par le dépôt, non relues par moi* : Davison et Hinkley (1997), (5.6), (5.10), (5.18), § 5.3.2, § 5.4.1 et tableau 5.8 (relevés R27.2 et S2.3) ; Efron et Tibshirani (1993), (14.14) (R27.5).
  - *Hypothèses* :
    - effet de la studentisation et risque de calibration insuffisante de C1 ;
    - bruit de ŝe\* selon B2 ;
    - débit 2,72-3,82 ;
    - coût par triangle simulé égal au coût mesuré sur des réplications de `reserve2` (précédent de #387 : coûts voisins entre triangles) ;
    - comportement sur trapèze.
  - *Non vérifiés* :
    - Davison et Hinkley, § 5.6 ; Beran ; Hall et Martin ; Booth et Hall ; Lee et Young ; DiCiccio et Efron ;
    - versions publiées des trois prépublications lues (j'ai lu les versions arXiv) ;
    - coût sur trapèze.
- **Informations manquantes** :
  - aucune source ne chiffre ces couvertures à T = 8 ;
  - `books.google.com`, `projecteuclid.org` et `www.ma.ic.ac.uk` sont refusés par le proxy de la session (403 sur le CONNECT). C'est un problème d'accès à la documentation, à traiter selon Q-63-10.
- **Décisions non résolues** : Q-2b-1 à Q-2b-7, par le mainteneur ; D3 après la mesure.
- **Critères déclenchés** :
  - écart à la lettre de l'issue (candidat remplacé, motif mesuré) ;
  - validité à T = 8 qu'aucun résultat exact ni aucune source ne tranche (inhérent, déclaré) ;
  - budget hors du précédent de #387 ;
  - aucun changement de résultat avant D3 ; si D3 restitue un candidat : contrat partagé, régénération de `reserve2` et coût de `run_engine()` multiplié par 2 à 4,5 ;
  - aucun désaccord avec `audit`, un autre agent ou un ADR.
- **Constats hors périmètre** :
  1. Le plancher du § 1.1 vaut aussi pour la note restituée. 19 % des triangles du monde de contrôle ont σ_A au-delà de tout σ\* : « borne haute dépassée » y est un manque massif, et pas seulement une étroitesse. La note de D2 (b) reste exacte. Critère : **aucun** (affirmation vraie ; nuance à verser à la lecture de 5c, pas d'issue).
  2. La filiation avec le brut de #387 n'est pas au bit (4·10⁻¹⁵), le moteur ayant changé depuis `e6547ad`. Critère : **aucun** (sans effet sur une classe).
- **Prochaine action recommandée** :
  1. La session verse ce rapport, annexe comprise, dans `docs/revues/20261120-s6-trapeze/`.
  2. Le mainteneur tranche Q-2b-1 à Q-2b-7.
  3. Étape 4 : `coder-approfondi` (`high`) écrit le script selon P1 à P11, lance `--essai` puis `--prevol` (coût par `run_engine()` compris) ; `audit` léger.
  4. Étape 5c selon M42, puis ma lecture avant D3.

## Annexe A. Pilote (relecture du monde de #387 ; graines de #387 ; aucun candidat calculé)

Commande : `LC_ALL=C.UTF-8 Rscript pilote2.R 2000 1` (puis `… 2000 2`). Corps (md5 `2609c79a5e17a297a91d2c0ae70a55ee`) :

```r
setwd("/home/user/outil_usp"); source("tests/outils_tests.R")
args <- commandArgs(TRUE); N <- as.integer(args[1]); P <- as.integer(args[2])
restreindre <- function(tri) { tri[row(tri) + col(tri) - 2L > nrow(tri) - 1L] <- NA; tri }
tri0 <- restreindre(.tri); aj0 <- mw_ajuster(tri0); jd0 <- .mw_colonnes_degenerees(aj0)
pool <- .mw_pool_residus(aj0, jd0); sdp <- sqrt(mean((pool - mean(pool))^2)); poolE <- pool / sdp
sigA <- sqrt(mw_msep(aj0)$msep) / aj0$reserve
tir <- switch(as.character(P), "1" = function(n) sample(poolE, n, replace = TRUE), "2" = function(n) stats::rnorm(n))
gen <- function(aj, tirer) { ... }   # copie de gen_triangle_h0() de #387, l. 382-402
boucle <- function(aj, B, seed, figes) engine_sous_graine(seed, { ... })  # boucle_allegee() de #387, l. 437-457
for (r in seq_len(N)) {
  tri <- engine_sous_graine(387000000 + 1000000 * (P - 1) + r, gen(aj0, tir))
  aj <- mw_ajuster(tri); sh <- sqrt(mw_msep(aj)$msep) / aj$reserve
  s <- boucle(aj, 999, 387500000 + 1000000 * (P - 1) + r, .mw_ensembles_figes(aj))$sig; s <- s[is.finite(s)]
  # u = mean(s <= sigA) ; v = mean(s <= sh^2/sigA) ; min(s), max(s), sd(log(s))
}
```

`ana.R` (md5 `8bdbd95f…`) compare σ̂ au brut de #387, compte σ_A > max σ\* et σ_A > σ̂²/min σ\* avec leurs IC de Clopper-Pearson, et calcule les quantiles de v et de z. `cout_imbrique.R` (md5 `f9a1d821…`) : 40 réplications externes de `reserve2` (graine 610 900 001, hors des plages de mesure), 199 tirages internes chacune (graines 610 950 001 et suivantes), identité avec `mw_bootstrap()`. Sorties brutes : `w_P1.tsv` (md5 `c0fe00d5…`) et `w_P2.tsv` (md5 `98d45ef4…`), dans `…/scratchpad/p610/` (versées dans `actuary-2b-pilote/`).

Sources consultées : [Chang et Hall, arXiv:1408.6327](https://arxiv.org/pdf/1408.6327) ; [McCarthy et al., arXiv:1511.00273](https://arxiv.org/pdf/1511.00273) ; [Zrimšek et Štrumbelj, arXiv:2403.20182](https://arxiv.org/pdf/2403.20182v3). Notices vues sans lecture du fond : [Booth et Hall (1994), notice](https://www.bohrium.com/paper-details/monte-carlo-approximation-and-the-iterated-bootstrap/812030175138021378-861) ; [DiCiccio et Efron (1996), Project Euclid](https://projecteuclid.org/euclid.ss/1032280214) (refusé par le proxy).

---

## Décisions du mainteneur du 20/11/2026 (questionnaire de la session principale, point d'arrêt D1')

- **Q-2b-1 (a)** : candidats C1 (I4 calibré par bootstrap imbriqué, queues séparées) et C2 (studentisé sur log σ, écart-type interne) ; C0 descriptif.
- **Q-2b-2 (a)** : niveau M1 (N = 1 000 par profil principal, B1 = 999, B2 = 199), budget de 12 h d'horloge sur 4 processus, règle du pré-vol (P7), tranches de 20 (M42 (b)).
- **Q-2b-3 (a)** : P1 et P2 principaux ; P3 descriptif seulement si le budget le permet ; P4 et P5 exclus, limite écrite.
- **Q-2b-4** : critère K-610-1 à K-610-4, profils Θ0 à Θ4, règle de préférence et modificateur W approuvés tels quels.
- **Q-2b-5 (a)** : rapport et annexe A versés ; chiffres du § 1.1 citables comme « relecture du monde de #387 ».
- **Q-2b-6 (a)** : aucune mesure de #610 sur trapèze dans S6, sauf si D2 étend #567 et D3 restitue un candidat.
- **Q-2b-7** : branche `claude/sauvegarde-610` autorisée d'avance si le pré-vol dépasse 2 h (ADR 0007, exécution selon M42).
