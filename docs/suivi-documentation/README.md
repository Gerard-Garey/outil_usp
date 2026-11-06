# Suivi de la documentation LaTeX

## Objet

Ce dossier reçoit ce que la grille de condensation de `docs/latex/CONVENTIONS.md` (§ 2, « Conservation du fond, condensation de la forme ») sort de `docs/latex/doc_tests_usp.tex` sans le faire tomber : la vie du dépôt (historique, décisions, numéros d'issue, SHA) et les informations importantes qui n'ont pas leur place dans le guide (mesures retirées, justifications d'une règle retirée, détails d'implémentation). Une information est *importante* si elle fonde une affirmation du document, borne sa portée, ou permettrait à un relecteur de refaire une mesure.

Le document décrit l'outil ; ce dossier garde la trace de ce qui a été retiré du document, sous le `\label` d'origine. Il n'est pas un second guide : il ne reformule pas la méthode, qui est dans le `.tex`.

## Fichiers

| Fichier | Plage du document |
|---|---|
| `I.md` | Préambule, page de garde, « Objet du document » et partie I (`sec:archi`, `sec:notations`, `sec:controles`) |
| `II.md` | Partie II (`sec:mc`, `sec:modele-auxiliaire`, `sec:nature`) |
| `III-H.md` | Partie III, introduction, hypothèses H1 à H4 et diagnostics de stabilité, de robustesse et graphiques (`sec:h1` à `sec:graphiques`) |
| `III-M.md` | Partie III, méthode Merz-Wüthrich (`sec:mw`, `sec:mwm1` à `sec:mwm6`) et lecture conjointe (`sec:lecture-conjointe`) |
| `IV.md` | Partie IV (`sec:verif`, `sec:biblio`, `sec:synthese`) |
| `annexe.md` | Annexe (`sec:annexe-flux`) |

## Règles de rédaction

- Les entrées suivent l'ordre du `.tex`. Une entrée par `\label` qui a perdu quelque chose, jamais d'entrée vide.
- En tête de chaque fichier, une section « Entrées transversales » reçoit ce qui ne relève d'aucun `\label` (par exemple un paragraphe répété dans plusieurs fiches, rangé sous le `\label` de la section qui le porte désormais).
- Titres de rubrique fixes et dans l'ordre du gabarit ci-dessous ; seules les rubriques non vides sont écrites.
- Une issue est citée nue (`#N`), une décision par son identifiant, une date en `jj/mm/aaaa`.
- **Aucune recopie** d'un ADR, de la feuille de route ni d'un fichier `docs/tableaux/` : on renvoie.
- Un chiffre n'est recopié que s'il ne vit nulle part ailleurs (valeur citée dans le `.tex` sans fichier versionné) ; il porte alors la mention « sans script versionné » et n'est jamais supprimé.
- L'entrée ne reformule pas la méthode (elle est dans le `.tex`).
- La rubrique « Correspondance SHA » suffit à retrouver l'état du moteur d'une mesure.
- L'entrée est écrite dans le même commit `docs:` que le retrait du `.tex`, à partir du tri du lot, qui désigne pour chaque passage « part en Markdown » sa rubrique de destination.
- Après chaque ajout, la table d'index ci-dessous est mise à jour.

## Gabarit d'une entrée

```markdown
## `<label>` — <titre courant de la fiche ou de la section> (partie <n>, § <section>)

**Historique.** <ancien état ; issue (#N) ; décision ; date (jj/mm/aaaa)>
**Décisions.** <règle décidée, par qui, quand ; identifiant (Q-…, D1-…, Mnn) ; ADR et point, par renvoi>
**Règle retirée (<identifiant>).** <définition de la règle retirée ; motif du retrait ; coût mesuré, par renvoi au fichier>
**Mesures retirées du guide.** <valeurs retirées et fichier `docs/tableaux/` qui les porte ; valeurs sans fichier : « sans script versionné »>
**Implémentation.** <détail d'implémentation retiré : fonction interne, tolérance, mesure de non-régression>
**Correspondance SHA.** <SHA> = <état mesuré> (fichier `docs/tableaux/…`)
**Renvois.** <ADR, feuille de route, issues>
```

## Index des entrées

Une ligne par entrée, dans l'ordre du `.tex`.

| `\label` | Fichier | Titre courant | Partie |
|---|---|---|---|
| Préambule (entrée transversale) | `I.md` | Commentaires `%` de la charte | Préliminaires |
| `sec:archi` | `I.md` | Architecture du moteur de calcul (Principe de séparation) | I |
| `sec:inventaire` | `I.md` | Inventaire des fonctions | I |
| `sec:segments` | `I.md` | Périmètres couverts et paramètres standard | I |
| `sec:graines` | `I.md` | Reproductibilité et gestion des graines | I |
| `sec:index-fonctions` | `I.md` | Index des fonctions de statistique et de p-value | I |
| `sec:ex-aequo` | `I.md` | Ex æquo des tests de rang et de signe | I |
| `sec:notations` | `I.md` | Notations générales (convention de restitution, graphie des textes) | I |
| `sec:controles` | `I.md` | Contrôles de qualité des données | I |
