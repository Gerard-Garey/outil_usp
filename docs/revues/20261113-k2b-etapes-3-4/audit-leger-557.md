## Audit léger de #557 (diff non commité de `R/engine.R` et `tests/unitaires/test_controles_entree.R`, branche `claude/lecteur-xlsx-et-refus-import`, tête `b048d5a`)

**Verdict : non conforme.** Un constat majeur demande une reprise : une correction d'une ligne et un test. Tout le reste est conforme. Les quatre batteries passent, les textes fixés sont repris mot pour mot, aucune dépendance n'est ajoutée et les références sont identiques au seuil 0.

Rien n'a été écrit dans le dépôt : `git status --short` ne montre que les deux fichiers déjà modifiés. Mes essais sont dans `<scratchpad>/audit557/` (`adv.R`, `adv2.R`, sorties des batteries, et `head/` : copie de la tête obtenue par `git archive`).

### Constats

**1. MAJEUR : une balise `<rPh .../>` auto-fermante avec attributs fait perdre du texte réel, et la diff crée ainsi une valeur fausse sans message**
- **Où :** `R/engine.R:8523`, fonction `.xml_textes()`, ligne `gsub("<rPh([ \t\r\n][^>]*)?>.*?</rPh>", "", x)`.
- **Cause :** dans le motif, `[^>]*` accepte le `/`. Une balise `<rPh sb="0" eb="0"/>` est donc lue comme une balise ouvrante. Le `.*?</rPh>` qui suit avale alors le vrai texte jusqu'au `</rPh>` suivant.
- **Mesure de la fonction seule (`adv.R`) :**
  - `.xml_textes('<r><t>x</t></r><rPh sb="0" eb="0"/><r><t>t</t></r><rPh sb="1" eb="1"><t>Z</t></rPh>')` rend `"x"` au lieu de `"xt"`.
- **Mesure de bout en bout (`adv2.R`, chaîne partagée `<r><t>1</t></r><rPh sb="0" eb="0"/><r><t>1.5</t></r><rPh sb="1" eb="1"><t>Z</t></rPh>` en B2) :**
  - lecteur interne : `xt = 1`, sans message ;
  - à la tête, le lecteur interne lisait `"11.5Z"`, valeur non numérique donc refusée en aval ;
  - openxlsx 4.2.9 lit aussi `1`, mais c'est sa limite déjà consignée (premier segment `<r>` seulement).
- **Effet :** sur le chemin interne, la diff transforme un refus en valeur fausse sans message.
- **Ce qui marche (mesuré) :** `<rPh/>` sans attribut n'est pas pris par le motif, sans effet. Un `<rPh>` vide est retiré. Un saut de ligne dans le bloc ne gêne pas : sous TRE par défaut, `.` traverse les fins de ligne. Plusieurs `<rPh>` sont retirés. Une TAB avant les attributs est traitée. `<rPhX>` n'est pas visé. Une chaîne sans `rPh` est inchangée.
- **Portée :** l'entrée est hors schéma (`CT_PhoneticRun` exige un `<t>`) et aucun tableur ne l'écrit. Mais elle entre dans la doctrine « refus, jamais une valeur fausse », et le brief demandait explicitement la forme auto-fermante.
- **Correction proposée :** retirer d'abord les formes auto-fermantes, puis les paires :
  ```r
  x <- gsub("<rPh([ \t\r\n][^>]*)?/>", "", x)
  x <- gsub("<rPh([ \t\r\n][^>/]*)?>.*?</rPh>", "", x)
  ```
  Ajouter un test sur `.xml_textes()` avec `<rPh sb="0" eb="0"/>` suivi d'un vrai `<rPh>`, et un test avec un saut de ligne dans le bloc (aucun des deux n'existe aujourd'hui).

**2. MINEUR : le contrôle ne voit pas certaines balises `<c>` que le lecteur lit**
- **Où :** `R/engine.R:8670-8673`, `.xlsx_controler_cellules()`.
- **Cause :** les règles lexicales diffèrent.
  - Le contrôle extrait ses balises avec `<c([ \t\r\n][^>]*)?/?>`.
  - `.xlsx_cellules()` lit `<c[[:space:]]...`. Sous C.UTF-8, `[[:space:]]` couvre aussi `\f`, `\v` et U+2003.
- **Mesure (`adv.R`) :**
  - `.xlsx_controler_cellules('<c r="1"><v>1</v></c>')` admet la balise (même chose avec `\f`) ;
  - `.xlsx_cellules()` en lit pourtant `ref = "1"`.
- **Mesure de bout en bout (`adv2.R`) :**
  - lecteur interne : `xt = NA`, `yt = 1.5` (valeur déplacée), avec deux avertissements R ;
  - openxlsx : `yt = 6`, la valeur est perdue sans message.
