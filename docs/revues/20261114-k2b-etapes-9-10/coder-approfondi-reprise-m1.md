# Reprise de `coder-approfondi` après la revue finale d'audit (M-1, m-1, m-2, m-3)

> Versée par la session principale (condensé fidèle). `coder-approfondi`, d'office (§ 10). 14/11/2026. Base `30bed39` ; commits `c848562` (`moteur:`), `585a40d` (`tests:`), `20f7d50` (`repo:`). Sondes et journaux : `scratchpad/coder/` de la session (non versés).

## Modifications

- **`R/engine.R`, `engine_lire_xlsx()`.**
  - Refus M-1 après `.xlsx_chemin_sort(noms)`, avant `utils::unzip(exdir)` : `ss <- grepl("sharedStrings.xml$", noms); if (sum(ss) > 1L || any(noms[ss] != "xl/sharedStrings.xml")) .refus_lecture(<texte d'actuary>)`. Même motif qu'openxlsx (code de `openxlsx:::read.xlsx.default` lu). `noms` vient de `utils::unzip(chemin, list = TRUE)$Name` ; une entrée `xl\sharedStrings.xml` (forgée avec python `zipfile`) est refusée sur les deux chemins ; un nom commençant par `/` ou `\` est déjà refusé par `.xlsx_chemin_sort()`.
  - m-1 : les `<t>` sont comptés préfixés ou non (`<([A-Za-z_][A-Za-z0-9_.-]*:)?t` + `XML_ATTRIBUTS_BALISE` + `/?>`) après retrait, préfixés ou non, des `<rPh .../>`, `<r/>` et des blocs `<rPh>…</rPh>`, `<r>…</r>` ; retrait en PCRE avec `(?s)`.
  - Défaut de la première version, corrigé avant remise : sous TRE, `.*?` suivi d'un groupe facultatif dans la balise fermante devient glouton (`<si><r><t>a</t></r><t>1</t><t>1.5</t><r><t>c</t></r></si>` rendu `"<si></si>"`, X1 contourné) ; cas ajouté au test.
  - Commentaires d'en-tête complétés (nouveau refus, X1 préfixé, limite `<x:si>` mesurée). Huit appels à `.refus_lecture(` (sept avant).
- **`tests/unitaires/test_controles_entree.R`** : `classeur487()` reçoit `fichiers_partages` et `cible_partage` ; sept vérifications nouvelles, sur les deux chemins (table hors `xl/`, deux tables, classe ; `<x:t>` comptés et non-régression du retrait non glouton ; témoins `<x:r><t>` et `<x:tab/>` lus 11,5 ; limite `<x:r><x:t>`) ; libellé m-3.
- **`.github/workflows/ci.yml`** (m-2) : versions confirmées par l'exécution 43519555424 (job 132210369471 : openxlsx 4.2.5.2, zip 2.3.1) ; comptes d'assertions retirés.

Écarts au brief : témoin `<x:r><x:t>` lu 11,5 impossible (aucun chemin ne lit le texte d'un `<x:t>`, sous 4.2.9 comme 4.2.5.2) : remplacé par un témoin `<x:r><t>` et un test de limite. Extraction de `<si>` préfixé non appliquée (insuffisante, voir limites).

## Vérifications (`LC_ALL=C.UTF-8`, R 4.3.3)

| Contrôle | Résultat |
|---|---|
| `test_controles_entree.R`, openxlsx 4.2.9 | 441/441, 0 saut |
| idem, openxlsx 4.2.5.2 + zip 2.3.1 | 441/441, 0 saut |
| idem, sans openxlsx | 425/425, 6 sauts attendus |
| nouveaux tests contre le moteur de `30bed39` | 5 échecs (M-1 ×3, X1 préfixé, témoin `<x:r><t>`) : tests efficaces |
| `test_unitaires.R --parallele` sans / avec openxlsx | 3817/3817 (7 sauts attendus) ; 4021/4021 (0 saut) |
| `comparer_references.R --seuil 0` | 6 cas, 0 écart |
| `test_reproductibilite.R` | OK, 6 cas |
| `concordance_doc_moteur.R --strict` | 0 écart |

## Tableau avant / après (openxlsx 4.2.9 ; « après » identique sous 4.2.5.2 ; valeur visée xt = 11,5 en B3)

| Forme | Chemin | Avant | Après |
|---|---|---|---|
| Table en `xl/strings/sharedStrings.xml`, « 1 »+« 1.5 » en `<r>` sans `<rPr>` | interne | refus en aval | refus M-1 |
| idem | openxlsx | **ok, xt lu 1** | refus M-1 |
| Deux tables (`xl/` + `a/`) | interne | ok, 11,5 | refus M-1 |
| idem | openxlsx | erreur R brute | refus M-1 |
| Entrée `xl\sharedStrings.xml` | les deux | non mesuré | refus M-1 |
| `<si><t>1</t><x:t>1.5</x:t></si>` | les deux | **ok, xt lu 1** | refus X1 |
| `<si><x:t>1</x:t><x:t>1.5</x:t></si>` | les deux | refus en aval | refus X1 |
| `<si><x:r><x:rPr/><t>1</t></x:r><x:r><t>1.5</t></x:r></si>` (+ `<rPr>`) | les deux | refus X1 à tort | **ok, 11,5** |
| idem avec `<x:rPh><t>Z</t></x:rPh>` | les deux | refus X1 | refus en aval (« 1Z1.5 ») |
| `<x:r>` contenant `<x:t>` (+ `<rPr>`) | les deux | refus en aval | inchangé |
| `<t>11.5</t><x:tab/>` | les deux | ok, 11,5 | inchangé |
| `<x:si><x:t>1</x:t><x:t>1.5</x:t></x:si>` | interne / openxlsx | refus en aval / erreur R | inchangé |
| `xl/sharedStrings.xml` simple (témoin) | les deux | ok, 11,5 | inchangé |

## Limites et questions remontées

1. **`<x:si>` préfixé mêlé à des `<si>`** : `<x:si><x:t>9</x:t></x:si><si><t>11.5</t></si>`, cellule d'indice 0 lue 11,5 par les deux chemins, ok = TRUE. Extraire `<si>` préfixé dans le seul lecteur interne ne corrigerait pas openxlsx ; il faudrait un nouveau refus. Non appliqué ; limite consignée dans l'en-tête de la fonction.
2. **Segfault d'openxlsx 4.2.9** (préexistant) : indice de chaîne partagée hors bornes (`<c t="s"><v>5</v>` avec une seule `<si>`) → « caught segfault », processus R tué. Lecteur interne : NA, refus en aval. Correctif possible : refuser avant openxlsx tout indice `t="s"` ≥ nombre de `<si>`.
3. Commentaire de `lire_tableau()` (`app.R`) : « forme non lisible » ne nomme pas l'emplacement ; non modifié.
4. `./xl/sharedStrings.xml` ou `xl\sharedStrings.xml` refusés (prudence ; aucun tableur vu les écrire, non vérifié).
