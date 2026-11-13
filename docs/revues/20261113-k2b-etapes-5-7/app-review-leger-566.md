# Revue légère en rendu réel d'`app-review` sur #566 (étape 7 de K2b)

> Versée par la session principale (condensé fidèle). Règle 10, diff non commité de `app.R` sur `796b481`. Shiny 1.8.0 / plotly 4.10.4, Chromium `page.pdf()` A4, 1 600 px, `B = 99`. 13/11/2026.

**Verdict : conforme avec réserves** (aucun bloquant ni majeur ; trois mineurs ; une issue rédigée, non créée).

## Preuves refaites
| Point | Résultat |
|---|---|
| `test_application.R` | 237 / 237 |
| 42 PDF : graduation absente / pixels au bord / texte hors zone utile | 0 / 42, 0 / 42, 0 / 42 |
| examen visuel (premium H2, H3, Surface, Calibration ; reserve2 M1 ; portrait et paysage) | entiers |
| largeurs des conteneurs à 960 et 1 600 px, avant / après | 42 relevés identiques |
| captures d'écran premium, original contre corrigé | 0 px à 960 ; à 1 600 px, seule la mention de durée de calcul diffère |

Robustesse du script : idempotent (double `beforeprint`/`afterprint`), bascule `matchMedia`, double impression, onglets cachés, redimensionnement après impression, graphiques ajoutés après chargement : aucun résidu. Aucun calcul (lecture de la taille affichée et CSS).

## Points demandés
1. **Lisibilité** (mineur) : graduations ≈ 5-5,5 pt, sous-titres de graphique ≈ 3,6 pt en portrait à 1 600 px ; critère de #566 tenu, `exigences.md` § 5 sans taille imposée ; recommandation : imprimer en paysage ou depuis une fenêtre étroite (facteur 1 sous 960 px, ≈ 0,9 en paysage).
2. **Titre de carte isolé** (onglet Calibration, page 2 portrait de premium) : défaut antérieur mis au jour (la page n'est plus rétrécie), non causé par `break-inside: avoid` (essai avec `auto`) ; dans le périmètre (les PDF font foi) ; règle `.bloc > h4 { break-after: avoid }` validée en rendu réel (orphelin disparu à 1 600 et 1 280 px).
3. **Surface 3D WebGL vide dans les PDF** : avant comme après ; hors périmètre ; issue rédigée ci-dessous.

## Constats mineurs
1. Lisibilité des sous-titres en portrait à 1 600 px : documenter (pas de code).
2. Titre isolé : ajouter `.bloc > h4 { break-after: avoid; }` dans `@media print`.
3. Aucun test d'impression automatisé ; le script suppose des tailles en `px` sur `.svg-container` (observé ; une valeur en `%` donnerait un `viewBox` faux, non observé).

## Issue rédigée (non créée ; à soumettre au mainteneur)
**Titre** : Impression : la surface 3D « Fonction objectif » (WebGL) est vide dans le PDF — **Libellés** : `bug`, `needs-triage`.
> Dans « Surface objectif » (`premium`, `reserve1`), `g_surface` (`plot_surface_objectif()`) s'affiche à l'écran mais le PDF de Chromium `page.pdf()` (A4 portrait et paysage) ne contient que le titre et la barre de couleur. Identique avant et après #566. Reproduction : shiny 1.8.0, plotly 4.10.4, `B = 99`, « Relancer les calculs », `page.pdf({format:'A4'})`. Cause supposée (non vérifiée) : canvas WebGL non capturé à l'impression ; limite : Chromium headless sans GPU. Pistes : image statique de repli à l'impression, ou mention explicite. Refs #566, #564.

## Suite : correctif (mineurs 2 et 3) et revue sur son diff

- `coder` ajoute `.bloc > h4 { break-after: avoid; }` et, la règle seule laissant « Valeurs candidates » isolé (reserve1, Calibration, paysage), `.bloc > h4 + .row { break-inside: avoid; }` ; garde `px` dans `preparer()` ; assertion de lecture du source. Mesures (shiny 1.8.0) : 42 PDF, 0 graduation absente, 0 au bord, aucun titre isolé en dernière ligne de page ; Tests et Descriptif sans orphelin nouveau ; largeurs d'écran identiques.
- **Revue d'`app-review` sur ce diff : conforme.** La règle `h4 + .row` ne vise que la ligne de « Valeurs candidates » (280 px pour un bloc de 340 px : ni rognage ni page vide) ; garde `px` correcte (aucun état partiel ; `restaurer()` ne touche que les éléments marqués) ; assertion pertinente mais incomplète (mineur facultatif).
- **Session** : assertion complétée (`.bloc > h4 + .row` et `/px$/`), `test_application.R` sous shiny 1.8.0 : 238 / 238.
- Mineur 1 (lisibilité en portrait à 1 600 px) : consigné ici et dans la PR (« imprimer en paysage ou depuis une fenêtre étroite ») ; pas de code.
