# Avis d'`actuary` sur les choix ajoutés de #556 (étape 6 de K2b)

> Versé par la session principale. Fiche de base. 13/11/2026, diff non commité de `app.R`.

1. **Garde `shiny.silent.error` : acceptée.** `req()` lève une condition de classe `shiny.silent.error` (héritant de `error`, hypothèse corroborée par la mesure `testServer` du codeur) ; ce n'est pas un échec d'écriture, la notifier afficherait un faux « Export impossible » ; l'erreur est relevée, aucun fichier vide n'est servi. Les erreurs de `validate()` sont traitées de même, ce qui est cohérent.
2. **Journal puis notification : accepté** (traçabilité, #94).
3. **« donnees courantes conservees » dans tous les cas de refus : accepté.** Vérifié dans le diff : dans les quatre branches, `refuser_import()` puis `return()` précèdent toute écriture de `donnees()`, `triangle()` ou `version_grille()` ; démarrage et imports acceptés avec réserve hors de ce chemin.
4. **`refus_moteur` laissé : accepté avec réserve.** Inoffensif, vérifié par `test_application.R` l. 613-617. **Réserve** : le commentaire d'`app.R` l. 257-258 (« pour la phrase de l'import ("Fichier ... (XLSX) refuse. <texte>") ») est devenu faux ; à reformuler avant le commit.

Aucun effet sur σ_USP, p-values ni verdicts.
