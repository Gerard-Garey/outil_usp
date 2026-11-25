# JS2, étape 7 : visa du diff du `.tex` (`3a0e922..422aedc`)

*Rédigé par l'agent `actuary-approfondi` (IA), le 25/11/2026. Versé par la session principale (Q-54-10), texte du rapport, seule la section « Retour » étant resserrée. Lecture seule sur `claude/jalon-js2`, tête `422aedc`, arbre propre ; aucune écriture dans le dépôt ni sur GitHub.*

## Synthèse (session principale)

- **Verdict : visa**, hors préambule ; aucun bloquant, aucun majeur.
- Plage du visa identique, octet pour octet, à `git diff main...HEAD -- docs/latex/` : le visa vaut pour tout le `.tex` de la branche, hors préambule.
- Point 1 (p-value 0,514 non reproduite) : le moteur de `19e47fc` (fusion de Fq) donnait déjà 0,024 ; chiffre inexact dès sa publication ; retiré par la branche ; pas de constat à garder.
- Point 2 (p de famille M1 et p globale) : pas de réserve exigée dans JS2 ; commentaire recommandé sur #620, soumis au mainteneur.
- Préambule : second regard à la revue finale, après les étapes 4a et 4b.
- Huit mineurs écartés (ADR 0018), repris au corps de la PR #619.

## Rapport

### Verdict : **visa**

Le diff ne contient ni bloquant ni majeur, donc aucun texte de remplacement n'est à fournir. Je recommande deux actions, qui ne conditionnent pas le visa (§ 2 et § 3).

**Périmètre.** `git diff main...HEAD -- docs/latex/` est identique, octet pour octet, à `git diff 3a0e922 422aedc -- docs/latex/` (`diff` vide, vérifié). Ce visa vaut donc pour tout le `.tex` de la branche, hors préambule.

### 1. Contrôle des trois commits

**`dfccd09`, `mw:m1d`, rubriques 6 et 7 (l. 17288-17305 et 17360-17368).**
- Le texte reprend mot pour mot mes § 3.1 et 3.2. Seul écart : « avec un » devient « avec » en rubrique 7, sans conséquence.
- Les statuts sont ceux du § 3.3 : propriété exacte du sens de l'écart ; « en général plus dégénérée » et « amplitude négligeable » sont des énoncés structurels ; « dégénérée » est réservé aux réplications mesurées ; grandeur, niveau et puissance sont dits non transposables ou non mesurés.
- Aucun chiffre n'est cité à la fois en rubrique 6 et en rubrique 7 (grille, type 6).
- Chiffres recoupés sur `sortie_mesure_617.txt` :
  - règles de minimum 0,14193 et 0,68446 ;
  - σ̂² de T0 égal à 7,83·10⁻²⁹ pour j = 2 et j = 4, que le texte arrondit à « voisin de 10⁻²⁸ » ;
  - p-values 0,008 / 0,007 et 0,023 / 0,010 ;
  - 8×6 avec trois facteurs, 8×5 avec quatre.
- Le texte concorde avec `sec:boot-mw` (l. 6563-6575) : une colonne J−1 dégénérée, ou celle d'un carré, est simulée avec la valeur de la règle.

**`dfccd09`, `sec:mwm1` (1), l. 16409-16411.** C'est le texte que je proposais pour le constat E5 : il est conforme.

