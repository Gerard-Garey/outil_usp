# JS2 : relevés du poste Windows (25/11/2026)

> Versement du début de l'étape 5 de la fiche « Jalon JS2 » (`docs/feuille-de-route.md`, § 3). Les étapes 4a et 4b ont été exécutées par la session principale (IA), en session locale de Claude Code sur le poste du mainteneur, à la demande de celui-ci (handoff du 25/11 de la PR #619).
>
> La batterie a tourné au **SHA de la batterie `1ac9581`** (`Version` 3.1.0), en tête détachée, sur un arbre propre (hors `?? prompt-poste-local.md` et `?? sorties-p/`, fichiers du mainteneur hors dépôt). La tête de branche `e04e8a3` n'en diffère, sous `R/`, `app.R` et `tests/`, que par la constante de `34d07f0`.

## Plateforme

| Élément | Valeur |
|---|---|
| Système | Windows 11 Famille x64, 10.0.26300 (build 26300) |
| R | `R version 4.3.3 (2024-02-29 ucrt)` |
| Locale | `French_France.utf8` (`LC_NUMERIC=C`) |
| Paquets R | `openxlsx` 4.2.9, `zip` 2.3.0 |
| md5 | `R/engine.R` `723277ddfa5736d7411838d15d8dad00`, `R/charger_moteur.R` `5ed6226c768d5ad781ea03a7306ccc11` (valeurs attendues) |

## Synthèse

| Étape | Relevé | Critère | Verdict |
|---|---|---|---|
| 4a | `etape-4a-batterie.md` ; sorties brutes `sortie_*.txt`, `codes_de_sortie.txt` | ADR 0006, annotation du 14/11, sur sept cas | **accepté** : six cas identiques à JS1 ; `reserve2_trapeze` sans écart au-delà de 5,831e-16 |
| 4a, information | `sortie_test_controles_entree.txt` | aucun (information) | 647 assertions, 0 échec |
| 4b | `etape-4b-sources.md` ; séance du 25/11, 18:48:37-18:54:17 UTC | fait nouveau sur une source | **PJ-3** : avis de l'ACPR de conformité aux orientations EIOPA-BoS-25/249 |
| PJ-3, lecture | `regulatory-pj3-avis-acpr.md` | lecture par `regulatory` (routine) | aucun effet sur le moteur ni les résultats ; deux mentions du `.tex` trompeuses ; recommande une correction texte seul dans JS2 |

Points saillants :
- **σ_USP, p-values et verdicts** : aucun changé ; les sept σ_USP sont ceux des références. Pas de PJ-2.
- **Fait nouveau** : l'ACPR s'est déclarée conforme aux orientations EIOPA-BoS-25/249 (avis du registre officiel, fichier du 10/11/2026, page mise à jour le 12/11/2026), sans date d'application. Le `.tex` affirme qu'aucune déclaration n'a été trouvée au 18/11/2026 (l. 10600-10601 et 21664-21665) ; l'avis existait déjà. La recherche du 19/11 (#463) ne l'avait pas trouvée.
- **Les cinq sources ont été consultées le 25/11** ; quatre sont inchangées.

## Décision attendue du mainteneur (PJ-3)

1. **Forme** : (a) correction texte seul du `.tex` dans JS2 (recommandation de `regulatory`, points 1 à 4 et 6 de son § 4), ou (b) issue séparée (corps rédigé au § 4 du rapport).
2. **Point 5 de `regulatory`** (renvoi du § 171 de la notice à une orientation abrogée) : il touche le fond ; s'il est retenu, avis d'`actuary`.
3. **`\dateconsultation`** : 25 novembre 2026 si la correction (a) intègre l'avis ; sinon inchangée.
4. **Lectures L1 à L3** de l'applicabilité des orientations de 2025 en France : décrites par `regulatory`, non tranchées ; aucune ne change un résultat.

## Tri ADR 0018 (proposé, à la fin de l'étape 5)

- **Gardé** : mentions du `.tex` contredites par une source datée (affirmation fausse de la documentation, critère de l'ADR 0018). Traitement selon la décision PJ-3 ci-dessus.
- **Écarté (mineur)** : `docs/suivi-documentation/IV.md`, l. 219, « l'absence de déclaration vaut au 18/11 », à corriger dans la même entrée de `IV.md` que l'étape 5, sans issue.
- Aucune issue urgente ; la sortie du brouillon et l'étiquette attendent la décision PJ-3.
