# Validation de fin de branche K3 « Registre » : diff du `.tex` (actuary)

> *Rapport d'`actuary` (fiche de base, Opus 5.5), 10/11/2026, reproduit par la session principale (Q-54-10). Diff visé : `c7a6597..20f0ef4 -- docs/latex/doc_tests_usp.tex` (commits `577de3d` #484, `bf54e23` #469, `85c5ce3` #485, `20f0ef4` #486).*

## Visa : validé avec réserves

Cinq réserves, toutes mineures. Le diff fait ce que fixent l'avis amont et les décisions du mainteneur du 10/11/2026 (Kruskal en diagnostic, H0/H1 « sans objet » ; QA1 (a), statistique non définie, texte non lu). La documentation décrit ce que fait `R/engine.R` à `20f0ef4`, sauf le point 4 (correction de `p_exacte` à n1 = n2 = 1, alors dans l'arbre de travail).

## Réponses aux quatre points de `docwriter`

### 1. TOST, « hors hiérarchie » : à garder

- Formule fixée par l'ADR 0002 (point 3, annotations du 07/10 et du 15/10/2026) et reprise par `CONTEXT.md` (« Modèle auxiliaire MCO », « P-value retenue ») ; la changer exigerait d'annoter l'ADR. Le fond la justifie : la p de Student pondérée n'a aucun des statuts de la hiérarchie (poids estimés).
- La phrase ajoutée en `sec:modele-auxiliaire-regles` concilie les deux plans : hors hiérarchie quant au statut, « place de la p non simulée » dans le mécanisme d'`add()` (code l. 4864-4874). Sans conséquence sur le verdict : le TOST n'a jamais de p exacte ni de p Monte-Carlo.
- Tension restante (m1), antérieure à la branche : l'encadré de `sec:nature` affirme qu'une p non simulée retenue porte la nature `asymptotique` ou `approximation a n fini` ; la p du TOST, rangée dans `p_asymptotique`, est retenue sous une troisième nature, sans exception écrite.

### 2. Kruskal à un résidu par année : diagnostic par règle

- Pas par nature (le type dépend de `ka$un_par_annee`) ; pas par décision (le cas dépend des données : géométrie du triangle après exclusion des colonnes dégénérées) ; donc par règle. Identité vérifiée : N groupes de taille 1 donnent H = N − 1. La définition actuelle n'énumère que R1, R3, R14, R15 : à étendre (m2).

### 3. Anscombe-Glynn, rubrique 3 : justification exacte

- b2 = m4/m2² ≥ 1 (Cauchy-Schwarz) ; dénominateur croissant en b2 (A > 6 > 4), minimal en b2 = 1.

| T | 33 | 34 | 35 | 36 |
|---|---|---|---|---|
| dénominateur en b2 = 1 | +0,01332 | +0,00514 | −0,00275 | −0,01037 |

- Négatif pour tout T de 35 à 20 000 ; Z signée = +35,899 à T = 40, b2 = 1 (inversion confirmée).
- Complément : b2 = 1 n'est atteint qu'à T pair ; à T impair, minimum 1/(pq) − 3 (inégalité de Pearson b2 ≥ 1 + b1) ; à T = 35, b2 min = 1,00327, dénominateur −0,00096 : cas atteignable dès T = 35.
- Formulation « texte non lu » à harmoniser (m5) : l'inventaire classe l'article [P], texte entier non relu.

### 4. Suites à n1 = n2 = 1 : une phrase sur la p exacte, après la correction

- À n1 = n2 = 1, la loi exacte de R existe (ponctuelle en 2) : p exacte = p_min = 1, test sans objet à tout α ; seule Z est non définie. Mettre `p_exacte` à NA applique la convention des lignes non applicables (aucune p-value restituée, l. 3606-3610). Validé sur le fond.
- Erreur au passage (m3) : « (R ≡ 2, Var(R) = 0) » se rattache aux deux cas, alors qu'à n1 n2 = 0, R vaut 1.

## Réserves et textes de correction

