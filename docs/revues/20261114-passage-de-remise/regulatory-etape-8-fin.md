**Verdict : conforme. `79a2865` et `3a3bacf` reprennent R2, R3 et D sans écart au texte du règlement délégué (UE) 2026/269. Aucun constat bloquant ni majeur. Restent deux constats mineurs de forme (C1, C2) et une précision facultative (P1). R1 n'est pas encore exécutée : ce n'est pas à `docwriter` de la faire, elle va dans la pièce de remise.**

# Contrôle aval de `regulatory`, KR étape 8, reprise de R2, R3 et D (`79a2865`, `3a3bacf`)

> *Rapport de l'agent `regulatory` (IA), rendu à la session principale le 14/11/2026. Arbre lu : `claude/passage-de-remise`, tête `a0fe3e2`. Lecture seule : je n'ai rien écrit dans le dépôt ni sur GitHub.* Versé tel quel par la session principale (Q-54-10).

## Textes lus

**Règlement délégué (UE) 2026/269, version française, vérifiée en ligne.**
- Source : `http://publications.europa.eu/resource/celex/32026R0269`, xhtml de l'Office des publications, en-tête du convertisseur `generated_on:20260218-0530`, ELI `http://data.europa.eu/eli/reg_del/2026/269/oj`.
- Passages lus : l'en-tête, le titre, l'art. 1er, points 29) et 39), l'art. 2 et la formule de signature.
- J'ai aussi cherché si l'acte modifie les art. 116, 147, 218, 219 et 220 ou les annexes II, XIV et XVII du règlement 2015/35. Il ne les modifie pas : aucune phrase « L'article 218 est… » ni « L'annexe II/XIV est… ». L'annexe XVII de l'acte modificatif modifie l'annexe XXV du 2015/35, pas l'annexe XVII.

**Version consolidée du 14.11.2024** (xhtml à la racine) : art. 117, paragraphes 2 et 3 ; art. 148, paragraphes 2 et 3 ; art. 218, paragraphe 1.

**Code** : `R/engine.R` l. 98 et 123. La colonne `np_standard` vaut 1 pour les quatre segments de l'annexe XIV.

**Contrôle** : `LC_ALL=C.UTF-8 Rscript tests/controle_doc_nd.R` sur la tête. Liste A : 0 occurrence, A10 compris.

## 1. Vérifications factuelles (`79a2865`, `sec:segments`, l. 2194-2204 à la tête)

| Énoncé du `.tex` | Source (CELEX 32026R0269, FR) | Verdict |
|---|---|---|
| « règlement délégué (UE) 2026/269 de la Commission du 29 octobre 2025 » | titre : « RÈGLEMENT DÉLÉGUÉ (UE) 2026/269 DE LA COMMISSION du 29 octobre 2025 » ; « Fait à Bruxelles, le 29 octobre 2025. » | exact |
| « série L, 2026/269 du 18.2.2026 » (R2) | en-tête : « Journal officiel de l'Union européenne — FR — Série L — 2026/269 — 18.2.2026 » | exact |
| « antérieure au 30.1.2027, date d'application de cet acte fixée par son article 2 » (D) | art. 2, « Entrée en vigueur et application » : « Il est applicable à partir du 30 janvier 2027. » | exact. L'art. 2 fixe une date unique, sans application différée par point. L'entrée en vigueur, au vingtième jour après la publication, est distincte ; le `.tex` ne la cite pas, à juste titre. |
| point 29) b) remplace l'art. 117(3) ; citation « s'il existe une telle réassurance non proportionnelle pour ce segment précis, ou par un facteur de 100 % dans les autres cas » | « b) le paragraphe 3 est remplacé par le texte suivant » ; citation identique au mot près dans la première phrase du nouveau § 3 | exact |
| point 29) a) et c) : σ(res,s) de l'art. 117(2)(b) redéfini par de nouveaux § 4 et 5 | a) « … tel que visé aux paragraphes 4 et 5 » ; c) « les paragraphes 4 et 5 suivants sont ajoutés » | exact |
| « modifie de même l'article 148 (point 39)), avec effet sur le seul risque de réserve, le facteur d'ajustement des segments de l'annexe XIV restant de 100 % pour le risque de primes » (R3) | voir § 2 ci-dessous | exact (voir P1) |

## 2. Portée du point 39) sur l'art. 148 : « avec effet sur le seul risque de réserve »