**`dfccd09`, condensation de `mw:m1id`.** Vérifiée passage par passage. Aucun fond, aucun statut épistémique ni aucune réserve n'est perdu :
- **Multiplicateurs.** La colonne m_{n_j} du tableau de la rubrique 3 (l. 17437-17441) porte exactement les valeurs 2,905 / 3,040 / 3,299 / 3,979 / 8,192. Leur statut (« calcul numérique… arrondies au millième ; exactes sous ce modèle gaussien à paramètre vrai ») reste en rubrique 6 (l. 17487-17489).
- **« Il dépasse 20 % dans chaque colonne ».** Exact : le minimum du tableau vaut 23 %, ce qui fonde toujours « n'y écarte pas une ordonnée d'un cinquième ».
- **Exemple chiffré de la rubrique 4 (facteur 1,93).** La propriété (ii) reste avec sa formule exacte (l. 17461-17466), de même que la réserve de Jensen et la portée limitée à l'espérance du carré. L'exemple est versé au suivi, remesuré : 0,7120919 → 1,370803, facteur 1,925 (grille, type 7).
- **Taux 0,211 et 0,187.** La série 0,695 / 0,343 / 0,211 / 0,187 / 0,157 est monotone : « 0,695 (j = 0) à 0,157 (j = 4) » est exact. Le taux qui porte la conclusion, 0,343 en colonne 1, reste. La source T7 (d) est citée et les deux taux sont au suivi.
- **CV_j.** Les chiffres retirés (0,063, 0,683, 0,229, 1,000) sont dans la rubrique 7 de `mw:m1a` (alinéa « Rôle de la dispersion intra-colonne »).
- **Mesures de contrôle.** `Rscript tests/controle_doc_nd.R` : `mw:m1d` p. 370-372, 12 799 caractères sur 12 800 ; `mw:m1id` p. 372-374, 10 886 caractères ; 0 violation (`.log` postérieur au `.tex`). `concordance_doc_moteur.R --strict` : 0 écart.

**`34d07f0`.** Hors visa. Une remarque mineure (m6).

**`422aedc`, `sec:trapeze-niveau` (l. 16179-16183).**
- Phrase exacte : l'en-tête de `docs/tableaux/20261123-issue612-simulation-jm1-trapeze.md` porte les md5 `5bffa722…` (moteur) et `1e320e8e…` (script) et l'arbre `d6ff884`.
- Le journal montre une exécution complète à cet état.
- « Notamment » couvre le contrôle (m), qui n'est pas nommé.
- Aucune vie du dépôt dans le `.tex`.

### 2. Point 1 de docwriter (0,514 contre 0,024) : suffisant, pas de constat à garder

- Reproduit : **0,024 (ECHEC), A = 0,005283677** à la tête de branche, sur le triangle `td` de `tests/unitaires/test_merz_wuthrich_suite.R:1477` (`reserve2`, B = 999, graine 20260831).
- `R/` de `19e47fc` (fusion de Fq), extrait par `git archive` : **le moteur y donne déjà 0,024**, avec la même statistique, alors que le `.tex` de ce commit écrit 0,514 (l. 16334).
  - Le chiffre était faux dès sa publication : ce n'est pas une dérive du moteur depuis Fq.
  - Clone superficiel (limite à `19e47fc`) : l'origine (autre triangle, état intermédiaire de Fq ou erreur de transcription) n'est pas retrouvable.
