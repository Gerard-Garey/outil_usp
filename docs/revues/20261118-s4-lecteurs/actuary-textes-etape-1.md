# Avis d'actuary : textes de l'étape 1 de S4 (#595, #568, #569)

> *Rédigé par l'agent `actuary` (IA, fiche de base, routine), 18/11/2026, branche `claude/lecteurs-messages-et-qualite` (tête `0995ace`). Rapport versé tel que rendu par la session principale (agent sans écriture).*

Trois textes de motifs, sans accents, dans la forme des motifs des lecteurs (constat, cause, action). La portée de #569 est vérifiée dans le code et dans l'avis C1 de K3b. Aucune écriture dans le dépôt.

## Point bloquant à transmettre à l'étape 3 (#595 (b))

La fiche S4 (étapes 1 et 3) dit « balise `<Relationship` suivie d'un caractère autre qu'une espace, `/` ou `>` ». Or la racine `<Relationships` est elle-même `<Relationship` suivie de `s`. La piste de l'issue #595 exclut bien `s` (« autre qu'une espace, `/`, `>` ou `s` »), mais la fiche l'a perdu. La règle doit viser l'élément `<Relationship>` lui-même, pas le texte `<Relationship`. Sinon tous les classeurs seraient refusés, et le critère « classeurs de l'écrivain interne toujours admis » échouerait.

## (i) #595 : deux refus d'admission (même texte sur les deux chemins)

**(a) Relation retenue à cible ambiguë.** On réemploie `TEXTE_REFUS_RELATIONS` (`R/engine.R` l. 9431), avec `partie = "xl/_rels/workbook.xml.rels"`. Deux formes de position, au modèle de `.xlsx_controler_relations()` (« balise <Relationship> %d : attribut Id absent, repete ou prefixe (%s) ») et du contrôle 3 de `.xlsx_controler_designation()` :

```r
# a1 : attributs de nom local Target qui ne se reduisent pas a un seul, ecrit Target
sprintf("balise <Relationship> %d, relation de la feuille lue : attribut Target repete ou prefixe (%s)",
        lien, cite(noms_target))
# lien : rang de la relation retenue parmi les balises <Relationship> ;
# cite() : celle de .xlsx_controler_relations(), noms d'attribut par .xlsx_citer(),
# joints par ", " (ex. "x:Target, Target")

# a2 : texte Target= ailleurs que dans le nom de l'attribut Target
sprintf("balise <Relationship> %d, relation de la feuille lue : texte Target= dans la valeur de l'attribut %s",
        lien, .liste_positions(.xlsx_citer(noms_attr)))
# noms_attr : noms des attributs dont la valeur porte le texte (ex. "Foo" ; "Target"
# si Target='a Target="b.xml"')
```

Rendu, par exemple : `Classeur illisible : la partie xl/_rels/workbook.xml.rels du classeur designe la feuille lue de facon ambigue (balise <Relationship> 1, relation de la feuille lue : attribut Target repete ou prefixe (x:Target, Target)) ; l'outil ne lit pas cette forme de facon sure (une autre feuille pourrait etre lue). Enregistrer de nouveau le classeur depuis un tableur.`

*Justification.* C'est exactement le constat du texte existant : une autre feuille est lue (999 au lieu de 104,2, σ_USP faux avec `ok = TRUE`, mesure de l'issue). Garder ce texte maintient un seul libellé pour toute la famille D-S1-37. « Absent » n'est pas dans a1 : une relation de feuille sans `Target` relève déjà de « aucune feuille trouvee ». Pour a2, chercher le texte dans le texte collé, comme `occurrences()` et `texte_colle()`, car `openxlsx` cherche `Target="` après collage des lignes (issue #595). Le nom d'attribut cité est celui où commence l'occurrence, reportée dans la partie.

**(b) Balise `<Relationship>` de forme non reconnue.** Constante dédiée : `TEXTE_REFUS_RELATIONS` serait faux ici, car la balise en cause n'est pas forcément celle de la feuille lue, et le risque est un blocage, pas une autre feuille.

```r
TEXTE_REFUS_BALISE_RELATION <- "Classeur illisible : la partie xl/_rels/workbook.xml.rels du classeur porte une balise <Relationship> de forme non reconnue (%s : caractere autre qu'une espace, \"/\" ou \">\" apres le nom de la balise, par exemple une tabulation ou une fin de ligne) ; l'outil ne lit pas cette forme de facon sure (la lecture pourrait ne jamais se terminer et figer l'application). Enregistrer de nouveau le classeur depuis un tableur."
# %s : sprintf("balise(s) <Relationship> %s", .liste_positions(k)), k = rangs parmi les balises <Relationship>
```

