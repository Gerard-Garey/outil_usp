# Revue finale d'`app-review` sur K2b (étape 10, règle 10)

> Versée par la session principale (condensé fidèle). `app-review`, `model: "opus"`. 14/11/2026. Tête `8d4ced3` (`30bed39` ne touche que le `.tex`). Rendu réel : shiny 1.8.0, plotly 4.10.4, Chromium (Playwright), 1 600 px ; application lancée sans le paquet `zip` (`R_ZIPCMD=commande_zip_absente`).

**Verdict : conforme.** Aucun constat bloquant, majeur ni mineur.

## Rendu réel

| Scénario | Observé |
|---|---|
| CSV sans colonne `yt` | statut « Import du fichier sans_yt.csv (CSV) refuse ; donnees courantes conservees. Motif : Colonne(s) manquante(s) : yt. … » ; une seule notification ; grille inchangée |
| Faux `.xlsx` | même forme, motif `MESSAGE_ILLISIBLE$xlsx` ; une notification ; grille inchangée ; cause R au journal seulement |
| Export Excel sans zip (`usp_refus_ecriture`) | notification « Export impossible : Ecriture du fichier .xlsx impossible : ni le paquet R zip ni la commande zip … » ; page HTTP 500 sans cause R ; Chromium annule le téléchargement |
| Calcul (B = 99), onglet H2 en PDF A4 portrait et paysage, Calibration en portrait | graphiques entiers ; aucune trace après impression ; tailles d'écran identiques ; « Chaine de calibration » et « Valeurs candidates » avec leur contenu |

## Points de contrôle

- Déclenchement : l'import n'appelle jamais `run_engine()` (`app.R:1349-1441`).
- Onglet Données : les quatre refus passent par `refuser_import()` (`app.R:1360-1409`), avec `return()` avant toute écriture des données.
- Graphiques et Calibration : règles `@media print` et script `beforeprint`/`afterprint` seulement (`app.R:487-517`, `538-577`).
- Aucun calcul hors du moteur.
- Messages : `proteger_export` sur les cinq `downloadHandler` (`app.R:2033-2089`).

## Réserves des revues légères : toutes levées

#556 M1 (cause R dans la page 500) et M2 (commentaire de `lire_tableau()`) ; #566 mineurs 2 et 3 ; #566 mineur 1 consigné dans le corps de la PR.

## Suivi hors diff

Issue rédigée à l'étape 7 (surface 3D WebGL vide dans le PDF, `../20261113-k2b-etapes-5-7/app-review-leger-566.md`, l. 28-30) : non créée, à soumettre au mainteneur.

## Remarques sans action

`refus_moteur` de `lire_tableau()` lu par les tests seulement ; téléchargement `<output>.html` en échec selon le navigateur (documenté) ; fichier sans extension → « () » dans le statut (préexistant).
