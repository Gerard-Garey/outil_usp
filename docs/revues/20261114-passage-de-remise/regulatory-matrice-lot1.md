# Matrice de conformité KR, étape 6, lot 1 sur 3 : art. 218 à 220, annexes II et XIV (M6), crédibilité et mélange

> Rapport de `regulatory` (effort `high`), versé intégralement par la session principale (Q-54-10). SHA du gel `a2f9c3a` ; `.tex` 3.7. Rien n'a été écrit dans le dépôt, ni issue créée ou commentée.

## En tête : pas de motif d'arrêt, mais une réserve à confirmer par le mainteneur

**Aucun écart de conformité majeur.** Pour toute date de référence antérieure au 30/01/2027, l'outil calcule exactement ce que prescrit le texte consolidé du 14.11.2024. Cela vaut pour le σ standard, le barème, le facteur c, le facteur √((T+1)/(T−1)) et le mélange.

**Réserve E-L1-1 : le domaine de validité n'a pas de borne supérieure.**
- Le règlement délégué (UE) 2026/269 est publié (JO série L 2026/269 du 18.2.2026). Il est applicable au **30/01/2027** (art. 2).
- Son art. 1er, point 29) b), remplace l'art. 117(3). À partir de cette date, le facteur NP de 80 % (segments II-1, II-4, II-5) ne s'applique plus que « s'il existe une telle réassurance non proportionnelle pour ce segment précis, ou par un facteur de 100 % dans les autres cas ».
- Or `np_standard` (`R/engine.R` l. 98) applique 80 % sans condition. Le `.tex` (l. 2180-2187) et le code (l. 57-61) déclarent l'outil valable pour toute date de référence postérieure ou égale au 01/01/2020.
- **Chiffrage**, données nettes, II-1, T = 8, sans réassurance NP : l'outil rend σ_USP = 0,1032524 ; le texte de 2027 donne 0,1114524. Écart de −0,0082 (−7,4 %), du côté non prudent.
- **Si la date de référence du dossier est postérieure ou égale au 30/01/2027, l'écart devient majeur et c'est un motif d'arrêt.** Le mainteneur doit confirmer cette date.
- C'est le sujet de #504, dont la lecture était prévue après la remise. Proposition : un commentaire sur #504 plutôt qu'une nouvelle issue (§ 9).

## Base de la revue

- **Code** : SHA du gel `a2f9c3a`. La tête est passée à `547afd3` pendant la revue ; entre les deux, seuls `docs/feuille-de-route.md` et `docs/revues/` changent ; `R/` et le `.tex` sont identiques.
- **`.tex`** : version 3.7, dernier commit `3d421d8`.

**Textes lus :**
- Version consolidée du 14.11.2024 : art. 19, 117, 148, 218 à 220 ; annexes II et XIV (marqueur ▼M6) ; annexe XVII, B(4), C(4), D(4) en rendu graphique, et section G.
- JOUE L 12 du 17.1.2015 : art. 117 et 148 (p. 74-75 et 94) ; art. 218 à 220 (p. 142-144) ; annexe II p. 230, annexe XIV p. 269 ; B(4) p. 273 et C(4) p. 275, lus à l'image, identiques au consolidé ; section G p. 282.
- Règlement délégué (UE) 2019/981 (manifestation xhtml FR de l'Office des publications, CELEX 32019R0981) : art. 1er, points 66) et 74) ; art. 2 : « L'article 1er, points 50), 59) à 61), 66) et 74), est applicable à partir du 1er janvier 2020 » ; annexes I et IX : les 32 valeurs sont identiques au consolidé.
- Règlement délégué (UE) 2026/269 (manifestation xhtml FR, CELEX 32026R0269) : art. 1er, points 29) (art. 117) et 39) (art. 148) ; art. 2 ; aucun point ne modifie les art. 218 à 220 ni les annexes II, XIV et XVII, ce qui confirme le commentaire du 08/11 sur #504.

