# Contrôle aval de `regulatory`, KR étape 8 (14/11/2026)

> *Rapport de l'agent `regulatory` (IA), fiche de base, rendu à la session principale le 14/11/2026 et versé intégralement par elle (Q-54-10). Arbre lu : `claude/passage-de-remise` `e86e27c`.*

## Contrôle aval de `regulatory`, KR étape 8 : passages réglementaires réécrits par `docwriter` dans `docs/latex/doc_tests_usp.tex`

Branche `claude/passage-de-remise`, tête `e86e27c`. Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue.

**Verdict global : aucun constat bloquant ni majeur.**
- Passages 1, 2 et 3 : conformes.
- Passage 4 : conforme avec réserves, trois constats mineurs.

**Textes lus**
- Version consolidée du 14.11.2024 : art. 117, 218, 219 et 220 ; annexe XVII, A(1) et D(1) à D(4). Les formules D(4)(c), Ĉ(i,j) et f̂_j, ont été lues à l'image, extraite du xhtml.
- Règlement délégué (UE) 2026/269 : version française (xhtml) de l'Office des publications (`publications.europa.eu/resource/celex/32026R0269`). C'est le JO série L 2026/269 du 18.2.2026 ; le fichier a été généré le 18/02/2026. J'ai lu le titre, l'art. 1er, points 29) et 39), et l'art. 2.
- Code : `R/engine.R`, l. 1963-2029 et 7740-8000.

---

### 1. #573, `06d6717` : conforme

**(a) Motif d'`usp_valider_ajustement()` (l. 4385-4410) : conforme.**
- Le rappel de la méthode n° 2 est retiré aux deux endroits : forme 1 (« … article 219, paragraphe 1, point d)) et une vérification à faire ») et forme 2 (« le fondement étant celui de la forme 1 »).
- C'est conforme au code : l. 2012-2027, aucune phrase sur la n° 2.
- C'est conforme à mon contrôle aval de `c5a1953`, avec les renvois exacts : art. 220(1)(a)/(b) ; B(2)(g) ou C(2)(e), iii et iv ; art. 219(1)(d) ; B(1)(a)/C(1)(a), B(1) et B(2)(a).
- Il ne reste aucune occurrence de « reste ouverte » ni de « ouvrant aussi » dans le `.tex`.

**(b) « prévoyant aussi » (l. 4478) : conforme.** Art. 220(1)(b), consolidé (JOUE p. 144) : « la méthode du risque de réserve n° 1 ou la méthode du risque de réserve n° 2 ». La formule est alignée sur les l. 4018, 5147 et 14748.

**(c) Puce de `sec:mw` (l. 14745-14752) : conforme.**
- **Citation « pouvant être remplacés » : exacte.** Elle figure deux fois à l'art. 218, consolidé, JOUE p. 142 :
  - dans l'intitulé, « Sous-ensemble de paramètres standard pouvant être remplacés par des paramètres propres à l'entreprise » ;
  - au paragraphe 1, « Le sous-ensemble de paramètres standard pouvant être remplacés […] comprend les paramètres suivants ».