- Classement ADR 0018 : E5, phrase fausse déjà corrigée par la branche (chiffre retiré) ; E6, non (aucune affirmation actuelle n'en dépend ; le constat qualitatif est reproduit). Pas d'issue.
- Complément facultatif au suivi `III-M.md`, entrée `mw:m1d`, à la place de « (origine non établie : triangle ou état du moteur de la mesure de Fq) » :
  > « Le moteur de `19e47fc` (fusion de Fq), dont le `.tex` citait déjà 0,514, donne 0,024 sur ce triangle (actuary, visa de l'étape 7 de JS2) : le chiffre était inexact dès sa publication, et non rendu faux par une évolution du moteur ; origine non retrouvable dans l'historique disponible. »

### 3. Point 2 de docwriter (p de famille et p globale) : pas de réserve exigée dans JS2

- « Membre… de la p de famille de M1 et de la p globale… ; verdict inchangé » est la phrase type de la grille (type 9) : l'appartenance ne change pas le verdict de la ligne. Elle reste vraie et ne dit rien de l'effet de la colonne J−1 : ce n'est pas une affirmation fausse (E5).
- Le fond reste réel : minP (`fiche:p-famille`) range m(0) parmi des m(i) calculés sur les réplications ; dans le cas J−1, l'échangeabilité du membre Alpha est rompue ; la « propriété dans le cas idéal » ne vaut donc plus ; le sens de l'effet est plausiblement conservateur, mais **non exact** (les rangs des réplications changent aussi).
- Ces deux p-values sont des diagnostics sans verdict. La mesure est prévue par #620, critère 4, décidée (E-25/11 (JS2, 2c), (i)). La fiche n'a plus de marge (12 799 sur 12 800).
- **Recommandation, à faire par la session avec l'accord du mainteneur.** Le critère 5 de #620 ne couvre que les pistes (a) et (b) ; une fermeture en statu quo (c) laisserait la fiche sans cette réserve. Commentaire proposé sur #620 :
  > « Quelle que soit la piste retenue, (c) comprise, la fiche `mw:m1d` (rubrique 6) dit l'effet mesuré de la colonne J−1 sur la p de famille M1 et la p globale (critère 4), ou, à défaut de mesure, qu'il n'est pas mesuré ; une fermeture `not planned` reste subordonnée à cette phrase. »

### 4. Préambule (hors visa)

`\versiondoc` 4.6, `\datedoc` « 25 novembre 2026 », `\dateconsultation` « 18 novembre 2026 ». `\versiondoc` devrait changer ; `\dateconsultation` porte une affirmation sur les sources (E11, Q-74-9). Second regard utile à la revue finale (session et `docwriter`), contre le compte rendu de consultation de l'étape 4 ; pas de nouveau visa d'`actuary`, sauf si la consultation change la lecture d'une source (`regulatory`, puis `actuary`).

### Constats mineurs écartés (ADR 0018)

- `docs/latex/doc_tests_usp.tex:17364` (`mw:m1d`, r7) — « p-value inchangée sans la colonne » au singulier ; sur T0, les colonnes j = 2 et J−1 ont été retirées ensemble ; le constat vaut pour ce retrait conjoint — aucun critère.
- `doc_tests_usp.tex:17400` (`mw:m1id`, r1) — « ni débordement » retiré ; la justification du suivi (positivité des termes) ne couvre que l'annulation ; aucun résultat en cause — aucun critère.
- `doc_tests_usp.tex:17380` (`mw:m1id`, r1) — place de la ligne « juste après la famille α » retirée du `.tex` (mécanique, type 5 ; décision Q-D1-Fj-1 au suivi) — aucun critère.
- `doc_tests_usp.tex:17400, 17415, 17481, 17492, 17515` — lignes de source de 132 à 160 caractères, saut de paragraphe supprimé avant « Lecture de e_a » ; PDF non affecté — aucun critère.
- `doc_tests_usp.tex:17362` — le « triangle de six années » n'est plus identifié dans la fiche ; le suivi le désigne (`td`) — aucun critère.
- `tests/controle_doc_nd.R:137` (m6) — la `raison` de `mw:m1d` n'est pas alignée sur `CONVENTIONS.md` (colonne J−1 du trapèze) ; sans effet sur le contrôle — aucun critère.
- `doc_tests_usp.tex:16180` — « ne se refait qu'à cet état » un peu strict : un état antérieur à `414e723` pourrait passer les contrôles ; l'état identifié fait foi — aucun critère.
- `mw:m1d` à 12 799 caractères pour 12 800 : toute addition exigera une condensation ou une nouvelle décision de budget — aucun critère (information).

### Retour

- **Statut** : `complet`.
- **Preuves vérifiées** : diff lu en entier ; textes comparés à `actuary-2-lecture-617.md` § 3.1-3.2 ; chiffres recoupés sur `sortie_mesure_617.txt` ; tableau de `mw:m1id` ; rubrique 7 de `mw:m1a` ; en-tête de `20261123-issue612-…md` ; `controle_doc_nd.R` 0 violation ; concordance 0 écart ; p d'Alpha 0,024 sur `td` à la tête et à `19e47fc` ; `.tex` de `19e47fc` citant 0,514 ; #620 relue (critères 4 et 5).
- **Hypothèse** : effet de la colonne J−1 sur la p de famille plausiblement conservateur, non exact.
- **Non vérifiés** : p d'Alpha sans la colonne sur `td` (0,024 selon `docwriter`) ; origine de 0,514.
- **Décisions non résolues** : commentaire sur #620 (§ 3) et complément au suivi (§ 2), au mainteneur.
- **Critères déclenchés** (routage, § 4) : aucun.
