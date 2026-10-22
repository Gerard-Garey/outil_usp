# JOURNAL de la mesure #309 (puissance à T = 8 des lignes M1 à M4 de Merz-Wüthrich ; niveau des candidats de #300 et #301)

- Commit mesuré : 754dd0a71e48243bc87240f2c0f3a825c23c8776 (branche claude/merz-wuthrich-puissance, poussé), worktree détaché
- md5 R/engine.R : a6250d419ea27cb2e87bf4ed70dac453 ; md5 tests/puissance_mw_t8.R : cd4df329e47cdff297ce173234960a04 ; md5 spécification : 072e12472ef287ff163ace3c3332ea6f
- Locale : LC_ALL=C.UTF-8 ; R 4.3.3 ; 4 cœurs
- Plan : spécification D1-Fi, plan (A) + volet A + P3 (décisions Q-D1-Fi-1 et Q-D1-Fi-3 du mainteneur, 19/10/2026 ; compléments du 19/10) ; 89 sorties (--lister)
- Débit : essai du 2026-10-19 au commit mesuré (--essai --n 1 --coeurs 4, arbre propre) : volet A 2,17 h, volet B 30,02 h, (i2) 0,71 h, oracles 0,21 h, contrôles 0,70 h ; total 33,80 h d'horloge (133,09 h CPU) ; essais antérieurs sur arbre de travail 34,45 h, 32,87 h, 32,34 h
- Empreinte sans commentaires : 6ce112eecc6a7e9b6500ab639e757891
- Contrôles au commit mesuré (--controles --coeurs 4, arbre propre) : Bilan OK
- Décision de lancement : exécution longue sur branche de sauvegarde décidée par le mainteneur (Q-D1-Fi-1, 19/10/2026), après audit léger, /code-review et --essai (brief du mainteneur, point 3) ; durée annoncée dans la PR #349
- Lancement 2026-10-19T14:25:23Z : LC_ALL=C.UTF-8 bash tests/outillage/lancer_tranches.sh -p plan.txt -d DOSSIER -j 1 -s tests/puissance_mw_t8.R -- --coeurs 4 (depuis le worktree au commit mesuré)
- Synchronisation : bash tests/outillage/synchroniser_sauvegarde.sh -d DOSSIER -w WORKTREE -b claude/sauvegarde-309 -c sauvegarde/issue309 -i 600

## Plan (sortie de --lister, 89 sorties)

