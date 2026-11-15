# Avis d'actuary sur les questions du lot C de #574 (S1, étape 5)

> *Rédigé par l'agent actuary (IA), fiche `actuary` (routine), le 15/11/2026, sur `claude/lecteurs-contrat-ferme` (`185a3e7` et diff non commité du lot C). Aucun fichier écrit par l'agent. Versé intégralement par la session principale (Q-54-10). Décision du mainteneur qui en découle : `decisions-mainteneur.md`, D-S1-12.*

En bref : les cinq points sont acceptés et aucun code n'est à modifier. Il reste une décision du mainteneur : viser le tableau avant / après du lot C, comme il l'a fait avec D-S1-10 pour le lot B. Je n'ai écrit aucun fichier.

### 1. `<v/>` et `<v></v>` : accepté, sans décision nouvelle

- **`<v/>` traité comme une absence de `<v>`.** C'est fondé sur la mesure : avant le lot, `<v/>` est lu comme une cellule sans `<v>` sur chaque type.
  - Cas `r8-n-auto`, `r8-str-auto`, `ok-is-auto-seul` : NA sur les deux chemins.
  - Cas `r8-s-auto` : 11.5 par openxlsx (σ_USP = 0.2005042338).
  - Cas `r8-b-auto` : "FALSE" par openxlsx.
  - La conséquence est que l'amendement Q5 (`t="s"` et `t="b"` sans `<v>` refusés) couvre aussi `<v/>`. C'est voulu : `t="s"` `<v/>` est une valeur fausse sur le chemin openxlsx (groupe A).
- **`<v></v>` refusé pour un nombre (`t` absent ou `n`).** Avant le lot : lu "" en interne et 0 par openxlsx. Sur la série, ce 0 n'était refusé que par la règle de positivité de x_t. Dans une colonne où 0 est admis (un incrément de triangle, par exemple), openxlsx rendrait une valeur fausse. Le refus relève donc du groupe A et non d'une forme lue juste. Il n'écarte aucune forme lue juste.
- **`<v></v>` admis pour `t="str"`.** Les deux chemins le lisent "" (cas `r8-str-vide`), il y a parité, et la donnée est refusée en aval si elle tombe dans le tableau. C'est le côté sûr.
  - Que ce soit ce qu'écrit Excel pour une formule qui rend "" reste une **hypothèse non vérifiée** : je n'ai pas de source.
  - Le choix ne dépend pas de cette hypothèse.
- **`t="inlineStr"` avec `<v/>` et `<is>` admis** (cas `r8-is-auto`, σ_USP = 0.1114524114 sur les deux chemins) : c'est cohérent avec la règle.
- **Une précision pour le bilan, sans effet sur le code.** Mon texte de R8 portait deux lignes en tension : « inlineStr : la cellule porte `<is>` » et « une cellule sans `<v>` ni `<is>` est admise ». Le codeur a retenu « `<is>` facultatif ». Je l'accepte : c'est la règle générale, et ma mesure du lot B (Q5) montre que `inlineStr` sans `<is>` n'invente pas de valeur et n'alloue rien en XFD1048576.

### 2. Positions citées : accepté, sans décision

- `t="e"` sans valeur cite la référence seule (« B2 ») ; `t="d"` cite la valeur. C'est conforme aux textes du § 2 de l'avis amont.
- Garder le blanc de tête dans « B2 :  1 » est exact : le refus porte justement sur ce blanc. Le double espace reste peu lisible.
- Mettre la valeur citée entre guillemets serait plus clair, mais `.xlsx_citer()` est la convention commune des autres refus. Je classe ce point en mineur écarté (ADR 0018, critère « aucun ») et je ne propose aucun changement.

### 3. Ordre interne des refus : accepté, sans décision

