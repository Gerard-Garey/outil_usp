> *Rédigé par l'agent actuary (IA).* Fiche `actuary-approfondi` (matrice § 3 de `docs/agents/routage.md` : nouvelle approche, au moins deux options), 18/11/2026, lecture seule, sur `main` `c013568`. Versé intégralement par la session principale. Le constat 2 du `README.md`, que le § 5 juge inexact, a été corrigé depuis.

# Avis d'`actuary` sur Q-66-3 : lire les classeurs par le seul lecteur interne ? (temps 2 de Q-67-7 (a))

**En bref :** je recommande l'option **(a)**. Le lecteur interne devient le seul lecteur de production, et `openxlsx` reste un témoin de test borné. L'ordre est **(a) > (b) >> (c) >> (d)**. Aucune mesure de plus n'est nécessaire avant la décision.

Mission en lecture seule : je n'ai écrit aucun fichier, aucune issue et aucun commentaire. Dépôt `/home/user/outil_usp`, `main` `c013568`. L'arbre de travail porte deux éléments non commités qui ne sont pas de mon fait : `docs/feuille-de-route.md` modifié et le dossier `docs/revues/20261118-q66-3-lecteur-interne/`.

## Ce que j'ai lu, et pourquoi

**Lectures du brief :**
- `README.md` de la mesure, `comparaison.txt`, et les scripts `lire_corpus.R`, `comparer.R` et `generer_suppl.R` ;
- `docs/feuille-de-route.md` : Q-66-3 (l. 6928), Q-67-7 (l. 4155), « Forme » de la fiche S4, bloc du 68ᵉ point (l. 6971-7012), décisions E-18/11 (#594) et E-18/11 (corpus) (l. ~4553) ;
- `R/engine.R` :
  - en-tête de la section 7ter (l. 8813-8833) ;
  - en-tête et corps d'`engine_lire_xlsx()` (l. 11540-11720) ;
  - commentaire de la règle D-S1-31 dans `.xlsx_controler_structure()` (l. 10390-10400) ;
  - `.xlsx_blancs_entete()` (l. 11243-11258) ;
- #594 et la spécification `issuecomment-6986469629` ; D-S1-31 et D-S1-34 (`docs/revues/20261115-s1-rejeu/decisions-mainteneur.md`, l. 74 et 84) ; `mesure-594/README.md` ;
- `docs/exigences.md` § 4.1, 4.2 et 5.6 ; ADR 0016, point 6 ; `docs/agents/routage.md` § 4.

**Lectures hors brief :**
- `docs/latex/doc_tests_usp.tex`, l. 5470-5516 (« Écarts qui subsistent entre les deux chemins ») : pour vérifier la portée de la parité ;
- #602 : c'est un écart où `openxlsx` lit juste et le lecteur interne faux ;
- le job `parite-lecteurs` de `.github/workflows/ci.yml` (l. 348-462) : pour savoir ce que couvrent les trois lots et le job, `zip` compris ;
- `identite_code()` (`R/display_helpers.R`, l. 2966) : pour savoir ce que le rapport figé consigne ;
- `formals(utils::unzip)` et la source de `read.xlsx.default` d'`openxlsx` (branche `master` de GitHub, et non la version 4.2.5.2).

## 1. Fond pour le dossier ACPR : un interprète ou deux ?

**Conclusion : un seul interprète (le lecteur interne) est plus défendable.**

**a. Revue indépendante d'un fichier quantitatif unique.** `docs/exigences.md` § 4.1 range « préparation et transformation des données » dans `R/engine.R`, « pour permettre une revue indépendante ».
- Sur le chemin `openxlsx`, le passage du XML au `data.frame` est fait par du code tiers, hors du fichier revu : `getCellInfo`, `getSharedStringsFromFile`, `read_workbook`, `replaceXMLEntities`.
- Aujourd'hui, ce point repose sur une exception de `CLAUDE.md`, non sur l'exigence elle-même.
- *Vérifié* : texte d'exigences et source de `read.xlsx.default`, lue sur `master`. Que ces fonctions soient compilées (Rcpp) est une *hypothèse*, non vérifiée.

**b. Pas de contrôle croisé en production.** `engine_lire_xlsx()` admet le classeur, puis rend **directement** `openxlsx::read.xlsx(...)` si le paquet est présent (l. 11654-11657). Aucune comparaison n'a lieu à l'exécution.
- Le statu quo n'offre donc pas une lecture contrôlée par deux interprètes. Il offre deux lectures possibles, et l'environnement du poste choisit laquelle.
- *Vérifié* (lecture du code).

**c. La traçabilité de la lecture est incomplète aujourd'hui.**
- `identite_code()` ne relève que `version`, `md5_engine`, `md5_chargeur` et `releve`. `app.R` et `R/display_helpers.R` ne contiennent aucune occurrence d'`openxlsx`. *Vérifié* (grep).
- Le rapport figé ne dit donc ni quel interprète a lu les données, ni la version d'`openxlsx`.
- Avec le seul lecteur interne, le md5 de `R/engine.R` et la version de R identifient entièrement le lecteur. Restent hors de cette identité :
  - `utils::unzip`, dont la méthode par défaut est `"internal"` (*vérifié*, R 4.3.3) ;
  - les moteurs d'expressions régulières de R ;
  - la locale, qui fixe la classe `[[:space:]]` des en-têtes (en-tête de `.xlsx_blancs_entete()`, parité non mesurée sous Windows).
- L'empreinte des données (`engine_empreinte()`) atténue l'écart sans le combler : elle identifie les valeurs employées, non le lecteur.

**d. Reproductibilité d'un poste à l'autre.**
- *Statu quo* : le résultat de la lecture dépend de deux faits que le rapport figé ne trace pas, la présence d'`openxlsx` et sa version.
- Deux versions sont déjà en service : 4.2.5.2 en CI (instantané de 2023) et 4.2.9 sur le poste. L'en-tête d'`engine_lire_xlsx()` documente des comportements propres à l'une ou à l'autre (cible `./worksheets/…`, `r:id` qui faisait lire la feuille suivante sous 4.2.5.2). Un relecteur de l'ACPR peut avoir une troisième version, dont la parité n'est pas mesurée.
- *Lecteur interne seul* : la lecture ne dépend plus que du code versionné et de R. La dépendance à la locale reste à consigner.

**e. Point décisif : la parité ne vaut pas sur tout le domaine admis.** Le `.tex` (l. 5470-5495) et l'en-tête d'`engine_lire_xlsx()` consignent, **sur des classeurs admis**, des formes que le lecteur interne lit juste et devant lesquelles `openxlsx` s'arrête sur une erreur R :
- balises `<sheet>` et `<Relationship>` préfixées ;
- attributs entre apostrophes ;
- cible `./worksheets/…` ;
- seconde entrée de même nom dans un autre dossier.

Ils consignent aussi des différences de contenu sans effet sur les valeurs employées :
- colonne booléenne rendue logique par `openxlsx`, en caractères par le lecteur interne ;
- `&amp;lt;1` rendu `<1` par `openxlsx`.

Aujourd'hui, un même classeur admis peut donc être lu sur un poste et refusé par une erreur R sur un autre, selon la présence d'`openxlsx`. *Vérifié* par lecture du `.tex` et du code ; ce sont des mesures antérieures que je n'ai pas refaites (`openxlsx` absent de la session).

**f. Le lecteur interne est déjà un lecteur de production.** C'est celui de tout poste sans `openxlsx`. C'est aussi le seul qu'exercent les trois lots de la CI (ci.yml, l. 349-353 : « Les trois lots n'ont ni openxlsx ni zip »).
- Sa justesse doit donc être établie quoi qu'on décide. Garder `openxlsx` n'en dispense pas : cela ajoute un second interprète à justifier.
- *Vérifié* (ci.yml).