- **Portée :** le XML est mal formé (U+2003 n'est ni un blanc XML ni un `NameChar`). Le défaut existait déjà pour le refus « sans r » (#487). Mais le nouveau commentaire annonce le refus sur « toutes les balises `<c>` ».
- **Correction proposée :** dans les deux contrôles, utiliser la même classe que le lecteur : refuser `<c` suivi de tout `[[:space:]]` autre que l'espace, puis extraire avec `<c([[:space:]][^>]*)?/?>`. À défaut, consigner la limite.

**3. MINEUR : une référence écrite avec une entité est admise, et la parité est rompue**
- **Où :** `R/engine.R:8674-8676`.
- **Cause :** `.xlsx_attribut()` décode la valeur, donc `r="&#65;2"` est lu `A2` et passe la regex.
- **Mesure (`adv2.R`) :**
  - lecteur interne : lecture normale ;
  - openxlsx 4.2.9 : erreur R brute `missing value where TRUE/FALSE needed`.
- **Écart avec la décision 3 :** c'est précisément le mode de défaillance que la décision voulait supprimer, même si la valeur brute n'a pas la forme de la regex.
- **Correction proposée :** refuser aussi une valeur brute de `r` qui contient `&`, par exemple avec `grepl('[ \t\r\n]r="[^"]*&', balises)`. On garde ainsi la lecture décodée commune avec le lecteur pour tout le reste.
- **Décision :** l'extension de la règle relève du mainteneur si `coder` préfère consigner la limite.

**4. MINEUR : une affirmation de commentaire n'est figée par aucun test**
- **Où :** commentaire de `R/engine.R:8518-8521`.
- **Affirmation :** dans le corps, une chaîne en ligne avec `<rPh>` est rendue NA par openxlsx, puis refusée en aval (séries : « valeur non numérique » ; triangle : « cellule observée manquante »).
- **État :** c'est mesuré par `coder` (`coder557/apres_rph2.txt`, sur 4.2.9 et 4.2.5.2). Mais le test `rphI557` ne vérifie que la colonne ignorée `z` (NA).
- **Correction proposée :** sous `if (avec_openxlsx483)`, ajouter une assertion qui passe la feuille dans `engine_lire_donnees_csv()` avec `<rPh>` en `xt` et vérifie le motif.

**5. MINEUR (information, pas de reprise demandée) : coût du nouveau contrôle**
- **Où :** `R/engine.R:8674`. Le `vapply(.xlsx_attribut)` porte sur chaque balise.
- **Mesure :**

| Cellules | Contrôle | `.xlsx_cellules()` |
|---|---|---|
| 10 000 | 0,59 s | 1,06 s |
| 100 000 | 7,2 s | 14,2 s |

- **Lecture :** environ +50 % sur ce poste de la lecture. C'est négligeable aux tailles utiles (T = 8, triangle de quelques dizaines de cellules). Vectoriser par un `regmatches` unique demanderait de reproduire exactement la règle « nom entier, première occurrence », ce qui ne vaut pas le risque.

### Points vérifiés et conformes
- **Textes fixés :** comparaison automatique (`python3`, sous-chaîne exacte). Les quatre blocs de l'avis d'`actuary` sont présents à l'identique dans `engine.R` :
  - § 1, `t="str"` ;
  - § 2, texte du refus ;
  - § 3, commentaire sur `<rPh>` ;
  - § 3, correction du point 4.
  - `REF557` du test est identique au texte du § 2.
  - L'ancienne phrase « Les entites d'une cellule t="str" ne sont decodees par aucun des deux chemins » a bien été retirée.
- **Règles du refus de référence :**
  - il passe après le refus « sans r », dont le texte reste inchangé (test `rordre557`) ;
  - il est de classe `usp_refus_lecture` ;
  - il porte sur les balises auto-fermantes (`<c r="" s="1"/>` refusé) ;
  - il lit la référence comme le lecteur (`x:r="Z9" r="A2"` admis ; `r='0' r="A2"` : le contrôle et le lecteur voient tous deux `0`) ;
  - les minuscules restent admises.
- **Formes testées à la main :**
  - refusées : `A01`, `é2`, `Ａ2`, `"A2 "`, `A2&#10;` (pour `A01`, c'est l'effet voulu de `[1-9]`) ;
  - admises : `XFD1048576` et `AAAAAAAAAA1`, car aucune borne n'est contrôlée, ce qui est consigné.
- **Architecture :** tout est dans `R/engine.R`, sans dépendance nouvelle. Aucun tirage aléatoire, aucune grandeur dépendante de la plateforme.
- **Tests :**
  - chaque forme de la décision 3 est couverte sur chaque chemin ;
  - `tous487` contrôle que les deux chemins sont présents quand openxlsx est là ;
  - les assertions propres à openxlsx sont masquées sans lui ;
  - la parité `t="str"` est vérifiée par `identical(interne, openxlsx)` ;
  - je n'ai trouvé aucun test qui passe pour une mauvaise raison : chaque refus est comparé au texte exact.
- **Décompte :** la diff ajoute 10 assertions sans openxlsx et 12 avec, ce qui correspond aux appels `verifier` de la diff.
- **Surface documentaire :** le `.tex` n'est pas touché. La concordance stricte passe ; `coder` doit lister la surface d'impact dans le commit.

### Vérifications exécutées (sous `LC_ALL=C.UTF-8`)

| Commande | Résultat |
|---|---|
| `Rscript tests/unitaires/test_controles_entree.R`, sans openxlsx | 401/401 ok, rc 0 (tête : 391) |
| La même avec `R_LIBS=.../k2b-rejeu/lib` (openxlsx 4.2.9) | 415/415 ok, rc 0 (tête : 403) |
| `Rscript tests/comparer_references.R --seuil 0` | CONFORME, 57 018 feuilles, écart maximal 0, rc 0 |
| `Rscript tests/concordance_doc_moteur.R --strict` | 0 écart, rc 0 |
| `git diff --check` | propre |
| `adv.R` | regex `<rPh>`, formes de référence, `\f` / U+2003, temps |
| `adv2.R` | trois cas de bout en bout sur les deux chemins |

L'avertissement openxlsx « NAs introduced by coercion » apparaît aussi à la tête : il n'est pas nouveau.

### Questions pour `actuary`
Aucune. La diff ne modifie aucun `detail` ni aucune `reference` du registre des tests.

### Questions pour le mainteneur
Pour le constat 3 : étendre le refus aux références écrites avec une entité (décision 3, lettre ou esprit), ou consigner la limite.