- R7 refuse d'abord un type inconnu (forme forgée), puis `d`, puis `e` (erreur de tableur, à corriger par l'utilisateur). Chaque refus arrête la lecture : l'ordre ne change que le message rendu quand un classeur cumule plusieurs fautes, jamais le fait d'accepter ou de refuser.
- Dans R8, l'ordre contenu et type, puis nombre, puis booléen est cohérent.
- Évaluer R8 avant R10 est nécessaire : l'indice de chaîne partagée est alors fait de chiffres seulement. Le commentaire de R10 est mis à jour en conséquence, et c'est exact (`-1` refusé par R8, « indice de chaine non entier »).

### 4. `1e400` : ne pas le refuser dès R8 ; accepté tel quel, sans décision

- **Mesure.** Avant et après le lot, `1e400` est lu `Inf` par les deux chemins. `run_engine()` rend alors `ok = FALSE` (« Valeurs infinies : x_t et y_t doivent etre des nombres finis. »), et le triangle refuse Inf à la lecture, selon le codeur.
- **Avis.** Aucune valeur fausse n'est acceptée. Les deux chemins sont à parité et le refus est motivé. R8 est une règle de forme (syntaxe décimale) ; y ajouter un contrôle de domaine numérique dupliquerait `engine_valider_donnees()` sans rien protéger de plus.
- **Constat lié**, mesuré sous R avec `LC_ALL=C.UTF-8` :
  - commande : `Rscript -e 'as.numeric(c("1e400","1e-400","1e-320","4.9e-324","1.7976931348623158e308"))'` ;
  - sortie : `Inf 0 9.999889e-321 4.940656e-324 Inf`.
  - `1e-400` passe donc à 0. Ce n'est pas un écart matériel (|écart| < 1e-300), je le range en « aucun » (ADR 0018).
  - DBL_MAX écrit en 17 chiffres est lu `Inf` par `as.numeric()`. Excel ne monte pas au-delà d'environ 9,99E+307 : c'est une **hypothèse non vérifiée**. Le cas serait de toute façon refusé en aval. Critère « aucun ».

### 5. Formes lues juste et désormais refusées : couvertes par D-S1-1, mais le visa du tableau avant / après reste requis

La règle de visa : D-S1-1 a retenu le contrat complet R0-R12, dont les textes de R7 et R8 nomment ces cas. Aucune décision nouvelle de fond n'est donc nécessaire. En revanche, chacun de ces cas faisait rendre un σ_USP avant le lot et est refusé après. C'est un changement de résultat hors références, qui va dans le tableau avant / après du commit du lot C, soumis au visa du mainteneur comme l'a été D-S1-10 pour le lot B (règle « Approbation des changements de résultats » de CLAUDE.md).