```
ora-A-N.txt	--oracle --volet A --loi N
ora-A-E.txt	--oracle --volet A --loi E
ora-A-A.txt	--oracle --volet A --loi A
va-N-0001-0250.txt	--volet A --loi N --b 1:250
va-N-0251-0500.txt	--volet A --loi N --b 251:500
va-N-0501-0750.txt	--volet A --loi N --b 501:750
va-N-0751-1000.txt	--volet A --loi N --b 751:1000
va-N-1001-1250.txt	--volet A --loi N --b 1001:1250
va-N-1251-1500.txt	--volet A --loi N --b 1251:1500
va-N-1501-1750.txt	--volet A --loi N --b 1501:1750
va-N-1751-2000.txt	--volet A --loi N --b 1751:2000
va-E-0001-0250.txt	--volet A --loi E --b 1:250
va-E-0251-0500.txt	--volet A --loi E --b 251:500
va-E-0501-0750.txt	--volet A --loi E --b 501:750
va-E-0751-1000.txt	--volet A --loi E --b 751:1000
va-E-1001-1250.txt	--volet A --loi E --b 1001:1250
va-E-1251-1500.txt	--volet A --loi E --b 1251:1500
va-E-1501-1750.txt	--volet A --loi E --b 1501:1750
va-E-1751-2000.txt	--volet A --loi E --b 1751:2000
va-A-0001-0250.txt	--volet A --loi A --b 1:250
va-A-0251-0500.txt	--volet A --loi A --b 251:500
va-A-0501-0750.txt	--volet A --loi A --b 501:750
va-A-0751-1000.txt	--volet A --loi A --b 751:1000
vb-P1-H0-0001-0250.txt	--volet B --plan P1 --cellule H0 --b 1:250
vb-P1-H0-0251-0500.txt	--volet B --plan P1 --cellule H0 --b 251:500
vb-P1-H0-0501-0750.txt	--volet B --plan P1 --cellule H0 --b 501:750
vb-P1-H0-0751-1000.txt	--volet B --plan P1 --cellule H0 --b 751:1000
vb-P1-CST20-0001-0250.txt	--volet B --plan P1 --cellule CST20 --b 1:250
vb-P1-CST20-0251-0500.txt	--volet B --plan P1 --cellule CST20 --b 251:500
vb-P1-CST20-0501-0750.txt	--volet B --plan P1 --cellule CST20 --b 501:750
vb-P1-CST20-0751-1000.txt	--volet B --plan P1 --cellule CST20 --b 751:1000
vb-P1-EXP2-0001-0250.txt	--volet B --plan P1 --cellule EXP2 --b 1:250
vb-P1-EXP2-0251-0500.txt	--volet B --plan P1 --cellule EXP2 --b 251:500
vb-P1-EXP2-0501-0750.txt	--volet B --plan P1 --cellule EXP2 --b 501:750
vb-P1-EXP2-0751-1000.txt	--volet B --plan P1 --cellule EXP2 --b 751:1000
vb-P1-CEL4-0001-0250.txt	--volet B --plan P1 --cellule CEL4 --b 1:250
vb-P1-CEL4-0251-0500.txt	--volet B --plan P1 --cellule CEL4 --b 251:500
vb-P1-CEL4-0501-0750.txt	--volet B --plan P1 --cellule CEL4 --b 501:750
vb-P1-CEL4-0751-1000.txt	--volet B --plan P1 --cellule CEL4 --b 751:1000
vb-P1-CEL6-0001-0250.txt	--volet B --plan P1 --cellule CEL6 --b 1:250
vb-P1-CEL6-0251-0500.txt	--volet B --plan P1 --cellule CEL6 --b 251:500
vb-P1-CEL6-0501-0750.txt	--volet B --plan P1 --cellule CEL6 --b 501:750
vb-P1-CEL6-0751-1000.txt	--volet B --plan P1 --cellule CEL6 --b 751:1000
vb-P1-CST10-0001-0250.txt	--volet B --plan P1 --cellule CST10 --b 1:250
vb-P1-CST10-0251-0500.txt	--volet B --plan P1 --cellule CST10 --b 251:500
vb-P1-EXP0-0001-0250.txt	--volet B --plan P1 --cellule EXP0 --b 1:250
vb-P1-EXP0-0251-0500.txt	--volet B --plan P1 --cellule EXP0 --b 251:500
vb-P1-DFI-0001-0250.txt	--volet B --plan P1 --cellule DFI --b 1:250
vb-P1-DFI-0251-0500.txt	--volet B --plan P1 --cellule DFI --b 251:500
vb-P1-CAL7-0001-0250.txt	--volet B --plan P1 --cellule CAL7 --b 1:250
vb-P1-CAL7-0251-0500.txt	--volet B --plan P1 --cellule CAL7 --b 251:500
vb-P1-CAL4-0001-0250.txt	--volet B --plan P1 --cellule CAL4 --b 1:250
vb-P1-CAL4-0251-0500.txt	--volet B --plan P1 --cellule CAL4 --b 251:500
vb-P1-DCAL-0001-0250.txt	--volet B --plan P1 --cellule DCAL --b 1:250
vb-P1-DCAL-0251-0500.txt	--volet B --plan P1 --cellule DCAL --b 251:500
vb-P1-LIG-0001-0250.txt	--volet B --plan P1 --cellule LIG --b 1:250
vb-P1-LIG-0251-0500.txt	--volet B --plan P1 --cellule LIG --b 251:500
vb-P1-CELx4-0001-0250.txt	--volet B --plan P1 --cellule CELx4 --b 1:250
vb-P1-CELx4-0251-0500.txt	--volet B --plan P1 --cellule CELx4 --b 251:500
ora-B-P2.txt	--oracle --volet B --plan P2
vb-P2-H0-0001-0250.txt	--volet B --plan P2 --cellule H0 --b 1:250
vb-P2-H0-0251-0500.txt	--volet B --plan P2 --cellule H0 --b 251:500
vb-P2-H0-0501-0750.txt	--volet B --plan P2 --cellule H0 --b 501:750
vb-P2-H0-0751-1000.txt	--volet B --plan P2 --cellule H0 --b 751:1000
vb-P2-CST20-0001-0250.txt	--volet B --plan P2 --cellule CST20 --b 1:250
vb-P2-CST20-0251-0500.txt	--volet B --plan P2 --cellule CST20 --b 251:500
vb-P2-CST20-0501-0750.txt	--volet B --plan P2 --cellule CST20 --b 501:750
vb-P2-CST20-0751-1000.txt	--volet B --plan P2 --cellule CST20 --b 751:1000
vb-P2-EXP2-0001-0250.txt	--volet B --plan P2 --cellule EXP2 --b 1:250
vb-P2-EXP2-0251-0500.txt	--volet B --plan P2 --cellule EXP2 --b 251:500
vb-P2-EXP2-0501-0750.txt	--volet B --plan P2 --cellule EXP2 --b 501:750
vb-P2-EXP2-0751-1000.txt	--volet B --plan P2 --cellule EXP2 --b 751:1000
vb-P2-CST10-0001-0250.txt	--volet B --plan P2 --cellule CST10 --b 1:250
vb-P2-CST10-0251-0500.txt	--volet B --plan P2 --cellule CST10 --b 251:500
vb-P2-EXP0-0001-0250.txt	--volet B --plan P2 --cellule EXP0 --b 1:250
vb-P2-EXP0-0251-0500.txt	--volet B --plan P2 --cellule EXP0 --b 251:500
vb-P2-DFI-0001-0250.txt	--volet B --plan P2 --cellule DFI --b 1:250
vb-P2-DFI-0251-0500.txt	--volet B --plan P2 --cellule DFI --b 251:500
ora-B-P3.txt	--oracle --volet B --plan P3
vb-P3-H0-0001-0250.txt	--volet B --plan P3 --cellule H0 --b 1:250
vb-P3-H0-0251-0500.txt	--volet B --plan P3 --cellule H0 --b 251:500
vb-P3-H0-0501-0750.txt	--volet B --plan P3 --cellule H0 --b 501:750
vb-P3-H0-0751-1000.txt	--volet B --plan P3 --cellule H0 --b 751:1000
vb-P3-CST20-0001-0250.txt	--volet B --plan P3 --cellule CST20 --b 1:250
vb-P3-CST20-0251-0500.txt	--volet B --plan P3 --cellule CST20 --b 251:500
vb-P3-CST20-0501-0750.txt	--volet B --plan P3 --cellule CST20 --b 501:750
vb-P3-CST20-0751-1000.txt	--volet B --plan P3 --cellule CST20 --b 751:1000
vb-P3-DFI-0001-0250.txt	--volet B --plan P3 --cellule DFI --b 1:250
vb-P3-DFI-0251-0500.txt	--volet B --plan P3 --cellule DFI --b 251:500
```

