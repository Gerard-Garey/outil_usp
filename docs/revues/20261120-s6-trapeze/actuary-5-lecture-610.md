# S6, étape 5 (c), #610 : lecture de la mesure de couverture de C1 et C2 (Merz-Wüthrich, bootstrap imbriqué), préparation du point d'arrêt D3

> *Rédigé par l'agent actuary (IA).* Consultation en lecture seule sur `claude/merz-wuthrich-trapeze`, tête `425c1c9` (sorties commitées) ; commit mesuré `f573ddc`. Je n'ai rien écrit dans le dépôt : ni fichier, ni issue, ni commentaire. Petits calculs R à un processus sur le brut versé, scripts dans le dossier temporaire de la session (`…/scratchpad/l610/lire.R`, `diag.R`, `tiers.R`) ; aucun tirage.

## 0. Synthèse : options de D3 et recommandation

**Profil de lecture : Θ3**, obtenu par application stricte des règles fixées avant tirage (protocole 2b, § 4 ; réponses du 20/11). C1 et C2 sont chacun en **distorsion matérielle libérale** à 90 % sur P1 **et** sur P2, avec une marge de 0,09 à 0,15 entre l'IC de Clopper-Pearson et le bord haut de la bande (0,15). Aucun Θ0, aucun Θ4, aucun candidat éligible (Θ1), aucun « non tranché » (Θ2). La lecture fixée d'avance pour Θ3 est : **constat seul ; note inchangée ; fiche complétée par `docwriter`**.

| | Option de D3 | Coût mesuré par `run_engine(reserve2)` (pré-vol, `18836fd`) | Effet | Avis |
|---|---|---|---|---|
| **(a)** | **Constat seul** : ni C1 ni C2 dans `run_engine()` ; étape 6b sans objet ; Q-2b-6 (mesure sur trapèze) sans objet ; note de l'application inchangée ; constat porté au `.tex` à l'étape 8 ; #610 fermée par la fusion (`Closes #610` maintenu : ses cinq critères d'acceptation sont remplis) | aucun (16,1 s) | aucun résultat changé ; `reserve2.rds` inchangée | **recommandée** : c'est la lecture Θ3 fixée avant tirage |
| (b) | Restituer C1 et C2 (B2 = 199) en regard du percentile, malgré Θ3 | × 3,68 (16,1 s → environ 59 s ; +43,0 s) | champ nouveau de `bootstrap`, `reserve2.rds` régénérée par la CI, phrase d'affichage | **déconseillée** : contraire au profil fixé avant tirage ; couverture 0,67 à 0,73 pour 90 % ; sur P1, **moins bonne** que I4, qui n'est pas restitué (McNemar apparié, p ≈ 3·10⁻⁴) |
| (c) | Restituer C2 seul à B2 = 50 | × 1,77 (16,1 s → environ 28 s ; +12,3 s) | idem (b) | **déconseillée** : C2-50 est descriptif et lui aussi en distorsion libérale (0,327 sur P1, 0,271 sur P2) |
| (d) | Nouvelle mesure (R étendu, autre B, autre profil) | — | — | **exclue** par la règle « aucune extension de R après lecture » ; inutile vu les marges |

**Recommandation : (a).** La note actuelle de l'application (« aucun intervalle « basic » mesuré ne rétablit ce niveau ») reste vraie. Le double bootstrap n'y change rien : il ne rétablit pas non plus le niveau nominal. Ouvrir une piste méthodologique nouvelle serait hors #610 et demanderait une spécification et un protocole nouveaux. Je ne la recommande pas en l'état, faute de candidat fondé sur une source relue (§ 6).

## 1. Provenance et intégrité (vérifiées)

- md5 du script `tests/couverture_ic_sigma_mw_imbrique_t8.R` à la tête et à `f573ddc` : `725f005a…`, égal au JOURNAL. md5 de `R/engine.R` : `faf36c54…`, égal au JOURNAL. `git diff --stat f573ddc HEAD -- R/ tests/outils_tests.R <script>` est vide.
- md5 des sorties égaux à ceux du JOURNAL : `.md` `51fd2c4a…`, brut `de803ba3…`. md5 du protocole : `032a3948…`, égal au T0.
- K-610-3 : contrôles 1 à 11 OK, `INTEGRITE OK`. En particulier :
  - contrôle 7 : filiation avec #387 exacte, écart 0 ;
  - contrôles 3 et 4 : boucles externe et interne `identical()` à `mw_bootstrap()` sur 125 tranches sur 125 ;
  - contrôle 5 : écriture indépendante des bornes sur les 2 500 triangles, écart maximal 2,9·10⁻¹⁵.