| Forme | Avant (les deux chemins) | Fondement dans le contrat retenu | Avis |
|---|---|---|---|
| `t="S"` `<v>1</v>` | lu 1, σ_USP = 0.1700579153 | R7 « toute autre valeur est refusée » | **Valeur fausse** (la chaîne d'indice 1 est 104.2) : groupe A, le refus corrige un défaut |
| `t="N"`, `t="Str"` | 104.2, σ_USP = 0.1114524114 | R7, comparaison exacte | Groupe B. L'énumération du type de cellule (ST_CellType) est sensible à la casse en XML Schema. Ce point n'est **pas vérifié sur le texte ECMA-376** dans cette consultation ; le refus tient de toute façon par le contrat |
| `t="s"` d'indice `" 1"`, `1.0`, `+1`, `1e0` | 104.2, σ_USP = 0.1114524114 | R8 « `s` : `^[0-9]+$` » | Groupe B. Un validateur XSD d'entier accepterait `+1` et `" 1"` (repli des blancs), mais `<v>` n'est pas typé entier dans le schéma, et aucun tableur ne les écrit (*hypothèse*). L'indice `01` reste admis, ce qui est cohérent avec le motif |
| `t="n"` avec `<is>` | 104.2 | R8 « `t` absent ou `n` : pas d'`<is>` » | Groupe B, couvert ; c'est la variante explicite de « `<is>` sans `t="inlineStr"` », déjà listée au § 8 B |
| `t="str"` avec `<is>` | 104.2 | R8 « `str` : … sans `<is>` » | Groupe B, couvert |
| `inlineStr` avec `<v>`, avec ou sans `<is>` | 104.2 | R8 « `inlineStr` : … sans `<v>` » | Groupe B, couvert. La cellule ambiguë (deux valeurs possibles) est refusée par construction, ce que je recommande |

La table du § 8 de l'avis amont n'était pas exhaustive. Elle illustrait les groupes A et B par des exemples, alors que le texte de R7 et R8 énumère les règles. L'omission relève de la complétude de mon avis amont et non d'un écart du code.

---

## Retour

- **Statut** : `complet` pour l'avis. Le visa du lot C relève du mainteneur.
- **Résultat** : les points 1 à 5 sont acceptés. Aucune modification de code n'est demandée.
- **Preuves**
  - *Vérifié* :
    - le diff non commité de `R/engine.R` (`.xlsx_controler_types()`, `.xlsx_controler_contenus()`, `XML_MOTIF_NOMBRE`, ordre d'appel dans `.xlsx_admettre()`) ;
    - les sorties `/home/user/outil_usp/docs/revues/20261115-s1-rejeu/sorties/574-lot-c-avant.txt` et `574-lot-c-apres.txt`, extraites par awk pour les cas `r7-t-S`, `r7-t-N`, `r7-t-Str`, `r8-s-blanc`, `r8-s-1.0`, `r8-s-plus1`, `r8-s-1e0`, `r8-tn-is`, `r8-str-is`, `r8-is-v`, `r8-is-v-seul`, `r8-is-auto`, `r8-*-vide`, `r8-*-auto`, `r8-n-1e400`, `r7-t-e-*`, `r7-t-d`, `r8-b-blanc` ;
    - dans la sortie après, aucun code de sortie non nul (`grep -c "code de sortie : [^0]"` rend 0) ;
    - la mesure `as.numeric()` du point 4 ;
    - les textes de R7 et R8 et le § 8 (avis amont, l. 77-92 et 278-330), l'amendement Q5 (avis du lot B, l. 78-94), D-S1-1 et D-S1-10 (`decisions-mainteneur.md`).
  - *Hypothèses* :
    - Excel écrirait `<v></v>` pour `t="str"` quand la formule rend "" ;
    - aucun tableur n'écrirait les formes du point 5 hors `t="S"` ;
    - plafond d'Excel vers 9,99E+307.
  - *Non vérifiés* :
    - sensibilité à la casse de ST_CellType sur le texte ECMA-376 ;
    - openxlsx 4.2.9 ;
    - Windows ;
    - le refus de Inf par le triangle, repris du codeur sans remesure.
- **Informations manquantes** : texte normatif ECMA-376 (partie 1, § 18.18.11), non consulté.
- **Décisions non résolues** (mainteneur) : visa du tableau avant / après du lot C. Il doit couvrir :
  - les formes du point 5 ;
  - `t="e"` hors du tableau (D2 : σ_USP rendu avant, refus après ; déjà décidé par D-S1-2 (i), mais c'est un changement de résultat) ;
  - `t="d"` ;
  - le chemin openxlsx de `t="s"` sans `<v>` ou avec `<v/>` (σ_USP = 0.2005042338, puis refus) ;
  - les formes du § 8 A et B déjà décidées.
- **Critères déclenchés** : changement de résultat hors références (σ_USP rendu, puis refus) ; aucun désaccord avec `audit` ni avec un ADR.
- **Constats hors périmètre** :
  - `1e-400` lu 0 et DBL_MAX en 17 chiffres lu `Inf` par `as.numeric()` : critère « aucun » (écart non matériel, ou refusé en aval) ;
  - double espace dans « B2 :  1 » : critère « aucun » (lisibilité).
- **Prochaine action recommandée** : le codeur ajoute au tableau avant / après du commit du lot C une ligne par forme du point 5 (avant : σ_USP ; après : texte du refus), puis la session soumet ce tableau au visa du mainteneur avant le commit. Ensuite, `audit` léger du diff.