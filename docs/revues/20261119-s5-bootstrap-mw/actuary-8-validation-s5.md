> *Versé intégralement par la session principale le 20/11/2026 (`actuary-approfondi`, étape 8 de S5, validation de fond ; tête `4585867`). Trois parties : le rapport de validation, la réponse à la question complémentaire sur « en erreur » dans `n_sans_sigma`, le contrôle ciblé du commit de correction `0489800`.*

---

## Partie 1 — Rapport de validation

> *Rédigé par l'agent actuary (IA).* Étape 8 de S5, validation de fond. Lecture seule sur `claude/bootstrap-merz-wuthrich`, tête `4585867`. Je n'ai écrit aucun fichier du dépôt, créé aucune issue ni posté aucun commentaire. Mon seul script de recomptage est dans le dossier temporaire de la session (`recompte246.R`).

# Validation de fond S5 (#246, #492, #387, #445, #607)

## 0. Synthèse

| Objet | Visa |
|---|---|
| 1. Sortie de #246 (`reserve2`, R = 1 000) | **sans réserve**. **Aucune phrase de plus n'est demandée dans le `.tex`.** |
| 2. Diff du `.tex` (`e4a8ae4...HEAD`) | **avec réserves** : une correction **majeure** (même longueur, dans la fiche) et quatre mineures. |
| 3. Tableaux de #492 | **sans réserve** : aucun écart depuis l'étape 3. |
| 4. Rendu de #387 / D2 (b) | **sans réserve**. La réserve majeure de l'objet 2 touche aussi ce rendu dans la fiche. |

Je demande donc une modification du `.tex` : la correction majeure M-1. Les mineures m-1 à m-4 sont recommandées, sans être exigées.

---

## 1. Sortie de #246 : visa sans réserve

### 1.1 Contrôles

Tous *vérifiés* :
- **Provenance.** À HEAD, md5 de `tests/double_bootstrap_mw.R` = `0ed6a48…`, de `tests/outils_tests.R` = `cdf8f7d…`, de `triangle_mw.csv` = `3e9a584…`. Ce sont les valeurs de la sortie.
- **Moteur.** À HEAD, `R/engine.R` a pour md5 `d94de7d…` et pour empreinte #231 `17ce964a…` (calculées par Rscript). C'est le moteur exécuté. `git diff 75e144e HEAD` ne touche que les deux fichiers de sortie.
- **Recomptage indépendant** sur le brut (1 000 lignes, toutes admises, 0 p\* absente, B_eff = 999 partout, aucun retirage ni plafond). Pour les 13 clés, je retrouve à l'identique les comptes k, les comptes « < » et les taux p\* < 0,05, < 0,10 et < 0,025 de la sortie.
- **Décisions.** D-1 tenue : aucune occurrence de « Beran » dans le script, la sortie ou le `.tex`. D-3 tenue : |sd_pop − 1| = 0,0012, donc pas de section « Alertes », ce qui est correct.
- **Point non revérifié.** La comparaison (rep) entre deux exécutions et entre `--coeurs 1` et `--coeurs 4` a été faite à la main à R = 20 (message de `3808265`, mineur consigné par `audit`). Je ne l'ai pas relancée.

### 1.2 Ce que la sortie permet de conclure

C'est un constat de simulation, sous le modèle de Mack ajusté à `reserve2` (f̂, σ̂², première colonne fixée), sous la loi E et à T = 8.

1. **Les quatre ECHEC observés restent sous 0,05 dans la loi simulée de leur p, en tenant compte de l'erreur (i)** (*vérifié*) :

   | Clé | F̂\* | IC de Clopper-Pearson |
   |---|---|---|
   | Calendrier | 0,004 | [0,001 ; 0,010] |
   | Alpha | 0,003 | [0,001 ; 0,009] |
   | Courbure | 0,027 | [0,018 ; 0,039] |
   | DW | 0,035 | [0,025 ; 0,048] |

   - Pour l'erreur (ii), DW est le seul cas limite : sa bande descriptive F̂\*(p_obs ∓ 2 err_mc) monte jusqu'à 0,050.
   - Les cinq lignes en OK restent au-dessus de 0,10, bornes basses comprises : CorrDev à 0,137 au plus bas.
   - Deux des trois ALERTE sont à cheval sur 0,10 : PenteIntra 0,108 [0,089 ; 0,129] et Origine 0,090 [0,073 ; 0,110]. HomogF vaut 0,061 [0,047 ; 0,078].
   - **Lecture.** Dans ce monde, l'effet plug-in (f, σ² et le vivier réestimés sur chaque triangle simulé) ne fait basculer aucun ECHEC ni aucun OK. F̂\* n'est pas retenue, et aucun verdict ne change.
