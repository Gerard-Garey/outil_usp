# Compte rendu de `coder` sur #566 (étape 7 de K2b)

> Versé par la session principale (condensé fidèle). Fiche de base. 13/11/2026, sur `796b481`. Scripts, PDF et relevés dans le scratchpad de la session (`c566/`), non versés.

## Cause
Plotly fixe en pixels la largeur de `.svg-container` et des `svg.main-svg` au dernier affichage (1 170 px pour un graphique pleine largeur à 1 600 px) ; la zone utile fait 718 px en A4 portrait, 1 047 px en paysage ; Chromium ne déclenche pas le redimensionnement de plotly (différé de 100 ms) avant la capture ; la page entière était en outre comprimée (« Parametres » : 65,6 pt avant, 98 pt après, `pdftotext -bbox`).

## Correctif (`app.R`, +54 lignes)
- Script d'en-tête : à `beforeprint` (et au passage de `matchMedia('print')`), pose sur chaque `.js-plotly-plot` l'attribut `data-impression`, deux variables CSS (largeur et rapport naturels) et un `viewBox` sur ses `svg.main-svg` ; retrait à `afterprint`.
- `@media print` : `.js-plotly-plot { break-inside: avoid }` ; pour `[data-impression]`, hauteur automatique, `.svg-container` à `width: 100% !important`, `max-width: var(--impr-largeur)`, `aspect-ratio: var(--impr-ratio)`, SVG à 100 % × 100 %. Le conteneur n'est jamais agrandi.
- `viewBox` plutôt que `Plotly.relayout` : la largeur de page n'est pas connue à `beforeprint` (1 049 px mesurés au `change`, non final).

## 42 PDF (shiny 1.8.0 / plotly 4.10.4, 1 600 px, A4, `B = 99`)
Mesures : (a) graduation du DOM absente du texte du PDF ; (b) pixels non blancs sur les 4 derniers px de la zone utile ; (c) examen visuel.
- **Avant** : 16 / 42 avec graduation absente ; 26 / 42 au bord (dont les 16) ; 14 indemnes.
- **Après** : 0 / 42 graduation absente ; 0 / 42 au bord ; aucune coupure vue sur les planches. `reserve2` à 960 px : 0 / 14.

## Écran
Largeurs des conteneurs plotly à 960 et 1 600 px, trois méthodes : identiques avant / après (86 relevés). Captures d'écran de six sous-onglets, version d'origine contre corrigée : `reserve1` et `reserve2` 24 / 24 identiques ; `premium` 18 / 24, six écarts de 3 × 4 px au coin haut droit à 960 px avant impression seulement. Après impression : aucun `data-impression` ni `viewBox` résiduel.

## Contrôle sous shiny 1.14.0 / plotly 4.12.1
42 PDF : 0 graduation absente, 0 au bord ; six PDF regardés, entiers ; largeurs d'écran identiques.

## Tests
`test_application.R` (1.8.0) : 237 / 237 ; `concordance_doc_moteur.R --strict` : 0 écart. Aucun test d'impression n'existe ; assertion de lecture du source proposée.

## Limites et effets de bord
- Chromium `page.pdf()` seul (ni Firefox, ni WebKit, ni boîte de dialogue, ni aperçu de Chrome).
- Réduction proportionnelle d'un graphique plus large que la zone utile, texte compris (facteur 0,61 à 1 600 px en portrait, graduations ≈ 5,5 pt) ; pas de réduction à 960 px.
- Hors périmètre : surface 3D « Fonction objectif » (WebGL) vide dans les PDF avant comme après ; titres de carte isolés en bas de page dans l'onglet Calibration (un cas nouveau après correctif : page 2 portrait de premium) ; pagination 66 pages au lieu de 61.

## Surface d'impact documentaire
Aucune (`grep` sur `imprim`, `beforeprint`, `media print`, `A4` dans le `.tex`).
