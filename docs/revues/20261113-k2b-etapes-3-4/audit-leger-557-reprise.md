## Audit léger de la reprise de #557 (diff non commité, branche `claude/lecteur-xlsx-et-refus-import`, tête `0514725`)

**Verdict : conforme avec réserves.** Les constats 1 à 4 de mon audit précédent sont levés. Les décisions 3, 4, 7 et 8 sont appliquées à la lettre, et les quatre batteries passent. Il reste un constat **mineur** : une forme résiduelle du constat 1. Il ne bloque pas le commit : il se corrige par une reprise d'une ligne et d'un test, ou se consigne.

Je n'ai rien écrit dans le dépôt : `git status --short` ne montre que `R/engine.R` et `tests/unitaires/test_controles_entree.R`, et `git diff --check` est propre. Mes essais sont dans `<scratchpad>/audit557b/` (`adv3.R`, `adv4.R`, sorties `*.txt`, `head/engine.R` = `git show HEAD:R/engine.R`).

### Constat

**M1 (mineur) : `<rPh .../>` auto-fermant avec un `>` littéral dans une valeur d'attribut fait encore perdre le texte réel**
- **Où :** `R/engine.R:8531-8532`, `.xml_textes()`, et le commentaire `R/engine.R:8527-8528`.
- **Cause :** les deux motifs utilisent `[^>]*`. Sur `<rPh sb="0>" eb="0"/>`, le premier motif ne trouve pas la forme auto-fermante. Le second prend `<rPh sb="0>` pour une balise ouvrante et avale tout jusqu'au `</rPh>` suivant. La phrase du commentaire « Apres le premier retrait, toute balise <rPh restante est ouvrante » est donc fausse dans ce cas.
- **Mesure de la fonction seule** (`adv3.R`, sous `LC_ALL=C.UTF-8`) : `.xml_textes('<t>1</t><rPh sb="a>b"/><t>2</t><rPh><t>Z</t></rPh><t>3</t>')` rend `"13"` au lieu de `"123"`.
- **Mesure de bout en bout** (`adv4.R`, chaîne partagée `<r><rPr><b/></rPr><t>1</t></r><rPh sb="0>" eb="0"/><r><t>1.5</t></r><rPh sb="1" eb="1"><t>Z</t></rPh>` en B2) :

| Chemin | À la tête | Après la diff |
|---|---|---|
| Lecteur interne | `11.5Z` (refusé en aval) | `xt = 1`, sans message |
| openxlsx 4.2.9 | 1 | 1 |

  Avec `sb="0&gt;"` (entité), le lecteur interne lit bien 11.5.
- **Portée :** l'entrée est doublement hors schéma : `sb` est un `xsd:unsignedInt`, et `<rPh/>` n'a pas de `<t>`. Elle reste du XML bien formé. Sur le chemin interne, la diff change un refus en valeur fausse.
- **Correction suggérée :** dans les deux motifs, remplacer le groupe d'attributs par une version qui tient compte des guillemets : `([ \t\r\n]([^>"']|"[^"]*"|'[^']*')*)?`. Mesuré sous TRE : il rend `"123"` sur le cas ci-dessus et garde les quatre résultats du test actuel (`"xt"`, `"112"`, `"abc"`). Ajouter ce cas au test. À défaut, corriger la phrase du commentaire et consigner la limite. Pas de décision à prendre.

### Constats de l'audit précédent

1. **Constat majeur 1 : levé.**
   - Le retrait se fait en deux temps (`<rPh(...)?/>`, puis les blocs).
   - Le choix de `[^>]*` plutôt que `[^>/]*` dans le second motif est justifié et testé : `<rPh sb="a/b">…</rPh>` est retiré et `"abc"` est lu.
   - `adv.R` rejoué : les cinq cas `rPh` donnent `"xt"`, `rPhX` n'est pas visé, la TAB est traitée, le saut de ligne aussi.
   - Nouveau test « `<rPh sb="0" eb="0"/>` suivi d'un vrai `<rPh>` » plus un bloc multiligne.
   - Seul le résidu M1 ci-dessus subsiste.
2. **Constat 2 : levé.**
   - Le premier refus porte maintenant sur `<c[[:space:]]` autre que `"<c "`, et l'extraction utilise `[[:space:]]`, la même classe que `.xlsx_cellules()`.
   - `<c\fr="1">` et `<c U+2003 r="1">` sont refusés au texte BALISE_C (`adv.R`, `adv2.R` cas 3, sur les deux chemins).
   - NBSP : le contrôle l'admet, mais le lecteur ne lit aucune cellule (`character(0)`), donc il n'y a pas d'écart entre les deux.
3. **Constat 3 : levé par la décision 8.** `r="&#65;2"` est refusé au texte de la décision 3 sur les deux chemins (`adv2.R` cas 2). Avant, openxlsx levait une erreur R brute.
4. **Constat 4 : levé.** L'assertion `rphC557` passe sous 4.2.9 et 4.2.5.2 : texte exact « valeur non numérique » côté openxlsx, 11 lu côté interne.

