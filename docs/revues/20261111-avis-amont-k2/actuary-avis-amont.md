# K2, étape 2 : avis amont d'`actuary` sur les textes

> *Rédigé par l'agent actuary (IA), fiche de base, le 11/11/2026, sur la branche `claude/fichiers-et-point-decimal` (tête `7513508`, `R/engine.R` identique à `main` `83198f5`). Reproduit par la session principale : mise en forme, et condensation de quelques motifs sans changement des textes fixés, des mesures ni des recommandations. Rien n'a été écrit dans le dépôt. Les trois scripts de mesure (`colA.R`, `sep.R`, `lead.R`) sont restés dans le scratchpad de la session ; ils ont été lancés avec `openxlsx` 4.2.9 sous `LC_ALL=C.UTF-8`.*

**Décisions du mainteneur du 11/11/2026 prises sur cet avis** (§ 7) : D1, règle R-a ; D2, compression par le paquet R `zip` s'il est présent, sinon par `utils::zip()` (option proposée par la session après lecture des dépendances d'`openxlsx`, qui importe `zip`) ; D3, divergence nommée dans K2, puis issue `needs-triage` après la remise.

## 0. Lectures et mesures

- **Lu** :
  - fiche « Branche K2 » et `rejeu-etape1.md`, avec les sorties `scripts-rejeu/*.out` ;
  - issues #487, #522, #520, #550, #488, #439 ;
  - règles R-527.1 à R-527.8 et tableau G3/G4 de `docs/revues/20261111-avis-amont-k4/actuary-avis-amont.md` (§ 7), ainsi que `inventaire_527.md` ;
  - dans `R/engine.R` : l. 7594-7855, 7882-8073, 9217-9240 et 9300-9395 ;
  - dans `app.R` : l. 230-251 et 1857-1879 ;
  - `tests/unitaires/test_controles_entree.R`, l. 2040-2075 et 2260-2360.
- **Mesuré** (*vérifié*) :
  - **M1, colonne A sans aucune cellule.** Les deux chemins de lecture la rendent : `V1` pour le lecteur interne, `X1` pour `openxlsx` avec `skipEmptyCols = FALSE`. Sur ce fichier, « triangle 7 × 7 décalé en colonne B » et « triangle 8 × 8 dont l'année de développement 0 est vide et sans en-tête » sont **le même fichier, octet pour octet**. Les deux chemins le lisent aujourd'hui en 7 × 7, avec `ok = TRUE`.
  - **M2, `sep.names = " "` d'`openxlsx`.**
    - « deux mots » est gardé.
    - « x\tt » devient « x t » et « a  b » devient « a b ».
    - L'espace de tête de « ␣lead » est retirée, avec ou sans `sep.names`.
    - L'espace insécable n'est pas retirée.
  - **M3, en-tête « ␣xt ».** Il est refusé par le lecteur interne et accepté par `openxlsx`. La divergence change donc l'acceptation du fichier, pas seulement le libellé.

Les textes ci-dessous sont en R, sans accents. **Aucun ne cite l'annexe XVII** : `regulatory` n'est requis nulle part.

## 1. #520 : colonne de développement 0 vide et sans en-tête

### 1.1 Texte retenu (identique avec et sans colonne `i`)

```r
sprintf(paste("Colonne(s) vide(s) sans en-tete avant la premiere colonne renseignee du triangle (colonne(s) %s) :",
              "annee de developpement 0 manquante presumee ; la renseigner, ou retirer la colonne vide",
              "si le triangle commence bien a l'annee de developpement 0."), liste(gauche))
```

Motif :
- Le texte prend la forme de LE-05 et le terme « presumee » de Q-59-2.
- La colonne est numérotée par sa position dans le tableau lu, colonne `i` comprise.
- Il n'y a pas de renvoi réglementaire.
- La seconde branche de l'alternative couvre le cas où le tableau est seulement décalé : les cellules ne permettent pas de le distinguer (M1).

### 1.2 Distinction avec un triangle non carré ; règle

