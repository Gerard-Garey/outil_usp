# Avis d'actuary (fiche de base), 11/11/2026 : libellé de #502 après le constat 2 du /code-review

**Verdict : (b), libellé à corriger.** Aucun contrôle du script ne borne l'erreur de quadrature ni celle de uniroot() (lecture de `tests/mesure_dw_rho_negatif_t8.R` à ccb5771, l. 28-47, 80-105, 325-372, 396) :
- S0 : formule matricielle de DW contre stat_dw() (100 séries, 1e-12) ; ne touche ni la quadrature ni uniroot().
- S1 : points critiques uniroot() contre dw_p_exacte() < α (300 séries, 0 désaccord) ; même `.imhof_p_sup0()` des deux côtés, donc accord et non contrôle indépendant ; pas de borne.
- N : puissance à ρ = 0 contre α (1e-8) ; sous H0 seulement.
- L : rattachement aux valeurs versionnées à ρ = −0,5 (1e-6), −0,3 et −0,6 (5e-4).
- S-ρ-α : recoupement Monte-Carlo à ρ = 0, −0,9 et −0,99 seulement (erreur-type au plus 7,9e-4 à N = 4e5, critère à 3 erreurs-types).

L'erreur aux autres ρ, et notamment à ρ ≤ −0,999, n'est pas bornée. L'ancien libellé mêlait erreur Monte-Carlo et erreur numérique. La précision « de l'ordre de 1e-3 » proposée par la revue est fausse en mode --essai (N = 2e4) : l'en-tête donne donc l'erreur-type et le critère exacts de l'exécution complète.

Textes fixés : en-tête, occurrence 1 (« non bornee a priori ; elle est verifiee sans etre bornee : niveau a rho = 0 (controle N), accord des points critiques avec dw_p_exacte(), meme quadrature (controle S1), et recoupement par simulation de la section 2 (erreur-type au plus 7,9e-4, critere a 3 erreurs-types) a rho = -0,9 et -0,99 seulement ») ; en-tête, occurrence 2 (« erreur numerique non bornee a priori ») ; sortie (« non bornée a priori, vérifiée sans être bornée par le niveau à ρ = 0 (contrôle N), par l'accord des points critiques avec dw_p_exacte() (contrôle S1, même quadrature) et par le recoupement par simulation (précision de l'ordre de l'erreur-type, section 2) à … seulement »).