### Décisions du mainteneur
- **Décision 7 (Q-F).**
  - **Texte :** il est identique au caractère près au texte de `decisions-mainteneur.md` (comparaison en `python3`, une seule occurrence), et `QF557` est égal à ce texte.
  - **Condition :**
    - présence d'un segment `<r>`, `<x:r>`, `<r >` ou `<r/>` ;
    - absence de toute balise littérale `<rPr>`.
  - **Formes que la condition ne prend pas pour un segment** (`adv3.R`) : `<rPh`, `<rPr>` seul, `&lt;r&gt;` dans un texte.
  - **Formes refusées** (mesures `X5`, `X6` de `coder`) : `<rPr/>`, `<rPr a="1">` et `<x:rPr>` ne suffisent pas à lever le refus.
  - **Cohérence avec openxlsx :** `X4` (`<rPr>` dans un commentaire) est lu juste par openxlsx, donc la condition suit bien le critère littéral d'openxlsx.
  - **Place :** sur les deux chemins, après les contrôles de la feuille et avant celui de la ligne 1 et l'appel à openxlsx (`R/engine.R`, `engine_lire_xlsx()`).
  - **Classe :** `usp_refus_lecture` (testé).
  - **F7 :** une table qui ne contient qu'un seul `<r>` sans `<rPr>` est refusée (`<si><r><t>xt</t></r></si>` donne TRUE dans `adv3.R`, et le test de classe utilise justement `<si><r><t>t</t></r></si>`), alors qu'openxlsx lirait juste un segment unique. C'est conforme à la lettre de Q-F (« au moins un segment `<r>` sans aucun `<rPr>` dans toute la table »). Cela reste un refus de sens sûr, sous l'hypothèse non vérifiée qu'aucun tableur n'écrit cette forme.
- **Décision 8 (Q-A étendue).** On exige exactement un attribut de nom entier `r` et une valeur brute `^r="[A-Za-z]+[1-9][0-9]*"$`.
  - Refusés (`adv.R`, `adv3.R`, tests) : `<c r='Z9' r="B3">`, `<c r="B3" r='Z9'>`, `<c r="Z9" r="B3">`, `<c r="A2"r="B2">`, `&#66;3` et `A2&#10;`.
  - Admis : `x:r` à côté de `r`, et `s='a r="B2"' r="A2"` (même découpage que `.xlsx_attribut()`).
  - Texte identique à `REF557` et au § 2 de l'avis d'`actuary`.
  - Ordre : le refus « sans r » passe en premier (`rordre557`).
- **Décision 3 :** les formes `""`, `1`, `A0`, `1A`, `" A2 "`, `A` et `A1:B2`, ainsi que `<c r="" s="1"/>`, sont refusées sur les deux chemins (tests).
- **Décision 4 :** le texte phonétique est retiré, sous la réserve de M1.
- **Refus « sans r » inchangé octet pour octet et non élargi :**
  - Son texte et celui de BALISE_C sont identiques à la tête (comparaison des lignes `.refus_lecture`).
  - La condition `[ \t\r\n]r="` n'a pas changé.
  - L'ensemble des balises qu'il contrôle est le même qu'avant : seules les balises `<c ` survivent au premier refus.
- **Aucun fichier juste aujourd'hui n'est refusé hors décisions :**
  - Les seuls nouveaux refus hors décisions 3, 7 et 8 portent sur `<c` suivi de FF, VT ou U+2003 : c'est du XML illégal, que le lecteur interne lisait déjà faux.
  - F7 est couvert par la décision 7.

### P2 et X1 : antérieurs, non aggravés
J'ai rejoué `mesure.R` et `mesure_x.R` de `coder` contre la tête (`MOTEUR=head/engine.R`) et contre la diff :

| Cas | Chemin | À la tête | Après la diff |
|---|---|---|---|
| P2 | openxlsx (4.2.9 et 4.2.5.2) | `xt = 1` | `xt = 1` |
| P2 | lecteur interne | refus en aval | 11,5, juste |
| X1 | openxlsx | 1 | 1 |
| X1 | lecteur interne | 11,5 | 11,5 |

- **P2 :** la valeur fausse est identique avant et après la diff ; la diff ne touche pas la sortie d'openxlsx, et le lecteur interne passe d'un refus à la valeur juste.
- **X1 :** rien ne change sur aucun des deux chemins ; la diff ne modifie ni la concaténation des `<t>` ni le chemin openxlsx.
- **À noter :** openxlsx est le chemin par défaut quand il est installé. Ces deux limites restent donc des valeurs fausses acceptées sur ce chemin. C'est déjà porté par `coder` en question.

### Vérifications exécutées (sous `LC_ALL=C.UTF-8`)

| Commande | Résultat |
|---|---|
| `Rscript tests/unitaires/test_controles_entree.R`, sans openxlsx | 409/409 ok, rc 0 |
| La même, avec openxlsx 4.2.9 | 424/424 ok, rc 0 |
| La même, avec 4.2.5.2 (`lib_old:lib`) | 424/424 ok, rc 0 |
| `Rscript tests/comparer_references.R --seuil 0` | CONFORME, 57 018 feuilles, écart maximal 0, rc 0 |
| `Rscript tests/concordance_doc_moteur.R --strict` | 0 écart, rc 0 |

Rejeux et essais complémentaires :
- `adv.R` (sans le chronométrage) : tous les cas sont conformes.
- `adv2.R` (4.2.9) : les trois cas sont refusés aux textes fixés, sur les deux chemins.
- `adv3.R` : formes de `r`, NBSP, Q-F, `<rPh>` avec `>` dans une valeur.
- `adv4.R` : M1 de bout en bout, tête contre diff.
- Rejeu P2 et X1 contre la tête et contre la diff.
- Contrôle des textes exacts en `python3`.

### Questions pour `actuary`
Aucune nouvelle : la diff ne modifie aucun `detail` ni aucune `reference` du registre des tests. P2 et X1 restent les questions déjà portées par `coder`.
