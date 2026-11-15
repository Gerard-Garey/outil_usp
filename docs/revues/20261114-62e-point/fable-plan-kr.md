# Consultation Fable sur le plan de KR (14/11/2026)

> Versé par la session principale. Consultation de `architect-approfondi` avec `model: "fable"`, sur accord du mainteneur (Q-62-7 (b), `docs/agents/routage.md` § 4.1). Compteur Fable : 1 sur 3. Avis seul : l'agent n'a rien écrit ni créé. Arbre de travail à `main` `a4738b5`, 62e point non commité.
>
> Rapport reproduit tel que rendu, au découpage typographique près.

## Décisions du mainteneur sur cet avis (14/11/2026)

- Ajustements : **tous portés** dans la fiche KR (M1 à M4, m1 à m6).
- **Q-A** : (a), `Version` de `DESCRIPTION` relevée par un commit `repo:` à l'étape 1 de KR, avant le gel. Le numéro reste à fixer par le mainteneur.
- **Q-B** : les rapports figés du dossier sur données réelles sont produits sur l'état étiqueté.
- **Q-C** : `openxlsx` reste le lecteur par défaut ; la limite est consignée au README (« Prérequis ») et dans le `.tex`.

## Rapport

**Verdict : plan sûr avec ajustements.** Aucun bloquant si M1 à M4 entrent dans la fiche KR avant l'étape 0. Aucune décision Q-62-1 à Q-62-6 n'est à rouvrir.

### Majeurs

- **M1 — le `.tex` contredit #548 et le plan ne le corrige pas.** `sec:graines`, l. 2731-2749, affirme trois choses :
  - le seuil 1e-6 « vaut environ trois fois la dérive maximale mesurée entre plateformes » et « garde sa marge d'environ trois » ;
  - il n'y a « aucune valeur au-delà du seuil » ;
  - un poste Windows (R 4.3.1) exécute les tests contre ces références.

  Ces trois affirmations sont *vérifiées* dans le `.tex`. L'annotation de l'ADR 0006 et l'avis d'`actuary` (l. 22, « désormais fausse pour le poste ») disent l'inverse. Le README, l. 199-206, est à jour ; le `.tex` ne l'est pas (*vérifié* : aucune occurrence de 1,814, 483 ou ucrt). L'étape 7 ne prévoit rien pour #548.
  - *Ajustement* : à l'étape 7, un commit `docs:` #548 par `docwriter` sur ce passage, d'après l'annotation et le relevé de l'étape 3. Visa à l'étape 8. La ligne `Closes #548` en dépend.
- **M2 — aucun contrôle aval de `regulatory` sur le `.tex` final.**
  - La matrice (étape 6) lit le `.tex` 3.7. L'étape 7 réécrit ensuite la puce de `sec:mw` (l. 14698-14703), la l. 4398, les ancrages D(2)(b) et D(2)(c) et les limites. L'étape 8 n'appelle qu'`actuary-approfondi`.
  - Précédent : en K2b, `regulatory` a jugé inexact un passage qu'`actuary` tenait pour hors périmètre.
  - *Ajustement* : à l'étape 8, `regulatory` (fiche de base) contrôle les passages réglementaires du diff du `.tex` de KR. La matrice versée précise qu'elle vaut pour le PDF 3.8.
- **M3 — pas de règle de dégel.** Le plan dit « issue ou arrêt ». Or K2b montre que le mainteneur peut décider un correctif dans la branche (M-1, `<x:rPh>`). Un tel commit ne serait vu que sur son diff (règle 10). La batterie Windows, les deux `audit` et l'`app-review` resteraient attachés à l'ancienne tête.
  - *Ajustement* :
    - (a) nommer le périmètre du gel (`R/`, `app.R`, `DESCRIPTION`) et dire si `tests/` en fait partie ;
    - (b) poser un critère de sortie à l'étape 12 : `git diff <SHA étape 1> HEAD -- R/ app.R DESCRIPTION` vide, avec ce SHA cité dans le relevé #548 et dans l'étiquette ;
    - (c) à défaut, sur décision du mainteneur : revue du diff par le vérificateur du domaine, attestation écrite d'`audit` que les conclusions de l'étape 4 tiennent, parité CI, et batterie Windows rejouée si `R/engine.R` est touché.
