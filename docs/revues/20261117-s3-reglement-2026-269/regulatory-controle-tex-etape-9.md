# Contrôle aval des passages réglementaires du `.tex` : S3, étape 9 (#504)

> *Rédigé par l'agent regulatory (IA), le 17/11/2026.* Branche `claude/reglement-2026-269` à `c8225c0`, arbre propre. Diff contrôlé : `git diff 1feae61..c8225c0 -- docs/latex/doc_tests_usp.tex`. Le commit `addb439` (#598) est hors du champ réglementaire : seule la fiche multi-démarrages change, sans texte réglementaire. Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue. Les numéros de ligne renvoient au `.tex` à `c8225c0`.

## Verdict global

**Le diff est conforme : aucun écart bloquant, aucun écart majeur, six écarts mineurs.**

- Les deux citations sont exactes au caractère près, lues sur l'image :
  - l'art. 117(3) nouveau ;
  - la deuxième phrase de l'art. 148(3) (L 12/94).
- Les pages citées sont toutes exactes.
- L'entrée bibliographique est exacte.
- L'affirmation « 2026/269 ne modifie ni les art. 218 à 220 ni les annexes II, XIV, XVII » est exacte.
- Les décisions du mainteneur sont écrites comme **interprétations**, non comme texte :
  - R1-a ;
  - R2-b + R2-d ;
  - la lecture inclusive de « ce segment précis », avec mention de la lecture restrictive (E-17/11 (ce segment)) ;
  - R-3 laissée ouverte.
- Les six écarts mineurs sont tous dans le périmètre de S3. Ils relèvent d'un passage de `docwriter` (commit `docs:`) et ne touchent ni σ_USP, ni une p-value, ni un verdict.
- **Aucune issue n'est proposée.**

## Sources lues en rendu graphique (pdftoppm, 90 à 110 dpi)

- **`Règlement délégué 2026-269.pdf`** : p. 1 (titre), 25, 26, 29, 30, 37 et 94.
- **`Règlement délégué.pdf`** (JOUE L 12 du 17.1.2015) : L 12/75, 94, 142 et 277.
- **Couche texte de 2026/269** : elle n'a servi qu'à des recherches :
  - liste des points 1) à 148) de l'art. 1er ;
  - recherche de « transitoire » et des dates 2027-2032.

Les rendus sont dans `/tmp/claude-0/-home-user-outil-usp/7785da0b-f095-5cab-9c27-b986f3ac865f/scratchpad/reg9/`.

## Matrice

