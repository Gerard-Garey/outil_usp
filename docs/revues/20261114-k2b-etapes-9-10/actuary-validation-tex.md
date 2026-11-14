# Validation du diff du `.tex` de K2b par `actuary-approfondi` (étape 9, règle 9)

> Versé intégralement par la session principale (Q-54-10). Fiche `actuary-approfondi`. 14/11/2026. Diff relu : `git diff main...HEAD -- docs/latex/doc_tests_usp.tex`, tête `e3eb7e7`. Lecture seule.

**Signalement préalable de l'agent** : pendant la revue, l'arbre de travail a reçu deux modifications non commitées de commentaires (`R/engine.R` l. ~8894, `app.R` l. ~251). *Note de la session : c'étaient les corrections de `coder` lancées en parallèle, commitées ensuite en `16c6b14` et `8d4ced3`.*

## Verdict : conforme avec réserves

Aucun constat bloquant ni majeur. Quatre constats mineurs (m1 à m4) touchent du texte écrit dans K2b : correction recommandée dans K2b par un commit `docs:` avant la sortie du brouillon. Le point 3 sort du périmètre et relève d'une issue selon l'agent.

### 1. Conformité aux décisions 1 à 8 et aux mesures

- **Décisions 1 et 2 (#540)** : conforme. L'encadré de `sec:mw` (l. 14729-14750) porte les points 1 à 5 de l'annotation bis de l'ADR 0005. La ligne « Géométrie carrée » (l. 4832-4840) porte la description des termes indéfinis et les points 1 et 2, et renvoie à l'encadré. Le passage de la l. 5094 ajoute « à la lettre » et sépare les cas I < J et I > J. La citation de Merz et Wüthrich concorde avec la source.
- **Décisions 3 et 8 (#557)** : conforme. Le texte (l. 890-893 et 4581-4585) rend exactement le code (`.xlsx_controler_cellules()`, l. 8720-8724) : un seul `r`, entre guillemets doubles, de forme `^[A-Za-z]+[1-9][0-9]*$`, cellule vide de style comprise, minuscules admises.
- **Décision 4** : conforme. Condition de mesure remplie : docwriter a mesuré `<is>` avec `<rPh>` → NA, en-tête `X2`.
- **Décision 5** : conforme (l. 4648-4649, limite consignée sous Windows).
- **Décision 6 et formule de #565** : conforme. Le job « Parité des lecteurs de classeur » de l'exécution 43529857660 (tête `2159f93`) est en succès ; le job impose `VERSION_OPENXLSX: "4.2.5.2"` et échoue sur une autre version (`ci.yml` l. 398 et 458-468) ou sur une ligne « [saute] » (l. 495) ; il exécute `test_controles_entree.R`, qui contient les tests des en-têtes en double (#555) et des refus P2 et X1 (l. 3106-3107). La formule « mesuré sous 4.2.9, vérifié en intégration continue sous 4.2.5.2 » est donc fondée et couvre P2 et X1 sous 4.2.5.2. Le `.tex` n'attribue la troncature P2/X1 qu'à la version 4.2.9 mesurée.
- **Décision 7** : conforme, hypothèse « aucun tableur n'écrit cette forme » marquée non vérifiée. Réserve m2.
- **#572 (P2, X1, `.xml_textes()` attentif aux guillemets)** : conforme au code (l. 8554-8555 et 8960-8986). Décompte « sept refus » juste aux deux endroits (l. 894 et 4638). Pour la forme X1 en `<is>`, « texte non numérique » concorde avec la mesure de docwriter (`1</t><t>1.5`).
- **#556** : conforme à `app.R` (`texte_refus_import()`, `toupper(ext)` rendu par « extension en capitales », `texte_echec_export()` puis `proteger_export()`, cause R au journal seulement ; `usp_refus_ecriture` posé par `engine.R` l. 8323 et 8402).
- **#566** : aucune surface documentaire ; recherche de docwriter acceptée.
- **`e3eb7e7`** : vérifié comme pure scission. Diff mot à mot `2159f93..e3eb7e7` : insertion de `\\ & &` et de `\\`, puis `&` ; déplacement de six fonctions avec leurs arguments ; retrait de deux séparateurs de fin de liste. Aucun mot changé ; correspondance fonctions / arguments / descriptions conservée (7 + 6, ordre identique).

### 2. Encadré « Restriction d'implémentation » et D(2)(d) après troncature

D(2)(d) relu dans le texte consolidé (texte courant) : « pour la première année d'accident, le montant de paiements cumulé de la dernière année de développement pour laquelle des données sont disponibles inclut tous les paiements de l'année d'accident à quelque différence non significative près ».

Selon D(3)(a), la numérotation repart de 0 à la première année disponible. Après l'exclusion des I−J années les plus anciennes, l'ancienne année I−J devient la première, et sa dernière année de développement disponible est J. La phrase « D(2)(d) s'applique à la nouvelle première année d'accident » est **exacte et nécessaire** : le respect de D(2)(d) par l'ancienne première année n'établit pas celui de l'année I−J. D(2)(b) et D(2)(c) restent satisfaits (J+1 ≥ 5). Termes indéfinis exacts : I−i > J ⇔ i < I−J ; Q̂ indéfini pour 1 ≤ i ≤ I−J. Seule réserve, de forme : m4.

### 3. Lignes ~3979 et ~5061 : « laisse ouverte la méthode n° 1 »

- **Diagnostic.** Défaut voisin de celui corrigé par l'annotation bis, sans être le même. L'art. 220(1)(b) offre bien les deux méthodes : « laisse ouverte » n'est pas faux au sens strict. En revanche, « en garantit l'admissibilité » (l. 3980) et « l'entreprise à qui l'outil refuse la seconde conserve la première » (l. 14660-14662) vont trop loin : la méthode n° 1 est soumise à ses propres exigences de données (section C), et l'outil lui-même peut la refuser (refus du MV en bordure, l. 4386-4392). L'argument exact est double : la méthode n° 1 est disponible si l'entreprise remplit la section C, le choix relevant de l'art. 220(2) ; à défaut, le paramètre standard reste applicable.
- **Où le corriger.** Selon l'agent, hors du périmètre de K2b (texte antérieur, ni #540 ni une autre issue de la branche).
- **Recommandation de l'agent : une issue** (circuit 4 avec `regulatory`) couvrant le `.tex` aux l. 3978-3980, 4880-4881, 5060-5062 et 14658-14663, le cas symétrique de la l. 4392 et le motif `engine.R` l. 1986 (« La methode du risque de reserve no 2 reste ouverte (meme point). »).
- **Texte proposé pour la l. 3979-3980** : « l'article~220, paragraphe~1, point~b), qui offre aussi la méthode du risque de réserve n\textsuperscript{o}~1, sous ses propres exigences de données (section~C), le choix entre les deux méthodes relevant de l'article~220, paragraphe~2, et le paramètre standard restant applicable à défaut, fonde son admissibilité. »

*Suite : le mainteneur a tranché pour une correction dans K2b, `.tex` seul, avec les textes de `regulatory` (l. 3979, 4885, 5064) ; la puce de `sec:mw` et le motif du moteur restent hors K2b.*

### 4. Rigueur statistique : constats mineurs

- **m1, l. 4603-4604 (`t="str"`)** : « (mesuré) » couvrait une justification non mesurée ; « ne s'écrivant pas avec une entité » est inexact (tout caractère s'écrit en référence numérique). Remplacer « par les deux chemins à l'identique, un en-tête attendu ou un nombre ne s'écrivant pas avec une entité (mesuré). » par « par les deux chemins à l'identique (mesuré)~; un texte resté non décodé garde le caractère «~\code{\&}~», si bien qu'il n'est ni un en-tête attendu ni un nombre et ne peut donner de valeur fausse (raisonnement, non mesuré). »
- **m2, l. 892 et 4588** : le code n'admet que la chaîne littérale `<rPr>` (l. 8960) ; une `<rPr/>` ou une `<rPr a="1">` n'évite pas le refus. l. 892 : « sans aucune balise \code{<rPr>} » → « sans aucune balise \code{<rPr>} écrite sous cette forme exacte » ; l. 4588 : « sans aucune balise de mise en forme \code{<rPr>} » → « sans aucune balise de mise en forme écrite exactement \code{<rPr>} (une \code{<rPr/>} ou une \code{<rPr} à attributs ne suffit pas à éviter la troncature par \code{openxlsx}, mesuré) ».
- **m3, l. 5096** : pour I > J, f̂_j, S_j et σ̂²_j restent définis. Remplacer « dont dépend la simple définition des estimateurs~: » par « dont dépend l'application des formules~: ».
- **m4, l. 14744** : « la troncature » n'est pas introduite dans l'encadré. Remplacer « après la troncature, D(2)(d) s'applique à la nouvelle première année d'accident. » par « après cette exclusion, D(2)(d) s'applique à la nouvelle première année d'accident, dont le montant cumulé à l'année de développement~$J$ doit inclure tous ses paiements à une différence non significative près, ce que D(2)(d) vérifié sur l'ancienne première année n'établit pas. »

Les autres mentions « (mesuré) » du diff renvoient aux mesures versées de docwriter ou de coder ; les hypothèses sont marquées comme telles.

## Retour

- **Statut** : complet. **Résultat** : conforme avec réserves.
- **Vérifié** : D(2)(d), D(2)(e) et D(3) dans le texte consolidé (extraction du xhtml) ; `R/engine.R` l. 8675-8724 et 8940-8986 ; `app.R` l. 200-225 et 2025-2041 ; `ci.yml` l. 383-506 et exécution 43529857660 ; diff mot à mot de `e3eb7e7`.
- **Repris sans les refaire** : mesures sur classeurs forgés (docwriter, coder) ; citation de Merz et Wüthrich.
- **Non vérifié** : D(2)(d) dans le JOUE (non relu à l'image) ; CI de `e3eb7e7` en cours au moment de la revue.
- **Critères déclenchés** : aucun. Aucun σ_USP, aucune p-value ni aucun verdict touché ; aucun désaccord avec l'ADR 0005.
