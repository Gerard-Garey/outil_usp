# Décisions du mainteneur sur l'avis amont de K2b (13/11/2026)

> *Consignées par la session principale (IA)* d'après les réponses du mainteneur au questionnaire du 13/11/2026. Sources : `coder-rejeu-k2b.md` (étape 1), `actuary-avis-amont-k2b.md`, `regulatory-lecture-mw04.md` et `actuary-relance-mw04.md` (étape 2), dans ce dossier.

| N° | Objet | Décision | Effet |
|---|---|---|---|
| 1 | #540, qualification de la restriction I = J | **Nouvelle annotation datée de l'ADR 0005**, rédigée par `architect`. La puce 3 de l'annotation du 13/11 est corrigée : la méthode n° 1 est l'autre méthode standard de l'art. 220(1)(b), sous ses propres exigences (section C), et le choix entre les deux méthodes relève de l'art. 220(2) ; l'art. 19(1)(b) est cité avec l'art. 219(1)(a). La lecture (A) n'est pas remise en cause. Le motif porte les points 1 à 3 de la qualification de `actuary-relance-mw04.md` ; l'ADR et le `.tex` en portent les points 1 à 5. Corrections mineures (vi) de `regulatory` comprises. | Aucun σ_USP, aucune p-value ni aucun verdict |
| 2 | #540, texte de MW-04 (émis si I > J seulement, R-1) | « Triangle non carre (%d annees d'accident, %d annees de developpement) : admis par l'annexe XVII, section D, point (2)(e), mais refuse par l'outil, les formules des paragraphes 4 et 5 de cette section ne se calculant a la lettre que pour un triangle carre. Se ramener a un triangle carre exclut des annees d'accident : exclusion a justifier (art. 219(1)(a) et 19(1)(b)). » Merz et Wüthrich (2008, p. 546) restent dans le `.tex` et l'ADR seulement. | Libellé changé hors références ; test l. 1664-1668 remplacé, l. 1618-1622 complété |
| 3 | Q-A, #557, références de cellule | **Refus de toute référence hors `^[A-Za-z]+[1-9][0-9]*$`**, sur toutes les balises `<c>` (texte d'`actuary`, § 2). | Fichiers forgés aujourd'hui acceptés (`r="1"`, `"A0"`, `"1A"`, `" A2 "`, `<c r="" s=…/>` côté `openxlsx`) refusés |
| 4 | Q-B, #557, `<rPh>` | **Texte phonétique ignoré** par `.xml_textes()` ; chaîne en ligne avec `rPh` : limite consignée, sous la condition de mesure du corps (avis, § 3b) | Texte lu changé dans des fichiers acceptés ; un en-tête attendu passe de refusé à accepté |
| 5 | Q-C, #557, blancs d'en-tête sous Windows | **Limite consignée dans K2b ; mesure facultative sur le poste du mainteneur à KR** (`scripts-rejeu/mesure_557d.R`, avec la batterie Windows de #548) | Aucun |
| 6 | Q-D, #565, job de parité | **Branché à l'agrégat bloquant `tests-moteur`** (mêmes conditions de déclenchement que les lots, `success` ou `skipped`) | La parité des lecteurs bloque la fusion |

**Tranché par délégation par `actuary`** (avis amont, sans question au mainteneur) : `t="str"` en limite consignée ; textes de #556 (statut unique, notification, classe `usp_refus_ecriture`, forme « démarrage » hors périmètre) ; critères d'acceptation de #566 ; versions et fichiers du job de #565 ; `coder-approfondi` d'office pour #557.

Fable : aucune consultation (0 sur 3).
