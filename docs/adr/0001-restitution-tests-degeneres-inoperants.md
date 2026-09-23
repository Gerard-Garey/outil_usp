---
status: accepted
date: 2026-09-21
---

# Les tests dégénérés ou inopérants sont restitués comme diagnostics, pas retirés

À T = 8, certains tests ne peuvent rien conclure : leur statistique est constante par construction dans le cas courant (centrage et variance unitaire des résidus standardisés quand δ̂ est au bord de [0, 1], issues #3 et #5) *[formulation amendée le 22/09/2026 : la condition exacte est « π̂_t constant », voir l'amendement ci-dessous]*, ou leur plus petite p-value atteignable dépasse le seuil α retenu pour le calcul (Cox-Stuart, suites). Nous les restituons comme **diagnostics** — valeur affichée, sans verdict, avec la raison et, pour un test inopérant, la p-value minimale atteignable — plutôt que de les retirer ou de les garder comme tests. Le dossier ACPR montre ainsi que la vérification a été examinée et pourquoi elle ne porte pas de verdict, sans donner la fausse assurance d'un « OK » impossible à perdre.

## Considered Options

- **Retirer ces tests** : écarté, la trace de l'examen disparaîtrait du dossier.
- **Les garder comme tests marqués « non applicable » au bord** : écarté, un test applicable seulement hors du cas courant à T = 8 induit le lecteur en erreur.
- **Seuil fixe de 0,10 pour qualifier un test d'inopérant** : écarté au profit du α du calcul, cohérent avec le verdict qui en dépend déjà ; α figure dans les métadonnées de chaque calcul.

## Consequences

Le statut test / diagnostic d'une vérification peut changer avec les données et avec α ; il est déterminé par le moteur et documenté. Voir `CONTEXT.md` (test, diagnostic, test inopérant).

---

## Amendement du 22 septembre 2026 — la condition de dégénérescence est « π̂_t constant », non « δ̂ au bord de [0, 1] »

### Ce que disait l'ADR

Le premier paragraphe ci-dessus qualifie le centrage et la variance unitaire des résidus standardisés de statistiques « constante[s] par construction dans le cas courant », avec pour condition « quand δ̂ est au bord de [0, 1] ». Cette formulation, conservée telle quelle ci-dessus, est fausse sur deux points ; elle avait été reprise par `CONTEXT.md` (entrée « Statistique dégénérée », « quand δ̂ = 1 », « loi simulée constante par construction ») et corrigée dans le moteur par le jalon J1a (PR #17) sans que l'ADR ne suive. Issue #27, points 3 et 4.

### Ce qui est faux, et ce qui est mesuré

**1. La condition.** La pondération du modèle réglementaire est π_t = 1 / ln(1 + e^{2γ} (δ + (1 − δ) x̄ / x_t)) (`usp_pi()`, `R/engine.R` l. 210-211). Elle est constante en t si, et seulement si, δ = 1 **ou** les volumes x_t sont constants. « δ̂ au bord de [0, 1] » inclut δ̂ = 0 avec des volumes variables, où π̂_t varie et où aucune des deux égalités Σ z_t = 0, Σ z_t² = T ne tient. Mesuré sur les données du dépôt tronquées à T = 5 (`run_engine()`, méthode `premium`, graine 20260831) : δ̂ = 0, `delta_au_bord = TRUE`, amplitude relative de π̂_t 14,7 %, moyenne(z) = −0,0149, Σ z² = 4,989 pour T = 5. Inversement, à volumes constants (x_t ≡ 100, mêmes y_t) : δ̂ = 0, π̂_t constant, moyenne(z) = 2e-17, var(z) = 1,142856 = T/(T − 1) à 1e-6 près. C'est la constance effective de π̂_t qui décide, pas la position de δ̂ ; le moteur la teste par `pi_constant <- diff(range(fit$pi)) <= 1e-9 * mean(fit$pi)` (`usp_tests()`, l. 1457) et distingue trois libellés (π̂_t constant ; δ̂ au bord mais π̂_t variable ; δ̂ intérieur). [*Annotation du 23/09/2026 : depuis l'issue #31 (commit `4301c6d`, branche B), le drapeau n'est plus calculé sur l'étendue observée des π̂_t mais sur sa cause, par `usp_regime(delta, x, tol = TOL_DELTA_BORD)` : `pi_constant = delta >= 1 − tol || volumes_constants`, avec `volumes_constants = diff(range(x)) <= tol · mean(x)` et une tolérance unique `TOL_DELTA_BORD = 1e-6`, la même que pour `delta_au_bord` (avis `actuary` : au-dessus de la résolution de L-BFGS-B, ~1e-9 en ajustement complet, ~1e-7 en réajustement rapide). Le test sur l'étendue à 1e-9 laissait, pour δ̂ dans [1 − 1e-6 ; 1 − 3,9e-9) à volumes variables, affirmer « δ au bord mais π_t n'est PAS constant ». Les trois libellés sont inchangés ; aucun résultat ne change sur les cas de test. Voir `CONTEXT.md`, « Volumes constants » et « Tolérance de bord ».*]

**2. La loi simulée.** Elle n'est pas « constante par construction ». Sous le bootstrap paramétrique, chaque réplication ré-estime δ*, et la loi simulée est un **mélange** : sur les données de test (T = 8, δ̂ = 1, B = 999, graine 20260831), 493 réplications ont δ* = 1 et une moyenne des z* d'écart-type 2,2e-16 (zéro machine), 460 ont δ* = 0 et un écart-type de 1,7e-02 (composante diffuse), 46 un δ* intérieur (commentaire de `.stats_bootstrapables()`, l. 904-913 ; effectifs recalculés le 22/09/2026 sur le poste local, identiques). Ce n'est pas le mélange qui prive la p-value de sens, mais l'**atome en la valeur observée** : la statistique observée étant elle-même un zéro machine, la p-value bilatérale se décidait au signe du bruit d'arrondi sur près de la moitié des réplications — d'où trois valeurs selon la plateforme (0,742 sous Windows, ≈ 0,56 sur la CI, 0,674 sous Linux R 4.3.3 ; issue #3). Le défaut est plus grave que celui annoncé : une loi constante donnerait une p-value dénuée de sens mais stable ; un atome donne une p-value qui change avec la machine.

**3. Les deux égalités n'ont pas le même statut** quand π̂_t est constant. Σ z_t = 0 découle de la forme fermée de ln β dans `usp_noyau()` : identité algébrique, vraie à la précision machine que l'optimiseur ait convergé ou non. Σ z_t² = T suppose la dérivée en γ effectivement annulée : elle ne tient qu'à la tolérance d'arrêt près et tombe si γ̂ bute sur une borne de [−12, 3] (mesuré sur les données de test, δ̂ = 1, γ̂ = −1,93 intérieur : Σ z² = 7,9999946, var(z) = 1,1428564 contre T/(T − 1) = 1,1428571). C'est donc la condition en γ, et non celle en ln β, qui rive la variance : Σ √π̂_t z_t = 0 ne dit rien de Σ z_t². Le libellé du diagnostic diffère donc entre les deux lignes (`contrainte("centrage")`, `contrainte("variance")`, l. 1476-1502) ; un même message pour les deux faisait affirmer une chose fausse sur le centrage dans la colonne « commentaire » destinée au dossier.

### Décision

1. Dans le premier paragraphe du présent ADR, lire : « leur valeur observée est fixée par l'estimation (centrage et variance unitaire des résidus standardisés : grandeurs rivées par l'estimation, la première par la condition en ln β, identité algébrique Σ √π̂_t z_t = 0 vraie dans tous les cas, la seconde par la condition en γ, qui ne tient qu'à un optimum intérieur ; statistiques dégénérées, respectivement nulle et égale à T/(T − 1) à la tolérance d'arrêt près, lorsque π̂_t est constant, c'est-à-dire δ̂ = 1 ou volumes x_t constants — issues #3, #5, #27) » à la place de « leur statistique est constante par construction dans le cas courant (centrage et variance unitaire des résidus standardisés quand δ̂ est au bord de [0, 1], issues #3 et #5) ».
2. La décision de fond — restitution comme **diagnostic**, sans verdict — est inchangée. Sa portée est précisée : pour ces deux lignes, le statut de diagnostic ne dépend **pas** des données, parce que chacune des deux conditions du premier ordre tient à tout optimum intérieur, indépendamment des données ; seul le libellé change avec la constance de π̂_t. La phrase « Le statut test / diagnostic d'une vérification peut changer avec les données et avec α » des Conséquences ne vaut donc que pour les tests inopérants (Cox-Stuart, suites), et pour la ligne M6 de concentration de la réserve (PR #18).
3. Aucune p-value n'est retenue pour ces diagnostics, ni exacte, ni Monte-Carlo, ni asymptotique ; le repli sur la loi nominale est interdit (dernière branche de `add()` dans `usp_tests()`, l. 1129-1131 ; issue #23 ; `CONTEXT.md`, entrée « P-value retenue »).
4. Le vocabulaire est fixé dans `CONTEXT.md` : « Grandeur rivée par l'estimation » (le cas général), « Statistique dégénérée » (le cas π̂_t constant, loi simulée à atome). Le terme « dégénéré » du titre du présent ADR est conservé dans ce sens restreint.

### Conséquences

Les fiches « Centrage » et « Variance unitaire » du document LaTeX (jalon J1a, PR #17, puis #23) portent déjà la condition exacte et le mécanisme du mélange à atome ; le présent amendement aligne l'ADR sur elles, il ne change ni le code, ni un résultat, ni une référence de non-régression. Issues : #27 (motif), #3 (mécanisme mesuré), #5 (§ 2, identifiabilité de δ), #23 (règle de sortie de la hiérarchie). Voir aussi ADR 0003 (catalogue des statistiques Monte-Carlo, dont `MeanZ` et `VarZ` sont sorties) et ADR 0006 (l'écart de `MeanZ` entre plateformes relève de cet atome, non de la dérive d'ordre 1e-7 qui y est décrite).
