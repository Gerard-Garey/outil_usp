# Avis amont d'`actuary` sur #509, #498 et #499 (branche K5, 10/11/2026)

> *Rédigé par la session principale (IA).* Les rapports d'origine d'`actuary` (fiche de base, Opus 5.5) ont été rendus le 10/11/2026 dans une session du poste local et n'ont pas été conservés en entier (scratchpad non persistant, Q-54-10). Le texte ci-dessous reprend **mot pour mot** les textes fixés, tels que le handoff `6752459057` de la PR #516 les a consignés ; c'est la seule trace écrite. Le complément du 10/11 (périmètre de la phrase 4) est le rapport d'`actuary` rendu dans la session cloud, résumé fidèlement.

## #509 : `ref` de F. et de M4 dans `GROUPES`

Libellé retenu : « hors hypothèses de l'annexe XVII » pour F. et M4 ; G., M6 et LC inchangés. Mis en œuvre par `c5f54a1`.

## #498 : règle des verdicts

`engine_regle_verdicts(alpha)` dans `R/engine.R`, hors `run_engine()`, rend `character(4)` ; `stop(call. = FALSE)` si α non numérique, non scalaire, non fini ou hors ]0, `SEUIL_ECHEC_SENS_REJETER`[ (même domaine et libellé que `.engine_verifier_usage()`) ; valeurs au format décimal français, 15 chiffres significatifs (17 si besoin), sur le modèle de `.engine_saisie()` avec `decimal.mark = ","` ; α/2 calculé par `alpha / 2` ; accents en échappements `\u…`.

1. `Règle des verdicts au seuil α = %s, appliquée à la p-value retenue p de chaque test, selon le sens du test indiqué sur sa ligne.` (α)
2. `Sens « rejeter » (le rejet de H0 est le résultat recherché) : OK si p < %s ; ALERTE si %s ≤ p < %s ; ECHEC si p ≥ %s.` (α, α, seuil, seuil)
3. `Sens « ne pas rejeter » (le non-rejet de H0 est le résultat recherché) : ECHEC si p < %s (α/2) ; ALERTE si %s ≤ p < %s ; OK si p ≥ %s.` (α/2, α/2, α, α)
4. `Portent le verdict INFO, qui n'est pas un verdict : les lignes de diagnostic, dont les tests inopérants (plus petite p-value atteignable ≥ α : aucun verdict possible), les lignes non applicables et les tests sans p-value retenue. Le verdict ne dépend que de p, de α et du sens ; les mentions du commentaire (ECHEC inatteignable, verdict sensible à l'aléa de simulation) ne le modifient pas.`

Test unitaire demandé : grille de p contenant les bornes, zone du texte = verdict d'`add()` dans les deux sens (p = α sens « rejeter » → ALERTE ; p = 0,30 → ECHEC ; p = α/2 sens « ne pas rejeter » → ALERTE ; p = α → OK) ; valeurs injectées présentes ; α hors domaine refusé.

Placement : en tête de l'onglet Tests avec α du résultat (`res$metadata$alpha`), bloc État, rapport figé ; α du panneau différent de celui du résultat signalé ; colonne Sens en Synthèse (décision du mainteneur du 10/11).

**Complément du 10/11 (session cloud), question de `coder` sur la phrase 4.** Les contrôles de `res$controles` (`usp_controle_donnees()`, `usp_controles_numeriques()`) portent des verdicts OK / ECHEC issus de booléens, sans p ni α. Avis : la règle est placée **uniquement** en tête du tableau des tests (onglet Tests) et de la section des tests du rapport figé, jamais au-dessus des contrôles ; texte inchangé (la phrase 1 borne la portée à « chaque test » ; les contrôles ne sont pas des tests au sens de `CONTEXT.md`). Une légende des contrôles demanderait une autre fonction et une issue distincte, non proposée. Relecture des quatre phrases implémentées contre le code d'`add()` : aucun écart de fond. Mis en œuvre par `4f11194` et `26878fb` ; conformité mot pour mot au texte ci-dessus vérifiée par la session (`engine_regle_verdicts(0.10)`).

## #499 : repère de profondeur

Seuil 10 gardé. Chaînes (ASCII, comme les voisines) :

- `engine_valider_donnees()`, dans `paste()` : `"T = %d : lois asymptotiques peu fiables."`, `"Privilegier les p-values exactes ou Monte-Carlo."`, `"Une p-value elevee ne demontre pas la validite de l'hypothese :"`, `"elle ne permet pas de la rejeter."` ;
- `mw_valider_triangle()`, dans `paste()` : `"I + 1 = %d annees d'accident : estimateurs de variance tres bruites en fin de triangle."`, `"Une p-value elevee ne demontre pas la validite de l'hypothese :"`, `"elle ne permet pas de la rejeter."`.

Débuts de chaîne lus par `test_controles_entree.R` inchangés. Puis suppression d'`avertissement_T()`, de `bandeau_T` et de l'appel du rapport figé ; `.tex` (repères T < 10 et I + 1 < 10) : retouche courte par `docwriter`. Décision du mainteneur du 10/11 : phrase ajoutée aux **deux** repères. Mis en œuvre par `1b2f412`.

**Erreur relevée dans la fiche K5, étape 4** : « aucun repère de profondeur en Merz-Wüthrich après la suppression » est faux ; `mw_valider_triangle()` porte déjà le repère I + 1 < 10. À corriger dans `docs/feuille-de-route.md` au point suivant.
