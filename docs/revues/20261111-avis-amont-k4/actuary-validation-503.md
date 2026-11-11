# Avis de validation d'actuary : issue #503, mesure m2var sous trois exposants (branche K4)

Objet : valider la mesure spécifiée au § 5.3 de `docs/revues/20261111-avis-amont-k4/actuary-avis-amont.md`. Ce n'est pas une relance de l'avis amont.

## Pièces lues

- `docs/tableaux/20261111-issue503-m2var-exposants.md` (non commité) ;
- `tests/mesure_m2var_exposants_mw.R` (en-tête, T2 et T2b, notes, contrôles) ;
- fiche `mw:m2var` de `docs/latex/doc_tests_usp.tex`, l. 16037-16158 (rubriques 4 et 6) ;
- `git diff R/engine.R` (le commentaire du § 5.2) et le `detail`, l. 12741-12757 ;
- `CONTEXT.md`, entrées « P-value exacte », « Erreur de Monte-Carlo », « Calibration des p-values Monte-Carlo » ;
- `docs/latex/CONVENTIONS.md` (vie du dépôt, citations de `tests/`) ;
- précédent `docs/tableaux/20261009-issue229-grille.md` (emploi du « test de McNemar exact »).

## Recontrôles exécutés (*vérifié*)

- md5 actuels : `R/engine.R` c5fa9141b295d2c0099391ec01552031, script 34df9a51c481fcaafd251c37ea34944b, `tests/puissance_mw_t8.R` 0e825b10de930e8cd097600c40c6c008. Ce sont les md5 du tableau.
- `binom.test` : 89/122 donne p = 4,040e-07 ; 44/60 donne 3,940e-04 ; 17/62 donne 4,971e-04. Ce sont les valeurs du tableau.
- IC de Clopper–Pearson : P2, κ = 0 : [0,11176 ; 0,14134] ; κ = 2 : [0,08532 ; 0,11188]. Ils se chevauchent de 1,2e-4.
- Avec une correction de Holm sur les trois comparaisons de P2 (calcul fait à la main sur ces p), le plus grand p ajusté vaut 7,9e-04. Le décalage subsiste après correction de multiplicité.
- Rapports calculés sur T1 :
  - sous P2, entre κ = 0 et κ = 2 : 1,29 pour la part au-delà de 1e-3 ; 1,10 pour q50 ; 1,14 pour q90 ; 1,09 pour q99 ; 1,14 pour le maximum ;
  - sous P1 : 1,06 au plus pour q50 ;
  - entre P2 et P1, à exposant fixé : 13,3 à 13,8 pour q50 ; 13,4 à 14,3 pour q99.

## Lecture de fond

1. **Le décalage sous P2 est un effet du modèle de simulation, non un artefact du nombre de triangles.**
   - Le plan est apparié (graines communes, 2 000 triangles indépendants d'un b à l'autre, tous admis). Le test exact de McNemar y est donc valide comme test d'égalité des parts marginales sous le modèle simulé.
   - p = 4e-07 entre κ = 0 et κ = 2. Le classement est monotone sur toutes les grandeurs de T1 : la part, les trois quantiles, le maximum et l'écart moyen.
   - Mon critère « IC disjoints » ignorait l'appariement. Il était donc conservateur, et sa non-activation, de justesse, ne prouve pas l'égalité des lois. Je le dis sans détour : le critère mécanique de l'avis amont n'est pas déclenché, mais le constat qualitatif de la fiche doit quand même être nuancé.
2. **Le décalage est faible.**
   - D de Kolmogorov–Smirnov : 0,025 et 0,017 sous P2, 0,010 et 0,011 sous P1.
   - Les quantiles varient d'environ 10 % d'un exposant à l'autre. L'effet de la dispersion de la première colonne (P1 contre P2) est de l'ordre de ×13 à ×14.
   - La phrase de la fiche « son ordre de grandeur suit la dispersion des cumuls dans les colonnes, non l'exposant » est donc confirmée et désormais quantifiée.
3. **Le sens du décalage renforce la conclusion de la fiche.**
   - L'exposant réglementaire κ = 1 se trouve entre les deux alternatives : κ = 0 donne des écarts un peu plus grands, κ = 2 un peu plus petits.
   - Un écart grand ne signale donc pas un exposant faux. La grandeur ne détecte pas une mauvaise spécification de σ_j. C'est un constat de simulation sous les plans P1 et P2 (géométrie 8 × 8), sans théorème.
