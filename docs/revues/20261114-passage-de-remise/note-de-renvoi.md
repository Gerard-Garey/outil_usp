# Note de renvoi : pièces de JF et rapports de KR (étape 10, ajustement F)

> Versée par la session principale le 14/11/2026 (fiche « Branche KR », étape 10 ; décision Q-55-6 (a), ajustement F). Elle ne contient aucune analyse nouvelle : elle indique où se trouvent les pièces qui, ensemble, tiennent lieu de relecture intégrale du dossier (JF, complétée par KR sur le diff ; Q-55-6 (a)).

## 1. Jalon JF (relecture intégrale)

- **PR** Gerard-Garey/outil_usp#480 : corps et handoffs en commentaires.
- **Vérifications documentaires** : `docs/references/verifications-jf.md` (relevés de `regulatory` et de la session, dont la veille des consolidations EUR-Lex et des orientations de l'AEAPP du 08/11/2026) ; `docs/references/inventaire-non-relu.md`.
- **Issues issues de JF** : #482 à #495 et #497 à #504.
- **Vie du document** (décisions, ADR, SHA, sous le `\label` d'origine) : `docs/suivi-documentation/` (`I.md`, `II.md`, `III-H.md`, `III-M.md`, `IV.md`, `annexe.md`, `README.md`).

## 2. Branches K1 à K6, K2b et K3b (entre JF et KR)

Rapports versés dans `docs/revues/`, sous les dossiers datés du 09/11 au 14/11/2026 : avis amont, fins de branche et validations (`20261109-fin-de-branche-k1`, `20261110-fin-de-branche-k3`, `20261110-fin-de-branche-k5`, `20261111-fin-de-branche-k4`, `20261111-fin-de-branche-k6`, `20261112-fin-de-branche-k3b`, `20261112-validation-k2`, `20261113-k2b-*`, `20261114-k2b-etapes-9-10`), avis sur #548 (`20261112-avis-548-seuil-m9`) et 62e point (`20261114-62e-point`, plan de KR et consultation Fable).

## 3. Passage de remise KR (ce dossier)

| Étape | Pièce |
|---|---|
| 1 (#573) | `regulatory-573-amont.md`, `actuary-573-avis.md`, `audit-573-leger.md`, `regulatory-573-aval.md` |
| 2 | `etape-2/` (balayage des chaînes, mesure de #575) |
| 3 | `etape-3-releve-poste.md` (critère de #548 accepté sur `a2f9c3a`) |
| 4 | `audit-high-i-registre.md`, `audit-high-ii-entrees-sorties.md` |
| 5 | `app-review-integral.md` |
| 6 | `regulatory-matrice-lot1.md`, `regulatory-matrice-lot2.md`, `regulatory-matrice-lot3.md` (matrice complète, valant pour le PDF 3.8 sous réserve du contrôle aval de l'étape 8) |
| 8 | `actuary-etape-8-tex.md`, `regulatory-etape-8-aval.md`, `actuary-etape-8-fin.md`, `regulatory-etape-8-fin.md` |
| 9 | `audit-etape-9-revue-finale.md` |
| 10 | commentaires datés sur #463 et #504 ; la présente note |
| synthèse | `README.md` de ce dossier (dont la date de référence du calcul, R1) |

## 4. Identification de l'état remis

- Gel du code : `a2f9c3a` (`R/`, `app.R`, `DESCRIPTION`, `tests/`), `Version` 2.1.0.
- md5 au gel : `R/engine.R` `818f276d8941e5780468382c640f8cfa`, `R/charger_moteur.R` `5ed6226c768d5ad781ea03a7306ccc11`.
- Documentation : `docs/latex/doc_tests_usp.tex`, `\versiondoc` 3.8, et son PDF versionné.
- Étiquette annotée posée par le mainteneur sur le commit de fusion de KR (étape 12).
