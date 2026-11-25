# Créneau d'absorption A3 (#620) : pièces de revue

Branche de travail `claude/creneau-a3`, PR brouillon #623. Plan : fiche « Créneau d'absorption A3 », § 3 de `docs/feuille-de-route.md` (adopté, Q-75-6 (a)).

| Pièce | Étape | Auteur | Statut |
|---|---|---|---|
| `actuary-1-specification-620.md` | 2 : spécification et protocole | `actuary-approfondi`, 25/11/2026 | versée telle quelle ; **PA-1 en attente** |

## Synthèse de la spécification (étape 2)

- **Pistes.**
  - (a) Alpha reçoit l'ensemble figé des colonnes dégénérées, comme les douze autres clés. C'est un contrat partagé : signature de `mw_famille_alpha()` et entrée de `MW_CATALOGUE_MC`. Le domaine d'effet s'étend au carré.
  - (b) La colonne J−1 dégénérée d'un trapèze est simulée par son estimateur direct, nul ou négligeable. La piste remplace la clause « colonne J−1 dégénérée : simulation inchangée (règle) » de l'annotation du 25/11 de l'ADR 0005. σ_boot et l'intervalle changent aussi sur tout trapèze à J−1 dégénérée, I = J + 1 compris.
  - (c) Statu quo documenté.
- **Constat structurant.** Sur le domaine de l'issue, (a) et (b) donnent la même p d'Alpha, la même p de famille M1 et la même p globale (prédiction H3). La mesure ne départage donc pas les deux pistes sur Alpha. Elle décide si chacune est admissible.
- **Critères écrits avant la mesure.**
  - R0 : validité, contrôles I1 à I9.
  - Admissibilité de (b) : Gb1 à Gb4. Admissibilité de (a) : Ga1 à Ga4.
  - Règle de choix : (b) si elle est admissible, sinon (a), sinon (c). La grandeur de Δp n'est pas un critère : E2 est retenu.
- **Protocole de l'étape 3.**
  - Script `mesure-620/mesure_620.R`, adaptation de `mesure_617.R`.
  - Variantes V0, Va et Vb, par substitution dans `environment(run_engine)` seulement.
  - Huit triangles : T0 à T3, K1, KA, `reserve2`, `reserve2_trapeze`.
  - B = 999, graine 20260831, graine secondaire 20261125 sur T1 et T2.
  - Durée estimée : environ 8 minutes (hypothèse).
- **σ_USP.** Il ne change dans aucune piste. Les références devraient rester identiques (hypothèse forte, à prouver à l'étape 6).
- **Budget de `mw:m1d`** (12 800 caractères) :
  - (a) : environ 12 094 ;
  - (b) : environ 12 474 ;
  - (c) : environ 12 897, soit un dépassement d'environ 97, à résoudre par une condensation ou par un relèvement décidé à PA-2.
- **Questions au mainteneur pour PA-1.**
  - PA-1-1 : protocole de mesure.
  - PA-1-2 : ordre (b), puis (a), puis (c).
  - PA-1-3 : lecture du commentaire du 25/11 sous (a) ou (b).
  - PA-1-4 : prototype Va avec A = `NA` quand aucune colonne ne reste.

  Recommandation d'`actuary-approfondi` : approuver les quatre.
- **Critères d'escalade signalés** (non décidés) :
  - choix entre (a) et (b) qu'aucune mesure ne tranche ;
  - clause de l'ADR 0005 remplacée en (b) ;
  - contrat partagé en (a) ;
  - changement de résultat sous (a) et sous (b) ;
  - validité à T = 8 non mesurable.
- **Constats mineurs écartés (ADR 0018)** : C1, C2 et C5 (§ 5 de la spécification), aucun critère. Il n'y a aucun constat marquant.
