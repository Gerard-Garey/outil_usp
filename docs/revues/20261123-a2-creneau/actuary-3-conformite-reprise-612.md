# Conformité de la reprise du script de mesure de #612 (A2, étape 2)

*Rapport de l'agent `actuary` (routine), 23/11/2026, sur le diff `37c7479..3a0b582` de `tests/simulation_jm1_trapeze_t8.R` (md5 `1e320e8e1b765dfd8ff64ad4b97df1ba`) ; protocole `actuary-1-protocole-612.md` (md5 `70176c2e3ded10922eeb81971b533ae7`, PA-1). Lecture seule, sans exécution. Versé par la session principale (Q-54-10), en synthèse fidèle.*

## Verdict : conforme avec réserves

C1 et C2 sont tenus, R1 à R8 aussi. Aucune correction n'est exigée avant la sonde S.

**Réserve, à lever par le mainteneur avant la mesure L-A (pas avant la sonde).** Le script restreint K0 sur deux points, contre la lettre du § 4 du protocole (K0 « par (G, ℓ) ») et de l'entrée E-23/11 (étape 2), qui écrit « (dc) » sans distinguer le carré de D :
- (dc) D sort de K0 (nature « constat ») ;
- R3 retire le bloc D du verdict K0 sur les refus et les p absentes.

Sur le fond, les deux sont justifiés (§ 2 et 3). Mais une règle de décision se fixe avant les données : le mainteneur doit les confirmer explicitement. Le script affiche la ligne D et le détail de (dc) D : en cas de refus, K0 se relit sur la sortie sans recalcul.

## 1. C1 : tenu

- `controle_t()` exige le § 4 présent à l'identique **et** `identical(md5, MD5_PROTOCOLE_PA1)` (valeur littérale `70176c2e…`), nature `integrite`.
- En mesure et en essai, (t) est appelé en premier ; un défaut arrête le script par `arret_integrite("avant tout tirage ((t))")` (l. 1400-1401).
- « (1) fin » vérifie en plus que le md5 du protocole n'a pas changé entre le début et la fin.
- Au pré-vol, (t) est évalué sans arrêt avant les tirages : acceptable, le pré-vol n'écrit rien.

## 2. C2 : conforme sur le fond ; partage de (dc) à déclarer

- `controle(nature = …)` oriente chaque défaut vers `INTEGRITE`, `DEFAUTS_K0` ou `DEFAUTS_CONSTAT`.
- (inv), (o) et (dc) carré, nature `k0` : défaut → `MOTIFS_K0`, K0 faux, R0 par `REGLE`, sans INTEGRITE ECHEC ; l'écriture reste possible (C2 et R8).
- (dc) D, nature `constat` : défaut → `REGLE_3` et `REGLE_4` « non évaluables », sans R0. Partage jugé juste :
  - le carré sert à K2b, qui décide ; D ne sert qu'aux constats (3) et (4) (protocole § 3, colonne « Rôle ») ;
  - un défaut de (dc) D ne dit rien des cellules M ni de C ;
  - (v2) couvre déjà la substitution V2 ;
  - même logique que R3.
- R8 visait à ce que ces contrôles ne bloquent plus l'écriture : obtenu. L'écart à la lettre de C2 est à faire confirmer.
- (so) reste un contrôle d'intégrité, à juste titre : V2 ne touche que la simulation.

## 3. Questions du développeur

- **R5 : lecture voulue.** Le triangle observé passe deux fois par `mw_residus()` (`.mw_pool_residus()`, `.mw_contexte_mc()`), compté à part par `tri_obs`. Une réplication passe par `.mw_tirer_triangle_valide()` → `mw_ajuster()` → `.mw_stats()` ; celles dont l'ajustement échoue n'appellent pas `mw_residus()` : les exclure est juste, la part est conditionnelle aux réplications où ce code tourne. Nuance non bloquante : une réplication dont `.mw_stats()` échoue après `mw_residus()` reste au dénominateur hors `B_effectif` (effet négligeable, `B_eff_min` imprimé). Deux réplications consécutives identiques compteraient une fois : sans portée en loi continue.
- **(dc) D et cas M-1 (b) : ne pas l'exiger dans le script.** La validité ne demande que l'égalité du prédicat sous V0 et V2. À l'étape 4, (3) et (4) seront lus avec le compte M-1 (b) / n ; s'il n'est pas n/n, lecture conditionnée à ce sous-ensemble, en descriptif.
- **R3 : conforme.** C reste dans le verdict K0 (il porte K2b) ; seul D en sort, sa ligne restant affichée. Le découpage (bloc, G, ℓ, variante) est plus strict que « par (G, ℓ) ». Même réserve de lettre que (dc) D.

## 4. Écarts déclarés

- **R7 : acceptable.** `--duree-max` estime la durée de chaque groupe avant lancement (l. 1671) ; l'agrégation finale (quelques minutes à une dizaine [H]) tient dans la marge de 0,2 h. Consigne écrite dans `--aide`, au message d'interruption et dans la commande du pré-vol. Réserve d'exploitation : la session applique `--duree-max 1.6` au dernier segment ; la limite dure reste le `timeout` de M42.
- **(c), (oracle), (u) bloquants : acceptable** (contrôles de spécification, de témoin de #567 et de reproductibilité).
- **R1, R2, R4, R6 : tenus** (lus dans le diff).

## 5. Observation d'essai (B = 199, non probante) et ordre

Avec des nombres aléatoires communs, Δp vient d'un écart systématique de la statistique sur ~43 % des réplications et ne décroît pas avec B, alors qu'err_mc décroît en 1/√B. Passer à B = 999 multiplie le rapport par ≈ 2,24 [H] : maximum attendu de l'ordre de 4 > 2, la règle de correction du constat (1) se déclencherait probablement [H, non probant].

L'ordre décidé (sonde S d'abord) en sort renforcé. Si la règle se déclenche, deux options pour le mainteneur :
- (a) correction `moteur:` d'abord : V0 devient le code corrigé, ce qui amende la définition de V0 « état actuel » du protocole ; (r567) détecterait toute modification des nombres de #567, seuil 0 attendu sur les sept cas [H forte] ;
- (b) mesure d'abord : défendable si des triangles simulés dans la plage 1e-12 à 1e-10 sont improbables dans M [H] ; le script ne compte pas les réplications touchées dans M, l'hypothèse ne serait pas vérifiée.

## Retour

- **Statut** : complet par lecture ; décision du mainteneur ouverte.
- **Non vérifié** par `actuary` : essai et pré-vols au md5 `1e320e8e…` (constatés par `audit`, `audit-leger-reprise-612.md`).
- **Décisions non résolues (mainteneur)** : confirmer avant L-A (dc) D en « constat » et R3 ; si la sonde déclenche la correction, ordre entre correction `moteur:` et mesure.
- **Critères (`routage.md`, § 4)** : écart à la lettre d'une décision du mainteneur ; changement de résultat possible à la sonde ; à T = 8, aucun résultat exact. Aucun désaccord avec `audit`.
- **Hors périmètre** : aucun. Nuance du dénominateur : mineure, dans le périmètre.
