# `/code-review` de K2b et correctif `<x:rPh>` (étape 10, règle 10)

> Versé par la session principale (condensé fidèle). 14/11/2026.

## `/code-review` (niveau medium, `main...HEAD` à `4740dde`) : dix constats

| # | Fichier:ligne | Constat | Suite |
|---|---|---|---|
| 1 | `R/engine.R:8555` | `.xml_textes()` ne retire que les `<rPh>` non préfixés ; X1 retire les blocs préfixés avant de compter : `<si><t>11</t><x:rPh sb="0" eb="1"><t>7</t></x:rPh></si>` lu 117 par la voie de repli, sans message | vérifié par la session (présent dès `30bed39`, donc antérieur à la reprise) ; mainteneur : correction dans K2b → `36d4a07` |
| 2 | `R/engine.R:8720` | référence de cellule sans borne (`XFD1048576`, `A99999999999`) : erreur R brute (allocation de 128 Go, débordement d'entier), message générique | aucune valeur fausse ; issue rédigée |
| 3 | `R/engine.R:8719` | références en minuscules (`r="b2"`) : parité avec openxlsx non mesurée | déjà consigné dans le `.tex` (erreur R chez openxlsx 4.2.9, mesuré) ; sans suite |
| 4 | `R/engine.R:8993` | exemption Q-F par un `<rPr>` n'importe où dans la table | conforme à la décision 7 et au commentaire mesuré (4.2.9) ; la CI couvre 4.2.5.2 ; pour mémoire dans l'issue |
| 5 | `R/engine.R:8716` | contrôle `[ \t\r\n]r="` presque redondant avec le contrôle d'attribut | simplification ; sans suite dans K2b |
| 6 | `R/engine.R:9018` | motif de préfixe répété en littéral | factorisé dans `XML_PREFIXE_NOM` par `36d4a07` |
| 7 | `R/engine.R:8554` | six passes d'expressions régulières par chaîne | performance ; mesurée sans régression sur des tables ordinaires (audit) |
| 8 | `app.R:258` | champ `refus_moteur` lu par les tests seulement | documenté ; sans suite |
| 9 | `app.R:541` | script d'impression inactif si le widget est *responsive* (largeur en %) | l'application fixe les tailles en px (mesuré par app-review) ; pour mémoire |
| 10 | `docs/latex/doc_tests_usp.tex` | PDF non commité | commit de fin de branche prévu (`compiler-doc`) |

## Correctif `36d4a07` (`coder-approfondi`, d'office)

`.xml_textes()` retire aussi `<x:rPh .../>` et les blocs `<x:rPh>…</x:rPh>` (PCRE `(?s)`, préfixe lu comme au comptage X1) ; constante `XML_PREFIXE_NOM` partagée avec Q-F et X1 (motifs identiques, vérifié par `identical()`). Tests : 443/443 avec openxlsx 4.2.9, 427/427 sans ; unitaires 4023/4023 avec ; références identiques au bit (6 cas) ; les deux assertions nouvelles échouent contre `4740dde`.

| Forme | Chemin | Avant (`4740dde`) | Après |
|---|---|---|---|
| `<t>11</t><x:rPh ...><t>7</t></x:rPh>` | interne / openxlsx | **117**, ok, sans message / 11 | 11 / 11 |
| `<t>1</t><x:rPh .../><x:rPh ...><t>7</t></x:rPh>` | interne / openxlsx | 17 / 1 | 1 / 1 |
| deux blocs `<x:rPh>` (7 puis 8) | interne / openxlsx | 1178 / 11 | 11 / 11 |
| `<r><rPr/>1</r><r>1.5</r><x:rPh ...><t>7</t></x:rPh>` | interne / openxlsx | 11.57 / **11.57**, ok, sans message | 11.5 / **11.57**, ok, sans message |
| chaîne en ligne `<is><t>11</t><x:rPh>..7..</x:rPh>` | interne / openxlsx | 117 / NA, refus en aval | 11 / NA, refus en aval |

**Limite antérieure, inchangée côté openxlsx** (ligne en gras ci-dessus) : décision du mainteneur du 14/11/2026, consignée dans le `.tex` (`81e95ef`) et portée dans une issue, sans refus dans K2b.

## Audit léger de `36d4a07` : conforme avec réserves

Constat d'origine résolu ; Q-F et X1 inchangés ; `>` dans un attribut, multiligne, non glouton, `<x:rPhX>` gardé : justes ; aucune régression sans préfixe. Mineur : coût quadratique sur une chaîne forgée de milliers de `<x:rPh …>` non fermés (2 000 : 1,45 s ; 8 000 : 21,6 s ; 20 000 : 144 s), déjà payé par X1 pour la table ; exposition nouvelle pour les chaînes en ligne. 100 000 `<si>` ordinaires : 8,85 s (9,06 s avant). Pas de reprise recommandée ; porté dans l'issue.

## Revue d'`actuary` sur `4740dde` : conforme avec réserves

C1 (`<x:t>` directs relèvent de X1) et C2 (« donne une valeur fausse (mesuré) ») appliqués mot pour mot en `81e95ef` ; C3 (motif « finit par sharedStrings.xml » d'openxlsx, point non échappé) facultatif, sans suite.
