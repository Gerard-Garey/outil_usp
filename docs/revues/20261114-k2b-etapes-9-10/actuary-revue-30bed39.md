# Revue par `actuary` du diff `30bed39` (corrections de validation, règle 10)

> Versé intégralement par la session principale (Q-54-10). Fiche de base. 14/11/2026. `git show 30bed39 -- docs/latex/doc_tests_usp.tex`. Lecture seule.

**Verdict : conforme.** Le commit applique fidèlement m1 à m4 et les corrections de `regulatory`. Il ne réaffirme nulle part l'« admissibilité » du refus et ne change pas le fond. Incohérence résiduelle dans la puce de `sec:mw` : hors périmètre K2b sur décision du mainteneur, donc pas une réserve sur ce commit, mais à porter dans une issue de suite de #540 (S1).

## Contrôle point par point

- **Article 220 (l. 3979, 4886, 5065).** « laisse ouverte » remplacé partout par « prévoit aussi la méthode n° 1, l'autre méthode standard, sous ses propres exigences de données (section C) » (au tableau, l. 4886 : « prévue par… sous ses propres exigences (section C) ») ; choix renvoyé à l'article 220, paragraphe 2. « en garantit l'admissibilité » (l. 3979) et « Le refus ne prive l'entreprise d'aucun droit » (l. 5059) supprimés. Le fond reste porté par D(4) seul (interprétation déclarée). Formulation identique à celle de l'encadré I > J (l. 14754). Conforme.
- **m1 (l. ~4606, `t="str"`).** Mesuré et déduit séparés. Le raisonnement tient : un texte non décodé contient « & », `as.numeric` rend NA et la cellule est refusée en aval. Aucun « & » dans les en-têtes attendus de `R/engine.R` (grep, contrôle partiel). Au pire, une entité valant un chiffre (`&#x31;`) donne un refus, pas une valeur fausse. Conforme.
- **m2 (`<rPr>`, l. 884 et ~4591).** Correspond au test réel `grepl("<rPr>", sx, fixed = TRUE)` (`R/engine.R` l. 8962) ; « `<rPr/>` ou `<rPr` à attributs ne suffit pas » reprend le commentaire du moteur (l. 8956-8958, « mesure »). Remarque sans suite obligatoire : ce commentaire cite aussi `<rPr >` ; « forme exacte » le couvre.
- **m3 (l. 5102).** « l'application des formules » s'accorde avec la suite (« ne permet pas d'appliquer les formules des paragraphes 4 et 5 »). Conforme.
- **m4 (l. 14750-14753).** Exigence D(2)(d) reportée sur la nouvelle première année ; paraphrase fidèle à la citation de D(2)(d) (l. 5081-5083). Conforme.
- **Coupure de la longtable (l. 887).** Table à 3 colonnes (`p{4.6cm}p{4.0cm}p{6.2cm}`, l. 708) ; continuation en troisième colonne (`\\ & &`), coupure entre deux propositions. Texte inchangé. Conforme.

## Constats

- Bloquant / majeur / mineur sur ce diff : aucun.
- **S1 (pour l'issue de suite de #540)** — puce de `sec:mw`, l. 14664-14669 : « Le refus ne prive l'entreprise d'aucun droit », méthodes n° 1 et n° 2 « *alternatives* », « l'entreprise à qui l'outil refuse la seconde conserve la première », « ce qui est la condition de son admissibilité ». Elle contredit les trois passages corrigés et l'encadré I > J (l. 14754) ; la l. 3979 renvoie à `sec:mw` pour « la justification détaillée ». À reformuler sur le modèle de la l. 14754, en retirant « condition de son admissibilité » ; y joindre le motif `R/engine.R` l. 1986 (`phrase_res2`, « reste ouverte »).

## Retour

- **Vérifié** : diff ; aucune occurrence restante de « laisse ouverte » ni de « ne prive » hors puce l. 14664 ; `R/engine.R` l. 8956-8962 ; `.tex` l. 708, 5081-5083, 14664-14669, 14750-14756.
- **Hypothèses** : absence de « & » dans les en-têtes attendus (grep, non exhaustif) ; compilation non relancée par l'agent.
- **Non vérifié** : la mesure `<rPr/>` / `<rPr` à attributs (commentaire du moteur et compte rendu de coder-approfondi de #557).
- **Critères déclenchés** : aucun.
