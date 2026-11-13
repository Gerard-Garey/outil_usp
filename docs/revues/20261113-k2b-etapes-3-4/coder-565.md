Issue #565 : le job « Parité des lecteurs de classeur » est en place dans `.github/workflows/ci.yml`, seul fichier modifié (+168/−3). Rien n'est commité ni poussé. Le diff partiel de la session interrompue était juste et complet. Je l'ai relu et vérifié, et j'ai seulement ajusté un commentaire (mesures des tests).

**Contenu du job `parite-lecteurs` (l. 348 à 507)**
- **Déclenchement** : `needs: changements`, `if: moteur == 'true'`, `ubuntu-22.04`, R 4.3.1, `DATE_INSTANTANE` 2024-02-15, `timeout-minutes: 30`, comme les lots.
- **Paquets** : `shiny` 1.8.0, `plotly` 4.10.4, `openxlsx` et `zip` sont installés depuis l'instantané, avec `actions/cache`.
  - La clé de cache est propre au job (`paquets-parite-…-openxlsx${VERSION_OPENXLSX}-zip${VERSION_ZIP}`).
  - Ainsi `openxlsx` et `zip` n'entrent jamais dans la bibliothèque ni dans le cache des lots.
  - La spec demandait de réutiliser la clé des lots pour `test_application.R` si possible. Je ne l'ai pas fait, et ce n'est pas une limite à signaler : `shiny` et `plotly` sont réinstallés ici, avec cache, donc `test_application.R` tourne.
- **Contrôle des versions** : étape bloquante dans un `Rscript` neuf, `packageVersion()` de `shiny`, `plotly`, `openxlsx` et `zip` contre `VERSION_*`.
  - `VERSION_OPENXLSX` = 4.2.5.2 et `VERSION_ZIP` = 2.3.1 sont commentées « À CONFIRMER par le journal de la première exécution » (instantané Posit inaccessible depuis la session, 403).
- **Même BLAS que les lots** : l'action `./.github/actions/blas-reference` est reprise.
- **Tests** : boucle bash sous `LC_ALL=C.UTF-8` sur `test_controles_entree`, `test_outdec`, `test_defauts_connus`, `test_application`.
  - Tous les fichiers sont exécutés même si l'un échoue.
  - Le journal est conservé et `pipefail` garde le code de sortie de `Rscript`.
  - Le job échoue si `grep -n '\[saute\]'` trouve une ligne, quel que soit le paquet manquant.
  - Une étape finale écrit un bilan dans `$GITHUB_STEP_SUMMARY`.
- **Agrégat `tests-moteur`** :
  - `needs` inclut `parite-lecteurs` ;
  - `PARITE` est ajoutée à l'environnement ;
  - le statut attendu est `$attendu_unitaires` (`success` si le moteur change, `skipped` sinon), comme `UNITAIRES`.
- **Inchangés** : les trois lots (aucun hunk avant la ligne 345, aucun `openxlsx` ni `zip` avant elle), `references.yml` et la table des durées.

**Commandes exécutées et résultats**
Les journaux sont dans `<scratchpad>/ci565/`. Le script `boucle.sh` y reproduit l'étape CI et se lance avec `LC_ALL=C.UTF-8`.
- **YAML** : `python3 -I -c yaml.safe_load` passe.
  - Les jobs sont `changements, tests-unitaires, reproductibilite, ecarts-references, parite-lecteurs, tests-moteur, documentation, fiches-agents`.
  - `tests-moteur.needs` = `[changements, tests-unitaires, reproductibilite, parite-lecteurs]`.
  - Les 9 étapes du job sont bien lues.
  - `actionlint` et `yamllint` ne sont pas installés.
- **`R_LIBS=lib_old:lib`** (openxlsx 4.2.5.2, zip 2.3.1, vérifiés par `packageVersion`) : aucune ligne `[saute]`, `STATUT=0`.
  - `test_controles_entree.R` 403/403, `test_outdec.R` 97/97, `test_defauts_connus.R` 127/127.
