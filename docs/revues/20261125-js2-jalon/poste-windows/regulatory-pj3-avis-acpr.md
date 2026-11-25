# JS2, PJ-3 : lecture de l'avis de l'ACPR par `regulatory` (25/11/2026)

> Rapport de l'agent `regulatory` (IA, fiche de routine), versé intégralement par la session principale. L'agent n'a rien écrit dans le dépôt. Saisi au point d'arrêt PJ-3 de l'étape 4b (`etape-4b-sources.md`, source 2).

**Conclusion.** Aucun chiffre, aucun contrôle du moteur et aucun verdict ne dépend de ce fait. En revanche, l'avis de l'ACPR rend incomplète, et de fait trompeuse, la mention « aucune déclaration de conformité de l'ACPR […] trouvée ». Elle figure en deux endroits (l. 10600-10601 et 21664-21665). Une correction texte seul dans JS2 suffit. `\dateconsultation` ne peut passer au 25/11 que si les quatre sources de l'exception E11 sont relues et consignées.

## 1. Relevé de la source

**Ce que j'ai pu lire :**
- **Page de l'ACPR** (« mise-en-oeuvre-…-1 ») : lue. Type « Avis » (registre officiel). Seule date affichée : « Mise à jour le 12 Novembre 2026 ». Aucune date de publication distincte. Liens vers le PDF de l'avis et vers la version FR d'EIOPA-BoS-25/249.
- **PDF de l'avis** : lu en rendu graphique, une page.
  - Intitulé : « Mise en œuvre des orientations […] concernant les paramètres propres à l'entreprise d'assurance (EIOPA-BoS-25/249) en vertu de la directive 2009/138/CE, du règlement délégué 2015/35 et du règlement d'exécution (UE) 2015/498 ».
  - Le texte est conforme à la citation de la session.
  - **Aucune date dans le corps**, aucune signature, aucun numéro. Mention de pied de page « ACPR-RESTREINT ».
  - Métadonnées : `CreationDate` et `ModDate` = 2026-11-10T10:29:20+01:00, nom de fichier `20261110_…`, dossier `2026-11`.

**Date de l'avis :**
- Ce qu'on peut établir : fichier créé le 10/11/2026 ; page affichée comme mise à jour le 12/11/2026. L'avis existait donc en ligne avant le 18/11, au moins selon la date que la page affiche.
- Ce qu'on ne peut pas établir : la date exacte de la déclaration de conformité, la date de première mise en ligne, et si le 12/11 est une première publication ou une retouche.

