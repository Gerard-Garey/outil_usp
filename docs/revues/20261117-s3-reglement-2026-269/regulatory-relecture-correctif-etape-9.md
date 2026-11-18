# Relecture du diff correctif de l'étape 9 de S3 (#504), règle 10

> *Rédigé par l'agent regulatory (IA), le 17/11/2026.*

**Périmètre.** Branche `claude/reglement-2026-269`, HEAD `989e87a`. Diff relu : `git diff 16d2433..989e87a`, sur `docs/latex/doc_tests_usp.tex` et `docs/suivi-documentation/` (`I.md`, `III-H.md`, `annexe.md`). Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue. Les numéros de ligne renvoient au `.tex` à `989e87a`.

**Pages relues en rendu graphique** (rendus de l'étape 9, dans `/tmp/claude-0/-home-user-outil-usp/7785da0b-f095-5cab-9c27-b986f3ac865f/scratchpad/reg9/`) :
- 2026/269, p. 29 ;
- JO L 12, p. 142.

Les autres pages citées (2026/269, p. 25, 26, 37 et 94 ; L 12/277) avaient été lues à l'image à l'étape 9. Leur contenu cité par le correctif est identique à ce relevé.

## Verdict

**Conforme. Les six écarts m1 à m6 sont correctement repris. Le diff n'introduit aucun nouvel écart réglementaire. Je ne propose aucune issue.**

## Écart par écart

| Écart | Reprise (`.tex` à 989e87a) | Contrôle | Verdict |
|---|---|---|---|
| m1 | l. 2407-2408 : « sans disposition transitoire pour les articles 117, 148 et 218 à 220 » | La restriction répond au constat (régime de l'art. 170 modifié, point 47), p. 37). Elle n'affirme rien sur les autres matières de l'acte. | conforme |
| m2 | l. 2469 : guillemets retirés, « paramètre standard à remplacer de C(4) et D(4) » | Le passage n'attribue plus de citation à D(4). En paraphrase, la formule est exacte : D(4)(d) vise le paramètre standard que σ_USP remplace (L 12/277). | conforme |
| m3 | l. 2470-2472 : « …de l'article 218, paragraphe 1, point c) iv), à l'article 148, paragraphe 2, lu comme le point b), redéfini de même » | L 12/142 (image) : 218(1)(c)(iv) renvoie bien à « l'article 148, paragraphe 2, point a) ». 2026/269, p. 29 (image) : le point 39) a) remplace 148(2)(b) par « σ(res,s) … tel que visé aux paragraphes 4 et 5 ». La chaîne est exacte et cohérente avec l'anomalie de l'encadré (l. 2721-2723). | conforme |
| m4 | l. 2466-2468 : « …100 % pour toute autre réassurance non proportionnelle (quatrième alinéa) et en l'absence de réassurance non proportionnelle (premier alinéa) » | p. 29 (image), 148(4) : le premier alinéa donne « un facteur de 100 % dans les autres cas » ; le quatrième alinéa porte sur « la réassurance non proportionnelle autre que celle visée au deuxième alinéa ». Il en va de même au 117(4), p. 25. L'énumération est complète, et le « donc » qui suit est fondé. | conforme |
| m5 | l. 2730-2732 : « …sans effet sur l'outil, dont la couverture qualifiante déclarée est définie par le troisième alinéa (paragraphe « Texte « 2026/269 », risque de réserve », ci-dessus) et qui ne calcule pas le facteur… » | p. 29 (image) : le deuxième alinéa renvoie bien au « quatrième alinéa », et les conditions a) et b) figurent au troisième. Le motif est désormais complet, et le paragraphe cité définit bien la couverture qualifiante par ces conditions (l. 2460-2465). | conforme |
| m6 | l. 2382 : « (paragraphe « Texte « 2026/269 », risque de primes », ci-dessous) » | Le paragraphe nommé existe sous ce titre (l. 2421), et c'est lui qui énonce la condition d'emploi de 117(3) nouveau. | conforme |

## Autres modifications du diff

Les autres modifications viennent des mineurs d'`actuary` et de `d4c8b9f`. Je les ai relues sous l'angle réglementaire seul :

- **l. 2416-2417** (actuary m1), « son terme standard est le paramètre que σ_USP remplace dans ce même calcul » : formulation conforme à l'art. 218(1) et à la règle de mélange de B(4), C(4) et D(4). Le passage reste qualifié d'*interprétation*. **Conforme.**
- **l. 2450-2453** (actuary M1), effet d'une déclaration erronée avec un σ standard saisi : la « valeur réglementaire à laquelle la saisie est comparée » vaut 0,8·σ brut ou σ brut selon la déclaration. C'est conforme à 117(3) nouveau, p. 25, aux segments 1, 4 et 5. Le fond relève du code et d'`actuary`. **Aucun écart réglementaire.**
- **l. 2655-2656** (actuary m2), « calculé avec le σ standard de la table », « valeurs observées » : la qualification rend le constat chiffré exact. Les valeurs +0,0082, +0,00304 et +0,01148 sont inchangées et avaient été vérifiées à l'étape 9. **Conforme.**
- **l. 14159** (« paramètre standard retenu ») et **l. 22433-22441** (portée d'une anomalie des fonctions du paramètre standard) : passages de nature technique, sans citation ni renvoi au règlement. **Hors champ réglementaire.**
- **`d4c8b9f`**, fiche multi-démarrages (« sont à l'optimum ») : **hors champ réglementaire.**
- **`docs/suivi-documentation/I.md`** : la trace de reprise cite exactement les textes retirés et les sources de m1 à m6 (pages 25, 26, 29, 37, L 12/142 et L 12/277). **Conforme.**

## Constats

- **Bloquants : aucun. Majeurs : aucun. Mineurs : aucun.**
- **Interprétations nouvelles : aucune.** R1-a, R2-b + R2-d, la lecture inclusive de « ce segment précis » et R-3 (laissée ouverte, le calcul est refusé en présence d'une couverture qualifiante) restent écrites comme interprétations.
- **Hors périmètre (ADR 0018) : aucun constat.**
- **Issue proposée : aucune.**
- **Critères d'escalade : aucun.** Pas de désaccord avec `actuary` ni avec le mainteneur, et aucun changement de σ_USP.
