# Avis amont d'`actuary` : K2b, étape 2 (textes et choix de #557, #540, #556, #566, #565)

> *Rédigé par l'agent actuary (IA), fiche de base.* Avis rendu le 13/11/2026 sur la branche `claude/lecteur-xlsx-et-refus-import` (PR brouillon #571, tête `ea3d007`). L'agent est resté en lecture seule : il n'a écrit aucun fichier du dépôt et n'a créé ni commenté aucune issue.

Légende : **[M]** mesuré par l'agent (commande exécutée, sortie lue) ; **[Mc]** mesuré par `coder` au rejeu (`docs/revues/20261113-avis-amont-k2b/coder-rejeu-k2b.md`) ; **[L]** lu (code, issue, ADR, règlement) ; **[H]** hypothèse.

## Lu

- La fiche « Branche K2b » de `docs/feuille-de-route.md` (l. 3663-3727), plan décidé le 13/11 (Q-61-1 à Q-61-3 (a)).
- Le rapport de rejeu de `coder` (en entier).
- Les issues #557, #540, #556, #565 et #566.
- `docs/revues/20261112-lecture-d2e-540/actuary-avis-lecture-b.md` (§ 1 à § 4).
- L'ADR 0005, l. 70 et l'annotation du 13/11/2026.
- `docs/exigences.md`, § 5.
- Dans `R/engine.R` : l. 8453-8471 (`.refus_lecture()`), 8505-8515 (`.xml_textes()`), 8624-8651 (`.xlsx_controler_cellules()`), 8686-8742, 8770-8860 (en-tête et corps d'`engine_lire_xlsx()`), 8312-8325 et 8398-8409 (`engine_ecrire_xlsx()`), 10055-10071 (`mw_valider_triangle()`).
- Dans `app.R` : l. 178-196, 215-300, 1255-1360 et 1935-1990.
- Dans `.github/workflows/ci.yml` : l. 355-385 (l'agrégat `tests-moteur`).
- Dans le `.tex` : l. 1676, 4781, 5041, 7480, 14677 et 17643.

**Vérifications propres à cet avis :**
- **Citation de Merz et Wüthrich [M].** Le PDF officiel de la CAS (`https://www.casact.org/pubs/forum/08fforum/21merz_wuetrich.pdf`) a été téléchargé et passé par `pdftotext -layout`. On y lit : « For simplicity, we assume that I = J (note that all our results can be generalized to the case I > J). » Le pied de page qui suit est « Casualty Actuarial Society E-Forum, Fall 2008 546 ». La page 546 est donc **confirmée**. Titre : « Modelling The Claims Development Result For Solvency Purposes », M. Merz, M. V. Wüthrich.
- **Intitulés de l'annexe XVII [M]** (texte consolidé, balises retirées) : « C. Méthode du risque de réserve n° 1 » et « D. Méthode du risque de réserve n° 2 ».
- **D(2)(e) [M]** : « le nombre d'années d'accident consécutives pour lesquelles des données sont disponibles n'est pas inférieur au nombre d'années de développement consécutives de la première année d'accident… ».
- **Art. 19, paragraphe 1, point b) [M]** : « … aucune donnée pertinente n'est exclue de ce calcul sans justification ».
- **Corps de la PR #564 [M]** (`gh api repos/…/pulls/564`) : « Mesures en rendu réel (Chromium, `page.pdf()` A4 …) », tableau « Méthode / orientation » sur premium, reserve1 et reserve2, et « seul Chromium a été mesuré ».

Aucune question de cet avis ne porte sur une p-value, un test statistique ou σ_USP. Les six cas de référence ne passent ni par les lecteurs ni par un triangle non carré [L, fiche ; Mc]. Le cadre T = 8 n'est donc pas en jeu, sauf comme rappel dans le texte de MW-04.

---

## 1. #557, cellules `t="str"`

**Constat [Mc].** La valeur n'est pas perdue. Les deux chemins la lisent **brute**, à l'identique, et seules les entités (`&amp;`, `&lt;`, `&#233;`) ne sont pas décodées. La fiche (étape 4 : « aujourd'hui perdue ») est inexacte sur ce point. L'issue et le commentaire du code, eux, sont exacts.

**Analyse.**
- **Décoder sur le seul chemin interne** rompt la parité que l'issue exige.
- **Décoder sur les deux chemins** est en pratique impossible sans relire le XML. La sortie d'`openxlsx::read.xlsx()` ne dit pas quelle cellule était `t="str"`, et une entité laissée brute ne peut pas être distinguée d'un texte qui contient littéralement « `&amp;` ». Il faudrait reprendre la position de chaque cellule dans le XML, c'est-à-dire refaire le travail du lecteur interne. L'en-tête (« sortie d'openxlsx non retouchée ») écarte ce choix à juste titre.
- **Effet de la limite.** Une cellule `t="str"` est le résultat d'une formule texte. Un en-tête attendu (`t`, `xt`, `yt`, `i`, `j<k>`) et un nombre ne s'écrivent pas avec une entité. Un en-tête porteur d'entité n'est pas reconnu, ce qui mène à un refus en aval, dans le sens sûr. Le contrôle de la ligne 1 lit lui aussi le texte brut (l. 8710 [L]), ce qui reste cohérent avec les deux chemins. **Aucun fichier aujourd'hui accepté ne change.**
- **Réserve [H].** « Aucun effet sur un calcul » n'a pas été mesuré de bout en bout. Il faudrait un nombre forgé en références numériques (`&#49;`) dans une cellule `t="str"`. Un tableur ne l'écrit pas.

**Recommandation : limite consignée** (tranchée par délégation, aucun fichier changé), avec un test de parité qui fige la lecture brute identique sur les deux chemins (en-tête et corps).

Texte proposé pour le commentaire d'en-tête, à substituer à « Les entites d'une cellule t="str" ne sont decodees par aucun des deux chemins » :

```
# Le texte d'une cellule t="str" (resultat de formule) est lu tel quel, sans
# decodage des entites (&amp;, &lt;, &#233;...), a l'identique par les deux
# chemins (mesure, #557) : limite consignee. Un decodage sur le seul lecteur
# interne romprait la parite, et openxlsx ne dit pas quelle cellule etait
# t="str" (sa sortie n'est pas retouchee). Un en-tete attendu (t, xt, yt, i,
# j<k>) ou un nombre ne s'ecrit pas avec une entite.
```

---

## 2. #557, références de cellule

**Constat [Mc].**
- `r=""` donne une **erreur R brute** sur les deux chemins. Exception : `<c r="" s="1"/>` sans valeur est lu par `openxlsx`.
- `r="1"` et `r="A0"` **déplacent** une valeur sur le lecteur interne (`yt = 1.5` au lieu de `xt`) ou la **perdent** sur `openxlsx`. `r="A0"` ajoute aussi une ligne `NA` côté `openxlsx`.
- `r="1A"` et `r=" A2 "` perdent la valeur côté `openxlsx`, sans message.
- Un segfault d'`openxlsx` a été observé une fois sur ces formes, sans être reproduit.

**Analyse.** Une valeur déplacée ou perdue sans message est le pire mode de défaillance d'un lecteur dans un outil soumis à l'ACPR. L'outil a déjà une doctrine sur ce point : « refus, jamais une position devinée ». Elle couvre la cellule sans `r` et les formes `r='A2'` et `r = "A2"` (en-tête de `.xlsx_controler_cellules()`, l. 8624-8636 [L]). Refuser `r=""` seul laisserait passer, par exemple, `r="1"`, qui déplace une valeur. Étendre le refus applique la même doctrine. Le refus a lieu avant `openxlsx`, ce qui supprime aussi l'exposition au segfault [H].

**Recommandation : refus de toute référence hors `^[A-Za-z]+[1-9][0-9]*$`**, sur toutes les balises `<c>`, cellules vides de style comprises. C'est la règle déjà appliquée à la cellule sans `r`. **Décision du mainteneur**, car des fichiers aujourd'hui acceptés deviennent refusés :
- `r="1"`, `"A0"`, `"1A"` et `" A2 "`, aujourd'hui lus avec une valeur perdue ou déplacée ;
- `<c r="" s=…/>`, aujourd'hui lu par `openxlsx`.

Ce sont des formes forgées, qu'aucun tableur n'écrit [H].

**Précisions pour `coder`.**
1. **Minuscules.** La règle garde les minuscules (`r="a2"`) : ce comportement est inchangé. Les refuser changerait un fichier lu aujourd'hui par le chemin interne. La divergence actuelle (erreur R brute côté `openxlsx`) reste une limite déjà consignée.
2. **Même lecture que le lecteur.** La valeur de `r` doit être lue par la même règle lexicale que `.xlsx_cellules()` : `r="…"` entre guillemets doubles, premier attribut `r` non préfixé. Sinon le contrôle et le lecteur ne verraient pas la même référence (cas `<c x:r="Z9" r="A2">`).
3. **Hors périmètre.** Aucune borne de colonne ni de ligne (XFD, 1 048 576) : non mesuré.
4. **Ordre des contrôles.** Le contrôle s'applique après celui de la cellule sans `r`, dont le texte reste inchangé octet pour octet.

**Texte du refus** (classe `usp_refus_lecture`, texte fixe : la valeur fautive n'est pas citée, comme pour les autres refus). Il vaut aussi si le mainteneur retient `r=""` seul :

```
Classeur illisible : cellule dont la reference de position (attribut r) n'a pas la forme attendue, lettres de colonne puis numero de ligne a partir de 1 (par exemple A2), dans la feuille lue ; l'outil ne deduit pas sa position. Enregistrer de nouveau le classeur depuis un tableur.
```

---

## 3. #557, texte phonétique `<rPh>`

**Constat [Mc].**
- Le lecteur interne concatène le texte phonétique (`xt` suivi de `rPh` « ZZ » donne `xtZZ`), parce que `.xml_textes()` prend tous les `<t>` (l. 8511-8515 [L]).
- Pour une chaîne **partagée**, `openxlsx` l'ignore (`xt`).
- Pour une chaîne **en ligne** avec `rPh`, `openxlsx` perd l'en-tête (`X2`).
- Cas « chaîne partagée enrichie avec `rPh` » : `openxlsx` rend `x`, cause non analysée par `coder`.

**3a. Ignorer `<rPh>` dans `.xml_textes()` : oui.** Le texte phonétique est une annotation de lecture, pas le texte de la cellule. Ce choix rétablit la parité avec `openxlsx` pour les chaînes partagées simples, chemin de référence mesuré. Je ne cite pas la norme ECMA-376, que je n'ai pas relue (non vérifié). La justification est la mesure de parité.

**Effets :**
- Un en-tête attendu passe de refusé à accepté, avec le bon nom.
- Pour une colonne ignorée ou un texte du corps, la **valeur lue change** (`abcZZ` devient `abc`) dans des fichiers aujourd'hui acceptés, sans effet sur un calcul [H, non mesuré de bout en bout].
- Aucun fichier accepté ne devient refusé.

Le changement porte sur des fichiers aujourd'hui acceptés : **décision du mainteneur** (légère), recommandation **oui**.

Point à mesurer par `coder` : la chaîne partagée **enrichie** avec `rPh`. `openxlsx` la rend `x`, le lecteur interne corrigé la rendra `xt` : la parité reste rompue sur ce cas. Proposition : le consigner comme limite propre à `openxlsx`, puisqu'un nom tronqué ne devient pas un nom attendu, et le figer dans un test.

**3b. Chaîne en ligne avec `rPh` : limite consignée** (tranchée par délégation).
- Après 3a, le lecteur interne lit le bon nom. `openxlsx` perd l'en-tête, ce qui mène au refus « colonne(s) manquante(s) » en aval.
- Aucun des deux chemins ne produit une valeur fausse : un chemin lit juste, l'autre refuse.
- Excel n'écrit pas de chaînes en ligne [H].
- Un refus motivé ajouterait un contrôle et changerait des fichiers acceptés (colonnes ignorées) pour un cas sans risque de valeur fausse.
- **Condition** : `coder` mesure le **corps** en ligne avec `rPh` côté `openxlsx`, non mesuré au rejeu. Si `openxlsx` y rendait un texte qui se lit comme un nombre différent de la cellule, je reviendrais au refus.

Texte de commentaire proposé :

```
# Le texte phonetique (<rPh>) d'une chaine n'est pas lu (.xml_textes()), comme
# par openxlsx pour une chaine partagee (mesure, #557). Une chaine en ligne
# qui porte <rPh> est lue entiere ici ; openxlsx 4.2.9 en perd l'en-tete (nom
# de colonne X<col>), qui est alors refuse en aval comme colonne manquante :
# limite consignee, sans valeur fausse sur aucun des deux chemins.
```

Correction du point 4 de l'issue, l. 8778-8779 [Mc] :

```
# une chaine en ligne enrichie (<is><r><t>..) est lue entiere ici ; openxlsx
# 4.2.9 la rend NA dans le corps du tableau et en perd l'en-tete (nom de
# colonne X<col>, mesure, #557) ;
```

---

## 4. #557, blancs d'en-tête sous Windows

**Constat.**
- [Mc] Parité mesurée sous `C.UTF-8` et sous `C` sur sept blancs. Le jeu de blancs dépend de la locale (U+2003).
- [L] Le commentaire de `.xlsx_blancs_entete()` dit déjà « parité mesurée sous C.UTF-8 seulement ».
- Windows n'est pas mesurable en session.

**Recommandation : limite consignée dans K2b**, critère de l'issue (« ou consigné comme limite »). La mesure sur le poste est **facultative**, au passage KR, avec le script `scripts-rejeu/mesure_557d.R` joint à la batterie Windows déjà prévue (#548). Elle ne conditionne pas K2b. Comme KR est sous gel du code, une divergence mesurée serait documentée et versée à D3, après la remise.

**Décision du mainteneur** : faire cette mesure sur son poste ou non. C'est une tâche pour lui.

---

## 5. Recours à `coder-approfondi` pour #557

**Oui, d'office** (`docs/agents/routage.md`, § 10 ; fiche K2b, étape 4). Selon les choix 2 et 3a, des fichiers aujourd'hui acceptés deviennent refusés (références mal formées, `<c r="" s=…/>`) ou changent de valeur lue (`<rPh>` ignoré). Même si le mainteneur ne retient que `r=""` seul et refuse 3a, le cas `<c r="" s=…/>` lu par `openxlsx` suffit à remplir le critère.

Le commit doit porter un **tableau avant / après** des comportements hors références (une ligne par forme de 1.1 à 1.3 du rejeu, sur les deux chemins). Les références restent identiques (`comparer_references.R --seuil 0`).

**Écart de fiche à corriger** : le motif « valeur aujourd'hui perdue (`t="str"`) » ne vaut pas. Le recours tient par les points 2 et 3a.

---

## 6. #540, R-1 et R-2

**R-1** : `if (I > J)` au lieu de `if (I != J)` (l. 10068). MW-03 reste seul pour I < J [Mc : deux motifs aujourd'hui].

**Texte exact proposé pour MW-04** (`sprintf`, mêmes arguments `nrow(tri)`, `ncol(tri)`). Le préfixe et « paragraphes 4 et 5 de la section D de l'annexe XVII » sont gardés, si bien que les tests l. 1612-1617 et 2135-2138 restent vrais :

```
Triangle non carre (%d annees d'accident, %d annees de developpement) : D(2)(e) admet plus d'annees d'accident que d'annees de developpement, mais les formules des paragraphes 4 et 5 de la section D de l'annexe XVII ne se calculent a la lettre que pour un triangle carre, seul traite par l'outil. Se ramener a un triangle carre exclut des donnees et doit etre justifie (art. 19, paragraphe 1, point b)) ; a defaut, la methode du risque de reserve no 1 (section C de l'annexe XVII) reste ouverte. Merz et Wuthrich (2008, p. 546) supposent eux aussi un triangle carre, par simplicite, et annoncent l'extension sans en imprimer la formule.
```

**Pourquoi les quatre propositions dans le motif.**
- L'annotation du 13/11 de l'ADR 0005 impose une qualification « la même dans le motif du moteur, dans la documentation LaTeX et ici » [L]. Retirer la phrase sur Merz et Wüthrich du motif serait un écart à un texte décidé, qui demanderait une décision et une nouvelle annotation. Le coût est d'environ 130 caractères.
- Le texte nomme la section C plutôt que « méthode n° 1 » seul, pour que l'utilisateur sache où aller (intitulé vérifié [M]).
- La notation `D(2)(e)` est celle de MW-03.
- `Wuthrich` est la graphie ASCII du moteur (25 occurrences [M]).

**Variante (b), si le mainteneur juge le motif trop long** : s'arrêter après « … reste ouverte. ». La citation reste dans le `.tex` et l'ADR. C'est un écart à l'annotation de l'ADR 0005, donc une **décision du mainteneur** et une annotation par `architect`. Je ne la recommande pas.

`regulatory` (`medium`) contrôle le texte en aval, comme prévu à l'étape 5.

**`.tex` (par `docwriter`, règle 9) :**

| Ligne | Passage | Avis |
|---|---|---|
| 14677 | encadré : « Le cas I > J produirait un trapèze dont le texte ne précise pas le traitement … convention implicite non prévue par le règlement » | **à remplacer** par les quatre propositions (texte de l'annotation de l'ADR), avec renvoi bibliographique à Merz et Wüthrich (2008), déjà dans `sec:biblio`, p. 546 ; l'explication des termes indéfinis qui précède est gardée |
| 4781 | tableau, « Géométrie carrée », « Restriction d'implémentation » | **à compléter** : garder l'explication des termes indéfinis ; ajouter que le domaine de l'outil est plus étroit que D(2)(e), que le refus n'est émis que si I > J, et renvoyer à l'encadré |
| 5041 | « un triangle non carré ou incomplet ne permet pas d'appliquer les formules » | **à retoucher a minima** : « ne permet pas d'appliquer **à la lettre** les formules » ; un I < J est refusé par D(2)(e), non par les formules |
| 17643 | fiche `mw:m6sig`, « sous la contrainte I = J imposée par `mw_valider_triangle()` » | **exact tel quel** (énoncé conditionnel) ; ajouter au plus un renvoi `\ref` vers l'encadré. Le plan cite cette fiche, mais aucune qualification n'y est fausse |
| 1676, 7480 | « seul admis », « le triangle étant carré » | **aucune retouche** : constats exacts du domaine de l'implémentation |

**ADR 0005** : déjà annoté, rien à ajouter, sauf si la variante (b) est retenue.

`docs/specifications/fm-merz-wuthrich-restitution.md`, l. 304 (ancien libellé) : spécification historique, à laisser. Hors périmètre.

**Tests** (`tests/unitaires/test_controles_entree.R`) :
- l. 1664-1668 : texte complet à remplacer par le nouveau ;
- l. 1618-1622 (5 × 6, I < J) : ajouter l'**absence** de « non carre » et exactement un motif, MW-03. Le 5 × 6 respecte D(2)(b) et D(2)(c) (cinq lignes, cinq colonnes au moins) [L] ;
- l. 1612-1617 et 2135-2138 : inchangés (préfixe et « paragraphes 4 et 5 » conservés) ;
- ajouter un cas I < J par `run_engine()` ou `engine_lire_triangle()`.

Aucun `.rds` touché [Mc]. `concordance_doc_moteur.R --strict` à faire tourner par `coder`.

---

## 7. #556, restitution des refus d'import et échec d'export

**Constat [Mc].** Il y a quatre formes : illisible ; refus du lecteur ; validation du moteur, sans nom de fichier ; dimension. Seule la dernière dit que les données sont conservées. Les données sont pourtant conservées dans les neuf cas mesurés, séries **et** triangle. Il y a aussi deux notifications différentes.

**Texte unique du statut** (une seule aide de mise en forme dans `app.R` pour les quatre branches, l. 1266-1327 ; textes en ASCII sans accents, comme l'usage d'`app.R`) :

```
sprintf("Import du fichier %s (%s) refuse ; donnees courantes conservees. Motif : %s",
        fi$name, toupper(ext), paste(motifs, collapse = " "))
```

`motifs` vaut, selon le cas :
- `lu$erreur` : `MESSAGE_ILLISIBLE` inchangé, qui commence par « illisible comme … » ;
- le texte de `usp_refus_lecture` ;
- `v$erreurs` ou `r$erreurs` ;
- `rd`.

**Justifications.**
- Le nom de fichier figure **toujours**, y compris pour la forme C.
- « Donnees courantes conservees » est **générique**, sans « series » ni « triangle » : la mesure établit que les deux sont conservés quelle que soit la méthode. C'est le sens de `exigences.md` § 5.2 (« sans jamais modifier silencieusement les données »).
- L'état vient d'abord, le motif ensuite.
- `MESSAGE_ILLISIBLE` n'est pas modifié : il sert aussi au démarrage.

**Notification unique**, qui remplace « Import refuse. » et « Import refuse : fichier illisible. » :

```
Import refuse ; donnees courantes conservees : voir le statut d'import.
```

Elle garde `type = "error"`, `duration = 8`, sur le modèle de « … : voir le statut d'import. » déjà employé l. 1307 et 1349.

**Forme « démarrage »** (`charger_ln()`, `charger_mw()`) : **inchangée, hors de #556**. Ce n'est pas un import. Aucune donnée courante n'est conservée : une grille vide est chargée, et `REFUS_DEMARRAGE` le dit. Lui appliquer la mention « conservées » serait faux.

Les non-refus « Donnees importees, mais non valides » et « Triangle importe, avec des avertissements » ne changent pas.

**Échec d'export.**
- **Comportement** : chaque `content` des cinq `downloadHandler` est entouré d'un `tryCatch`. Il notifie, journalise (`journaliser()`), puis **relève l'erreur**, pour que le navigateur ne reçoive pas un fichier vide présenté comme valide.
- **Limite connue** : le navigateur enregistre la page d'erreur (`dl_donnees_xlsx.html`, [Mc]), à consigner.
- **[H] à mesurer en rendu réel par `app-review`** : qu'une notification émise pendant la requête de téléchargement atteigne bien le client, sous `shiny` 1.8.0 (CI) comme 1.14.0.

**Cause reprise.**
- Les deux erreurs d'`engine_ecrire_xlsx()` (l. 8322 et 8404) sont des textes destinés à l'utilisateur. Je recommande de leur donner une **classe `usp_refus_ecriture`**, sur le modèle de `usp_refus_lecture`, textes inchangés octet pour octet : l'application montre leur texte sans le recopier.
- Toute autre erreur reçoit un texte fixe, cause R au journal. C'est la politique de #94 : aucune erreur R brute à l'écran, critère de l'étape 6. Les erreurs de `write.csv` sont dans la langue du système, et celles de `rapport_html()` sont des erreurs de programmation.
- Conséquence : `R/engine.R` est touché, d'où l'**`audit` léger** prévu par la fiche, sans résultat changé.

Textes :

```
Export impossible : %s          # %s = conditionMessage() d'une erreur usp_refus_ecriture
Export impossible : erreur lors de l'ecriture du fichier (detail consigne au journal de l'application).
```

`type = "error"`, `duration = 10`.

Tranché par délégation : la fiche confie les textes à `actuary` et prévoit l'`audit` léger si le moteur est touché.

---

## 8. #566, impression des graphiques

**« Trois méthodes »** : ce sont **trois méthodes de calcul** (premium, reserve1, reserve2) et **une** méthode d'impression, Chromium `page.pdf()` A4 (vérifié [M] dans le corps de la PR #564 : « seul Chromium a été mesuré »).

**Critères d'acceptation corrigés**, à poser par la session en commentaire de #566. C'est une clarification, sans changement de périmètre : le paysage figure déjà dans le critère.
1. Pour chacune des trois méthodes de calcul, avec `B = 99` et après « Relancer les calculs », imprimer en A4 **portrait et paysage**, par Chromium `page.pdf()` (même appel que R44), les six sous-onglets de « Graphiques » et l'onglet « Calibration » : 42 PDF.
2. Aucun graphique rogné : dernière graduation de chaque axe visible, aucun tracé coupé au bord droit de la zone utile. Contrôle visuel des PDF, qui **font foi**. La mesure DOM sous `emulateMedia('print')` (bord droit du `<svg>` inférieur ou égal à la largeur utile) est indicative seulement.
3. Écran inchangé à 960 et 1 600 px : largeurs des conteneurs plotly identiques au relevé **avant** correction, **pour les trois méthodes**. Le relevé de référence n'existe que pour premium [Mc] : `coder` relève reserve1 et reserve2 avant de modifier.
4. Limites consignées : Firefox et WebKit, boîte de dialogue d'impression du navigateur.

**Versions.**
- Acceptation sous **`shiny` 1.8.0 et `plotly` 4.10.4**, versions figées de la CI, à installer depuis l'archive CRAN comme `openxlsx` 4.2.5.2 au rejeu. Le dimensionnement des widgets dépend de la version de plotly.js [H].
- Contrôle complémentaire sous 1.14.0 et 4.12.1.
- Si l'installation des versions de la CI échoue, le dire et consigner la limite.
- Les versions du poste du mainteneur sont inconnues : une impression de contrôle sur le poste à KR, facultative, est à signaler au mainteneur.

---

## 9. #565, job de CI

**Versions.** **Même instantané que `shiny` et `plotly`** (`DATE_INSTANTANE = 2024-02-15`), soit vraisemblablement `openxlsx` 4.2.5.2 et `zip` 2.3.1 [H : contenu de l'instantané Posit non vérifié, 403]. C'est conforme au plan (« aux versions de l'instantané ») et à l'issue.
- L'hypothèse se lève d'elle-même : le contrôle des versions est bloquant. `coder` fixe `VERSION_OPENXLSX` et `VERSION_ZIP` d'après le journal de la première exécution, sans supposer.
- Les tests de parité passent sous 4.2.5.2 et 2.3.1 (403 sur 403, 97 sur 97) comme sous 4.2.9 [Mc], et les sorties des cas de #557 sont identiques aux deux versions [Mc].
- Les commentaires du code qui citent « mesure, openxlsx 4.2.9 » restent vrais : ce sont des relevés de mesure.
- Le `.tex` (passage de `docwriter`) dira : « mesuré en session sous 4.2.9, vérifié en CI sous \<version du journal\> ».
- Écarté : un second instantané pour 4.2.9. Il ajouterait une date et des dépendances plus récentes sous R 4.3.1, sans gain mesuré.

**Fichiers exécutés**, un par un, `Rscript tests/unitaires/<fichier>.R` sous `LC_ALL=C.UTF-8` (mode mesuré possible, lanceur inchangé) :
- `test_controles_entree.R`, `test_outdec.R` : obligatoires (les sept lignes `[saute]`) ;
- `test_defauts_connus.R` : voie « paquet » exercée ;
- `test_application.R`, si la bibliothèque `shiny` et `plotly` mise en cache peut être réutilisée (même clé) : c'est le chemin `zip::zipr()` de l'export de l'application, celui qu'emprunte un poste muni d'`openxlsx` ; sinon, limite consignée.

**Critères renforcés.**
- **Aucune** ligne `[saute]` dans le job, quel que soit le paquet.
- Contrôle bloquant de `packageVersion("openxlsx")` et `packageVersion("zip")` dans un processus R neuf.
- Les lots restent sans ces deux paquets.
- `references.yml` inchangé.

**Agrégat `tests-moteur`.** Je recommande de **brancher** le job :
- conditions de déclenchement identiques à celles des lots (`changements`, `moteur == 'true'`) ;
- statut attendu `success` ou `skipped`, comme `UNITAIRES` (l. 376-383) ;
- ainsi, sans toucher aux règles de protection, la parité devient bloquante à la fusion.

C'est un changement de ce qui bloque la fusion : **à confirmer par le mainteneur**. À défaut, le job est informatif et la réserve d'`actuary` (C3 de K3b) n'est levée qu'à moitié.

---

## Écarts avec le plan décidé et la fiche

1. **Étape 4.** « `t="str"` perdue » est inexact. Le recours à `coder-approfondi` tient par les points 2 et 3a.
2. **Étape 4.** Refus étendu aux références mal formées, au-delà de `r=""` : décision du mainteneur.
3. **Étape 5 et règle 9.** « Trois passages » du `.tex` : 14677 et 4781 sont à reprendre, 5041 a minima ; 17643 est exact (renvoi au plus) ; 1676 et 7480 restent inchangés.
4. **Étape 6.** Classe `usp_refus_ecriture` dans le moteur, d'où `audit` léger. C'est prévu par la fiche, sous condition.
5. **Étape 3.** Branchement du job à l'agrégat, non prévu par la fiche.
6. **Étape 7.** Critère « trois méthodes » clarifié ; référence d'écran à relever pour reserve1 et reserve2.

---

## Retour

- **Statut** : `revue requise`. Les textes sont fixés. Questions au mainteneur :
  - **Q-A (point 2)** : refus de toute référence de cellule hors `^[A-Za-z]+[1-9][0-9]*$`, recommandé, ou de `r=""` seul. Des fichiers forgés aujourd'hui acceptés, avec une valeur perdue ou déplacée, deviennent refusés.
  - **Q-B (point 3a)** : ignorer `<rPh>`, recommandé. La valeur lue change dans des fichiers acceptés (colonnes ignorées, textes du corps) ; aucun fichier accepté ne devient refusé.
  - **Q-C (point 4)** : mesure facultative des blancs d'en-tête sur le poste Windows à KR, ou limite seule.
  - **Q-D (point 9)** : branchement du job de parité à l'agrégat bloquant `tests-moteur`, recommandé.
  - **Q-E (point 6)**, seulement si le mainteneur juge le motif MW-04 trop long : variante (b), écart à l'annotation de l'ADR 0005.
- **Tranché par délégation** : `t="str"` en limite ; chaîne en ligne avec `rPh` en limite, sous la condition de mesure du corps ; texte du refus de référence ; texte de MW-04 à quatre propositions ; répartition dans le `.tex` ; textes de #556 (statut, notification, forme « démarrage » hors périmètre, textes d'export) ; critères de #566 ; versions et fichiers du job de #565 ; `coder-approfondi` d'office pour #557.
- **Preuves.**
  - *Vérifié* : citation et page de Merz et Wüthrich, p. 546 [M] ; intitulés des sections C et D de l'annexe XVII, D(2)(e), art. 19, paragraphe 1, point b) [M, texte consolidé] ; corps de la PR #564 [M] ; code et tests aux lignes citées [L] ; annotation de l'ADR 0005 [L] ; mesures du rejeu [Mc].
  - *Hypothèses* : contenu de l'instantané Posit du 15/02/2024 ; aucune forme forgée écrite par un tableur ; aucun effet bout en bout sur un calcul des points de #557 ; notification atteignant le client depuis un `downloadHandler` ; dépendance du rendu d'impression à la version de plotly.js.
  - *Non vérifié* : norme ECMA-376 pour `rPh` (non citée) ; corps en ligne avec `rPh` côté `openxlsx` ; chaîne partagée enrichie avec `rPh` (cause côté `openxlsx`) ; Windows.
- **Informations manquantes** : instantané Posit inaccessible (403) ; versions du poste du mainteneur.
- **Décisions non résolues** : Q-A à Q-E, par le mainteneur ; texte de MW-04, par `regulatory` (`medium`) en aval.
- **Critères déclenchés** (§ 4) : **résultat changé hors références** (Q-A, Q-B ; `coder-approfondi` d'office) ; lecture de l'ADR 0005 (« la même ») qui fonde le choix du motif à quatre propositions, sans désaccord avec l'ADR ; aucun désaccord avec `audit`, `regulatory` ou un autre expert ; aucun σ_USP, aucune p-value ni aucun verdict touché ; aucune question de validité à T = 8.
- **Prochaine action recommandée** : la session porte Q-A à Q-D (et Q-E au besoin) au mainteneur, verse cet avis dans `docs/revues/20261113-avis-amont-k2b/`, consulte `regulatory` (`medium`) sur le texte de MW-04, commente #566 avec les critères corrigés, puis lance l'étape 3 (#565).

Fichiers pertinents :
- `/home/user/outil_usp/docs/feuille-de-route.md`
- `/home/user/outil_usp/docs/revues/20261113-avis-amont-k2b/coder-rejeu-k2b.md`
- `/home/user/outil_usp/docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md`
- `/home/user/outil_usp/R/engine.R`
- `/home/user/outil_usp/app.R`
- `/home/user/outil_usp/.github/workflows/ci.yml`
- `/home/user/outil_usp/tests/unitaires/test_controles_entree.R`
- `/home/user/outil_usp/docs/latex/doc_tests_usp.tex`
- Texte du PDF de Merz et Wüthrich extrait pour vérification : `<scratchpad>/mw/mw.txt`