## Sorties
- Reprise 2026-10-19T14:35:07Z : processus du lanceur et de la synchronisation arretes a la reprise de la session (conteneur conserve) ; meme commande relancee, depuis le worktree au commit mesure
- Sortie ora-A-N.txt : md5 9d2b3f8ec0969889e3083a36a61d5937, terminee, INTEGRITE OK, synchronisee 2026-10-19T14:35:09Z
- Sortie ora-A-A.txt : md5 3d347653bbd194abb4bb6c72936dd5aa, terminee, INTEGRITE OK, synchronisee 2026-10-19T14:45:16Z
- Sortie ora-A-E.txt : md5 3ab15cf7be671a4d8b07fe14b6461cc6, terminee, INTEGRITE OK, synchronisee 2026-10-19T14:45:17Z
- Reprise 2026-10-19T15:13:00Z : processus arretes vers 14:45 UTC (conteneur suspendu, session inactive) ; meme commande relancee ; veille de la session ajoutee
- Sortie va-N-0001-0250.txt : md5 1d03b729dffd05d986026a53389a0686, terminee, INTEGRITE OK, synchronisee 2026-10-19T15:23:05Z
- Sortie va-N-0251-0500.txt : md5 10e39ef50a10c77501e862623e288c00, terminee, INTEGRITE OK, synchronisee 2026-10-19T15:33:09Z
- Sortie va-N-0501-0750.txt : md5 266cc4a7ca36d619fbec71e411974476, terminee, INTEGRITE OK, synchronisee 2026-10-19T15:43:12Z
- Sortie va-N-0751-1000.txt : md5 43333940976688ac7d266d6d79a74765, terminee, INTEGRITE OK, synchronisee 2026-10-19T15:43:12Z
- Sortie va-N-1001-1250.txt : md5 04e3a46395206add50ad22c340f0a9cf, terminee, INTEGRITE OK, synchronisee 2026-10-19T15:53:16Z
- Sortie va-N-1251-1500.txt : md5 b147e2387ddd8014dadc4b6ae4df0c54, terminee, INTEGRITE OK, synchronisee 2026-10-19T16:03:20Z
- Sortie va-N-1501-1750.txt : md5 14a4ecc412d9450dff0651c275217000, terminee, INTEGRITE OK, synchronisee 2026-10-19T16:13:25Z
- Sortie va-N-1751-2000.txt : md5 405b9125d6f624dc7dfda8f4b14a4f61, terminee, INTEGRITE OK, synchronisee 2026-10-19T16:23:28Z
- Sortie va-E-0001-0250.txt : md5 b9db1dce5825f092cddfa58e56d389c9, terminee, INTEGRITE OK, synchronisee 2026-10-19T16:33:32Z
- Sortie va-E-0251-0500.txt : md5 b349a47c2591c38b0581626dd7437b26, terminee, INTEGRITE OK, synchronisee 2026-10-19T16:33:32Z
- Sortie va-E-0501-0750.txt : md5 aba309c4d634c76a31051ba9bc53fe4b, terminee, INTEGRITE OK, synchronisee 2026-10-19T16:43:36Z
- Sortie va-E-0751-1000.txt : md5 d0cc306ce571639b032a025348660e48, terminee, INTEGRITE OK, synchronisee 2026-10-19T16:53:40Z
- Sortie va-E-1001-1250.txt : md5 a476b54825ade5178d24b42cdc6c99eb, terminee, INTEGRITE OK, synchronisee 2026-10-19T17:03:44Z
- Sortie va-E-1251-1500.txt : md5 c72c7f08a609939dc065d851f724576a, terminee, INTEGRITE OK, synchronisee 2026-10-19T17:13:49Z
- Sortie va-E-1501-1750.txt : md5 bd4c43bd3e63f84e665c3018da7bfe57, terminee, INTEGRITE OK, synchronisee 2026-10-19T17:23:53Z
- Sortie va-E-1751-2000.txt : md5 dd15bdfdf167a7632c278e77d5ae131e, terminee, INTEGRITE OK, synchronisee 2026-10-19T17:33:57Z
- Sortie va-A-0001-0250.txt : md5 6552df3c400f6db15c187e259779b1f3, terminee, INTEGRITE OK, synchronisee 2026-10-19T17:44:00Z
- Sortie va-A-0251-0500.txt : md5 2ead36601e21cb4259cb6947998d1a3e, terminee, INTEGRITE OK, synchronisee 2026-10-19T17:54:05Z
- Sortie va-A-0501-0750.txt : md5 b631ffb356feca52650dc0c55a3356c0, terminee, INTEGRITE OK, synchronisee 2026-10-19T18:04:10Z
- Sortie va-A-0751-1000.txt : md5 4b9a0b96de56e27984d90b2748e80c5e, terminee, INTEGRITE OK, synchronisee 2026-10-19T18:14:15Z
- Sortie vb-P1-H0-0001-0250.txt : md5 dbb09e7cc9d942b361987c27ab8cbb0a, terminee, INTEGRITE OK, synchronisee 2026-10-19T18:44:28Z
- Sortie vb-P1-H0-0251-0500.txt : md5 e1216efd43105789071fd7ee513efabe, terminee, INTEGRITE OK, synchronisee 2026-10-19T19:14:43Z
- Sortie vb-P1-H0-0501-0750.txt : md5 0d0c43f6894476218cd848e9a2a2b881, terminee, INTEGRITE OK, synchronisee 2026-10-19T19:34:52Z
- Sortie vb-P1-H0-0751-1000.txt : md5 e24e19235da5b0a741156e2cebc19f83, terminee, INTEGRITE OK, synchronisee 2026-10-19T20:05:07Z
- Sortie vb-P1-CST20-0001-0250.txt : md5 94bb19f9f3f89c7c735cf6e01dd4d2f9, terminee, INTEGRITE OK, synchronisee 2026-10-19T20:35:21Z
- Sortie vb-P1-CST20-0251-0500.txt : md5 7f4e559e4932404a190a347c18177e34, terminee, INTEGRITE OK, synchronisee 2026-10-19T20:55:31Z
- Sortie vb-P1-CST20-0501-0750.txt : md5 9456ee8e4b7d326a6cb5947010d3c60f, terminee, INTEGRITE OK, synchronisee 2026-10-19T21:25:44Z
- Sortie vb-P1-CST20-0751-1000.txt : md5 771e70a1f79746c6ab6f60a5c33b4f68, terminee, INTEGRITE OK, synchronisee 2026-10-19T21:45:53Z
- Sortie vb-P1-EXP2-0001-0250.txt : md5 f0d17167bdf207170e7d77a3452f0a27, terminee, INTEGRITE OK, synchronisee 2026-10-19T22:16:09Z
- Sortie vb-P1-EXP2-0251-0500.txt : md5 018a799dd3c06914880d0103c1fa8716, terminee, INTEGRITE OK, synchronisee 2026-10-19T22:36:18Z
- Sortie vb-P1-EXP2-0501-0750.txt : md5 8e33a395abac9ce960dd954a3a4d8ae6, terminee, INTEGRITE OK, synchronisee 2026-10-19T23:06:33Z
- Sortie vb-P1-EXP2-0751-1000.txt : md5 7ffd123837d138f749d43f420a27ca83, terminee, INTEGRITE OK, synchronisee 2026-10-19T23:26:43Z
- Sortie vb-P1-CEL4-0001-0250.txt : md5 1ebdeebd4596800a79eb382f065182c3, terminee, INTEGRITE OK, synchronisee 2026-10-19T23:46:52Z
- Sortie vb-P1-CEL4-0251-0500.txt : md5 b88ea758c56b93d3105c54874cfb1eab, terminee, INTEGRITE OK, synchronisee 2026-10-20T00:17:08Z
- Sortie vb-P1-CEL4-0501-0750.txt : md5 94282735e47638ed053d52e52897a1e9, terminee, INTEGRITE OK, synchronisee 2026-10-20T00:37:18Z
- Sortie vb-P1-CEL4-0751-1000.txt : md5 6d0a823acff57a0c7007c6b39d924ee1, terminee, INTEGRITE OK, synchronisee 2026-10-20T01:07:34Z
- Sortie vb-P1-CEL6-0001-0250.txt : md5 492e6cf88069b00a352e3c436378abfc, terminee, INTEGRITE OK, synchronisee 2026-10-20T01:27:44Z
- Sortie vb-P1-CEL6-0251-0500.txt : md5 e36589e8219f29c983b7ba12cd9bce90, terminee, INTEGRITE OK, synchronisee 2026-10-20T01:58:01Z
- Sortie vb-P1-CEL6-0501-0750.txt : md5 c9cc32eea13b6d8ca6bbecac86a613bf, terminee, INTEGRITE OK, synchronisee 2026-10-20T02:18:12Z
- Sortie vb-P1-CEL6-0751-1000.txt : md5 c4a6243fbf0952d3b3b77f074a283db8, terminee, INTEGRITE OK, synchronisee 2026-10-20T02:38:22Z
- Reprise 2026-10-20T02:44:54Z : redemarrage du conteneur (02:44 UTC) ; meme commande relancee depuis le worktree au commit mesure
- Sortie vb-P1-CST10-0001-0250.txt : md5 638a05185b488baa6979c22480b61eba, terminee, INTEGRITE OK, synchronisee 2026-10-20T03:25:24Z
- Sortie vb-P1-CST10-0251-0500.txt : md5 90bbe8879943410c69ce62c2a25cbfed, terminee, INTEGRITE OK, synchronisee 2026-10-20T03:55:43Z
- Sortie vb-P1-EXP0-0001-0250.txt : md5 08e9471a3cbabd7625a91348ae0d7507, terminee, INTEGRITE OK, synchronisee 2026-10-20T04:36:07Z
- Sortie vb-P1-EXP0-0251-0500.txt : md5 d5ff283d55bbb946a4978a861aa76e50, terminee, INTEGRITE OK, synchronisee 2026-10-20T05:16:33Z
- Sortie vb-P1-DFI-0001-0250.txt : md5 c7dea51a0940497d414c5ebaf623f546, terminee, INTEGRITE OK, synchronisee 2026-10-20T05:57:00Z
- Sortie vb-P1-DFI-0251-0500.txt : md5 0e29a59407273baa5f7b1a7d83e1a39c, terminee, INTEGRITE OK, synchronisee 2026-10-20T06:37:27Z
- Sortie vb-P1-CAL7-0001-0250.txt : md5 0603569fdd50251761c37d72ef02afc1, terminee, INTEGRITE OK, synchronisee 2026-10-20T07:17:55Z
- Sortie vb-P1-CAL7-0251-0500.txt : md5 39ce21ff110c8d502da8ff7fd36185da, terminee, INTEGRITE OK, synchronisee 2026-10-20T07:58:25Z
- Sortie vb-P1-CAL4-0001-0250.txt : md5 5332bfcbe34a014e0c6986e4d07ad735, terminee, INTEGRITE OK, synchronisee 2026-10-20T08:38:56Z
- Sortie vb-P1-CAL4-0251-0500.txt : md5 090a75bbc5a1137e1907f0b1085b69a3, terminee, INTEGRITE OK, synchronisee 2026-10-20T09:29:34Z
- Sortie vb-P1-DCAL-0001-0250.txt : md5 1025a22ee50a31c3e3387bc84938ba7c, terminee, INTEGRITE OK, synchronisee 2026-10-20T10:10:03Z
- Sortie vb-P1-DCAL-0251-0500.txt : md5 6f20313dc9b7e5f4300cee301311149e, terminee, INTEGRITE OK, synchronisee 2026-10-20T10:50:34Z
- Sortie vb-P1-LIG-0001-0250.txt : md5 80eec1b7a06e0ef04757e9678304924d, terminee, INTEGRITE OK, synchronisee 2026-10-20T11:31:05Z
- Sortie vb-P1-LIG-0251-0500.txt : md5 c242727fe372dea12b39b0d255af6506, terminee, INTEGRITE OK, synchronisee 2026-10-20T12:21:44Z
- Sortie vb-P1-CELx4-0001-0250.txt : md5 681867222553122c8aa73870a511ee60, terminee, INTEGRITE OK, synchronisee 2026-10-20T13:02:14Z
- Sortie vb-P1-CELx4-0251-0500.txt : md5 8d2ce3911fce5a598e42f93de2e25872, terminee, INTEGRITE OK, synchronisee 2026-10-20T13:42:46Z
- Sortie ora-B-P2.txt : md5 527c6852bb47ff53b30738ca98563f96, terminee, INTEGRITE OK, synchronisee 2026-10-20T13:52:53Z
- Sortie vb-P2-H0-0001-0250.txt : md5 0858f26b38946425c429f99de52b987a, terminee, INTEGRITE OK, synchronisee 2026-10-20T14:43:42Z
- Sortie vb-P2-H0-0251-0500.txt : md5 090d531ac7f9bcc638233a19de1e7764, terminee, INTEGRITE OK, synchronisee 2026-10-20T15:34:26Z
- Sortie vb-P2-H0-0501-0750.txt : md5 31782b696e86744889d70ed115506751, terminee, INTEGRITE OK, synchronisee 2026-10-20T16:25:09Z
- Sortie vb-P2-H0-0751-1000.txt : md5 c1c01b9419b8a2e6994a41c53abbbba8, terminee, INTEGRITE OK, synchronisee 2026-10-20T17:05:41Z
- Sortie vb-P2-CST20-0001-0250.txt : md5 779620e746efea5d9d8f86593299387b, terminee, INTEGRITE OK, synchronisee 2026-10-20T17:56:23Z
- Sortie vb-P2-CST20-0251-0500.txt : md5 bf7bc31de278e5f3e4dec78557dac16c, terminee, INTEGRITE OK, synchronisee 2026-10-20T18:36:58Z
- Sortie vb-P2-CST20-0501-0750.txt : md5 7f4f354c489bd695dafe1a17ca5a2b57, terminee, INTEGRITE OK, synchronisee 2026-10-20T19:17:34Z
- Sortie vb-P2-CST20-0751-1000.txt : md5 815945985d68a1930a971f7f66e07efa, terminee, INTEGRITE OK, synchronisee 2026-10-20T19:58:10Z
- Sortie vb-P2-EXP2-0001-0250.txt : md5 69055b8271a0e009367ffa1026789499, terminee, INTEGRITE OK, synchronisee 2026-10-20T20:38:45Z
- Sortie vb-P2-EXP2-0251-0500.txt : md5 e4be00fed14743dccc50f70874675ed4, terminee, INTEGRITE OK, synchronisee 2026-10-20T21:19:21Z
- Sortie vb-P2-EXP2-0501-0750.txt : md5 761b1356168fdcf991a35e0ee3b71551, terminee, INTEGRITE OK, synchronisee 2026-10-20T21:59:56Z
- Sortie vb-P2-EXP2-0751-1000.txt : md5 ade5dbcfa770cb78d25577f48131205a, terminee, INTEGRITE OK, synchronisee 2026-10-20T22:40:31Z
- Sortie vb-P2-CST10-0001-0250.txt : md5 3619caad9e24d571ef9a29f5a940045d, terminee, INTEGRITE OK, synchronisee 2026-10-20T23:21:01Z
- Sortie vb-P2-CST10-0251-0500.txt : md5 2af622fcaee22af613a038a1acc0a031, terminee, INTEGRITE OK, synchronisee 2026-10-20T23:51:25Z
- Sortie vb-P2-EXP0-0001-0250.txt : md5 c1c1debb133f4050cc256dc3df89f752, terminee, INTEGRITE OK, synchronisee 2026-10-21T00:31:59Z
- Sortie vb-P2-EXP0-0251-0500.txt : md5 1b17ae657d343695f1586dca529154d3, terminee, INTEGRITE OK, synchronisee 2026-10-21T01:02:26Z
- Sortie vb-P2-DFI-0001-0250.txt : md5 dbabd95fde6c92dbd2ef4bb865eb49ff, terminee, INTEGRITE OK, synchronisee 2026-10-21T01:43:00Z
- Sortie ora-B-P3.txt : md5 85ad7d03c5a44768ecd453ba4031c8f2, terminee, INTEGRITE OK, synchronisee 2026-10-21T02:23:34Z
- Sortie vb-P2-DFI-0251-0500.txt : md5 9f258c4a8c40cd57fb901150ad5af355, terminee, INTEGRITE OK, synchronisee 2026-10-21T02:23:35Z
- Sortie vb-P3-H0-0001-0250.txt : md5 64d174573f2e8454541d364c256f6dc5, terminee, INTEGRITE OK, synchronisee 2026-10-21T03:04:13Z
- Sortie vb-P3-H0-0251-0500.txt : md5 15acc5b9f8d2bfeeeb8034b740938b4f, terminee, INTEGRITE OK, synchronisee 2026-10-21T03:44:49Z
- Sortie vb-P3-H0-0501-0750.txt : md5 d0d1146c33e8fa5f6c8f9f40b3d8e042, terminee, INTEGRITE OK, synchronisee 2026-10-21T04:25:22Z
- Sortie vb-P3-H0-0751-1000.txt : md5 220b54d396722e48f9724f563f83a172, terminee, INTEGRITE OK, synchronisee 2026-10-21T04:55:48Z
- Sortie vb-P3-CST20-0001-0250.txt : md5 231a244a9e1554b4f77533998374cdd9, terminee, INTEGRITE OK, synchronisee 2026-10-21T05:36:26Z
- Sortie vb-P3-CST20-0251-0500.txt : md5 5ffeb1985b2ecc7d7f3c6d4a0cdb48c8, terminee, INTEGRITE OK, synchronisee 2026-10-21T06:27:15Z
- Sortie vb-P3-CST20-0501-0750.txt : md5 067d871b4df111f3039aa177c8c82bc9, terminee, INTEGRITE OK, synchronisee 2026-10-21T07:07:58Z
- Sortie vb-P3-CST20-0751-1000.txt : md5 162958201cd6abb1e0e8419fb9349d2d, terminee, INTEGRITE OK, synchronisee 2026-10-21T07:48:41Z
- Sortie vb-P3-DFI-0001-0250.txt : md5 a4270b9003bf83e8495d0bb0508a97e4, terminee, INTEGRITE OK, synchronisee 2026-10-21T08:39:36Z
- Fin 2026-10-21T09:18:14Z : 89 sorties terminees, INTEGRITE OK (BILAN du lanceur)
- Sortie vb-P3-DFI-0251-0500.txt : md5 f54c0e0bd10a0263380901b5556c5120, terminee, INTEGRITE OK, synchronisee 2026-10-21T09:18:21Z
