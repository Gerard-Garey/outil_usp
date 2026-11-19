> *Versé intégralement par la session principale le 19/11/2026 (`actuary-approfondi`, lecture de la mesure de #387, préparatoire au point d'arrêt D2).*

> *Rédigé par l'agent actuary (IA).* S5, étape 4, #387 : lecture de la mesure de couverture à T = 8 de l'intervalle bootstrap de σ en Merz-Wüthrich, préparatoire au point d'arrêt D2. Consultation en lecture seule sur `claude/bootstrap-merz-wuthrich` (tête `444f96c`). Je n'ai rien écrit dans le dépôt : ni fichier, ni issue, ni commentaire. Mon seul script, une décomposition descriptive du fichier brut, est resté dans le dossier temporaire de la session (`decomp387.R`).

Les sorties sont dans `docs/tableaux/` : `20261119-issue387-couverture-ic-sigma-mw.md`, `…-brut.tsv` et `…-journal-mesure.md`.

## 0. Synthèse

- **Profil Ω3 confirmé**, Λ1 confirmé, V sans objet.
- **Cause de la sous-couverture sur P1 et P2.**
  - **Cause principale : le biais de σ̂ vers le bas** (médiane σ̂/σ_A = 0,845). Le bootstrap d'un triangle simulé ordinaire n'en reproduit qu'environ la moitié : la loi de σ*/σ̂ n'est pas pivotale.
  - **Cause secondaire : un intervalle trop étroit.** Sur l'échelle logarithmique, son étendue vaut environ 0,83 fois l'étendue réelle.
  - **Le choix de la cible n'y est pour rien** : σ_B/σ_A ≈ 0,99, et la couverture de σ_B ne gagne que 1,5 à 2 points.
- **Recommandation pour D2 : option (b).** Requalifier la note et proposer une issue pour étudier un autre intervalle, hors S5.
- **Visa d'exécution : accordé**, avec deux réserves mineures.

## 1. Lecture actuarielle

### 1.1 Couverture (T1 à T3)

Mesuré :
- **I1 à 90 %** : 0,573 [0,551 ; 0,595] sur P1 et 0,617 [0,595 ; 0,638] sur P2.
- **I2 à 90 %** : 0,596 et 0,640.
- **I4 à 90 %** : 0,692 et 0,733.
- **P3** (loi asymétrique, descriptif) : 0,518, 0,552 et 0,657.
- **À 95 %**, tous les intervalles restent en distorsion matérielle libérale. Le meilleur est I4 sur P2, à 0,816.
- **K-M5** : aucun intervalle de Clopper-Pearson ne touche un bord de la bande. Le classement ne dépend pas de l'erreur de Monte-Carlo en N (demi-largeur d'environ 0,02).

