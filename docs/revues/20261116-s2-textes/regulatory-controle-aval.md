<!-- Rapport de l'agent regulatory, branche S2, étape 7 (contrôle de conformité en aval), 17/11/2026. À verser tel quel par la session principale. -->

# Contrôle de conformité en aval, branche S2, étape 7 (#585, #586)

Je n'ai rien écrit dans le dépôt : ni fichier, ni commit, ni issue. Comparaison faite entre `940f941` (merge-base) et `36ae5db` (tête de `claude/textes-conformite-et-qualifications`). L'arbre de travail était propre.

**Synthèse.** Aucun écart bloquant ni majeur.
- Le motif de #585 reprend la lecture amont octet pour octet et il est fidèle au texte.
- Les formules transcrites de B(4)-(6) et C(4)-(6), leurs points et leurs pages du JOUE sont **conformes**. Je les ai relues sur l'image dans les deux versions.
- L'équivalence avec `usp_pi()`, `usp_noyau()` et `usp_parametre()` est exacte. Je l'ai recalculée à la tête de branche.
- La p. 75 que `docwriter` a ajoutée pour l'art. 117(2)(a) est **confirmée**.
- Il reste quatre constats mineurs, avec un texte de remplacement pour chacun. Deux sont des précisions de fond dans le périmètre de #586 (M-1, M-2), deux sont de forme (M-3, M-4).
- **Aucune issue nouvelle n'est proposée.**

## 0. Sources et méthode

- **Version d'origine** (`Règlement délégué.pdf`, JOUE L 12 du 17.1.2015) : pages p. 31, 75, 142, 143, 144 et 272 à 278 rendues par `pdftoppm` (100 à 150 dpi) et lues sur l'image. J'ai vérifié chaque page sur son en-tête « L 12/n ».
- **Version consolidée du 14.11.2024** (XHTML), formules :
  - j'ai extrait les 36 images de l'annexe XVII B et C ;
  - j'ai relu sur l'image celles de B(5), B(5)(d) (π_t), B(6) et C(4) ;
  - pour les autres, je m'appuie sur le contrôle md5 de ma lecture amont (§ 0).
- **Version consolidée, marqueurs relevés** :
  - l'annexe XVII est sous ▼B, sauf ►M1 en B(2)(c)/(d) et ►C4 en C(2)(e)(ii) ;
  - l'art. 117 est sous ▼B (bloc qui commence à la l. 10520 du XHTML, aucun marqueur jusqu'à la l. 11049) ;
  - l'art. 219 est sous ▼B.
- **Recalcul** : `Rscript`, moteur chargé par `charger_moteur()` à `36ae5db`.
  - Série x = 133, 197, 414, 1426, 105, 1375, 1631, 572 ; y = 97,1, 89,5, 322,2, 1160,6, 86,7, 866,1, 1593,8, 430,2. Résultat δ̂ = 0,710101, γ̂ = −1,67997.
  - σ̂ du moteur contre B(5) littéral : écart relatif 2,2e-16. Montant de B(6) : écart 0.
  - σ_USP de `usp_parametre()` contre B(4) littéral, avec σ_standard = 0,10 : 0,1496727 (barème court, c = 0,81) et 0,1361814 (barème long, c = 0,59) ; écart relatif ≤ 2,2e-16.

## 1. Matrice de conformité