## 2. Effet sur #594 et sur la prémisse de D-S1-31

**a. D-S1-31 ne repose que sur la double lecture.**
- Le commentaire du code (l. 10390-10396) motive le refus par la seule lecture fausse d'`openxlsx` : « le lecteur interne lit xt et 104.2 (mesure) ». La décision D-S1-31 dit de même : « lue juste par la voie de repli […], attribut gardé dans le texte par `openxlsx` ».
- Si `openxlsx` est retiré de la production, D-S1-31 perd **toute** sa prémisse, et non une partie. *Vérifié* (lecture).

**b. Limites qui disparaissent.**
- La limite du `data.frame` rendu (spécification, § 2.3) : la colonne `note` serait lue juste, blancs gardés, par le lecteur unique.
- Le test T6 (« limite consignée ») devient sans objet en production.
- La limite de E-18/11 (corpus) disparaît aussi : il n'y a plus de lecture fausse à confiner dans sa cellule. La question « confinement pour un autre écrivain » tombe donc, alors que c'était la seule *hypothèse* restante pour Excel et LibreOffice.

**c. L'option (b) bornée n'est plus fausse, mais elle devient trop restrictive.**
- Ses bornes (triangle, ligne 1, colonnes `t`, `xt`, `yt`, textes faits de seuls blancs) étaient toutes motivées par la parité :
  - ` 104.2 ` refusé par `openxlsx` ;
  - divergence vide / non vide ;
  - en-tête préfixé.
