<!-- Rapport d'audit (revue finale complète, règle 10, effort high) de git diff main...HEAD à 98a2be6, versé tel quel le 26/11/2026. -->

## Revue finale complète (règle 10) : `claude/outillage-ci-et-controles`, PR #626, tête `98a2be6`, 27 commits depuis `b084e13`

**Verdict : conforme avec réserves.** Le code est correct et ne change aucun résultat. Un constat majeur reste ouvert : le critère d'acceptation de #561 n'est pas tenu sur les mesures de CI de la branche. Le mainteneur doit trancher avant la sortie du brouillon, car le PR ferme #561 par `Closes`. Je n'ai rien écrit dans le dépôt : `git status` est vide, la tête est inchangée et le md5 de `R/engine.R` vaut toujours `c7b767f5…`. Toutes les exécutions ont eu lieu sur une extraction `git archive` dans le scratchpad, sauf les essais de garde de M3 faits sur un clone `git clone` dans le scratchpad.

### Constat majeur

**M1 — #561 : l'écart entre lots reste au-dessus de 20 % sur les exécutions de CI de la branche.**
- **Emplacements** : `tests/durees_unitaires.tsv` et `tests/test_unitaires.R:168` (`repartir_lots()`). Critère dans le corps de #561 (« écart entre lots < 20 % ») et dans la fiche S8, étape 4 (« sur trois exécutions de CI »).
- **Mesure** : durée de l'étape « Tests unitaires » de chaque lot, lue par `gh api …/runs/ID/jobs`, champs `.steps[]`. L'écart est calculé comme (max − min) / min, la définition de la fiche (14,6 % à `b084e13`).

| Exécution | Commit | Lots 1 / 2 / 3 (s) | Écart |
|---|---|---|---|
| 45867317144 | `98a2be6` | 248 / 184 / 279 | **51,6 %** |
| 45864547432 | `e0b023b` | 212 / 364 / 250 | 71,7 % |
| 45863204435 | `c988258` | 345 / 290 / 248 | 39 % |
| 45860635793 | `08fceb7` | 267 / 200 / 376 | 88 % |
| 45859308537 | `3eb82c6` | 338 / 297 / 355 | 19,5 % |

- **Cause** : ce n'est pas un défaut du procédé.
  - Avec la table de `98a2be6`, les charges estimées par `repartir_lots()` valent 1145 / 1146 / 1145 s, soit 0,1 % d'écart.
  - L'écart réel vient de la vitesse variable des runners. L'en-tête de la table l'écrit lui-même : rapport à la moyenne « de 0,5 à 1,4 ».
  - Seule l'exécution de `98a2be6` utilise la table finale (`b679be4`) : les trois exécutions demandées n'existent pas encore.
- **Ce qui est tenu** : le job témoin n'est plus le chemin critique (262 s contre 336 s pour le lot le plus long à `98a2be6`).
- **À trancher par le mainteneur** :
  - accepter le critère comme non mesurable tel quel et le reformuler (par exemple sur les charges estimées, ou sur la somme des durées par fichier d'une même exécution) ;
  - ou passer #561 en `Refs` ;
  - ou attendre trois exécutions sur la table finale.

  `coder` ne peut pas corriger ce point.

### Constats mineurs

**m1 — `tests/controle_doc_nd.R:170` (`.ligne_definition`) : un `%` dans un `\url` ou `\href` avant un mot de définition crée un faux positif A1.**
- **Mesure** : `nd_chercher()` sur `\url{https://ex.org/a%20b}\newcommand{\z}[1]{#12}` donne `A1 #12` à la tête de branche et rien sur `main`. Même résultat pour `\href{https://ex.org/a%20b}{lien} \def\z#1{#10}` et pour `\verb|%| \newcommand{\z}[1]{#12}`.
- **Cause** : le balayage s'arrête au premier `%`, même dans un argument d'URL. La règle d'ouverture de commentaire de la regex 3 et de `CONVENTIONS.md` § 5 exclut pourtant ce `%` (« ni placé dans l'argument d'un `\url` ou d'un `\href` »).
- **Portée** : faux positif seulement (sens strict), absent des « Limites » ; aucun effet sur le `.tex` actuel (sortie identique à `main`).
- **Correction** : ajouter `.arg_url` comme première alternative du groupe possessif, `(?:\\(?:url|href)\{[^}]*\}|[^\\%]|(?!\\def\b)\\.)*+`, avec un cas de test ; ou écrire la limite dans `CONVENTIONS.md`.

