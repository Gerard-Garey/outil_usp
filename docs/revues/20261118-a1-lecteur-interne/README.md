# A1, créneau d'absorption : lecteur interne seul, fins de ligne, chemin de lecteur, texte préservé, texte de formule — rapports versés (18-19/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/creneau-a1`, PR brouillon #605, base `c013568` (fusion de JS1). Issues #604, #602, #603, #594, #606. Plan : soixante-neuvième point de `docs/feuille-de-route.md`, fiche « Créneau d'absorption A1 » ; décisions E-18/11 (Q-68), E-18/11 (Q-69), E-18/11 (arrêts A et B), E-18/11 (arrêt D) et E-19/11 (A1). Mise en œuvre de l'ADR 0020 (lecture des classeurs par le seul lecteur interne).

## Contenu du dossier

- `inventaire-ecarts.md` : inventaire des écarts consignés entre le lecteur interne et `openxlsx::read.xlsx()` (`actuary-approfondi`, étape 1a), avec sa sonde (`sonde-inventaire.R`) et la sortie de la sonde relancée par la session sous `openxlsx` 4.2.5.2 (`sortie-sonde-inventaire.txt`).
- `relecture-xml-1.0.md` : relecture à la source de XML 1.0 (5e édition), §§ 2.2, 2.4, 2.10, 2.11, 3.1, 3.3.3, 4.4.2 et 4.6, par la session (étape 1c).
- `specification-594-amendee.md` : spécification amendée de #594 (`actuary-approfondi`, étape 1b), avec ses scripts et sorties (`specification-594/`).
- `specification-606.md` : spécification de #606 (`actuary`, étape 1d), avec ses scripts et sorties (`specification-606/`).
- `mise-en-oeuvre-594.md` : deux énoncés de la spécification amendée corrigés par la mesure (T15, décompte de T5), par la session d'après `actuary` et l'audit léger (étape 6).
- `validation-etape-8.md` : validation du diff du `.tex` et des tableaux avant / après par `actuary` (étape 8).

## Synthèse

