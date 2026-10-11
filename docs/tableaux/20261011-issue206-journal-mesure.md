# JOURNAL de la mesure #206 (+ #119), niveau L0

- Commit mesuré : 3a95e11400f2e770c6d7242c88a9e67fd394ca28 (branche claude/calibration-mc-merz-wuthrich, poussé), worktree détaché
- md5 R/engine.R : 25bff84c7828b632fe2b260b64663c9f ; md5 tests/calibration_mc_mw_t8.R : cf1692f76e665ae0118c6db20c7666cd ; md5 spécification : 153ad280a7e26f72a87cd327d8e2f89c
- Locale : LC_ALL=C.UTF-8 ; R 4.3.3 ; 4 cœurs
- Niveau : L0
- Débit : c_b = 20,68 s ; P = 3,750 (4 processus ; P_k = 1,000 / 1,944 / 2,932 / 3,750) ; F = 1,66 h CPU ; N_max = 12765 ; durée planifiée 11,17 h (pré-vol du 2026-10-10, commit 3a95e11)
- Empreinte sans commentaires : 9c8bf0d7971dd5fb215e5e30e1784591
- B2 : niveau L0 et durée annoncés au mainteneur, lancement approuvé par lui le 2026-10-10
- Lancement 2026-10-10T18:10:46Z : LC_ALL=C.UTF-8 bash tests/outillage/lancer_tranches.sh -p plan-L0.txt -d DOSSIER -j 4 (depuis le worktree au commit mesuré)
- Synchronisation : bash tests/outillage/synchroniser_sauvegarde.sh -d DOSSIER -w WORKTREE -b claude/sauvegarde-206 -c sauvegarde/issue206 -i 600

## Plan L0 (sortie de --plan L0, 33 sorties)

```
oracle-N.txt	--oracle --loi N
oracle-E.txt	--oracle --loi E
oracle-A.txt	--oracle --loi A
tranche-N-0001-0125.txt	--loi N --b 1:125 --pools redresse,brut
tranche-E-0001-0125.txt	--loi E --b 1:125 --pools redresse,brut
tranche-N-0126-0250.txt	--loi N --b 126:250 --pools redresse,brut
tranche-E-0126-0250.txt	--loi E --b 126:250 --pools redresse,brut
tranche-N-0251-0375.txt	--loi N --b 251:375 --pools redresse,brut
tranche-E-0251-0375.txt	--loi E --b 251:375 --pools redresse,brut
tranche-N-0376-0500.txt	--loi N --b 376:500 --pools redresse,brut
tranche-E-0376-0500.txt	--loi E --b 376:500 --pools redresse,brut
tranche-N-0501-0625.txt	--loi N --b 501:625 --pools redresse,brut
tranche-E-0501-0625.txt	--loi E --b 501:625 --pools redresse,brut
tranche-N-0626-0750.txt	--loi N --b 626:750 --pools redresse,brut
tranche-E-0626-0750.txt	--loi E --b 626:750 --pools redresse,brut
tranche-N-0751-0875.txt	--loi N --b 751:875 --pools redresse,brut
tranche-E-0751-0875.txt	--loi E --b 751:875 --pools redresse,brut
tranche-N-0876-1000.txt	--loi N --b 876:1000 --pools redresse,brut
tranche-E-0876-1000.txt	--loi E --b 876:1000 --pools redresse,brut
tranche-N-1001-1250.txt	--loi N --b 1001:1250 --pools redresse
tranche-E-1001-1250.txt	--loi E --b 1001:1250 --pools redresse
tranche-N-1251-1500.txt	--loi N --b 1251:1500 --pools redresse
tranche-E-1251-1500.txt	--loi E --b 1251:1500 --pools redresse
tranche-N-1501-1750.txt	--loi N --b 1501:1750 --pools redresse
tranche-E-1501-1750.txt	--loi E --b 1501:1750 --pools redresse
tranche-N-1751-2000.txt	--loi N --b 1751:2000 --pools redresse
tranche-E-1751-2000.txt	--loi E --b 1751:2000 --pools redresse
tranche-A-0001-0250.txt	--loi A --b 1:250 --pools redresse
tranche-A-0251-0500.txt	--loi A --b 251:500 --pools redresse
tranche-A-0501-0750.txt	--loi A --b 501:750 --pools redresse
tranche-A-0751-1000.txt	--loi A --b 751:1000 --pools redresse
sm-0001-0250.txt	--sous-mesure-N --b 1:250
sm-0251-0500.txt	--sous-mesure-N --b 251:500
```

## Sorties et incidents

