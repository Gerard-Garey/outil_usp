# Avis d'`actuary` sur le constat m1 de l'étape 7 (#567) : texte du motif « Triangle totalement dégénéré » sur un trapèze

> *Rédigé par l'agent actuary (IA, fiche de routine) le 21/11/2026 ; versé intégralement par la session principale.* Constat d'origine : § 4 de `regulatory-7-conformite-aval.md`. **Décision du mainteneur, 21/11/2026 : option (i)**, refus maintenu, motif conditionné à la géométrie (cadre de Q-E2r-192-1) ; correction technique dans #567 sur cette branche.

**Je recommande l'option (i).** Le refus de #192 reste, et seul le texte du motif change, sous une condition de géométrie. Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue.

## 1. Le constat est exact

Le cas (s5) de ma spécification 2a a gardé le prédicat sur j = 0..J−2, donc le refus. Mais le motif repris du carré dit à tort « aucun residu de Mack n'est retenu ».
- `mw_residus()` (`R/engine.R` l. 14437-14467) garde la colonne J−1 d'un trapèze à trois conditions : elle a au moins 2 facteurs, sa variance de réduction (estimateur direct σ²_{J−1}, `.mw_sigma2_residus()`) est strictement positive, et elle ne figure pas parmi les colonnes écartées.
- Dans le cas (s5), les trois conditions sont remplies. Le test (s5) (`tests/unitaires/test_merz_wuthrich_trapeze.R` l. 426-439) vérifie d'ailleurs `sigma2_Jm1_direct > 0` et que la colonne J−1 n'est pas dégénérée.
- Le commentaire l. 14090-14105 fonde le refus sur des exigences « inverifiables quand aucune variance n'est observee ». Dans ce cas, de la variance est observée sur la colonne J−1. Ce commentaire énonce une règle, donc il relève aussi du critère E5 (ADR 0018, l. 59).

## 2. Pourquoi (i) et pas (ii)

Le refus de #192 (décision du mainteneur, Q-E2r-192-1, option A) repose sur deux exigences de données, rendues obligatoires par l'art. 219(1)(d). Dans le cas (s5), les deux restent non établies.
- **Cohérence avec D(2)(h)(iv)** (variance proportionnelle au cumul précédent). Elle ne peut être éprouvée que sur la seule colonne J−1, soit I−J+1 facteurs : 4 sur un 8 × 5, au plus 5 à T = 8 puisque J ≥ 4. La proportionnalité se juge en comparant les colonnes entre elles ; une colonne unique ne la teste pas. Sur 4 ou 5 résidus, la puissance des diagnostics de Mack est négligeable. Je n'ai pas de référence qui chiffre cette puissance : c'est un argument de taille d'échantillon, pas un résultat publié.
- **Représentativité, D(2)(a).** L'argument est plus fort que sur un carré. Les données montrent une variabilité en J−1, mais la lettre de D(5)(d)(ii) la retire de la MSEP : σ²_{J−1} est fixé par la règle de minimum, nulle dès que σ²_{J−2} ou σ²_{J−3} l'est. La MSEP vaut alors 0 et D(4) donne σ_USP = (1 − c)·σ(res,s). Admettre ce triangle donnerait un crédit c à une MSEP nulle qui ignore une variance observée, donc une sous-estimation probable.
- **L'option (ii) changerait un résultat.** Elle ferait passer le cas d'un refus à un σ_USP rendu, ce qui touche σ_USP et l'acceptation du triangle et demande une décision du mainteneur. Rien ne la justifie.

## 3. Effet

- Aucun effet sur σ_USP, les verdicts, les p-values ni le statut `ok`. Seul change le texte de `validation$erreurs` dans le cas (s5).
- Aucune des références n'est concernée : `grep "totalement degenere"` sur `tests/reference/` ne trouve rien, `reserve2_trapeze` compris. Aucune régénération n'est nécessaire.
- Le motif du carré, et du trapèze dont la colonne J−1 est aussi dégénérée, reste **identique au caractère près**. Les tests `fragments192` (`test_merz_wuthrich.R` l. 1720 et suivantes, `test_merz_wuthrich_suite.R` l. 118) passent donc sans changement.

## 4. Spécification pour `coder`

**Condition de la variante.** Le triangle est totalement dégénéré et `mw_residus(aj)` retient au moins un résidu. Sous le prédicat, seule la colonne j = J−1 peut en porter. La condition suit ainsi exactement ce que fait le code, sans prédicat nouveau. La forme équivalente est : `!is.null(aj$sigma2_Jm1_direct)`, J−1 hors de `.mw_j_exclues(aj)` et variance de réduction strictement positive. Je préfère l'appel à `mw_residus()`, qui fait foi.

**Texte de la variante** (ASCII). Les fragments [A] et [B] remplacent leur équivalent du motif actuel ; tout le reste est inchangé.
- Arguments de `sprintf` : le premier `%s` reste `format(msep, digits = 3, decimal.mark = ".")` ; le `%d` est `I - J + 1`.
- `<PREDICAT>` = `.MW_PREDICAT_DEGENERE_TEXTE`.