4. **Sous P1**, les lois sont pratiquement confondues : maxima 3,68, 3,69 et 3,69e-4 ; aucun triangle au-delà de 1e-3. Les chiffres du 08/11 (« 3,3, 3,7 et 5,6e-4 ») venaient d'une graine non consignée : l'écart n'est pas un défaut, il est remplacé.
5. **Volet R** : min 0,80740, max 0,80769, étendue 2,90e-4. C'est exactement le chiffre de la rubrique 4. Le contrôle (flux) établit que le flux est celui de `mw_bootstrap()` ; aucun triangle n'a été retiré (999 sur 999).

## Q1 — Ajouts hors spécification et vocabulaire

- **T2b (paires discordantes et test exact de McNemar) : à garder**, avec un libellé reformulé. C'est l'analyse adaptée au plan à graines communes que j'avais moi-même imposé. Sans T2b, le tableau laisserait croire, par la colonne « non », à l'absence de différence.
- **D de Kolmogorov–Smirnov descriptif : à garder tel quel.** La note est juste : échantillons appariés, donc aucune p-value de `ks.test()`. C'est la mesure chiffrée de « lois voisines ».
- **Ligne « IC disjoints » : à garder, mais à reformuler.** Telle quelle, « non » se lit comme « pas de différence ».
- **Vocabulaire** :
  - le statut « constat de simulation sous un plan… ; aucun théorème » est correct ;
  - « p exact » entre en collision avec la catégorie « P-value exacte » de `CONTEXT.md`, réservée au modèle réglementaire. Il faut nommer le test (« test exact de McNemar »), comme le fait le précédent #229 ;
  - « descriptif » ne convient pas pour une p-value : écrire « indicatif » ;
  - il manque une phrase qui situe l'incertitude des IC et des p. Elle tient au nombre fini de triangles tirés : ce n'est ni l'« erreur Monte-Carlo » (`err_mc`, liée à B, terme à ne pas employer ici selon `CONTEXT.md`), ni une validité en T.

## Q4 — Le commit ne peut pas partir tel quel : modification du script requise

Ce sont des modifications de texte seulement. Les chiffres doivent rester identiques. Le tableau se régénère ensuite (md5 du script mis à jour).

1. **En-tête du script.**
   - Remplacer « La fiche affirme que sa loi a sensiblement la meme forme sous une variance de C(i,j+1) en C(i,j)^0, C(i,j)^1 ou C(i,j)^2 ; ce script en est le support versionne » par :
     « La fiche mw:m2var (rubriques 4 et 6) cite la loi de cet ecart sous une variance de C(i,j+1) en C(i,j)^0, C(i,j)^1 ou C(i,j)^2, et l'etendue de var(r) sur le bootstrap de reserve2 ; ce script en est le support versionne ».
     Motif : l'ancienne phrase deviendra fausse après la nuance de la rubrique 6.
   - Remplacer « ajout du codeur a la specification, a valider par actuary » par :
     « ajout a la specification de l'avis amont de K4, valide par actuary (validation de #503) ».
     Motif : la mention est périmée dès ce visa.
2. **T2, dernière colonne.**
   - En-tête : « Critère de l'avis amont : IC de T1 disjoints (appariement ignoré) ».
   - Note : « La dernière colonne est la lecture mécanique du critère de l'avis amont de K4 (§ 5.3) : « oui » si deux des trois IC de Clopper–Pearson de la part à |écart| > 1e-3 sont disjoints au sein du plan. Ce critère ignore l'appariement et est conservateur : « non » ne signifie pas l'absence de différence entre exposants ; la comparaison appariée est en T2b. »
3. **T2b.**
   - En-tête de colonne : « p bilatéral du test exact de McNemar (indicatif) ».
   - Note, à substituer à l'actuelle : « T2b : triangles appariés (mêmes graines). Test exact de McNemar : loi binomiale de paramètre 1/2 sur les triangles discordants. Le p est indicatif : trois comparaisons par plan, sans seuil ni correction de multiplicité pré-spécifiés. Il porte sur le modèle de simulation, non sur des données observées : un p petit dit que le décalage des parts entre exposants ne s'explique pas par le nombre fini de triangles tirés, non qu'il est grand ; sa taille se lit dans T1. »
4. **Sous la ligne « Statut »**, ajouter : « Les IC de Clopper–Pearson et les p de T2b ne mesurent que l'incertitude due au nombre fini de triangles tirés (2 000 par cellule) ; ils ne disent rien d'un autre plan ni d'une autre géométrie. »

**Critères d'acceptation**

- Deux exécutions successives donnent une sortie identique, durée exclue.
- Tous les contrôles sont OK.
- `diff` entre l'ancien et le nouveau tableau : seuls changent le md5 du script, la durée et les quatre textes ci-dessus. Aucun chiffre de T1, T2, T2b ni T3 ne change.

Aucune référence `tests/reference/` n'est touchée et aucun résultat du moteur ne change.