| # | Texte réglementaire (page JOUE) | Code ou `.tex` à `36ae5db` | Verdict |
|---|---|---|---|
| 1 | Art. 219(1)(a) → art. 19(1), exhaustivité (p. 143 ; p. 31) ; B(1) dernier alinéa (p. 272), C(1) dernier alinéa (p. 274) ; B(2)(b) (p. 272), C(2)(b) (p. 274) | `engine_valider_donnees()`, `R/engine.R` l. 10958 : « Valeurs manquantes : le calibrage exige des series completes (art. 219, paragraphe 1, point a), renvoyant a l'art. 19, paragraphe 1 ; annexe XVII, B/C(1) et B/C(2)(b)). » (commit `45dacd4`) | **Conforme**. Identique octet pour octet au § 1.1 de la lecture amont (comparaison shell). Art. 19(1) = exhaustivité, vérifié sur l'image p. 31. Le texte entier est figé par `test_controles_entree.R` l. 51-60 (commit `a38957c`). |
| 2 | Même ancrage | Tableau de `sec:controles`, ligne « Valeurs manquantes » : « Art. 219, paragraphe 1, point a), renvoyant à l'art. 19, paragraphe 1 : exhaustivité ; annexe XVII, B/C(1) et B/C(2)(b). Bloquant. » | **Conforme**, aligné sur le motif. B/C(n) est défini dans `sec:notations` (l. 3446). |
| 3 | B(4), chapeau, formule, points (a)-(e) (p. 273) | `sec:spec-lognormale`, paragraphe « Écart type propre à l'entreprise (B(4)) » | **Conforme** : formule, ordre des facteurs et prose identiques à l'image, dans les deux versions. |
| 4 | B(5), chapeau, formule, (a)-(d), (d)(i)-(ii), formules de π_t et de x̄ (p. 273, puis x̄ en p. 274) | Paragraphe « Fonction d'écart type (B(5)) » | **Conforme**. Seule différence : `exp` et `ln` sont en italique dans le JOUE, en romain dans le `.tex`. C'est de la typographie, pas un écart. |
| 5 | B(6), chapeau, montant, (a)-(d), x̄, dernier alinéa (p. 274) | Paragraphe « Paramètre de mélange… (B(6)) » | **Conforme** à l'image. |
| 6 | C(4), chapeau et formule σ_(res,s,USP) (p. 275) ; C(4)(e) « σ_(prem,s) » (p. 275) ; C(5) (p. 275) ; C(6) (p. 276) ; C(3)(c)-(d) (p. 275) | Paragraphe « Section C » | **Conforme**. Le chapeau est cité mot pour mot. C(4)(e) est bien imprimé σ_(prem,s) dans les deux versions. C(5) et C(6) sont identiques à B. y_t = montant de C(1)(a) (C(3)(c)) ; x_t comme dans C(3)(d). |
| 7 | Pages annoncées : B(1) p. 272, B(4) p. 273, B(5) p. 273-274, B(6) p. 274 ; C(1) p. 274, C(4) et C(5) p. 275, C(6) p. 276 | « Version du texte et pagination » | **Conforme** : chaque page est vérifiée sur l'en-tête. L'affirmation « aucune modification des paragraphes 1 et 3 à 6 des sections B et C » est exacte : aucun marqueur, M1 et C4 ne touchent que le paragraphe 2. |
| 8 | Équivalence avec le moteur | Paragraphe « Équivalence avec le moteur » ; `usp_pi()` l. 1436, `usp_noyau()` l. 1441, `usp_objectif()` l. 1465, `usp_ajuster()` l. 1779 (bornes l. 1794), `usp_parametre()` l. 2168 | **Conforme** (voir les chiffres du § 0). Points vérifiés un par un :<br>• π_t par commutativité, et `log1p` ;<br>• ln β̂ est la fraction de l'exposant, et le texte ne nomme pas β ;<br>• identité exacte γ̂ − ln σ̂ = −ln β̂ ;<br>• δ ∈ [0,1] tenu par `lower`/`upper` et par le renvoi 1e12 hors de l'intervalle ;<br>• `BORNES_GAMMA` dite non réglementaire et documentée dans `sec:controles` (l. 4670-4789) ;<br>• les labels `sec:h4`, `fiche:foc` et `fiche:multi-demarrages` existent ;<br>• `test_modele_lognormal.R` l. 31-62 contient bien une transcription littérale de B(5) et B(6), et `test_calibration.R` l. 261-285 contrôle B(4). |
| 9 | Art. 219(1)(b) et (c), art. 219(2)(a)-(e) (p. 143-144) | `sec:controles`, fin de la liste « Exigences de données non vérifiables », l. 5696-5710 | **Conforme** au texte et à D-S2-3 : le segment du point b) reprend mot pour mot le texte d'`actuary` retenu ; le point c) renvoie à « 2009/13/CE » ; la paraphrase de (2)(a)-(e) est fidèle ; les pages sont exactes. Une remarque de forme : M-3. |
| 10 | Encadré des anomalies, `sec:segments` | « présentes aussi dans la version d'origine (… p. 75, 142, 143 et 275) » | **Conforme** pour les quatre anomalies :<br>• **p. 75 confirmée** sur l'image : l'art. 117(2)(a), en haut de la p. L 12/75, porte « calculé conformément au paragraphe 2 » ; texte identique sous ▼B dans la consolidée (XHTML vers la l. 10640) ;<br>• p. 142, art. 218(1)(c)(iv) « article 148, paragraphe 2, point a) » : vérifié sur l'image (je ne l'avais lu que par extraction à l'étape 1) ;<br>• p. 143, « 2009/13/CE » : image ;<br>• p. 275, C(4)(e) : image.<br>L'ajout de la phrase « 2009/13/CE » est conforme au § 1.3 de la lecture amont. Un point de forme sur l'intitulé : M-4. |
| 11 | B(3)(c), « les pertes accumulées dans le segment s durant une année d'accident donnée t » (p. 273) | « l'outil les lit comme les pertes agrégées de B(1)(a), seules pertes que définit B(1) » | **Conforme**, et la qualification est correcte (« l'outil les lit », non la lettre du texte). Voir le § 3. Renforcement facultatif : M-2. |
| 12 | B(1)(a), citation (p. 272) | Encadré `\reglement` | **Conforme** mot pour mot, ponctuation finale « ; » comprise. |
| 13 | Lecture (ii) de B(1)(a) : A(1)(b) (p. 272), D(3)(a) (p. 277), D(5)(d)(ii) « j = 0,…, (J – 2) » (p. 278 ; identique dans la consolidée) | Paragraphe « Pertes agrégées (B(1)(a)) » | **Conforme** à D-S2-1 : la citation est littérale, la lecture est présentée comme celle de l'outil et la lecture (i) est dite non retenue. A(1)(b), D(3)(a) et D(5)(d)(ii) sont exacts dans les deux versions. Une ambiguïté de portée reste dans la paraphrase : M-1. |
| 14 | Réponse EIOPA Q&A 2580 (D-S2-2) | Citation en anglais dans `sec:spec-lognormale` ; entrée dans `sec:biblio` | **Conforme** à D-S2-2 :<br>• la citation est identique octet pour octet au relevé de `decisions-mainteneur.md` (au `$t$` près) ;<br>• la mention « n'a pas de valeur juridique propre » figure dans le texte et dans la bibliographie ;<br>• les métadonnées sont exactes. Je les ai reconfirmées le 17/11/2026 par WebFetch : ID 2580, « Article 31; Annex XVII », Final, 13 Feb 2023. Le contenu est confirmé en substance ; l'outil reformule, donc pas mot pour mot. La relecture verbatim de la session fait foi.<br>Une remarque de formulation : M-1 bis. |
| 15 | A(1)(a) (p. 272) ; A(1)(c) ; A(1)(d) ; C(3)(a) (p. 275) | Paragraphe « Année de survenance », `sec:notations` | **Conforme** :<br>• citation de A(1)(a) mot pour mot ;<br>• l'équivalence est limitée à B et D ;<br>• A(1)(c) est bien « année de déclaration » ;<br>• l'année de souscription n'est pas définie en A(1) (exact) ;<br>• A(1)(d) définit l'« exercice » comme l'année du paiement, d'où l'exactitude de « années de paiement au sens de A(1)(d) ».<br>Aucun emploi contraire de « survenance » pour la section C n'est relevé dans le `.tex` (l. 448 et 15019-15021 distinguent bien). |
| 16 | Partie IV, l. 18856 ; index des fonctions (B(4)/C(4), B(5)/C(5), B(6)/C(6)) | Diff `0a53d53` | **Conforme**. |
| 17 | `36ae5db` (#589, `sec:graines`) | — | Hors de mon domaine : aucun contenu réglementaire, aucune remarque. |

## 2. Constats

### Bloquants : aucun. Majeurs : aucun.

### Mineurs

**M-1. Portée de « pour les sinistres survenus pendant celle-ci »**
- **Problème (fond, #586)**. Dans `sec:spec-lognormale`, le complément « pour les sinistres survenus pendant celle-ci » ne porte grammaticalement que sur la provision.
  - « paiements effectués pendant l'année d'accident t » peut alors se lire comme tous les paiements de l'année civile t, y compris ceux des sinistres antérieurs. B(1)(a) écarte cette lecture (« de ces sinistres »), et D-S2-1 aussi.
  - La même ambiguïté se retrouve dans la liste de `sec:controles` (« paiements de l'année d'accident »).
- **Effet**. Le moteur n'est pas touché. Mais une série y_t construite sur cette mauvaise lecture changerait σ_USP de l'entreprise. La citation de B(1)(a) placée juste au-dessus lève le doute, d'où la classe « mineur ».
- **Remplacement 1**, paragraphe « Pertes agrégées (B(1)(a)) ». Remplacer :
  ```latex
  $y_t$ est donc la somme des paiements effectués pendant l'année d'accident~$t$ et de la meilleure
  estimation, établie à la fin de cette année, de la provision pour les sinistres survenus pendant
  celle-ci~; une estimation révisée ultérieurement n'en tient pas lieu.
  ```
  par :
  ```latex
  $y_t$ est donc la somme des paiements effectués pendant l'année d'accident~$t$ au titre des
  sinistres survenus pendant celle-ci et de la meilleure estimation, établie à la fin de cette
  année, de la provision pour ces mêmes sinistres~; une estimation révisée ultérieurement n'en
  tient pas lieu.
  ```
- **Remplacement 2**, liste de `sec:controles`. Remplacer :
  ```latex
  B(1)(a) (pertes agrégées~: paiements de l'année d'accident et meilleure
  estimation de la provision établie à la fin de cette année, non réestimée depuis, lecture retenue
  par l'outil, §\ref{sec:spec-lognormale})
  ```
  par :
  ```latex
  B(1)(a) (pertes agrégées~: paiements effectués pendant l'année d'accident au titre des sinistres
  de cette année et meilleure estimation de la provision pour ces sinistres établie à la fin de
  cette année, non réestimée depuis, lecture retenue par l'outil, §\ref{sec:spec-lognormale})
  ```
- **Lecture inchangée**. Ce n'est pas un changement de lecture : la précision explicite D-S2-1 (« pour ces sinistres »). Elle ne demande pas de nouvelle décision du mainteneur.

**M-1 bis. « Cette lecture est celle de la réponse de l'AEAPP » (formulation)**
- **Problème**. La réponse reprend elle-même « first development year of the accident year t » et ne dit pas « année 0 ». La lecture (ii) s'en déduit par « claims paid during year t » : c'est l'argument d'`actuary`, que je juge solide. « est celle de » dit donc un peu plus que la lettre de la réponse.
- **Statut**. Conforme à D-S2-2 ; à reformuler seulement si la session le juge utile. Remplacer :
  ```latex
  Cette lecture est celle de
  la réponse de l'AEAPP à la question~2580
  ```
  par :
  ```latex
  Cette lecture est conforme à
  la réponse de l'AEAPP à la question~2580
  ```
  et ajouter après la citation anglaise :
  ```latex
  ~; la réponse retient les paiements de l'année~$t$ elle-même, ce qui situe la meilleure
  estimation à la fin de l'année d'accident.
  ```

**M-2. Lecture de B(3)(c) (renforcement facultatif)**
- **Statut**. La phrase est fidèle (voir le § 3).
- **Remplacement proposé**, qui ajoute l'appui interne au texte français et n'exige aucune source externe. Remplacer :
  ```latex
  l'outil les lit comme les pertes agrégées de B(1)(a), seules pertes que définit
  B(1).
  ```
  par :
  ```latex
  l'outil les lit comme les pertes agrégées de B(1)(a), seules pertes que définit
  B(1) et seules dont B(2)(g) pose les hypothèses du modèle (relations linéaire et quadratique avec
  les primes acquises, loi log-normale).
  ```

**M-3. Deux deux-points dans une même phrase (forme, `sec:controles`, l. 5696-5698)**
- **Problème**. « …de l'annexe~XVII~: les données peuvent être intégrées … (paragraphe~1, point~b))~: l'outil vérifie seulement… ». En plus, « Il en va de même » s'applique mal au point b), que l'outil vérifie en partie.
- **Remplacement**. Remplacer :
  ```latex
  Il en va de même des critères de l'article~219 qui ne relèvent pas de
  l'annexe~XVII~: les données peuvent être intégrées
  ```
  par :
  ```latex
  Relèvent aussi de l'entreprise, en tout ou en partie, les critères de l'article~219 qui ne
  relèvent pas de l'annexe~XVII. Les données peuvent être intégrées
  ```
- Le reste de la phrase est inchangé, y compris le texte de D-S2-3 mot pour mot.

**M-4. Intitulé de l'encadré des anomalies (forme, `sec:segments`, l. 2551)**
- **Problème**. « Anomalies rédactionnelles du texte consolidé » contredit la suite : les quatre anomalies sont aussi dans la version d'origine.
- **Remplacement**. Remplacer :
  ```latex
  \emph{Anomalies rédactionnelles du texte consolidé}, relevées sur la version consolidée du
  14~novembre~2024, sans incidence sur les calculs, et présentes aussi dans la version d'origine
  ```
  par :
  ```latex
  \emph{Anomalies rédactionnelles du texte}, relevées sur la version consolidée du
  14~novembre~2024, sans incidence sur les calculs, et présentes aussi dans la version d'origine
  ```

**Remarque de forme, hors de mon domaine (`docwriter`)**. Dans les notations, le renvoi « sous-section « spécification réglementaire » ci-après » n'utilise pas de `\ref`, alors que le label existe : `§\ref{sec:spec-lognormale}` (`docs/latex/CONVENTIONS.md`, `\ref`).

## 3. Réponse à la question « pertes accumulées » (B(3)(c))

- **Le texte français.** B(1)(a) définit les « pertes agrégées ». B(3)(c), p. 273, désigne y_t par « pertes accumulées », seule occurrence de ce terme. B(1) ne définit aucune autre perte. B(2)(g)(i)-(iii), p. 273, pose les hypothèses du modèle sur les « pertes agrégées », que B(4)-(6) ajuste sur y_t.
- **La version anglaise** (source secondaire : texte adopté reproduit par legislation.gov.uk, lu par l'extrait d'un moteur de recherche ; *non vérifié sur le JOUE EN*) emploie le même terme dans les deux points : « aggregated losses » en B(1)(a) et « the aggregated losses in segment s in a particular accident year t are denoted by y_t » en B(3)(c). Si elle est confirmée, « accumulées » n'est qu'une variante de traduction.
- **Verdict : lecture fidèle**, à garder comme lecture de l'outil, sans la requalifier.
  - D-S2-1 la couvre implicitement : la décision définit y_t par le contenu de B(1)(a).
  - La session peut demander au mainteneur de le confirmer d'une ligne dans `decisions-mainteneur.md`, mais rien ne l'impose.
- `legislation.gov.uk` ne se résout pas dans la session : il faut autoriser ce domaine dans les réglages réseau pour lire le texte anglais directement.

## 4. Constats hors périmètre (ADR 0018) : la session trie

| Constat | Gravité | Critère | Preuve |
|---|---|---|---|
| La réponse 2 de l'EIOPA à la question 2580 lit les dépenses de B(2)(f) comme « all the expenses listed in Article 31(1), points (a) to (d) ». La liste de `sec:controles` résume B(2)(f) par « dépenses de gestion incluses », formule que l'on peut lire de façon restrictive. Le `.tex` dit expressément ne pas reprendre ce point. | mineur | **aucun** (lacune, aucune affirmation fausse) | `decisions-mainteneur.md`, relevé de la question 2 ; `.tex`, entrée de `sec:biblio` et liste l. 5684 |
| `R/engine.R`, commentaire d'en-tête du commit `98b458c` : « borne supérieure… 30.1.2027, règlement délégué (UE) 2026/269… facteur NP de l'art. 117, paragraphe 3 ». Hors du périmètre de la consultation : je ne l'ai **pas vérifié**, et le texte de 2026/269 n'est pas versionné. | non évalué | à évaluer par une revue `regulatory` avant la remise si ce commentaire passe dans le `.tex` | `git show 98b458c` |

## 5. Points non vérifiés

- Le JOUE en anglais pour B(1)(a) et B(3)(c) : je n'ai qu'une source secondaire (voir le § 3).
- La réponse EIOPA mot pour mot : ma lecture passe par un outil qui reformule. Le relevé de la session (curl, 16/11/2026) fait foi ; je n'ai confirmé que les métadonnées et la substance.
- Les 25 images restantes de la consolidée (B et C) : je les ai relues à l'étape 1, et leur identité tient au contrôle md5. J'ai relu à nouveau B(5), π_t, B(6) et C(4).
- La date d'application et l'objet du règlement délégué (UE) 2026/269 (§ 4).

Fichiers concernés :
- `R/engine.R` (l. 10958 ; l. 1436-1470, 1779-1800, 2168-2181)
- `tests/unitaires/test_controles_entree.R` (l. 47-60)
- `docs/latex/doc_tests_usp.tex` (l. 2549-2564, 3452-3473, 3518-3660, 4526, 5671-5710, 18856-18862, 20725-20733)
- `tests/unitaires/test_modele_lognormal.R`, `tests/unitaires/test_calibration.R`

Sources :
- [EIOPA Q&A 2580](https://www.eiopa.europa.eu/qa-regulation/questions-and-answers-database/2580_en)
- [legislation.gov.uk, annexe XVII (texte adopté, source secondaire, lu par un extrait de recherche)](https://legislation.gov.uk/eur/2015/35/annex/XVII/2014-10-10/data.xht)
