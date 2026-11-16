# Revue de la reprise de R1 du lot H (actuary, 16/11/2026)

> *Rédigé par l'agent actuary (IA).* Rapport versé intégralement par la session principale. Revue sur son diff (règle 10) de `git show 14853f8` (`docs/latex/doc_tests_usp.tex`, `docs/suivi-documentation/I.md`). Elle répond à la réserve R1 de `actuary-revue-lot-h-tex.md`.

## Verdict : visa, R1 levée

Le diff applique la correction proposée, et chaque affirmation nouvelle correspond à ce que j'ai mesuré sur la tête (voie de repli et openxlsx 4.2.5.2) :

- **Phrase d'introduction.** Elle dit maintenant « une seule forme connue donne une valeur fausse sur un classeur admis (cible de la feuille forgée, ci-dessous, lue fausse par l'un des chemins ou par les deux) ». C'est exact : le cas où les deux chemins lisent la même feuille fausse est couvert.
- **« fait lire à l'un des deux chemins » devenu « peut faire lire ».** C'est exact : avec `Target="…"` entre guillemets doubles, openxlsx s'arrête sur une erreur au lieu de lire une valeur fausse.
- **Condition d'openxlsx.** Il lit la mauvaise feuille quand la cible est entre apostrophes, « que ce texte le précède ou le suive ». Les quatre ordres sont mesurés et donnent tous 999 : `Target='…'` suivi de `x:Target="…"` ou de `Foo='Target="…"'`, et l'inverse.
- **Condition de la voie de repli.** Elle lit la mauvaise feuille « quand `x:Target="…"` précède l'attribut de cible ». C'est conforme à `.xlsx_attribut(…, "Target")`, qui prend le premier attribut de nom local `Target`. Mesuré : 999, avec la cible entre guillemets doubles comme entre apostrophes.
- **Les deux chemins.** `x:Target="…"` suivi de `Target='…'` donne 999 sur les deux chemins, σ_USP 0,5064392336, ok = TRUE. Mesuré.

Le `.tex` ne contient aucune vie du dépôt : ni « R1 », ni numéro d'issue, ni SHA. La trace de `I.md` (textes avant et après, motif, mesures de docwriter) concorde avec ma mesure. Le diff ne change aucun résultat.

**Remarque, sans réserve.** « sur un classeur admis » figure deux fois dans la même phrase d'introduction. Le second peut être retiré lors d'un prochain passage, au choix de docwriter.

## Retour

- **Statut** : `complet`.
- **Résultat** : visa ; R1 levée.
- **Preuves**
  - **Vérifiées** :
    - le diff `14853f8` ;
    - mes quatre exécutions de la sonde augmentée sur la tête `db7e3dd` (revue précédente), voie de repli et openxlsx 4.2.5.2 : `x:Target`/`Target='…'` 999/999 ; `Foo`/`Target='…'` 104,2/999 ; `x:Target`/`Target="…"` 999/erreur ; `Target='…'`/`x:Target` 104,2/999 ;
    - le code de `.xlsx_fichier_feuille()` (lecture de la cible).
  - **Non vérifié** : je n'ai pas rejoué la mesure de docwriter sur `d10b8fe`. Les valeurs qu'il consigne sont identiques aux miennes.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune.
- **Critères déclenchés** : aucun.
- **Constats hors périmètre** : aucun nouveau. Le cas « les deux chemins lisent la mauvaise feuille » reste à ajouter à l'issue prévue par D-S1-38/39 (E1, déjà signalé).
- **Prochaine action recommandée** : ajouter ce cas au corps de l'issue D-S1-38/39, puis faire le commit du PDF de branche.
