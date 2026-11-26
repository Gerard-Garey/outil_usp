# A3, étape 8 : visa du diff du `.tex` de #620 (`actuary-approfondi`, 26/11/2026)

*Rédigé par l'agent `actuary-approfondi` (IA). Rien n'a été écrit dans le dépôt, sur aucune issue ni aucune PR, par l'agent ; versé tel quel par la session principale. Objet : commit `a147700`.*

## Verdict : **validé**, sans reprise

Le diff ne contient aucun constat bloquant ni majeur. Je relève quatre points mineurs, à écarter selon l'ADR 0018 (liste plus bas). Le diff réalise l'intention de la piste (b) :
- les textes du § 4.1 de ma lecture sont repris à l'identique dans `mw:m1d` (rubriques 6 et 7) ;
- les huit passages du § 4.2 sont tous traités ;
- je n'ai trouvé aucune affirmation fausse sur le code ;
- le fond retiré est conservé dans `docs/suivi-documentation/III-M.md` (l. 271), sous `mw:m1d`.

Le tableau avant / après `docs/tableaux/20261126-issue620-colonne-jm1-degeneree.md` reste visé. Les chiffres du `.tex` lui correspondent :
- p d'Alpha : 0,008 → 0,007 et 0,023 → 0,010 ;
- p de famille M1 : 0,015 et 0,019 ;
- p globale : 0,027 et 0,022 → 0,027 et 0,023 ;
- règle de minimum : 0,14 et 0,68.

## Les quatre points soumis par `docwriter`

1. **Ajout au « Statut » de `sec:boot-mw`** : **accepté**. La phrase est exacte. Le plan de `sec:trapeze-niveau` tire σ_{J−1} > 0 : sa colonne J−1 n'est jamais dégénérée, même dans le cas à règle nulle, où c'est la colonne J−3 qui l'est. C'est la correction m4 de ma lecture. Une réserve de style : le « il » peut se lire comme renvoyant au « constat ». « ce niveau n'est pas mesuré » serait plus net, mais c'est facultatif.
2. **Passage (iii), « quand celle-ci n'est pas négligeable, elle cesserait de l'être »** : **accepté, et préférable à mon texte**. La condition ajoutée rend la phrase vraie sur T0 aussi. Sur T0, la règle de la colonne J−1 vaut 7,8·10⁻²⁹, parce que la colonne J−3 = 2 est dégénérée. La colonne y restait donc négligeable même tirée avec la règle, et la p d'Alpha (0,016) n'a pas changé. Mon « elle ne le serait plus » était faux dans ce cas.
3. **`mw:m6sig`, « aucun résidu retenu~; l'estimateur sert aussi à la simuler »** : **accepté**. La phrase précédente (cas non dégénéré) porte déjà « par convention de l'outil, non réglementaire (section~\ref{sec:boot-mw}) », et « aussi » y rattache la phrase sans ambiguïté réelle. L'exclusion de la MSEP et de σ_(res,s,USP) est dite dans la phrase générale qui précède. Ce passage ne contredit pas le gabarit restitué `FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE`.
4. **Index** : **accepté**.
   - « (autre trapèze) » est exact. Comme le cas `"degenere"` est maintenant énuméré en premier, « sinon » aurait été moins clair.
   - « lu par `mw_bootstrap()` seul » est vrai : son seul appel est `R/engine.R:16441`.
   - La ligne des constantes `FORMAT_MENTION_MW_SIGMA_DIRECT_*` (« simulée dans les deux cas avec l'estimateur direct ») est conforme à `.mw_cas_sigma_direct()` et à `mw_bootstrap()`.

## Nature de chaque affirmation (T = 8)

- **(i), (ii) et index** : ce sont des descriptions du code, et elles sont exactes (vérifiées sur `git diff 36e2041 aa4f663 -- R/engine.R`).
- **(iii), « son estimateur direct la garde d'amplitude négligeable »** : approximation numérique bornée. L'estimateur direct est de l'ordre relatif de la tolérance 10⁻¹², par construction de `.mw_colonne_degeneree()`. Ce n'est pas présenté comme exact. « dégénérée dans chaque réplication » reste qualifié de constat de simulation (« mesurée », rubrique 7 de `mw:m1d`).
- **(iii), « cesserait de l'être… probabilité pratiquement nulle »** : raisonnement de même nature que le « Fondement » déjà validé, appuyé par un constat de simulation (0 / 999 sous la règle, T1 et T2). La formulation est prudente et adéquate.
- **`mw:m1d`, rubrique 6** : l'invariance de la p d'Alpha, de la p de famille M1 et de la p globale est exacte, à des égalités près de l'ordre de la tolérance. Le facteur Σ′n_j/Σn_j est commun à A observée et aux A simulées, donc les rangs par réplication sont conservés, et le min P avec eux. Cette invariance suppose que la colonne reste négligeable, ce que la phrase dit (constat de simulation renvoyé à la rubrique 7). La formulation est correcte.
- **`mw:m1d`, rubrique 7** : constats de simulation sur triangles construits, étiquetés « non transposables ». Les valeurs au conditionnel décrivent l'ancienne loi (V0), et l'écart de la p globale est dit « sans sens garanti ». C'est conforme au § 2 de ma lecture.
- **Statut** : niveau non mesuré dans le cas dégénéré. C'est exact, et c'est la limite de validité à T = 8 qui manquait.

## Écart E1 (`docs/latex/CONVENTIONS.md`, l. 64) : **à écarter comme mineur**, critère ADR 0018 : aucun

- Le motif de l'exception de taille de `mw:m1d` cite encore la colonne J−1 « simulée avec la valeur de la règle de minimum (propriété exacte du sens de l'écart …) » et « mesure : 12 799 caractères ». La fiche fait désormais 12 479 caractères.
- `CONVENTIONS.md` n'entre pas dans le champ de E5 : ce n'est ni le `.tex`, ni le PDF, ni le README, ni un texte restitué. Il ne dit rien du code. L'écart n'a d'effet ni sur σ_USP, ni sur un verdict, ni sur une p-value, ni sur la reproductibilité.
- L'exception reste justifiée : 12 479 caractères dépasse 10 500, et les autres motifs (types 4, 6, 11, 12) demeurent.
- La décision PA-2-2 du mainteneur exclut une retouche pour le budget. Je recommande une ligne sous « Constats mineurs écartés (ADR 0018) », avec une mise à jour du motif à la prochaine retouche de `CONVENTIONS.md` pour une autre raison. Le mainteneur décide.