- **`R_LIBS=lib`** (openxlsx 4.2.9, zip 3.0.2) : aucune ligne `[saute]`, `STATUT=0`, mêmes totaux 403/403, 97/97, 127/127.
- **`test_application.R`** avec `R_LIBS=lib_old:lib:lib_shiny:lib_app` (shiny 1.14.0, plotly 4.12.1, openxlsx 4.2.5.2, zip 2.3.1) : 224/224, aucune ligne `[saute]`, `STATUT=0`.
  - Les versions de `shiny` et `plotly` ne sont pas celles de la CI (1.8.0 et 4.10.4).
- **Test négatif du critère** : un premier essai avec `lib_old` seul (openxlsx présent mais non chargeable, faute de ses dépendances) a donné 4 lignes `[saute]` dans les 3 fichiers, puis `::error::saute` et `STATUT=1`. Le critère `[saute]` détecte donc un paquet manquant.
- **Lots sans les deux paquets** : `LC_ALL=C.UTF-8 Rscript tests/test_unitaires.R --parallele` donne 3771 assertions, 3771 ok, 0 échec, 0 succès inattendu.
  - Les sept lignes `[saute]` attendues apparaissent : 6 dans `test_controles_entree.R`, 1 dans `test_outdec.R`.
  - C'est le comportement des lots en CI, où ces tests sautent aujourd'hui.
  - Cette mesure locale ne vérifie pas la CI.
- **Concordance** : `LC_ALL=C.UTF-8 Rscript tests/concordance_doc_moteur.R` donne « BILAN : 0 ecart(s) ».

**Surface d'impact documentaire : aucune**
- Le grep du `.tex` sur `ci.yml`, la CI et `openxlsx` ne donne rien qui décrive le job ni les tests de parité en CI.
- Les mentions d'`openxlsx` (l. 883 à 959, 2585 à 2588, 4590) concernent le lecteur, pas la CI.
- Les mentions de la CI (l. 2662 à 2666, « job Tests du moteur ») concernent le BLAS et les références, et restent vraies. Le nom de l'agrégat est inchangé.
- Aucune autre mention de `ci.yml` dans `README.md`, `CONTEXT.md` ni `docs/exigences.md` n'est touchée (le README n'a que le badge).
- Le `.tex` de K3b, ou un passage de `docwriter`, pourrait ajouter « vérifié en CI sous <version du journal> ». C'est prévu dans l'avis d'`actuary` § 9, et la version est à reprendre du journal.

**Message de commit proposé**
```
repo: CI, job « Parité des lecteurs de classeur » (openxlsx et zip), branché à tests-moteur (Refs #565)

Nouveau job parite-lecteurs dans ci.yml : mêmes conditions de déclenchement,
même R et même instantané CRAN que les lots, openxlsx et zip installés avec
cache propre au job (les trois lots restent sans eux, donc exercent toujours
les replis), contrôle bloquant des versions de shiny, plotly, openxlsx et zip.
Exécute test_controles_entree.R, test_outdec.R, test_defauts_connus.R et
test_application.R un par un sous LC_ALL=C.UTF-8 ; échoue si une ligne
« [saute] » apparaît. Branché à l'agrégat tests-moteur (statut attendu success
ou skipped, comme les lots), décision du mainteneur du 13/11/2026 (Q-D).
Mesuré en session sous openxlsx 4.2.5.2 + zip 2.3.1 et sous 4.2.9 + 3.0.2 :
aucune ligne « [saute] ». VERSION_OPENXLSX (4.2.5.2) et VERSION_ZIP (2.3.1) à
confirmer par le journal de la première exécution.

Surface d'impact documentaire : aucune.
Références inchangées (references.yml et lots non touchés).

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_014w4Cra1JGAyptyhUpSL4kt
```

