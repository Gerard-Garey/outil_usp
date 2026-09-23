# Calibrage des USP

Vocabulaire de l'outil de calibrage des paramètres propres à l'entreprise (Solvabilité II, annexe XVII), tel qu'il doit être employé dans le code, la documentation et le dossier ACPR.

## Modèle

**Modèle réglementaire** :
Le modèle statistique imposé par l'annexe XVII pour une méthode donnée ; pour les méthodes prime et réserve n° 1, pertes lognormales d'espérance proportionnelle au volume et de variance quadratique en le volume.
_Avoid_ : modèle ajusté (qui désigne le modèle réglementaire aux paramètres estimés), modèle MCO

**δ (paramètre de mélange)** :
Le poids, dans [0, 1], de la composante de variance proportionnelle au carré du volume ; il est estimé par maximum de vraisemblance comme l'impose l'annexe XVII, et il est presque non identifiable à T = 8 quand les volumes varient peu (δ̂ au bord de [0, 1] dans la plupart des cas).

## Restitution des vérifications

**Test** :
Une vérification d'hypothèse qui comporte une hypothèse nulle, une statistique, une p-value et un verdict.
_Avoid_ : contrôle, test complémentaire

**Diagnostic** :
Une quantité ou un graphique présenté sans verdict, pour éclairer la lecture des tests ou de l'estimation.
_Avoid_ : indicateur, contrôle

**Verdict** :
La conclusion d'un test au seuil α : OK, ALERTE ou ECHEC. Un diagnostic n'a pas de verdict (affiché INFO).

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
Une grandeur des résidus contrainte par une condition du premier ordre du maximum de vraisemblance plutôt que librement observée : sa dispersion sous le modèle est gouvernée par celle des poids π̂_t, non par les données, de sorte qu'elle ne peut pas contredire le modèle. Dans la branche lognormale, la condition en ln β (identité algébrique, Σ √π̂_t z_t = 0, forme fermée de `usp_noyau()`) rive la moyenne des résidus standardisés dans tous les cas ; la condition en γ, relation pondérée distincte qui ne tient qu'à un optimum intérieur en γ (domaine [−12, 3] de `usp_ajuster()`), rive leur variance. Quand π̂_t est constant, la contrainte détermine la grandeur : elle est alors une statistique dégénérée. Une grandeur rivée n'a aucune p-value retenue et est restituée comme diagnostic (« Centrage » et « Variance unitaire » dans `usp_tests()`, ADR 0001).
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

**Référence de non-régression** :
L'objet complet retourné par `run_engine()` pour un cas de test, enregistré dans `tests/reference/*.rds` (produit sur la plateforme désignée par l'ADR 0006) et auquel le second volet de `tests/test_reproductibilite.R` compare le résultat courant par `all.equal(tolerance = 1e-8)` sur toute sa structure. Cette comparaison n'est pas du bit près : `all.equal` juge une différence relative moyenne, et une dérive de plateforme diffuse (mesurée : écart relatif maximal 3,5e-07 sur les tirages bootstrap, 44 % des feuilles touchées) passe sous la tolérance (ADR 0006). Tout champ ajouté, retiré ou modifié impose une régénération sur la plateforme désignée — ou, pour les seules grandeurs non numériques, un patch chirurgical (ADR 0006, amendement) — accompagnée d'un tableau avant / après expliqué ligne à ligne.
_Avoid_ : golden file, snapshot ; « comparé au bit près » (propriété de la reproductibilité à graine égale, pas de la non-régression)

## Restitution figée

**Rapport figé** :
Le document HTML autonome — un seul fichier, aucune ressource chargée par URL — qui restitue l'objet retourné par `run_engine()` tel qu'il est en mémoire au moment de sa génération : données du calcul (jamais la saisie courante), contrôles, paramètre retenu et calibration, tests retenus, tests exclus en annexe, graphiques, et empreintes. Il ne relance aucun calcul ; toute valeur qu'il porte vient du moteur (ADR 0009, `docs/exigences.md` § 5.6).
_Avoid_ : export (désigne les tables CSV brutes), rapport dynamique, snapshot, rapport de session

**Empreinte** :
Un md5 qui identifie ce que le rapport figé restitue, calculé par le moteur hors `run_engine()` (`engine_empreinte()`). Trois empreintes, de statut différent : celle des **données** (texte canonique des données du calcul) ne dépend que des valeurs et se recalcule par un tiers ; celle du **résultat** (objet sérialisé sans horodatage ni durée) est stable sur une même machine mais dépend de la plateforme (ADR 0006) et ne se compare pas d'une machine à l'autre ; celle du **code** (octets de `R/engine.R`, avec la version de `DESCRIPTION`) identifie le moteur chargé. Elle atteste la correspondance entre une pièce et une exécution, pas l'authenticité de la pièce.
_Avoid_ : hash, checksum, somme de contrôle ; signature (aucune clé : l'empreinte ne prouve pas la provenance)
