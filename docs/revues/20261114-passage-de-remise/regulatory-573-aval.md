# Contrôle aval de `regulatory` sur #573 (commit `c5a1953`), 14/11/2026

Branche `claude/passage-de-remise`, tête `98d8741`. Avis seul.

**Verdict global : conforme.** Les huit motifs (deux méthodes × deux formes × deux bornes) respectent le visa « suppression pure ». Les renvois réglementaires sont exacts et aucun énoncé ne dépasse le texte.

## Méthode
- Diff de `c5a1953` lu : `phrase_res2`, ses deux usages et le passage du commentaire d'en-tête sont supprimés ; prédicat (`bord`, `bord_ensemble`, `refus`) inchangé.
- Moteur chargé par `charger_moteur()` (`LC_ALL=C.UTF-8`) ; `usp_valider_ajustement()` appelée sur des ajustements fictifs (forme 1 : γ = −12 et γ = 3, KKT non ; forme 2 : γ = −11,5 et γ = 2,5, KKT non, au moins un démarrage sur une borne) : huit `ok = FALSE`.
- Motif `premium` identique au caractère près avant et après (la phrase n'y figurait pas).

## Libellés finaux de `reserve1`
Partie commune : « L'outil ne calcule pas de parametre sur ces donnees (article 220, paragraphe 1, point b)), qui ne permettent d'etablir ni la distribution log-normale ni l'adequation de l'estimation de la vraisemblance maximum (C(2)(e), iii et iv ; article 219, paragraphe 1, point d)). », suivie directement de « Verifier… ».

| Cas | Fin du motif | Verdict |
|---|---|---|
| Forme 1, borne basse | « Verifier que y_t est observe (C(1)(a)) et non deduit de x_t par un coefficient fixe. » | conforme |
| Forme 1, borne haute | « Verifier les unites, la correspondance des annees et les valeurs aberrantes (C(1) et C(2)(a)). » | conforme |
| Forme 2 | « Verifier que y_t est observe (C(1)(a)) et non deduit de x_t par un coefficient fixe, ainsi que les unites, la correspondance des annees et les valeurs aberrantes (C(1) et C(2)(a)). » | conforme |

Motifs `premium` : mêmes textes avec la section B et l'art. 220(1)(a) ; aucune mention de la méthode n° 2 ; conformes.

## Renvois (version consolidée du 14.11.2024)

| Renvoi | Verdict |
|---|---|
| Art. 220(1)(a) / (b) | exacts ; la n° 2 n'est plus présentée comme un repli |
| Art. 219(1)(d) | exact (rend obligatoires B(2)(g) et C(2)(e)) |
| Annexe XVII, B(2)(g) / C(2)(e), iii et iv | exacts |
| B(6) / C(6), B(4) / C(4) | exacts ; BORNES_GAMMA dites « bornes de l'outil, non reglementaires » (γ n'est pas borné par le texte) |
| B(1)(a) / C(1)(a), B(1), B(2)(a) / C(1), C(2)(a) | exacts |

## Reste, hors de ce contrôle
- `.tex` (`docwriter`, étape 7) : l. ~4398 désormais faux par rapport au code ; l. ~4444 (« prévoyant aussi ») ; puce de `sec:mw`. Contrôle aval de `regulatory` sur ce diff du `.tex` (étape 8).
