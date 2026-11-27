# S9, #421 : réponses d'actuary aux six questions du coder (commits `4a2f6bf`, `4e0a829`)

> *Rédigé par l'agent actuary (IA), fiche `actuary`, le 27/11/2026, sur `claude/mesures-t8` (tête `4e0a829`). Lecture du script à ce commit. Aucun fichier écrit. [V] = vérifié (lecture du code ou commande citée), [H] = hypothèse. Versé intégralement par la session principale (Q-54-10).*

**1. Garde de lecture de K421-3 : principe validé, seuil et forme à corriger (le code change).**
- [V] Lecture du code. Imhof passe par `integrate(rel.tol = 1e-10)`, donc `abs.tol` vaut aussi 1e-10 par défaut. L'erreur absolue nominale sur la puissance est de l'ordre de 1e-10 ; c'est une estimation de `integrate()`, pas une borne garantie.
- Le critère compare deux coefficients à 1e-3 près en relatif. Il n'a donc de sens que si chaque déficit |P − L₋| dépasse environ 1e-10 / 1e-4 = 1e-6, soit une erreur relative inférieure au dixième du seuil.
- Avec un plancher à 1e-9, un déficit compris entre 1e-9 et 1e-6 donne une erreur relative de 1e-4 à 1e-1. C'est exactement le bruit observé (6e-2), et il produirait des « non atteint » factices. [H] Ces cas peuvent se présenter aux T intermédiaires (12 à 50), que l'essai n'a pas parcourus.
- Décision : lecture « sans objet » dès que **min** des deux déficits est inférieur à **1e-6**, au lieu de « < 1e-9 aux deux points ». Un seul point sous le plancher suffit à rendre le rapport illisible.
- La garde est fondée a priori sur la tolérance de la quadrature et non sur les valeurs vues. Elle est sans effet à T = 4, 5 et 8, où les déficits à la garde sont d'ordre 1e-4 à 1e-1. Elle est à tracer comme écart à l'avis.

**2. K421-2 quand l'erreur-type est nulle : passer à la loi binomiale exacte (le code change).**
- [V] Décompte du code : 13 T × 5 ρ × 2 α = **130** comparaisons, et non 140. Les « environ 170 » de mon avis étaient faux. Le nombre exact est à relever sur la sortie.
- [V] `.imhof_p_sup0()` tronque à [0, 1]. Une puissance de 1 signifie un déficit sous la précision de la quadrature, pas un déficit nul. z = Inf serait alors une alerte artificielle.
- Plus largement, l'approximation normale ne vaut pas quand N·min(p, 1 − p) est petit, par exemple à T = 100, ρ = −0,9. Lire « 3 ET » n'y a pas de sens.
- Décision, pour toutes les cellules :
  - remplacer p par min(max(p, 1e-9), 1 − 1e-9) ;
  - calculer la p bilatérale binomiale exacte : 2·min(P(X ≤ x), P(X ≥ x)), bornée à 1, avec `pbinom()` ;
  - « signalé » si elle est inférieure à 2,700e-3, « désaccord » si elle est inférieure à 6,334e-5. Ce sont les queues normales de 3 et 4 ET [V, `2*pnorm(-3)`, `2*pnorm(-4)`].
- Ce n'est qu'une traduction exacte du critère écrit d'avance. Garder la colonne en ET pour la lecture. Le seuil « plus de 2 signalées » reste inchangé.
- [V] Avec p = 1 − 1e-9 et N = 4e5 : un taux simulé de 1 donne P = 0,9996 (accord). Un seul non-rejet donne P = 4,0e-4 : la cellule est signalée, sans désaccord automatique.
  - *Note de la session (27/11) : valeurs unilatérales ; sous la règle bilatérale prescrite ci-dessus, un taux simulé de 1 donne P = 1 et un seul non-rejet P ≈ 8,0e-4, même classement (signalée, sans désaccord). Correction confirmée par actuary, `actuary-questions-420-367.md`, Q10 ; texte de l'avis conservé.*

