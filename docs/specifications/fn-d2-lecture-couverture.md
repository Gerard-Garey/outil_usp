# Lecture de la mesure de #305 — point d'arrêt D2-Fn

> *Rédigé par l'agent actuary (IA).* Consultation `actuary-approfondi` du 27/10/2026, en lecture seule, sur la branche `claude/incertitude-bootstrap-graphiques`, tête `c6a541a` ; versionnée par la session principale avant décision, comme D1-Fn (`docs/specifications/fn-incertitude-bootstrap.md`). Elle porte sur la mesure `docs/tableaux/20261027-issue305-couverture-ic-sigma.md` (L1, R = 1 000 par jeu, B = 999, commit mesuré `01ea076`, moteur `f304b88…`, INTEGRITE OK) et prépare les questions Q-D2-Fn-1 à 7.
>
> **Décisions du mainteneur du 27/10/2026 (point d'arrêt D2-Fn franchi)**, toutes selon les recommandations, questions soumises par la session principale :
> - Q-D2-Fn-1 et Q-D2-Fn-2 : **(A)**, Ψ2 au titre de I4 seul ; `res$ic_bootstrap_basic_log` restitué en regard du percentile, lognormal seulement ; pas de `res$ic_bootstrap_basic` ;
> - Q-D2-Fn-3 : **(A)**, libellés qualitatifs « niveau nominal », sans chiffre de couverture, note renvoyant à la fiche ;
> - Q-D2-Fn-4 et Q-D2-Fn-5 : **(A)**, nom de la ligne conservé, `detail` et `reference` selon les textes du § 2 ; `detail` de la ligne restreinte corrigé ;
> - Q-D2-Fn-6 et Q-D2-Fn-7 : **(A)**, marques de la spécification plus les bornes de I4 sur `plot_boot_sigma()` ; L inchangée dans Fn.
>
> **Décisions complémentaires du mainteneur du 27/10/2026**, après les revues du circuit 1 sur `f5d821f` (questions Q1 et Q3 d'`audit`, textes de remplacement d'`actuary-approfondi`), toutes selon les recommandations :
> - **Q-D2-Fn-4 bis** : `reference` de la ligne « Largeur relative de l'IC bootstrap 90% » portée à `"Efron (1979), Ann. Statist. 7 ; Davison et Hinkley (1997), sections 5.2 et 5.3"` (la ligne mesure la largeur du percentile, § 5.3 ; le « basic » en regard relève du § 5.2) ;
> - **Q-D2-Fn-5 bis** : dans le `detail` de la ligne restreinte, la phrase sur Andrews devient « Andrews (2000) montre que le bootstrap n'est pas convergent quand le parametre est au bord, dans un modele de moyenne contrainte ; sa transposition a l'estimateur de delta n'est pas demontree, et l'effet sur sigma n'est pas etabli. » (contenu d'Andrews [P+], transposition à δ̂ non démontrée) ; la phrase de couverture est inchangée.

Marques : [V] vérifié (fichier:ligne, commande lue ou relevé versionné avec page) ; [P] partiel ; [H] hypothèse ; [NV] non vérifié.

## 1. Profil : Ψ2 confirmé, au titre de I4 seul

**Contrôles préalables [V]**
- La spécification n'a pas bougé depuis la mesure : md5 actuel `c3d475…` = md5 consigné au T0 et au JOURNAL. Le critère et les profils appliqués sont ceux qui ont été approuvés.
- La mesure reste valable à `c6a541a`. Entre `01ea076` et `c6a541a`, le diff de `R/engine.R` ne touche dans `usp_bootstrap()` qu'un commentaire (l. 4972-4977) ; le reste concerne `engine_enveloppe_spread()` et `engine_plots_data()` (#306). Ni σ\*, ni `ic_bootstrap`, ni l'ajustement ne changent.
- **Ψ0 écarté** : K-C3 (1) à (4) OK (écart indépendant maximal 7,85e-16) ; 0 refus ou échec sur 2 × 1 000 jeux ; B_eff minimal 999.
- **Ψ4 écarté** : I1 sous-couvre du même côté sur les deux jeux.
- **Ψ1 écarté** : I1 en distorsion libérale sur J1 (0,710 [0,681 ; 0,738]) et sur J2 (0,639 [0,608 ; 0,669]).
- **Ψ2** : I4 compatible sur J1 (0,895 [0,874 ; 0,913]) et sur J2 (0,886 [0,865 ; 0,905]). I2 en distorsion libérale sur les deux jeux (0,810 et 0,752) ; selon le § 2.6 de la spécification, seul I4 entre dans la décision.

