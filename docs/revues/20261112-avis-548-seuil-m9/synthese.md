# Synthèse : avis d'`actuary` sur #548 (12/11/2026)

> *Rédigé par la session principale (IA).* Décision Q-60-7 (a) du 12/11/2026 : question posée à `actuary` (fiche de base), hors branche, pendant K3b. Rapport intégral : `actuary-avis-548.md`.

- **Avis** : conforme. Le seuil `TOLERANCE` = 1e-6 de M9 est maintenu (Q-59-6 (a)), comme garde de la CI où `premium_interieur` est reproduit au bit (0 feuille non identique sur 57 018, Linux R 4.3.3, `7eca6e4`).
- **Portée de l'écart Windows** : une seule réplication (n° 483) de `BP` et `BP79` dans `bootstrap$stats_boot`, loin des statistiques observées (marge relative minimale 1,3e-3 et 2,0e-4). σ_USP ne dépend d'aucun tirage. Aucune p Monte-Carlo, aucun verdict n'est touché.
- **À décider par le mainteneur** :
  - **A** : reformuler la justification du point 7 de l'ADR 0006, le seuil n'étant plus « environ trois fois la dérive maximale » pour le poste ;
  - **B** : écrire « première mesure consignée du poste sur `premium_interieur`, et première au-delà du seuil », l'ADR 0011 consignant déjà une mesure du poste le 25/09/2026 ;
  - **C** : traitement d'un pas de p Monte-Carlo dans le critère de KR, `SF` ayant une réplication à 3,28e-6 de l'observée.
- **Suite** (Q-60-7 (a)) : le mainteneur fait la mesure du § 3 sur son poste et dépose le relevé sur #548 ; `architect` annote l'ADR 0006 au premier commit `docs:` de KR (texte proposé au § 4) et écrit le critère du § 2 dans la fiche KR ; `Closes #548` dans KR.

**Décision du mainteneur du 12/11/2026** (questionnaire à la session principale) : corrections **A, B et C retenues**. L'annotation de l'ADR 0006 (texte du § 4 du rapport, avec A et B) et le critère de la batterie sous Windows (§ 2, avec le traitement d'un pas de p Monte-Carlo, C) sont portés par `architect` au premier commit `docs:` de KR.
