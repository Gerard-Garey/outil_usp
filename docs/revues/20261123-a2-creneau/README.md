# A2, créneau d'absorption : rapports versés (23-25/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/creneau-a2`, PR #614, base `8d7bf2f` (fusion de S7, PR #613). Issues #612, #608 et #615 ; `Refs` #463. Plan : soixante-treizième point de `docs/feuille-de-route.md`, fiche « Créneau d'absorption A2 » ; décisions Q-73-1 à Q-73-6 (23/11), PA-1 (23/11), PA-2 (25/11) et décisions du 25/11 sur l'étape 8.

## Contenu du dossier

| Fichier | Auteur, étape | Objet |
|---|---|---|
| `audit-lecture-608.md` | `audit`, étape 1b | lecture de #608 : ordre résolution / `setwd()`, cas résiduel |
| `mesure_608.R`, `sortie_mesure_608.txt` | `coder`, étapes 1b et W | script de mesure du cas résiduel ; sortie au poste Windows |
| `audit-lecture-W-608.md` | `audit`, étape W | lecture de la mesure : **non reproduit** |
| `actuary-1-protocole-612.md` | `actuary-approfondi`, étape 1 | protocole de mesure de #612, critères K0 à K4, règles R0 à R-V0 |
| `actuary-2-conformite-script-612.md`, `actuary-3-conformite-reprise-612.md` | `actuary`, étape 2 | conformité du script et de sa reprise au protocole |
| `audit-leger-script-612.md`, `audit-leger-reprise-612.md` | `audit`, étape 2 | audits légers du script de mesure |
| `sonde-S-constat-1-provisoire.md`, `sortie_sonde_S.txt` | session, étape 2 | sonde du constat (1) (origine de #615) |
| `actuary-4-lecture-mesure-612.md` | `actuary-approfondi`, étape 4 | lecture de la mesure L-A : R-V2 confirmée, **V2 recommandée** ; erratum « σ² contre σ_A » |
| `actuary-5-specification-615.md` | `actuary`, étape 6 | spécification de #615 (variante P1), **abandonnée le 25/11** |
| `rejeu_sonde_S_615.R`, `rejeu_sonde_S_615.txt` | `coder-approfondi`, étape 6 | rejeu du bloc S sous P1 (historique de `e4ecb16`) |
| `actuary-6-textes-v2.md`, `regulatory-1-mention-m6-v2.md` | `actuary`, `regulatory`, étape 6 | textes de V2 ; renvoi à D(5)(d)(ii) conforme |
| `actuary-7-visa-tex-etape8.md` | `actuary-approfondi`, étape 8 | **refus** du diff du `.tex` (M1 à M3, m1 à m6) ; P1 réfutée ; retour à la règle d'avant #615 recommandé |
| `mesure-ecarts-615/` | `audit`, étape 8 | précision en double des écarts de facteurs d'une colonne quasi dégénérée (arithmétique rationnelle exacte) |

## Synthèse

### #608 (étapes 1b, W, 5)
- Le constat n'est pas reproduit au poste Windows (`9fbe3f5`, lecture `6e4a59f`). Correction limitée au commentaire de `.xlsx_chemin_sortie()` (`6e871f2`), branche « non reproduit » de Q-73-2 (a) ; sept cas au seuil 0.

### #612 (étapes 1 à 4, PA-1, PA-2, 6, 7)
- Mesure L-A hors CI, 1 787 tranches en 18 segments, INTEGRITE OK (`77f6d81`) ; règle R-V2 déclenchée mécaniquement, confirmée sur le fond par `actuary-approfondi` (`78cd9e3`).
- PA-2 (25/11) : cas (B), variante V2 (colonne J−1 d'un trapèze simulée avec l'estimateur direct) ; ADR 0005 annoté (`0f19b10`) ; code `414e723`, textes `acfc950` après deux majeurs d'`app-review` sur le rendu réel.
- Effet sur `reserve2_trapeze` : σ_USP, p-values et verdicts identiques ; σ_boot, `ic_bootstrap`, `stats_boot` (PenteIntra, Alpha), `boot_reperes`, `usage_sigma` et détail M6 changent ; référence régénérée par la CI (tableau dans `docs/tableaux/`).
- Documentation : `ea3bcff`, reprise `4bd2850` et `4100d46` après l'étape 8.

### #615 (étape 6, puis retour)
- P1 (`e4ecb16`, spécification `6f9470f`) excluait d'une réplication les colonnes devenues dégénérées. À l'étape 8, `actuary-approfondi` réfute sa prémisse (résidus de « bruit d'arrondi ») : ce sont de vrais tirages (signes et rangs exacts) et P1 rend ExpVar libéral de façon certaine (K variable).
- **Décision du mainteneur du 25/11** : retour à la règle d'avant #615 (ensemble figé seul, K constant), garde `r = numeric(0)` gardée (`b50a5e0`, audit léger conforme avec réserves ; commentaire `9d7c633`). Aucun résultat changé (sept cas au seuil 0).

### Étapes 8 et 9 : visa et revue finale (25/11)
- `actuary-approfondi` : refus du diff du `.tex` (M1 sous-couverture affirmée à tort sous E ; M2 « reste » soutenu par un excès sur le témoin, corrigé en forme (ii) sur décision du mainteneur ; M3 prémisse de P1), puis **visa** de la reprise avec deux réserves mineures, corrigées en `4100d46`.
- `audit` (`high`) : **conforme** ; seuls écarts aux références dans les grandeurs annoncées de `reserve2_trapeze`.
- `app-review` (`model: "opus"`, rendu réel plotly et base R) : **conforme avec réserves** ; les deux majeurs de la revue légère sont levés.
- `/code-review` (effort medium) : référence non régénérée (traitée), K d'ExpVar sous P1 (traité par le retour), script de mesure figé (#618), tableau avant / après à verser (fait), `mw_tests()` sans garde (inatteignable, écarté).

### Étape 10
- Veille de #463 du 25/11 : aucun fait nouveau ; `\dateconsultation` inchangée.

## Constats mineurs écartés (ADR 0018, critère « aucun »)

- `audit` (revue finale) : `R/engine.R` (`mw_tests()`), `r <- res$residu` sans garde `numeric(0)`, inatteignable par `run_engine()` (refus #192), `mw_bootstrap()` échouant avant.
- `app-review` (revue finale) : valeur de σ²_{J−1} direct dans la partie repliée du détail M6 (vue Détail ; en clair dans Calibration et le rapport) ; « non estimée » et « estimation » juxtaposés dans le détail M6 ; commentaire M6 de 1 296 caractères dans le tableau « Robustesse » (lisible à 1 366 px) ; nombres des textes du moteur au point décimal (antérieur).
- `actuary-approfondi` (étape 8) : réserve de `mw:m2b` sans le cas σ̂²_j simulé ≤ 0 (même sens, dit en `sec:mw`) ; index, mention des lecteurs du contexte trop étroite (corrigée avec m4).