**m2 — `tests/test_unitaires.R:207` : message de refus imparfait.**
- `--fichiers=,` et `--fichiers=test_outdec,,` impriment « fichier(s) repete(s) : » suivi de noms vides, en plus de « nom vide ».
- Le refus lui-même est correct (code 1).
- **Correction** : `.repetes <- unique(.noms[!.vides & duplicated(.complets)])`.

### Vérifications exécutées

- **Invariant de branche** : `git diff b084e13 HEAD --stat -- R/ app.R DESCRIPTION tests/reference/ tests/donnees/ tests/outils_tests.R` est vide.
- **Batteries** (sous `LC_ALL=C.UTF-8`, openxlsx, zip, shiny et plotly installés) :
  - `test_unitaires.R --parallele` : 63 fichiers, 4 625 assertions, 0 échec, 0 xfail, 0 XPASS, aucune ligne `[saute]`, code 0 ;
  - `test_reproductibilite.R` : 7 cas CONFORMES, écart maximal 0, code 0 ;
  - `concordance_doc_moteur.R --strict` : 0 écart, code 0 ;
  - `controle_doc_nd.R` : 0 occurrence, code 0 ;
  - CI de `98a2be6` : verte.
- **Contrôle ND** : sortie identique à celle de `main` sur le même `.tex`, chemin mis à part (diff de `nd_main_out.txt` et `nd_head_out.txt`).
- **Aucune assertion perdue** :
  - Comptes par fichier, CI `main` 45818263273 contre CI `98a2be6` (4 565 → 4 609 assertions). Tous les écarts sont expliqués :
    - application : 298 → 188 + 111 (garde Shiny coupée en 78 + 110) ;
    - controles_entree : 636 → 518 + 117 (un retrait couvert) ;
    - p_mc_regime : 79 → 32 + 47 ;
    - enveloppe_spread : −1 ; incertitude_bootstrap : −1 ;
    - controle_doc_nd : +46 ;
    - defauts_connus (127), merz_wuthrich (112) et suite (160) : inchangés.
  - Noms statiques des assertions, `main` contre tête de branche : multi-ensembles identiques, hors ces seuls écarts.
  - Les trois coupes sont sans perte de ligne : multi-ensemble des lignes de l'original contre les deux parties, rien ne manque.
  - Les 20 blocs `testServer` sont identiques au caractère près, 6 dans la partie 1 et 14 dans la partie 2 ; aucune dépendance entre blocs rompue (analyse des symboles libres).
  - Aucun `echec_attendu` dans les parties coupées.
- **Couvertures citées pour les retraits** :
  - `test_reproductibilite.R` compare l'objet entier, `plots_data`, `ic_bootstrap`, `parametre_final` et `bootstrap$sigma_boot` compris : `INSTABLES` est vide et `EXCLUS_AJUSTEMENT` ne vise que `ajustement` ; `R7` y est construit par `executer_cas` ;
  - l'assertion `usage_accepte("alpha", list(0.05, 0.10, 0.29))` à `B_MIN_USAGE` = 99 couvre le retrait de la l. 1398.
- **Lignes `[saute]` des lots** : les 9 mêmes lignes, triées, sur `main` et à `98a2be6`.
- **Job témoin à `98a2be6`** :
  - 6 fichiers, 1 180 assertions, nombre égal à celui du témoin avant la branche ;
  - 535 contre 518 dans le lot : les 17 assertions propres au témoin sont gardées ;
  - aucun `[saute]` ;
  - tous les fichiers qui exigent openxlsx ou zip y sont, sauf `trapeze` (H1, déjà écarté).