- Or la forme partagée `<si><t xml:space="preserve">` est **déjà admise partout** (T9 de la spécification ; mesure-594 : XlsxWriter par défaut, lu juste).
- Sans `openxlsx`, la règle cohérente devient une **admission uniforme de la forme exacte `<t xml:space="preserve">` en chaîne en ligne**, traitée comme la chaîne partagée. Cela supprime :
  - l'argument `objet` d'`engine_lire_xlsx()` et la modification d'`app.R`, c'est-à-dire le contrat partagé que #594 introduisait ;
  - la règle de localisation placée après R9 et R10 ;
  - le nouveau motif de refus ;
  - une partie de T2, T3, T4, T7 et T8.
- *Hypothèse* : que la chaîne partagée bordée de blancs se lise aujourd'hui comme le ferait la chaîne en ligne, dans une cellule lue (en-tête `xt ` ramené à `xt` par `.xlsx_blancs_entete()`, cellule ` 104.2 `). Je ne l'ai pas mesuré ; cela doit devenir un critère d'acceptation.

**d. Ce que la spécification d'A1 doit changer si l'option (a) ou (b) est retenue.**
1. Rouvrir le choix « bornée ou uniforme ». E-18/11 (#594) a retenu la forme bornée **sur une prémisse que Q-66-3 change** : c'est au mainteneur de trancher à nouveau, sur une spécification amendée par `actuary`.
2. Ce qui garde sa justification sans `openxlsx` :
   - le refus des formes non exactes (`<t >`, apostrophes, `xml:space="default"`, `x:space=`), au nom du contrat fermé et faute d'écrivain connu ;
   - le refus des entités numériques (D-S1-18).
3. Ce qui doit être justifié par la sémantique propre du lecteur interne, et non plus par la parité :
   - le sort des blancs autour d'un nombre écrit en texte ;
   - un texte fait de seuls blancs, lu vide (à aligner sur `.nettoyer_cellules()` et sur le cas openpyxl sans lxml, déjà lu aujourd'hui).
4. La mesure du § 3.3 (triangle témoin) devient un simple test de non-régression sur un seul chemin.
5. **Ordre dans A1** : la décision Q-66-3 d'abord, puis #602, puis #594 respécifiée.

## 3. Risques du retrait d'`openxlsx`

| Risque allégué | Réel ? | Preuve |
|---|---|---|
| Classeurs que seul `openxlsx` lirait | **Non.** L'admission, commune et écrite en `R/engine.R`, précède `openxlsx`. Tout classeur admis a été analysé par les briques du lecteur interne (`.xlsx_cellules()`), et tout classeur refusé l'est sur les deux chemins. Le `.tex` documente l'inverse (des classeurs que seul le lecteur interne lit), jamais ce cas. | *Vérifié* (code l. 11643-11657, `.tex` l. 5470-5495) ; l'absence de forme admise que le lecteur interne lirait mal hors de #602 est une *hypothèse* |
| Perte d'un contrôle croisé | **En production, non** : ce contrôle n'existe pas (§ 1 b). **En test, oui mais modeste** : le seul défaut connu du lecteur interne, #602 (fins de ligne `\r\n` non normalisées, XML 1.0 § 2.11), a été **détecté** par comparaison au texte écrit, une référence tirée de la source ; la lecture juste d'`openxlsx` a seulement **orienté** le diagnostic. | *Vérifié* (#602) |
| Défaut du lecteur interne exposé à tous les postes | **Oui, pour #602** : sous Windows avec `openxlsx`, un texte à saut de ligne relu `\n` serait relu `\r\n` tant que #602 n'est pas corrigé. Textes seulement : aucun nombre, aucun σ_USP, aucun verdict. | *Vérifié* (#602, « Portée ») |
| Durée | Aucun gain ni aucune perte mesurables : c'est l'admission qui coûte. | *Vérifié* (`comparaison.txt` : 2,975 s contre 2,974 s pour 5 000 lignes) |
| Couverture de `zip` | **Un risque à ne pas créer.** Le job de parité couvre aussi l'archive par `zip::zipr()` (#488) et l'export de l'application. Retirer le job avec `openxlsx` retirerait cette couverture. | *Vérifié* (ci.yml, l. 349-378) |

**`openxlsx` comme oracle de test.** Le mot « oracle » est trop fort : sur le domaine admis, `openxlsx` a de nombreuses lectures fausses mesurées. Je propose l'expression « témoin différentiel ».
- Sa seule valeur propre est de déceler une erreur dans les valeurs attendues qu'un auteur de test écrit à la main (XML forgé), ou un écart sur un classeur dont la source n'est pas encodée.
- Partout où la source est connue (CSV de `tests/donnees/`), la comparaison à la source est strictement plus forte.
- Je le recommande donc **borné** :
  - au corpus naturel (classeurs des écrivains : openpyxl, pandas, XlsxWriter, `openxlsx::write.xlsx()`, écrivain interne) ;
  - sur les valeurs employées et la sortie d'`engine_lire_donnees_csv()` / `engine_lire_triangle()` ;
  - avec une liste fermée des écarts attendus.
- Le critère bloquant reste l'accord du lecteur interne avec la source. Les tests sur XML forgé deviennent des tests du seul lecteur interne, aux valeurs attendues explicites.

## 4. Piste `loadWorkbook(dossier, isUnzipped = TRUE)`

- **Apport** : supprimer la seconde décompression, qui pèse 0,1 % à 4,5 % de la lecture (mesure de #558, en-tête d'`engine_lire_xlsx()`) et dont l'effet ne se mesure pas sur le corpus. L'apport est négligeable.
- **Risques :**
  - elle remplace l'interprète dont la parité est mesurée (`read.xlsx.default`) par `read.xlsx.Workbook()`, sur lequel aucune mesure n'existe. D'après la source de `master`, `read.xlsx.default` « ne passe pas par `loadWorkbook` » (*vérifié* sur `master`, non sur 4.2.5.2). Tout le capital de mesures (S1, S4, #574, #595) serait à refaire ;
  - elle garde les deux interprètes, donc tous les coûts du statu quo ;
  - `loadWorkbook()` lit plus de parties du classeur que `read.xlsx.default` : surface d'analyse accrue (*hypothèse*) ;
  - son effet sur le dossier d'admission qu'on lui passe n'est pas connu (*non vérifié*).
- **Verdict : à écarter.**

## 5. Ce que la mesure établit, et ce qu'elle n'établit pas

**Elle établit** (*vérifié*) :
- l'identité au bit près des retours d'`engine_lire_xlsx()` et des lecteurs aval, refus et messages compris ;
- sur 42 classeurs venant de cinq écrivains tiers et des deux écrivains R ;
- sous Linux, en `C.UTF-8`, avec `openxlsx` 4.2.5.2, chemin interne obtenu par l'absence réelle du paquet, qui est la condition de production ;
- à quoi s'ajoutent les 15 classeurs relus sous Windows avec 4.2.9.

**Elle n'établit pas :**
- l'équivalence sur le domaine admis : des écarts consignés existent sur des formes forgées admises, absentes du corpus ;
- le comportement sur des sorties d'Excel ou de LibreOffice ;
- le comportement sous d'autres versions d'`openxlsx` ;
- le comportement sous la locale Windows pour les blancs d'en-tête.

**Correction à porter au dossier de la mesure.** Le constat 2 du `README.md` dit : « un classeur que seul le lecteur interne lirait juste est refusé par l'admission sur les deux chemins ». C'est **inexact en général**. Les formes du § 1 e sont admises, lues juste par le lecteur interne, et arrêtent `openxlsx` sur une erreur R (`.tex` l. 5482-5495). La phrase doit être bornée au corpus mesuré, ou corrigée avant d'être versée au dossier de l'ADR. Cette correction **renforce** l'argument du retrait.

**Faut-il une mesure de plus avant la décision ? Non.** La décision dépend d'une seule question : retirer `openxlsx` fait-il perdre une lecture juste ? Par construction, cela ne peut arriver que là où le lecteur interne se trompe sur une forme admise. Ce cas n'est pas atteignable par un corpus fini ; il se traite par la conformité du lecteur interne, déjà obligatoire.

Je recommande deux actions de session, au titre de **conditions de l'ADR** et non de préalables :
1. **Inventaire, sur lecture, des écarts consignés entre les deux chemins** (`.tex` l. 5470-5516, en-têtes du code, tests), classés selon le lecteur qui a raison. Seul #602 donne tort au lecteur interne à ma connaissance ; c'est une *hypothèse*, qu'il faut confirmer par cet inventaire. Faisable en session, sans `openxlsx`.
2. **Relecture à la source de XML 1.0** (§ 2.10, 2.11, 3.3.3) pour la conformité du lecteur interne : fins de ligne, `xml:space`, normalisation des valeurs d'attribut.
   - Elle est déjà prévue pour #602.
   - `www.w3.org` est injoignable dans cette session (*non vérifié* ; tentative faite, le domaine doit être autorisé). Elle se fera depuis le poste, ou après autorisation du domaine.

## 6. Recommandation : (a) > (b) >> (c) >> (d)

1. **(a) Lecteur interne seul en production, `openxlsx` gardé comme témoin de test borné.**
   - Motifs : §§ 1 a à 1 f. Une seule lecture, auditable dans le fichier revu et identifiée par le md5 de `R/engine.R`. Le témoin garde un contrôle indépendant à bas coût sur le corpus naturel.
2. **(b) Retrait complet.** Presque aussi bon sur le fond, puisque la comparaison à la source suffit sur un corpus aux valeurs connues. On perd le témoin, qui ne pèse dans aucune décision. L'écart entre (a) et (b) est une question de coût de maintenance, pour `architect` et le mainteneur, non une question de fond.
3. **(c) Statu quo.** Deux lectures possibles, choisies par le poste et non tracées au rapport figé ; issues de parité récurrentes ; double justification au dossier.
4. **(d) `loadWorkbook(isUnzipped = TRUE)`.** Les coûts de (c), plus un interprète non mesuré, pour un gain négligeable.

**Conditions d'acceptation de l'option (a) :**

1. **Code**
   - Retirer l'embranchement de la l. 11654, **sans autre changement de comportement** dans le même commit : aucune règle d'imitation d'`openxlsx` n'est retouchée (blancs d'en-tête, booléens rendus `"TRUE"`/`"FALSE"`, en-têtes en double).
   - Ces règles deviennent des choix du lecteur interne : l'ADR les liste et les garde.
   - Réécrire l'en-tête de la section 7ter (« implémentation plus complète et mieux éprouvée… repli ») et les en-têtes d'`engine_lire_xlsx()` et d'`.xlsx_admettre()` (« avant les deux adaptateurs »).
2. **Preuve de non-changement**
   - Rejouer `lire_corpus.R` **avec `openxlsx` installé** : le résultat doit être `identical()` à `interne.rds` sur les 42 classeurs.
   - Ajouter un test, dans le job qui installe `openxlsx`, qui vérifie que l'espace de noms `openxlsx` n'est pas chargé par `engine_lire_xlsx()` (`loadedNamespaces()`).
3. **Références** : identiques au seuil 0, `run_engine()` n'étant pas touché (skill `verifier-reproductibilite`) ; `concordance_doc_moteur.R --strict`.
4. **Tableau « hors références »** des comportements qui changent sur un poste muni d'`openxlsx` :
   - formes admises du § 1 e, lues au lieu d'une erreur R ;
   - colonne booléenne rendue en caractères, même refus en aval ;
   - textes à entités dans les colonnes non employées ;
   - textes à saut de ligne sous Windows, jusqu'à #602.
   - Aucun σ_USP, aucun verdict ni aucune p-value attendus changés. C'est une *hypothèse* hors corpus ; elle est *vérifiée* sur le corpus.
5. **Tests** : une assertion qui compare à une valeur attendue explicite est gardée sur le seul lecteur interne. Une assertion « même résultat qu'`openxlsx` » est soit convertie (valeur attendue explicite), soit déplacée dans la suite témoin bornée (corpus naturel, liste fermée des écarts attendus). `test_outdec.R` est à adapter.
6. **CI** : le job de parité, rebaptisé, garde `openxlsx` 4.2.5.2 (témoin) **et `zip`**, avec la couverture de `zip::zipr()` et de l'export de l'application. Les trois lots restent sans ces paquets.
7. **`.tex`** (`docwriter`, passage unique en fin de branche) : revoir les 74 occurrences.
   - Un seul lecteur ; « Écarts qui subsistent entre les deux chemins » devient la description du lecteur unique.
   - Les lectures fausses d'`openxlsx` mesurées peuvent rester comme **motif** de règles du contrat fermé (une forme qu'un lecteur répandu lit faux). Sinon, ces règles se justifient par « forme non lue de façon sûre ».
   - Index : `engine_lire_xlsx()`. Vie du dépôt dans `docs/suivi-documentation/`.
8. **`README.md`, `DESCRIPTION`** : « Lecture xlsx » et « Prérequis » à reprendre. `openxlsx` reste en `Suggests` sous (a), il en sort sous (b).
9. **`CLAUDE.md` « Architecture »** : remplacer l'exception « la lecture xlsx utilise `openxlsx` s'il est installé, avec repli sur un lecteur interne » par « lecture xlsx par le seul lecteur interne ». Commit `claude:` sur instruction du mainteneur. Annoter le point 6 de l'ADR 0016.
10. **A1** : ordre Q-66-3, puis #602 (normalisation des fins de ligne littérales, après la relecture de XML 1.0), puis #594 respécifiée et décidée de nouveau (§ 2 d).

---

## Retour

- **Statut** : `revue requise`. L'avis est complet sur les preuves prévues, mais :
  1. il relève une affirmation inexacte de la mesure versée (constat 2, § 5) ;
  2. il fait dépendre la spécification de #594, déjà décidée (E-18/11 (#594)), d'une nouvelle décision du mainteneur ;
  3. la décision finale revient au mainteneur (temps 4).
- **Résultat** : recommandation **(a)**, ordre **(a) > (b) >> (c) >> (d)** ; aucune mesure de plus avant la décision ; conditions d'acceptation au § 6.
- **Preuves**
  - *Vérifiées* :
    - retour direct d'`openxlsx`, sans comparaison (`R/engine.R` l. 11654-11657) ;
    - D-S1-31 motivée par `openxlsx` seul (l. 10390-10396 ; `decisions-mainteneur.md` l. 74) ;
    - écarts admis consignés (`.tex` l. 5470-5516) ;
    - rapport figé sans identité du lecteur (`identite_code()`, grep sans occurrence dans `app.R` et `R/display_helpers.R`) ;
    - lots de la CI sans `openxlsx` ni `zip`, et couverture de `zip` par le job de parité (ci.yml l. 348-378) ;
    - #602 (seul écart connu où le lecteur interne a tort) ;
    - `formals(utils::unzip)$unzip == "internal"` (R 4.3.3) ;
    - identité des 42 retours et durées égales (`comparaison.txt`) ;
    - `read.xlsx.default` ne passe pas par `loadWorkbook` (source `master` d'`openxlsx`).
  - *Hypothèses* :
    - absence, hors de #602, de toute forme admise que le lecteur interne lirait mal ;
    - absence d'effet sur σ_USP, un verdict ou une p-value hors corpus ;
    - lecture de la chaîne partagée bordée de blancs, dans une cellule lue, identique à celle qu'aurait la chaîne en ligne ;
    - fonctions d'analyse d'`openxlsx` compilées ;
    - surface d'analyse accrue de `loadWorkbook()`.
  - *Non vérifiés* :
    - les comportements d'`openxlsx` du § 1 e, non remesurés ici (`openxlsx` absent de la session ; je m'appuie sur les mesures consignées) ;
    - la source à la version 4.2.5.2 ;
    - XML 1.0 § 2.10, 2.11 et 3.3.3.
- **Informations manquantes** : texte de XML 1.0 (`www.w3.org` injoignable, à autoriser dans les réglages réseau ou à lire depuis le poste) ; source d'`openxlsx` 4.2.5.2 (seul `master` a été lu).
- **Décisions non résolues** (le mainteneur) :
  - choix entre (a), (b), (c) et (d) ;
  - forme bornée ou uniforme pour #594 si `openxlsx` est retiré ;
  - correction du constat 2 de la mesure avant son versement au dossier de l'ADR ;
  - `openxlsx` gardé ou non en `Suggests`.
- **Critères déclenchés** :
  - § 4.2 : invariant de `CLAUDE.md` « Architecture » modifié ; ADR 0016 (accepté), point 6, modifié ;
  - § 4.2, contrat partagé : la sortie d'`engine_lire_xlsx()` change de type pour une colonne booléenne sur les postes munis d'`openxlsx` ; par ricochet, le contrat de #594 (argument `objet`, `app.R`) peut disparaître ;
  - § 4.3 : nouvel ADR d'architecture (déjà prévu) ;
  - § 4.1.3 : Fable d'office (déjà prévu) ;
  - **changement de résultat hors références** (liste au § 6, condition 4), sans σ_USP ni verdict attendus ;
  - **remise en cause d'une décision du mainteneur** (E-18/11 (#594)) par changement de prémisse, ce qui n'est pas un désaccord entre agents ;
  - aucun désaccord avec `audit` ;
  - validité à T = 8 : sans objet.
- **Constats hors périmètre** :
  1. Le rapport figé n'identifie ni le chemin de lecture ni la version d'`openxlsx` (`R/display_helpers.R` l. 2966). Critère : aucun (mineur), sans objet si (a) ou (b) est retenue, à réexaminer au titre de E6 si (c) est retenue.
  2. L'en-tête de la section 7ter (`R/engine.R` l. 8821-8823) justifie le choix d'`openxlsx` par « implémentation plus complète et mieux éprouvée », motif périmé depuis l'admission de S1. C'est un motif, non une affirmation fausse sur le code : critère aucun (mineur), absorbé par (a) ou (b).
- **Prochaine action recommandée** : corriger ou borner le constat 2 de `docs/revues/20261118-q66-3-lecteur-interne/README.md`, puis transmettre cet avis et la mesure à `architect-approfondi` (Fable d'office) pour l'ADR. Si (a) ou (b) est retenue, confier à `actuary` l'amendement de la spécification de #594 avant le plan d'A1, avec l'inventaire des écarts consignés en annexe de l'ADR.
