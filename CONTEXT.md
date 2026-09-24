# Calibrage des USP

Vocabulaire de l'outil de calibrage des paramètres propres à l'entreprise (Solvabilité II, annexe XVII), tel qu'il doit être employé dans le code, la documentation et le dossier ACPR.

## Modèle

**Modèle réglementaire** :
Le modèle statistique imposé par l'annexe XVII pour une méthode donnée ; pour les méthodes prime et réserve n° 1, pertes lognormales d'espérance proportionnelle au volume et de variance quadratique en le volume.
_Avoid_ : modèle ajusté (qui désigne le modèle réglementaire aux paramètres estimés), modèle MCO

**δ (paramètre de mélange)** :
Le poids, dans [0, 1], de la composante de variance proportionnelle au carré du volume ; il est estimé par maximum de vraisemblance comme l'impose l'annexe XVII, et il est presque non identifiable à T = 8 quand les volumes varient peu (δ̂ au bord de [0, 1] dans la plupart des cas).

**Tolérance de bord (`TOL_DELTA_BORD`)** :
La tolérance unique, 1e-6, déclarée une fois en tête de `R/engine.R`, avec laquelle le moteur juge qu'un estimateur ou une donnée est à sa frontière : δ̂ au bord de [0, 1] (`delta_au_bord`, en absolu, inégalités larges) et volumes constants (en relatif à la moyenne). Elle est choisie au-dessus de la résolution de l'optimiseur L-BFGS-B (~1e-9 en ajustement complet, ~1e-7 en réajustement rapide) pour qu'un même δ̂ soit classé de la même façon quelle que soit la plateforme ; elle est calculée par `usp_regime()` et lue par `usp_ajuster()` et `usp_tests()` (issue #31). Elle ne dit rien de la précision de σ_USP : c'est une convention de restitution, pas un seuil statistique.
_Avoid_ : 1e-9 (ancien seuil sur l'étendue des π̂_t, abandonné le 23/09/2026), tolérance d'arrêt (celle de l'optimiseur, distincte)

**Volumes constants** :
La configuration où les volumes x_t sont égaux entre eux à la tolérance de bord près, en relatif (`diff(range(x)) <= TOL_DELTA_BORD · mean(x)`, `usp_regime()$volumes_constants`). C'est l'une des deux causes, avec δ̂ = 1, pour lesquelles π̂_t est constant en t (`pi_constant`) ; c'est aussi la configuration où la vraisemblance ne dépend plus de δ, qui n'est alors pas identifié (la valeur affichée de δ̂ est celle où l'optimiseur s'est arrêté), et où toute vérification qui régresse sur le volume est sans objet. Une seule définition doit servir à toutes les lignes du moteur ; les gardes numériques `sd(x) == 0` de certains tests en sont une version exacte, à aligner (issue #59).
_Avoid_ : volumes identiques, x constant au bit près (la constance est jugée à la tolérance de bord, pas exactement)

## Restitution des vérifications

**Test** :
Une vérification d'hypothèse qui comporte une hypothèse nulle, une statistique, une p-value et un verdict.
_Avoid_ : contrôle, test complémentaire

**Diagnostic** :
Une quantité ou un graphique présenté sans verdict, pour éclairer la lecture des tests ou de l'estimation. Un seuil conventionnel attaché à un diagnostic (2k/T pour les leviers, 4/T pour la distance de Cook, 10 % / 20 % pour le jackknife…) est un **repère** de lecture conservé dans `detail`, pas un seuil de rejet : il ne produit aucun verdict (ADR 0001, amendement du 23/09/2026, décision M7).
_Avoid_ : indicateur ; contrôle (réservé aux entrées de `res$controles` : contrôles de qualité des données, contrôles numériques de l'estimation) ; seuil de rejet (pour un repère)

**Verdict** :
La conclusion d'un test au seuil α : OK, ALERTE ou ECHEC. Seules en portent une ligne de `type = "test"` et la procédure de décision ESD (`type = "procedure de decision"`, qui décide au niveau α sans p-value) ; toute autre ligne — diagnostic, « non applicable » — n'a pas de verdict (affiché INFO) et son `sens_du_test` vaut `NA` (ADR 0001, amendement du 23/09/2026, décision M7). Le champ `verdict` des entrées de `res$controles` (familles A et H) est une issue réussi / échoué, OK ou ECHEC, sans seuil α ni ALERTE : ce n'est pas un verdict au sens de la table des tests.

**Contrôle numérique de l'estimation** :
Une vérification d'une **condition d'optimalité** de l'ajustement lognormal, jugée à une précision numérique annoncée, qui dit si l'optimiseur a fait son travail — et rien sur les données ni sur le modèle. Elle n'est ni un test (aucune hypothèse nulle, aucune loi de référence, aucune p-value : `p = NA`) ni un diagnostic (elle porte une issue OK / ECHEC) ; ses repères sont des tolérances numériques fixées en tête de `R/engine.R` (`TOL_OPTIMUM`, `REP_PAS_KKT`, `REP_GD_KKT`), non des seuils statistiques, et ils ne dépendent pas de T. Le verdict est **OK ou ECHEC, non bloquant** : `run_engine()` renvoie `ok = TRUE` et toutes ses sorties même en cas d'ECHEC, qui signale que le maximum de vraisemblance n'est peut-être pas atteint — point stationnaire non certifié (KKT) ou optimum non certifié par `optim()` ni corroboré par un second démarrage (convergence) — et que σ_USP se lit avec cette réserve. Les contrôles numériques forment la famille « H. Controles numeriques de l'estimation » de `res$controles` (`usp_controles_numeriques(fit)`, mêmes six champs que les contrôles de qualité des données de la famille A : `famille`, `test`, `stat`, `p`, `verdict`, `detail`), hors de la table des tests (M11 : ils l'ont quittée, 50 → 48 lignes ; l'ADR 0001 amendé, qui met toute ligne non-test de la table en INFO, ne les concerne donc pas). Deux contrôles, tous deux jugés sur le **même ensemble des démarrages à l'optimum** — les démarrages de la grille de `usp_ajuster()` dont l'objectif est à moins de `TOL_OPTIMUM` du minimum — et non sur le seul démarrage retenu, qui est départagé par l'ordre de la grille et varie selon la plateforme (M23) :
- **Condition du premier ordre (gradient projeté, KKT)** : OK si **au moins un démarrage à l'optimum** satisfait, **sur le même point**, toutes les conditions de `usp_kkt_satisfaite()` — gradient et gradient projeté finis, γ intérieur aux bornes numériques `BORNES_GAMMA` (à `TOL_DELTA_BORD` près), courbure H_γγ finie et strictement positive, |pas de Newton en γ| ≤ `REP_PAS_KKT`, |composante projetée du gradient en δ| ≤ `REP_GD_KKT`, règle unique au bord comme à l'intérieur (M16, M17, M25) ; la décision est calculée dans `usp_ajuster()` (`res$ajustement$kkt_au_moins_un`, dernier champ) ; `stat` est le pas de Newton du démarrage retenu, grandeur descriptive qui ne décide pas du verdict.
- **Convergence multi-démarrages** : OK si au moins un démarrage à l'optimum rend le code de retour 0 d'`optim()` et si au moins deux démarrages atteignent l'optimum (M15) ; `stat` est la part κ des démarrages aboutis à l'optimum, sans repère.
Le texte des `detail` n'est pas cité ici : il est en cours de raccourcissement (#76). Décisions : M11 (emplacement), M14 (gradients exclus de la comparaison aux références), M15 à M17 (règles et repères), M23 (démarrage retenu), M25 (KKT « au moins un démarrage, même point ») ; issues #22, #73.
_Avoid_ : test de convergence, test KKT (pas de loi, pas de p-value) ; diagnostic de convergence (il y a un verdict) ; contrôle de validité (réservé à `engine_valider_donnees()`, qui seul peut refuser le calcul, `ok = FALSE`) ; contrôle des données (famille A de `res$controles`, `usp_controle_donnees()`, qui porte sur les entrées, OK/ECHEC non bloquant) ; verdict INFO (réservé aux lignes de la table des tests) ; seuil de rejet, niveau α (pour un repère numérique) ; « l'optimiseur a convergé » pour le seul code 0 du démarrage retenu (le code du retenu ne décide plus, M15, M23)

**Test inopérant** :
Un test dont la plus petite p-value atteignable, sur le jeu de données considéré, dépasse le seuil α retenu pour le calcul : il ne peut pas rejeter et il est restitué comme diagnostic, avec cette p-value minimale.
_Avoid_ : test non significatif

**Sensibilité à δ** :
Le diagnostic qui donne σ_USP recalculé avec δ fixé à 0 puis à 1, pour mesurer l'effet de l'incertitude sur δ sur le paramètre final ; le σ_USP retenu reste celui du maximum de vraisemblance.

**Test retenu** :
Une ligne de la table des tests (test ou diagnostic) que la personnalisation de la restitution conserve : cochée par l'utilisateur et calculée sur la base de résidus choisie pour ce test, ou à base unique. La sélection ne touche à aucun calcul — le moteur produit toutes les lignes — et une seule règle la définit (`filtrer_selection()`), appliquée à l'identique par l'onglet Tests et par le rapport figé ; une ligne non retenue est un **test exclu**, restitué en annexe du rapport figé avec son verdict et le motif de son exclusion (ADR 0009).
_Avoid_ : test sélectionné, test affiché ; test désactivé, test masqué (suggèrent un effet sur le calcul)

## P-values

**P-value exacte** :
Une p-value dont la loi de la statistique sous H0 est exacte sous le modèle réglementaire. Une p-value exacte sous un autre modèle (par exemple à variance constante) n'est pas exacte au sens de l'outil.
_Avoid_ : p-value théorique

**P-value Monte-Carlo** :
Une p-value estimée par simulation sous le modèle ajusté (bootstrap paramétrique) ; son erreur dépend du nombre B de réplications, pas de T.
_Avoid_ : p-value bootstrap, p-value simulée

**P-value asymptotique** :
Une p-value issue de la loi limite de la statistique quand T tend vers l'infini ; sa qualité à T = 8 n'est jamais présumée.

**P-value retenue** :
La p-value qui fonde le verdict, choisie parmi celles qui existent dans l'ordre : exacte, puis Monte-Carlo, puis asymptotique ; `nature_p` documente le choix. La hiérarchie ordonne des p-values qui existent et ne se lit pas à l'envers : une grandeur rivée par l'estimation n'a aucune p-value retenue (`p_retenue = NA`, `nature_p = NA`, verdict INFO, dernière branche de `add()` dans `usp_tests()`), et le repli sur la loi asymptotique ou, plus généralement, sur la loi nominale — celle que la statistique suivrait si les paramètres n'avaient pas été estimés — est interdit, parce que la valeur observée n'est pas une observation : à π̂_t constant, la p-value nominale est une constante de T qui ne dépend pas des données (ADR 0001, issue #23).
_Avoid_ : p-value par défaut, repli asymptotique

**Statistique Monte-Carlo** :
Une entrée du catalogue des statistiques simulées d'une méthode : sa fonction de calcul, son sens de rejet (haut, bas, deux) et sa condition de dégénérescence ; la statistique affichée pour un test à p-value Monte-Carlo est celle-là, et elle est calculée, simulée et associée au test depuis ce seul catalogue (ADR 0003).
_Avoid_ : statistique bootstrapable, mc_nom (nom de variable, pas terme du domaine)

**Grandeur rivée par l'estimation** :
Une grandeur des résidus contrainte par une condition du premier ordre du maximum de vraisemblance plutôt que librement observée : sa dispersion sous le modèle est gouvernée par celle des poids π̂_t, non par les données, de sorte qu'elle ne peut pas contredire le modèle. Dans la branche lognormale, la condition en ln β (identité algébrique, Σ √π̂_t z_t = 0, forme fermée de `usp_noyau()`) rive la moyenne des résidus standardisés dans tous les cas ; la condition en γ, relation pondérée distincte qui ne tient qu'à un optimum intérieur en γ (domaine [−12, 3] de `usp_ajuster()`), rive leur variance. Quand π̂_t est constant, la contrainte détermine la grandeur : elle est alors une statistique dégénérée. Quand π̂_t n'est pas constant (δ̂ au bord ou intérieur, volumes variables), la grandeur reste rivée par la condition mais n'est pas déterminée par elle : var(z) n'a alors pas de valeur de référence, et son écart à T/(T−1) ne se lit pas comme un écart au modèle (libellé de la ligne « Variance unitaire », issue #39). Une grandeur rivée n'a aucune p-value retenue et est restituée comme diagnostic (« Centrage » et « Variance unitaire » dans `usp_tests()`, ADR 0001).
_Avoid_ : statistique rivée (ce n'est pas une statistique de test)

**Statistique dégénérée** :
Une statistique dont la valeur observée est fixée par l'estimation sur le jeu de données considéré, quelles que soient les observations : identiquement nulle, ou égale à une constante connue. Exemple : la moyenne des résidus standardisés (nulle, à la précision machine) et leur variance (égale à T/(T−1) à la tolérance d'arrêt de l'optimiseur près, pour un optimum intérieur en γ ; mesuré sur les données de test à δ̂ = 1 : var(z) = 1,1428564 contre T/(T−1) = 1,1428571) lorsque π̂_t est constant, c'est-à-dire δ̂ = 1 ou volumes x_t constants — et non dès que δ̂ est au bord de [0, 1] : à δ̂ = 0 avec des volumes variables, π̂_t varie et aucune des deux égalités ne tient. Elle ne peut pas contredire le modèle. Sa loi simulée sous le modèle ajusté n'est pas constante : c'est un mélange qui porte un atome en la valeur observée dès qu'une partie des réplications retombe dans la même configuration (sur les données de test, 493 réplications sur 999 à δ* = 1, 460 à δ* = 0, 46 intérieures) ; la p-value Monte-Carlo s'y décide par des ex æquo de bruit numérique et n'a pas de sens. La vérification est restituée comme diagnostic (ADR 0001 et son amendement du 22/09/2026, ADR 0003 ; issues #3, #27). Toute statistique dégénérée est une grandeur rivée par l'estimation ; la réciproque est fausse.
_Avoid_ : grandeur instable (désigne l'exclusion provisoire dans les tests, pas la propriété statistique) ; loi simulée constante (fausse : la loi simulée est un mélange à atome)

## Reproductibilité

**Graine locale** :
La convention selon laquelle toute simulation du moteur pose sa propre graine, explicite et consignée dans les métadonnées, et restaure l'état du générateur de l'appelant à sa sortie ; aucune p-value ne dépend de l'ordre des simulations ni de l'état du générateur avant l'appel (ADR 0004).

**Reproductibilité à graine égale** :
La propriété selon laquelle deux appels de `run_engine()` à données, paramètres et graine identiques, sur une même machine, retournent des objets `identical()`, au bit près, hors les trois champs d'exécution de `$metadata` (horodatage, durée, version de R) que le test retire avant comparaison (`nettoyer()` dans `tests/outils_tests.R`) ; vérifiée par le premier volet de `tests/test_reproductibilite.R` (mesurée, ADR 0004 et 0006). Elle ne s'étend pas d'une plateforme à l'autre : la branche lognormale passe par un optimiseur sur une vraisemblance quasi plate en δ, dont le chemin dépend de la bibliothèque BLAS et de la version de R (explication cohérente avec les mesures, non démontrée ; ADR 0006).
_Avoid_ : non-régression (la comparaison aux références, à tolérance, est une autre propriété)

**Critère de non-régression** :
La règle, unique et définie dans `tests/outils_tests.R`, qui décide si un résultat courant de `run_engine()` est « le même » que sa référence de non-régression : l'objet est aplati en feuilles atomiques nommées par leur chemin (`aplatir()`), les deux côtés doivent porter le même ensemble de chemins, et chaque feuille est jugée isolément, jamais en moyenne — feuille non numérique : `identical()` ; feuille dont le type diffère d'un côté à l'autre (`integer` contre `double` de même valeur, booléen contre nombre) : écart, le type faisant partie de la valeur — plus strict que `all.equal`, et voulu, un changement de type étant un changement de code ; feuille numérique non finie (`NA`, `NaN`, `±Inf`) d'un côté : `identical()` ; feuille numérique finie de même type : écart relatif |Δ|/|ref| ≤ 1e-6 si |ref| > 1e-6, écart absolu |Δ| ≤ 1e-6 sinon (règle de `all.equal.numeric` appliquée valeur par valeur ; la bascule vers l'absolu évite qu'une grandeur nulle par construction, ~1e-16 d'arrondi, affiche un écart relatif d'ordre 1). La structure de l'objet entier, que l'aplatissement ne restitue pas, est contrôlée à part (`structure_arbre()`) : `typeof` et tous les attributs de chaque nœud (`class`, `names`, `row.names`, `dim`, y compris les noms d'un scalaire) comparés par `identical()`, contrôle insensible à la plateforme puisque ces attributs sont des chaînes ou des entiers. Le seuil 1e-6 est empirique : environ trois fois la dérive de plateforme maximale mesurée (3,508e-07, poste du mainteneur contre Linux R 4.3.3), valable tant que les références sont produites sur le poste, à réexaminer à la bascule vers la CI (ADR 0006, second amendement du 23/09/2026 ; décision M9, issue #14). Le même comparateur sert au second volet de `tests/test_reproductibilite.R`, au tableau avant / après de `tests/comparer_references.R` et à `tests/patcher_reference.R`, tant pour le tri des grandeurs différentes avant patch (`ecart_feuille()`) que pour sa vérification finale (`comparer_objets()`).
_Avoid_ : tolérance agrégée, différence relative moyenne (critère antérieur, `all.equal(tolerance = 1e-8)`, abandonné le 23/09/2026 : il absorbait la dérive de plateforme et, parce que sa moyenne ne porte que sur les éléments différents d'un même vecteur, il pouvait diluer un changement localisé tombant dans un vecteur qui dérive — les tirages bootstrap, cas réel ; un scalaire isolé restait détecté)

**Référence de non-régression** :
L'objet complet retourné par `run_engine()` pour un cas de test, enregistré dans `tests/reference/*.rds` (produit sur la plateforme désignée par l'ADR 0006) et auquel le second volet de `tests/test_reproductibilite.R` compare le résultat courant selon le critère de non-régression : feuille par feuille, tolérance 1e-6 par valeur élémentaire, structure contrôlée à part. Cette comparaison n'est pas du bit près : elle absorbe volontairement la dérive de plateforme (mesurée : écart relatif maximal 3,5e-07 sur les tirages bootstrap, 44 % des feuilles touchées, ADR 0006), mais tout écart au-delà du seuil sur une seule feuille, tout chemin ajouté ou retiré, toute feuille non numérique différente, est une régression nommée par son chemin. Tout champ ajouté, retiré ou modifié impose une régénération sur la plateforme désignée — ou, pour les seules grandeurs non numériques, un patch chirurgical (ADR 0006, premier amendement) — accompagnée d'un tableau avant / après expliqué ligne à ligne.
_Avoid_ : golden file, snapshot ; « comparé au bit près » (propriété de la reproductibilité à graine égale, pas de la non-régression)

## Restitution figée

**Rapport figé** :
Le document HTML autonome — un seul fichier, aucune ressource chargée par URL — qui restitue l'objet retourné par `run_engine()` tel qu'il est en mémoire au moment de sa génération : données du calcul (jamais la saisie courante), contrôles, paramètre retenu et calibration, tests retenus, tests exclus en annexe, graphiques, et empreintes. Il ne relance aucun calcul ; toute valeur qu'il porte vient du moteur (ADR 0009, `docs/exigences.md` § 5.6).
_Avoid_ : export (désigne les tables CSV brutes), rapport dynamique, snapshot, rapport de session

**Empreinte** :
Un md5 qui identifie ce que le rapport figé restitue, calculé par le moteur hors `run_engine()` (`engine_empreinte()`). Trois empreintes, de statut différent : celle des **données** (texte canonique des données du calcul) ne dépend que des valeurs et se recalcule par un tiers ; celle du **résultat** (objet sérialisé sans horodatage ni durée) est stable sur une même machine mais dépend de la plateforme (ADR 0006) et ne se compare pas d'une machine à l'autre ; celle du **code** (octets de `R/engine.R`, avec la version de `DESCRIPTION`) identifie le moteur chargé. Elle atteste la correspondance entre une pièce et une exécution, pas l'authenticité de la pièce.
_Avoid_ : hash, checksum, somme de contrôle ; signature (aucune clé : l'empreinte ne prouve pas la provenance)
