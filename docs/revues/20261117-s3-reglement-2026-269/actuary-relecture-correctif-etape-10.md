# Relecture d'actuary du diff correctif, étape 10 de S3 (#504, #598)

> *Rédigé par l'agent actuary (IA) le 17/11/2026.* Branche `claude/reglement-2026-269` à `989e87a`. Je n'ai rien écrit dans le dépôt.

**Ce que j'ai relu (règle 10, diff correctif seul) :**
- le diff `git diff 16d2433..989e87a -- docs/latex/doc_tests_usp.tex` en entier : 50 lignes changées, dans les commits `d4c8b9f` et `989e87a` ;
- le diff de `docs/suivi-documentation/` sur le même intervalle ;
- les constats m1 à m6 de `regulatory-controle-tex-etape-9.md` ;
- ma validation de l'étape 10 ;
- le contexte des trois passages signalés par le rédacteur (l. 14160-14195 et 14340-14365).

`git diff --stat c8225c0..989e87a` ne touche pas `R/engine.R`. Le code sur lequel j'ai mesuré M1 à l'étape 10 est donc inchangé, en particulier `usp_parametre_standard()`, l. 1093 : `sigma_standard = if (saisie) sigma_standard else sigma_regl`. Ma mesure vaut toujours.

## Visa : levé sans réserve

M1 est corrigé exactement. Mes mineurs m1 à m5 sont repris fidèlement. Aucune modification du diff ne change le fond du document au-delà de ce que les constats demandaient. Les trois passages du point 2 ne conditionnent pas le visa (voir § 2).

## 1. M1 et mes mineurs

- **M1 est levé (l. 2452-2456).** Le texte distingue maintenant les deux cas :
  - « sans σ standard saisi » : l'erreur garde son sens. Déclarée présente à tort, la réassurance abaisse σ_USP de (1−c)×0,2×σ_brut (sens non prudent). Déclarée absente à tort, elle l'élève d'autant (sens prudent).
  - « Avec un σ standard saisi, σ_USP n'en dépend pas ; seule change la valeur réglementaire à laquelle la saisie est comparée. »

  C'est ma rédaction proposée. Elle est conforme au code (l. 1093) et à la mesure de l'étape 10 : σ_USP est `identical()` entre une déclaration TRUE et une déclaration FALSE, et seule la conformité de la saisie de 0,10 bascule. La phrase n'affirme plus rien de faux sur le chemin de la saisie, que le même paragraphe ouvre (« σ standard saisi ou non »).
- **m1 (l. 2416-2417)** : « son terme standard est le paramètre que σ_USP remplace dans ce même calcul ». C'est conforme, et l'imprécision sur le terme estimé disparaît.
- **m2 (l. 2655-2658)** : les deux incises demandées y sont, « calculé avec le σ standard de la table » et « ne dépend pas des valeurs observées ». C'est conforme. Les trois Δ (+0,0082, +0,00304, +0,01148) sont inchangés et restent justes.
- **m3 (l. 14159)** : « rapport qui dépend du paramètre standard retenu ». C'est conforme. La correction du rédacteur est fondée : le passage est bien en rubrique 5 (`\Pval`), et non en rubrique 6. Mon rapport le situait à tort.
- **m4 (l. 14401, `d4c8b9f`)** : « au moins deux démarrages sont à l'optimum ». C'est conforme et cohérent avec la rubrique 3 et avec `a_optimum` (l. 2163 du moteur).
- **m5 (l. 22436-22441)** : le texte ajoute les intervalles bootstrap de σ_USP et `res$plots_data` des deux méthodes, puis l'acceptation ou le refus du calcul (`ok`) pour une anomalie d'`engine_valider_declarations()`. C'est conforme à ma lecture de l'étape 10 (IC Merz-Wüthrich, l. 16729-16731 ; domaine refusé par cette fonction). La clause « aucune p-value ni aucun verdict » est conservée, et elle reste exacte.

## 2. Les trois passages laissés tels quels

Les trois phrases sont **vraies mais devenues incomplètes**. Avant S3, σ_std ne variait, à données identiques, que par la table (version 2015 ou consolidée) ou par la saisie. Depuis S3, il varie aussi avec la date de référence et la déclaration NP (segments 1, 4, 5 nettes). Le constat t1 de l'étape 10 en donne une illustration mesurée : au segment 1, données nettes, sans NP, le Δ_max du jackknife passe de 10,12 % à 9,38 % d'un côté à l'autre du 30.1.2027, à données identiques. Aucune des trois phrases n'est fausse : la dépendance à la table existe toujours. Aucune ne touche σ_USP, une p-value ou un verdict.

**Mon avis : les corriger dans la branche.** Ces passages ne sont pas hors périmètre : c'est S3 (#504) qui les a rendus incomplets. La même fiche a déjà été corrigée en rubrique 3 et, par m3, en rubrique 5. Les laisser créerait une incohérence interne de la fiche jackknife. Le coût est une substitution de quelques mots, par un commit `docs:` minimal.

Si la session les juge malgré tout hors périmètre, le tri ADR 0018 donne le critère « aucun » : affirmation exacte, sans effet sur σ_USP, une p-value, un verdict, la conformité ou la reproductibilité. Ils seraient alors écartés en une ligne. Le visa n'en dépend pas.