- **« énumère » : juste.** Le paragraphe 1 énumère les points a) à d).
- **« à défaut de paramètre propre, σ(res,s) s'applique » : exact.** Le paramètre standard de l'art. 117(2)(b) et de l'art. 148(2)(b) reste celui de l'annexe.
- **Les renvois à l'art. 220(1)(b) et (2) sont exacts.** Les « propres exigences de données » de la n° 1 sont C(1), C(2) et l'art. 219(1)(d).
- **« condition que l'outil retient pour son admissibilité » :** c'est la qualification que demandait le lot 1, § 7 (critère de l'outil, non du texte). L'écart avec mon texte du lot 3, § 3 (« condition de son admissibilité ») est voulu et conforme.
- **« Un troisième appui » (l. 14769) :** il est cohérent avec la l. 14733-14734 (« fondée sur deux appuis et confortée par une orientation ») et avec la liste, qui a deux appuis et une orientation. L'art. 116(6) est bien le troisième appui.
- **Observation, sans constat :** la faculté vient de l'art. 104(7) de la directive 2009/138/CE, auquel renvoie l'art. 218(1) (« comme énoncé à l'article 104, paragraphe 7, de la directive »). Le renvoi est facultatif et je ne propose pas de correction.

### 2. #559, `ea9449e` (l. 3951-3957) : conforme

**Le texte est repris mot pour mot du lot 3, § 2.** J'ai vérifié chaque appui dans le texte :
- **D(1)** : « indiqués séparément pour chaque année d'accident et chaque année de développement des paiements ». La paraphrase hors guillemets est fidèle.
- **A(1)(b)** : « la différence entre l'année de ce paiement et l'année de l'accident auquel il correspond ». C'est exact.
- **D(4)(c), à l'image** :
  - Ĉ(i,j) = C(i,I−i) · f̂_(I−i) ⋯ f̂_(j−2) · f̂_(j−1) ;
  - f̂_j = Σ_(i=0)^(I−j−1) C(i,j+1) / Σ_(i=0)^(I−j−1) C(i,j).
  - « enchaîne les facteurs f̂_(I−i), …, f̂_(j−1), dont chacun relie une année de développement à la suivante » est donc exact. f̂_j est défini au même point c).

**Colonne à en-tête en bord, motif distinct : conforme au code.**
- `.retirer_lignes_colonnes_vides()`, l. 7982-7997 :
  - `inter` → « annee de developpement manquante presumee » ;
  - `ent_bord` → « annee de developpement sans valeur ».
- « Sans ancrage dans le texte » est juste.
- D(2)(c) ne reste qu'au contrôle de profondeur (l. 4917) et dans la phrase « D(2)(c) n'est pas en cause » (l. 3972), qui est exacte.

**Constat mineur, hors `.tex` (code gelé).** Le commentaire d'en-tête de `R/engine.R`, l. 7753-7755, dit encore : « une colonne entierement vide intercalee, ou portant un en-tete, est refusee comme annee de developpement manquante presumee ». Il contredit les l. 7988-7997 et le `.tex`. Je propose de l'ajouter à l'issue E-4 du lot 3, § 4 (commentaires seulement, sans effet sur un résultat), dont le corps pourrait recevoir ce point :
> - `R/engine.R` l. 7753-7755 (en-tête de `.retirer_lignes_colonnes_vides()`) : « ou portant un en-tete, est refusee comme annee de developpement manquante presumee » ; depuis #559, une colonne à en-tête placée en bord reçoit le motif distinct « annee de developpement sans valeur » (l. 7992-7997). Texte attendu : « une colonne entierement vide intercalee est refusee comme annee de developpement manquante presumee ; une colonne vide portant un en-tete, en bord, comme annee de developpement sans valeur (motif distinct, sans renvoi reglementaire) ».

### 3. Limites #574 et #575, `dcd43e2` et `e8a60d4` : conformes

- Aucun renvoi réglementaire, et aucun n'est requis : ce sont des limites de lecture du fichier (indice de chaîne partagée hors bornes sous openxlsx, valeur fausse `<x:si>`), pas des exigences du texte.
- Le contrôle compensatoire (relecture des données lues, empreinte md5 dans le rapport figé) laisse à l'entreprise l'exactitude des données. C'est cohérent avec l'art. 219(1)(a), qui renvoie à l'art. 19, sans que le paragraphe ait à le citer.
- Le README (`e86e27c`) n'apporte aucun renvoi réglementaire non plus.

### 4. Borne E-L1-1, `7fceed2` (`sec:segments`, l. 2191-2208 ; l. 2407) : conforme avec réserves

**Citations vérifiées à la source (CELEX 32026R0269, version française) :**

| Énoncé du `.tex` | Source | Verdict |
|---|---|---|
| « règlement délégué (UE) 2026/269 de la Commission du 29 octobre 2025 », JO série L, 2026/269 | titre ; « Fait à Bruxelles, le 29 octobre 2025 » ; JO série L 2026/269 du 18.2.2026 | exact |
| art. 1er, point 29) b), remplace l'art. 117(3) | « b) le paragraphe 3 est remplacé par le texte suivant » | exact |
| citation « s'il existe une telle réassurance non proportionnelle pour ce segment précis, ou par un facteur de 100 % dans les autres cas » | nouveau § 3, première phrase | exacte, au mot près |
| point 29) a) et c) : σ(res,s) de l'art. 117(2)(b) redéfini par de nouveaux § 4 et 5 | a) « b) σ(res,s) représente […] tel que visé aux paragraphes 4 et 5 » ; c) « les paragraphes 4 et 5 suivants sont ajoutés » | exact |
| point 39) modifie l'art. 148 | « 39) L'article 148 est modifié comme suit » | exact (voir R3) |
| date d'application « fixée par son article 2 » | art. 2 : « Il est applicable à partir du 30 janvier 2027. » | exact : une seule date pour tout l'acte, sans application différée par point |

**Sens de l'écart : exact.**
- Au-delà de la date d'application, sur données nettes des segments II-1, II-4 et II-5 sans réassurance non proportionnelle, le paramètre standard de l'art. 218(1)(a)(i) devient σ brut × 100 %.
- Le paramètre propre de l'outil est donc inférieur à celui du texte modifié, du côté non prudent.
- Le renvoi au paragraphe « Paramètre remplacé… » (l. 2411-2414) chiffre le même écart. Sur des données identiques déclarées brutes puis nettes, la différence n'est que le terme standard, −(1−c)(1−NP)σ_brut = −0,0082 : σ_USP de 0,1032524 au lieu de 0,1114524.
- Le cas d'une réassurance non proportionnelle existante, où les 80 % demeurent, est correctement exclu.

