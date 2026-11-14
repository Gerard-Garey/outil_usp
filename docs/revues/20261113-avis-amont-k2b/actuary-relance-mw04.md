# Relance ciblée d'`actuary` sur le point 6 (MW-04), K2b, étape 2

> *Rédigé par l'agent actuary (IA), fiche de base.* Relance unique du 13/11/2026, en lecture seule. L'agent n'a écrit dans aucun fichier du dépôt et n'a touché à aucune issue. Ce texte remplace le point 6 de l'avis amont rendu plus tôt dans la journée.

Légende : **[M]** mesuré par l'agent (texte consolidé extrait du fichier xhtml de la racine, puis lu) ; **[L]** lu ; **[R]** établi par `regulatory` dans `regulatory-lecture-mw04.md` et non refait ici.

## Accord ou désaccord sur (i) à (vi)

**(i) Art. 219(1)(a) : d'accord.** Le texte consolidé dit, à l'art. 219(1)(a) : « les données répondent aux conditions énoncées à l'article 19, paragraphes 1, 2 et 3, […] les références au calcul des provisions techniques s'entendant comme des références au calcul des paramètres propres à l'entreprise » [M]. L'art. 19(1)(b) ne vise les USP que par ce renvoi, qu'il faut donc citer.

**(ii) « À défaut, la méthode n° 1 reste ouverte » : d'accord, la phrase est inexacte.**
- L'art. 220(1)(b) offre « la méthode du risque de réserve n° 1 ou la méthode du risque de réserve n° 2 » [M].
- L'art. 220(2) règle le choix entre les deux : « Lorsque l'entreprise est en mesure d'utiliser plusieurs méthodes standard, elle utilise celle qui fournit les résultats les plus précis… » [M] ; à défaut de démontrer la plus grande exactitude, elle prend la plus prudente [R].
- La méthode n° 1 n'est donc pas un repli qui s'ouvrirait faute de justification.
- L'erreur vient de mon avis du 12/11 (§ 4, troisième proposition), et je l'ai reprise ce matin. Je la retire.

**(iii) Nouvelle annotation datée de l'ADR 0005 : d'accord.**
- La troisième puce de l'annotation du 13/11 porte la même inexactitude, et elle fixe la qualification commune. L'erreur passerait donc dans le motif, dans le `.tex` et dans l'ADR.
- La nouvelle annotation, rédigée par `architect`, doit précéder le commit de #540 par `coder` et le passage de `docwriter`.
- Elle corrige un texte adopté par le mainteneur (Q-61-1 (a) : « formulation du § 4 de l'avis »). Elle lui est donc soumise pour accord. Le fond reste celui de la lecture (A) : aucune décision nouvelle sur le fond.

**(iv) Merz et Wüthrich hors du motif : d'accord.**
- Une source académique n'aide pas l'utilisateur à corriger ses données.
- La citation reste dans le `.tex` et dans l'ADR. Je l'ai vérifiée ce matin : CAS E-Forum, automne 2008, p. 546 [M, `pdftotext`].

**(v) Passages du `.tex` : d'accord.**
- **À reformuler** : l. 4781, 5041 et 14677.
- **Corrects** : l. 1676, 7480 et 17643.
- Pour la l. 5041, je me range à `regulatory`. Ce matin je proposais seulement d'ajouter « à la lettre ». Il faut aussi séparer le cas I < J (exclu par D(2)(e)) du cas I > J (admis par le texte, refusé par l'outil).
- Pour la l. 17643, la précision de `regulatory` est facultative et je n'ai pas d'objection : la règle de minimum s'applique par prescription, sans condition sur I.