## Q2 — Rubrique 6 de `mw:m2var` : nuancer (texte cible pour `docwriter`, étape 10)

Remplacer, l. 16119-16127, le passage qui va de « Constat de simulation (modèle de Mack… » à « …sous les exposants~0 et~2. » inclus. Garder la suite à partir de « Ce sont les tests des fiches… ». Texte cible, mot pour mot :

```latex
Constat de simulation (modèle de Mack à erreurs
gaussiennes ajusté au triangle de contrôle, variance de $C(i,j+1)$ en $C(i,j)^0$, $C(i,j)^1$ puis
$C(i,j)^2$, égale à celle du modèle au cumul moyen de la colonne~; 2\,000 triangles $8\times8$ par
plan et par exposant, tirés sous les mêmes graines d'un exposant à l'autre,
\code{tests/mesure\_m2var\_exposants\_mw.R})~: l'écart à $(N-k)/(N-1)$ a des lois voisines sous
les trois exposants, dont les deux alternatives que nomme la fiche~\ref{mw:m2b}. Sous le plan~P1
(section~\ref{sec:calib-mc-mw}), il vaut au plus $3{,}68$, $3{,}69$ et $3{,}69\cdot 10^{-4}$ en
valeur absolue (exposants~0, 1 et~2) et ne dépasse $10^{-3}$ dans aucun triangle. Sous le plan~P2,
à première colonne plus dispersée, il dépasse $10^{-3}$ dans $12{,}6$, $11{,}2$ et $9{,}8~\%$ des
triangles~: décalage faible mais systématique, que les graines communes rendent détectable, et de
sens opposé pour les deux alternatives, l'exposant~1 du règlement se trouvant entre elles --- un
écart plus grand irait vers l'exposant~0, un écart plus petit vers l'exposant~2, de quelques points
de pourcentage seulement. Son ordre de grandeur suit la dispersion des cumuls dans les colonnes,
non l'exposant~: la médiane de sa valeur absolue est treize à quatorze fois plus grande sous~P2
que sous~P1, et ne varie que d'environ $10~\%$ d'un exposant à l'autre, alors que l'hypothèse M2
est fausse par construction sous les exposants~0 et~2.
```

**Chiffres à citer, tous issus du tableau du 11/11, après sa régénération à chiffres inchangés**

| Grandeur | Avant (fiche) | Après |
|---|---|---|
| P1, max \|écart\|, exposants 0 / 1 / 2 | 3,3 / 3,7 / 5,6·10⁻⁴ | 3,68 / 3,69 / 3,69·10⁻⁴ |
| P1, triangles au-delà de 10⁻³ | non cité | aucun |
| P2, part au-delà de 10⁻³ | « 10 à 11 % » | 12,6 / 11,2 / 9,8 % |
| Médianes de \|écart\| (P2 / P1) | non cité | 13,3 à 13,8 (« treize à quatorze fois ») |
| Variation de la médiane entre exposants | non cité | au plus 1,10 (P2), 1,06 (P1) (« environ 10 % ») |

**Rubrique 4.** Les chiffres sont confirmés à l'identique et restent inchangés. Une seule retouche, recommandée : ajouter le script après « graine 20260831 ». Le texte devient « … section~\ref{sec:boot-mw}, graine 20260831, \code{tests/mesure\_m2var\_exposants\_mw.R}) … ». Le `.tex` cite déjà 151 fois des fichiers `\code{tests/…}`. Ne pas citer de fonction à point initial.

`CONVENTIONS.md` : le texte cible ne contient ni numéro d'issue, ni nom d'agent, ni décision (*vérifié* par relecture). La longueur est proche de l'actuelle (+3 lignes environ). Le contrôle de longueur des fiches reste à faire par `compiler-doc`.

## Q3 — `detail` du moteur : exact, inchangé (*vérifié*)

- « Grandeur contrainte par construction (reference …, et NON 1) » : identité exacte. Le défaut d'identité maximal vaut 3,22e-16 sur 12 000 triangles.
- « qui ne teste PAS la structure de variance » : confirmé et renforcé par la mesure. Les lois sont voisines, et le sens du décalage est opposé selon l'alternative.
- « son ecart a la reference donne a lire le CENTRAGE des residus, ici -0.0151 » : « ici » porte sur la moyenne des résidus, ce que vérifie le contrôle (r2). Aucun nombre de simulation n'est imprimé (règle #76).
- Le renvoi aux deux tests de structure de variance est correct.
- Le commentaire du § 5.2, posé dans `R/engine.R`, est exact une fois la fiche mise à jour. En cours de branche, la documentation peut être en retard sur le code.

Aucun patch de référence.