**Contrôles chiffrés** (`charger_moteur()`, `LC_ALL=C.UTF-8`) :
- 16 segments × 4 cas (primes brutes, primes nettes, réserve n° 1, réserve n° 2) : σ standard et point de l'art. 218 conformes.
- `usp_credibilite()` pour T = 5 à 16 sous les deux barèmes : conforme à G(1) et G(2).
- `run_engine` primes, II-1, données brutes : σ_USP = 0,1114524114, égal à c·σ̂·√(9/7) + (1−c)·0,10 au dernier chiffre.
- reserve1 XIV-1 : c = 0,81, σ standard = 0,057.
- reserve2, `triangle_mw.csv`, segment II-5 : c = 0,59 (I + 1 = 8), σ standard = 0,11, `correction_taille` = 1.
- Les numéros de ligne du xhtml cités en commentaire du code (l. 63-66, 102-105) sont exacts.

## 1. Article 218

| Texte | Code (`R/engine.R`) | `.tex` | Verdict |
|---|---|---|---|
| 218(1), chapeau | `usp_parametre_standard()` 689-749 | `sec:segments` 2336-2357 (« Portée ») | conforme |
| (1)(a)(i) écart type de primes net (art. 117(2)(a)) | point a) i) sur données nettes, 701-709 ; NP × σ brut, 705 | 2360-2393 | conforme au texte en vigueur ; NP standard (M13) : interprétation tranchée ; **réserve E-L1-1** après le 30/01/2027 |
| (1)(a)(ii) écart type brut (art. 117(3)) | point a) ii) sur données brutes, 706 et 710 | 2369-2380 | conforme |
| (1)(a)(iii) facteur NP propre | non couvert | 2337-2346 | conforme (hors périmètre déclaré) |
| (1)(a)(iv) écart type de réserve (art. 117(2)(b)) | point a) iv), σ(res,s) de l'annexe, 723-736 ; `.run_engine_mw()` 14583-14586 | 2394-2398 | conforme ; **réserve E-L1-1** (117(2)(b) renverra à 117(4)-(5) après le 30/01/2027) |
| (1)(b) et (d) révision | non couvert | 2347-2349 | conforme (hors périmètre déclaré) |
| (1)(c)(i), (ii), (iv) santé non-SLT | points c) i), ii), iv), 697 | 2360-2398 | conforme. Le renvoi de c) iv) à l'art. 148(2)(a) au lieu de b) est une anomalie du texte, identique en 2015 (p. 142) et au consolidé ; documentée en 2438-2441 |
| (1)(c)(iii) | non couvert | 2342-2345 | conforme (hors périmètre) |
| (1), dernier alinéa (pas a) ii) et a) iii) à la fois) | a) iii) non couvert | — | sans objet |
| (2), (3) contrat NP reconnaissable (▼M6) ; (4) inflation | — | 2342-2346 | sans objet |

## 2. Article 219

