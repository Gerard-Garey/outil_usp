# Revue légère d'`app-review` sur #556 (étape 6 de K2b)

> Versée par la session principale (condensé fidèle). Règle 10, revue légère du diff non commité sur `f7d4665`. Rendu réel : Chromium, shiny 1.8.0 / plotly 4.10.4. 13/11/2026.

**Verdict : conforme avec réserves** (aucun bloquant ni majeur ; deux mineurs).

## Points
1. Textes identiques à l'avis § 7 (`texte_refus_import()`, `NOTIFICATION_REFUS_IMPORT` `error` 8 s, `texte_echec_export()` `error` 10 s).
2. Forme unique dans les quatre branches (`refuser_import()`), observée à l'écran sur neuf fichiers (CSV illisible, vide, xlsx illisible, refus du lecteur, refus du moteur, dimension, triangle refusé, triangle de 45 ans) ; notification unique ; grille intacte après un refus (« donnees courantes conservees » exact).
3. Démarrage et non-refus inchangés.
4. `proteger_export` sur les cinq `downloadHandler` ; notification reçue par le client (texte du moteur pour `usp_refus_ecriture`, texte fixe pour une erreur R) ; cause au journal serveur seulement. `dl_rapport`, `dl_tests`, `dl_calib` non cliqués (enveloppe commune).
5. Garde `shiny.silent.error` juste, sans masquage (aucun `validate()` dans `app.R` ; `stop(e)` toujours relevé).
6. Aucun calcul ajouté. `test_application.R` : 236 / 236.

## Constats
- **M1 (mineur)** : `proteger_export` relève l'erreur d'origine ; la page d'erreur HTTP 500 de shiny (enregistrée par le navigateur en `.html`) contient la cause R brute (mesuré : `<p>impossible d'ouvrir le fichier 'cause R brute' : Permission denied</p>`). Correctif proposé : `stop(texte_echec_export(e), call. = FALSE)` au lieu de `stop(e)`, garde silencieuse inchangée.
- **M2 (mineur)** : commentaire de `lire_tableau()` (`app.R` ~l. 257-258) périmé (même réserve qu'`actuary`).

## Suite donnée par la session
M1 et M2 sont dans le périmètre de #556 (critère « aucune erreur R brute ») : corrigés dans K2b avant le commit (décision du mainteneur du 13/11 : mineurs corrigés dans la branche), puis revus sur leur diff. L'issue proposée par `app-review` pour M1 devient sans objet.

## Revue du correctif (M1, M2, libellés de l'audit), sur son diff

**Conforme, sans écart.** `proteger_export` : journal, notification inchangée, puis `stop(texte, call. = FALSE)` ; erreur toujours relevée, aucun fichier servi ; garde silencieuse intacte. Commentaire de `lire_tableau()` et libellés de `test_controles_entree.R` justes. **Mesure sous shiny 1.8.0 / plotly 4.10.4** : `GET` du lien `#dl_donnees` en échec → HTTP 500 dont le corps porte « Export impossible : erreur lors de l'ecriture du fichier (detail consigne au journal de l'application). », sans la cause R brute ; `#dl_donnees_xlsx` (`usp_refus_ecriture`) → texte du moteur ; notification reçue par le client dans les deux cas ; cause brute au journal serveur seulement. `test_application.R` sous 1.8.0 : 237 / 237 (149 dans le processus Shiny).
