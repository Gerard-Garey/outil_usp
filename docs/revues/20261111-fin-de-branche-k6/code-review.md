# /code-review (effort medium) sur `git diff main...HEAD` (tête ccb5771, main 12872c3), 11/11/2026

Huit constats rendus par la skill (texte traduit et résumé fidèlement ; traitement en fin de fichier).

1. **README.md:171** — le README annonce toujours des échecs Windows dus à #477, #478 et #479, que la branche corrige ; paragraphe non mis à jour.
2. **tests/mesure_dw_rho_negatif_t8.R:33** — « erreur numérique … contrôlée par le recoupement de la section 2 » exagère : recoupement Monte-Carlo à deux valeurs de ρ, précision ~1/√N, ne borne pas une erreur de quadrature ni les points uniroot() ; confusion erreur Monte-Carlo / erreur numérique.
3. **docs/latex/CONVENTIONS.md:150** — modifié dans le commit 61a7be2 de préfixe `tests:` ; CLAUDE.md attribue `docs/` au préfixe `docs:`.
4. **tests/controle_doc_nd.R:1078** — sous `--bloquant` avec fichier manquant, la branche de refus imprime (a) mais n'émet pas l'annotation `::warning` de GitHub Actions pour les occurrences de la liste A, que le chemin normal émet.
5. **tests/controle_doc_nd.R:1080** — appel `nd_imprimer_motifs(nd_controle_motifs(...))` dupliqué entre la branche de refus et le chemin normal ; risque de dérive. Forme suggérée : lancer (a) une fois, avant le contrôle de `manque`.
6. **tests/controle_doc_nd.R:613** — la ligne d'exception imprime le budget deux fois (« budget 13000 caracteres » et « source au plus 13 000 caracteres »).
7. **R/display_helpers.R:95** — la branche scientifique de fmt_p() refait la substitution de la virgule au lieu de passer par .num_fr() ; `ifelse(is.finite(v), out, "–")` final redondant.
8. **tests/unitaires/test_controle_doc_nd.R:476** — sous Windows `env_fils` est vide : les assertions de restauration de LC_ALL après lancer() y passent trivialement, et le fils hérite de `LC_ALL=valeur_initiale` (locale invalide).