- **M4 — #574 et #575 : la consignation dans le `.tex` seul ne suffit pas.** Pour les chiffres du dossier, l'option (a) de Q-62-3 tient : #575 est un arrêt franc, sans valeur fausse (*selon l'issue ; non rejoué, `openxlsx` absent de la session de l'agent*). Reste l'utilisateur qui importe un fichier :
  - il ne lit pas le `.tex`, et un *segfault* n'affiche rien ;
  - le README, l. 38-39, prescrit `remotes::install_deps(dependencies = TRUE)`, qui installe le dernier `openxlsx` et non la 4.2.5.2 de la CI (*vérifié*). Le *segfault* est mesuré sous 4.2.9, non sous 4.2.5.2 ;
  - rien ne permet de forcer le lecteur interne quand `openxlsx` est installé (`R/engine.R` l. 9048, `requireNamespace` seul, *vérifié*).
  - *Ajustements* :
    - (i) limite aussi au README (« Prérequis »), par un commit `docs:` de la session, puisque `docwriter` n'écrit que `docs/latex/` ;
    - (ii) texte de la limite avec les versions mesurées ; mesure de #575 sous 4.2.5.2, en sous-processus, avant l'étape 7, sans toucher au dépôt ; version d'`openxlsx` du poste relevée à l'étape 3 ;
    - (iii) pour #574-1 (valeur fausse sur les deux chemins, fichier forgé), écrire le contrôle compensatoire : données relues à l'écran, empreinte des données au rapport figé.
  - *Appui à (a)* : le contrôle de bornes de #575 compte les `<si>`, ce que #574-1 rend non trivial (`<x:si>` non extraite, l. 9016 et 9029). Ce n'est pas un correctif de cinq lignes sous gel.

### Point 2 — #573 sans effet sur les références : confirmé (*vérifié*)

- Les six `.rds` ont `ok = TRUE` et `validation$erreurs` vide. On n'y trouve aucune occurrence de « reserve no 2 », de « reste ouverte » ni d'« article 220 ».
- `tests/generer_references.R`, l. 29-37, refuse tout `ok = FALSE` : un motif de refus ne peut pas figurer dans les références.
- La chaîne n'est lue ni par `app.R` ni par `R/display_helpers.R`. Le `.tex`, l. 4398, la décrit en prose, sans `\code{}`.

### Mineurs

- **m1** : `docs/specifications/fc-validation-ajustement.md`, l. 105-113, cite la phrase « octet pour octet ». Ce fichier est hors de la surface du plan ; une annotation datée est à prévoir.
- **m2** : pour #573, trois points :
  - soumettre à `regulatory` la suppression pure de la phrase, puisqu'un motif de refus n'a pas à qualifier l'art. 220 ;
  - faire viser le texte par le mainteneur avant `coder-approfondi` ;
  - joindre à la PR l'avant / après du libellé.
- **m3** : identité du code (exigences § 5.6, ADR 0009 point 4). `DESCRIPTION` porte `Version: 2.0.0` depuis `510b03d` (22/10, *vérifié*). L'étiquette devrait citer les md5 de `R/engine.R` et de `R/charger_moteur.R`. Le relevé de l'étape 3 devrait noter le md5 affiché sur le poste, preuve que celui-ci a exécuté le moteur gelé.
- **m4** : à l'étape 3, les « contrôles Excel et CSV sous Windows » n'ont ni contenu ni critère. À préciser :
  - classeurs écrits par l'Excel du poste ;
  - `test_controles_entree.R` lancé avec `openxlsx` ;
  - zéro ligne « [saute] » ;
  - versions notées.
- **m5** : R45 échappe à `/code-review`, puisque l'étape 9 ne lit que le diff de KR. Il faut le lancer sur la PR de R45.
- **m6** : l'arbre de travail est à mettre à jour avant le commit de l'étape 0 :
  - les mentions « proposé », « en attente » et « si Q-62-x (a) » ;
  - la ligne E-14/11 (62e point), absente du § 4 (*vérifié*) ;
  - Q-62-7 passée en (b), la ligne du § 7 et le compteur Fable à 1 sur 3 ;
  - les libellés : le § 1 indique #573 à #576 en `needs-triage`, alors que l'API montre #573 en `documentation` + `ready-for-agent`, et #574 et #575 en `bug` seul (*vérifié*, 11:09 UTC).

### Questions nouvelles au mainteneur

- **Q-A** : quelle version de l'outil à la remise ?
  - (a) `Version` de `DESCRIPTION` relevée par un commit `repo:` à l'étape 1, avant le gel ;
  - (b) 2.0.0 gardée, l'identité du code étant portée par les md5 cités dans l'étiquette.

  Recommandation : (a), puisque le rapport figé affiche cette version.
- **Q-B** : les rapports figés du dossier, sur données réelles, sont-ils produits sur l'état étiqueté ? #573 change le md5 de `R/engine.R`, si bien qu'un rapport antérieur ne correspondrait plus au moteur remis (*hypothèse* : la feuille de route n'en dit rien).
- **Q-C** : dans l'application remise, garder `openxlsx` par défaut avec une limite au README, ou recommander l'usage sans `openxlsx` ? Le lecteur interne refuse la forme de #575 avec un motif.

### Retour

- **Statut** : revue requise (Q-A à Q-C ; M1 à M4 à porter dans la fiche).
- **Critères déclenchés** : ADR 0006 (cohérence du `.tex`), gel du code (Q-55-5), jalon de remise. Aucun σ_USP, verdict ni contrat partagé n'est touché.
- **Lectures hors brief** : `README.md`, `DESCRIPTION`, ADR 0009, `R/engine.R` l. 1960-2030 et 8940-9075, avis #548, revues de K2b, issues #573 à #575.
- **Non vérifié** : `docs/agents/routage.md` § 4-5 non relu en entier ; contenu de Q-60-9 ; comportement d'`openxlsx`.