**Conformité au lot 1, § 8 et § 9 : conforme.**
- Les deux configurations du § 8 sont couvertes :
  - primes nettes des segments 1, 4 et 5 ;
  - réserves avec couverture pour développements défavorables. « la lecture du texte modifié […] n'est pas établie par l'outil » ne tranche pas entre les lectures A et B : c'est juste, puisque l'interprétation reste à trancher.
- La borne figure dans le seul `.tex`, comme le proposait le § 9.
- Le paragraphe « Paramètre remplacé… » est restreint au même domaine (l. 2407).
- Le commentaire du code (l. 57-61), toujours sans borne supérieure, suivra après le gel, comme prévu au § 9 (commentaire sur #504). Ce n'est pas un constat du `.tex`.

**Question posée : le renvoi à « la date d'application fixée par son article 2 » suffit-il ?**
- **Comme désignation de la date, oui.** L'art. 2 fixe une date unique pour tout l'acte (« Il est applicable à partir du 30 janvier 2027 »). Le renvoi désigne donc sans ambiguïté une date que tout lecteur peut vérifier sur l'acte publié. Il distingue aussi justement la date d'application de l'entrée en vigueur (vingtième jour après la publication).
- **Pour qu'un lecteur de l'ACPR puisse contrôler la borne, non : le renvoi ne suffit pas seul.** Le contrôle exige que la date de référence du dossier figure dans le dossier. Or l'outil ne l'enregistre nulle part : `R/engine.R` n'a aucun champ de date de référence, seule la l. 60 du commentaire la mentionne.

**Constats (tous mineurs) :**

- **R1, mineur : date de référence du dossier non consignée.** Il faut l'écrire hors du `.tex`, dans la pièce de remise (synthèse de `docs/revues/20261114-passage-de-remise/` ou note de remise). Texte proposé :
  > « Date de référence du calcul : [jj/mm/aaaa], antérieure au 30 janvier 2027, date d'application du règlement délégué (UE) 2026/269 (article 2) ; domaine de validité de l'outil : `sec:segments`, paragraphes « Limite de périmètre » et « Borne supérieure du domaine ». »

  Variante facultative, à décider par le mainteneur au titre des CONVENTIONS : écrire la date dans le `.tex` au moyen d'une exception nommée au motif A10. Le motif vise la vie du dépôt, pas une date réglementaire. Texte, l. 2201-2202 :
  > « …antérieure à la date d'application de cet acte, le 30~janvier 2027 (article~2). »

  Cette forme serait symétrique de la borne inférieure, dont la date (« 1er janvier 2020 ») est écrite.
- **R2, mineur, de forme : date de publication absente de la référence.** Les autres actes cités portent leur date de publication (2019/981 : « L~161 du 18~juin 2019 »). Texte proposé, l. 2195-2196, si le mainteneur l'admet au regard de la règle « Pas de vie du dépôt » (date bibliographique et non vie du dépôt ; la forme pointée n'est pas atteinte par A10) :
  > « (\emph{Journal officiel de l'Union européenne}, série~L, 2026/269 du 18.2.2026) »
- **R3, mineur, de précision : « modifie de même l'article 148 ».** Le point 39) b) ne remplace que la première phrase de l'art. 148(3). La phrase qui fixe le facteur à 100 % pour tous les segments de l'annexe XIV est maintenue : rien ne change pour les primes en santé non-SLT. « De même » pourrait faire croire le contraire. Texte proposé, l. 2200-2201 :
  > « …et modifie de même l'article~148 (point~39)), pour le seul risque de réserve, le facteur standard de l'annexe~XIV restant de $100~\%$ pour le risque de primes. »

---

### Synthèse

| Passage | Verdict | Constats |
|---|---|---|
| 1. #573 : motif, « prévoyant aussi », puce de `sec:mw` | conforme | aucun ; « pouvant être remplacés » exact (art. 218, intitulé et § 1, JOUE p. 142) |
| 2. #559 : colonne vide intercalée, colonne à en-tête en bord | conforme | mineur hors `.tex` : commentaire `R/engine.R` l. 7753-7755, à ajouter à l'issue E-4 |
| 3. Limites #574 et #575 | conforme | aucun ; aucun renvoi réglementaire requis |
| 4. Borne E-L1-1 | conforme avec réserves | R1 (date de référence à consigner dans la pièce de remise), R2 (date de publication), R3 (art. 148) : mineurs |

- Aucune issue nouvelle à créer : le constat du passage 2 s'ajoute à l'issue E-4 proposée au lot 3, § 4.
- R1 à R3 relèvent de #504 et d'une reprise par `docwriter` si le mainteneur les retient.
- Aucun chiffre, aucune p-value ni aucun verdict n'est touché.

Sources :
- [Règlement délégué (UE) 2026/269, version française (Office des publications)](http://publications.europa.eu/resource/celex/32026R0269)
- [Règlement délégué (UE) 2026/269, ELI](https://eur-lex.europa.eu/eli/reg_del/2026/269/oj)