| Texte | Code | `.tex` | Verdict |
|---|---|---|---|
| (1) chapeau | contrôles de validité | `sec:controles` 3864-3877 | conforme |
| (1)(a), art. 19(1)-(3) | `engine_valider_donnees()` 9241-9246 ; libellé de troncature 15812-15819 ; MW-04 10283-10288 | 4220-4221 ; 2299-2325 ; 14780-14786 | conforme. Renvois à l'art. 19(1)(b) exacts (consolidé : « aucune donnée pertinente n'est exclue de ce calcul sans justification »). **Écart mineur E-L1-3** : le motif l. 9242 cite « (art. 19) » sans l'art. 219(1)(a), alors que le `.tex` (4220) écrit « Art. 219, paragraphe 1, point a), renvoyant à l'art. 19, paragraphe 1 » |
| (1)(b) intégration aux méthodes | contrôles de forme et de lecture | aucune mention | **écart mineur E-L1-2** (silence du `.tex`) |
| (1)(c) art. 101(3) de la directive (« 2009/13/CE » dans les deux versions, coquille du texte) | — | aucune mention | **écart mineur E-L1-2** |
| (1)(d) exigences propres à chaque méthode | `usp_valider_ajustement()` 1979-1985 ; `mw_valider_ajustement()` 11097-11102 | 4434-4458, 4925, 5027, 20087-20089 | conforme (lecture (a) déjà tranchée, #188 et #192) |
| (1)(e) documentation | libellé « profondeur » 15817-15818 | 3872-3873, 2302-2303, 5104-5107 | conforme (à la charge de l'entreprise, écrit) |
| (2)(a)-(e) données externes | rien | **aucune mention dans le `.tex`** (« externe » n'y vise que les résidus studentisés) | **écart mineur E-L1-2** : l'outil ne vérifie pas ces critères, et le dossier ne le dit pas |

## 3. Article 220

| Texte | Code | `.tex` | Verdict |
|---|---|---|---|
| (1) chapeau | `run_engine()` : trois méthodes de l'annexe XVII | 2350-2357 | conforme |
| (1)(a) méthode des primes | motif 1980-1985, point a) | 2386, 4440-4443 | conforme |
| (1)(b) réserve n° 1 ou n° 2 | motif point b) 1985 ; 11101-11102 ; MW-04 | 3982-3986, 4921, 5029, 5100-5102, 14789-14790 : conformes. 4397-4398, 4409-4410, 4444, 14698-14703 : voir § 7 | conforme pour le code ; `.tex` : voir § 7 |
| (1)(c) et (d) | non couverts | 2337-2349 | sans objet |
| (2) méthode la plus précise, à défaut la plus prudente | aucun choix fait par l'outil | 4445-4450 ; 14704-14716 (citation exacte du consolidé) ; 20082-20084 | conforme (le choix est déclaré comme relevant de l'entreprise) |

## 4. Annexes II et XIV (M6), facteur NP et domaine

| Texte | Code | `.tex` | Verdict |
|---|---|---|---|
| Annexe II, 24 écarts-types (▼M6) | `ANNEXE_II` 69-100 | tableau 2194-2214 | conforme, 24 sur 24 (consolidé et 2019/981, annexe I) |
| Annexe XIV, 8 écarts-types (▼M6) | `ANNEXE_XIV` 109-125 | tableau 2217-2229 | conforme, 8 sur 8 (annexe IX de 2019/981) |
| Neuf valeurs de 2015 remplacées | commentaire 53-56 | 2241-2247 | conforme (JOUE p. 230 et 269 relus) |
| Application de M6 au 01/01/2020 (points 66 et 74, art. 2) | commentaire 57-61 | 2171-2185 | conforme. Pages p. 39-41 et 64 de L 161 non revérifiées (manifestation sans pagination) |
| NP standard, art. 117(3) (80 % pour 1, 4, 5 ; 100 % ailleurs) et art. 148(3) (100 %) | `np_standard` 98 et 123 | 2234-2247, 2341-2346, 2382-2393 | conforme au texte en vigueur (JOUE p. 75 et 94 ; consolidé ▼B) ; **E-L1-1** à partir du 30/01/2027 |
| `SEGMENTS` | 130-140 (tables dérivées) | — | conforme |
| Borne supérieure du domaine | absente (57-61) | absente (2180-2187) | **E-L1-1** |

## 5. Crédibilité et mélange

Recoupe les lots 2 et 3, dont les verdicts sont partagés.