**Ce que fait le point 39) :**
- **a)** Il remplace l'art. 148(2)(b) : σ(res,s) « tel que visé aux paragraphes 4 et 5 ». C'est le risque de réserve.
- **b)** « au paragraphe 3, **la première phrase** est remplacée par le texte suivant : "Pour tous les segments visés à l'annexe XIV, l'écart type du risque de primes en santé non-SLT d'un segment donné est égal au produit de l'écart type du risque de primes brut en santé non-SLT indiqué à l'annexe XIV pour ce segment par le facteur d'ajustement pour la réassurance non proportionnelle, s'il existe une telle réassurance non proportionnelle pour ce segment précis, ou par un facteur de 100 % dans les autres cas." » C'est le risque de primes, réécrit dans sa forme.
- **c)** Il ajoute les § 4 et 5 : risque de réserve brut × facteur NP s'il existe une réassurance NP, sinon 100 %. Le facteur est calculé (Adjust(NP,s), ADC(rec,s)) pour une couverture pour développements défavorables qui remplit les conditions. Il vaut 100 % pour toute autre réassurance NP. C'est le risque de réserve.

**La seconde phrase de l'art. 148(3) reste en vigueur.** Version consolidée : « Pour tous les segments visés à l'annexe XIV, le facteur d'ajustement par défaut pour la réassurance non proportionnelle est égal à 100 %. »
- Après l'acte, l'écart-type du risque de primes santé non-SLT vaut donc σ brut × 100 % dans les deux branches de la nouvelle première phrase.
- Avant l'acte, il valait déjà σ brut × 100 %.

**Conclusion.** Le point 39) b) **touche formellement** le texte du risque de primes, mais **ne change pas le paramètre standard** du risque de primes de l'annexe XIV. Il ne change pas non plus le domaine de l'art. 218(1)(c)(iii), que l'acte ne modifie pas et qui exige déjà un contrat en excédent de sinistres ou de pertes reconnaissable.
- La seule modification de fond de l'art. 148 porte sur σ(res,s), et seulement en présence d'une couverture pour développements défavorables. Sans réassurance NP, ou avec une autre réassurance NP, le facteur vaut 100 % et σ(res,s) reste celui de l'annexe XIV.
- « **avec effet** sur le seul risque de réserve » est donc **exact**. Le mot « effet » est juste : une formule comme « ne modifie que le risque de réserve » aurait été inexacte, puisque le point b) réécrit une phrase sur les primes.
- « Avec effet » n'est pas trop étroit, et c'est plus juste que le texte que j'avais proposé (« pour le seul risque de réserve »).
- « de même » se lit correctement : comme pour l'art. 117, l'art. 148 voit son σ(res,s) redéfini par de nouveaux § 4 et 5.
- La phrase est cohérente avec le code (`ANNEXE_XIV$np_standard = c(1, 1, 1, 1)`).

**Question posée : le facteur NP de l'art. 117(3) touche-t-il aussi le risque de primes ?**
- **Oui, et seulement lui.** L'art. 117(3) ne porte que sur l'écart-type du **risque de primes** en non-vie, consolidé comme modifié. L'art. 117(2)(a) renvoie à ce paragraphe pour σ(prem,s).
- Le risque de réserve non-vie relève des nouveaux § 4 et 5 de l'art. 117 (point 29) a) et c)).
- Le `.tex` les distingue correctement : le § 3 remplacé pour les primes des segments II-1, II-4 et II-5, avec l'écart chiffré au paragraphe « Paramètre remplacé par la méthode du risque de primes », et les § 4 et 5 pour la réserve, dont la lecture en présence d'une couverture pour développements défavorables « n'est pas établie par l'outil ».
- La restriction « avec effet sur le seul risque de réserve » ne s'attache qu'à l'art. 148 dans la phrase. Elle ne peut pas se lire comme portant sur l'art. 117.

**P1, précision facultative, mineure, non requise.** « le facteur d'ajustement des segments de l'annexe XIV » ne nomme pas le facteur par son nom réglementaire. Texte possible, à confier à `docwriter` seulement si le mainteneur le retient :
> « …et modifie de même l'article~148 (point~39)), avec effet sur le seul risque de réserve, le facteur d'ajustement pour la réassurance non proportionnelle restant de $100~\%$ pour le risque de primes de tous les segments de l'annexe~XIV (article~148, paragraphe~3, seconde phrase, maintenue). »

## 3. Constat D (date écrite) : conforme

- La date est écrite en clair (« 30.1.2027 »), avec son fondement (art. 2). Le lecteur de l'ACPR n'a plus de recherche externe à faire : c'était l'objet de D.
- La forme pointée n'est atteinte par aucune regex d'A10, et le contrôle donne 0 occurrence.
- Il y a une asymétrie typographique avec la borne inférieure « 1er janvier 2020 », écrite en toutes lettres. Elle est imposée par A10 et sans portée réglementaire : simple observation, pas de constat.

