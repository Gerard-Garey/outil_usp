# K3b, étape 10 : validation du diff du `.tex` par `actuary` (règle 9, ADR 0010)

> *Avis de l'agent actuary (IA), fiche `actuary-approfondi`, le 12/11/2026.* Versé intégralement par la session principale (Refs #555). Branche `claude/registre-restes`. Le diff a été relu à la tête 48f90cf. Pendant la revue, la tête est passée à `cb4863e`, qui n'ajoute que `docs/revues/20261112-fin-de-branche-k3b/code-review.md` : le `.tex` et `docs/suivi-documentation/` sont identiques entre les deux têtes. Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue.

## Verdict : validé avec réserves (pas de visa en l'état)

Deux réserves sont **majeures** : une phrase fausse en #532, et pour #534 une affirmation universelle fondée sur une mesure, insérée de surcroît au milieu d'un raisonnement. Je donne pour chacune un texte de remplacement mot pour mot. Je les ai appliqués sur une copie hors dépôt : `controle_doc_nd.R` donne 0 occurrence de la liste A, 0 violation, et des décomptes de la liste B inchangés.

**Le visa est acquis dès que ces deux textes sont appliqués à l'identique.** Il suffit que la session vérifie que le diff reproduit les textes. Les cinq réserves **mineures** sont recommandées, sans être une condition du visa.

Aucune réserve bloquante. Aucun résultat (σ_USP, p-value, verdict) n'est touché par le diff documentaire.

