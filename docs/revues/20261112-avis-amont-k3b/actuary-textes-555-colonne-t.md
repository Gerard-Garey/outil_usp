# Complément K3b : colonne `t` des séries (étape 8, #555)

> *Complément de l'agent actuary (IA), fiche de base, le 12/11/2026, après les décisions 7 et 8 du mainteneur.* Versé intégralement par la session principale (Refs #555). L'agent n'a rien écrit dans le dépôt.

Le mainteneur a confirmé (a) pour `I` / ` i ` et étendu K3b à `t`. Je n'ai rien écrit dans le dépôt.

**Ce que j'ai fait** :
- Lu `R/engine.R` l. 7895-7970 (`engine_lire_donnees_csv()`).
- Mesuré le comportement actuel avec `Rscript` sous `C.UTF-8`, moteur chargé par `charger_moteur()`, lecteur interne du classeur seulement (`openxlsx` absent). Script : `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/t.R`.

## Ce que fait le moteur aujourd'hui

| Fichier | CSV | Classeur (lecteur interne) |
|---|---|---|
| `t, xt, yt, t` (même `t` ou `t` différent) | accepté ; tri sur le premier `t`, le second ignoré sans message | lu `t, xt, yt, t.1` ; même effet |
| `t, xt, yt, T` | accepté, `T` ignoré | idem |
| `T, xt, yt` (lignes dans le désordre) | accepté, **ni tri ni contrôle de consécutivité**, série lue dans l'ordre du fichier | idem |
| ` t , xt, yt` | `t` non reconnu, comme `T` | déjà reconnu (blancs retirés) : tri |
| `t, xt, yt, xt` | accepté, **le second `xt` ignoré sans message** | lu `xt.1` ; même effet |
| `t, XT, yt` | refus « Colonne(s) manquante(s) : xt … » | idem |

## (i) Textes fixés mot pour mot

| Cas | Texte | Remplissage des `%s` |
|---|---|---|
| En-tête `t` présent plusieurs fois (règle N : `t` ou `T`, blancs de bord `[[:space:]]` ignorés) | `En-tete de la colonne t present plusieurs fois (colonnes %s, d'en-tetes %s) : la colonne t, facultative, porte l'annee de chaque ligne et ne peut figurer qu'une fois (en-tete t ou T, blancs de bord ignores) ; retirer ou renommer la colonne en trop.` | positions des colonnes dans le tableau reçu, par `liste()` ; puis `liste(.echapper_texte(noms bruts))`, comme pour H1 et #550 |
| Option, **décision du mainteneur** : `xt` ou `yt` en double (comparaison exacte, sans règle N, conformément à D3) | `En-tete %s present plusieurs fois (colonnes %s) : la colonne %s ne peut figurer qu'une fois ; retirer ou renommer la colonne en trop.` | le nom, puis `liste(positions)`, puis le nom ; un message par nom en double |

Les messages existants de la colonne `t` (incomplète, non entière, dupliquée, et non consécutive dans son texte corrigé de mon premier rapport) ne changent pas. Ils s'appliquent à la colonne reconnue, quelle que soit la forme de son en-tête.

## (ii) Interactions

1. **Un en-tête `T` qui serait une donnée légitime.** Seules `t`, `xt` et `yt` sont attendues ; toute autre colonne est ignorée. L'export de l'application écrit `t, xt, yt`. Le seul `"T"` du moteur (l. 13977) est un argument, pas une colonne. Une colonne `T` porterait donc vraisemblablement l'année (en notation, T est la dernière année, B/C(3)(b)). Le risque résiduel est de deux ordres :
   - si `T` porte autre chose que des années, on obtient un refus par les motifs de `t`. Ce n'est pas silencieux, donc c'est acceptable ;
   - si `T` porte, par coïncidence, une permutation d'entiers consécutifs, les lignes sont réordonnées sans message. Je juge ce cas négligeable. Il est à signaler dans la PR.