**m1** — `sec:nature`, encadré « Principe de sélection », l. ~5857-5860 : après « … badge «~approx.\ n fini~» de \code{badge\_nature()} dans l'application)~; », insérer :
> seule exception, la p-value de Student du TOST, rangée dans \code{p\_asymptotique} (famille~(iii)), est retenue, quand la ligne est un test, sous une nature qui nomme le modèle auxiliaire pondéré, posée par \code{nature\_forcee}~: hors hiérarchie par son statut, aucune des trois voies ne la portant, elle occupe dans \code{add()} le rang de la p non simulée, le seul que son préfixe puisse respecter (point~(iv) ci-dessous)~;

**m2** — classement de la ligne Kruskal :
- `sec:nature` l. ~5945 : « \emph{par règle}, quand le motif en dépend (règles R1, R3, R14 et R15 ci-dessous) » → « \emph{par règle}, quand le motif en dépend (règles R1, R3, R14 et R15 ci-dessous, et ligne de Kruskal--Wallis à un seul résidu par année de survenance, fiche~\ref{mw:m3acc}) » ;
- l. ~6198-6199 : « \emph{par règle} quand il en dépend (règles~R1, R3, R14 et~R15) » → « \emph{par règle} quand il en dépend (règles~R1, R3, R14 et~R15, et ligne de Kruskal--Wallis à un résidu par année, fiche~\ref{mw:m3acc}) » ;
- `mw:m3acc` l. ~16561 : « La ligne est donc posée en diagnostic par \code{mw\_tests()}, » → « La ligne est donc posée en diagnostic par \code{mw\_tests()} (diagnostic \emph{par règle} au sens de la section~\ref{sec:nature}~: le cas dépend des données, par la géométrie du triangle après exclusion des colonnes dégénérées), ».

**m3** — `fiche:suites-wald-wolfowitz`, l. ~11441-11442, après le commit de la correction de `p_exacte` : remplacer la phrase par :
> Si $n_1 n_2 = 0$ (un seul côté de la médiane représenté) ou $n_1 = n_2 = 1$ ($R \equiv 2$), $\operatorname{Var}(R) = 0$ et $Z$ n'est pas définie~: \code{stat} à \code{NA}, ligne non applicable, motif selon le cas, sans aucune p-value restituée, \code{p\_exacte} comprise~; à $n_1 = n_2 = 1$, la loi exacte de $R$, ponctuelle en~2, donnerait $p = p_{\min} = 1$, et le test serait sans objet à tout $\alpha$.

**m4** — `fiche:suites-ratios-bruts`, l. ~12041 : « Elle n'est pas définie dans les deux mêmes cas » → « $Z$ n'est pas définie dans les deux mêmes cas ».

**m5** — `fiche:anscombe-glynn-aplatissement`, rubrique 3, l. ~11122-11123 : → « Le texte d'Anscombe et Glynn (1983) n'a pas été relu (texte intégral non relu)~; le document n'affirme rien de ce qu'il prescrirait dans ce cas. »

## Points relus sans constat

Index `add()` ; convention de restitution et refus d'`add()` (conformes à `verifier_p()` et au contrôle de forme de `nature_forcee`) ; nature forcée ; motif Monte-Carlo après « TEST INOPERANT » (conforme à `pre_mc`) ; R15 et priorité ; `PHRASE_VERDICT_SENSIBLE_MC` ; tableaux ; Anscombe-Glynn (p-value, pertinence, statut des valeurs, motifs identiques au code) ; Kruskal H0/H1 ; `mw:m3runs` ; index ; distinction exact / asymptotique / approximation / simulation : aucune confusion introduite.

## Retour

- **Statut** : complet. **Résultat** : validé avec réserves (m1 à m5, mineures).
- **Preuves** : diff du `.tex` (262 lignes) ; lecture de `R/engine.R` ; ADR 0002, `CONTEXT.md` ; `Rscript` (premier T à dénominateur ≤ 0 en b2 = 1 : 35 ; b2 min à T = 35 : 1,00327 ; Z signée à T = 40 : 35,89946 ; `test_anscombe_kurt()` NA et `z_non_definie` ; `test_runs(c(1,2,2,2,3))` NA, R = 2) ; algèbre (H = N − 1 ; b2 ≥ 1).
- **Non vérifié** : mesure Cox-Stuart à m = 0 (relève d'`audit`) ; Anscombe et Glynn (1983), D'Agostino et al. (1990), non lus.
- **Critères** : changement de résultat (p exacte de la ligne des suites à n1 = n2 = 1, hors références), validé sur le fond ; aucun désaccord.