### Ce qui est conforme
- **Ancrages réglementaires de #555.** Les lignes 3904, 4526, 4538 et 5022 reprennent mot pour mot les textes fixés (`actuary-textes-555.md` § 2.2). La l. 5022 intègre la remarque b de `regulatory`. La présomption est attribuée à l'outil partout, et il ne reste aucune citation « (2)(b) … exige des années consécutives » (grep vide).
- **Code et documentation concordent.** Comparaison faite avec `.entete_designe()`, `.liste_positions()`, `.motifs_colonne_i()`, `engine_lire_triangle()` (étapes A et B), `engine_lire_donnees_csv()` (cumul des refus de noms avec celui des colonnes manquantes, noms cités tels que reçus), `.motif_mc_indisponible()` et ses trois appels dans `add()` (#536), et `verifier_p()` (#537).
- **Vocabulaire.** Celui de `CONTEXT.md` est respecté (test inopérant, diagnostic, non applicable, p-value exacte).
- **Vie du dépôt.** Aucune n'est entrée dans le `.tex` : pas de numéro d'issue, de SHA, de date ni de « depuis ». L'historique est dans `III-H.md` et `I.md`.
- **Contrôles exécutés** sous `LC_ALL=C.UTF-8` : `concordance_doc_moteur.R --strict` donne 0 écart ; `controle_doc_nd.R --bloquant` sort en code 0 (0 liste A, 0 violation de plafond, 0 débordement).

---

## Réserves majeures

### M1. #532, fiche `fiche:suites-ratios-bruts`, l. 12395 : « $R$ finie » est faux (point 2 du brief)

- **Constat.** La grandeur dont la finitude conditionne la ligne est `boot$stats_obs$Runsr`, c'est-à-dire **Z**, et non R : `stat_nom = "Z"` (engine.R l. 7388), et la garde porte sur `is.finite(boot$stats_obs$Runsr)` (l. 7316 et 7401). Le nombre de suites R est défini dès que n1 ≥ 1 et n2 ≥ 1, y compris à n1 = n2 = 1 (R = 2, `test_runs()` l. 2628-2632).
- **Pourquoi c'est faux.** À la lettre, la phrase affirme qu'à n1 = n2 = 1, sous la double condition, la p-value exacte existe. Or la ligne y est non applicable et restitue `p_exacte = NA`. Elle contredit donc la rubrique 2 (l. 12353-12355).
- **Ce qui est vrai.** `runs_p_exacte()` est finie dès que n1 ≥ 1 et n2 ≥ 1 (l. 2735-2739). Z définie implique n1, n2 ≥ 1 et (n1, n2) ≠ (1, 1). Sous la double condition, `usp_runsr_p_exacte()` rend donc une valeur finie (l. 2819-2822).
- **Le relecteur de l'ACPR a-t-il assez ?** Oui, une fois la grandeur corrigée. Les deux cas où Z n'est pas définie et le statut non applicable sont déjà à la rubrique 2. La parenthèse dit alors exactement ce qu'il faut : hors de ces cas, la double condition suffit à l'existence de la p-value exacte, et le commentaire n'a jamais à en justifier l'absence.

**l. 12395, remplacer :**
`(quand $R$ est finie, la p-value exacte existe sous la double condition). Il ne cite pas la p-value de`
**par :**
`(quand $Z$ est définie, la p-value exacte existe sous la double condition). Il ne cite pas la p-value de`

Plafond : la fiche passe de 10 483 à 10 485 caractères, sous les 10 500 (mesuré sur copie).

### M2. #534, fiche `fiche:anscombe-glynn-aplatissement`, l. 11428-11431 : affirmation à qualifier et à déplacer (point 1 du brief)

- **Statut épistémique.** « `run_engine()` n'atteint pas ces refus » est énoncé comme un fait certain. Il repose sur un balayage de 67 ajustements avec `run_engine()` instrumenté, et sur une « majoration de |z| » qui n'est écrite nulle part (le message de `bb390cd` la nomme sans la donner).
  - Mon avis amont (§ 5) le disait déjà : les résidus d'ordre 1 sont « une hypothèse forte, mais pas démontrée ».
  - J'ignore aussi combien des 67 ajustements sont à T ≥ 20. Sous T = 20, la fonction sort avant tout refus, et la mesure n'y apporte rien.
  - Il faut donc qualifier la phrase de constat (`CLAUDE.md`, « Rigueur statistique » ; `CONVENTIONS.md`, « Statuts épistémiques »).
- **Antécédent rompu.** La phrase insérée sépare « Ce dénominateur » de son antécédent, $1 + x\sqrt{2/(A-4)}$ (l. 11427). Il faut la placer en fin de rubrique 3.
- **Soupassement omis.** « dépassement de capacité » omet le soupassement : le cas `rnorm(25) * 1e-170` en relève, et le commentaire du moteur (l. 2415-2416) le nomme.

**l. 11428-11431, remplacer :**
```
négative ou infinie. À $T \ge 20$, des résidus non finis, ou un $b_2$ non fini sur des résidus finis
et non constants (dépassement de capacité des moments centrés en virgule flottante), sont refusés
par une erreur et non restitués~; \code{run\_engine()} n'atteint pas ces refus, la fonction n'y
recevant que les résidus standardisés de l'ajustement validé. Ce dénominateur croît avec $b_2$, et $b_2 \ge 1$ pour tout échantillon
```
**par :**
```
négative ou infinie. Ce dénominateur croît avec $b_2$, et $b_2 \ge 1$ pour tout échantillon
```
**Puis insérer, juste après la ligne qui finit par** « le document n'affirme rien de ce qu'il prescrirait dans ce cas. » (l. 11437 actuelle, avant `\Loi`) :
```
À $T \ge 20$, des résidus non finis, ou un $b_2$ non fini sur des résidus finis et non constants
(dépassement ou soupassement de capacité des moments centrés en virgule flottante), sont refusés
par une erreur et non restitués. \code{run\_engine()} ne transmet à la fonction que les résidus
standardisés de l'ajustement validé, et aucun de ces refus n'y a été observé (constat sur un
balayage d'ajustements, sans script versionné)~; leur inatteignabilité n'est pas démontrée.
```
La fiche reste conforme (2 pages, environ 5 700 caractères, mesuré sur copie avec la seule différence de soupassement près).

---

## Réserves mineures

### m1. #555, `sec:controles`, l. 3942 et 3945 : convention de citation de V3 et V4 et ordre des motifs (point 3 du brief)
- **Sur le fond, conforme.** La formulation suit `actuary-arbitrages-555.md` (points 1 et 2) et le code (`.motifs_colonne_i()` l. 7838-7862) :
  - V1 et V2 sont cumulés ; sinon V3, V4 puis V5, exclusifs ;
  - V3 cite toutes les lignes en cause ;
  - V4 cite la ligne k ;
  - V5 cite les paires.
- **Deux imprécisions de forme.**
  - « ligne citée~: celle dont… » laisse croire à une seule ligne, alors que le code cite chaque décroissance (cinq au plus).
  - « à défaut », juste après « motifs cumulés », peut se lire « à défaut de cumul ».

**l. 3942, remplacer** `à défaut, le premier qui s'applique de trois motifs exclusifs, dans cet ordre~: valeurs répétées`
**par** `en l'absence de ces deux motifs, le premier qui s'applique de trois motifs exclusifs, dans cet ordre~: valeurs répétées`

**l. 3945-3946, remplacer** `(«~\code{Colonne i non croissante}~», ligne citée~: celle dont la valeur est inférieure à celle` / `de la ligne précédente)`
**par** `(«~\code{Colonne i non croissante}~», qui cite chaque ligne dont la valeur est inférieure à celle` / `de la ligne précédente)`

### m2. #555, l. 4603-4607 : en-têtes jamais renommés (point 4 du brief)
- **La phrase est exacte et sa mesure est reproduite indépendamment.** J'ai installé `openxlsx` 4.2.9 dans le dossier de travail de la session, hors dépôt. Puis, avec `charger_moteur()`, des classeurs écrits par `engine_ecrire_xlsx()` et lus par `engine_lire_xlsx()`, avec et sans `openxlsx` :
  - noms lus `t xt yt xt`, `t xt yt T`, `t xt yt t` et `i i 0 1` sur les deux chemins ;
  - refus identiques au caractère près (« En-tete xt present plusieurs fois (colonnes 2, 4)… », « En-tete de la colonne t present plusieurs fois (colonnes 1, 4, d'en-tetes t, T)… », « En-tete de la colonne i present plusieurs fois (colonnes 1, 2, d'en-tetes i, i)… ») ;
  - `formals(openxlsx::read.xlsx)$check.names` vaut `FALSE`.

  La phrase est donc fondée sur deux mesures concordantes, toutes deux hors batterie, ce que le texte dit déjà.
- **Deux précisions.**
  - « dans un CSV » ne vaut que pour un CSV lu comme le lit l'application (`check.names = FALSE`, app.R l. 250). Un appel direct par `read.csv()` avec ses réglages par défaut renomme `xt.1` en amont du moteur.
  - « appelé sans `check.names` » se lit mieux comme la valeur par défaut.

**l. 4603-4607, remplacer :**
`Aucun en-tête n'est renommé pour lever un doublon, sur les` / `deux chemins du classeur comme dans un CSV, de sorte qu'un en-tête présent plusieurs fois reçoit` / `le même refus par les trois chemins (mesuré sur la voie de repli~; \code{openxlsx}~4.2.9, appelé` / `sans \code{check.names}, garde aussi les doublons, mesure faite hors de la batterie de tests, qui` / `n'installe pas ce paquet).`
**par :**
`Aucun en-tête n'est renommé pour lever un doublon, sur les` / `deux chemins du classeur comme dans un CSV lu comme le lit l'application (noms de colonne tels quels), de sorte qu'un en-tête présent plusieurs fois reçoit` / `le même refus par les trois chemins (mesuré sur la voie de repli~; \code{openxlsx}~4.2.9, appelé` / `avec \code{check.names} à sa valeur par défaut, \code{FALSE}, garde aussi les doublons, mesure faite hors de la batterie de tests, qui` / `n'installe pas ce paquet).`

### m3. #537, l. 3741-3742 : forme de l'écriture
« par la plus courte écriture, de 15 à 17 chiffres significatifs » peut se lire comme une écriture de 15 à 17 chiffres, alors que l'exemple cité en compte 10. Le code essaie `format(val, digits = d)` pour d = 15, 16, 17, ce qui donne au plus d chiffres.

**Remplacer** `valeur refusée par la plus courte écriture, de 15 à 17 chiffres significatifs au point décimal, qui` / `se relit à l'identique~:`
**par** `valeur refusée par la plus courte écriture qui se relit à l'identique, à 15, 16 ou 17 chiffres significatifs au plus, au point décimal~:`

### m4. Suivi, alignement sur M1 et M2 (`docs/suivi-documentation/III-H.md`)
- **Entrée #532 (l. 520 environ)** : remplacer `par la justification de l'existence de la p-value exacte quand R est finie.` par `par la justification de l'existence de la p-value exacte quand Z est définie.`
- **Entrée #534 (l. 418 environ)** : remplacer `qu'aucun chemin de `run_engine()` n'atteint (commit `bb390cd` : majoration de |z| sur le domaine validé, balayage de 67 ajustements, `run_engine()` instrumenté, 0 refus).` par `qu'aucune mesure de `run_engine()` n'a atteints (constat, inatteignabilité non démontrée ; commit `bb390cd` : majoration de |z| sur le domaine validé, non écrite, balayage de 67 ajustements, part à T ≥ 20 non consignée, `run_engine()` instrumenté, 0 refus).`

### m5. Hors périmètre, pour mémoire (aucune correction demandée dans K3b)
Aux l. 3905-3908, l'ancrage « D(1), D(2)(c) et D(3)(c) » de la colonne vide du triangle reste imprécis (observation de `regulatory`, `regulatory-conformite-555.md`) :
- D(2)(c) n'exige que cinq années de développement consécutives au moins ;
- D(3)(c) ne fait que définir J.

La présomption y est déjà qualifiée de lecture de l'outil, si bien que la phrase n'est pas fausse. C'est l'issue déjà proposée, à créer au retour du mainteneur (décision 12).

---

## Retour

- **Statut** : `complet`.
- **Résultat** : validé avec réserves.
  - Visa subordonné à l'application mot pour mot de M1 (#532, R → Z) et de M2 (#534, constat qualifié, déplacé, soupassement ajouté).
  - m1 à m4 recommandées ; m5 hors périmètre.
  - Réponses aux quatre points de `docwriter` :
    1. **Oui**, la phrase doit être qualifiée de constat (M2).
    2. La phrase condensée est **suffisante** une fois R remplacé par Z ; en l'état, elle est fausse (M1).
    3. La convention de citation est **conforme sur le fond** ; deux retouches de forme (m1).
    4. La phrase est **exacte** : la mesure `openxlsx` 4.2.9 est reproduite indépendamment ; une précision (m2).
- **Preuves** :
  - *Vérifié, par lecture* :
    - `git diff main...HEAD -- docs/latex/doc_tests_usp.tex docs/suivi-documentation/` ;
    - R/engine.R l. 2418-2443, 2621-2636, 2731-2740, 2819-2832, 4236-4254, 4755-4771, 4862-4922, 7300-7421, 7780-7865, 8018-8132, 8150-8229, 8841-8844, et le diff de `c47bab0` ;
    - les messages de `bb390cd` et `c47bab0` ;
    - les huit fichiers de `docs/revues/20261112-avis-amont-k3b/`.
  - *Vérifié, par mesure* (`Rscript`, `LC_ALL=C.UTF-8`) :
    - `concordance_doc_moteur.R --strict` : 0 écart ;
    - `controle_doc_nd.R --bloquant` : code 0 ;
    - sur une copie hors dépôt portant M1 et M2 : 0 liste A, 0 violation, `fiche:suites-ratios-bruts` à 10 485 caractères, liste B inchangée ;
    - parité des doublons d'en-tête sur les deux chemins du classeur avec `openxlsx` 4.2.9 (installé dans le dossier de travail de la session, hors dépôt) ;
    - en-têtes non UTF-8 contenant `t` (`"t\x85"`, `"\x85t"`) : ne désignent pas `t`.
  - *Hypothèse* : le `.aux` lu par le contrôle des pages correspond au `.tex` courant (même horodatage).
  - *Non vérifié* : la « majoration de |z| » de `bb390cd` (non écrite) ; la part des 67 ajustements à T ≥ 20 ; la recompilation du PDF après correction (pages des fiches à 3 pages « à vérifier »).
- **Informations manquantes** : script et domaine du balayage de #534 (non versionnés).
- **Décisions non résolues** : aucune pour le mainteneur. L'issue m5 et l'issue sur l'installation d'`openxlsx` en CI (`actuary-arbitrages-555.md`) restent à créer sur son accord (décision 12).
- **Critères déclenchés** : aucun changement de résultat. Aucun désaccord avec `regulatory` ni avec un ADR. Un écart entre mon avis amont (§ 5 : non démontré) et le texte de `docwriter` (affirmation universelle), corrigé par M2.
- **Prochaine action recommandée** :
  1. `docwriter` applique M1 et M2, et de préférence m1 à m4, dans un commit `docs:` par issue (#532, #534, puis #555 et #537 pour les mineures), compile pour contrôle avec `controle_doc_nd.R --bloquant` et `concordance --strict` ;
  2. la session vérifie que le diff reproduit les textes ci-dessus, ce qui vaut visa ;
  3. ensuite, commit du PDF et sortie du brouillon selon la décision 13.

Fichiers concernés :
- /home/user/outil_usp/docs/latex/doc_tests_usp.tex
- /home/user/outil_usp/docs/suivi-documentation/III-H.md
- /home/user/outil_usp/R/engine.R
- /home/user/outil_usp/docs/revues/20261112-avis-amont-k3b/actuary-avis-amont.md
- /home/user/outil_usp/docs/revues/20261112-avis-amont-k3b/actuary-arbitrages-555.md
- script de mesure : /tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/mesure_openxlsx.R