*Justification.* Modèle direct : le refus l. 9805 et l. 10219 (« balise de cellule de forme non reconnue (blanc autre qu'une espace apres "<c") ») ; parenthèse de risque d'après la l. 10659 (« la lecture pourrait arreter l'application »). Le blocage est établi par l'issue (`timeout`, code 124 sous `openxlsx` 4.2.5.2). Le même texte vaut sur la voie de repli, qui lirait ce classeur : c'est voulu, pour la parité exigée par la fiche. Tester le texte brut et le texte collé (une balise peut être reconstituée par le collage, `<Relation\nship`), racine `<Relationships` exclue.

## (ii) #568 : un texte commun aux deux configurations

```r
sprintf(paste("En-tetes de colonnes en chiffres romains (colonnes %s, d'en-tetes %s) : l'en-tete I",
              "designe la colonne i, facultative, qui porte l'annee d'accident de chaque ligne (en-tete",
              "i ou I, blancs de bord ignores), et ne peut titrer une colonne d'annee de developpement ;",
              "renommer les colonnes d'annee de developpement, par exemple j0, j1, j2, ... (format",
              "d'export de l'application)."),
        .liste_positions(k), .liste_positions(.echapper_texte(names(df)[k])))
# k : positions (colonnes du tableau, comme ki du motif H1) de la suite reconnue I, II, III, ...
```

*Justification.* Même cause dans les deux configurations (l'en-tête I est réservé à i par la règle N, `.entete_designe()`) et même action (renommer les colonnes de développement). Dans la configuration « i suivie de I, II, … », la colonne i n'est pas en cause, donc pas citée. « facultative, qui porte l'annee d'accident de chaque ligne » et « en-tete i ou I, blancs de bord ignores » reprennent le motif H1 (l. 8628-8631) ; `j0, j1, …` est l'en-tête d'export de l'application (`app.R` l. 2329 ; `tests/donnees/triangle_mw.csv`), cohérent avec la numérotation j depuis 0 des motifs du triangle (l. 8668).

## (iii) #569 : information dans `avertissements_lecture` d'`engine_lire_donnees_csv()`

```r
sprintf(paste("Lignes du tableau rangees par annee t croissante pour le calcul (ligne(s) de donnees %s",
              "deplacee(s)) : l'outil suit l'ordre de la colonne t, non celui des lignes du fichier ; cet",
              "ordre determine notamment les p-values et verdicts des tests sensibles a l'ordre des annees",
              "et, si la profondeur T retenue est inferieure au nombre de lignes, les annees retenues (les",
              "T plus recentes selon t). Verifier que la colonne t porte l'annee de chaque ligne ; aucune",
              "action n'est requise si c'est le cas."),
        .liste_positions(which(o != seq_along(o))))
# o <- order(to) (l. 8563)
```

Condition d'émission : `any(o != seq_along(o))`, exactement « si et seulement si l'ordre du fichier diffère de celui de t ». Une permutation et son inverse ont les mêmes points fixes : l'ensemble cité ne dépend pas du sens de lecture.

*Sources.* Années retenues : la troncature garde les T dernières positions après le tri (`idx <- (n - T + 1):n`, l. 11548 ; l. 1661 dans `usp_lire_donnees()`). Tests d'ordre : avis C1 (`docs/revues/20261112-fin-de-branche-k3b/actuary-avis-c1-entete-T.md` l. 22, 36-38), mesure : les tests sensibles à l'ordre changent jusqu'au verdict, σ_USP inchangé quand toutes les années sont retenues. « Notamment » : l'inventaire de tout ce qui dépend de l'ordre (graphiques…) n'est pas fait, la liste n'est pas fermée. Le texte ne dit pas que σ_USP change. « Ligne(s) de donnees » et « tableau » valent sur CSV et classeur ; lignes vides refusées en amont ; « profondeur T retenue » est le libellé de l'application (`app.R` l. 135). Sans colonne t : pas de tri, pas d'information.

## Retour

- **Statut** : complet.
- **Preuves** : *vérifié* par lecture de `R/engine.R` (l. 8198, 8210, 8231-8274, 8436-8566, 8584-8680, 9431, 9460-9500, 9540-9615, 9640-9690, 9805, 10659, 1661, 11548), `app.R` l. 135 et 2329, `tests/donnees/triangle_mw.csv`, avis C1 de K3b, issues #595, #568, #569, fiche S4, Q-66-5 et Q-66-6 ; *hypothèse* : liste non exhaustive de ce qui dépend de l'ordre ; *non vérifié* : comportement d'`openxlsx` (non installé ; mesures de l'issue).
- **Décision non résolue** : pour (b), texte brut, collé ou les deux : choix de `coder-approfondi` à l'étape 3 ; recommandation : les deux.
- **Critères déclenchés** : aucun pour les textes.
- **Hors périmètre** :
  - à mesurer à l'étape 3 (a) de #595 (critère G ou E1 si valeur fausse, non vérifié) : `Target` unique entre apostrophes (`Target='…'`) ou avec des blancs autour de `=` (la regex d'`openxlsx` `(?<=Target=").+xml(?=")` ne le trouve pas) ; `<x:Relationship` préfixée suivie d'une tabulation ; racine `<Relationships` suivie d'une tabulation ;
  - mineurs écartés (ADR 0018) : motif « balise de cellule de forme non reconnue » écrit deux fois (l. 9805 et 10219) ; « Colonne t incomplete » sans plafond (déjà #558 (4a)) ; `.tex` l. 5058 sans signalement (déjà étape 7).
