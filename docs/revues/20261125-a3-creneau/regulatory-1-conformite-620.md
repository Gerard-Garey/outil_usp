# A3, étape 7 : contrôle de conformité de #620 (`regulatory`, routine, 26/11/2026)

*Rédigé par l'agent `regulatory` (IA), sans écriture dans le dépôt ; versé tel quel par la session principale. Périmètre : commits `36e2041..aa4f663` (code) et `a147700` (`.tex`).*

**Verdict : conforme, aucun écart bloquant, majeur ni mineur dans le périmètre (a147700, 36e2041..aa4f663).** Aucune issue proposée. Un constat mineur hors diff figure au point 4.

## Texte de référence (consolidé du 14.11.2024, annexe XVII, section D, formules lues en rendu graphique)
- **D(4)** : σ_(res,s,USP) = c · √MSEP / Σ_{i=0..I}(Ĉ_(i,J) − C_(i,I−i)) + (1 − c) · σ_(res,s).
- **D(5)** : la MSEP sur i = 1..I. Elle lit Q̂_{I−i} et Q̂_j, avec S_{I−i}, S_j et S′_j.
- **D(5)(d)** : Q̂_j = σ̂²_j / f̂²_j.
- **D(5)(d)(ii)** :
  - première ligne, pour j = 0..J−2 : σ̂²_j = (1/(I−j−1)) Σ_{i=0..I−j−1} C_(i,j)(C_(i,j+1)/C_(i,j) − f̂_j)² ;
  - seconde ligne, pour j = J−1 : σ̂²_j = min(σ̂²_{J−2}, σ̂²_{J−3}, σ̂⁴_{J−2}/σ̂²_{J−3}).
  - Le texte ne contient aucune condition sur I, ni aucune disposition sur la simulation des tests.

## Matrice

