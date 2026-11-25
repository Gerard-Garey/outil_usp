# JS2, étape 4b : consultation des sources d'E11 (25/11/2026)

> Relevé de la session principale (IA), session locale de Claude Code sur le poste du mainteneur, le même jour que l'étape 4a (Q-74-9 (a)). Modèle : entrées du 18/11 de `docs/suivi-documentation/IV.md` et commentaire de veille 6982571393 de #463.

**Séance unique : 25/11/2026, de 18:48:37 à 18:54:17 UTC.** Pages lues par `curl` (HTTP), texte extrait de la page ou du PDF ; heure UTC de chaque requête entre parenthèses.

## 1. Page de l'AEAPP des orientations EIOPA-BoS-25/249

`https://www.eiopa.europa.eu/publications/final-report-revised-guidelines-undertaking-specific-parameters_en` (HTTP 200, 18:48:55) :
- dates affichées : « Publication date 14 July 2025 (Last updated on: 8 September 2026) », donc **aucune mise à jour** depuis les relevés précédents ;
- « The revised Guidelines will become applicable two months after the publication of translations into all official EU languages. Until then, the Guidelines issued in 2015 are applicable. » : formule inchangée ;
- aucune date d'application.

Page des orientations de 2015 (`…/guidelines-undertaking-specific-parameters_en`, HTTP 200, 18:48:59) : « Compliance Table » et ligne « France » toujours datés du 31 January 2023.

## 2. Déclaration de conformité de l'ACPR aux orientations de 2025

- Page « Orientations EIOPA » employée le 06/11 (`https://acpr.banque-france.fr/fr/reglementation/orientations-eiopa`) : HTTP 404 (18:52:33).
- Publication générale « Mise en œuvre des orientations de l'Autorité Européenne des Assurances et Pensions Professionnelles en vertu de la directive 2009/138/EC et du règlement (EU) N° 2015/35 » (HTTP 200, 18:52:53) : « Mise à jour le 24 Septembre 2026 », inchangée ; elle cite EIOPA-BoS-14/178 « sur les paramètres propres à l'entreprise » et ne mentionne pas EIOPA-BoS-25/249.
- Recherche du site de l'ACPR, « orientations eiopa » (HTTP 200, 18:52:56) : elle rend une **publication distincte**, que les relevés précédents n'avaient pas trouvée.
- **Fait nouveau.** Publication de l'ACPR « Mise en œuvre des orientations de l'Autorité Européenne des Assurances et Pensions Professionnelles concernant les paramètres propres à l'entreprise d'assurance (EIOPA-BoS-25/249) en vertu de la directive 2009/138/CE, du règlement délégué 2015/35 et du règlement d'exécution (UE) 2015/498 », rubrique « Registre officiel — Avis » :
  - URL : `https://acpr.banque-france.fr/fr/publications-et-statistiques/publications/mise-en-oeuvre-des-orientations-de-lautorite-europeenne-des-assurances-et-pensions-professionnelles-1` (HTTP 200, 18:53:26) ;
  - « Mise à jour le 12 Novembre 2026 » ; la liste de résultats de la recherche lui associe la date du 10 novembre 2026 ;
  - avis PDF : `https://acpr.banque-france.fr/system/files/2026-11/20261110_avis_conformit%C3%A9_GLs_Specific_Parameters.pdf` (HTTP 200, `application/pdf`, 18:54:15 ; md5 `c28d2311edd7d995f44bc8da77a77e6e`), une page, non daté dans son corps, nom de fichier daté du 10/11/2026 ;
  - texte de l'avis, intégral hors titre : « L'Autorité de contrôle prudentiel et de résolution (ACPR) s'est déclarée conforme aux orientations de l'Autorité Européenne des Assurances et Pensions Professionnelles concernant les paramètres propres à l'entreprise d'assurance (EIOPA-BoS-25/249). Ces orientations précisent les exigences relatives à l'utilisation de paramètres spécifiques à l'entreprise ou au groupe d'assurance pour le calcul du capital de solvabilité requis en formule standard. Ces orientations sont applicables aux organismes d'assurance et de réassurance qui doivent tout mettre en œuvre pour les respecter, conformément aux dispositions de l'article 16 du règlement (UE) n° 1094/2010 instituant l'Autorité Européenne des Assurances et Pensions Professionnelles. » ;
  - la page renvoie à la version française des orientations sur le site de l'AEAPP (`EIOPA-BoS-25-249 GLs on undertaking-specific parameters_FR.pdf`).
- Conséquence : l'avis est antérieur au 18/11/2026. L'affirmation du `.tex` ancrée sur `\dateconsultation` (« aucune déclaration […] trouvée » au 18 novembre 2026, mentions 1 et 4 d'E11) était donc déjà inexacte à cette date ; la recherche du 19/11 (#463, commentaire 7007125739) ne l'avait pas trouvée.

## 3. Règlement d'exécution (UE) 2015/498

Point d'accès SPARQL de l'Office des publications (`https://publications.europa.eu/webapi/rdf/sparql`, HTTP 200, 18:49:31-32) :
- aucun acte modificatif (`cdm:resource_legal_amends_resource_legal`) de 32015R0498 ;
- aucune consolidation `02015R0498-*` ;
- contrôle de méthode : la même requête sur 32015R0035 rend ses 13 actes modificatifs, de 32016R0467 à 32026R0269, et 12 identifiants `02015R0035-*`.

## 4. AEAPP, *Q&A*, question 2580

`https://www.eiopa.europa.eu/qa-regulation/questions-and-answers-database/2580_en` (HTTP 200, 18:49:02) : statut « Final », date de soumission « 13 Feb 2023 », article « Article 31; Annex XVII » ; réponse au point 1 identique mot pour mot à la citation du document (« The aggregated losses referred to in Annex XVII B.(1)(a) DR for a given year t should be equal to the claims paid during year t plus the best estimate of the claims outstanding at the year end of the first development year of the accident year t. »).

## 5. Légifrance, code des assurances

Pages lues par `curl` (HTTP 200) :
- art. R. 352-5 (`LEGIARTI000030564441`, 18:52:28) : « En vigueur depuis le 01 janvier 2016 », création par le décret n° 2015-513 du 7 mai 2015, art. 4 ;
- art. R. 356-19 (`LEGIARTI000036332133`, 18:52:30) : « En vigueur depuis le 31 décembre 2017 », modifié par le décret n° 2017-1765 du 26 décembre 2017, art. 1er ;
- aucune version à venir ni abrogation (`data-abrogated="false"`) ; le module des versions n'a pas été ouvert (même limite qu'aux relevés précédents).

## Verdict

Les cinq sources ont été consultées. Quatre sont inchangées. La deuxième porte un fait nouveau : l'ACPR s'est déclarée conforme aux orientations EIOPA-BoS-25/249 (avis du 10/11/2026, page mise à jour le 12/11/2026).

**Verdict : PJ-3.** Selon la fiche, `regulatory` (routine) lit la source, puis le mainteneur décide : le `.tex` change dans JS2 (texte seul), ou une issue est créée. `\dateconsultation` n'est pas changé avant cette décision.