**Ce que les tableaux complets ajoutent [V]**
- **Queues séparées à 90 %.** Pour I1, I2, I3 et A1, presque tous les manques sont au-dessus (σ0 au-delà de la borne haute) ; pour I1, 0 jeu sur 1 000 sous la borne basse. Pour I4, queues équilibrées et compatibles avec 5 % chacune : 4,5 / 6,0 % (J1), 5,5 / 5,9 % (J2).
- **95 %.** I4 compatible sur les deux jeux (0,940), avec deux réserves : K-C4, l'IC de τ va jusqu'à 0,0766 et dépasse 3ρ/2 = 0,075 ; queue haute de J1 « non tranchée », 4,3 % [3,1 ; 5,8] contre 2,5 % nominal. I1 à 95 % couvre 0,790 (J1) et 0,714 (J2).
- **Régimes (T3).** La sous-couverture du percentile n'est pas un effet du bord : sur J2, 0,632 au bord contre 0,660 à l'intérieur (n = 250) ; J1, où δ0 est au bord, ne fait pas pire que J2. I4 sur J2 : 0,891 au bord, 0,872 [0,824 ; 0,911] à l'intérieur. L'intérieur de J1 (n = 35) n'apporte pas d'information. Rien ne justifie un intervalle conditionnel au régime.
- **I3 (restreint)** sous-couvre autant que I1 : 0,726 et 0,654.
- **A1 (percentile × √(9/7))** reste en distorsion libérale : 0,820 et 0,770.
- **Largeurs (I4 / I1)**, médianes : 1,067 contre 0,730 σ0 sur J1 (+46 %), 1,063 contre 0,693 σ0 sur J2 (+53 %).
- **B1.** 1/moyenne(σ̂/moyenne(σ\*)) = 0,897 (J1) et 0,873 (J2), dans l'incertitude de E[σ̂]/σ0 = 0,902 ± 0,016 et 0,871 ± 0,016 : indice de la quasi-pivotalité de σ̂/σ, donc de la justification de I4. Le percentile, centré sur la loi de σ\*, est décalé vers le bas d'environ deux fois le biais par rapport à σ0, ce qui explique que tous les manques soient au-dessus [H, raisonnement heuristique cohérent avec les queues mesurées].

**Pourquoi I4 marche.** Si σ̂/σ était exactement pivotal, I4 serait exact à l'erreur Monte-Carlo près [V, raisonnement]. Davison et Hinkley (1997), exemple 5.1, p. 197-198 : le « basic » sur l'échelle log, éq. (5.10), p. 195, retrouve la solution exacte parce que Ȳ/μ est un pivot exact [V par le relevé S2.3 de `docs/references/verifications-fn.md`, non relu dans cette consultation]. Ici le pivot n'est pas exact (π_t dépend de γ et de δ, `usp_pi()`, `R/engine.R:1232-1234` [V]) : la quasi-pivotalité est une hypothèse [H], que la mesure confirme sur ces deux plans seulement. Aucune source lue ne chiffre la couverture à n = 8 [V, R27.6].

**Verdict sur les intervalles** : percentile (I1) fragile, conservé (Q-42-10) mais libellé à requalifier ; I4 pertinent en regard du percentile, sur ces deux plans ; I2 à écarter ; I3 à requalifier.

## 2. Questions au mainteneur