| Élément | Extrait / fonction | Verdict |
|---|---|---|
| Calcul de σ_USP (D(4)) et de la MSEP (D(5)) | Seules 4 lignes non commentées du diff `36e2041..aa4f663` changent : le prédicat `.mw_simulation_sigma_direct()`, le corps de `.mw_cas_sigma_direct()`, le gabarit `FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE` et la légende `MW_USAGE_SIGMA_DEGENERE`. `mw_ajuster()`, `mw_msep()` et `mw_parametre()` ne changent pas. `mw_bootstrap()` ne passe la copie `aj_sim` (σ²_{J−1} ← estimateur direct) qu'à `.mw_tirer_triangle_valide()`. La MSEP observée et le σ* de chaque réplication (`mw_msep(ab)` sur le triangle réajusté) gardent la règle de minimum. | **Conforme.** Contrôle : `docs/tableaux/20261126-issue620-colonne-jm1-degeneree.md` constate σ_USP, `parametre`, `msep` et `ajustement` `identical()` avant et après sur T0 à T3 (par exemple 0,04757970671 → 0,04757970671). La batterie de reproductibilité (7 cas) passe sans régénération. |
| Seconde ligne de D(5)(d)(ii) appliquée à j = J−1 quel que soit I | `mw_ajuster()`, inchangée. Le commentaire d'en-tête mis à jour (l. 13109 sq.) rappelle « s'applique quel que soit I ». | **Conforme.** |
| `FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE` | « la regle de minimum s'applique a sigma2_(J-1) par prescription de l'annexe XVII, D(5)(d)(ii), seconde ligne […] Par convention de l'outil, non reglementaire, l'estimateur direct sert a simuler la colonne J-1 […] ; il n'entre ni dans la MSEP ni dans sigma(res,s,USP) » | **Conforme.** La citation désigne bien la seconde ligne (j = J−1). La convention est qualifiée explicitement de non réglementaire. La nouvelle légende `MW_USAGE_SIGMA_DEGENERE` porte « (convention) » et attribue la MSEP et σ_USP à la règle : conforme. |
| `sec:boot-mw`, alinéa « Colonne J−1 d'un trapèze » | Phrases ajoutées sur le carré et sur la colonne dégénérée. Le passage « **Convention de l'outil, non réglementaire** » s'applique désormais aux deux cas du trapèze. La phrase « D(4) et D(5) » n'est pas modifiée et liste la MSEP, σ_USP et le σ*. Le Statut ajoute « niveau non mesuré » pour la colonne dégénérée. | **Conforme.** Aucune lecture de D(4) ni de D(5) n'est altérée, et rien ne présente la simulation comme prescrite. |
| `sec:trapeze-niveau`, premier alinéa (l. 16160-16170) | La citation « première ligne de D(5)(d)(ii) appliquée à j = J−1 (I − J degrés de liberté), et non par la valeur de la règle » n'est pas modifiée. La phrase suivante dit maintenant « […] et à la simulation de cette colonne par le bootstrap, par convention de l'outil ; il n'entre ni dans f̂_j, ni dans Ĉ, ni dans Q̂_j, ni dans la MSEP, ni dans σ_USP ». | **Conforme.** L'usage de la formule de la première ligne hors de son domaine (j ≤ J−2) est présenté comme un estimateur de l'outil, non comme une prescription. |
| `mw:m6sig`, rubrique 3 (l. 19203-19220) | La nouvelle dernière phrase dit « aucun résidu retenu ; l'estimateur sert aussi à la simuler ». | **Conforme.** Le « aussi » renvoie à la phrase précédente, qui qualifie la simulation de « convention de l'outil, non réglementaire ». Le texte situe en amont que l'`estim` reste la règle et que l'estimateur n'entre ni dans la MSEP ni dans σ_(res,s,USP). Remarque de rédaction, sans verdict : la qualification « non réglementaire » n'est pas répétée dans cette phrase. |
| Paragraphe σ̂²_{J−3} = 0 (l. 15801-15806) | « elle est simulée avec cet estimateur, que la règle soit nulle ou non (section boot-mw) ; cette convention ne touche ni la MSEP ni σ_USP ». | **Conforme.** La lecture littérale du minimum (valeur 0 quand σ̂²_{J−3} = 0) reste celle du texte, et la MSEP garde Q̂_{J−1} = 0. Imprécision de rédaction, non réglementaire et sans verdict : « la colonne J−1 fournit des résidus » ne réserve pas le cas dégénéré, où aucun résidu n'est retenu. Ce n'était pas réservé non plus avant le commit. |
| Index des fonctions (l. 1793 sq., 1874 sq.) | Descriptions des fonctions alignées sur le nouveau prédicat. | **Conforme.** Elles ne contiennent aucune référence réglementaire. |

## Constat mineur hors diff (non introduit par a147700)
1. `sec:boot-mw` (l. 6567-6569, phrase inchangée) dit : « la règle de minimum reste appliquée partout où elle entre dans le calcul de D(4) et D(5) : f̂_j, Ĉ, Q̂_{J−1}, la MSEP… ». Selon D(4)(c), f̂_j et Ĉ_(i,j) ne dépendent pas de σ̂²_{J−1}. Seuls Q̂_{J−1} (D(5)(d)), la MSEP et σ_USP lisent la règle. La liste se comprend comme « les grandeurs de D(4)/D(5) restent celles du calcul observé », mais la lettre suggère que la règle entre dans f̂_j et Ĉ. Cela n'a aucun effet sur σ_USP, un verdict ou une p-value.
   - Critère ADR 0018 : **aucun**, ou au plus **E5** (affirmation imprécise de la documentation sur le code) si la session juge la formulation fausse plutôt qu'elliptique.
   - Preuve : D(4)(c), formules de Ĉ_(i,j) et f̂_j (rendu graphique du consolidé), comparées à D(5)(d) (Q̂_j = σ̂²_j / f̂²_j).

*Tri par la session* : formulation jugée elliptique, non fausse (la phrase dit « partout où elle entre ») ; écarté comme mineur (ADR 0018), ligne au corps de la PR.

Fichiers examinés : `R/engine.R` (l. 13836-13960, 16230-16245, 16425-16475, `mw_msep()` l. 13994) ; `docs/latex/doc_tests_usp.tex` (l. 1793-1880, 6547-6606, 15790-15806, 16159-16170, 17297-17312, 17366-17376, 19195-19220) ; `docs/tableaux/20261126-issue620-colonne-jm1-degeneree.md`.