## 4. `3a3bacf` (CONVENTIONS, E4) : conforme avec réserves

**Conforme sur le fond.** « 30.1.2027 », « 18.2.2026 » et « 2026/269 » sont des dates et un numéro réglementaires. Ce n'est pas de la vie du dépôt. Les trois formes échappent aux motifs de la liste A par construction (vérifié : A10 = 0).

**C1, mineur, de forme : contradiction résiduelle dans CONVENTIONS.**
- La règle en prose « Pas de vie du dépôt » (`docs/latex/CONVENTIONS.md`, l. 113) dit encore, sans réserve : « ni date postérieure au 31 décembre 2025 ».
- E4 admet désormais deux dates postérieures, mais la prose ne renvoie pas à E4. C'est précisément la double lecture que relevait le point D d'`actuary`.
- Texte à confier à `docwriter`, l. 113 : remplacer « ni date postérieure au 31 décembre 2025, » par :
> « ni date postérieure au 31 décembre 2025 (hors dates et numéros réglementaires, exception E4 du § 5), »

**C2, mineur, de forme, en partie antérieur au commit.** E4 se termine par « Cas négatifs du jeu de tests. ».
- Or `tests/unitaires/test_controle_doc_nd.R` (l. 190-191) ne porte que « 17~janvier 2015 », « 17~janvier~2015 », « 14~novembre 2024 », « 14 novembre 2024 », « 25.3.2015 », « règlement 2015/35 » et « EIOPA-BoS-14/178 ».
- « 2019/981 », « 2015/498 » et « EIOPA-BoS-25/249 » y manquaient déjà. Les trois formes ajoutées n'y sont pas non plus : le commit le dit lui-même, au titre du gel.
- Texte à confier à `docwriter`, fin d'E4 : remplacer « Cas négatifs du jeu de tests. » par :
> « Cas négatifs du jeu de tests : « 17~janvier 2015 », « 14~novembre 2024 », « 25.3.2015 », « règlement 2015/35 », « EIOPA-BoS-14/178 » ; les autres formes de la liste n'y figurent pas. »

## 5. R1 : rappel du texte proposé (non exécuté, hors `.tex`)

Je n'ai trouvé la date de référence consignée ni dans `docs/revues/20261114-passage-de-remise/README.md` ni ailleurs. R1 reste ouverte.
- Elle revient à la session principale, ou au mainteneur pour la valeur de la date, dans la pièce de remise : synthèse de `docs/revues/20261114-passage-de-remise/` ou note de remise. Elle ne revient pas à `docwriter`.
- Texte proposé, inchangé sur le fond. Seule la forme de la date est alignée sur le `.tex`, désormais explicite :
> « Date de référence du calcul : [jj/mm/aaaa], antérieure au 30 janvier 2027, date d'application du règlement délégué (UE) 2026/269 (article 2) ; domaine de validité de l'outil : `sec:segments`, paragraphes « Limite de périmètre » et « Borne supérieure du domaine ». »
- La variante facultative de R1 (écrire la date dans le `.tex`) est absorbée par D et faite dans `79a2865`.
- Le contrôle reste incomplet tant que la date de référence elle-même n'est pas consignée dans le dossier : le moteur n'a aucun champ qui la porte.

## Synthèse

| Point | Commit | Verdict | Gravité | Correction |
|---|---|---|---|---|
| R2, date de publication | `79a2865` | conforme | — | aucune |
| R3, portée du point 39) sur l'art. 148 | `79a2865` | conforme ; « avec effet sur le seul risque de réserve » exact, plus juste que mon texte | — (P1 facultative, mineure) | P1 si retenue |
| D, date d'application écrite | `79a2865` | conforme | — | aucune |
| Dates, numéro, art. 2 | `79a2865` | conforme : 2026/269, 29.10.2025, JO série L du 18.2.2026, application au 30.1.2027, vérifiés au texte primaire | — | aucune |
| E4 de CONVENTIONS | `3a3bacf` | conforme avec réserves | mineur (C1, C2) | textes de C1 et C2 ci-dessus, à `docwriter` |
| R1, date de référence dans la pièce de remise | — | non exécutée | mineur | session ou mainteneur, texte du § 5 |

- Aucun chiffre, aucune p-value, aucun verdict ni σ_USP n'est touché.
- Aucune issue nouvelle à proposer : tout relève de #504 et de la branche KR.

Sources :
- [Règlement délégué (UE) 2026/269, version française (Office des publications, CELEX 32026R0269)](http://publications.europa.eu/resource/celex/32026R0269)
- [Règlement délégué (UE) 2026/269, ELI](http://data.europa.eu/eli/reg_del/2026/269/oj)