- Sortie oracle-A.txt : md5 d614980dbe8988f6a79adb45330021c8, terminee, INTEGRITE OK, synchronisee 2026-10-10T18:21:25Z
- Sortie oracle-E.txt : md5 3243e66efd3f8981b047aea4ba52b19c, terminee, INTEGRITE OK, synchronisee 2026-10-10T18:21:25Z
- Sortie oracle-N.txt : md5 21c8a42f84657d7e3d05b29dc04b5628, terminee, INTEGRITE OK, synchronisee 2026-10-10T18:21:25Z
- Sortie tranche-N-0001-0125.txt : md5 e779d775dd6e5d91fe8bb1237ccdb0bc, terminee, INTEGRITE OK, synchronisee 2026-10-10T19:41:49Z
- Sortie tranche-E-0001-0125.txt : md5 15a7964b83af1c35f55052959556d319, terminee, INTEGRITE OK, synchronisee 2026-10-10T19:51:52Z
- Sortie tranche-E-0126-0250.txt : md5 8310f4656346c72c485364249224d01f, terminee, INTEGRITE OK, synchronisee 2026-10-10T19:51:52Z
- Sortie tranche-N-0126-0250.txt : md5 81b06f446989f8b941e7663377db644a, terminee, INTEGRITE OK, synchronisee 2026-10-10T19:51:52Z
- Sortie tranche-N-0251-0375.txt : md5 265986ad710c25e1b0e1536c4c8f7c14, terminee, INTEGRITE OK, synchronisee 2026-10-10T21:12:17Z
- Sortie tranche-E-0251-0375.txt : md5 a104b899ea3083a9d9f61a3cf1f5f929, terminee, INTEGRITE OK, synchronisee 2026-10-10T21:22:20Z
- Sortie tranche-E-0376-0500.txt : md5 8d8f0a62e98cd70f8af1cb153eb2d7be, terminee, INTEGRITE OK, synchronisee 2026-10-10T21:22:20Z
- Sortie tranche-N-0376-0500.txt : md5 0eb0f8de32377ac75a02a8585698c053, terminee, INTEGRITE OK, synchronisee 2026-10-10T21:22:20Z
- Sortie tranche-N-0501-0625.txt : md5 669a5d7f8b25183e38c38b57082c8653, terminee, INTEGRITE OK, synchronisee 2026-10-10T22:42:47Z
- Sortie tranche-E-0501-0625.txt : md5 35a56add5c1bbc158f789e2dd3e34527, terminee, INTEGRITE OK, synchronisee 2026-10-10T22:52:51Z
- Sortie tranche-E-0626-0750.txt : md5 2225e1da082e4d1555e9edbd9a531349, terminee, INTEGRITE OK, synchronisee 2026-10-10T22:52:51Z
- Sortie tranche-N-0626-0750.txt : md5 d9372b0eee4c69792f1743bfe956ae77, terminee, INTEGRITE OK, synchronisee 2026-10-10T22:52:51Z
- Sortie tranche-N-0751-0875.txt : md5 9b38e131aa9b4bcdd7d46b98c0947037, terminee, INTEGRITE OK, synchronisee 2026-10-11T00:13:21Z
- Sortie tranche-E-0751-0875.txt : md5 558397b2e86272a9c9dcef2912305001, terminee, INTEGRITE OK, synchronisee 2026-10-11T00:23:25Z
- Sortie tranche-E-0876-1000.txt : md5 d51d18d9795e90d7a8e473b11d034cc5, terminee, INTEGRITE OK, synchronisee 2026-10-11T00:23:25Z
- Sortie tranche-N-0876-1000.txt : md5 5c8063b64eea58a2b41940255625a37d, terminee, INTEGRITE OK, synchronisee 2026-10-11T00:23:25Z
- Sortie tranche-E-1001-1250.txt : md5 1c55477b8795ba18540936f04e06ae56, terminee, INTEGRITE OK, synchronisee 2026-10-11T01:43:58Z
- Sortie tranche-E-1251-1500.txt : md5 fb6b969c16580de5cf514f67df4a6f90, terminee, INTEGRITE OK, synchronisee 2026-10-11T01:43:58Z
- Sortie tranche-N-1001-1250.txt : md5 9818834486cab0da28b724fd1f24b574, terminee, INTEGRITE OK, synchronisee 2026-10-11T01:43:58Z
- Sortie tranche-N-1251-1500.txt : md5 4b13d97605c178f3351b7c656a4792b7, terminee, INTEGRITE OK, synchronisee 2026-10-11T01:43:58Z
- Sortie tranche-N-1501-1750.txt : md5 f8a6956dfb2044bb938abc7e04a0531c, terminee, INTEGRITE OK, synchronisee 2026-10-11T03:04:32Z
- Sortie tranche-E-1501-1750.txt : md5 bb376297e635ea89dd15ec3a0cb4409b, terminee, INTEGRITE OK, synchronisee 2026-10-11T03:14:37Z
- Sortie tranche-E-1751-2000.txt : md5 6fffa196495f77ef9713b89e7799d123, terminee, INTEGRITE OK, synchronisee 2026-10-11T03:14:37Z
- Sortie tranche-N-1751-2000.txt : md5 76b436d4eafbfcf61ad1646cecb16c73, terminee, INTEGRITE OK, synchronisee 2026-10-11T03:14:37Z
- Sortie sm-0001-0250.txt : md5 9199ab85bccf43ec04a9483d7258b2b7, terminee, INTEGRITE OK, synchronisee 2026-10-11T04:35:15Z
- Sortie tranche-A-0001-0250.txt : md5 123d6cef099b3c290e75ba8972f4a2db, terminee, INTEGRITE OK, synchronisee 2026-10-11T04:35:15Z
- Sortie tranche-A-0251-0500.txt : md5 2fe31ba9b4d5536031afb347953414f3, terminee, INTEGRITE OK, synchronisee 2026-10-11T04:35:15Z
- Sortie tranche-A-0501-0750.txt : md5 5bf70a7f60911ec90c07e7bd3c492e21, terminee, INTEGRITE OK, synchronisee 2026-10-11T04:35:15Z
- Sortie tranche-A-0751-1000.txt : md5 3db548bb8d79d8dad801404821638954, terminee, INTEGRITE OK, synchronisee 2026-10-11T04:35:15Z
- Sortie sm-0251-0500.txt : md5 7b2769f2197f578ecd02a9185bbe4ce8, terminee, INTEGRITE OK, synchronisee 2026-10-11T04:45:18Z
- Fin de la mesure : 33 sorties terminées, INTEGRITE OK (dernière : sm-0251-0500.txt, 2026-10-11T04:38:00Z) ; aucun incident, aucun redémarrage du conteneur, aucune reprise ; synchroniseur arrêté par STOP, dernière synchronisation 2026-10-11T05:20:46Z (tête de claude/sauvegarde-206 : 222ba4c) ; controler_md5.sh : 33 sorties conformes, en local et sur la branche de sauvegarde