| # | Passage du `.tex` (lignes) | Texte (lu sur l'image) | Verdict |
|---|---|---|---|
| 1 | l. 2302-2306 : art. 117 et 148 de 2026/269 lus au JO ; « cet acte ne modifie ni les articles 218 à 220, ni les annexes II, XIV et XVII » | Liste continue de l'art. 1er : le point 76) vise les art. 216 et 217, le point 77) l'art. 231. Les points 131) à 148) visent les annexes III, V, VI, VII, VIII, VIII bis, IX, X, XIII, XVI, XIX à XXVI (couche texte). Cela confirme R-5 de la lecture amont | **conforme** |
| 2 | l. 2318-2328 : borne inférieure, « celui applicable à la date de référence » ; « il n'a pas de borne supérieure » | Art. 2 de 2019/981 (contrôle de l'étape 6, ligne 6) ; É-3 de l'étape 6 corrigé (« applicable » remplace « en vigueur ») | **conforme** |
| 3 | l. 2381-2382 : « 2026/269 ne change pas ces valeurs ; il en change la condition d'emploi (paragraphe suivant) » | 117(3) nouveau, p. 25 : 80 % et 100 % inchangés, condition « s'il existe » ajoutée | **conforme** sur le fond ; renvoi imprécis (**m6**) |
| 4 | l. 2390-2416 : date de référence ; « 2019/981 » du 1.1.2020 au 29.1.2027, art. 117 et 148 dans leur version d'origine ; « 2026/269 » à partir du 30.1.2027, art. 2 (p. 94), « sans disposition transitoire » | Art. 2, p. 94 : « Il est applicable à partir du 30 janvier 2027 » ; fait le 29 octobre 2025 | Date, page et date de l'acte **conformes** ; « sans disposition transitoire » trop général (**m1**) |
| 5 | l. 2412-2416 : R1-a | Le texte est muet sur la date qui fixe le texte applicable | **conforme** : écrit « *Interprétation*, et non texte », lecture écartée mentionnée |
| 6 | l. 2420-2425 : citation de 117(3) nouveau, point 29) b), p. 25 ; 80 % pour 1, 4, 5 et 100 % pour les autres | p. 25 : « s'il existe une telle réassurance non proportionnelle pour ce segment précis, ou par un facteur de 100 % dans les autres cas » | **conforme**, citation exacte au caractère près |
| 7 | l. 2425-2429 : seule la première phrase de 148(3) est remplacée (point 39) b), p. 29) ; citation de la deuxième phrase (JO L 12, p. 94) | p. 29 : « au paragraphe 3, la première phrase est remplacée » ; L 12/94 : « Pour tous les segments visés à l'annexe XIV, le facteur d'ajustement par défaut pour la réassurance non proportionnelle est égal à 100 % » | **conforme**, citation exacte |
| 8 | l. 2429-2439 : facteur appliqué selon la déclaration ; exigée là où le facteur diffère de 100 % ; sans effet ailleurs et sous « 2019/981 » | 117(3) nouveau ; 117(3) d'origine (L 12/75) ; D-S3-6, Q-S3-3, Q-S3-4 | **conforme** |
| 9 | l. 2440-2455 : R2-b, R2-d et lecture inclusive de « ce segment précis » ; sens de l'erreur (1 − c) × 0,2 × σ brut | 117(3) silencieux sur la date, la reconnaissance et la couverture multi-segments (vérifié p. 25) | **conforme** : « *Interprétation*, et non texte », lectures écartées dites, lecture restrictive mentionnée « sans que le texte la tranche » ; arithmétique exacte |
| 10 | l. 2456-2459 : 117(2)(b), (4), (5), points 29) a) et c), p. 25-26 ; art. 148, point 39), p. 29-30 | p. 25 (29) a) à c)), p. 26 (fin de 117(4), 117(5)) ; p. 29 (39) a) à c), 148(4)), p. 30 (148(5)) | **conforme** (pages exactes) |
| 11 | l. 2459-2467 : facteur = Adjust(NP,s) pour une CDD qualifiante (deuxième alinéa), 100 % pour toute autre réassurance NP (quatrième alinéa) ; « Sans couverture qualifiante, … sous toutes les lectures » | 117(4), 1er alinéa : « … ou par un facteur de 100 % dans les autres cas » ; 2e alinéa ; 4e alinéa : « Pour la réassurance non proportionnelle autre que celle visée au deuxième alinéa, le facteur d'ajustement est de 100 % » | **conforme** sur la conclusion ; l'énumération omet le cas « aucune réassurance NP » du premier alinéa (**m4**) |
| 12 | l. 2460-2465 : paraphrase des conditions du troisième alinéa | p. 26 et p. 29 : a) « chaque couverture n'est appliquée qu'à un groupe précis de polices, présentant les mêmes caractéristiques de risque et appartenant au même segment, et comporte un point d'attachement et de détachement séparés et distincts » ; b) « ne dépasse pas le produit de l'estimation V(net,res,s) … par la somme de 1 et de σ(res,s,annex) ». V(net,res,s) : « meilleure estimation nominale des engagements … pour le segment, après déduction des montants recouvrables … de la couverture pour développements défavorables » | **conforme** : 1 + σ et non 1 + 3σ ; « nette de cette couverture » suit la lettre et n'ajoute rien sur les autres réassurances |
| 13 | l. 2468-2473 : R-3, deux lectures ; facteur non plafonné à 1 | Adjust = max(0 ; [V·3·σ_annex − ADC·C·Pr + Par] / [V·3·σ_annex]), sans plafond supérieur (image, p. 25 et 29) | **conforme** sur le fond. Les guillemets « à remplacer » ne figurent pas dans D(4) (**m2**). La chaîne de renvoi est écrite pour l'annexe II seulement (**m3**) |
| 14 | l. 2473-2480 : refus en présence d'une CDD qualifiante ; « L'outil ne calcule pas Adjust et ne vérifie aucune des conditions » | D-S3-4, D-S3-7 | **conforme** : présenté comme choix de domaine, non comme texte |
| 15 | l. 2600-2603 : domaine de l'outil | idem | **conforme** |
| 16 | l. 2620-2665 : paramètre remplacé ; interprétation valable sous les deux textes ; constat chiffré (+0,0082 ; +0,00304 ; +0,01148) | B(4) affine en σ standard ; Δ = (1 − c) × 0,2 × σ brut (vérifié à l'étape 6, ligne 11) ; D-S3-8 | **conforme** |
| 17 | l. 2665-2668 : réserve, facteur 100 % sous « 2026/269 », CDD qualifiante hors du domaine | 117(4) et 148(4), 1er et 4e alinéas | **conforme** |
| 18 | l. 2683-2690 : conformité d'un σ saisi jugée selon le texte applicable (0,10 non conforme au 31.12.2026, conforme au 30.1.2027) | 117(3) d'origine et nouveau | **conforme** |
| 19 | l. 2719-2723 : anomalie « quatrième alinéa » de 148(4), p. 29 | p. 29 : « qui remplit les conditions énoncées au quatrième alinéa » ; les conditions a) et b) sont au troisième alinéa, et le quatrième fixe 100 % | Constat et page **conformes** ; justification « sans effet sur l'outil » incomplète (**m5**) |
| 20 | l. 2943-2946 : cas de référence au 31.12.2026, texte « 2019/981 » | Q-S3-7 | **conforme** |
| 21 | l. 20885-20896 : entrée bibliographique de 2026/269 | p. 1 : titre identique au caractère près ; JO série L, 2026/269 du 18.2.2026 ; Commission du 29 octobre 2025. Portée : points 29) et 39), art. 2 | **conforme** |
| 22 | Tableaux des contrôles, lignes « Date de référence et déclarations » (lognormal et Merz-Wüthrich) | D-S3-5, D-S3-6, D-S3-9 | **conforme** |
| 23 | `\versiondoc` 4.0 | Q-65-4 (E-B) | **conforme** |

