# Vérification des références externes de la branche Fn (Davison et Hinkley, 1997)

> *Rédigé par Claude (session de relevé groupé des sources, à accès internet par le proxy de la session), le 25/10/2026. Commande de la session principale de Fk, sur ordre du mainteneur du 25/10/2026 (décision Q-41-7 ; brief du commentaire `6388285797` de la PR #374). Relevé versé sur la branche `claude/lecture-conjointe-familles` (PR brouillon #374), à reprendre par la branche Fn.* Forme reprise de `docs/references/verifications-fj.md`.

## Objet

Davison, A. C. et Hinkley, D. V. (1997), *Bootstrap Methods and their Application*, Cambridge University Press, chap. 4 et 5-6, pour :

- l'intervalle « basic » et l'intervalle de percentile (issue #305, point 4) ;
- les enveloppes ponctuelle et simultanée du QQ-plot (chap. 4) ;
- le bootstrap paramétrique sous le modèle nul ajusté (chap. 4).

**Le texte n'a pas pu être lu** (§ 2). Seuls la notice et la table des matières sont vérifiés sur pièce ; les renvois de la documentation du paquet R *boot* (des mêmes auteurs) sont relevés comme sources secondaires (§ 3).

Les numéros de ligne citent la tête `269883a` de la branche `claude/lecture-conjointe-familles`.

## Méthode et statuts

Statuts de `verifications-fj.md` : **[V]** vérifié sur le texte ; **[P]** vérification partielle (notice, table des matières ou source secondaire lue sur pièce, raison donnée) ; **[X]** affirmation fausse, non trouvée, ou écart ; **[NV]** non vérifié (raison donnée). Aucun fichier source déposé dans le dépôt. Aucune formule n'est rapportée : aucune n'a pu être lue dans l'ouvrage.

## Sources consultées (25/10/2026)

| Source | Accès | Contenu lu |
|---|---|---|
| Cambridge Core, page de l'ouvrage : `https://www.cambridge.org/core/books/bootstrap-methods-and-their-application/ED2FD043579F27952363566DC09CBD6A` | libre (HTTP 200) pour la page ; **chapitres payants** (« Get access ») | notice, DOI 10.1017/CBO9780511802843, table des matières avec pages |
| Texte des chapitres 4, 5 et 6 | **non obtenu** | accès sur abonnement ou achat seulement ; aucune version en libre accès ; aucune copie tierce cherchée ni utilisée |
| Paquet R *boot*, version 1.3-32 (29/08/2025), fichiers `man/envelope.Rd` et `man/boot.ci.Rd` du miroir CRAN `https://raw.githubusercontent.com/cran/boot/master/` | libre | sections `details`, `references`, `examples` (source secondaire : la documentation renvoie à l'ouvrage) |

---

## Tableau récapitulatif

| # | Affirmation | Lieu dans le dépôt | Ce qui est vérifié | Statut |
|---|---|---|---|---|
| 1 | Notice : Davison et Hinkley, *Bootstrap Methods and their Application*, CUP, 1997 | `doc_tests_usp.tex:12503-12504`, `:18651-18652` | Cambridge Core | [V] |
| 2 | Chap. 4 = tests ; bootstrap paramétrique sous le modèle nul ajusté | `doc_tests_usp.tex:12566`, `:18656-18658` ; `R/engine.R:6722`, `:6743` | titre du chap. 4 (« Tests », p. 136-190) seulement | [P] |
| 3 | Enveloppe simultanée (« globale ») du QQ-plot, chap. 4 | `doc_tests_usp.tex:13262-13267`, `:18696` ; `R/engine.R:7476` | documentation de `boot::envelope` : éq. (4.17), exemples 4.7 et 4.8 | [P] |
| 4 | Enveloppe ponctuelle : quantiles de chaque colonne | `doc_tests_usp.tex:13261` | documentation de `boot::envelope` | [P] |
| 5 | Intervalles « basic » et de percentile | issue #305, point 4 ; `doc_tests_usp.tex:12910`, `:12958` | documentation de `boot::boot.ci` : chap. 5 ; titre du chap. 5 (« Confidence Intervals », p. 191-255) | [P] |
| 6 | Chap. 6 (régression linéaire), redressement des résidus par le levier | `bloc-5.md:121` (demande de vérification) | titre du chap. 6 (« Linear Regression », p. 256-325) seulement | [NV] pour le contenu |
| 7 | Formules, pages précises, conditions de validité à petit échantillon | — | — | [NV] |

---

## 1. Notice et table des matières [V]

> A. C. Davison et D. V. Hinkley, *Bootstrap Methods and their Application*, Cambridge University Press, 1997, DOI 10.1017/CBO9780511802843 (594 p. selon la fiche de l'éditeur).

Table des matières (Cambridge Core) :

| Chapitre | Pages |
|---|---|
| 1 — Introduction | 1-10 |
| 2 — The Basic Bootstraps | 11-69 |
| 3 — Further Ideas | 70-135 |
| 4 — Tests | 136-190 |
| 5 — Confidence Intervals | 191-255 |
| 6 — Linear Regression | 256-325 |
| 7 — Further Topics in Regression | 326-384 |
| 8 — Complex Dependence | 385-436 |
| 9 — Improved Calculation | 437-498 |
| 10 — Semiparametric Likelihood Inference | 499-521 |
| 11 — Computer Implementation | 522-550 |

La notice du `.tex` (l. 12503-12504 et 18651-18652 : auteurs, titre, Cambridge University Press, 1997) est **exacte**. Le `.tex` ne donne pas de pages ; s'il en donne, celles de la table ci-dessus sont vérifiées.

## 2. Texte des chapitres 4 à 6 [NV]

Chapitres derrière « Get access » sur Cambridge Core (abonnement institutionnel ou achat). Aucune autre voie légitime trouvée. **Aucune formule, aucune page intérieure et aucune citation de l'ouvrage n'est donc rapportée.**

Conséquence : les renvois du `.tex` à « Davison et Hinkley (1997, chap. 4) » (l. 12504, 12566, 13262, 18658, 18696) restent à dater « non relu sur le texte intégral » au sens de Q-Fc-10 et Q-37-10 (calendrier : « Davison et Hinkley (1997) avant Fk », non satisfait), sauf fourniture du livre par le mainteneur.

## 3. Sources secondaires : documentation du paquet *boot* [P]

Le paquet *boot* est le code d'accompagnement de l'ouvrage. Sa documentation n'est pas l'ouvrage : elle donne des renvois, pas des énoncés vérifiés.

### 3.1 `envelope` (enveloppes de courbe)

- `details` : « The pointwise envelope is found by simply looking at the quantiles of the replicates at each point. The overall error for that envelope is then calculated using equation (4.17) of Davison and Hinkley (1997). A sequence of pointwise envelopes is then found until one of them has overall error approximately equal to the level required. »
- `examples` : « Testing whether the final series of measurements of the gravity data may come from a normal distribution. This is done in Examples 4.7 and 4.8 of Davison and Hinkley (1997). »

**Confrontation au dépôt.**

- `doc_tests_usp.tex:13262-13267` : bande simultanée « enveloppe globale de Davison et Hinkley (1997, chap. 4), celle de la fonction *envelope* du paquet *boot*, réécrite dans le moteur », k* le plus grand k tel que la proportion des lignes ayant une valeur hors bande ne dépasse pas 0,10. Le rattachement au **chap. 4** concorde avec la documentation (éq. (4.17), exemples 4.7-4.8, numérotés dans le chap. 4). **[P]** : cohérent, non lu dans l'ouvrage.
- Nuance de lecture, sans [X] : la documentation dit que l'erreur globale de l'enveloppe est rendue « approximately equal to the level required » par une suite d'enveloppes ponctuelles ; le `.tex` décrit une règle « ne dépasse pas 0,10 ». Que `boot::envelope` choisisse la dernière enveloppe sous le niveau ou la plus proche n'est pas dit dans la documentation lue ; la conformité de la réécriture du moteur à `boot::envelope` relève d'un test du code, pas de ce relevé.
- `doc_tests_usp.tex:13261` (bande ponctuelle, quantiles 5 % et 95 % de chaque colonne) : conforme à « quantiles of the replicates at each point » [P].

### 3.2 `boot.ci` (intervalles « basic » et de percentile)

- `description` : « the first order normal approximation, the basic bootstrap interval, the studentized bootstrap interval, the bootstrap percentile interval, and the adjusted bootstrap percentile (BCa) interval ».
- `details` : « The formulae on which the calculations are based can be found in Chapter 5 of Davison and Hinkley (1997). »
- `references` : « Davison, A.C. and Hinkley, D.V. (1997) *Bootstrap Methods and Their Application*, Chapter 5. »

**Confrontation au dépôt.** L'issue #305 (point 4) oppose l'intervalle de percentile, [q̂_{α/2}, q̂_{1−α/2}] (`doc_tests_usp.tex:12910`), à l'intervalle « basic » ; elle ne cite pas Davison et Hinkley mais Efron et Tibshirani (1993). Si Fn cite Davison et Hinkley pour l'un ou l'autre, le renvoi est le **chap. 5** (et non le chap. 4 ni le chap. 6) [P]. **La formule de l'intervalle « basic » n'est pas rapportée ici** : elle n'a pas été lue dans l'ouvrage.

### 3.3 Bootstrap paramétrique sous le modèle nul ajusté

`doc_tests_usp.tex:12566` et `:18656-18658` attribuent au chap. 4 le test par bootstrap paramétrique sous le modèle nul ajusté (rapport de vraisemblance sur δ ; `R/engine.R:6722`, `:6743`, champ `reference`). Le titre du chap. 4 (« Tests ») est compatible ; le contenu n'est pas lu. **[P]**, sans écart constaté.

### 3.4 Chap. 6 et redressement par le levier

`bloc-5.md:121` demande de « faire vérifier Davison & Hinkley (1997, chap. 6) pour le redressement par le levier (l. 4149) » ; `bloc-5.md:142` note que « la formule de Davison & Hinkley est de mémoire ». Le chap. 6 est bien « Linear Regression » (p. 256-325) ; la formule n'est **pas** vérifiée [NV].

---

## Voie d'accès

Achat des chapitres 4, 5 et 6 sur Cambridge Core, accès institutionnel, ou prêt de l'ouvrage (Q-37-10 ; commentaire `6238477255` de la PR #332, n° 4). Le présent relevé ne lève pas la condition « Davison et Hinkley (1997), chap. 4 et 6, avant Fk ».

*Aucune page, équation ni citation de l'ouvrage n'a été rapportée sans avoir été lue ; les numéros (4.17), 4.7 et 4.8 viennent de la documentation de* boot*, citée comme telle.*