**3. Graines : acceptables, pas de changement.**
- [V] Les graines sont déterministes et consignées en T0. Le flux de T = 8 est identique au bit. `git grep` à `4e0a829` ne trouve la plage 421000004-421000100 hors de `mesure_dw_rho_negatif_t8.R` ni dans `tests/` ni dans `R/`.
- Aucune indépendance entre les T n'est requise : chaque T est lu séparément.

**4. M, B et C bloquants à T = 8 seul : acceptable, pas de changement.**
- [V, par argument] À T = 4, L₋ = 0 et la puissance vaut α > 0 en ρ = 0. Elle décroît donc forcément sur une partie de la grille, et passe sous α près de la garde.
- Les paires non croissantes à T = 4 sont une conséquence de la limite démontrée (avis, § 1.2), pas un défaut. Les rendre bloquantes hors de T = 8 serait faux.
- Pour les autres T, C est couvert par K421-3.

**5. Nom du tableau de `mesure_lb1_dw_t8.R` : sans enjeu statistique, la décision revient à `architect` ou au mainteneur [H].**
- [V, message de `4a2f6bf`] La sortie est identique au tableau du 20/10, hors T0. Un nouveau tableau n'apporterait aucun résultat.
- Je recommande de ne pas en verser à l'étape 6 et de garder le nom daté, sans toucher `CAS_A`. Si un tableau est versé, son en-tête doit citer #421.

**6. Réserve M42 : le seuil de 1e-3 reste tel quel ; les nouveaux affichages sont tracés.**
- Changer K3_REL maintenant que 1,09e-3 est connu serait une décision guidée par les données. C'est précisément ce que M42 interdit.
- K421-3 est un constat, pas un échec. À T = 5, α = 0,10, la lecture « régime non atteint, écart relatif 1,09e-3 » est honnête et doit paraître avec sa valeur.
- [V, par le calcul du point 1] Avec des déficits d'ordre 1e-3, l'erreur de quadrature pèse environ 1e-7 en relatif. L'écart de 1,09e-3 est donc mesuré, pas du bruit.
- La marge de 6,042e-4 à T = 5, α = 0,05 dépasse le seuil de 1e-6 de K421-1 d'un facteur 600 : L₋ = 0 est décidée sans ambiguïté, et aucun seuil n'est en jeu.
- Les corrections des points 1 et 2 ne visent que la lisibilité des lectures. Elles ne déplacent aucun verdict à T = 4, 5 ou 8. Elles doivent être consignées dans la trace M42 de `synthese.md` (date, motif, valeurs déjà vues) avant l'exécution officielle.

## Retour
- **Statut** : complet.
- **Résultat** :
  - points 3, 4 et 6 : validés tels quels ;
  - point 1 : plancher à 1e-6 sur le minimum des deux déficits ;
  - point 2 : lecture binomiale exacte avec p bornée à [1e-9, 1 − 1e-9] ; dénombrement corrigé à 130 ;
  - point 5 : renvoyé à `architect`.
- **Preuves** :
  - vérifiées : lecture de `4e0a829` (l. 295-341, 538-546, 666-675), de `R/engine.R` (l. 2892-2893), `git grep` des graines, `pnorm` et `(1-1e-9)^4e5` sous R ;
  - hypothèses : déficits compris entre 1e-9 et 1e-6 aux T intermédiaires ; valeur réelle de l'erreur de `integrate()` (estimation, pas une borne).
- **Informations manquantes** : nombre de comparaisons à relever sur la sortie complète.
- **Décisions non résolues** : nom du tableau de `mesure_lb1_dw_t8.R` (`architect` ou mainteneur) ; trace des écarts aux points 1 et 2 dans la réserve M42 (mainteneur).
- **Critères déclenchés** : écart au protocole écrit (points 1 et 2), dans le périmètre de la réserve M42 déjà acceptée. Aucun résultat du moteur n'est changé.
- **Constats hors périmètre** : le « 140 » du coder et mes « environ 170 » sont des dénombrements faux. C'est un mineur au sens de l'ADR 0018 (aucun critère G ni E1 à E6), corrigé ici.
- **Prochaine action** : `coder-approfondi` applique les points 1 et 2, puis relance l'essai ; `audit` léger sur le diff ; ensuite l'exécution officielle de l'étape 6.
