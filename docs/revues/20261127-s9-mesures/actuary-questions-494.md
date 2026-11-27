# S9, étape 5 bis : réponses aux quatre questions de précision du coder sur `ff7673f` (#494)

> *Rédigé par l'agent actuary (IA), fiche `actuary`, le 27/11/2026, sur `claude/mesures-t8`, commit `ff7673f`. md5 de `R/engine.R` : `c7b767f5d9116c35a0a9237ffdd2d79a` (vérifié). Aucun fichier écrit, aucune issue ouverte. Versé intégralement par la session principale (Q-54-10).*

Lu : `git show ff7673f:tests/puissance_mw_t8.R` (`RHO_CORRDEV_309`, recoupement REC309, F3, F4), `R/engine.R` (hiérarchie de `add()`, l. 5387-5398 ; lignes CorrDev et DW de `mw_tests()`, l. 17243-17264), le tableau de #309 (l. 84, 127, 146, 222, 241), l'avis de l'étape 1 (§ 4) et celui de l'étape 5.

**Q1. Rejet lu sur `p_mc` : je confirme. Aucun changement de code. [V]**
- Dans `mw_tests()`, CorrDev et DW n'ont pas de p exacte (`p_ex` absent) et portent un `mc_nom`. La hiérarchie de `add()` en tire `p_retenue = p_mc` dès que `p_mc` est finie. Si `p_mc` manque, aucune p non simulée ne la remplace (l. 5391-5394, #181).
- Pour ces deux lignes, « p_mc » et « p retenue de la procédure du dossier » sont donc la même grandeur par construction, et non par hasard. Le § 4.1 est respecté.
- La colonne de F3 (« p retenue ≠ p_mc ») sert de garde-fou si la hiérarchie évolue : elle doit rester à 0. Tout écart non nul est à me renvoyer avant toute lecture.

**Q2. Statut d'admission différent de #309 compté en INTEGRITE ECHEC : extension acceptée. Aucun changement de code. [V pour le fait, H pour l'interprétation]**
- Sur un même b, triangle et graines sont les mêmes. Un statut différent signifie donc soit un triangle différent, soit une règle d'admission modifiée depuis #309. Dans les deux cas, l'appariement du second cas de PM-3 perd son fondement.
- Arrêter le calcul est la réaction prudente ; continuer en silence sur l'intersection ne l'est pas.
- En #309, P1.H0 a n = 1 000 admis sur R = 1 000 (l. 222). Un refus en S9 serait donc un fait nouveau.
- Réserve : un ECHEC de ce contrôle ne disqualifie pas la mesure par lui-même. Il me revient pour en établir la cause (générateur ou admission) avant que le mainteneur décide.

**Q3. Premier cas de PM-3 jugé contre le ρ de #309 relu : accepté. Aucun changement de code. [V pour la provenance, H pour la stabilité de ρ]**
- ρ est la taille lissée à B = 999 du test Monte-Carlo idéal sous F0 (#309, l. 84). Il dépend de trois choses : la statistique, le DGP (ORA-A-N est l'oracle de P1, ORA-B-P2 celui de P2) et B.
- L'identité de `obs:CorrDev` triangle par triangle atteste la statistique et le DGP. L'égalité « p_mc = p:CorrDev », relevée aussi en F4, atteste en plus la règle « ≥ » d'`engine_p_mc()`.
- L'arrondi à 5 décimales (au plus 5e-6) est négligeable. L'erreur de ρ due à N0 est d'environ 0,002 [H de #309], et les bandes de classe sont ρ/2 et 3ρ/2.
- Limite : ρ ne vaut qu'à B = 999. Une classe F4 calculée en essai à B réduit n'a aucune valeur. L'en-tête marque déjà ce cas « non représentatif » ; il faut s'en tenir à ce marquage.
- À noter : si p_mc est identique à p:CorrDev sur toutes les paires, le second cas donne mécaniquement n01 = n10 = 0 et p = 1. C'est le résultat attendu d'un moteur dont la chaîne CorrDev n'a pas changé, pas un défaut du contrôle.

**Q4. « Ligne présente » = « p_mc finie » : accepté sous condition. Changement de texte recommandé, sans effet sur les nombres. [V pour le code, H pour l'effet]**
- L'analogie avec F1 n'est pas exacte. En F1, une ligne T-3b (sans p) reste dans n et compte comme non-rejet. En F4, premier cas, comme en #309, une p absente compte aussi comme non-rejet dans n. En F3, un triangle admis dont la p_mc n'est pas finie sort de n.
- Or la puissance de la procédure du dossier est P(rejet). Un test sans p ne rejette pas.
- Les deux définitions coïncident tant que le nombre d'absences est nul. C'était le cas en #309 (abs. = 0 pour CorrDev, l. 222 et 241). F3 permet de recalculer l'autre convention (k / admis), car il imprime « admis » et n.
- Condition : si, dans une cellule, n < admis pour CorrDev ou DW, la lecture du § 4.5 se fait sur le dénominateur des admis, p absente comptée comme non-rejet. Le fait doit être signalé.
- Recommandation non bloquante : écrire dans la note de F3 « ligne présente : p_mc finie (statistique seule), L ou T-3b (famille) » et rappeler l'écart de convention avec F1 et F4.

## Retour
- **Statut** : `complet`.
- **Résultat** :
  - Q1 confirmée, Q2 et Q3 acceptées, sans changement de code ;
  - Q4 acceptée sous la condition « absences nulles, sinon dénominateur des admis », avec une précision de note recommandée (texte seul).
- **Preuves** :
  - *Vérifiées* : code de `ff7673f` (lignes citées), hiérarchie de `add()`, tableau de #309.
  - *Hypothèses* : ρ stable entre les deux versions du moteur ; cause d'un éventuel écart de statut ; absences nulles sous AR(1).
  - *Non vérifiée* : la sortie de l'essai, que je n'ai pas vue.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune. La lecture d'un éventuel signal PM-3 ou d'un INTEGRITE ECHEC reviendra à actuary, puis au mainteneur.
- **Critères déclenchés** : aucun.
- **Constats hors périmètre** : un seul, l'écart de convention de dénominateur entre F1/F4 et F3 (Q4). Critère ADR 0018 : aucun, tant que les absences sont nulles (mineur).
- **Prochaine action recommandée** : le coder ajoute la précision de note de la Q4 (facultatif) ; ensuite, lancement de la campagne au périmètre fixé par le pré-vol (PM-2).