```
Triangle totalement degenere : pour chaque annee de developpement j = 0..J-2, les facteurs individuels C(i,j+1)/C(i,j) sont identiques (a la tolerance relative 1e-12 de l'outil pres : <PREDICAT>). Pour des facteurs exactement egaux, en arithmetique exacte, sigma2_j = 0 (annexe XVII, D(5)(d)(ii)) et MSEP = 0 ; ici sigma2_j et la MSEP (valeur calculee : %s) sont nuls ou negligeables a la tolerance de l'outil (residus d'arrondi ou ecarts relatifs entre facteurs de l'ordre de 1e-12), [A] aucun residu de Mack n'est retenu sur les annees j = 0..J-2 et, par D(4), sigma(res,s,USP) = (1 - c) * sigma(res,s) a un ecart negligeable pres, sans contribution significative des donnees. Seule l'annee de developpement J-1 (%d facteurs individuels, I - J + 1) porte des facteurs distincts et des residus de Mack ; sa variance n'entre pas dans la MSEP, ou sigma2_(J-1) est fixe par la regle de minimum de D(5)(d)(ii), nulle ou negligeable des que sigma2_(J-2) ou sigma2_(J-3) l'est. [B] Ces donnees ne permettent pas d'etablir leur coherence avec les hypotheses sur la nature stochastique des montants de sinistres cumules (D(2)(h), en particulier iv : variance proportionnelle au cumul precedent), que la seule annee J-1 ne suffit pas a eprouver, ni leur representativite du risque de reserve (D(2)(a)), la variabilite observee sur l'annee J-1 etant absente de la MSEP ; exigences de donnees rendues obligatoires par l'article 219, paragraphe 1, point d). L'outil n'applique donc pas a ce triangle la methode du risque de reserve no 2 (article 220, paragraphe 1, point b)). Verifier qu'il s'agit de paiements cumules observes (D(1)) et non de montants projetes ou lisses.
```

L'expression « nulle des que sigma2_(J-2) ou sigma2_(J-3) l'est » est exacte : c'est l'équivalence démontrée en commentaire l. 13645-13650, et J ≥ 4 par D(2)(c), donc J−3 ≥ 1.

**Critères d'acceptation**
1. Le motif du carré est inchangé : les `fragments192` existants passent.
2. Le test (s5) vérifie en plus :
   - que les fragments « aucun residu de Mack n'est retenu sur les annees j = 0..J-2 », « Seule l'annee de developpement J-1 (4 facteurs individuels, I - J + 1) » et « absente de la MSEP » sont présents ;
   - que le fragment du carré « aucun residu de Mack n'est retenu et, par D(4) » est absent ;
   - un seul motif, et aucun avertissement de colonnes.
3. Il faut un cas de trapèze dont la colonne J−1 est aussi dégénérée. Il doit garder le motif du carré et ne retenir aucun résidu.
4. Le commentaire l. 14090-14105 est mis à jour : la variance de la colonne J−1 peut être observée, mais elle est écartée de la MSEP par D(5)(d)(ii).
5. `concordance_doc_moteur.R --strict` passe, et `identical()` tient sur les sept références.

**Hors périmètre :** le prédicat, la décision de refus, les autres motifs.

## 5. Où et comment traiter le constat

- **Critère ADR 0018 : E5.** C'est un motif de refus restitué qui dit du code une chose qu'il ne fait pas. Ce n'est pas E4 : la partie réglementaire du motif est exacte. Ce n'est pas E1 ni E2 : le refus est voulu.
- **À traiter dans #567, sur cette branche,** comme une correction technique (circuit 3, `coder` puis `audit` sur le diff), sans issue nouvelle. C'est un défaut introduit par #567 elle-même (la géométrie du trapèze).
- **Un point pour `docwriter` à l'étape 8.** La fiche `sec:controles` (`docs/latex/doc_tests_usp.tex` l. 6003-6020) dit encore « la colonne J−1, qui n'a qu'un facteur individuel pour I = J, seule géométrie admise ». Elle devra décrire la variante, et le § (iv) l. 15827 devra nuancer « ne tire aucune information des données ».

## Retour

- **Statut : complet.**
- **Résultat :** option (i) recommandée. Le refus est maintenu, avec un motif conditionné à la géométrie. Aucun effet sur σ_USP, les verdicts ni les p-values.
- **Preuves.** Vérifié par lecture : `R/engine.R` l. 13613-13639 (prédicat), l. 14090-14126 (motif et commentaire), l. 14437-14467 (`mw_residus()`) ; le test (s5), l. 426-439 ; les fragments `fragments192` dans deux fichiers de test ; l'absence du motif dans `tests/reference/` (grep) ; `doc_tests_usp.tex` l. 6003-6020 et 15827-15834. Repris de `regulatory`, non réexécuté : `mw_residus()` retient 4 résidus sur le 8 × 5 et `sigma2_Jm1_direct` = 3,396. Hypothèse : la puissance négligeable des diagnostics sur 4 ou 5 résidus d'une seule colonne est un argument de taille, sans référence qui le chiffre.
- **Critères déclenchés :** aucun, puisqu'aucun résultat ne change. Rejoint `regulatory` sur la gravité et le critère.
- **Constats hors périmètre :** aucun.
- **Prochaine action recommandée :** brief à `coder` avec la section 4, puis `audit` léger sur le diff, puis reprise par `docwriter` à l'étape 8.