- **Q-D2-Fn-1 — Profil.** (A, recommandée) Ψ2 au titre de I4 seul. (B) Lecture Ψ3 : aucun « basic » restitué, au motif que I4 n'a été mesuré que sur deux plans. (C) Différer. Le critère fixé avant l'exécution donne Ψ2 ; queues, 95 % et régimes ne le contredisent pas.
- **Q-D2-Fn-2 — Intervalle restitué en regard du percentile.** (A, recommandée) I4 seul, `res$ic_bootstrap_basic_log`, sans `res$ic_bootstrap_basic` ; vecteur `c(bas_95, bas_90, haut_90, haut_95)` en fin d'objet ; `a·σ̂²/q + b`, q quantiles de type 7 de `bootstrap$sigma_boot` (σ\* brut ; le log porte sur σ, pas sur σ_USP, puisque b ≠ 0) ; `NULL` quand `ic` l'est ; cinq cas lognormaux, pas Merz-Wüthrich (#387) ; oracles 90 % : `premium` [0,09272 ; 0,18605], `premium_interieur` [0,07638 ; 0,13652]. La restitution pour `reserve1`, `premium_ii6`, `premium_net` et des données réelles extrapole les deux plans [H] ; la fiche le dit. (B) I4 et I2. (C) Aucun. I2 seul est exclu par le § 2.6.
- **Q-D2-Fn-3 — Libellés (bloc Calibration et rapport).** (A, recommandée) qualitatifs, sans chiffre de couverture :
  - lognormal, ligne 1 : « Intervalle bootstrap de percentile, niveau nominal 90 % : [ ; ] | 95 % : [ ; ] » ;
  - lognormal, ligne 2 : « Intervalle bootstrap « basic » sur l'échelle logarithmique, niveau nominal 90 % : [ ; ] | 95 % : [ ; ] » ;
  - lognormal, note grise : « Niveaux nominaux. À T = 8, sous les modèles ajustés à deux jeux de référence, l'intervalle de percentile couvre nettement moins que son niveau nominal (σ sous-estimé, borne haute dépassée) ; l'intervalle « basic » sur l'échelle logarithmique couvre près de son niveau nominal. Constat de simulation : voir la documentation, fiche de l'intervalle bootstrap. » ;
  - Merz-Wüthrich : « Intervalle bootstrap de percentile, niveau nominal 90 % : [ ; ] | 95 % : [ ; ] », note « Couverture à T = 8 non mesurée pour cette méthode. »

  (B) Même texte avec les chiffres (constante du moteur rattachée au tableau ; chiffres faux sans signal si le moteur change). (C) Libellé inchangé : non conforme à Ψ2.
- **Q-D2-Fn-4 — Ligne de diagnostic « Largeur relative de l'IC bootstrap 90% ».** (A, recommandée) nom conservé (clé de #380, décomptes, concordance) ; `detail` : `"Intervalle bootstrap de percentile du parametre retenu, niveau nominal 90 % : res$ic_bootstrap. A T = 8, couverture inferieure au niveau nominal sous les modeles simules (constat de simulation, voir la documentation). Intervalle basic sur l'echelle logarithmique en regard : res$ic_bootstrap_basic_log."` ; `reference` : `"Efron (1979), Ann. Statist. 7 ; Davison et Hinkley (1997), section 5.2"`. (B) Renommer la ligne.
- **Q-D2-Fn-5 — Ligne de l'intervalle restreint.** (A, recommandée) `detail` : ajouter « Couverture inferieure au niveau nominal a T = 8 sous les modeles simules, comme l'intervalle complet (voir la documentation). » et remplacer « Le bootstrap complet, qui reajuste delta, n'est pas convergent quand delta est au bord (Andrews, 2000) » par « Le bootstrap de l'estimateur de delta n'est pas convergent quand delta est au bord (Andrews, 2000) ; l'effet sur sigma n'est pas etabli. » (B) Tout porter dans la fiche.
- **Q-D2-Fn-6 — `plot_boot_sigma()`.** (A, recommandée) spécification § 3 (échelle de σ_USP, `sigma_usp_boot`, `regime_boot`, `boot_reperes` avec `sigma_usp`, `ic_bas`/`ic_haut`, `moyenne`, `sigma_standard`) plus `basic_log_bas` et `basic_log_haut` (90 %) tracés distinctement ; légendes « percentile, nominal 90 % » et « basic (échelle log), nominal 90 % » ; la fiche précise que les bornes de I4 ne sont pas des quantiles de l'histogramme. (B) I4 dans Calibration seulement.
- **Q-D2-Fn-7 — Largeur relative L, calculée sur le percentile.** (A, recommandée) `estim` inchangé dans Fn ; la fiche indique que I4 est plus large de 46 à 53 % et que L sous-estime l'incertitude. (B) Issue proposée pour calculer L sur I4.

**Impact attendu** : σ_USP, verdicts, p-values et `ic_bootstrap` inchangés ; champs ajoutés (`ic_bootstrap_basic_log`, `sigma_usp_boot`, `regime_boot`, `boot_reperes`), régénérés par la CI ; deux `detail` et une `reference` modifiés (non numériques). Visa d'`actuary`.

## 3. Pour `docwriter` (`fiche:ic-bootstrap`, étape 5)

1. `\refl` : Andrews (2000) p. 399-405 ; Davison et Hinkley (1997) § 5.2.1, éq. (5.6) p. 194 et (5.10) p. 195, ex. 5.1 p. 197-198, § 5.3.1-5.3.2 p. 202-203 avec l'ex. 5.4 ; Efron et Tibshirani (1993) § 13.3, 13.4, 13.8.
2. `\Cadre` : percentile `res$ic_bootstrap` ; « basic » log en regard `res$ic_bootstrap_basic_log`, lognormal seulement, jamais à la place du percentile ; restreint.
3. `\Stat` : I4 = [σ̂²/q₁₋α ; σ̂²/q_α] sur l'échelle de σ, reporté sur σ_USP par a·(·) + b ; couvrir σ0 équivaut à couvrir aσ0 + b ; « basic » log sur σ, pas sur σ_USP.
4. `\Loi`, couverture : « aucune source lue ne la chiffre à n = 8 » et « une simulation propre au dépôt la mesure » (tableau, SHA `01ea076`, moteur `f304b88…`, R = 1 000, B = 999 ; constat de simulation sous deux modèles ajustés). Chiffres : I1 0,710 / 0,639 (90 %), 0,790 / 0,714 (95 %), manques au-dessus ; I3 0,726 / 0,654 ; A1 0,820 / 0,770 ; I4 0,895 / 0,886 (queues 4,5 / 6,0 et 5,5 / 5,9 %), 0,940 à 95 % avec la réserve K-C4 et la queue haute non tranchée de J1 ; régimes sans effet sur la sous-couverture.
5. `\Loi`, Andrews (2000) : énoncé sur le paramètre au bord ; surcouverture asymptotique à μ = 0 du percentile (CI₂) et du « percentile » de Hall (CI₁, « basic » de (5.6)) pour la moyenne contrainte [P+] ; non-transposition à σ écrite comme [H] ; J1 (δ0 = 1) ne montre pas de surcouverture pour σ à T = 8 (percentile 0,710, « basic » 0,810) ; l'intervalle restreint n'est pas concerné par Andrews mais sous-couvre autant que l'intervalle complet.
6. Biais B1 : E[σ̂]/σ0 = 0,902 ± 0,016 et 0,871 ± 0,016 ; estimation bootstrap du biais relatif 0,897 et 0,873 ; E[corr·σ̂]/σ0 = 1,022 ± 0,018 (IC excluant 1) et 0,988 ± 0,018 (IC contenant 1), constat sous deux plans, jamais « le facteur corrige le biais » ; A1 ne rétablit pas la couverture.
7. Justification de I4 : (5.10) et ex. 5.1 ; pivot exact → I4 exact ; pivot non exact ici, quasi-pivotalité [H] confirmée sur deux plans ; I4 plus large de 46 et 53 %, L sous-estime l'incertitude.
8. `\Usage` : « les variantes BCa seraient plus exactes » → précision du second ordre asymptotique (D-H p. 203 et 214), non mesurée ici, BC_a non proposé faute d'accélération spécifiée ; reformuler « Il est fréquent d'obtenir, sur un historique de 10 ans… » à partir des taux mesurés.
9. Libellés et graphique : textes de Q-D2-Fn-3 et Q-D2-Fn-6 ; Merz-Wüthrich « couverture non mesurée » (#387).
10. Tableaux de « Nature des p-values et validité à T = 8 » : même statut si l'IC y figure.

*Hors question* : sur J1, le flux complémentaire V3b tire en moyenne 24 691 fois sur un plafond de 25 000 (T5) ; mécanisme connu de #279, sans effet sur l'IC, aucune action dans Fn.