## Écarts

**Bloquants : aucun. Majeurs : aucun.**

**Mineurs** (tous dans le périmètre de S3 ; correction par `docwriter`, sans effet sur σ_USP, une p-value ou un verdict) :

- **m1, l. 2407, « sans disposition transitoire ».**
  - **Constat.** Lue seule, la mention vaut pour tout l'acte, qui contient pourtant des régimes calés sur la date de transition pour d'autres matières.
  - **Preuve.** Art. 1er, point 47) (art. 170 modifié, p. 37, lue sur l'image) : régime propre aux entreprises autorisées « avant le 29 janvier 2027 ». Autres passages, localisés par la couche texte et non relus sur l'image : progression 2027 → 2032 (p. 16) ; considérant sur une reconnaissance « à titre transitoire » de fonds propres (p. 10).
  - **Correction proposée.** « sans disposition transitoire pour les articles 117, 148 et 218 à 220 ».
- **m2, l. 2468-2469, « le paramètre standard «~à remplacer~» de C(4) et D(4) ».**
  - **Constat.** Les guillemets attribuent ces mots aux deux paragraphes. Or D(4)(d) (L 12/277, image) dit « le paramètre standard pour le risque de réserve … du segment s ». Le mot « à remplacer » ne figure qu'en C(4)(e), où il vise σ(prem,s) : c'est l'anomalie déjà relevée l. 2709-2713.
  - **Correction proposée.** Retirer les guillemets ou citer exactement chaque paragraphe.
- **m3, l. 2469-2471, chaîne de lecture de R-3.**
  - **Constat.** Elle n'est écrite que pour l'annexe II (218(1)(a)(iv) → 117(2)(b)). Pour l'annexe XIV, la chaîne est 218(1)(c)(iv) → 148(2)(**a**) (L 12/142, image), anomalie lue comme le point b) (l. 2715-2716), puis 148(2)(b) nouveau → 148(4)-(5).
  - **Correction proposée.** Ajouter « et, pour l'annexe XIV, de l'article 218, paragraphe 1, point c) iv), à l'article 148, paragraphe 2, lu comme le point b) ».
- **m4, l. 2459-2467, énumération incomplète du facteur de réserve.**
  - **Constat.** Le premier alinéa de 117(4) et de 148(4) donne aussi 100 % en l'absence de toute réassurance NP (« dans les autres cas »). C'est sur ce cas que repose en partie le « donc » de « Sans couverture qualifiante, … sous toutes les lectures ». La conclusion reste exacte.
  - **Correction proposée.** Ajouter « et en l'absence de réassurance non proportionnelle (premier alinéa) ».
- **m5, l. 2721-2723, motif « sans effet sur l'outil, qui ne calcule pas le facteur d'ajustement ».**
  - **Constat.** Le motif est incomplet. Sous l'annexe XIV, la lecture de ce renvoi définit aussi ce que l'utilisateur déclare comme couverture qualifiante (`cdd_qualifiante`, refus si `TRUE`). Lu à la lettre, le quatrième alinéa ne pose aucune condition, et toute CDD serait qualifiante.
  - **Correction proposée.** « … sans effet sur l'outil, dont la couverture qualifiante déclarée est définie par le troisième alinéa (paragraphe « Texte «~2026/269~», risque de réserve ») et qui ne calcule pas le facteur ».
- **m6, l. 2382, « (paragraphe suivant) ».**
  - **Constat.** Le paragraphe suivant est « Date de référence du calcul et texte applicable ». La condition d'emploi est énoncée au paragraphe « Texte «~2026/269~», risque de primes » (l. 2420).
  - **Correction proposée.** Renvoyer à ce paragraphe nommément.

## Interprétations

Aucune nouvelle. R1-a, R2-b + R2-d, la lecture inclusive de « ce segment précis » et R-3 ouverte avec refus sont écrites comme interprétations, conformément à D-S3-2 à D-S3-4 et à E-17/11 (ce segment).

## Constats hors périmètre (ADR 0018)

Aucun. Les six mineurs sont dans le périmètre de S3 (#504). Aucun ne relève d'un critère de l'ADR 0018 : ce ne sont pas des affirmations fausses sur le code, et aucun n'a d'effet sur σ_USP, une p-value ou un verdict.

## Issue proposée

**Aucune.** Les six mineurs se corrigent sur la branche par un commit `docs:` de `docwriter`, puis un contrôle de son diff.

## Critères d'escalade (signalés, sans décision)

Aucun : pas de désaccord avec `actuary` ni avec les décisions du mainteneur, pas de changement de σ_USP.