Comparaison avec la lognormale (#305) : le percentile y couvrait 0,710 et 0,639, et I4 0,895 et 0,886. En Merz-Wüthrich, le percentile est un peu plus mauvais, et surtout **I4 ne rétablit pas le niveau**.

### 1.2 Queues séparées : quel côté manque (T3)

Mesuré : la non-couverture vient presque entièrement du **côté haut**. σ_A est au-dessus de la borne haute.

| Intervalle | Profil | Sous la borne basse | Au-dessus de la borne haute |
|---|---|---|---|
| I1 à 90 % | P1 | 0,000 | 0,427 |
| I1 à 90 % | P2 | 0,000 | 0,383 |
| I4 à 90 % | P1 | 0,0145 | 0,294 |
| I4 à 90 % | P2 | 0,019 | 0,2485 |

- La queue basse est en distorsion **conservatrice** pour I1 et I2.
- Elle est non tranchée ou conservatrice pour I4.
- Le schéma est le même qu'en lognormale : « borne haute dépassée ».

### 1.3 Biais de σ̂ et position de σ̂ dans σ* (T6, plus ma décomposition)

**Mesuré dans T6.**
- Médiane de σ̂/σ_A : 0,845 (P1), 0,845 (P2), 0,790 (P3).
- Moyenne de σ̂/moyenne(σ*) : 1,055, 1,053 et 1,051.
- Rang médian de σ̂ dans σ* : 0,60.

**Mesuré par moi sur le brut** (*vérifié*, commande exécutée ; hors des sorties versionnées) :
- Moyenne de σ̂/σ_A : 0,891 (P1) et 0,874 (P2).
- P(σ̂ < σ_A) : 0,71 et 0,76.

**Sur le triangle de contrôle lui-même** (`reserve2.rds`, *vérifié*) :
- La loi bootstrap σ*/σ̂ a une moyenne de 0,887, une médiane de 0,845 et P(σ* < σ̂) = 0,713.
- Ses quantiles à 5 % et à 95 % valent 0,613 et 1,264.
- C'est presque exactement la loi de σ̂_r/σ_A sur P1 : 0,891, 0,845, 0,706, 0,614 et 1,269. Le contrôle de cohérence de la simulation est donc tenu.
- En revanche, sur un triangle simulé ordinaire, le bootstrap ne voit qu'environ 5 % de biais en moyenne (1/1,055), avec un rang de 0,60, contre environ 11 % et 0,71 sur le triangle générateur.

**Interprétation** (*hypothèse* étayée par ces chiffres) :
- Le biais relatif de σ̂ dépend du triangle : la loi de σ*/σ̂ n'est pas pivotale.
- Les intervalles réfléchis (I2, I4) corrigent le biais que *voit* le bootstrap du triangle observé. Ce biais est environ la moitié du biais réel. D'où l'échec de I4, qui réussissait en lognormale, où le biais bootstrap (11,2 et 13,9 %) suivait le biais réel (E[σ̂]/σ0 = 0,902 et 0,871).
- Mécanisme probable, non isolé par la mesure (*hypothèse*) : des estimateurs de variance par colonne à très peu de degrés de liberté, plus l'extrapolation du dernier σ², passés à la racine.

### 1.4 Intervalle trop étroit ? (T3, plus ma décomposition)

Mesuré :
- Largeur médiane / σ_A : I1 0,480 (P1) et 0,496 (P2) ; I4 0,539 et 0,570.
- I4 est donc plus large que I1 d'environ 12 à 15 %, contre 46 % en lognormale.
- Étendue à 90 % de σ̂/σ_A entre triangles : 0,655 et 0,680.
- Sur l'échelle logarithmique, l'étendue médiane du bootstrap, log(q95*/q05*), vaut 0,612 et 0,634. L'étendue réelle de log(σ̂/σ_A) vaut 0,726 et 0,772. Le rapport est d'environ 0,84 et 0,82 (*vérifié*, ma commande).

### 1.5 Part de chaque cause (exploratoire, a posteriori, hors critère, aucune classe changée)

- **Biais.** Avec pour cible la médiane des σ̂, qui neutralise le biais médian par construction, I1 couvrirait 0,84 (P1) et 0,83 (P2) à 90 %. Le biais explique donc environ les trois quarts de l'écart sur P1 (27 points sur 33), et 21 points sur 28 sur P2.
- **Étroitesse.** Le reste, de 6 à 7 points, revient à l'étroitesse et à la forme de l'intervalle.
- **Portée.** Cette décomposition n'est pas additive. Ce n'est la couverture d'aucun paramètre, seulement un éclairage.
- **Concentration.** Par tiers de σ̂/σ_A, I1 couvre 0,03, 0,69 et 1,00 sur P1 : l'intervalle suit σ̂, et manque dès que σ̂ est bas.

### 1.6 Cible : couverture de σ_B (T4)

- Mesuré : σ_B/σ_A vaut entre 0,975 et 1,004 (quantiles à 5 % et à 95 %, ma commande). La corrélation entre log σ̂ et log σ_B est quasi nulle.
- Mesuré : la couverture de σ_B ne gagne que de 1,5 à 2 points (I1 à 90 % : 0,590 et 0,636), dans les mêmes classes.
- **La cible σ_A n'explique pas la sous-couverture.** La convention σ_A reste une *hypothèse de modélisation* : le règlement définit σ par son estimation, sans analogue en population. Mais toute cible proche de σ(f0, σ0²) donne le même tableau.
- La moyenne des σ̂ comme cible ne sauve rien non plus : 0,76 et 0,80.

### 1.7 Profil volatil, P4 et P5 (T2, T5, T7)

**Mesuré.**
- Couverture à 90 % sur P4 : I1 0,537, I2 0,125, I4 0,380.
- I2 a une borne basse ≤ 0 sur 834 triangles admis sur 1 016 : il n'a pas de sens sur ce profil.
- Médiane de σ̂/σ_A : 0,20.
- Ma commande : R̂ médian des triangles admis 609, contre R0 = 158,6 au générateur.

**Interprétation** (*hypothèse* argumentée) :
- σ = √MSEP/R est proche de sa singularité. L'admission (R̂ > 0) retient surtout des R̂ grands, donc des σ̂ petits.
- σ_A n'est pas représentatif de sa propre population admise.
- K-M2 ne juge donc pas la qualité de l'intervalle seule.

**Strates de π̂ (T5).**
- Mesuré : la couverture **croît** avec π̂. Pour I1 à 90 % sur P4, elle vaut 0 (π̂ = 0), 0 (]0 ; 0,05]), 0,51 (]0,05 ; 0,20]) et 0,99 (> 0,20).
- Mesuré, ma commande : le R̂ médian par strate vaut 1 269, 969, 712 et 249.
- π̂ suit donc la proximité de R̂ à 0, c'est-à-dire du régime du générateur.
- **Aucun élément ne fonde un seuil de retrait sur π̂** (option (b) de 1a) : il retirerait précisément les triangles où l'intervalle couvre.