- **Recalcul indépendant** (`lire.R`, sur le brut, σ_A = 0,02182451066). Pour les 3 profils × 7 intervalles × 2 niveaux, j'ai recalculé τ̂, l'IC de Clopper-Pearson, la classe et les deux queues avec leurs classes : **identiques au tableau versé** (T1, T2). Aucune borne n'est à moins de 10⁻⁸ en relatif de σ_A : aucun cas d'égalité ne peut faire basculer une couverture.
- Mesure faite en six segments de 90 min avec reprise (M42 (b)), contexte identique dans les 125 tranches. Le coût médian, 51,0 s par triangle, est conforme au pré-vol (53 s prévus).

## 2. Application des règles fixées avant tirage (ordre du protocole : Θ0, Θ4, Θ1 à Θ3, puis W)

| Étape | Condition (texte du § 4) | Constat (T7, T1) | Résultat |
|---|---|---|---|
| Θ0 | K-610-3 en défaut ; ou, sur P1 ou P2, refus, triangles sans intervalle ou b exclues au-delà de 1 % (trois taux séparés, règle 5) | K-610-3 rempli ; refus 0/1 000, sans intervalle 0/1 000, b exclues 0/999 000 sur P1 et sur P2 | non déclenché |
| Θ4 | un candidat en distorsion de côtés opposés entre P1 et P2 | C1 et C2 en distorsion libérale sur P1 et P2 (même côté) | non déclenché |
| Θ1 | C1 ou C2 compatible ou en écart mineur sur P1 **et** P2 | aucun | aucun candidat éligible |
| Θ2 | aucun éligible, au moins un « non tranché » sur P1 ou P2 | aucun « non tranché » (K-610-4 : aucun IC ne touche un bord) | non applicable |
| **Θ3** | C1 et C2 chacun en distorsion matérielle sur au moins un profil principal, sans Θ4 | C1 et C2 chacun en distorsion sur les deux | **retenu** |
| Préférence (i), (ii) | sous Θ1, si deux éligibles | — | sans objet |
| W | sous Θ1, pour le candidat retenu | — | sans objet. À titre descriptif, la saturation haute de C1 à 90 % vaut 0,293 (P1) et 0,238 (P2), au-delà de 1 % : C1 aurait relevé de W-b s'il avait été éligible |

Aucune règle n'est ajoutée ni modifiée. Les comparaisons appariées du § 4 sont des **compléments descriptifs** que j'ajoute à la lecture : elles n'entrent dans aucun profil.

## 3. Lecture par profil (cible σ_A ; IC de Clopper-Pearson à 95 %)

### 3.1 Critère principal K-610-1 (90 %, ρ = 0,10, bande [0,05 ; 0,15])

| Profil | Intervalle | couverture | τ̂ [IC] | manques bas / haut | classe |
|---|---|---|---|---|---|
| P1 (loi E) | C1 | 0,671 | 0,329 [0,300 ; 0,359] | 0,036 / 0,293 | distorsion matérielle libérale |
| P1 (loi E) | C2 | 0,669 | 0,331 [0,302 ; 0,361] | 0,046 / 0,285 | distorsion matérielle libérale |
| P2 (loi N) | C1 | 0,729 | 0,271 [0,244 ; 0,300] | 0,044 / 0,227 | distorsion matérielle libérale |
| P2 (loi N) | C2 | 0,719 | 0,281 [0,253 ; 0,310] | 0,055 / 0,226 | distorsion matérielle libérale |

Écart entre la borne basse de l'IC et le bord haut de la bande : 0,150 et 0,152 (P1), 0,094 et 0,103 (P2). Aucune taille d'échantillon raisonnable ne changerait la classe.

### 3.2 Descriptif K-610-2

- **Références I1 et I4 sur graines nouvelles** :
  - I1 : P1 0,591 et P2 0,600 à 90 % ; I4 : P1 0,702 et P2 0,718.
  - Classes identiques à celles de #387 : distorsion libérale, avec des IC qui se recoupent (T3). La relecture du monde de #387 est donc reproduite sur graines nouvelles.
- **95 %** : C1 et C2 couvrent de 0,78 à 0,80 (P1, P2) ; distorsion libérale partout. Les manques hauts, de 0,165 à 0,199, sont à comparer à ρ/2 = 0,025.
- **Queues séparées** : seul gain des candidats, et il est réel.
  - La queue basse, en distorsion **conservatrice** pour I1 (0 manque), devient compatible ou en écart mineur pour C1 et C2 (0,036 à 0,055 à 90 %).
  - La **queue haute reste en distorsion libérale** (0,23 à 0,29 contre 0,05) et porte tout le défaut.
