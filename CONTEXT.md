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
La p-value qui fonde le verdict, choisie dans l'ordre : exacte, puis Monte-Carlo, puis asymptotique.
