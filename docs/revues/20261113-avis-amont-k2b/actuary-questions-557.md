# Avis d'`actuary` sur les trois questions de `coder-approfondi` (étape 4, #557)

> *Rédigé par l'agent actuary (IA), fiche de base.* Relance du 13/11/2026, en lecture seule. Lu : `apres_r.txt`, `apres_rph.txt` et `apres_rph2.txt` (dossier `coder557/` du scratchpad). Le reste des mesures est repris de `coder` sans être rejoué [Mc].

**En bref.** Je recommande les trois changements. Ils touchent tous des fichiers aujourd'hui acceptés, donc ils relèvent du mainteneur : Q-A étendue, Q-B confirmée et Q-F nouvelle.

## Q1 : chaîne partagée enrichie lue tronquée par `openxlsx`

**Constat [Mc, lu dans `apres_rph2.txt`].** Sous `openxlsx` 4.2.9 comme 4.2.5.2, une série dont une cellule est une chaîne partagée enrichie `1` + `1.5` passe sans message :

| Chemin | `ok` | `xt` |
|---|---|---|
| `openxlsx` | `TRUE` | `c(10, 1, 12, 13, 14)` |
| lecteur interne | `TRUE` | `c(10, 11.5, 12, 13, 14)` (valeur juste) |

`openxlsx` accepte donc une valeur fausse sans rien signaler. C'est le pire défaut possible pour un lecteur, et il est déjà là aujourd'hui. Selon que le poste a `openxlsx` ou non, le même fichier donne deux σ_USP différents.

Le critère de parité de #557 et la règle « refus, jamais une valeur devinée » commandent un refus.

**Recommandation : option (b).** Refuser, avant `openxlsx` et sur les deux chemins, une table de chaînes partagées qui contient au moins un segment `<r>` sans aucun `<rPr>` dans toute la table.
- Ce critère reproduit exactement la condition mesurée du défaut d'`openxlsx`, qui est une condition sur la table entière : on refuse donc exactement quand `openxlsx` peut tronquer.
- Option (c), refuser seulement si une telle chaîne est référencée : plus précise, mais plus complexe (il faut résoudre les indices de toute la feuille). Le gain serait nul en pratique, car une table sans `<rPr>` où un segment `<r>` ne sert à rien est elle-même une forme forgée.
- Option (a), consigner la limite : écartée, puisqu'une valeur fausse serait acceptée.

**Décision du mainteneur (Q-F)** : des fichiers aujourd'hui acceptés deviennent refusés.

Hypothèse à signaler [H] : un tableur ne produit pas de segments `<r>` sans aucun `<rPr>` dans la table. Ce n'est pas vérifié pour Excel ni pour LibreOffice. Si `coder` dispose d'un classeur enrichi produit par un tableur, il faut contrôler qu'il n'est pas refusé.

**Texte exact du motif** (classe `usp_refus_lecture`, texte fixe) :

```
Classeur illisible : la table des chaines partagees (xl/sharedStrings.xml) contient du texte decoupe en segments (balises <r>) sans aucune mise en forme (balise <rPr>) ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre tronquee). Enregistrer de nouveau le classeur depuis un tableur.
```

Le tableau avant / après du commit doit porter la ligne suivante : « `openxlsx` : valeur tronquée acceptée (1 au lieu de 11,5) → refus motivé ; lecteur interne : lu juste → refus motivé (parité) ».

## Q2 : `11` suivi du phonétique `7` lu 117 par le lecteur interne

**Confirmé : à corriger.** Mon avis disait « sans effet sur un calcul [H] ». La mesure réfute cette hypothèse : avant le correctif `rPh`, le lecteur interne acceptait une valeur fausse (117 au lieu de 11).

Le tableau avant / après doit le dire : « lecteur interne : valeur fausse acceptée (117) → valeur juste (11), identique à `openxlsx` ».

Le correctif `<rPh>` corrige donc une valeur fausse ; ce n'est plus un simple alignement. Ma recommandation sur Q-B (ignorer `<rPh>`) s'en trouve renforcée. Elle reste soumise au mainteneur, puisque la valeur lue dans un fichier accepté change.

## Q3 : forme de l'attribut `r`

**Recommandation : durcir le contrôle** sur la forme brute, sans toucher au lecteur. Le contrôle exige deux choses :
1. **exactement un** attribut `r` dans la balise `<c>` ;
2. de la forme `r="[A-Za-z]+[1-9][0-9]*"`, en **valeur brute** : guillemets doubles, sans `&`.

**Motifs.**
- `<c r='Z9' r="A2">` répète un attribut. Ce XML est mal formé : le contrôle et le lecteur interne retiennent Z9, et `openxlsx` n'a pas été mesuré sur ce cas. Une position différente selon le chemin pourrait conduire à une valeur fausse : à refuser.
- `r="&#66;2"` est du XML légal, qui vaut B2 une fois les entités décodées. Aucune valeur fausse n'est en jeu, mais `openxlsx` lève une erreur R brute. Le refus donne un motif propre et un comportement identique sur les deux chemins.
- Sur tout fichier accepté par ce contrôle durci, `.xlsx_attribut()` rend la même valeur qu'une lecture brute (une seule occurrence, aucune entité). La consigne « même règle que le lecteur » est donc tenue sur le domaine accepté, sans modifier le lecteur.

**Texte** : celui du § 2 de mon avis amont, inchangé (« … n'a pas la forme attendue, lettres de colonne puis numero de ligne a partir de 1 (par exemple A2) … »). Il couvre aussi ces deux cas.

**Décision du mainteneur** : ce durcissement entre dans **Q-A** (refus des références mal formées). Une forme lue aujourd'hui par le lecteur interne (`&#66;2`) deviendrait refusée, ainsi que la double occurrence de `r`. À mesurer par `coder` : `openxlsx` sur `<c r='Z9' r="A2">` (non mesuré).

## Retour

- **Statut** : `revue requise`. Questions au mainteneur :
  - **Q-F (nouvelle)** : refus de la table de chaînes partagées qui contient des segments `<r>` sans aucun `<rPr>`.
  - **Q-A étendue** : attribut `r` unique, en valeur brute.
  - **Q-B** : confirmée et requalifiée en correction d'une valeur fausse.
- **Preuves** :
  - *Lues dans les sorties de `coder`* : `apres_rph2.txt` (11,5 lu 1 par `openxlsx` 4.2.9 et 4.2.5.2, `ok = TRUE`) et `apres_r.txt` (`&#66;2` : lu par le lecteur interne, erreur R brute chez `openxlsx`).
  - *Repris de `coder` sans relecture* : 117 lu avant le correctif ; condition « aucun `<rPr>` dans la table ».
  - *Hypothèse* : un tableur n'écrit pas cette forme.
  - *Non mesuré* : `openxlsx` sur la double occurrence de `r`.
- **Critères déclenchés** : un résultat change hors références (des valeurs fausses acceptées deviennent refusées ou justes), et l'hypothèse « sans effet sur un calcul » de mon avis amont est réfutée par la mesure. Aucun σ_USP des six cas n'est touché.
- **Prochaine action recommandée** : la session porte Q-F, Q-A étendue et Q-B au mainteneur ; `coder-approfondi` complète le tableau avant / après avec les lignes ci-dessus et mesure les deux points restants.