### 1.8 Volet A.5 (ii) : Λ1 (T8)

Vérifié par relecture des tableaux :
- **K-V1** : 26 classes, dont 24 compatibles et 2 en écart mineur (ExpVar à 0,10 ; Alpha à 0,05).
- **K-V2** : aucun McNemar significatif. La plus petite p brute vaut 0,125, et la p de Holm vaut 1 partout.
- **K-V3** : aucun signal. La plus petite p de Holm binomiale vaut 0,149.
- **K-V4** : 0 p absente.

Portée :
- Un seul profil (fixture, loi E), 1 016 triangles.
- Les écarts de moins d'environ 2 points ne sont pas détectables (demi-largeur de Clopper-Pearson d'environ 0,018).
- Le McNemar repose sur 1 à 9 paires discordantes : une non-détection n'est pas une équivalence.

## 2. Proposition pour D2 (Ω3)

### 2.1 Texte exact de la note de `textes_ic_bootstrap()`, branche `reserve2`

Il remplace « Couverture à T = 8 non mesurée pour cette méthode. » :

> « Niveaux nominaux. À T = 8, sous les modèles ajustés à deux triangles, l'intervalle de percentile couvre nettement moins que son niveau nominal (σ sous-estimé, borne haute dépassée) ; aucun intervalle « basic » mesuré ne rétablit ce niveau. Constat de simulation : voir la documentation, fiche de l'intervalle bootstrap. »

- **Compatibilité avec #492.** Quand k > 0, la note devient : phrase conditionnelle, puis « … : {k} sur B = {B}. », puis le texte ci-dessus. Les deux énoncés restent vrais ensemble : la sous-couverture est mesurée sans réplication écartée (P1, P2, π̂ = 0) comme avec (P4).
- **Variante plus étroite**, si le mainteneur ne veut citer que le critère principal : « sous le modèle ajusté au triangle de contrôle ».
- **Aucun nombre** dans la note, comme en lognormale : les chiffres vont dans la fiche.
- **Le libellé « niveau nominal 90 % » de la ligne reste tel quel.** Le remplacer par une couverture mesurée serait faux ailleurs : 0,54 à 0,62 selon le plan et la loi.