| Texte | Code | `.tex` | Verdict |
|---|---|---|---|
| G(1) `CRED_LONG` ; G(2) `CRED_COURT` | 144-150 | 2250-2259 | conforme (JOUE p. 282 et consolidé ▼B) |
| Affectation : II-1, II-5, II-6 au barème long, le reste de l'annexe II et toute l'annexe XIV au barème court | `usp_bareme_segment()` 391-398 | 2250-2259 | conforme |
| « 15 et plus » / « 10 et plus » ; refus sous 5 ans | `usp_credibilite()` 351-356 | 1486 | conforme |
| G(3)(a)-(b) durée = T retenu | `.engine_credibilite_appliquee()` 423-459 | 2290-2333 | interprétation tranchée (lecture (A), #104) |
| G(3)(c) durée = I + 1 | `mw_parametre()` 11242-11243 | 14436-14438 | conforme |
| Barème saisi, barème sans segment | dérogation, 426-456 ; `engine_derogations()` 15769-15787 | 2261-2288 | conforme (dérogation déclarée, #93) |
| B(4) et C(4) : c·σ̂·√((T+1)/(T−1)) + (1−c)·σ standard | `usp_parametre()` 2113-2127 ; T = `fit$T` = `length(x)`, 1794 | formule non transcrite (lot 2, E1) ; forme implicite en 2283, 13290-13294, 13408 | code conforme au dernier chiffre ; `.tex` : écart mineur déjà proposé au lot 2 |
| √((T+1)/(T−1)) | 2116 | 2297, 14435 | conforme (même T que la durée de G(3)) |
| D(4) : c·√MSEP/R̂ + (1−c)·σ(res,s), sans facteur | `mw_parametre()` 11241-11255 ; IC 14637 | 14654-14658 (formule identique à l'image) ; 13414-13415 | conforme |

## 6. Motifs de refus et conditions qui citent ces articles

| Motif | Code | Verdict |
|---|---|---|
| `usp_valider_ajustement()`, après #573 (relu) | 1963-2029 | conforme ; huit motifs et renvois (220(1)(a)/(b), 219(1)(d), B(2)(g)/C(2)(e)) exacts |
| `.nature_erreurs()` : B(2)(c)-(d), C(2)(c), D(2)(f) | 630-664 | conforme |
| B/C(2)(b) : profondeur et longueur | 9279-9282, 9393-9417 | conforme |
| Crédibilité partielle | 9357-9362, 10469-10475 | conforme |
| `mw_valider_ajustement()` : R̂ ≤ 0, MSEP, triangle dégénéré | 11047-11104 | conforme (interprétations M4 et #192 déjà tranchées) |
| MW-04 (art. 219(1)(a) et 19(1)(b)) | 10283-10288 | conforme. Remarque de forme : « section D, point (2)(e) », au lieu de « paragraphe 2, point e) » selon la convention de `sec:notations` |
| Valeurs manquantes « (art. 19) » | 9242 | **E-L1-3** (mineur ; code gelé) |
| Ligne « profondeur » d'`engine_derogations()` | 15812-15819 | conforme |

## 7. Points imposés (#573 ; constat seulement, `docwriter` les reprend à l'étape 7)

- **`.tex` l. 4397-4398**, « pour la méthode de réserve n° 1 le rappel que la méthode n° 2 reste ouverte » : faux par rapport au code depuis `c5a1953`. **Écart mineur doc ↔ code.** **L. 4409-4410** (« le fondement et le rappel de la méthode n° 2 étant ceux de la forme 1 ») est dans le même cas, comme l'a déjà relevé le lot 2. Ces lignes sont à retirer, sans remplacement.
- **`.tex` l. 4444**, « ce point ouvrant aussi la méthode n° 2 » : **conforme**, « ouvrir » se lisant comme « prévoir » (verdict du lot 2). Harmonisation recommandée avec 3983 et 5100 : « prévoyant aussi ». **L. 4445-4450** : conforme ; on peut ajouter « selon l'article 220, paragraphe 2 » après « relève de l'entreprise ».
- **Puce de `sec:mw`, l. 14698-14703** (l'ancre « ~14664 » du brief tombe sur la formule de D(4)) : « l'entreprise à qui l'outil refuse la seconde conserve la première » fait de la méthode n° 1 un repli acquis. Or elle a ses propres exigences (C(1), C(2), art. 219(1)(d)) et peut elle-même être refusée (#188). **Écart mineur.**
  - Le texte de remplacement du lot 3, E-3, est approuvé : faculté de l'art. 218(1), « pouvant être remplacés » ; art. 220(1)(b) ; art. 220(2).
  - Remarque de forme : « ce qui est la condition de son admissibilité » est un critère de l'outil, à qualifier comme tel, par exemple « condition que l'outil retient ».
  - Le décompte des appuis est incohérent : « deux appuis et une orientation » en 14686, puis « Un quatrième appui » en 14720.

## 8. Écarts et interprétations du lot

- **E-L1-1, domaine après le 30/01/2027.** Mineur à la date de la remise, majeur si la date de référence du dossier tombe au 30/01/2027 ou après. Configurations touchées :
  - données nettes de primes II-1, II-4, II-5 sans réassurance NP (chiffrage ci-dessus) ;
  - méthodes de réserve en présence d'une couverture pour développements défavorables (nouvel art. 117(4)-(5) et 148(4)-(5)).

  Le second point est une **interprétation à trancher** (`actuary`, puis le mainteneur), car le texte de 2027 admet deux lectures :
  - lecture A : le σ(res,s) de C(4) et D(4) devient le σ ajusté par Adjust(NP,s) ;
  - lecture B : il reste la valeur de l'annexe.

  Le code ne connaît que B, ce qui est sans effet sans couverture.
- **E-L1-2.** Art. 219(2) (données externes), 219(1)(b) et 219(1)(c) : rien n'en est dit dans le `.tex`. Écart mineur de documentation.
- **E-L1-3.** Motif « (art. 19) » sans l'art. 219(1)(a). Écart mineur ; le code est gelé.
- **Interprétations déjà tranchées, non rouvertes** : NP standard sur données nettes (M13) ; lecture (A) de la durée (#104) ; σ(res,s) en C(4)(e) ; dérogations σ et barème (#55, #93) ; barème court par convention sans segment ; lecture (a) de B(2)(g)(iv) et C(2)(e)(iv).

## 9. Suites proposées (à créer ou poster sur accord du mainteneur)

### (a) Commentaire proposé sur #504 (pas de nouvelle issue)

> *Rédigé par l'agent regulatory (IA).* Lecture de l'acte, matrice de KR, lot 1, 14/11/2026, manifestation xhtml FR de l'Office des publications (CELEX 32026R0269, JO série L 2026/269 du 18.2.2026).
>
> **Ce que change l'acte (applicable au 30/01/2027, art. 2)**
> - L'art. 1er, point 29) b), remplace l'art. 117(3). Le facteur NP (80 % pour II-1, II-4, II-5) ne s'applique plus que « s'il existe une telle réassurance non proportionnelle pour ce segment précis, ou par un facteur de 100 % dans les autres cas ».
> - L'art. 1er, point 29) a) et c), redéfinit σ(res,s) de l'art. 117(2)(b) par les nouveaux paragraphes 4 et 5. Le nouveau paragraphe 4 introduit Adjust(NP,s) pour les couvertures pour développements défavorables.
> - Le point 39) fait de même pour l'art. 148. La seconde phrase de l'art. 148(3) (100 % par défaut) est maintenue : rien ne change pour les primes en santé non-SLT.
> - Les art. 218 à 220 et les annexes II, XIV et XVII ne sont pas touchés.
>
> **Effet sur l'outil**
> - `np_standard` (`R/engine.R` l. 98) et la limite de périmètre (`R/engine.R` l. 57-61, `.tex` l. 2180-2187, `CLAUDE.md`, `.claude/rules/moteur.md`) valent jusqu'au 29/01/2027.
> - Ensuite, sur données nettes II-1, II-4, II-5 sans réassurance NP, le σ standard du mélange doit être σ brut. Exemple : II-1, T = 8, σ_USP 0,1114524 au lieu de 0,1032524, soit un écart de −0,0082 côté non prudent.
> - Pour les réserves avec une couverture pour développements défavorables, il faut trancher entre deux lectures du σ(res,s) de C(4)/D(4) : σ ajusté ou valeur de l'annexe.
>
> **Proposition**
> - Borner dès la remise le domaine à une date de référence antérieure au 30/01/2027, par une modification du `.tex` seul à l'étape 7 de KR si le mainteneur l'ajoute au périmètre. Le commentaire du code suivra après le gel.
> - Traiter le fond (entrée « réassurance NP en place », lecture de σ(res,s)) après la remise, par le circuit 2.
>
> Refs #504, #19, #55.

Suggestion : revoir les libellés de #504 (`needs-info`), puisque l'acte est maintenant lu.

### (b) Issue proposée

**Titre** : docs/moteur: art. 219 — données externes (paragraphe 2) et points b), c) absents du `.tex` ; motif « art. 19 » des valeurs manquantes sans renvoi à l'art. 219(1)(a)

**Libellés** : `bug`, `needs-triage`

**Corps** :

> *Rédigé par l'agent regulatory (IA).*
>
> ## Constat (matrice de KR, lot 1, code au gel `a2f9c3a`)
> - `docs/latex/doc_tests_usp.tex` ne mentionne ni l'art. 219, paragraphe 2 (critères supplémentaires pour les données externes, points a) à e)), ni l'art. 219, paragraphe 1, points b) (données intégrables aux méthodes standardisées) et c) (art. 101(3) de la directive ; le texte écrit « 2009/13/CE » dans la version d'origine, p. 143, comme dans le consolidé). L'outil ne vérifie pas ces critères, et le dossier ne dit pas qu'ils sont à la charge de l'entreprise. La liste des « Exigences de données non vérifiables par l'outil » (l. 5104-5125) ne couvre que l'annexe XVII.
> - `R/engine.R` l. 9242, dans `engine_valider_donnees()` : le motif « Valeurs manquantes : le calibrage exige des series completes (art. 19). » cite l'art. 19, qui vise les provisions techniques, sans l'art. 219(1)(a) qui le rend applicable. Le `.tex` (l. 4220) écrit « Art. 219, paragraphe 1, point a), renvoyant à l'art. 19, paragraphe 1 ».
>
> ## Attendu
> - `.tex` : une phrase dans `sec:controles` (ou dans la liste des exigences non vérifiables) sur l'art. 219(1)(b), (c) et (2), à la charge de l'entreprise ; la coquille « 2009/13/CE » ajoutée à l'encadré « Anomalies rédactionnelles » (l. 2432-2442), s'il cite le point c).
> - Code, après le gel : motif « (art. 219, paragraphe 1, point a), renvoyant à l'art. 19, paragraphe 1 ; annexe XVII, B/C(1) et B/C(2)(b)) », puis alignement des tests unitaires qui contrôlent ce texte.
> - Aucun σ_USP, aucune p-value ni aucun verdict changé ; références identiques. Il s'agit d'un libellé hors références, à vérifier par `grep` dans les `.rds`.
>
> ## Circuit
> Circuit 4 pour le `.tex` (`docwriter`, puis `regulatory`) ; circuit 3 pour le motif, après la remise sauf dégel.
>
> Refs #573 (matrice de KR, lot 1).