**(vi) Corrections mineures de l'ADR : d'accord.**
- Remplacer « entièrement développées en J » par « qui ont atteint l'année de développement J ».
- Annoncer la liste des critères de la suite (#567) par « notamment ».

## Texte final unique du motif MW-04

Condition d'émission : `if (I > J)` à la place de `if (I != J)`. Message en `sprintf`, avec `nrow(tri)` puis `ncol(tri)` :

```
Triangle non carre (%d annees d'accident, %d annees de developpement) : admis par l'annexe XVII, section D, point (2)(e), mais refuse par l'outil, les formules des paragraphes 4 et 5 de cette section ne se calculant a la lettre que pour un triangle carre. Se ramener a un triangle carre exclut des annees d'accident : exclusion a justifier (art. 219(1)(a) et 19(1)(b)).
```

Écarts avec le texte de `regulatory` :
- **« que pour un triangle carre » au lieu de « que si I = J ».** Le motif s'adresse à l'utilisateur et donne les effectifs, pas les symboles I et J, qu'il ne définit pas. Le sens est le même.
- **« Se ramener a un triangle carre » au lieu de « a un carre »**, pour la clarté.

Le reste reprend le texte de `regulatory`, en particulier « exclut des annees d'accident ». C'est exact : retirer des colonnes de développement priverait la première année de ses derniers paiements.

**Effet sur les tests** (`tests/unitaires/test_controles_entree.R`, lus [L]) :
- **l. 1612-1617** (6 × 5) : `contient("non carre")` et `contient("paragraphes 4 et 5")` restent vrais. **Inchangé.**
- **l. 2135-2138** : le test vérifie que le motif commence par `"Triangle non carre (8 annees d'accident, 7 annees de developpement)"`. Le préfixe est conservé. **Inchangé.**
- **l. 1664-1668** : le test compare le texte complet. **À remplacer** par le texte ci-dessus.
- **l. 1618-1622** (5 × 6, I < J) : **à compléter**. Il faut vérifier qu'il n'y a qu'un motif et qu'aucun ne contient « non carre ».

Le motif écrit « section D, point (2)(e) » et ne contient donc pas la chaîne « D(2)(e) ». Le test de MW-03 (`contient("D(2)(e)")`) ne peut ainsi pas réussir à cause de MW-04. C'est une raison de garder cette forme plutôt que la notation abrégée.

## Qualification commune corrigée (nouvelle annotation de l'ADR 0005 et `.tex`)

1. Les formules des paragraphes 4 et 5 de la section D de l'annexe XVII ne se calculent à la lettre que si I = J. Pour I > J, deux termes sont indéfinis :
   - C(i, I−i), pour i < I−J ;
   - Q̂_{I−i}, pour 1 ≤ i ≤ I−J.

   Ces termes ne concernent que les années d'accident qui ont atteint l'année de développement J.
2. Le domaine de l'outil est plus étroit que celui de D(2)(e), qui admet I > J.
   - Le refus d'un triangle I > J est le choix de la lecture stricte (A), non une exigence du texte.
   - Un triangle I < J relève du seul motif D(2)(e).
3. Se ramener à un triangle carré exclut des années d'accident. Cette exclusion est à justifier : l'art. 219(1)(a) rend applicable l'art. 19(1)(b), selon lequel « aucune donnée pertinente n'est exclue … sans justification ». Après troncature, la nouvelle première année d'accident doit satisfaire D(2)(d) [R, non relu ici].
4. La méthode du risque de réserve n° 1 est l'autre méthode standard de l'art. 220(1)(b), sous ses propres exigences de données (section C). Le choix entre les deux méthodes relève de l'art. 220(2).
5. Merz et Wüthrich (2008, p. 546) supposent I = J par simplicité et annoncent l'extension au cas I > J sans en imprimer la formule.

**Répartition.**
- Le motif porte les points 1 à 3, sans D(2)(d).
- L'ADR et le `.tex` portent les points 1 à 5. Le point 5 renvoie à la bibliographie (`sec:biblio`), où l'entrée Merz et Wüthrich (2008) existe déjà.
- Côté `.tex` :
  - l'encadré de la l. 14677 reçoit la qualification entière ;
  - le tableau de la l. 4781 garde la description des termes indéfinis, ajoute les points 1 et 2, et renvoie à l'encadré pour le reste ;
  - la l. 5041 ajoute « à la lettre » et sépare les cas I < J et I > J.

L'annotation nouvelle doit dire en clair que le motif porte les points 1 à 3 et la documentation les points 1 à 5. Elle lève ainsi la contrainte « la même dans le motif » de l'annotation du 13/11.

## Merz et Wüthrich dans le motif : reste-t-il une décision au mainteneur ?

Il n'y a pas de décision séparée. Le retrait de la citation est l'une des corrections de la nouvelle annotation de l'ADR 0005, que le mainteneur approuve de toute façon, puisqu'elle corrige le point 3 du texte adopté à Q-61-1 (a). La question Q-E de mon avis amont devient donc sans objet et se fond dans cette approbation.

## Retour

- **Statut** : `revue requise`. La nouvelle annotation de l'ADR 0005 (puce 3 corrigée, répartition entre le motif et la documentation, précisions de (vi)) doit être approuvée par le mainteneur avant la reprise par `coder` et `docwriter`.
- **Résultat** : je suis d'accord avec `regulatory` sur les six points (i) à (vi). Le texte final de MW-04 et la qualification commune corrigée sont donnés plus haut. Aucun désaccord ne demeure.
- **Preuves** :
  - *Vérifiées* : les art. 219(1)(a), 220(1)(b) et 220(2) [M, texte consolidé] ; la p. 546 de Merz et Wüthrich [M, ce matin] ; les tests l. 1610-1622, 1662-1669 et 2133-2139 [L].
  - *Non relu ici* : D(2)(d) (recherche infructueuse dans l'extraction, faute de tours) ; je m'appuie sur `regulatory` et sur la citation de mon avis du 12/11.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : approbation de la nouvelle annotation de l'ADR 0005 par le mainteneur. Il n'y a pas de Q-E distincte.
- **Critères déclenchés** : mon avis du 12/11, versé, et la décision Q-61-1 (a) contenaient une inexactitude (méthode n° 1, art. 19 cité sans l'art. 219). Elle est reconnue ici, sans désaccord persistant avec `regulatory`. Aucun σ_USP, aucune p-value ni aucun verdict n'est touché.
- **Prochaine action recommandée** :
  1. `architect` rédige l'annotation datée de l'ADR 0005 avec la qualification ci-dessus, et la session la soumet au mainteneur.
  2. Une fois l'accord donné, `coder` fait l'étape 5 avec le texte final de MW-04 et les tests indiqués.
  3. `regulatory` contrôle le texte en aval, comme prévu.
