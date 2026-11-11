# K4 — étape 1 : rejeu des constats et inventaire de #527 (11/11/2026)

Rapports de `coder` (lecture seule, aucun fichier du dépôt modifié), versés par la session de K4.

- `rejeu.md` : rejeu des sept constats (#528, #506, #519, #533, #503, #493, #527) et du repli Q-56-6 (Refs #420) sur `R/engine.R` de `12872c3`.
- `inventaire_527.md` : messages du moteur restitués par l'application ; 45 erreurs ou refus dans le périmètre, plus 14 avertissements à trancher ; gardes internes écartées avec motif.
- `scripts/` : scripts d'essai cités par les deux rapports, à lancer depuis la racine sous `LC_ALL=C.UTF-8`.

Synthèse : l'inventaire dépasse le seuil d'une vingtaine de messages fixé par le plan ; la scission de #527 (Q-58-2 (c)) est soumise au mainteneur avant l'avis amont d'`actuary`.

## Étape 2 — avis amont d'`actuary-approfondi` (11/11/2026)

- `actuary-avis-amont.md` : textes fixés mot pour mot pour les sept issues et le repli Q-56-6 ; règle R-527 et tableau des 59 messages de #527 (26 changent) ; questions Q-A à Q-E au mainteneur ; constats hors périmètre R-1 à R-4.
- `scripts-actuary/` : mesures de longueur et de nombre de phrases, lignes non applicables de #533.

Écarts au plan signalés : #528 étendu à `reserve2` (deux H0 de M5) ; #533 limité aux deux lignes de suites ; commit des avertissements de #527 sans patch de référence attendu ; étape 8 (#493) étendue aux trois points du 08/11 sur décision du mainteneur.