- **`--fichiers`** : dix cas de refus essayés (vide, virgules, inconnu, répété avec ou sans `.R`, option répétée, avec `--lot`, avec dossier, `.r`) : tous refusés, code 1.
- **Table des durées** : `calculer_durees_unitaires.R` rejoué sur les 5 exécutions citées (sortie dans le scratchpad) : table identique à l'octet à `tests/durees_unitaires.tsv`.
- **`CONVENTIONS.md`** : regex d'A1 (5), d'A12 (5) et d'A10 (4) identiques à `MOTIFS_A` ; `fenetre2` = 5 (A1) et 2 (A12) ; compte de `mw:m1d` de 12 479 caractères, conforme à la sortie du contrôle ; le libellé « estimateur direct » est conforme au `.tex`, l. 17304 et 17370.
- **#470** :
  - md5 du script à `08fceb7` et à la tête de branche : `29d7635c…`, celui que cite le tableau ;
  - synthèse du tableau du 26/11 identique ligne à ligne à celle du 06/11 ;
  - `--ecrire` refusé avant tout calcul, code 1, dans cinq situations : hors git, arbre modifié, copie non suivie dans `tests/`, copie hors du dépôt, avec `--pilote`.
- **Règles de commit** :
  - la commande grep des mots-clés de fermeture sur `git log main..HEAD --format=%B` ne trouve rien ;
  - préfixes conformes aux fichiers de chaque commit ;
  - auteur `Claude <noreply@anthropic.com>` partout ;
  - un commit `tests:` par proposition ;
  - `ci.yml` valide en YAML.
- **Constats des audits légers précédents** : je n'ai pas les rapports où m1 à m6, C1 à C5 et M1, M2 sont numérotés. Je n'ai donc pas pu rapprocher chaque identifiant. J'ai seulement constaté les points vérifiables :
  - m5 du contrôle ND : `issues?+` possessif, testé, et `CONVENTIONS.md` aligné en `98a2be6` ;
  - les six constats de forme de #470 ;
  - la garde sur le fichier réellement exécuté (`08fceb7`) ;
  - l'acceptation d'une exécution seulement si tous ses lots ont réussi (`9a23529`) ;
  - les commentaires de `ci.yml` (`12251b8`).
- **Hors constat** :
  - Après les retraits de `test_enveloppe_spread.R` et `test_incertitude_bootstrap.R`, le poste Windows ne contrôle plus ces champs que par `test_reproductibilite.R`, jugé à la main selon le critère de l'annotation de l'ADR 0006. La couverture existe toujours.
  - Les `run_engine` mis en mémoire hors de `verifier()` (`r_cred16`, `res_tri_ref`, `r_def_run`) : une erreur ferait échouer tout le fichier au lieu d'une seule assertion. L'échec reste compté ; rien n'est perdu.

### Hors périmètre (ADR 0018)

Aucun constat. `test_affichage_regime_t8.R` compte 73 assertions en local contre 74 en CI : c'est l'absence de git dans l'extraction `git archive` (bloc conditionné par `.git_ok`, l. 154), pas un défaut. Critère : aucun.

### Questions pour `actuary`

Aucune. Aucun `detail` ni aucune `reference` du registre n'est touché, puisque `R/` ne change pas. Le seul changement de fond du script #470 est dans `resume_rho()` : la paire et le seuil imprimés sont désormais ceux du max |ρ| et non plus ceux du max de ratio. Il ne change aucun chiffre du tableau, le nombre de triangles admis étant le même (100 000) pour toutes les paires.

### Fichiers utiles

- Journaux des batteries : `/tmp/claude-0/-home-user-outil-usp/b03583ae-874e-5b98-83fb-1e4a3633d356/scratchpad/unit_head.log`, `/tmp/claude-0/-home-user-outil-usp/b03583ae-874e-5b98-83fb-1e4a3633d356/scratchpad/repro.log`, `/tmp/claude-0/-home-user-outil-usp/b03583ae-874e-5b98-83fb-1e4a3633d356/scratchpad/conc.log`, `/tmp/claude-0/-home-user-outil-usp/b03583ae-874e-5b98-83fb-1e4a3633d356/scratchpad/nd.log`
- Table rejouée : `/tmp/claude-0/-home-user-outil-usp/b03583ae-874e-5b98-83fb-1e4a3633d356/scratchpad/durees_rejeu.tsv`
- Comparaison du contrôle ND : `/tmp/claude-0/-home-user-outil-usp/b03583ae-874e-5b98-83fb-1e4a3633d356/scratchpad/nd_main_out.txt`, `/tmp/claude-0/-home-user-outil-usp/b03583ae-874e-5b98-83fb-1e4a3633d356/scratchpad/nd_head_out.txt`
- Code concerné : `/home/user/outil_usp/tests/controle_doc_nd.R`, `/home/user/outil_usp/tests/test_unitaires.R`, `/home/user/outil_usp/tests/durees_unitaires.tsv`
