# Mise en œuvre de #594 : deux corrections de la spécification amendée par la mesure

*19/11/2026, étape 6 d'A1. Rédigé par la session d'après l'avis d'`actuary` (questions ciblées, lecture seule) et l'audit léger de l'étape 6. Ne modifie pas la spécification décidée (`specification-594-amendee.md`, arrêt A, A-1 à A-5 en (a)) : corrige deux énoncés que la mesure a contredits.*

## T15 : liste fermée du témoin openxlsx

- **Énoncé de la spécification** (§ 4, T15, marqué *non vérifié*, `openxlsx` absent) : liste fermée mise à jour, « note préfixée pour les 12 séries… ».
- **Mesure** (openxlsx 4.2.5.2, R 4.3.3, `C.UTF-8`, 19/11) : la liste `ECARTS_TEMOIN_OPENXLSX` reste à **deux entrées** (`blancs/ligne_finale_note_blanche`, `entete/openpyxl_entete_lu_blanc`), inchangée.
- **Motif** (*vérifié*) : l'emploi 1 du témoin (ADR 0020, point 3) compare la **sortie aval** (`engine_lire_donnees_csv()` ou `engine_lire_triangle()`) à la source CSV ; un écart ne compte que s'il atteint cette sortie. Au niveau du `data.frame`, `openxlsx` garde `xml:space="preserve">` dans la note de **onze autres classeurs** de `LUS_594_CORPUS` ; la note n'est pas employée (séries) ou est refusée aux mêmes positions que la source (triangle) : ces différences sont **hors critère**. Les comparer au lecteur interne serait une assertion de parité, que l'ADR exclut.
- La boucle de l'emploi 1 n'appelle pas `engine_lire_xlsx()` : #594 ne pouvait pas changer les écarts du témoin.

## T5 : nombre de formes refusées

- **Énoncé de la spécification** : « 13 formes ». Ce nombre ne correspond à aucun décompte (*vérifié*) ; son origine est une *hypothèse* (formes refusées par R3 et par R8 mêlées).
- **Décompte** : le § 1 liste **11 formes** (4 à blanc, 1 à apostrophes, 2 « autre valeur », 3 « autre attribut », la forme vide à blanc) ; le prototype du § 3 en a forgé 10 refusées par R3 (sans `space="preserve"`) et 2 refusées par le complément de R8 (`&#32;`, `&#9;`).
- **T5 tel que codé** teste **13 formes** : les 11 du § 1 et deux de même nature (`<t\nxml:space="preserve">`, `<t xml:space ="preserve">`), chacune en valeur (B2) et en en-tête (B1), refus R3 de texte exact. La mention « *vérifié* par prototype » du § 1 ne couvrait pas `space="preserve"` : T5 le couvre désormais.

Aucune de ces deux corrections ne change une règle, un test décidé ni un résultat.
