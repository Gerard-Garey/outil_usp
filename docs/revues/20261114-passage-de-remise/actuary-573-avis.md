# Avis d'`actuary` (fiche de base) sur la lecture amont de #573, 14/11/2026

Base : `main` `f8ff168`. Avis seul. Rapport de `regulatory` : `regulatory-573-amont.md`.

## 1. Information perdue par la suppression
Aucune :
- `phrase_art220` cite déjà l'art. 220(1)(b), qui prévoit les méthodes n° 1 et n° 2 ; l'application propose `reserve2` comme méthode à part entière ;
- la phrase n'ajoutait qu'une orientation pratique, inexacte : la méthode n° 2 a ses propres conditions (annexe XVII, D(2), via l'art. 219(1)(d) ; R > 0, D(4)) ;
- à la borne basse, la cause du refus (ratios y_t/x_t quasi constants) est un défaut de données de C(1)(a), et le motif renvoie déjà à l'action utile (« Verifier que y_t est observe… ») ;
- un motif imprimé peut être cité tel quel dans un dossier ACPR : « reste ouverte » se lit comme un repli acquis, contraire à l'encadré I > J et à l'annotation bis de l'ADR 0005.

La variante de réécriture de `regulatory` apporte peu et comporte un risque : citer l'art. 220(2) au moment du refus se lit comme une invocation, contraire au `.tex` (l. 4445-4450 : l'art. 220(2) « n'est pas invoqué »), et l'entreprise n'est sans doute pas « en mesure d'utiliser » les deux méthodes quand la n° 1 ne fournit pas de paramètre.

## 2. Recommandation
**Suppression pure** de la phrase dans les deux formes du motif (`R/engine.R` l. 2006 et 2024 ; définition l. 1986). Avant / après du § 3 de `regulatory` : correct.

Seule phrase de repli acceptable, si le mainteneur en veut une (ASCII, sans art. 220(2), sans « ouverte ») :
`La methode du risque de reserve no 2, prevue au meme point, est soumise a ses propres exigences de donnees (annexe XVII, D(2)).`

## 3. Effets
- Aucun sur σ_USP, les p-values ni les verdicts : `phrase_res2` ne sert qu'à composer `motif`, dans la branche de refus (`ok = FALSE`) ; prédicat inchangé (`bord`, `bord_ensemble`, `refus`, l. 1971-1975).
- Chaîne absente des six références (`readRDS` puis `rapply` sur les chaînes, `LC_ALL=C.UTF-8`) : 0 occurrence de « reste ouverte » et de « Maximum de vraisemblance non » ; ni régénération ni patch.

## 4. Amendement du périmètre
- Moteur : `R/engine.R` l. 1986, 2006, 2024 ; commentaire l. 1959-1960.
- Tests : `tests/unitaires/test_controles_entree.R` l. 868, 873, 4792 **et 4799** (non citée par `regulatory`).
- `.tex` (`docwriter`, étape 7) : **l. 4398** (« le rappel que la méthode n° 2 reste ouverte », non citée par `regulatory`) ; l. 4444 (« prévoyant aussi ») ; puce de `sec:mw` (l. ~14664).
- Spécification : `docs/specifications/fc-validation-ajustement.md` l. 113 (annotation déjà prévue par m1, étape 1 (ii)).

## 5. À trancher par le mainteneur
1. Suppression (recommandée par `regulatory` et `actuary`) ou phrase de repli.
2. Sort de la spécification l. 113 (déjà décidé par m1 : annotation datée).

Statut : complet. Aucun désaccord avec `regulatory` ni avec un ADR.