Textes proposés :
- **Fiche jackknife, rubrique 6 (l. ~14171).** Remplacer « il dépend de la table de l'annexe par la part standard du dénominateur, à données identiques » par :
  > « il dépend du paramètre standard retenu (table de l'annexe, nature des données, texte applicable et réassurance non proportionnelle déclarée, saisie) par la part standard du dénominateur, à données identiques »

  La mesure qui suit compare les tables de 2015 et consolidée. Elle reste une illustration valable, et je n'y touche pas : sa valeur de −9,4 % correspond à σ_std = σ_brut, données brutes, cohérente avec la l. 2648.
- **Même fiche, « Pourquoi aucun verdict » (l. ~14186).** Remplacer « et dépend de la table de l'annexe » par :
  > « et dépend du paramètre standard retenu »
- **Fiche `fiche:ic-bootstrap`, « Pourquoi aucun verdict » (l. ~14363).** Remplacer « les repères, sans source, dépendent de la table » par :
  > « les repères, sans source, dépendent du paramètre standard retenu »

  Le titre de paragraphe « Dépendance de L à la table de l'annexe » (l. ~14348) annonce une mesure qui porte bien sur la table. Il reste exact et je ne propose pas de le changer.

## 3. Le reste du diff ne change pas le fond

Les autres changements portent sur les mineurs de `regulatory` :
- m1 : « sans disposition transitoire pour les articles 117, 148 et 218 à 220 » ;
- m6 : renvoi nommé au paragraphe « Texte 2026/269, risque de primes » ;
- m4 : le cas « en l'absence de réassurance non proportionnelle (premier alinéa) » est ajouté ;
- m2 : guillemets retirés de « à remplacer » ;
- m3 : chaîne de renvoi de l'annexe XIV ;
- m5 : motif complété de l'anomalie de 148(4).

Chacun reprend la correction proposée par `regulatory`. Aucun n'introduit de chiffre, de p-value, de vitesse de convergence ni de référence nouvelle. Aucun ne modifie une conclusion :
- m4 confirme « sans couverture qualifiante, la valeur de l'annexe sous toutes les lectures » ;
- m3 étend R-3 à l'annexe XIV sans en changer les deux lectures, et la mention « aucune des deux lectures n'est uniformément prudente » reste exacte pour les deux annexes, le facteur Adjust ayant la même forme.

Une remarque de forme, que je ne compte pas comme constat : « à l'article 148, paragraphe 2, lu comme le point b) » ne nomme pas le point a) que vise le texte. L'anomalie est documentée dans l'encadré (l. ~2715-2716), et la lecture relève de `regulatory`.

Les trois fichiers de `docs/suivi-documentation/` ne reçoivent que l'historique des passages retirés. C'est conforme à `CONVENTIONS.md` (règle « Pas de vie du dépôt »), sans contenu de fond.

## Constats

Aucun constat bloquant ni majeur. Un seul mineur, recommandé sans être exigé : **r1**, les trois passages du § 2, à corriger par substitution (textes ci-dessus).

---

## Retour

- **Statut** : `complet`.
- **Résultat** : **visa levé sans réserve**. M1, m1 à m5 et les mineurs m1 à m6 de `regulatory` sont repris correctement. Aucun changement de fond hors des constats. Pour r1, je recommande de corriger dans la branche ; à défaut, l'écarter (ADR 0018, critère « aucun »).
- **Preuves** :
  - *Vérifié* :
    - le diff `16d2433..989e87a` du `.tex` (50 lignes) et de `docs/suivi-documentation/`, ligne à ligne ;
    - `R/engine.R` n'a pas changé depuis `c8225c0` (`git diff --stat`) ;
    - l. 1093 de `usp_parametre_standard()` (la saisie prime) ;
    - la valeur 0,1114524 pour les données brutes (l. 2648 du `.tex`), cohérente avec le −9,4 % de la fiche jackknife ;
    - le contexte des l. 14160-14195 et 14340-14365.
  - *Hypothèses* : aucune nouvelle.
  - *Non vérifié* :
    - la compilation du `.tex` et `concordance_doc_moteur.R --strict` (à la charge de la session) ;
    - les sources des mineurs de `regulatory` (art. 170, p. 37 ; 148(2), L 12/142), relevant de cet agent ;
    - je n'ai pas relancé de mesure, puisque le code est inchangé.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : la session décide entre corriger r1 (recommandé) et l'écarter.
- **Critères déclenchés** : aucun. Pas de changement de résultat, aucun désaccord avec `audit`, `regulatory` ou un ADR.
- **Constats hors périmètre** : aucun. r1 relève du périmètre de #504.
- **Prochaine action recommandée** : `docwriter` applique les trois substitutions de r1 par un commit `docs:` minimal. Je n'ai pas besoin de les relire si le texte est repris tel quel ; sinon, une relecture de ce seul diff. Ensuite viennent le commit du PDF et la revue finale de la règle 10.

Fichiers :
- /home/user/outil_usp/docs/latex/doc_tests_usp.tex
- /home/user/outil_usp/docs/revues/20261117-s3-reglement-2026-269/actuary-validation-etape-10.md
- /home/user/outil_usp/docs/revues/20261117-s3-reglement-2026-269/regulatory-controle-tex-etape-9.md
