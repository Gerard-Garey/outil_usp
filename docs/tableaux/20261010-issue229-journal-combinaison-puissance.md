# Journal de la branche de sauvegarde de #229

Branche de sauvegarde (ADR 0007, annotation du 9 octobre 2026), créée depuis le commit mesuré `9279266` de la branche de travail `claude/mesure-p-conditionnelle` (PR #238). Aucune PR, jamais fusionnée ; supprimée après le commit unique des sorties définitives sur la branche de travail. Contenu : `sauvegarde/issue229/` seulement.

Moteur : md5 de `R/engine.R` 95a48eaf3588a58c507299954597fef1 ; empreinte sans commentaires (#231) 46fe1025c2c4a6f241822a89e74b4c06.

## Étape 4 : grille semi-analytique

- Commande (worktree détaché à `9279266`, R 4.3.3, 4 vCPU, `LC_ALL=C.UTF-8`) : `Rscript tests/grille_regime_t8.R --coeurs 4 --ecrire --brut <hors dépôt>/20261009-issue229-grille-brut.tsv`
- Début (UTC) : 2026-10-09T22:59:39Z
- Fin (UTC) : 2026-10-09T23:08:50Z, code 0 (environ 9 min d'horloge sur 4 cœurs).
- Valeurs brutes : `20261009-issue229-grille-brut.tsv`, md5 160d45911cfa25250c14a0e7c31aeb23, 10 049 053 octets (L12 : versionnées ici en attendant l'accord du mainteneur).
- Tableau : `docs/tableaux/20261009-issue229-grille.md`, md5 60528d7823364500cb3475ded8fa8c22, commité sur la branche de travail.
- Journal d'erreur : `grille.err.txt`.

## Brouillons (protection contre la perte du conteneur)

- 2026-10-09T23:42:41Z : redémarrage du conteneur pendant l'écriture du script de l'étape 5. Copie du brouillon non audité `tests/p_conditionnelle_regime_t8.R` (2 088 lignes) et du diff non commité des tests (`etape5-tests.diff`, base `ba630a0`) dans `brouillons/`. Ces fichiers ne sont pas des résultats ; ils ne font foi qu'une fois commités sur la branche de travail après audit.

## Étape 4 bis : grille relancée après la décision A2 (A8 → A4)

- Commande : même commande, worktree détaché à `4a1dc99`, `TZ=UTC` ; début 2026-10-10T00:00:09Z, fin 2026-10-10T00:07:20Z, code 0, bilan OK.
- Valeurs brutes : `20261010-issue229-grille-brut.tsv`, md5 5fd8d9630dd8518c6add582054c77098, 10049330 octets.
- Tableau : `docs/tableaux/20261010-issue229-grille.md`, md5 ba5e29a2aa3d727b4c4ffa61d11de05f, commité sur la branche de travail. Acceptation (A2) : ligne des intensités non déclenchée ; md5 ε et Y de A4 conformes ; seules diffèrent de la grille du 09/10 les durées et les cellules de la famille A et des agrégats de P.

## Étape 6 : mesure emboîtée (T0 à T3 sur J1, J2, J3, puis partie P)

- Commit mesuré : `fee9968a6cda9f7e7397683b81d01e1648939093` (worktree détaché, arbre propre ; branche de travail `claude/mesure-p-conditionnelle`). Cette branche de sauvegarde a été créée plus tôt depuis `9279266` ; son contenu est indépendant du code mesuré.
- Plateforme : R 4.3.3, Ubuntu 24.04, BLAS et LAPACK de référence 3.12.0, 4 vCPU ; `LC_ALL=C.UTF-8`, `TZ=UTC`.
- md5 `R/engine.R` : 95a48eaf3588a58c507299954597fef1 ; md5 du script `tests/p_conditionnelle_regime_t8.R` : 6c047bafbff524547046fde278bf0d13.
- Empreinte sans commentaires : 46fe1025c2c4a6f241822a89e74b4c06
- Pré-vol (`--prevol`, J1, J2, J3, R = 2 000) : aucune erreur sur les six fonctions (sorties dans `preparation/`).
- Débit P4 : J2 intérieur, 3 réplications par exécution, durée moyenne par réplication 13,06 s à 1 exécution, 12,10 à 12,70 s à 2, 12,65 à 13,35 s à 3, 12,91 à 13,27 s à 4 exécutions concurrentes (horloge 51 à 54 s pour chaque k) : débit agrégé proportionnel au nombre de tranches jusqu'à 4 ; 4 tranches concurrentes retenues. Estimation (coder, sur ces coûts) : 32 à 35 h CPU, environ 9 à 10 h d'horloge, sous le plafond de 54 h fixé par le mainteneur.
- Lanceur : `bash sauvegarde/issue229/lancer.sh <wt-mesure> <wt-sauvegarde> 4` (idempotent ; reprise par --reprendre) ; synchronisation : `bash sauvegarde/issue229/synchro.sh <wt-sauvegarde> 600`.
- Lancement : 2026-10-10T01:11:52Z.

### Tranches terminées
- Incident : redémarrage du conteneur vers 01:19-01:28 UTC (processus arrêtés à 01:18:41, environ 5 min après la fin du tour de la session : récupération pour inactivité probable). Tranches J2 1 à 4 partielles (29 à 31 réplications chacune), poussées ; relance à 2026-10-10T01:29:05Z par le lanceur, qui reprend chaque tranche partielle par --reprendre. Parade : une tâche de surveillance suivie par la session reste active pendant toute la mesure.
- Tranche J2-03de08.txt : md5 795cd0bd71fc33d1cfc116bf2c8c653a, debut 2026-10-10T01:29:05Z, fin 2026-10-10T02:04:37Z, code 0 (options : --jeu J2 --reprendre /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/tranches/J2-03de08.partiel1.txt)
- Tranche J2-02de08.txt : md5 9d780994a92f8b02a7b32adf3f71b6e0, debut 2026-10-10T01:29:05Z, fin 2026-10-10T02:04:42Z, code 0 (options : --jeu J2 --reprendre /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/tranches/J2-02de08.partiel1.txt)
- Tranche J2-01de08.txt : md5 70b33502fe0c9b933373682b4a99c289, debut 2026-10-10T01:29:05Z, fin 2026-10-10T02:05:34Z, code 0 (options : --jeu J2 --reprendre /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/tranches/J2-01de08.partiel1.txt)
- Tranche J2-04de08.txt : md5 160abcc82a2452651603136be4e30c3a, debut 2026-10-10T01:29:05Z, fin 2026-10-10T02:05:58Z, code 0 (options : --jeu J2 --reprendre /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/tranches/J2-04de08.partiel1.txt)
- Tranche J2-05de08.txt : md5 2b29bf13c83dca5be1d0f7ae206b3d12, debut 2026-10-10T02:04:37Z, fin 2026-10-10T02:44:43Z, code 0 (options : --jeu J2)
- Tranche J2-07de08.txt : md5 6031b5625e5d505f43097f0c51613689, debut 2026-10-10T02:05:34Z, fin 2026-10-10T02:46:25Z, code 0 (options : --jeu J2)
- Tranche J2-06de08.txt : md5 2744e8f1200c294f5be6cb54ed161777, debut 2026-10-10T02:04:42Z, fin 2026-10-10T02:46:31Z, code 0 (options : --jeu J2)
- Tranche J2-08de08.txt : md5 c1d18a8e9267030b6c552f35199681ac, debut 2026-10-10T02:05:58Z, fin 2026-10-10T02:46:34Z, code 0 (options : --jeu J2)
- Tranche J3-01de08.txt : md5 2250094ff6e03853a2789ef416db74d9, debut 2026-10-10T02:44:43Z, fin 2026-10-10T03:26:03Z, code 0 (options : --jeu J3 --grille-brut /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv)
- Tranche J3-02de08.txt : md5 3044ca2769cd91775d6db2ea06433f9a, debut 2026-10-10T02:46:25Z, fin 2026-10-10T03:26:48Z, code 0 (options : --jeu J3 --grille-brut /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv)
- Tranche J3-04de08.txt : md5 6fff9ba3335cd6076dbc4475d6495243, debut 2026-10-10T02:46:34Z, fin 2026-10-10T03:26:52Z, code 0 (options : --jeu J3 --grille-brut /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv)
- Tranche J3-03de08.txt : md5 510918c5e785c6abb66829ca25fcd878, debut 2026-10-10T02:46:31Z, fin 2026-10-10T03:27:04Z, code 0 (options : --jeu J3 --grille-brut /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv)
- Tranche J3-05de08.txt : md5 a2632a0b808c56857edd9b88753f9ae4, debut 2026-10-10T03:26:03Z, fin 2026-10-10T04:06:53Z, code 0 (options : --jeu J3 --grille-brut /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv)
- Tranche J3-06de08.txt : md5 95aa3500bff7c18bfbae067aa72d0c7b, debut 2026-10-10T03:26:48Z, fin 2026-10-10T04:07:25Z, code 0 (options : --jeu J3 --grille-brut /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv)
- Tranche J3-07de08.txt : md5 498760ae0d56331aa8e2acac71d786a4, debut 2026-10-10T03:26:52Z, fin 2026-10-10T04:07:34Z, code 0 (options : --jeu J3 --grille-brut /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv)
- Tranche J3-08de08.txt : md5 75379b52dc9527fe43506353a8b8d397, debut 2026-10-10T03:27:04Z, fin 2026-10-10T04:08:11Z, code 0 (options : --jeu J3 --grille-brut /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv)
- Tranche J1-01de08.txt : md5 1d48124b642e13442c4781f4a8fa8b2b, debut 2026-10-10T04:06:53Z, fin 2026-10-10T04:51:14Z, code 0 (options : --jeu J1)
- Tranche J1-03de08.txt : md5 3f029e12d1a3cc0b94378d54c577d7ea, debut 2026-10-10T04:07:34Z, fin 2026-10-10T04:51:52Z, code 0 (options : --jeu J1)
- Tranche J1-02de08.txt : md5 7fa554735a24acf752ac531fe639d515, debut 2026-10-10T04:07:25Z, fin 2026-10-10T04:52:53Z, code 0 (options : --jeu J1)
- Tranche J1-04de08.txt : md5 f8f47d9b945eb35a16c34bed47796c73, debut 2026-10-10T04:08:11Z, fin 2026-10-10T04:53:04Z, code 0 (options : --jeu J1)
- Tranche J1-05de08.txt : md5 b833f3627f49cf4cc5cec62b2e2ce898, debut 2026-10-10T04:51:14Z, fin 2026-10-10T05:36:49Z, code 0 (options : --jeu J1)
- Tranche J1-08de08.txt : md5 ee06c64dc0b0cd2a433d1156f59bc8a0, debut 2026-10-10T04:53:04Z, fin 2026-10-10T05:37:32Z, code 0 (options : --jeu J1)
- Tranche J1-06de08.txt : md5 9ab05bee1628907cd3eea0b66d320823, debut 2026-10-10T04:51:52Z, fin 2026-10-10T05:37:48Z, code 0 (options : --jeu J1)
- Tranche J1-07de08.txt : md5 7d80d0c7f33b28743a093a6a52352aa6, debut 2026-10-10T04:52:53Z, fin 2026-10-10T05:40:30Z, code 0 (options : --jeu J1)
- Tranche H0-03de04.txt : md5 ff08ae462a847215a88f6a860d4d1647, debut 2026-10-10T05:37:48Z, fin 2026-10-10T06:14:06Z, code 0 (options : --scenario H0)
- Tranche H0-01de04.txt : md5 7b8c2e0e1e9ea4b806de740ec3dc0116, debut 2026-10-10T05:36:49Z, fin 2026-10-10T06:14:07Z, code 0 (options : --scenario H0)
- Tranche H0-02de04.txt : md5 7091d19681e49813f73d32e7d635bb72, debut 2026-10-10T05:37:32Z, fin 2026-10-10T06:14:50Z, code 0 (options : --scenario H0)
- Tranche H0-04de04.txt : md5 237298913bde55ab7a95763429552314, debut 2026-10-10T05:40:30Z, fin 2026-10-10T06:17:08Z, code 0 (options : --scenario H0)
- Tranche H3-01de04.txt : md5 1c007102117696ab455a25981511532e, debut 2026-10-10T06:14:06Z, fin 2026-10-10T06:55:26Z, code 0 (options : --scenario H3)
- Tranche H3-02de04.txt : md5 3be02e1952fce9e0b60572e9e3188b48, debut 2026-10-10T06:14:07Z, fin 2026-10-10T06:55:36Z, code 0 (options : --scenario H3)
- Tranche H3-03de04.txt : md5 055b2806e17c384f55bd9f3a82dbd49e, debut 2026-10-10T06:14:50Z, fin 2026-10-10T06:56:37Z, code 0 (options : --scenario H3)
- Tranche H3-04de04.txt : md5 e32a30a4704dd3211c41fd4da2a07828, debut 2026-10-10T06:17:08Z, fin 2026-10-10T06:58:21Z, code 0 (options : --scenario H3)
- Tranche C3-01de04.txt : md5 427b5df718cf767dad87f62bad7789da, debut 2026-10-10T06:55:26Z, fin 2026-10-10T07:35:48Z, code 0 (options : --scenario C3)
- Tranche C3-02de04.txt : md5 6cdea33a4dc02ca99c7879e3a0767d1f, debut 2026-10-10T06:55:36Z, fin 2026-10-10T07:36:39Z, code 0 (options : --scenario C3)
- Tranche C3-03de04.txt : md5 8b627bc438f42c81ce78bb43a9d88dd6, debut 2026-10-10T06:56:37Z, fin 2026-10-10T07:37:15Z, code 0 (options : --scenario C3)
- Tranche C3-04de04.txt : md5 07d5547d7061531762b8c7a511bf96a4, debut 2026-10-10T06:58:21Z, fin 2026-10-10T07:39:26Z, code 0 (options : --scenario C3)
- Tranche C4-01de04.txt : md5 b93dafd495b8052cf091854f95945269, debut 2026-10-10T07:35:48Z, fin 2026-10-10T08:16:48Z, code 0 (options : --scenario C4)
- Tranche C4-02de04.txt : md5 bab05d3b950617ad31eeac1f20beb9a2, debut 2026-10-10T07:36:39Z, fin 2026-10-10T08:18:15Z, code 0 (options : --scenario C4)
- Tranche C4-03de04.txt : md5 731a291fa9d7cd174e3d22a7d61b93e1, debut 2026-10-10T07:37:15Z, fin 2026-10-10T08:18:39Z, code 0 (options : --scenario C4)
- Tranche C4-04de04.txt : md5 6ac1bafe8e32daccccc08fd0e93a4283, debut 2026-10-10T07:39:26Z, fin 2026-10-10T08:20:50Z, code 0 (options : --scenario C4)
- Tranche A4-01de04.txt : md5 669617d386d4b91b387091b93d18d5b8, debut 2026-10-10T08:16:48Z, fin 2026-10-10T09:00:49Z, code 0 (options : --scenario A4)
- Tranche A4-02de04.txt : md5 f1406163e3054732357509f5af625d0b, debut 2026-10-10T08:18:16Z, fin 2026-10-10T09:02:32Z, code 0 (options : --scenario A4)
- Tranche A4-03de04.txt : md5 836573aa5dd47993cfa4b364af52eee6, debut 2026-10-10T08:18:39Z, fin 2026-10-10T09:02:54Z, code 0 (options : --scenario A4)
- Tranche A4-04de04.txt : md5 53a8789250840222734acbc5862c012e, debut 2026-10-10T08:20:50Z, fin 2026-10-10T09:04:04Z, code 0 (options : --scenario A4)
- Tranche A2-01de04.txt : md5 40b3099e74945780b5b8957cb62adb22, debut 2026-10-10T09:00:49Z, fin 2026-10-10T09:44:51Z, code 0 (options : --scenario A2)
- Tranche A2-02de04.txt : md5 538dd88bc6e13e5620a4d053b6536809, debut 2026-10-10T09:02:32Z, fin 2026-10-10T09:46:27Z, code 0 (options : --scenario A2)
- Tranche A2-03de04.txt : md5 82ecda7091c1535958ed28eaee278c7a, debut 2026-10-10T09:02:54Z, fin 2026-10-10T09:46:57Z, code 0 (options : --scenario A2)
- Tranche A2-04de04.txt : md5 6925adccfa9360770a482d0bbfaac518, debut 2026-10-10T09:04:04Z, fin 2026-10-10T09:48:17Z, code 0 (options : --scenario A2)
- Fin de la mesure : 48 tranches sur 48 terminées (code 0, INTEGRITE OK, aucune réplication en erreur), lanceur terminé à 2026-10-10T09:48:17Z.