- **Ordre des contrôles.** Le motif est posé par `.retirer_lignes_colonnes_vides()`, et `engine_lire_triangle()` rend le refus avant `mw_valider_triangle()`. Le motif « Triangle non carre » est donc remplacé, et non doublé.
- **Déclencheur.** Une colonne entièrement vide, sans en-tête, qui n'est pas `i`, placée avant la première colonne de développement renseignée, et après `i` si cette colonne existe.
- **Cas inchangés :**
  - un vrai triangle non carré garde MW-04 ;
  - une colonne vide qui porte un en-tête garde LE-06 ;
  - une colonne vide placée avant `i` reste retirée sans message (test #483 « xlsx de triangle decale en colonne B »).
- **Règle recommandée, R-a (positionnelle et uniforme).** Elle est le pendant de la règle des lignes : une ligne vide en tête est déjà refusée (LE-03). **Décidée par le mainteneur (D1).**
- **Règle écartée, R-b** (avec `i`, refuser seulement si le reste est non carré). Elle ne s'applique pas sans `i`, car le reste y forme un 7 × 7 carré. Elle contredirait donc Q-59-2.
- **Conséquences de R-a :**
  - un triangle sans `i` décalé en colonne B est désormais refusé : c'est inévitable, puisqu'il a les mêmes cellules (M1) ;
  - un triangle avec `i` dont une colonne vide sans en-tête sépare `i` de `j0` est désormais refusé (test `col_vide(tri483, 1, "V2")`, `test_controles_entree.R` l. 2047-2054, à changer).
- Les bords droits et les séries ne sont pas touchés.

## 2. #522 : en-tête hors ligne 1 ; caractères de contrôle

### 2.1 Refus d'une ligne 1 sans valeur (même texte sur les deux chemins xlsx, pour les séries et le triangle)

```r
"Ligne 1 du fichier sans aucune valeur : l'en-tete du tableau doit etre en ligne 1, sans ligne au-dessus ; supprimer la ou les lignes vides au-dessus de l'en-tete."
```

- « sans aucune valeur » couvre la ligne absente et la ligne de cellules mises en forme sans valeur.
- *Hypothèse* : le même texte vaut pour un CSV dans ce cas, non mesuré.
- Effet hors des références : un fichier qu'`openxlsx` acceptait devient refusé.

### 2.2 Motif propre au titre seul en A1 : **non**

- **La détection serait heuristique.** Une ligne 1 qui ne porte qu'une cellule est un en-tête légitime de triangle (« i » suivi d'en-têtes vides).
- **Le cas est déjà refusé** par LE-02 (séries) et par LE-13 (triangle).
- **Seule « Colonnes presentes » diffère** selon le chemin. On l'aligne de deux façons :
  - pour les espaces, par le § 3.3 ;
  - en citant **« (vide) »** pour tout nom que `.entete_absent()` juge absent (`""`, `NA`, `X<k>` ou `V<k>` à sa position). Rendu : « … Colonnes presentes : Export ACME, (vide), (vide). »

### 2.3 Échappement des caractères de contrôle

Les caractères de contrôle sont écrits selon la forme de `citer()` dans `mw_valider_triangle()` (l. 9374-9387, convention du 16/10/2026), sans guillemets :
- caractère ASCII : `encodeString(…, quote = "")`, qui rend `\001`, `\t`, `\n`, `\033` ;
- caractère non ASCII blanc, de contrôle ou de format : `\uXXXX`, ou `\UXXXXXXXX` au-delà de U+FFFF ;
- tout autre caractère reste inchangé.