- **σ_B** (T4) : mêmes classes partout.
- **P3** (loi A, N = 500, descriptif) : C1 0,710, C2 0,690 ; même classe. Le constat ne dépend donc pas de la loi d'erreurs parmi E, N et A.
- **Variantes C1-99 et C2-50** : τ̂ à moins de 0,010 de C1 et C2 sur les mêmes triangles (P1 : 0,320 contre 0,329 et 0,327 contre 0,331 ; P2 : 0,269 contre 0,271 et 0,271 contre 0,281).
- **Largeur** : C1 et C2 sont 1,28 à 1,33 fois plus larges que I1 et environ 1,13 fois plus larges que I4 (médianes), sans gain de couverture sur I4.
- **Reproduction du § 1.1** (T6) : σ_A > max σ\* dans 0,187 (P1) et 0,181 (P2) des triangles. Le plancher du percentile, calibré ou non, est confirmé : sur P1, 0,1870 [0,1633 ; 0,2126], au-dessus de 0,15.

## 4. Pourquoi le double bootstrap ne corrige pas : diagnostics complémentaires (descriptifs, calculés sur le brut)

*Vérifié* par commande (`diag.R`, `tiers.R`) :

1. **Comparaison appariée avec I4** (90 %, mêmes triangles ; McNemar exact sur les paires discordantes) :
   - P1 : C1 manque 51 triangles que I4 couvre, et n'en couvre que 20 que I4 manque (p = 3,0·10⁻⁴) ; pour C2, 55 contre 22 (p = 2,2·10⁻⁴). **C1 et C2 sont moins bons que I4 sur P1.** Le résultat tient encore sous une correction de Bonferroni pour les six comparaisons.
   - P2 : 25 contre 36 et 37 contre 38 (p = 0,20 et 1) ; aucune différence détectée, ce qui n'établit pas une équivalence.
2. **Où tombent les manques hauts** :
   - Tous les manques hauts de C2 surviennent pour σ̂/σ_A ≤ 0,84 (P1) et ≤ 0,79 (P2, P3). C'est le tiers bas, celui où σ̂ sous-estime le plus.
   - Parmi les manques, la médiane de σ_A/borne haute vaut 1,11 (P1) et 1,15 (P2). Le manque n'est donc pas marginal.
3. **La calibration élargit là où ce n'est pas utile** :
   - La saturation haute de C1 (Q_w(α) = 0, borne haute portée à σ̂²/min σ\*) ne survient jamais sur un triangle manqué : 0 manque parmi 293 saturés (P1), 0 parmi 238 (P2). La médiane de σ̂/σ_A des triangles saturés vaut 1,13 (P1) et 1,08 (P2), contre 0,78 et 0,79 pour les non saturés.
   - Largeur logarithmique médiane dans le tiers haut de σ̂/σ_A : I4 0,92, C1 1,21, C2 1,40 (P1). Dans le tiers bas : 0,49, 0,47 et 0,45. Les candidats s'élargissent là où σ̂ surestime, et pas là où il sous-estime.
   - cor(log σ̂, log(borne haute de C2/σ̂)) = 0,80 (P1) et 0,65 (P2) : la marge haute relative croît avec σ̂.
4. **Interprétation** (*hypothèse*, cohérente avec les faits 2 et 3). Le bootstrap de second niveau estime l'erreur de couverture au point θ̂ du triangle observé, et non au point θ. À T = 8, θ̂ est loin de θ : σ̂/σ_A va de 0,62 à 1,27 entre les quantiles 5 % et 95 % sur P1. La dispersion bootstrap dépend du niveau de σ̂. Un triangle à σ̂ bas engendre donc un monde de second niveau lui aussi « étroit », qui ne signale pas l'insuffisance. La non-pivotalité relevée en #387 subsiste au second niveau. C'est le risque écrit au § 2.1 du protocole (« calibration insuffisante si la non-pivotalité persiste au second niveau ») : la mesure le confirme ; le mécanisme reste une hypothèse.

## 5. Erreurs à distinguer

- **Erreur Monte-Carlo en N** (nombre de triangles) : demi-largeur des IC de Clopper-Pearson d'environ 0,03 (N = 1 000). Elle est petite devant l'écart à la bande (0,09 à 0,15) : les classes ne dépendent pas de N.
- **Erreur Monte-Carlo en B1 et B2** :
  - B2 n'est pas isolé, mais l'effet est éclairé par C1-99 et C2-50 : moins de 0,010 sur τ̂. Ce n'est pas ce qui produit la distorsion.
  - B1 = 999 n'a pas varié. Les quantiles extrêmes de C1 reposent sur les 2 à 20 premières statistiques d'ordre des σ\*, mais aucun triangle saturé (borne à min σ\*) n'est manqué.
  - Rien n'indique qu'un B plus grand changerait la classe (*hypothèse* pour B1).