2. **Niveau du test bootstrap sous ce modèle** (*vérifié*, lecture faite par moi contre la bande fermée [ρ/2 ; 3ρ/2] de #206, non imprimée par l'outil). Pour les 12 lignes à verdict, les quatre taux sont dans la bande :
   - de 0,033 à 0,063 pour ρ = 0,05 ;
   - de 0,081 à 0,119 pour ρ = 0,10 ;
   - de 0,018 à 0,033 pour ρ = 0,025.

   Runs, qui est un diagnostic, est sous la bande à ρ = 0,025 (0,011 [0,006 ; 0,020]), avec un IC qui la recoupe.

   Ces taux ne sont **pas une information nouvelle** sur `reserve2` : ce sont les lignes r ≤ 1 000 du plan E de #297, retrouvées au bit près par (r2), et #297 en donne déjà 2 000 à la section `sec:calib-mc-mw`.

### 1.3 Ce que la sortie ne permet pas de conclure

- **Erreur (iii), non quantifiée.** La sortie ne dit rien hors de (θ̂, E). La loi externe E coïncide, au facteur sd_pop près, avec le monde du bootstrap interne. Le double bootstrap mesure donc l'erreur plug-in de la réestimation, pas l'erreur liée à la loi des résidus. Or #206 et #297 montrent que c'est cette dernière qui déplace les niveaux (loi A). De plus, σ̂² est biaisé vers le bas à T = 8 (#387, médiane de σ̂/σ_A = 0,845) : le générateur est lui-même décalé (*hypothèse* sur l'effet que cela a sur F̂\*, non mesuré).
- **Validité de F̂\* comme p corrigée.** Aucun résultat exact ni aucune référence relue ne dit que F̂\* est mieux calibrée que p_obs à T = 8. Beran n'est pas relu (D-1).
- **Puissance.** Elle n'est pas étudiée. Une fréquence élevée n'atteste pas l'adéquation.
- **Triangle du dossier.** La sortie porte sur le triangle de contrôle (D-2).
- **Erreurs (i) et (ii).** Elles sont bien séparées dans la sortie : intervalle de Clopper-Pearson pour (i), bande descriptive pour (ii).

### 1.4 Phrase dans le `.tex` : non nécessaire

1. Les niveaux sur `reserve2` sont déjà au `.tex` avec un échantillon double (#297).
2. Les F̂\* ne sont pas retenues, ne changent aucun verdict et portent sur le triangle de contrôle.
3. Le paragraphe de `b89489f` (l. 20638-20663) énonce déjà le statut et les trois erreurs. Sa phrase finale, « Le document ne cite aucune sortie de cet outil. », est exacte et doit rester telle quelle.

*Option non demandée*, si le mainteneur la veut, à placer hors de la fiche, en `sec:calib-mc-mw`, à la place de la dernière phrase de la l. 20663 :

> « Sur le triangle de contrôle ($R = 1\,000$), les quatre p-values de Monte-Carlo en \code{ECHEC} restent sous $0{,}05$ dans leur loi simulée, bornes de Clopper--Pearson comprises (au plus $0{,}048$), et celles des lignes en \code{OK} au-dessus de $0{,}10$~; constat de simulation sous le modèle ajusté et la loi E, qui ne change aucun verdict. »

---

## 2. Diff du `.tex` : visa avec réserves

### 2.1 Points soumis par `docwriter`

- **Écart au § 3 de ma lecture de #387 (tableau et lecture placés en `sec:boot-mw`) : accepté** (*vérifié*).
  - La fiche garde le constat et renvoie à `sec:boot-mw`. Le renvoi est juste : la rubrique 4 de la fiche est bien `\Loi`.
  - `sec:boot-mw` contient ce que mon § 3 exigeait : plan, cible, critère, I1, I2 et I4 à 90 % avec Clopper-Pearson pour I1, le 95 % résumé par « au mieux 0,816 », le profil volatil, σ_B, les strates de π̂, la triple source d'erreur et le statut.
  - La forme en prose plutôt qu'en tableau ne fait perdre aucune conclusion. Les tableaux complets sont désignés dans `docs/tableaux/`.
  - Tous les chiffres sont recoupés contre T1 à T7 : 0,573, 0,617, 0,596, 0,640, 0,692, 0,733, 0,816, 0,518, 0,537, 0,125, 834/1 016, 0,380, 0,845, 1,055, 1,053, 0,590, 0,636, 323 = 111 + 212, 0,507, 0,99 (401), 1 016/1 700.
- **Convention σ_A : acceptée** (*vérifiée* : conforme à mon § 1.6 et à D2 (b)). Précision mineure m-3 ci-dessous.
- **Statut « raisonnement » du niveau conditionnel à l'admission, et item de `sec:t8` : acceptés** (*vérifié*).
  - L'encadré (l. 6180-6183), l'item de `sec:t8` (l. 8037-8043) et le paragraphe de `sec:calib-mc-mw` (l. 20615-20637) concordent avec T7, T8 et Λ1 : 24 classes compatibles et 2 en écart mineur, McNemar avec une plus petite p de 0,125 et Holm à 1, 1 à 9 paires discordantes, demi-largeur d'environ 0,018, oracle de 9 988 sur 17 000, π̂ médian 0,138, 39 % au-delà de 0,20.
  - La phrase « les niveaux ci-dessus y valent aussi conditionnellement à l'admission (raisonnement) » est fondée. Sur P1 et P2, les 4 000 triangles sont admis et π̂ = 0 partout. L'écart entre niveau conditionnel et niveau sans condition est alors borné par P(R̂ ≤ 0), dont la borne de Clopper-Pearson à 0/4 000 vaut environ 0,0009.
  - « Sans distorsion détectée » est meilleur que mon « sans distorsion ».
  - Précision mineure m-2 ci-dessous.
- **« presque tous » dans la synthèse (l. 21980) : accepté** (*vérifié*). Sur I1, la part sous la borne basse vaut 0,000 sur P1, P2, P4 et P5, aux deux niveaux. Elle vaut 0,001 sur P3 (loi A) à 90 %, et 0 à 95 %. « Tous » serait faux d'un triangle sur 1 000.
- **Phrase des compléments bibliographiques sur la non-pivotalité (l. 21717-21720) : acceptée sur le fond.** La quasi-pivotalité y reste une hypothèse étayée sur les seuls plans lognormaux, et la non-pivotalité en Merz-Wüthrich une hypothèse étayée. Il manque seulement « mesuré » (m-1).

### 2.2 Rigueur statistique

Respectée (*vérifié* sur tout le diff).
- Chaque chiffre de couverture ou de niveau porte « constat de simulation ».
- L'erreur de Monte-Carlo (nombre de triangles, Clopper-Pearson ; B inclus dans la procédure) et l'erreur de substitution sont séparées partout.
- « Raisonnement », « hypothèse » et « argument élémentaire » sont marqués.
- Aucune référence nouvelle. Aucune citation de Beran ni de Davison et Hinkley § 5.6.
- #492 et #445 : l'index de `n_sans_sigma` est conforme au code (`R/engine.R` l. 16098-16114 et 16155 : σ\* fini seulement si la MSEP est finie et la réserve > 0 ; réplication gardée dans `sim`). La ligne de B minimal (l. 4668) est juste. Les entrées de `.usp_spearman_S()`, `.usp_smirnov_D()`, `.mw_df()` et `degeneres_aj` ne touchent aucun fond statistique.

### 2.3 Corrections demandées

**M-1, majeur** : `docs/latex/doc_tests_usp.tex:14591-14592`, fiche `fiche:ic-bootstrap`.
- Le texte « Sous les modèles ajustés à deux triangles, … ($0{,}573$ et $0{,}617$ à 90~\% ; …) » fait lire une couverture par triangle.
- Or 0,573 et 0,617 sont le **même** triangle de contrôle sous E et sous N. Le triangle volatil couvre 0,537 et la loi A 0,518 (T1 à T3). Un lecteur de la seule fiche surestime le meilleur cas.
- Correction de même longueur rendue (21 caractères contre 21), sans effet sur le plafond de trois pages :
  - remplacer : `($0{,}573$ et $0{,}617$ à` / `90~\%~;`
  - par : `($0{,}52$ à $0{,}62$ pour` / `90~\%~;`
- La plage couvre P1 à P5 (0,518 à 0,617, *vérifié*). Elle rejoint le « 0,54 à 0,62 selon le plan et la loi » de ma lecture, A comprise. `sec:boot-mw` et le tableau 2 (l. 9116, « sur le triangle de contrôle ») restent exacts tels quels.

**m-1, mineur** : `:21720`. « et aucun intervalle «~basic~» ne rétablit le niveau » devient « et aucun intervalle «~basic~» **mesuré** ne rétablit le niveau ». Seuls I2 et I4 sont mesurés. Le tableau 1, le tableau 2, la fiche et la note disent tous « mesuré ».

**m-2, mineur** : `:20620-20621`.
- Remplacer « l'écart est nul si la statistique est indépendante de l'événement $\{R > 0\}$ (argument élémentaire, donné sans référence~; aucune source ne chiffre » par « l'écart est nul si la p-value est indépendante de l'événement $\{\hat R > 0\}$ (argument élémentaire, donné sans référence~; aucune source lue ne chiffre ».
- Motifs : la condition porte sur la p (statistique et loi de référence bootstrap, qui dépendent toutes deux du triangle) ; l'événement est R̂, pas R ; « source lue » est la formule du reste du document.

**m-3, mineur** : `:6546-6547`. « sans analogue en population » devient « sans en désigner d'analogue en population ». Tel quel, le texte se lit « il n'en existe pas », alors que σ_B, deux phrases plus loin, en est un candidat.

**m-4, mineur** : `:6556`. « la loi de $\hat\sigma^{(b)}/\hat\sigma$ n'est pas pivotale » devient « la loi de $\hat\sigma/\sigma$ n'est pas pivotale, celle de $\hat\sigma^{(b)}/\hat\sigma$ variant d'un triangle à l'autre ». Le pivot est σ̂/σ (comme en l. 14610 et 21717), et la variation de la version bootstrap en est l'indice. C'est une formule que j'avais moi-même employée en d4eb433.

*Facultatif, non classé* : `:6550`. « le percentile n'a aucun manque sous sa borne basse » pourrait devenir « … sous E et N » (sous A : 1 sur 1 000 à 90 %). Le contexte de la phrase est déjà E et N.

---

## 3. Tableaux de #492 : visa sans réserve

Aucun écart depuis mon visa de l'étape 3 (*vérifié*) :
- Depuis `d65c1b4`, seul `8a3ebc5` touche `R/engine.R`, et il ne change que des commentaires : le diff sans lignes de commentaire est vide. L'empreinte #231 vaut `17ce964a…` à HEAD.
- Aucun commit sur `tests/reference/` depuis `d65c1b4`.
- σ_USP de `reserve2` = 0,0497764613, et l'unique feuille ajoutée est `bootstrap$n_sans_sigma = 0`. C'est cohérent avec la l. 6526 du `.tex` (« 999 valeurs, n_sans_sigma nul »).

---

## 4. Rendu de #387 / D2 (b) : visa sans réserve

- **Note de l'application** (*vérifié*). `R/display_helpers.R:2540-2544` reprend **mot pour mot** le texte de mon § 2.1, avec la portée « sous les modèles ajustés à deux triangles ». Quand k > 0 (l. 2545-2553), la phrase conditionnelle et le compte précèdent le constat, comme prévu. Il n'y a aucun chiffre de couverture, et le libellé « niveau nominal 90 % » est inchangé.
- **`.tex`** (*vérifié*). Ω3 est rendu fidèlement : aucun « basic » restitué en Merz-Wüthrich, percentile qualifié de sous-couvrant, cause donnée comme *hypothèse* de non-pivotalité, cible sans effet (σ_B), aucun seuil sur π̂.
  - Λ1 est rendu fidèlement (encadré, `sec:t8`, `sec:calib-mc-mw`).
  - Mes chiffres exploratoires (étendue logarithmique 0,83, cible médiane) ne figurent pas au `.tex`, comme je l'avais demandé.
  - Seule réserve : l'attribution des deux chiffres dans la fiche (M-1, objet 2).

---

## Retour

- **Statut** : `complet`.
- **Résultat** :
  - Objets 1, 3 et 4 : visa sans réserve.
  - Objet 2 : visa avec réserves. M-1 (majeur, même longueur, `:14591`) est exigée avant le PDF ; m-1 à m-4 sont recommandées.
  - Aucune phrase de plus n'est demandée pour la sortie de #246.
- **Preuves** :
  - *Vérifiées* :
    - md5 et empreinte #231 à HEAD (Rscript) ;
    - recomptage intégral du brut de #246 ;
    - T1 à T8 de #387 relus contre chaque chiffre du diff ;
    - code de `n_sans_sigma` (`R/engine.R` l. 16089-16155) ;
    - `textes_ic_bootstrap()` ;
    - historique `git log` de `R/` et de `tests/reference/` depuis `d65c1b4` ;
    - diff `8a3ebc5` limité aux commentaires.
  - *Hypothèses* :
    - l'effet du biais de σ̂² du générateur sur F̂\* ;
    - la non-pivotalité, qui reste une hypothèse étayée ;
    - la lecture en bandes de #206 appliquée aux taux de #246, faite par moi et non imprimée par l'outil.
  - *Non vérifié* : la comparaison (rep) entre exécutions, faite à la main à R = 20 selon `3808265`, non relancée ; l'effet de M-1 sur la mise en page, à confirmer par `controle_doc_nd.R --bloquant`. La longueur rendue est identique.
- **Informations manquantes** :
  - Beran (1988), non relu (D-1, sans incidence) ;
  - aucune source ne chiffre ces couvertures ni ces niveaux à T = 8.
- **Décisions non résolues** : l'option de la phrase du § 1.4, au mainteneur (je ne la demande pas).
- **Critères déclenchés** :
  - validité à T = 8 tranchée par simulation seulement (inhérent, déclaré) ;
  - aucun changement de résultat ;
  - aucun désaccord avec `audit`, un autre agent ou un ADR.
- **Constats hors périmètre** :
  1. Lecture a posteriori, exploratoire : sous le modèle ajusté, 11 triangles simulés sur 1 000 ont au moins 4 ECHEC parmi les 12 lignes à verdict, autant que `reserve2`. Critère : **aucun**. La lecture conjointe pré-spécifiée est la p globale de #297 ; ce chiffre n'a pas à entrer au `.tex`.
  2. Paragraphes fusionnés dans la fiche (lignes blanches retirées, l. 14606-14607, 14625-14626 et 14644-14645) : question de typographie, sans effet sur le fond. Critère : **aucun**.
  3. Dans le paragraphe « Biais » (l. 14599), l'expression « Dans la simulation de couverture » est devenue ambiguë : un paragraphe Merz-Wüthrich la précède désormais, alors qu'elle désigne J1 et J2. Critère : **aucun** (mineur écarté).
  4. (rep) entre exécutions non imprimée dans la sortie. Critère : **aucun**, déjà consigné par `audit`.
- **Prochaine action recommandée** :
  1. `docwriter` applique M-1, plus m-1 à m-4 s'il les retient, en un commit `docs:`.
  2. Contrôles `controle_doc_nd.R --bloquant` et `concordance_doc_moteur.R --strict`.
  3. Je contrôle le diff de ce seul commit (pas de nouvelle validation complète).
  4. Puis la revue finale (`audit` en `high`, `app-review`) et le PDF.

---

## Partie 2 — Réponse à la question complémentaire (« en erreur » dans `n_sans_sigma`)

> *Rédigé par l'agent actuary (IA).* Réponse à la question complémentaire de l'étape 8 (« en erreur » dans `n_sans_sigma`). Lecture seule.

**Ma réponse est (b) : écarter.** C'est un constat mineur au sens de l'ADR 0018 (aucun critère E1 à E6 rempli). Je ne demande aucune modification de la note, du test ni du `.tex`.

**Phrases qui omettent « en erreur »** (*vérifié*, par `grep`) :
- la note, `R/display_helpers.R:2548-2550` ;
- le texte attendu de cette note, `tests/unitaires/test_sans_sigma_mw.R:189` ;
- `docs/latex/doc_tests_usp.tex:6173-6174`, encadré « Différence de nature » ;
- `docs/latex/doc_tests_usp.tex:14491-14492`, rubrique Cadre de `fiche:ic-bootstrap`.

Deux endroits citent déjà le cas : l'index des fonctions, `doc_tests_usp.tex:1647` (« réserve simulée $\le 0$, MSEP simulée en erreur, non finie ou négative »), et le commentaire de `R/engine.R:16089-16094`.

**Pourquoi j'écarte :**
1. **Aucun chiffre n'est touché.** σ_USP, les p-values, les verdicts et `n_sans_sigma` lui-même ne changent pas : le code compte bien ce cas (`R/engine.R:16110-16114`). Seul le texte qui accompagne le compte est en cause.
2. **Ce n'est pas une affirmation fausse sur le code (E5), mais une énumération incomplète.** Chaque cas que les phrases nomment est exact. Le cas omis, une MSEP qui n'existe pas, se lit naturellement comme une forme de MSEP « non finie ». Et la règle exhaustive figure à sa place de référence, l'index des fonctions (l. 1647), que le `.tex` tient synchronisé avec le code.
3. **Le cas n'est peut-être jamais atteint.** Sa survenue sans substitution n'est pas mesurée : une réplication n'arrive à `mw_msep()` qu'une fois `mw_ajuster()` et `.mw_stats()` passés sans erreur. Sur les mesures de #387 (P1 à P5, plus de 7 900 triangles admis), `n_sans_sigma` concorde avec le masque σ\* fini (contrôle 8) sans qu'aucune erreur de MSEP ait été isolée. Je n'ai pas vérifié si une telle erreur est survenue dans ces mesures.
4. **Le coût est disproportionné.** Il faudrait toucher l'application, le texte figé du test, refaire une revue par `app-review`, et réécrire deux phrases du `.tex`, dont une dans la fiche qui tient ses trois pages sans aucune marge.

**À rouvrir seulement si** une erreur de `mw_msep()` est un jour observée sans substitution. Il faudrait alors appliquer (a), avec les textes suivants :
- **note**, l. 2549 : « (réserve simulée négative ou nulle, ou MSEP simulée en erreur, non finie ou négative) », et la même chose dans `test_sans_sigma_mw.R:189` ;
- **`.tex`, l. 6173-6174** : « dont la MSEP simulée est en erreur, n'est pas finie ou est négative » ;
- **`.tex`, l. 14491-14492** : « à MSEP simulée en erreur, non finie ou négative ». Ce sont neuf caractères de plus dans la fiche ; leur effet sur la mise en page serait à vérifier par `controle_doc_nd.R --bloquant`.

**Ligne proposée sous « Constats mineurs écartés (ADR 0018) »** :
> « Note de `textes_ic_bootstrap()`, `.tex` l. 6173 et 14491 : la parenthèse des causes de `n_sans_sigma` omet « MSEP en erreur », que l'index (l. 1647) et le code comptent. Énumération incomplète, non fausse ; aucun chiffre touché ; survenue sans substitution non mesurée. Écarté (actuary, étape 8). »

**Retour**
- **Statut** : `complet`.
- **Résultat** : (b), constat écarté.
- **Preuves** :
  - *Vérifiées* : les occurrences relevées par `grep` ; la branche d'erreur, `R/engine.R:16110-16114`.
  - *Hypothèse* : le cas n'est pas atteint sans substitution (non mesuré).
- **Critères déclenchés** : aucun.
- **Constats hors périmètre** : aucun.
- **Prochaine action** : la session consigne la ligne ci-dessus dans le rapport de revue. Cela ne change rien aux corrections M-1 et m-1 à m-4 de mon rapport de l'étape 8.

---

## Partie 3 — Contrôle ciblé du commit `0489800` (corrections de `docwriter`)

> *Rédigé par l'agent actuary (IA).* Contrôle ciblé de `0489800`, en lecture seule.

**Visa : sans réserve. La réserve de l'objet 2 est levée.**

- **M-1 est appliquée telle que je l'avais demandée** (l. 14591). La fiche donne maintenant « ($0{,}52$ à $0{,}62$ pour 90~\% ; … » au lieu des deux valeurs du seul triangle de contrôle. La plage reprend les couvertures à 90 % de T3 sur P1 à P5, de 0,518 à 0,617.
- **m-1 à m-4 et le point facultatif sont appliqués mot pour mot**, sans aucun autre changement de fond :
  - l. 21720 : « mesuré » ajouté ;
  - l. 20620-20621 : la condition porte sur la p-value, l'événement s'écrit $\{\hat R > 0\}$, et « aucune source lue » remplace « aucune source » ;
  - l. 6546 : « sans en désigner d'analogue » ;
  - l. 6551 : « sous E et N » ajouté ;
  - l. 6556-6557 : la non-pivotalité porte sur σ̂/σ.
- **Mise en page et contrôles** : je ne les ai pas relancés. Je reprends du message de commit la compilation à 468 pages, la fiche aux pages 321 à 323, et `controle_doc_nd.R --bloquant` et `concordance_doc_moteur.R --strict` à 0. Le diff est lu par `git show 0489800`.

Avec ce commit, les quatre objets de l'étape 8 sont visés sans réserve. Le constat « en erreur » sur `n_sans_sigma` reste écarté (ADR 0018). Prochaine étape : revue finale, puis PDF.