## Constats mineurs écartés (ADR 0018)

- **m-1** — `doc_tests_usp.tex:6605` : le « il » est ambigu (« ce niveau » serait préférable). Style. Critère : aucun.
- **m-2** — `docs/latex/CONVENTIONS.md:64` : motif et compte périmés (E1 ci-dessus). Critère : aucun.
- **m-3** — `doc_tests_usp.tex:21868` : « simulée avec l'estimateur direct si `.mw_simulation_sigma_direct()` est vrai ». C'est vrai, mais la condition est devenue toujours vraie sur un trapèze. Critère : aucun.
- **m-4** — `doc_tests_usp.tex:15800` (« Sur un trapèze, la colonne J−1 fournit des résidus ») et `:16165` (« Il sert aux lignes fondées sur les résidus, au vivier… »). Ces phrases sont générales et ne disent pas l'exception de la colonne J−1 dégénérée, qui n'a aucun résidu retenu. Cette imprécision existait avant le commit, qui ne l'aggrave pas. La règle commune d'exclusion est énoncée dans `sec:mw` et au premier alinéa de `sec:boot-mw`. Critère : aucun ; j'ai examiné E5 et l'écarte pour cette raison.

---

## Retour

- **Statut** : `complet`.
- **Résultat** : **validé**. Les quatre points soumis sont acceptés. Aucun constat bloquant ni majeur. Quatre mineurs à écarter, dont E1.
- **Preuves**
  - *Vérifiées* : `git show a147700 -- docs/latex/doc_tests_usp.tex`, lu en entier ; `sec:boot-mw` relu dans son état final (l. 6535-6606) ; `sec:trapeze-niveau`, l. 16159-16253 : le plan ne comporte pas de colonne J−1 dégénérée ; `mw:m6sig`, l. 19195-19222 ; index, l. 1793-1884 et 1940-1946 ; `git diff 36e2041 aa4f663 -- R/engine.R` ; appels de `.mw_simulation_sigma_direct()` et `.mw_cas_sigma_direct()` : `engine.R:16441`, 13956 et 17457 ; aucun résidu de l'ancien prédicat dans le `.tex` (grep « n'est pas dégénérée », « simulée avec », « tirée avec ») ; textes retirés conservés dans `III-M.md:271` ; chiffres de la rubrique 7 confrontés au tableau (§ 2) et à la remesure de `docwriter` consignée dans `III-M.md` ; ADR 0005, annotation du 26/11/2026 (l. 300-376) ; ADR 0018, critères E1 à E6 (l. 48-59).
  - *Hypothèses* : aucune nouvelle.
  - *Non vérifiées par moi* : la remesure 999 / 999 des réplications dégénérées sur le moteur courant (je m'appuie sur le suivi, sur Gb4 et sur l'égalité Vb = moteur du tableau, sans réexécution) ; les contrôles annoncés par `docwriter` (concordance `--strict`, `controle_doc_nd`, compilation).
- **Informations manquantes** : aucune.
- **Décisions non résolues** : tri de E1 (je recommande de l'écarter) : la session trie, le mainteneur décide.
- **Critères déclenchés** : aucun nouveau ; le niveau à T = 8 dans le cas dégénéré n'est pas mesuré : c'est maintenant écrit au « Statut », déjà signalé à l'étape 5 ; aucun désaccord avec `audit`, un autre expert ou un ADR.
- **Constats hors périmètre** : m-1 à m-4 ci-dessus, tous mineurs, critère « aucun ».
- **Prochaine action recommandée** : consigner ce visa et la ligne des mineurs écartés ; passage de `regulatory` en routine (fait : `regulatory-1-conformite-620.md`) ; revue finale de la règle 10, puis commit du PDF par la session principale avant la sortie du brouillon.