- **Erreur d'approximation en T** : c'est l'objet mesuré. À T = 8, l'erreur de couverture de la procédure entière vaut de +0,17 à +0,23 au-dessus du nominal (90 %, P1 et P2). Elle ne décroît pas avec B. Les ordres asymptotiques du double bootstrap (Chang et Hall, 2014, cités au protocole) ne disent rien de sa valeur à T = 8, et aucune source relue ne la chiffre.
- **Erreur de substitution** (modèle ajusté au lieu de la vérité) : non quantifiée. La même classe sous E, N et A en atteste seulement la stabilité pour la loi d'erreurs.

## 6. Options de D3 : détail

**(a) Constat seul — recommandée.**
- Conforme à la lecture Θ3 approuvée avant tirage (Q-2b-4).
- Étape 6b sans objet. Q-2b-6 (a) sans objet : la mesure sur trapèze n'était prévue que si D3 restituait un candidat.
- Aucun résultat changé ; `reserve2.rds` et coût de `run_engine()` inchangés.
- Note de l'application inchangée : son texte, l. 2540-2544 de `R/display_helpers.R`, reste vrai.
- À l'étape 8, `docwriter` complète la fiche (`fiche:ic-bootstrap` sans marge : hors de la fiche ou pagination contrôlée, selon le plan) et la phrase du `.tex` l. 14591-14593 (« aucun « basic » mesuré ne rétablit ce niveau ») avec les éléments du § 7.
- #610 : ses cinq critères d'acceptation sont remplis : protocole avant tirage (contrôle 9), `INTEGRITE OK`, classes à 90 % avec Clopper-Pearson, coût par `run_engine()` mesuré au pré-vol, aucun σ_USP, aucune p-value ni aucun verdict changé. Elle peut donc être fermée par la fusion sur le constat versé.
- Variante (a') : élargir la note de l'application à « aucun intervalle mesuré (« basic », calibré ou studentisé par bootstrap imbriqué) ne rétablit ce niveau ». C'est un commit `app:` et un passage d'`app-review`, alors que Θ3 dit « note inchangée ». **Non recommandée** : la note renvoie déjà à la fiche, qui portera le détail.

**(b) Restituer C1 et C2 à B2 = 199 — déconseillée.**
- Coût mesuré au pré-vol : +43,0 s pour 16,1 s, soit × 3,68 par appel de `run_engine(reserve2)`, à multiplier dans les batteries et dans la régénération CI de `reserve2`.
- Elle afficherait sous le libellé « 90 % » un intervalle qui couvre environ 0,7, plus large que I4 et, sur P1, moins bon que lui en apparié.
- Elle irait contre la lecture Θ3 fixée d'avance. Elle exigerait aussi la mesure sur trapèze de Q-2b-6 (a) si D2 étend #567.

**(c) Restituer C2 seul à B2 = 50 — déconseillée.**
- × 1,77 (+12,3 s).
- Mêmes objections. De plus, C2-50 n'est que descriptif (réponses du 20/11, point 6).

**(d) Mesure complémentaire — exclue** par le critère : « aucune extension de R après lecture ».

**Hors D3, pour information.** Le défaut que #610 visait (critère G, majeur : la seule mesure restituée de l'incertitude de σ_USP en Merz-Wüthrich couvre environ 0,6 pour 0,9) **subsiste**. Il est déclaré dans la note et dans le `.tex`, sans affirmation fausse. Je ne connais aucun candidat, fondé sur une source relue, qui le corrige à T = 8. Une piste nouvelle relèverait d'une issue nouvelle, d'une spécification et d'un protocole avant tirage (circuit 1), sur décision du mainteneur. Je ne la propose pas.

## 7. Éléments pour la fiche (étape 8, `docwriter`), sous Θ3

- Candidats mesurés : C1, I4 calibré par bootstrap imbriqué, queues séparées ; C2, studentisé sur log σ avec écart-type interne ; B1 = 999 et B2 = 199. Fondements tels qu'au protocole (§ 2.1, § 2.2), en indiquant que l'application de la calibration à chaque borne est une construction du dépôt.
- Couverture à 90 % : C1 0,671 (E) et 0,729 (N) ; C2 0,669 (E) et 0,719 (N). N = 1 000 par loi, IC de Clopper-Pearson, distorsion matérielle libérale ; à 95 % : 0,78 à 0,80.
- Les manques sont tous ou presque au-dessus de la borne haute. La queue basse est ramenée au voisinage du nominal.
- Le double bootstrap ne rétablit pas le niveau nominal. Le percentile calibré est exclu par construction : σ_A dépasse le maximum des σ\* dans environ 19 % des triangles.
- Statut : constat de simulation sous le modèle ajusté au triangle de contrôle, conditionnel à R̂ > 0 et R\* > 0. Clopper-Pearson ne mesure que l'erreur de simulation en N, rien de l'erreur en T.
- Aucun nombre dans la note de l'application.

## 8. Limites

- La mesure ne porte que sur le triangle de contrôle (P4 volatil non mesuré, portée écrite d'avance) et sur des carrés 8×8. Sur un trapèze, rien n'est mesuré (Q-2b-6 (a)).
- Effet de B1 non isolé.
- Les diagnostics du § 4 sont des analyses descriptives que j'ajoute après lecture. Ils n'entrent dans aucune règle et ne modifient aucune classe. Le McNemar est une analyse *post hoc*.
- Sources non relues, déjà signalées au protocole : Davison et Hinkley (1997), § 5.6, entre autres. Problème d'accès à la documentation (Q-63-10).

## Retour

- **Statut** : `revue requise`. La lecture est complète, et D3 revient au mainteneur.
- **Résultat** :
  - profil **Θ3** ;
  - C1 et C2 : **fragiles, à ne pas restituer** (distorsion libérale à 90 % sur P1 et P2, IC disjoints de la bande) ;
  - D3 recommandé : **(a) constat seul**.
- **Preuves** :
  - *vérifiées* :
    - md5 et SHA de provenance ;
    - recalcul indépendant des classes de T1 et T2 sur le brut (`lire.R`) ;
    - diagnostics appariés et par tiers (`diag.R`, `tiers.R`) ;
    - coûts du pré-vol (message de `18836fd` ; `COUT_PREVOL`, l. 242 du script) ;
    - texte de la note (`R/display_helpers.R` l. 2540-2544) et du `.tex` (l. 14591-14593) ;
    - critères d'acceptation de #610 (`mcp__github__issue_read`) ;
  - *hypothèses* : mécanisme du § 4 (point 4) ; absence d'effet d'un B1 plus grand ;
  - *non vérifiés* : Davison et Hinkley, § 5.6, et les autres sources listées au protocole.
- **Informations manquantes** : aucune pour D3.
- **Décisions non résolues** : D3, par le mainteneur ; libellé de #610 et fermeture par la fusion, par la session après D3.
- **Critères déclenchés** :
  - validité à T = 8 tranchée par simulation seulement (inhérent, déclaré) ;
  - aucun changement de résultat sous (a) ; sous (b) ou (c), changement de résultat hors σ_USP et contrat partagé (`bootstrap`, régénération de `reserve2`) ;
  - aucun désaccord avec `audit`, un autre agent ou un ADR ;
  - aucune double lecture d'une source.
- **Constats hors périmètre ou mineurs** (ADR 0018) :
  1. Dans T5 de la sortie `.md`, la ligne « P1 : bornes des tiers … » est insérée entre l'en-tête et les lignes du tableau (script l. 1516). En Markdown GitHub, le tableau est donc rompu : seul le rendu est touché, les valeurs restent justes et le brut suffit. Dans le périmètre de #610, mais la sortie n'est jamais patchée (P10). Critère : **aucun** (mineur) ; à corriger dans le script seulement si une nouvelle mesure est lancée.
  2. Le texte de Θ3 cite la note sous la forme « aucun intervalle mesuré ne rétablit ce niveau », alors que la note dit « aucun intervalle « basic » mesuré ». C'est une paraphrase du protocole ; la note reste vraie. Critère : **aucun**.
- **Prochaine action recommandée** :
  1. La session verse cette lecture dans `docs/revues/20261120-s6-trapeze/`.
  2. Le mainteneur tranche D3 ; je recommande (a).
  3. Sous (a) : étape 6b sans objet ; constat de #610 porté au `.tex` par `docwriter` à l'étape 8 ; ma validation du diff à l'étape 9.


## Décision du mainteneur au point d'arrêt D3 (20/11/2026)

Option **(a), constat seul** : aucune restitution de C1 ni de C2 dans `run_engine()` ; étape 6b sans objet ; mesure sur trapèze (Q-2b-6 (a)) sans objet ; note de l'application inchangée ; constat porté au `.tex` à l'étape 8 (éléments du § 7 de cette lecture) ; `Closes #610` maintenu.