Les 32 issues ouvertes ont été relues : pas de doublon. Les points du § 7 relèvent de #573, la formule B(4)/C(4) de l'issue du lot 2, et la loi de 2027 de #504.

## Synthèse

- **Écart majeur** : aucun à la date de la remise. **La réserve E-L1-1 devient un motif d'arrêt si la date de référence du dossier est postérieure ou égale au 30/01/2027** : confirmation du mainteneur demandée.
- **Écarts mineurs** : E-L1-1 (domaine), E-L1-2 (art. 219(2), (1)(b), (1)(c)), E-L1-3 (motif « art. 19 ») ; l. 4397-4398, 4409-4410 et puce 14698-14703 (#573).
- **Couverture** : chaque paragraphe des art. 218, 219 et 220, les 32 valeurs des annexes II et XIV, les facteurs NP standard, `CRED_LONG`, `CRED_COURT` et leur affectation, `usp_parametre()`, `mw_parametre()` et le facteur √((T+1)/(T−1)) ont un verdict.
- **Validité** : la matrice vaut pour le PDF 3.8, sous réserve du contrôle aval, à l'étape 8, des passages réécrits à l'étape 7 (l. 4397-4398, 4409-4410, 4444, 14698-14720, et la borne de domaine si elle est retenue).

Sources :
- Règlement délégué (UE) 2026/269, ELI : https://eur-lex.europa.eu/eli/reg_del/2026/269/oj/eng ; texte lu sur la manifestation de l'Office des publications : http://publications.europa.eu/resource/celex/32026R0269
- Règlement délégué (UE) 2019/981 : http://publications.europa.eu/resource/celex/32019R0981
- EIOPA, Q&A 3578 (signalement de la modification de l'art. 117(3)) : https://www.eiopa.europa.eu/qa-regulation/questions-and-answers-database/3578_en
