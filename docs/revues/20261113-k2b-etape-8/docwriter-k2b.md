# Compte rendu de `docwriter`, étape 8 de K2b (règle 9)

> Versé par la session principale (condensé fidèle). Fiche de base (effort `medium`). 13/11/2026, sur `6a32d38` ; six commits `docs:`, `.tex` seul, tête `726a02a`.

## Commits
1. `daac516` (#565) : § contrôles, parenthèse sur les en-têtes en double : « mesuré sous la version 4.2.9 et vérifié en intégration continue sous la version 4.2.5.2 » ; l'intégration continue exécute la parité sur les deux chemins.
2. `73aba41` (#557) : index (`engine_lire_xlsx()`, `.xml_textes()`, `.xlsx_controler_cellules()`) ; présentation de l'application (renvoi à « Lecture des fichiers ») ; § contrôles, « Lecture des fichiers » : refus de la référence de cellule (décisions 3 et 8) et Q-F (décision 7), `<rPh>` ignoré (décision 4), limites (chaîne en ligne avec `<rPh>` ; `t="str"` sans décodage ; blancs d'en-tête non mesurés sous Windows) ; « trois refus » → « cinq ».
3. `2e49464` (#540) : encadré « Restriction d'implémentation » de `sec:mw` (qualification entière, points 1 à 5 de l'annotation bis : termes indéfinis, lecture stricte de l'outil et non exigence du texte, I < J au seul motif D(2)(e), exclusion à justifier (art. 219(1)(a) et 19(1)(b)) puis D(2)(d) après troncature, méthode n° 1 et art. 220(1)(b) et (2), Merz et Wüthrich 2008, p. 546) ; ligne « Géométrie carrée » de `sec:controles` ; encadré « Différence de nature » (trois cas). Fiche M6 (l. 17643) laissée, juste.
4. `a025024` (#572) : décompte remesuré (7 appels de `.refus_lecture(` hors définition) : « cinq » → « sept » (index et § contrôles) ; refus P2 et X1 (« formes que l'outil tient pour non prévues par le format », ordre de CT_Rst non affirmé) ; `.xml_textes()` attentif aux guillemets ; limites `<is>`, `<x:rPh>`, `<x:t>`.
5. `13d62f8` (#556) : forme unique du statut d'import et notification unique ; échec d'export (texte du moteur pour `usp_refus_ecriture`, texte fixe sinon, cause au journal) ; index `engine_ecrire_xlsx()` (classe `usp_refus_ecriture`). l. ~876, 925, 4541 vérifiées, inchangées.
6. `726a02a` : `\versiondoc` 3.7, `\datedoc` 13 novembre 2026 ; retouche de forme dans l'index (#556) contre un Underfull nouveau.
#566 : aucune surface (`grep` « impression », « paysage », « A4 », « @media »).

## Grille de surface
- #557, #572 : fiches et tableaux 1 et 2 non concernés ; index mis à jour ; table de traçabilité déjà juste ; décomptes trois → cinq → sept aux deux endroits ; graines : « ne tirent rien » juste.
- #540 : fiches M6 et M2 justes ; deux encadrés mis à jour ; l. 2311 juste.
- #556 : index mis à jour. #565 : entrée (7) seule.

## Mesures de `docwriter`
Classeurs forgés (`scripts-rejeu/fab.R`), deux chemins, openxlsx 4.2.9 : `r="A0"`, `r="1"`, Q-F, P2, X1, M1 refusés ; `openxlsx::read.xlsx` seul : Q-F, P2, X1 lus 1 ; `<rPh>` partagé lu 11 ; `<x:rPh/>` 11,5 ; `<x:t>` vide ; `t="str"` `a&amp;b` tel quel ; `<is>` avec `<rPh>` : NA, en-tête `X2` ; `<is>` P2 : NA ; `<is>` X1 : texte « 1</t><t>1.5 », refusé en aval (non numérique). `mw_valider_triangle()` : 8×9 → D(2)(e) seul ; 9×8 → MW-04 seul. Sources : art. 19(1)(b), 219(1)(a), 220(1)(b), 220(2), annexe XVII D(2)(d)-(e) (consolidé du 14.11.2024) ; Merz et Wüthrich, p. 546 (« For simplicity, we assume that I = J (note that all our results can be generalized to the case I > J) »).

## Concordance et compilation
`concordance_doc_moteur.R --strict` : 0 écart après chaque commit (sauf `a025024`, parti sans relance après deux retouches de mots ; 0 aux essais suivants) ; `controle_doc_nd.R --bloquant` : 0. TeX Live 2023/Debian, pdfTeX-1.40.25 : 0 erreur, 0 référence indéfinie, 0 Overfull, 1 348 Underfull (comme la base) ; 442 pages (440 avant) ; PDF restauré, non indexé.

## Écarts relevés dans le code (non corrigés, relèvent de `coder`)
- Commentaire d'en-tête d'`engine_lire_xlsx()` : une chaîne `<is>` de forme X1 n'est pas lue « NA » par openxlsx 4.2.9 mais « 1</t><t>1.5 » (refusée en aval) ; le `.tex` dit « NA ou texte non numérique ».
- Commentaire d'`app.R` ~l. 251-253 : cite encore « trois » refus motivés.

## Points pour l'étape 9 (`actuary-approfondi`) et `regulatory`
- Encadré de `sec:mw` (#540) : lecture réglementaire (art. 219, 19, 220(2), D(2)(d) après troncature) ; contrôle de `regulatory` demandé par la règle 11 des conventions ; D(2)(d) marqué « non relu » par `actuary`.
- l. ~3973 et ~5032 (refus de R̂ ≤ 0) : « l'article 220, paragraphe 1, point b) laisse ouverte la méthode n° 1 », tournure voisine de celle corrigée par l'annotation bis ; ajouter l'art. 220(2) ? (hors périmètre de K2b).
- Formule de #565 fondée sur la première exécution du job de parité (commentaire de la PR #571 du 13/11, 18:15).