Rendu : « Colonnes presentes : a\001b, x\tt\n, y\033[31mt. »

La forme `<U+0001>` est écartée :
- elle varie selon la plateforme ;
- elle se confond avec du texte littéral ;
- le moteur a déjà une convention.

On n'ajoute pas de guillemets, car LE-02 n'en met pas. La barre oblique inverse est doublée, ce qui est nécessaire pour lever toute ambiguïté.

L'octet 0x89, déclaré Latin-1, sera écrit `\u0089`. Il faut passer les noms par `enc2utf8()` avant `utf8ToInt()`. Recommandation : sortir `citer()` en fonction partagée.

## 3. #487 : lecteur interne xlsx

### 3.1 Refus d'une cellule sans `r` ou sans aucun attribut

```r
stop("Classeur illisible : cellule sans reference de position (attribut r) dans la feuille lue ; l'outil ne deduit pas sa position. Enregistrer de nouveau le classeur depuis un tableur.")
```

- Le texte prend la forme du refus « Classeur illisible : aucune feuille trouvee. »
- Le refus passe par `stop()`, journalisé par `lire_tableau()`, qui affiche `MESSAGE_ILLISIBLE`.
- L'attribut `r` est facultatif dans `CT_Cell` (*vérifié sur des sources secondaires* qui reproduisent ECMA-376 ; voir Sources).
- *Hypothèse* : un tableur réécrit `r` à l'enregistrement.
- **Parité** : `openxlsx` lève une erreur R brute, ou perd la valeur sans message. Le contrat « même refus » exige donc un contrôle du XML commun aux deux chemins, fait avant l'appel à `openxlsx`. La forme de ce contrôle revient à `coder`.

### 3.2 Entités XML

- **Lecteur interne.**
  - Décoder les cinq entités prédéfinies (`&lt;`, `&gt;`, `&quot;`, `&apos;`, `&amp;`) et les références numériques (`&#NNN;`, `&#xHH;`), dans `sharedStrings` comme dans `inlineStr`.
  - Décoder `&amp;` en dernier.
  - *Non vérifié dans la session* : XML 1.0, § 4.1 et § 4.6 (hôte non autorisé). C'est une connaissance standard, à confirmer si `audit` le demande.
- **Ne pas post-traiter la sortie d'`openxlsx`**, sous peine de décoder deux fois.
- **Contrat « même data.frame »** : il porte sur les nombres, sur les `sharedStrings` (segments concaténés) et sur les entités nommées. Trois divergences sont à nommer dans l'en-tête d'`engine_lire_xlsx()` :
  1. les références numériques, laissées telles quelles par `openxlsx` ;
  2. les entités de `inlineStr`, laissées telles quelles par `openxlsx`. Sous Q-59-3 (ii), un en-tête exporté qui contient `&`, `<` ou `>` serait relu échappé par `openxlsx`. Cela n'a pas d'effet sur les exports de l'application, dont les en-têtes sont `t`, `xt`, `yt`, `i`, `j0`… ;
  3. la chaîne enrichie en ligne, que `openxlsx` rend `NA`.
- Aucun effet sur les nombres, donc sur σ_USP, les p-values et les verdicts.

### 3.3 Espaces d'en-tête : **aligner**

- La divergence change l'acceptation du fichier (M3). Elle ne peut donc pas seulement être nommée.
- Appeler `openxlsx::read.xlsx(…, sep.names = " ")`.
- Dans le chemin interne, appliquer la même normalisation : blancs de bord retirés, suite de blancs intérieurs ramenée à une espace.
- La règle exacte est à mesurer par `coder` sur une grille, avec un test de parité.
- **Reste** : divergence CSV ↔ xlsx (« ␣xt » refusé en CSV). **Décision du mainteneur (D3)** : nommée dans K2, issue `needs-triage` après la remise.

## 4. #550

### 4.1 O2

Remplacer `paste(utils::head(names(df)[ent_bord], 5), collapse = ", ")` par `liste(<noms echappes>)`, avec l'échappement du § 2.3. Rendu à six colonnes :

> « … (colonne(s) 10, 11, 12, 13, 14 et 1 autre(s), d'en-tete(s) vide1, vide2, vide3, vide4, vide5 et 1 autre(s)) : annee de developpement sans valeur ; la renseigner ou retirer la colonne. »

### 4.2 O1 : notation « annee d'accident i = N »

| Ligne | Actuel | Retenu |
|---|---|---|
| 9365 | `Nom d'annee d'accident en ligne 2 (i=1) declare d'encodage "bytes" : ses caracteres ne sont pas determines ; fournir le nom en UTF-8 ou en Latin-1 declare.` | `Nom de l'annee d'accident i = 1 declare d'encodage "bytes" : ses caracteres ne sont pas determines ; fournir le nom en UTF-8 ou en Latin-1 declare.` |
| 9368 | `Nom d'annee d'accident manquant ou vide en ligne 3 (i=2).` | `Nom de l'annee d'accident i = 2 manquant ou vide.` |
| 9405 | `Annee d'accident en double : "2002" (lignes 2 et 5, i=1 et i=4).` | `Annee d'accident en double : "2002" (annees d'accident i = 1 et i = 4).` |

Gabarits :
- l. 9365 : `sprintf(paste("Nom de l'annee d'accident i = %d declare d'encodage \"bytes\" :", "ses caracteres ne sont pas determines ; fournir le nom en UTF-8 ou en", "Latin-1 declare."), k - 1L)`
- l. 9368 : `sprintf("Nom de l'annee d'accident i = %d manquant ou vide.", k - 1L)`
- l. 9405 : `sprintf("Annee d'accident en double : %s (annees d'accident %s).", <formes citees>, enum(paste0("i = ", k - 1L)))`

Motif :
- Le numéro de ligne « ligne k » vaut toujours i + 1 : il est redondant.
- Une seule notation par message.
- Changement minimal (R-527.8).
- Les fixtures sont à lister dans le commit.
- Aucune référence touchée.

## 5. #488 et #439

1. **1.797e308 → `Inf` à l'export CSV actuel** : résolu par construction sous Q-59-3, car `.xlsx_nombre()` écrit « 1.7976931348623157e+308 ». Aucun σ_USP n'en dépend : le domaine [1e-50 ; 1e+50] est refusé (LN-06, MW-08).
2. **Valeurs non finies dans le nouvel export CSV.**
   - `NA` donne une cellule vide ; ±Inf est écrit en texte « Inf » / « -Inf ».
   - `NaN` revient `NA`. Le critère d'aller-retour `identical()` de l'étape 7 porte donc sur les valeurs finies et sur `NA`.
   - *Hypothèse* : la grille de saisie ne produit pas de `NaN`.
3. **`zip` externe sous Q-59-3 (ii).** L'écrivain interne appelle `utils::zip()`, qui exige un programme `zip` dans le `PATH` sous Windows (aide `?zip`, *vérifié*). **Décision du mainteneur (D2)** : compression par le paquet R `zip` s'il est présent, sinon par `utils::zip()`.
4. **#439** : aucun texte ni aucune question statistique.

## 6. `regulatory`

Non nécessaire.

## 7. Décisions revenant au mainteneur (prises le 11/11/2026)

- **D1 (#520)** : **R-a**.
- **D2 (#488)** : **paquet `zip` s'il est présent**, sinon `utils::zip()`.
- **D3 (#487)** : **divergence nommée dans K2**, issue `needs-triage` après la remise.

## Retour

- **Statut** : `revue requise`, levée par D1 à D3.
- **Critères déclenchés** :
  - changement de résultat hors des références (#520, #522, #487 « ␣xt ») ;
  - écart avec la règle #483 pour le bord gauche des triangles (test l. 2047-2054).
- Aucun désaccord. Aucun σ_USP, aucune p-value ni aucun verdict des six cas n'est touché.

## Sources

- [ECMA-376 SpreadsheetML, élément c (Cell), reproduction docx4java](https://webapp.docx4java.org/OnlineDemo/ecma376/SpreadsheetML/c_1.html)
- [ST_CellRef, reproduction docx4java](https://webapp.docx4java.org/OnlineDemo/ecma376/SpreadsheetML/ST_CellRef.html)
- [Microsoft Learn, DocumentFormat.OpenXml.Spreadsheet.Cell](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.cell)
- [docx4j, classe Cell (CT_Cell)](https://javadoc.io/static/org.docx4j/docx4j/6.1.2/org/xlsx4j/sml/Cell.html)