**Points non vérifiés**
- **Versions de l'instantané** : le contenu de l'instantané Posit du 15/02/2024 n'a pas été vérifié (403). Si les versions diffèrent, le contrôle bloquant échoue en le disant et il faut corriger `VERSION_OPENXLSX` et `VERSION_ZIP` d'après le journal.
- **Exécution réelle du job** : le job n'a jamais tourné sur GitHub Actions. La première exécution reste à observer pour :
  - l'installation depuis l'instantané ;
  - le cache ;
  - la durée de `test_application.R` (195 s en CI d'après le commentaire existant) ;
  - le fait que `tests-moteur` voie `PARITE=success`.
- **Dates d'archive CRAN** (openxlsx 4.2.5.2 au 06/02/2023, zip 2.3.1 au 27/01/2024) : reprises de `coder-rejeu-k2b.md` § 5.3, non remesurées.
- **Sept lignes `[saute]` en CI** : le décompte vient de ce même rapport (journaux CI de `8205955`). Le rejeu local sans les paquets les reproduit.
- **`test_application.R` et `test_defauts_connus.R`** n'émettent aucune ligne `[saute]` en CI (la commande `zip` suffit). L'absence de `[saute]` ne prouve donc pas seule que la voie `zip::zipr()` y est exercée. Seul le contrôle des versions garantit la présence du paquet `zip`. Cette réserve figure déjà dans `coder-rejeu-k2b.md` § 5.2.
- **Doute pour `actuary`** : aucun sur le fond.

Fichier modifié : `/home/user/outil_usp/.github/workflows/ci.yml`.

---

Les deux constats de l'audit léger sont repris dans `/home/user/outil_usp/.github/workflows/ci.yml` (seul fichier touché), sans commit. Le YAML est revalidé : `yaml.safe_load` passe et les 8 jobs sont toujours lus.

**Diff des deux points** (les numéros de ligne cités dans le commentaire viennent de votre message ; je ne les ai pas relus dans les fichiers de tests).

1. Commentaire de l'étape « Contrôle des paquets R » (l. 452-457 environ). Il ne se trouve pas au niveau du job mais juste avant cette étape.
```
-      # openxlsx et zip : sans lui, un paquet absent ferait sauter ses tests,
-      # ce que le critère « aucune ligne [saute] » attraperait plus loin, mais
-      # une version différente de celle attendue passerait inaperçue.
+      # openxlsx et zip : c'est lui qui empêche un paquet absent de faire sauter
+      # des tests, et lui seul pour les voies qui sautent sans écrire « [saute] »
+      # (test_outdec.R l. 198-199, test_application.R l. 970, 1035-1039, 2043) ;
+      # le grep de l'étape des tests n'attrape que les lignes « [saute] »
+      # explicites. Il détecte aussi une version différente de celle attendue.
```

2. Étape « Bilan (résumé du job) ».
```
-            grep -E '^(=== |Bilan|TOTAL|Duree|Fichiers en echec)|\[saute\]' "$RUNNER_TEMP/parite_lecteurs.log" || true
+            grep -E '^(=== |TOTAL|ECHEC$)|assertions :|\[saute\]' "$RUNNER_TEMP/parite_lecteurs.log" || true
```

**Vérification du bilan.** J'ai appliqué ce motif aux journaux réels du scratchpad. Le résultat est `cat old.log app.log | grep -E '^(=== |TOTAL|ECHEC$)|assertions :|\[saute\]'`, avec `old.log` et `app.log` dans `<scratchpad>/ci565/`. Chaque fichier lancé seul affiche son en-tête, sa ligne « N assertions : … » avec la durée, et sa ligne `TOTAL` :
```
=== tests/unitaires/test_controles_entree.R ===
   403 assertions : 403 ok, 0 echec(s), … (135.7 s)
TOTAL : 403 assertions, 403 ok, …
=== tests/unitaires/test_outdec.R ===
   97 assertions : 97 ok, … (22.9 s)
TOTAL : 97 assertions, …
=== tests/unitaires/test_defauts_connus.R ===
   127 assertions : 127 ok, … (98.1 s)
TOTAL : 127 assertions, …
=== tests/unitaires/test_application.R ===
   224 assertions : 224 ok, … (189.2 s)
TOTAL : 224 assertions, …
```
Aucune ligne `[saute]` dans ces journaux.

**Non vérifié.** Aucun journal du scratchpad ne contient de ligne `ECHEC` seule. Je n'ai donc pas contrôlé que ce terme du motif (`ECHEC$`) capte quelque chose en cas d'échec.