**Portée de l'avis :**
- Il dit : l'ACPR se déclare conforme à EIOPA-BoS-25/249, et ces orientations « sont applicables » aux organismes, au sens de l'art. 16 du règlement (UE) n° 1094/2010.
- Il ne dit pas :
  - la date d'application en France ;
  - si les orientations de 2015 (EIOPA-BoS-14/178) cessent de s'appliquer, ni quand ;
  - quoi que ce soit sur la notice (§ 171, qui renvoie à l'orientation 6 de 2015).

**Page générale de l'ACPR** (mise à jour le 24/09/2026) : lue. Elle ne cite qu'EIOPA-BoS-14/178. Pas de mention de 25/249.

**Page de l'AEAPP** : lue.
- « 14 July 2025 (Last updated on: 8 September 2026) ».
- « The revised Guidelines will become applicable two months after the publication of translations into all official EU languages. Until then, the Guidelines issued in 2015 are applicable. »
- Aucune date d'application.
- Le document « Guidelines on undertaking-specific parameters » porte la date 14 October 2025. Il est listé en anglais plus 23 traductions, soit les 24 langues officielles. Les traductions ne sont pas datées (« AI induced translations »).

**Les traductions sont-elles publiées ?**
- Indices pour : les 24 langues sont listées sur la page. Selon `docs/suivi-documentation/IV.md` (relevé du 06/11), les PDF FR, GA et MT ont été créés le 04/09/2026. La page a été mise à jour le 08/09/2026. Une déclaration de l'ACPR environ deux mois plus tard serait cohérente avec le délai de l'art. 16(3) du règlement 1094/2010. C'est une inférence, non établie par les pièces.
- Indice contre : la phrase « Until then… » est maintenue, mais elle est conditionnelle et n'a pas été mise à jour.
- **La date de publication des traductions, donc la date d'application, n'est pas établie.**

**Non lisible :** le PDF FR des orientations (lien de l'ACPR vers l'AEAPP). WebFetch a renvoyé 403, curl a renvoyé 429. Ses métadonnées et son texte n'ont pas été relus.

## 2. Passages du `.tex` (`docs/latex/doc_tests_usp.tex`, tête `e04e8a3`)

| Lignes | Citation courte | Verdict | Motif |
|---|---|---|---|
| 53 | `\dateconsultation{18~novembre 2026}` | exact (voir § 4) | C'est une date de consultation : elle ne devient pas fausse, mais l'état qu'elle date est dépassé. |
| 443-445 | « EIOPA-BoS-14/178 (orientation~6) et EIOPA-BoS-25/249 (orientation~5)~; notice de l'ACPR, §§~2, 170 et~171 » | exact | Liste de références, sans affirmation sur la conformité. |
| 10583-10588 | notice de l'ACPR, « Version du 17/07/2023 », §§ 170-171 | exact | Inchangé par l'avis. |
| 10591-10593 | « auxquelles l'ACPR s'est déclarée conforme le 1er décembre 2023 (notice, §~2) » | exact | Vrai pour 2015. Seul, il laisse croire que c'est la seule déclaration : voir 10600-10601. |
| 10593-10597 | « abrogées et remplacées par […] EIOPA-BoS-25/249, adoptées le 25~juin 2025, applicables deux mois après la publication de leurs traductions » | exact | C'est la règle de la page de l'AEAPP. |
| 10597-10600 | « la même page donne ces traductions […] non datées, et indique toujours que les orientations de 2015 s'appliquent […] la date d'application n'est donc pas établie » | exact | Constat confirmé au 25/11. |
| 10600-10601 | « et aucune déclaration de conformité de l'ACPR à ces nouvelles orientations n'a été trouvée » | **incomplet, trompeur** | C'est littéralement le compte rendu d'une recherche, mais une déclaration existait au 18/11 (avis du 10/11, page du 12/11). Le dossier affirmerait donc à tort son absence. Il devient **inexact** si `\dateconsultation` avance. |
| 10601 | « la version applicable est celle en vigueur à la date de référence du calcul » | exact | Principe inchangé. Reste muet sur ce que l'avis apporte en France (voir § 3). |
| 10601-10604 | exigence de tests annuels et rapport ORSA tirée de la notice (§ 171), non des orientations | exact | L'avis ne touche pas la notice. Voir aussi le § 3 sur le § 171. |
| 21638-21648 | notice : « §~2 (conformité de l'ACPR, déclarée le 1er décembre 2023, aux orientations… » | exact | Décrit ce que dit la notice. |
| 21650-21653 | EIOPA-BoS-14/178 : « version à laquelle l'ACPR s'est déclarée conforme (notice, §~2) » | **incomplet** | L'article défini laisse entendre une version unique. L'ACPR s'est aussi déclarée conforme à 25/249. |
| 21655-21660 | entrée EIOPA-BoS-25/249 : « orientations données dans toutes les langues officielles […] non datées~; page indiquant toujours l'application des orientations de 2015 » | exact | Constat confirmé. |
| 21662-21664 | « Applicables deux mois après […]~; jusque-là, les orientations de 2015 s'appliquent. Date de cette publication non établie » | exact | Constat confirmé. |
| 21664-21665 | « et aucune déclaration de conformité de l'ACPR trouvée, au \dateconsultation{} » | **incomplet, trompeur** | Même motif qu'aux l. 10600-10601. L'entrée bibliographique ne cite pas l'avis de l'ACPR (absent de `sec:biblio`). |
| 21626, 21671, 21682 | `\dateconsultation` pour le règlement 2015/498, la question 2580, le code des assurances | exact | Non touchés par l'avis. |
| 8367, 8373, 10817, 22549 | « dossier ACPR », notice § 159 | exact | Sans rapport avec la conformité aux orientations. |

Hors `.tex`, `docs/suivi-documentation/IV.md` contient un constat devenu faux :
- l. 219 : « la publication n'ayant pas changé depuis le 24/09/2026, l'absence de déclaration vaut au 18/11 » est **inexact**. La déclaration figure sur une autre page de l'ACPR (suffixe « -1 »).
- l. 218 (relevé du 06/11) : « aucune déclaration de conformité de l'ACPR trouvée » était exact à cette date, puisque le fichier date du 10/11.

## 3. Effet réglementaire

**Moteur : aucun effet.** Aucune occurrence d'EIOPA, d'« orientation » ou de l'ACPR dans `R/` (seuls des homonymes graphiques dans `display_helpers.R`).
- `TEXTES_APPLICABLES` et `engine_valider_declarations()` ne portent que sur les règlements délégués : M6, 2019/981, 2026/269.
- Aucune donnée réglementaire (`ANNEXE_II`, `ANNEXE_XIV`, `CRED_*`), aucune déclaration (`reassurance_np`, `cdd_qualifiante`), aucun σ_USP, aucune p-value et aucun verdict n'en dépend.

**Dossier :** les orientations n'ont pas force de loi. L'art. 16(3) du règlement 1094/2010 oblige à « tout mettre en œuvre » (*comply or explain*). Ce qui change :
- La documentation ne peut plus dire qu'aucune déclaration de l'ACPR n'existe.
- Quand 25/249 s'applique, la conformité continue relève de l'orientation 5 (§§ 13-15), sans tests statistiques ni périodicité. Le § 171 de la notice renvoie alors à une orientation 6 de 2015 abrogée.
- L'exigence de tests annuels et du rapport ORSA reste une exigence de la notice de l'ACPR (version du 17/07/2023), tant que celle-ci n'est pas révisée. Le `.tex` le dit déjà (l. 10601-10604).
- Ni les tests de l'outil ni leur rôle n'en sont modifiés.

**Trois lectures de l'applicabilité en France, sans trancher :**
- **(L1)** Applicables deux mois après la publication de toutes les traductions, date fixée par l'AEAPP. La déclaration de l'ACPR (art. 16(3)) n'atteste que l'intention de l'autorité de s'y conformer. Jusqu'à cette date, les orientations de 2015 s'appliquent. La date n'est pas établie par les pièces, même si les indices du § 1 la placeraient vers début novembre 2026.
- **(L2)** En France, les organismes sont tenus de s'y conformer dès l'avis de l'ACPR (« sont applicables »), donc au plus tard le 12/11/2026.
- **(L3)** Variante de L1 : l'avis de l'ACPR, qui ne fixe aucune date, n'écarte pas la phrase de l'AEAPP « Until then, the Guidelines issued in 2015 are applicable » tant que cette page n'est pas mise à jour.

Aucune de ces lectures ne change un résultat de l'outil. La formule du `.tex` « version en vigueur à la date de référence du calcul » reste valable sous les trois.

**Critère ADR 0018 :** E6, affirmation de la documentation contredite par une source datée (avis du 10/11, page du 12/11) ; aucun effet sur σ_USP, sur un verdict ou sur la reproductibilité.

## 4. Recommandation de forme

**Recommandation : (a), correction texte seul dans JS2.** Le changement porte sur un fait documentaire, sans effet sur le code ni sur les résultats. L'exception E11 prévoit justement de mettre à jour ces mentions aux jalons.

À corriger :
1. **l. 10600-10601** : remplacer « et aucune déclaration […] n'a été trouvée » par le constat de l'avis. L'ACPR s'est déclarée conforme à EIOPA-BoS-25/249 (avis du registre officiel, fichier daté du 10/11/2026, page mise à jour le 12/11/2026). L'avis rappelle l'art. 16 du règlement 1094/2010 sans fixer de date d'application. La date d'application reste donc non établie. Aucune date de déclaration ne doit être écrite au-delà de ce que montrent les pièces.
2. **l. 21664-21665** : même correction dans l'entrée EIOPA-BoS-25/249, ou renvoi à une nouvelle entrée bibliographique (point 4).
3. **l. 21653** : « version à laquelle l'ACPR s'est déclarée conforme » devient « version à laquelle l'ACPR s'est déclarée conforme selon la notice (§ 2) ». La conformité à 25/249 est renvoyée à l'avis.
4. **`sec:biblio`** : ajouter une entrée « ACPR, *Avis — Mise en œuvre des orientations […] (EIOPA-BoS-25/249)* » : URL du PDF et de la page ; dates (fichier du 10/11/2026, page mise à jour le 12/11/2026) ; portée (déclaration de conformité, art. 16, aucune date d'application, rien sur les orientations de 2015 ni sur la notice) ; date de consultation ancrée sur `\dateconsultation` (ajout de cette source à la liste de l'exception E11 dans `CONVENTIONS.md`, § 5).
5. Optionnel, conseillé : une demi-phrase à la fin de l'introduction de la partie III : une fois 25/249 applicable, le § 171 de la notice renvoie à une orientation abrogée, et l'exigence de tests annuels reste celle de la notice tant qu'elle n'est pas révisée. Cela touche le fond : avis d'`actuary` souhaitable.
6. Hors `.tex` : corriger `docs/suivi-documentation/IV.md`, l. 219, sous le `\label` d'origine, et signaler l'erreur de relevé du 19/11 dans #463 (page « -1 » non trouvée).

Si le mainteneur préfère une issue (b) : titre « Documentation : déclaration de conformité de l'ACPR aux orientations EIOPA-BoS-25/249 (avis du 10/11/2026) absente de la partie III et de la bibliographie » ; libellés `bug`, `needs-triage` ; corps : fait, passages touchés (`doc_tests_usp.tex` l. 10600-10601, 21653, 21664-21665 ; `IV.md` l. 219), effet (aucun sur le moteur ni les résultats ; ADR 0018, E6), lectures L1 à L3 à trancher par le mainteneur et `actuary`, correction (points 1 à 6), Refs #463, #607.

**`\dateconsultation` au 25 novembre 2026 : seulement sous conditions.** L'exception E11 n'autorise le changement qu'à un jalon (JS2 en est un), et après une nouvelle consultation de chacune des sources ancrées, consignée dans `IV.md`. L'agent a relu lui-même la page de l'AEAPP et les pages de l'ACPR ; il n'a relu ni le règlement d'exécution 2015/498, ni la question 2580, ni le code des assurances. Tant que ces trois-là ne sont pas relues et consignées, la date reste au 18/11 et la correction 1-2 s'écrit au passé.

> *Note de la session principale.* Les trois sources que l'agent n'a pas relues l'ont été par la session principale le même jour, dans la séance de 18:48 à 18:54 UTC (`etape-4b-sources.md`, sources 3, 4 et 5), sans fait nouveau. La condition posée ci-dessus pour `\dateconsultation` au 25 novembre 2026 est donc remplie, sous réserve de la décision du mainteneur sur PJ-3 et de l'entrée de `IV.md` (étape 5, fin).
