## Avis d'actuary : K3b, constat C1 (en-tête `T` des séries) et `b2_non_defini`

> *Avis de l'agent actuary (IA), fiche de base, le 13/11/2026, sur le constat C1 de la revue finale d'`audit`.* Versé intégralement par la session principale (Refs #555). Il corrige la prémisse de `actuary-textes-555.md` (l. 34 et 149) et de `actuary-textes-555-colonne-t.md` (interaction 6), versés tels quels et non modifiés.

Je recommande au mainteneur de **confirmer la décision 8**. La prémisse de mon avis était fausse et je la corrige ci-dessous. Mais c'est l'ancien comportement qui était défectueux, pas le nouveau. Pour `b2_non_defini`, je garde le code tel quel et propose d'ajouter le mot « exactement » dans la fiche, sans bloquer la branche.

**Tête du dépôt.** La tête est `7859e23`, et non `77be237` comme dit le brief. Le commit en plus ne verse que le rapport d'audit, sans code. Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue.

**Mesures reproduites** sous `LC_ALL=C.UTF-8`, avec `adv1.R`, `adv2.R` et `adv4.R` :
- **Avec les 8 années**, σ_USP est identique au bit près. Pour le vérifier, j'ai écrit le script `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/rf/adv4b_actuary.R`, qui teste `identical()` et rend TRUE (0,10341126057586322).
- **Avec la profondeur T = 6**, σ_USP passe de 0,1280504 à 0,1193536.
- **Sept verdicts changent** sur la série mélangée à S/P croissant (`adv4.R`).
- **Le fichier à trou** passe de ok TRUE à FALSE.
- **Point de plus** : sans changer de verdict, `adv1.R` montre que des p-values bougent déjà avec les 8 années (par exemple 0,120 → 0,260).

**Cause, lue dans le code.** Le moteur tronque la série par `idx <- (n - T + 1):n` (`R/engine.R` l. 1257, commentaire « on garde les T annees les plus recentes »). Il garde donc les T dernières lignes du fichier. Pour un fichier `T` en désordre, l'ancien moteur gardait les années 2, 5, 4, 8, 6, 7 au lieu de 3 à 8. Il contredisait ainsi son propre contrat.

### (1) Correction de mon avis (texte exact)

**`actuary-textes-555.md`, l. 34.** Remplacer « σ_USP ne bouge pas, car la vraisemblance de B/C ne dépend pas de l'ordre. En revanche, les tests sensibles à l'ordre (H3) peuvent changer de verdict. » par :

> Lorsque toutes les années du fichier sont retenues, σ_USP ne bouge pas. La vraisemblance de B/C est symétrique en les couples (x_t, y_t), et σ_USP n'en dépend que par l'ajustement (mesuré au bit près : revue finale d'`audit`, constat C1). En revanche, quand une profondeur T inférieure au nombre de lignes est demandée, le moteur retient les T dernières lignes du fichier. Ce ne sont plus les T années les plus récentes, donc σ_USP change (mesuré : 0,1280504 → 0,1193536 à T = 6). Les p-values des tests sensibles à l'ordre (tendance monotone, suites, sup-F, OLS-CUSUM, y compris sur ratios bruts) changent aussi, jusqu'au verdict (mesuré : sept verdicts sur une série à S/P croissant).

**Même fichier, l. 149.** Remplacer « Effet possible : verdicts H3 sur une série non triée et consécutivité non contrôlée ; σ_USP inchangé. » par :

> Effet possible : série non triée et consécutivité non contrôlée. σ_USP est inchangé si toutes les années sont retenues, mais il change à profondeur T réduite (années retenues fausses). Les p-values et verdicts des tests sensibles à l'ordre changent.

**`actuary-textes-555-colonne-t.md`, interaction 6, même correction.** Après « changent de sort : tri », insérer :

> (σ_USP inchangé si toutes les années sont retenues, changé à profondeur réduite ; p-values et verdicts des tests sensibles à l'ordre changés : constat C1 d'`audit`)

### (2) Décision 8 : options pour le mainteneur

- **(a) Confirmer, c'est ma recommandation.** Le fichier `T` est trié et sa consécutivité contrôlée, comme un fichier `t`.
  - Ce qui change n'est pas une régression. Le nouveau comportement corrige deux défauts silencieux :
    - à profondeur réduite, l'ancien moteur retenait de mauvaises années ;
    - les tests d'ordre tournaient sur une chronologie fausse.
  - Le cas S/P croissant le montre bien : une tendance réelle, que le désordre masquait (tendance monotone p = 0,588), est enfin détectée (p = 0,004).
  - À faire : compléter le tableau avant / après de la PR avec les mesures de C1, et corriger l'affirmation « aucun σ_USP, p-value ni verdict changé » du commit `21561e0`. On ne réécrit pas ce commit : le corps de PR et le présent avis suffisent.
- **(b) Refuser l'en-tête `T` avec un message** (« renommer la colonne en t »). Aucun réordonnancement silencieux, mais un fichier à l'en-tête sans ambiguïté est renvoyé à l'utilisateur. Cela ne protège pas mieux que (a), puisque (a) applique les mêmes contrôles qu'à `t`.
- **(c) Statu quo : `t` exact seul, `T` ignoré.** Je le déconseille. On revient au défaut silencieux : mauvaises années à profondeur réduite, tests d'ordre faussés, aucun contrôle de consécutivité.

**Colonne `T` étrangère, si la décision 8 est confirmée :**
- **`T` vide** : le fichier est refusé (« Colonne t incomplete … »). Ce refus est explicite et n'induit pas en erreur.
- **`T` portant autre chose que des années** : le fichier est refusé par les motifs de `t` (non entier, doublon, non consécutif). Ce n'est pas silencieux.
- **Risque résiduel** : une colonne étrangère qui serait, par coïncidence, une permutation d'entiers consécutifs. Les lignes seraient alors réordonnées sans message. Ce risque existe déjà pour un `t` exact : la décision 8 n'en crée pas un nouveau type, et je le juge négligeable.
- **Option hors périmètre** (issue à rédiger, création sur accord du mainteneur) : un message d'information quand le tri réordonne effectivement les lignes, pour `t` comme pour `T`. Je ne recommande pas d'étendre K3b.

### (3) `b2_non_defini` à l'égalité exacte (décision 4)

- **Le code ne change pas.** Le test `n < 20` passe en premier (`R/engine.R` l. 2420), donc rien ne bouge à T = 8.
- **Pourquoi l'égalité exacte reste le bon critère** :
  - b2 ne dépend pas de l'échelle des résidus : une tolérance absolue comme `TOL_EX_AEQUO` (1e-12) n'aurait pas de sens pour lui ;
  - le cas de dépassement ou de soupassement de capacité est déjà refusé par `stop()`.
- **Options** :
  - (a) statu quo strict ;
  - (b) ajouter le mot « exactement » dans la fiche (« résidus exactement constants ») ;
  - (c) passer à une tolérance dans le code, ce que je déconseille.
- **Recommandation : (b).** C'est un seul mot, qui fait dire à la fiche exactement ce que fait le code. `docwriter` l'ajoute dans son passage déjà prévu pour M1/M2. Ce n'est pas bloquant.

## Retour

- **Statut** : `complet`.
- **Résultat** :
  - (1) correction de la prémisse, avec les trois textes ci-dessus ;
  - (2) confirmer la décision 8, option (a), et tracer C1 dans la PR ;
  - (3) ajouter « exactement » dans la fiche, sans bloquer.
- **Preuves** :
  - *Vérifié par mesure* : `adv1.R`, `adv2.R` et `adv4.R` relancés, avec des résultats conformes à C1 ; σ_USP identique au bit près avec les 8 années (`adv4b_actuary.R`).
  - *Vérifié par lecture* : troncature `R/engine.R` l. 1257 ; reconnaissance de `T` l. 8040-8065 ; `test_anscombe_kurt()` l. 2411-2432 ; `TOL_EX_AEQUO` l. 316 ; décision 8 dans `decisions-mainteneur.md` l. 20 ; mes deux avis.
  - *Hypothèse* : une colonne `T` d'un fichier de séries porte l'année.
  - *Non vérifié* : chemin `openxlsx` pour `T`, déjà couvert par la batterie selon l'audit.
- **Informations manquantes** : aucune.
- **Décisions non résolues** (le mainteneur tranche) : confirmer la décision 8 en connaissant ses effets sur σ_USP et sur les verdicts ; retenir ou non l'option (b) pour `b2_non_defini` ; issue optionnelle sur le message de réordonnancement.
- **Critères déclenchés** : changement de résultat (σ_USP à profondeur réduite, sept verdicts hors références), soumis au mainteneur ; mon avis antérieur était erroné et je le corrige ici. Aucun désaccord avec `audit` : je rejoins C1.
- **Prochaine action recommandée** :
  - la session verse cet avis dans `docs/revues/20261112-fin-de-branche-k3b/`, complète le tableau avant / après de la PR avec les lignes de #555 et note la correction du message de `21561e0` ;
  - au retour du mainteneur, confirmation de la décision 8 ;
  - `docwriter` ajoute « exactement » avec M1/M2.
