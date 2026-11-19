# S5, bootstrap Merz-Wüthrich : rapports versés (19-20/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/bootstrap-merz-wuthrich`, PR brouillon #609, base `e4a8ae4` (fusion d'A1, PR #605). Issues #445, #492, #387, #246, #607 ; `Refs` #602, #603, #604, #608 (étape P), #206, #305, #463. Plan : soixante-dixième point de `docs/feuille-de-route.md`, fiche « Branche S5 — Bootstrap Merz-Wüthrich » ; décisions Q-70-1 à Q-70-5 du 19/11, toutes en (a).

## Contenu du dossier

- `actuary-1c-protocole-246.md` : protocole de l'outil de double bootstrap (#246), par `actuary-approfondi` (étape 1c) ; décisions D-1 à D-4 du mainteneur.
- `actuary-1a-specification-492-avis-b1.md` : spécification de #492 et avis sur la piste B1 de #445 (étape 1a).
- `actuary-1b-protocole-387.md` : protocole de la mesure de couverture (#387, étape 1b) ; décisions Q-1b-1 à Q-1b-8, réponses sur Q5, Q8 et Q9.
- `actuary-4-lecture-mesure-387.md` : lecture de la mesure L0 de #387 (étape 4), préparatoire au point d'arrêt D2.
- `actuary-8-validation-s5.md` : validation de fond de l'étape 8 (quatre parties).
- Le rejeu sous Windows (étape P) a son propre dossier : `docs/revues/20261119-s5-rejeu-windows/`.

## Synthèse

### Étape 0 et étape P
- Ouverture : `94b03ac` (70e point d'étape, Q-70-1 à Q-70-5 en (a)).
- Étape P, rejeu sous Windows au poste du mainteneur par une session locale, au SHA `8a3ebc5` (module xlsx identique à `e4a8ae4`) : préparation `d5803fc`, versement `4e6539e`. (i) à (iv) tenus : **condition de la sortie du brouillon remplie**. (v) : deux écarts du témoin sous `openxlsx` 4.2.9, égaux à la liste 4.2.5.2 ; lecteur interne 38 sur 38. (vi) : constat de #608 non reproduit avec `subst`. Témoin facultatif : dérive connue de JS1 sur `premium_interieur` (1,814e-06), pas une régression de S5.

### Étapes 1a, 1b, 1c : spécifications et protocoles (`actuary-approfondi`)
- 1c (#246) : `73a31ea`, décisions `e923a3e`.
- 1a (#492, B1 de #445) : `b5efbef` ; point d'arrêt A non déclenché ; B1 et l'essentiel de B2 déjà réalisés par #513.
- 1b (#387) : `cb73e11`, décisions `116576d`, réponses `444f96c`, avant toute exécution.

### Étape 2 : #445, identique au bit près
- `306d4bf` (B2), `f65dfef` (B3), `c1b578f` (B4), `5afc33d` (`tests:`). Six cas au seuil 0, `identical()` sur 300 triangles ; reserve2 17,03 → 15,41 s, premium_interieur 17,70 → 16,28 s. B1 sans objet.

### Étape 3 : #492
- `d65c1b4` : champ `bootstrap$n_sans_sigma`, `reserve2.rds` régénérée par la CI (exécution 44580488447) ; seule feuille ajoutée, `n_sans_sigma = 0` ; σ_USP, p-values et verdicts inchangés. Visa d'`actuary-approfondi` sans réserve.

### Étape 4 et point d'arrêt D2 : #387
- Script `e6547ad` ; mesure L0 `692fb00` (`INTEGRITE OK`) ; lecture `d4eb433` : profil **Ω3** (percentile à 90 % couvrant 0,573 et 0,617 sur le triangle de contrôle sous E et N, 0,52 à 0,62 sur les cinq profils ; aucun « basic » mesuré ne rétablit le niveau) et **Λ1**.
- D2 : **décision (b) du mainteneur** (`63e0d30`) ; note de l'application requalifiée (`2037ec1`, `964d5e9`), commentaires du moteur alignés (`8a3ebc5`) ; 4b sans objet ; issue #610 créée hors S5.

### Étape 5 : #246
- Outil `3808265`. Mesure sur `reserve2` en session cloud, sous Linux : pré-vol refait au commit `75e144e` (durée prévue 0,80 h à 4 processus), puis `--ecrire`, R = 1 000, B = 999, 2 869 s, **`INTEGRITE OK`** ; (r2) 13 sur 13 clés identiques au brut de #297, 9 sur 9 au brut de #206. Sorties : `4585867` (`docs/tableaux/20261119-issue246-double-bootstrap-reserve2.md` et `-brut.tsv`).
- Lecture d'`actuary-approfondi` (étape 8, objet 1) : les quatre ECHEC observés restent sous 0,05 dans la loi simulée de leur p, bornes de Clopper-Pearson comprises ; les OK restent au-dessus de 0,10 ; constat de simulation sous le modèle ajusté et la loi E, à T = 8, qui ne change aucun verdict ; aucune phrase du `.tex` demandée (« Le document ne cite aucune sortie de cet outil » reste exact).

### Étape 6 : #607
- Volet `claude:` (`ff81d97`, sur instruction du mainteneur) ; volet `CONVENTIONS.md` au passage de `docwriter` (`75e144e`).

### Étape 7 : règle 9 (`docwriter` en `high`, poste local)
- `f2a3b9a`, `215c39a` (#492) ; `47245b4` (#387) ; `5dec335` (#445) ; `b89489f` (#246) ; `75e144e` (#607, E11, `\versiondoc` 4.3).

### Étape 8 : validation (`actuary-8-validation-s5.md`)
- `actuary-approfondi` : sortie de #246, tableaux de #492 et rendu de D2 visés **sans réserve** ; diff du `.tex` visé **avec réserves** : une réserve majeure (M-1, la plage de couverture de la fiche `fiche:ic-bootstrap` faisait lire deux triangles là où il n'y en avait qu'un) et quatre mineures.
- Corrections par `docwriter` (`high`) : `0489800`, toutes portées, longueur et pagination inchangées (fiche aux pages 321 à 323 ; `controle_doc_nd.R --bloquant` et concordance `--strict` à 0). Contrôle ciblé d'`actuary` : réserve levée, **quatre objets visés sans réserve**.
- Question complémentaire : « MSEP en erreur » absente de la parenthèse des causes de `n_sans_sigma` (note, `.tex` l. 6173 et 14491), relevée par `audit` et `/code-review` : écartée par `actuary` (ADR 0018).

### Étape 9 : revue finale (règle 10, `git diff origin/main...HEAD`)
- `app-review` en Opus sur `75e144e` : **conforme**, aucun constat dans le périmètre ; un hors périmètre (histogramme Merz-Wüthrich conditionnel sans le dire), critère aucun, déjà écarté.
- `audit` en `high` sur `4585867` : **conforme avec réserves**. Unitaires par lots 1 091 + 1 796 + 1 237 = 4 124 assertions, 0 échec ; reproductibilité, six cas conformes à écart 0 ; `comparer_references.R --seuil 0` conforme ; concordance `--strict` à 0 ; section 7ter non touchée ; pistes de #445 identiques au bit près (moteur de `main` et de la tête côte à côte) ; compte de #492 vérifié (77 = 199 − 122 sur le triangle volatil). Deux mineurs, écartés : « MSEP en erreur » (ci-dessus) ; deux fichiers absents de `tests/durees_unitaires.tsv` (table rafraîchie sur les durées de la CI de `main`, #561).
- `/code-review` (`medium`, sur `origin/main...4585867`) : quatre constats, tous mineurs, écartés (ADR 0018 ; PR #609).
- Audit léger de `0489800` : **conforme avec réserves** ; mineur l. 9116 déjà tranché par `actuary` (exact tel quel) ; question sur m-4, formulation maintenue par `actuary` (`6174cec`).
- `\datedoc` au 20 novembre 2026, jour du PDF (`3ea33f4`) ; `\dateconsultation` inchangée.

### Étape 10 : veille et PDF
- *(à compléter)*

## Constats hors périmètre (ADR 0018)

- Aucune issue nouvelle dans ces étapes ; #610 a été créée au point d'arrêt D2.
- **Écartés (mineurs)** : voir la PR #609, « Constats mineurs écartés (ADR 0018) ».