### Étape 1 : spécifications et sources
- **1a, inventaire** (`89d4b39`) : quatorze écarts sur des classeurs admis (A1 à A14). Aucun ne donne tort au lecteur interne, hors A14 (fins de ligne, #602). Un défaut commun aux deux chemins, **C1** (texte d'une cellule `t="str"` lu sans décodage, colonne `xt` retenue en silence sur un classeur forgé), soumis au point d'arrêt B : gardé, devenu #606, cinquième place d'A1.
- **1b, spécification amendée de #594** (`89d4b39`, `3cfa229`) : admission uniforme de la forme exacte `<t xml:space="preserve">` en chaîne en ligne, fondée sur la sémantique du seul lecteur interne ; critère C1 tenu sur 28 classeurs sur 28 ; 13 classeurs du corpus deviennent lus. Arrêt A : A-1 à A-5 en (a), `TEXTE_REFUS_R3` repris.
- **1c, XML 1.0** (`7d91b73`, complétée dans `89d4b39` et `d3fc9a1`) : citations mot pour mot, page lue le 18/11 (md5 consigné), après autorisation de `www.w3.org` dans l'environnement de la session. Préalable de 3b ; arrêt C sans objet.
- **1d, spécification de #606** (`d3fc9a1`) : options (i) refus et (ii) refus puis décodage. Arrêt D : D-1 (a), option (ii), et D-2 (a), portée sur tout le classeur.

### Étapes 2 à 6b : réalisation
- **#604**, ADR 0020 :
  - 2a `9bba313` : corpus de 38 classeurs dans `tests/donnees/classeurs/`, md5 identiques ;
  - 2b `46525b8` (`moteur:`, `coder-approfondi`) : retrait de l'embranchement `openxlsx` ; 42 classeurs sur 42 `identical()` à la lecture par le lecteur interne seul à `c013568` ;
  - 2c `43dd3d1` (`tests:`) : témoin borné à trois emplois, assertions de parité converties en valeurs attendues ; avec `openxlsx` 4.2.5.2, aucune ligne « [saute] » ;
  - 2d à 2g `c2ec69c`, `ad3f612`, `efe57b8`, `0c7742d`, `c20cefa` : job « Témoin openxlsx et archive zip » (identifiant `parite-lecteurs` gardé), README, `CLAUDE.md` « Architecture » (Q-68-8 (a)), ADR 0016 annoté.
- **#602** : 3a `17d84e6`, `edc8206` (écriture en octets des parties du classeur et du CSV) ; 3b `c21920e`, `f4ee973` (fins de ligne littérales normalisées à l'entrée de chaque partie lue, XML 1.0, § 2.11, avant le décodage ; fuzz différentiel de l'audit sur 7 684 classeurs forgés, aucune admission ni aucun refus changé).
- **#603** : 4 `fbe5a5b`, `da100f1` (forme `X:` sans barre refusée sous Windows avant toute écriture ; système simulé sous Linux).
- **#594** : 6 `a072411`, `b18ba7b`, `a7f1af4` (`coder-approfondi` en `high`) : 13 classeurs passent de « refus R3 » à « lu », sortie aval `identical()` à la source CSV ; libellé de R3 modifié. **Visa du mainteneur** le 19/11 (`issuecomment-7003636855` sur #594).
- **#606** : 6b `f8d2c96`, `b3b5dd7` : `<v>` des cellules `t="str"` soumis au refus des références puis décodé ; le cas forgé F1 (σ_USP rendu à tort) est refusé. **Visa du mainteneur** le 19/11 (`issuecomment-7004495189` sur #606).
- Chaque commit `moteur:` porte son tableau avant / après et a eu son audit léger (conforme ; mineurs corrigés avant le commit).
- Six cas de référence identiques au seuil 0 à chaque commit ; aucun σ_USP, aucune p-value ni aucun verdict des six cas changé ; références ni patchées ni régénérées.

### Étape 7 : règle 9 (`docwriter`, `high`)
- Un commit `docs:` par issue : `3e2d957` (#604), `f252b24` (#602), `641da8b` (#603), `d051c6c` (#594), `9d7a4ce` (#606) ; `69283e0` : `\versiondoc` 4.2 (Q-69-2 (a)) et `\datedoc` au 19/11.

### Étape 8 : validation (`validation-etape-8.md`)
- `actuary` : **visa avec réserves**. Aucun bloquant ; un majeur (M1 : `\datedoc` déplacé sans que soient refaites les consultations datées « à la date d'établissement »), levé par l'exception E11 (ci-dessous) ; neuf mineurs (m1 à m9), repris par `docwriter` dans `c182d0d`, sauf m8 (message de `46525b8` : A12 omise ; A1 à A4, sur poste muni d'`openxlsx`, font d'une erreur R un classeur lu), levé sans réécriture de commit par le tableau « hors références » complet joint à la PR.
- Tableaux visés : #604 (`46525b8`), #602 (`17d84e6`, `c21920e`) et #603 (`fbe5a5b`), les lignes Windows restant « attendu, non mesuré » jusqu'au rejeu (10b) ; #594 et #606, déjà visés par le mainteneur, concordent avec les spécifications et avec la remesure.
- Liste fermée du témoin (`ECARTS_TEMOIN_OPENXLSX`, deux entrées sous 4.2.5.2) et note `mise-en-oeuvre-594.md` : cohérentes avec l'ADR 0020, point 3.

### Étape 9 : revue finale (règle 10, `git diff origin/main...HEAD`)
- `audit` en `high` : **conforme**, aucun bloquant ni majeur. `/code-review` (`medium`).
- Sept mineurs corrigés, correction revue sur son diff : `2fb3f88` (dossier de Q-66-3), `3d42473` (`CONTEXT.md`, témoin), `da0a84b` (garde du chemin d'`engine_ecrire_csv()`, rétablie après #602 ; commentaires remis au présent), `9e0bff6` (tests correspondants, ligne « [saute] », en-tête du témoin, libellés sans « repli »), `6998701` (`.tex`, témoin aussi écrivain réel).
- Deux constats antérieurs ou de règle générale devenus des issues, sur accord du mainteneur : #607 (règle de `\datedoc`) et #608 (chemin Windows à barre initiale unique). Hors A1 (plafond de cinq numéros) : à rattacher au plan par `architect`.
- Compte des `verifier()` de `test_controles_entree.R` : 606 (à `c013568`) → 644.

### Exception E11 (M1 de l'étape 8)
- Décision du mainteneur du 19/11 : seconde date. `\dateconsultation` (18/11/2026) date les six mentions de consultation ; `\datedoc` ne date plus que la page de garde (`3678044`, contrôle `controle_doc_nd.R` étendu ; `b2be8bf`, `.tex` et `CONVENTIONS.md`, § 5). La règle générale reste à #607.

### Étapes 10 à 12
- **10a** : sans objet, aucun classeur Excel ni LibreOffice ; limite consignée au `.tex` (E-18/11 (Q-69)).
- **10b** : rejeu sous Windows **reporté à la prochaine branche** (décision du mainteneur du 19/11). Les lignes Windows des tableaux de #602 (`"a\nb"` relu `identical()`) et de #603 (`X:f.xlsx` refusé sans fichier) restent « attendu, non mesuré » à la fusion ; le rejeu comprend aussi l'emploi 1 du témoin sous `openxlsx` 4.2.9 (liste des écarts non datée pour cette version).
- **11** : veille de #463 du 19/11 (`issuecomment-7007125739`) : aucun fait nouveau ; Légifrance non lisible depuis la session cloud. PDF de fin de branche `74b986d` (`.tex` de `b2be8bf`, pdfTeX-1.40.25, 465 pages, aucune référence indéfinie). CI de `b2be8bf` entièrement verte.
- **12** : cette synthèse.

## Constats hors périmètre (ADR 0018)

- Issues nouvelles : #606 (gardée et placée dans A1), #607 et #608 (hors A1).
- **Écartés (mineurs)** : voir la PR #605, « Constats mineurs écartés (ADR 0018) ».
