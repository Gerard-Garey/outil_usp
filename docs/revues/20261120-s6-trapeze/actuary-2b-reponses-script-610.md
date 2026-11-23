# S6, #610 : réponses d'actuary aux questions de `coder-approfondi` sur le protocole 2b

> *Rédigé par l'agent actuary (IA).* S6, #610 : réponses aux six questions de `coder-approfondi` sur le protocole 2b. J'ai relu `docs/revues/20261120-s6-trapeze/actuary-2b-protocole-610.md` en entier (§ 2, P4, P5, P7, § 4, § 5, § 6 et les décisions du 20/11). Je n'ai pas ouvert le script non suivi : mes réponses portent sur ce que le brief en dit. Je n'ai rien écrit et créé aucune issue.
>
> *Note de versement (session principale) : réponses versées intégralement, telles que rendues, le 20/11/2026, avant le commit du script `tests/couverture_ic_sigma_mw_imbrique_t8.R`, qui les applique (reprise de `coder-approfondi` après l'audit léger).*

## Réponses (règle applicable, puis nature)

**1. Ordre des niveaux : correct.**
- Règle : on essaie dans l'ordre M1+P3, M1, M3, M4, et on retient le premier niveau dont la durée prévue au pré-vol est ≤ 12 h.
- Pourquoi M1+P3 passe avant M1 : dans le tableau du § 5, M1+P3 n'est pas un niveau distinct mais M1 plus un ajout facultatif. Q-2b-3 (a), « P3 si le budget le permet », se lit donc ainsi : on tente d'abord M1+P3, puis M1 seul. Avec le pré-vol actuel (8,39 h ≤ 12 h), c'est **M1+P3** qui est retenu. P3 est tiré à R = 500, fixé avant l'exécution et écrit au JOURNAL.
- Sous M1 : le script écrit « confirmation du mainteneur requise » et ne lance pas la mesure de lui-même ; il faut un `--niveau` explicite. La raison : le mainteneur a fixé le niveau M1, et P7, qui ne renvoie au mainteneur qu'au-dessous de M4, est plus faible que cette décision.
- Nature : lecture de P7 combinée à Q-2b-2 (a) et Q-2b-3 (a). **À signaler au mainteneur** : M4 retire C1, ce qui modifie K-610-1 (« C1 et C2 »). M4 touche donc le critère approuvé et ne peut venir que d'une décision de sa part.

**2. Formation de C2 : la règle du script est la bonne.**
- Règle pour C2 : plus de 20 réplications b avec n_b > 20 **et** ŝe\*_b fini et > 10⁻¹².
- Règle pour C1 et C0 : plus de 20 réplications b avec n_b > 20.
- C1-99 et C2-50 : les mêmes règles, appliquées aux 99 ou aux 50 premiers σ\*\*.
- Nature : lecture. Dans P4, « admises » veut dire admises pour l'intervalle considéré. Le but est que Q_t repose sur plus de 20 valeurs, ce que P4 ne pouvait pas garantir s'il comptait aussi des b dont ŝe\*_b est dégénéré.
- Complément sans effet sur le critère : si le ŝe externe est non fini ou ≤ 10⁻¹², C2 n'est pas formé et le cas est compté.

**3. Modificateur W : correct, avec une précision sur C1.**
- Pour C2, « bornes dégénérées » = les ŝe\*_b dégénérés. Les bornes de C2 sont finies dès que Q_t l'est.
- Pour C1, on compte **la saturation définie au § 2.1 seulement**, c'est-à-dire la saturation haute Q_w(α) = 0, au niveau 90 % (celui de K-610-1). La saturation basse n'entre pas dans W (voir la question 4).
- Les b exclues (n_b ≤ 20) comptent pour les deux candidats.
- Chaque taux est comparé séparément à 1 %, sur P1 et sur P2 séparément. On compare la proportion observée non arrondie, sans intervalle de confiance. W-a est atteint si chaque taux est ≤ 0,01.
- Dénominateurs :
  - saturations : triangles où C1 est formé ;
  - ŝe\*_b dégénérés : b avec n_b > 20, cumulées sur le profil ;
  - b exclues : σ\* finis, cumulés sur le profil.
- Nature :
  - « taux séparés » : je lève l'ambiguïté de « … et … au plus 1 % » en tant qu'auteur du texte ; le critère n'est pas modifié, mais le choix est à consigner au JOURNAL et à signaler au mainteneur pour information ;
  - **compter les saturations basses de C1 dans W serait un complément qui durcit le critère approuvé** : à ne pas faire sans décision du mainteneur.

**4. Saturations basses : à garder, comme données descriptives seulement.**
- Règle : compter séparément « saturation haute » et « saturation basse », à 90 % et à 95 % :
  - C1 : haute si Q_w(α) = 0, basse si Q_w(1 − α) = 1 ;
  - C0 : haute si Q_u(1 − α) = 1, basse si Q_u(α) = 0.
- Le test se fait par égalité exacte sur le quantile de type 7 calculé : une interpolation entre deux 0 ou deux 1 rend exactement 0 ou 1.
- Ces comptes vont dans K-610-2, qui mentionne déjà « saturations de C1 et C0 » sans préciser le côté. Ils n'entrent ni dans W ni dans Θ0.
- Nature : complément descriptif qui ne touche pas le critère.

**5. Θ0 : correct.** Trois taux distincts, pas de taux cumulé. Pour chacun, sur P1 ou sur P2, Θ0 se déclenche si la proportion observée non arrondie est > 0,01 :
- **refus** : triangles refusés, rapportés aux triangles tirés ;
- **triangles sans intervalle** : triangles admis où au moins un des intervalles I1, I4, C1, C2 à 90 % n'est pas formé, rapportés aux triangles admis. C'est l'union, pas un taux par intervalle. C0, C1-99 et C2-50, descriptifs, n'en font pas partie ;
- **b exclues** : b avec n_b ≤ 20, rapportées aux σ\* finis, cumulés sur le profil. Les ŝe\*_b dégénérés ne comptent pas ici : ils relèvent de W.

Nature : lecture. La conjonction « ou » de Θ0 sépare les trois taux, et W distingue « b exclus » et « bornes dégénérées ». Le choix de l'union n'aura d'effet que si différents intervalles manquent sur différents triangles ; on attend 0 sur P1 et P2.

**6. Préférence (ii).**
- Règle : le coût d'un candidat se mesure pour la procédure mesurée, celle que couvre le statut épistémique (B1 = 999, B2 = 199). À cette procédure, C1 et C2 demandent les mêmes tirages, et leur calcul propre est négligeable. Leurs coûts sont donc égaux par construction.
- Le script écrit : « (ii) non discriminante : coûts égaux à B2 = 199 (mêmes tirages, × 3,68 par `run_engine()` au pré-vol) ; la règle renvoie à la décision du mainteneur en dernier ressort ».
- Il donne le × 1,77 de C2 seul à B2 = 50 **à titre d'information**, sans l'utiliser pour (ii). C2-50 est descriptif, et ce n'est pas lui que la mesure qualifie. Le restituer à la place de C2 serait une décision de D3, à prendre au vu de ses propres classes descriptives.
- Le script calcule (i) mécaniquement, et ne désigne lui-même aucun candidat préféré.
- Nature : lecture. Le § 5 chiffrait déjà « C1 et C2 à B2 = 199 » comme un coût unique.

## Retour

- **Statut** : `complet` pour la lecture du protocole. Je n'ai pas lu le script : la conformité du code à ces règles relève d'`audit`.
- **Résultat** : les points 1, 2, 3 (pour C2 et les b exclues), 5 et 6 sont des lectures du protocole. Le point 4 et la règle sur le ŝe externe (point 2) sont des compléments descriptifs. Deux points touchent ou bordent le critère approuvé : la baisse à M4 (retire C1 de K-610-1) et l'éventuelle inclusion des saturations basses dans W (durcirait le critère).
- **Preuves** :
  - *vérifiées* (relecture du protocole versé) : § 2.1 (la saturation n'est définie que pour Q_w(α) = 0), § 2.2 (ŝe\*_b exclus et comptés), P4, P5, P7, § 4 (texte de Θ0 et de W), § 5 (tableau des niveaux, coût unique « C1 et C2 à B2 = 199 »), décisions du 20/11 ;
  - *hypothèse* : le calcul propre de w et de t\* est négligeable devant les tirages ;
  - *non vérifié* : le code du script.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : le mainteneur, en cas de baisse sous M1 (et en particulier à M4), en cas d'égalité sur (i) et (ii) à D3, et s'il veut compter les saturations basses dans W.
- **Critères déclenchés** : deux lectures possibles d'une phrase du protocole (« … et … au plus 1 % » de W), tranchée ici par son auteur sans changer le critère ; c'est un problème de rédaction du protocole, pas de documentation disponible. Aucun changement de résultat, aucun désaccord.
- **Constats hors périmètre** : aucun.
- **Prochaine action recommandée** : `coder-approfondi` applique ces règles et les consigne au JOURNAL (dont le choix de taux séparés pour W), puis `audit` léger ; mesure M1+P3 selon M42, sur `claude/sauvegarde-610`, que Q-2b-7 autorise d'avance (pré-vol au-delà de 2 h).