2. **Colonne vide d'en-tête `T`.** Elle était ignorée. Une fois renommée `t`, elle est refusée par « Colonne t incomplete … ». C'est un changement de comportement, en sécurité.
3. **`t` + `T`, `t` + ` t `, `T` + ` t `** : refus « t en double ».
4. **Nom `NA` ou non UTF-8** : ne désigne jamais `t`. Garde `validUTF8()`, comme pour `i`.
5. **Doublon de `xt` ou de `yt`** : même défaut silencieux que `t` (le premier est pris). Il n'est pas couvert par la décision 2 ; d'où la ligne « option » ci-dessus. **Recommandation : l'inclure.** Le texte est prêt ; un second `xt` ignoré peut fausser σ_USP sans message, si c'était celui que l'utilisateur voulait fournir.
6. **Résultats** : aucun fichier dont la colonne s'intitule exactement `t` ne change. Références identiques (`--seuil 0`) ; aucun σ_USP, aucune p-value, aucun verdict des références ne change. Les fichiers `T`, ` t ` (CSV) ou en double changent de sort : tri, ou refus.

## (iii) Emplacement

Dans `engine_lire_donnees_csv()` :
1. après `.declarer_latin1()` et le refus `.ligne1_sans_valeur()` (`MOTIF_LIGNE1_VIDE`, qui reste en tête) ;
2. **étape des noms**, avant la recherche des colonnes manquantes : refus « t en double » (et, si l'option est retenue, « xt / yt en double »), **cumulés** avec le motif des colonnes manquantes, qui est de la même étape, et rendus ensemble ;
3. sans doublon : la colonne unique reconnue est renommée `"t"`, et **`noms` est recalculé**. Point à ne pas manquer : `noms` est figé à la l. 7904 et relu à la l. 7955 (`"t" %in% noms`) ;
4. tout cela avant `.retirer_lignes_colonnes_vides()`, dont la sélection de colonnes `df[, !retirer]` renommerait un doublon en `t.1`.

**Parité avec le classeur.** C'est la même exigence que pour H1 : le lecteur interne (`make.unique()`, l. 8690) rend `t, t` sous la forme `t, t.1`, et `xt, xt` sous la forme `xt, xt.1`. Ces doublons échappent au contrôle. La correction doit être unique pour `i`, `t`, `xt` et `yt` (piste : retirer `make.unique()` du lecteur interne). La parité avec `openxlsx` reste à mesurer par `audit` dès que le paquet est disponible. ` t ` est déjà ramené à `t` sur ce chemin, et la règle N est sans effet sur un nom déjà mis en forme.

## Tests à prévoir

- `T, xt, yt` dans le désordre → trié, identique au même fichier avec `t` ; idem pour ` t ` en CSV, identique au classeur.
- `t` + `T`, et `t` + `t` en CSV et en classeur (lecteur interne) → `identical()` au texte « t en double », en-têtes cités tels que lus, sans `t.1`.
- `T` avec un trou → message « Colonne t : annees non consecutives … » (texte corrigé) ; `T` vide → « Colonne t incomplete … ».
- `t` en double et `xt` manquant → les deux motifs, cumulés.
- Si l'option est retenue : `xt, xt` sur les deux chemins → texte « xt en double ».
- Régression : `t` exact, fichiers existants identiques.

## Retour

- **Statut** : `complet`, sauf la parité avec `openxlsx`, non mesurée faute du paquet.
- **Résultat** : textes, emplacement et tests fixés pour `t` ; doublons silencieux de `xt` / `yt` mis au jour, avec un texte prêt.
- **Preuves** :
  - *Vérifié par mesure* : le tableau du comportement actuel (CSV et lecteur interne).
  - *Vérifié par lecture* : l. 7904 et 7955 (`noms` figé), l. 13977 (`T` est un argument).
  - *Hypothèse* : une colonne `T` dans un fichier de séries désigne l'année.
- **Informations manquantes** : `openxlsx` absent ; comportement sous Windows non mesuré.
- **Décisions non résolues** : inclure le refus des doublons `xt` / `yt` dans K3b (mainteneur ; je recommande oui) ; forme de la correction de `make.unique()` (`coder` et `audit`).
- **Critères déclenchés** : changement de comportement hors références (fichiers `T` ou ` t ` triés, doublons et colonne `T` vide refusés) ; aucun changement de σ_USP ni de verdict sur les références.
- **Prochaine action recommandée** : faire trancher l'option `xt` / `yt` par le mainteneur ; passer ces textes à `coder-approfondi` pour l'étape 8, avec le critère de parité commun à `i` et `t` ; contrôle des textes par `regulatory` en aval (décision 6).