Effets sur le code (étape 4b refondue ; pas de régénération, `res` est inchangé) :
- commit `app:` : la note, plus les commentaires de `display_helpers.R`, l. 2514-2524 ;
- commit `tests:` : `NOTE_MW` (`tests/unitaires/test_incertitude_bootstrap.R:412`) et `NOTE_MW_492` (`tests/unitaires/test_sans_sigma_mw.R:180`). Le critère A.7 (6) de 1a, « note identique à celle de `e4a8ae4` », devient caduc ;
- commit `moteur:` limité aux commentaires : `R/engine.R` l. 12857 (« couverture non mesuree, #387 ») et l. 18116. L'empreinte #231 ne change pas ;
- revue par `app-review`.

### 2.2 Options du mainteneur

| Option | Contenu | Avis |
|---|---|---|
| (a) | note requalifiée seulement | exacte, minimale ; laisse sans suite un défaut majeur mesuré |
| **(b) recommandée** | note requalifiée, plus une issue proposée pour un autre intervalle, hors S5 (périmètre au plafond) | conforme à Ω3 approuvé ; même traitement qu'en lognormale (percentile conservé et qualifié) |
| (c) | intervalle Merz-Wüthrich retiré | change le contrat (`ic_bootstrap`, graphique, régénération de `reserve2`), contraire au précédent lognormal, supprime la seule mesure de dispersion ; déconseillé |
| (d) | I4 affiché en regard malgré tout | meilleur que I1 de 10 à 12 points sur P1 et P2, mais en distorsion, et pire sur P4 (0,38) ; contraire à Ω3 ; déconseillé |

### 2.3 Corps de l'issue proposée (non créée ; libellés `enhancement`, `needs-triage`)

**Titre** : `tests/moteur: intervalle de σ en Merz-Wüthrich à couverture proche du nominal à T = 8 (percentile mesuré à 0,57-0,62 pour 90 %)`

> *Rédigé par l'agent actuary (IA).*
>
> **Constat (mesure de #387, `docs/tableaux/20261119-issue387-couverture-ic-sigma-mw.md`, moteur `e6547ad`).**
> - À T = 8, sous le modèle de Mack ajusté au triangle de contrôle, l'intervalle de percentile de σ couvre 0,573 (loi E) et 0,617 (loi N) pour un niveau nominal de 90 %, tous les manques étant au-dessus.
> - Les intervalles « basic » (0,596 et 0,640) et « basic » logarithmique (0,692 et 0,733) restent en distorsion matérielle libérale.
> - C'est un constat de simulation, conditionnel à l'admission (R̂ > 0).
>
> **Cause mesurée.**
> - σ̂ est biaisé vers le bas : médiane de σ̂/σ_A 0,845.
> - Le bootstrap d'un triangle simulé n'en reproduit qu'environ la moitié : σ̂/moyenne(σ*) vaut 1,055, contre environ 1,13 sur le triangle de contrôle.
> - Toute correction de biais au premier niveau (réflexion) est donc insuffisante.
> - L'étendue logarithmique du bootstrap vaut environ 0,83 fois l'étendue réelle.
>
> **Objet.**
> 1. `actuary` spécifie, sources relues, un ou deux intervalles candidats qui tiennent compte de cette non-pivotalité : calibration du niveau nominal par bootstrap imbriqué (double bootstrap), ou intervalle studentisé sur log σ avec une variance interne par bootstrap imbriqué ou par jackknife. Aucune source relue par le dépôt n'en chiffre la couverture à T = 8. La section « Double Bootstrap Methods » du chapitre 5 de Davison et Hinkley (1997) a été repérée dans une table des matières, sans être relue : elle est à relire avant toute spécification, et ne peut pas être citée en l'état.
> 2. La couverture est mesurée avec le plan, les graines disjointes et le critère de #387, fixé avant l'exécution.
> 3. Point de décision du mainteneur : restitution en regard du percentile, jamais à sa place (Q-42-10).
>
> **Critères d'acceptation.**
> - Protocole et critère écrits avant tout tirage.
> - `INTEGRITE OK`.
> - Classes de couverture à 90 % sur P1 et P2, avec intervalles de Clopper-Pearson.
> - Coût par `run_engine()` mesuré.
> - Aucun σ_USP, aucune p-value ni aucun verdict changé.
>
> **Hors périmètre** : σ_USP, p-values, verdicts ; méthode lognormale ; seuil sur `n_sans_sigma`, que la mesure ne fonde pas.
>
> **Coût.** Estimation fondée sur la boucle allégée mesurée en 1b (0,39 s pour B = 999), *hypothèse* : environ 390 s par triangle pour un double bootstrap 999 × 999, environ 80 s avec un B interne de 199. Une mesure sur 2 000 triangles demande quelques dizaines d'heures de calcul sur 4 processus.
>
> **Impact sur les résultats** : aucun jusqu'à la décision ; si un intervalle est restitué, contrat partagé et régénération de `reserve2`.
>
> **Critère ADR 0018 : G**, gravité majeure sur l'échelle d'`actuary`. La seule mesure restituée de l'incertitude de σ_USP en Merz-Wüthrich couvre environ 0,6 pour 0,9. E1 à E4 et E6 ne sont pas remplis. E5 ne l'est plus une fois la note requalifiée.

Aucun doublon trouvé : recherche REST sur « bootstrap intervalle », « BCa », « double bootstrap » et « couverture ». #246 porte sur les p-values, pas sur l'intervalle.

## 3. Ce que `docwriter` devra écrire (fin de branche, sans nouvelle référence)

Seuls les chiffres des sorties versionnées (T1 à T8) et de `reserve2.rds` déjà cités vont dans le `.tex`. Mes chiffres exploratoires (étendue logarithmique, cible médiane) n'y vont pas, sauf si la session les verse avec leur script.

1. **`fiche:ic-bootstrap`, rubrique Cadre** (l. 14387-14393). Appliquer A.4 (2) de #492 (restitution de `n_sans_sigma`). Remplacer « sa couverture n'est pas mesurée ; restituer … postérieur à la remise » par : couverture mesurée à T = 8, nettement inférieure au nominal, aucun intervalle « basic » restitué.
2. **`fiche:ic-bootstrap`, rubrique Loi**, nouveau paragraphe « Couverture à T = 8, méthode Merz--Wüthrich », après celui de la lognormale :
   - script et sortie ;
   - plan : triangle de contrôle (lois E, N, A) et triangle volatil versionné (E, N) ;
   - cible σ_A par convention, motif écrit, et σ_B descriptive ;
   - critère identique à celui de la lognormale ;
   - tableau de I1, I2 et I4 à 90 % (avec intervalles de Clopper-Pearson) et à 95 %, sur P1, P2 et P4 ;
   - lecture : tous en distorsion libérale, manques au-dessus, médiane de σ̂/σ_A 0,845 ; biais vu par le bootstrap d'environ 5 % sur un triangle simulé (T6, 1,055) contre 11,3 % sur le triangle de contrôle (valeur déjà au `.tex`), d'où l'échec de la réflexion (*hypothèse* de non-pivotalité) ; σ_B dans les mêmes classes ;
   - triangle volatil : couverture croissante avec π̂, donc aucun fondement à un seuil ;
   - statut : constat de simulation, conditionnel à l'admission et à R* > 0, aucune source à n = 8.
3. **Rubrique Usage, Limites** : en Merz-Wüthrich aussi, le percentile sous-couvre ; aucun intervalle de remplacement.
4. **Encadré « Différence de nature »** de `sec:controles` (l. 6128-6135). Appliquer A.4 (1) de #492 (restitution et affichage du compte). Ajouter le renvoi à la couverture mesurée, et une phrase sur le niveau conditionnel des p-values de Monte-Carlo (point 6).
5. **Valeurs du triangle de contrôle** (l. 6480-6483). Remplacer « n'est pas mesurée … travail postérieur à la remise » par la couverture mesurée (0,573 et 0,617 à 90 %) et le renvoi à la fiche.
6. **Section « Nature des p-values et validité à T = 8 »** :
   - tableaux 1 (l. 8353) et 2 (l. 9004) : ajouter le percentile Merz-Wüthrich (diagnostic, sous-couverture mesurée, aucun « basic ») ;
   - § « Ce que l'on peut et ne peut pas affirmer » : un item sur la limite A.5 sous Λ1. La loi de référence inclut les réplications à R* ≤ 0 alors que le triangle n'est testé que si R̂ > 0 (raisonnement). Écrire « niveau mesuré sur un profil volatil, sans distorsion » : 13 clés aux seuils 0,10 et 0,05, compatibles ou en écart mineur, aucun McNemar significatif, triangle volatil, loi E seulement, 1 016 triangles, écarts de moins d'environ 2 points non détectables. Rien n'est mesuré sous N ni sur d'autres triangles.
7. **Aucun numéro d'issue, aucune citation de Davison et Hinkley § 5.6.**

## 4. Visa d'exécution : accordé avec deux réserves mineures

Vérifié :
- md5 des deux sorties, du moteur (`e5ac6cb…`), du script (`76c92d9…`) et du protocole au moment de l'exécution (`d6ddf11…`) : identiques au JOURNAL, sur `git show e6547ad`.
- Arbre de la mesure inchangé entre `e6547ad` et `HEAD`, hors sorties et ajout au protocole.
- L0 tenu : effectifs tirés conformes, aucune extension de R.
- Admissions plausibles : P4 0,598, P5 0,574, oracle 0,588 (attendu environ 0,59).
- Ω0 non déclenché. Contrôles 1 à 14 et fixture OK, dont le contrôle 5 sur chacun des 1 016 triangles de P4.
- Q5, Q8 et Q9 sont dans le script commité à 19:07:12, avant le lancement à 19:07:17.

Réserves mineures :
1. Les graines du pré-vol suivent une formule différente de P6 (393 000 000 + 10 000 (p − 1) + u, et 393 050 000 + …). Elles restent dans la plage déclarée, et le contrôle 10 établit la disjonction. Aucun effet sur la mesure.
2. Q5, Q8 et Q9 ont été versés au protocole après l'exécution (`444f96c`). Les sections 1 et 3 sont inchangées (le diff n'ajoute que 10 lignes ; contrôle 11). Seule la traçabilité de date est en cause.

## Retour

- **Statut** : `revue requise`. La lecture est complète ; la décision D2 revient au mainteneur.
- **Résultat** :
  - Ω3, Λ1, V sans objet.
  - Sous-couverture due d'abord au biais de σ̂, que le bootstrap ne reproduit qu'à moitié (non-pivotalité), puis à l'étroitesse ; la cible n'y est pour rien.
  - D2 : option (b) recommandée.
  - Visa avec deux réserves mineures.
- **Preuves** :
  - *Vérifiées* :
    - tableaux T0 à T8 relus ;
    - md5 et horodatages, par commande ;
    - `reserve2.rds` : moyenne de σ*/σ̂ 0,887, médiane 0,845 ;
    - décomposition sur le brut (Rscript, sortie citée en 1.3 à 1.7) ;
    - textes actuels de `textes_ic_bootstrap()`, des tests qui figent la note et des lignes du `.tex`.
  - *Hypothèses* : mécanisme de non-pivotalité ; origine du biais ; singularité du ratio sur P4 ; coût du double bootstrap.
  - *Non vérifiés* : contenu de Davison et Hinkley, section « Double Bootstrap Methods » (titre vu dans une table des matières non numérotée) ; non cité.
- **Informations manquantes** : aucune source ne chiffre ces couvertures à T = 8.
- **Décisions non résolues** : D2, options (a) à (d) ; création de l'issue ; refonte de l'étape 4b en note requalifiée. Le mainteneur décide, `architect` replace l'étape dans le plan.
- **Critères déclenchés** :
  - texte restitué par l'application changé (note) : aucun σ_USP, aucun verdict ni aucune p-value ;
  - le critère A.7 (6) de 1a devient caduc ;
  - validité à T = 8 tranchée seulement par simulation, sur ces plans.
- **Constats hors périmètre** :
  1. Commentaires de `R/engine.R`, l. 12857 et 18116 : « couverture non mesurée », devenu faux. Critère E5, par analogie avec A.6 (2) de 1a ; dans le périmètre de #387.
  2. Le `.tex`, l. 6482, dit « travail postérieur à la remise ». Critère E5 ; dans le périmètre de #387.
  3. Les tableaux 1 et 2 omettent l'intervalle Merz-Wüthrich. Critère : aucun (omission) ; à traiter au passage de `docwriter`.
  4. Sur P4, I2 a une borne basse ≤ 0 dans 82 % des cas. Critère : aucun, I2 n'étant pas restitué.
- **Prochaine action recommandée** :
  1. La session verse ce rapport dans `docs/revues/20261119-s5-bootstrap-mw/`.
  2. Le mainteneur tranche D2.
  3. Sous (b) : commits `app:`, `tests:` et `moteur:` (commentaires) par `coder`, puis `app-review` ; issue créée après accord.
  4. `docwriter` en fin de branche, puis validation du diff du `.tex` par `actuary`.

Sources consultées pour repérer seulement l'existence de la section citée ci-dessus (aucune affirmation de fond ne s'y appuie) : table des matières de Davison et Hinkley (Scribd) ; compte rendu de l'ouvrage (Cambridge).
