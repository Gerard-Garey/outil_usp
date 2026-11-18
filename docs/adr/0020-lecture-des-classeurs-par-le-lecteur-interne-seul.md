---
status: accepted
date: 2026-11-18
---

# Un classeur `.xlsx` est lu par le seul lecteur interne du moteur ; `openxlsx` sort de `R/engine.R` et ne reste qu'un témoin de test borné ; son comportement ne motive plus aucune règle nouvelle

> *Rédigé par l'agent architect (IA), fiche `architect-approfondi`, Fable d'office pour un ADR d'architecture (`docs/agents/routage.md`, § 3 et § 4.1.3 ; compteur de la période hors branche ouverte par le soixante-huitième point : 1 sur 3 ; modèle annoncé par l'environnement de la consultation : `claude-fable-5-2`), le 18/11/2026, hors branche, sur `main` `c013568`. Troisième temps de Q-67-7 (a) (`docs/feuille-de-route.md`, § 5, « Examen de Q-66-3 »). **Statut : accepté le 18/11/2026** (rubrique « Acceptation » ; d'abord proposé, questions Q-68-3 à Q-68-10). Les numéros de ligne de `R/engine.R`, du `.tex` et de `ci.yml` sont ceux de `c013568`. Aucun fichier de code, de test ni de documentation n'est modifié par cette proposition.*

## Contexte

**L'état du code** (*vérifié*, lecture de `R/engine.R`). `engine_lire_xlsx()` (l. 11643) fait deux choses :

1. elle appelle `.xlsx_admettre()` (l. 11293), contrôle unique du contrat fermé du lecteur de classeur (règles R0 à R12, #574, décision D-S1-1). Ce contrôle extrait l'archive, analyse la feuille lue cellule par cellule avec les briques du lecteur interne (`.xlsx_cellules()`, `.xlsx_controler_*()`), et refuse par `usp_refus_lecture` tout classeur hors du contrat ;
2. puis, **si le paquet `openxlsx` est installé**, elle rend directement `openxlsx::read.xlsx(chemin, …)` (l. 11654-11657) ; sinon elle assemble le `data.frame` à partir des cellules déjà analysées par l'admission (l. 11658-11721).

Le choix entre les deux lectures n'est fait ni par l'appelant ni par un argument : c'est la présence du paquet sur le poste qui le fait. Aucune comparaison n'a lieu à l'exécution, et le rapport figé ne dit pas quelle lecture a servi (`identite_code()` relève la version, le md5 de `R/engine.R`, celui du chargeur et le relevé ; `app.R` et `R/display_helpers.R` ne contiennent aucune occurrence d'`openxlsx` ; *vérifié*, `grep`).

**Le motif d'origine est périmé.** L'en-tête de la section 7ter (l. 8821-8823) justifie la priorité donnée à `openxlsx` par une « implementation plus complete et mieux eprouvee », le lecteur interne étant « un repli, non un remplacement ». Ce motif date d'avant S1. Depuis S1, l'admission précède `openxlsx` : celui-ci ne relit que des classeurs que le lecteur interne a déjà analysés en entier, et tout classeur refusé l'est sur les deux chemins.

**Ce que la double lecture a coûté** (*vérifié*, feuille de route et issues) :

- chaque écart mesuré entre les deux interprètes est devenu une issue ou un lot : #572, #579, lots G et H de #574, #594, #595 ; #558 a dû garder une seconde décompression de l'archive (Q-66-2) ;
- des règles d'admission ont pour motif consigné, dans les commentaires du code, d'empêcher `openxlsx` de lire autre chose que le lecteur interne : désignation de la feuille lue (`.xlsx_controler_relations()`, `.xlsx_controler_designation()`, `.xlsx_controler_balises_relation()` ; décisions D-S1-37 à D-S1-39), ordre de lecture (R6b), `<t>` à attribut d'une chaîne en ligne (D-S1-31) ;
- emprise relevée par `grep -c openxlsx` à `c013568` : 204 occurrences dans `R/engine.R` pour **un seul embranchement de code**, 226 dans `tests/unitaires/test_controles_entree.R`, 14 dans `test_outdec.R`, 74 dans le `.tex`, 14 dans `ci.yml`, 4 dans le README, une dans `DESCRIPTION` et une dans `CLAUDE.md`.

Pour une évolution typique du lecteur (une règle d'admission, une forme de cellule), il faut aujourd'hui toucher six endroits : la règle ; sa mesure sous deux versions d'`openxlsx` (4.2.5.2 en CI, 4.2.9 sur le poste) ; un test joué sur les deux chemins, par substitution de `requireNamespace` dans l'environnement du moteur et lignes « [saute] » ; le job de parité ; le paragraphe « Écarts qui subsistent entre les deux chemins » du `.tex` (l. 5470-5516) ; l'en-tête d'`engine_lire_xlsx()`.

**La mesure** (premier temps de Q-67-7 (a) ; `docs/revues/20261118-q66-3-lecteur-interne/README.md` et `comparaison.txt` ; *vérifiée* par la session, relue ici). Sur 42 classeurs (36 versés d'openpyxl, pandas et XlsxWriter ; 6 écrits par l'écrivain interne et par `openxlsx::write.xlsx()`), sous Linux, `C.UTF-8`, `openxlsx` 4.2.5.2 :

- le retour d'`engine_lire_xlsx()` est identique au bit près sur les deux chemins, 42 fois sur 42 (29 lus, 13 refusés avec le même message) ;
- le retour du lecteur aval (`engine_lire_donnees_csv()` ou `engine_lire_triangle()`) l'est aussi, 42 fois sur 42 ;
- les durées sont égales à la précision de la mesure (2,97 s contre 2,97 s pour 5 000 lignes) : c'est l'admission qui coûte.

C'est un comportement observé sur un corpus fini, non une preuve d'équivalence. Excel et LibreOffice ne sont pas couverts (décision E-18/11 (corpus)).

**L'avis d'`actuary`** (deuxième temps ; `docs/revues/20261118-q66-3-lecteur-interne/actuary-avis.md`). Ordre **(a) > (b) >> (c) >> (d)**, sans mesure de plus avant la décision. Quatre constats portent la conclusion :

- la parité ne vaut pas sur tout le domaine admis. Le `.tex` (l. 5482-5495) et l'en-tête d'`engine_lire_xlsx()` consignent des formes **admises** que le lecteur interne lit juste et devant lesquelles `openxlsx` s'arrête sur une erreur R : balises `<sheet>` et `<Relationship>` préfixées, attributs entre apostrophes, cible `./worksheets/…`, seconde entrée de même nom dans un autre dossier. Un même classeur admis peut donc être lu sur un poste et refusé sur un autre ;
- deux versions d'`openxlsx` sont déjà en service, avec des comportements propres consignés ; un relecteur peut en avoir une troisième, non mesurée ;
- le lecteur interne est déjà un lecteur de production : c'est celui de tout poste sans `openxlsx`, et le seul qu'exercent les trois lots de la CI (`ci.yml`, l. 349-353). Sa justesse doit être établie quoi qu'on décide ;
- le seul écart connu où le lecteur interne a tort est #602 (fins de ligne `\r\n` non normalisées). Qu'il soit le seul est une *hypothèse*, à confirmer par un inventaire (condition 10).

**Les décisions qui reposent sur la double lecture.** D-S1-31 refuse une chaîne en ligne dont la balise `<t>` porte un attribut, au seul motif qu'`openxlsx` garde l'attribut dans le texte lu (commentaire l. 10393-10400). E-18/11 (#594) a retenu pour #594 l'option (b) bornée, dont toutes les bornes viennent de la parité. E-18/11 (corpus) consigne comme limite le confinement de la lecture fausse d'`openxlsx` à sa cellule.

**Le problème de forme.** `engine_lire_xlsx()` est une interface à deux adaptateurs derrière une couture (`requireNamespace("openxlsx")`) que l'environnement choisit. Depuis S1, le second adaptateur n'apporte aucune variation voulue du comportement : le **test de suppression** (fiche S4, « Forme ») montre que le retirer fait disparaître la complexité sans la reporter sur un appelant. Il ne reste alors de la lecture, après l'admission, qu'un assemblage d'une soixantaine de lignes, commentaires compris, sur des cellules déjà analysées.

## Décision

### 1. Un seul lecteur de production

`engine_lire_xlsx(chemin, entete = TRUE)` lit tout classeur par l'admission puis par l'assemblage interne. Les lignes 11652 à 11657 (le commentaire et l'embranchement) sont retirées. La signature ne change pas ; le retour est celui du chemin interne d'aujourd'hui, à l'identique. Après le commit, ni `R/` ni `app.R` n'appellent `openxlsx` : hors commentaires, la seule occurrence du mot qui reste dans `R/engine.R` est le message d'`engine_ecrire_xlsx()` cité plus bas (aujourd'hui trois lignes hors commentaires : l. 9076, 11654 et 11655 ; *vérifié*, `grep`).

La lecture d'un classeur ne dépend plus que du code versionné de `R/engine.R` et de R. `docs/exigences.md` § 4.1 (« préparation et transformation des données » dans le fichier unique, « pour permettre une revue indépendante ») est tenu sans exception pour la lecture.

### 2. Le commit du retrait ne change aucune autre règle

Aucune règle d'admission n'est ajoutée, retirée ni assouplie dans le même commit. Les règles nées de la parité restent, à l'identique, et deviennent des règles propres du lecteur interne et du contrat fermé :

- blancs d'en-tête retirés et ramenés à une espace (`.xlsx_blancs_entete()`, l. 11255) ;
- cellule booléenne rendue `"TRUE"` ou `"FALSE"`, colonne en caractères ;
- en-têtes gardés tels quels, doublons compris ;
- tableau dimensionné sur les seules cellules à valeur ;
- désignation de la feuille lue (D-S1-37 à D-S1-39), ordre de lecture (R6b), référence en minuscules (D-S1-9), `<t>` à attribut d'une chaîne en ligne (D-S1-31).

Leur motif s'écrit désormais sans le présent de la double lecture : « forme que l'outil ne lit pas de façon sûre » (aucun écrivain connu ne la produit, ou un lecteur répandu la lit autrement, mesure à l'appui). Les textes de refus du moteur ne nomment pas `openxlsx` (*vérifié*, `grep` hors commentaires) : aucun ne change.

Assouplir l'une de ces règles est une décision distincte, avec son issue, l'avis d'`actuary` et le visa du mainteneur, puisqu'un classeur refusé deviendrait lu. La première est #594 (rubrique « Conséquences »). Aucune autre n'est proposée ici.

### 3. `openxlsx` est un témoin de test borné

Le mot « oracle » ne convient pas : sur le domaine admis, `openxlsx` a des lectures fausses mesurées. Le terme retenu est **témoin** (avis d'`actuary`, § 3).

**Lieu.** `tests/` seulement. Le test appelle `openxlsx` directement, par une seule aide de test qui fixe les options de l'appel retiré (`colNames`, `skipEmptyRows = FALSE`, `skipEmptyCols = FALSE`, `na.strings = character(0)`, `sep.names = " "`). Le moteur n'en sait plus rien.

**Objet : trois emplois, liste fermée.**

1. **Lecture du corpus naturel.** Des classeurs écrits par de vrais écrivains (écrivain interne, `openxlsx::write.xlsx()`, et le corpus versé d'openpyxl, pandas et XlsxWriter si Q-68-9 (a)) sont lus par le lecteur interne et par le témoin. La comparaison porte sur les valeurs employées : sortie d'`engine_lire_donnees_csv()` ou d'`engine_lire_triangle()`.
2. **Témoin de l'écrivain.** Ce qu'écrit `engine_ecrire_xlsx()` est relu par `openxlsx` (valeurs, noms de feuille ; tests existants de #488 et #580). C'est le seul lecteur OOXML tiers de la batterie, puisqu'il n'y a pas de corpus Excel ni LibreOffice : un aller-retour écrivain interne → lecteur interne ne prouve que la cohérence de l'outil avec lui-même.
3. **Absence.** Dans un processus R neuf où `openxlsx` est installé, `engine_lire_xlsx()` ne charge pas son espace de noms (`loadedNamespaces()`).

**Hors du témoin : le XML forgé.** Un test sur un classeur forgé est un test du seul lecteur interne, à valeur attendue explicite (valeur lue, ou texte du refus). Une assertion « même résultat qu'`openxlsx` » sur un classeur forgé est convertie en valeur attendue explicite, ou retirée avec son motif.

**Règle de lecture d'un écart.** Le critère bloquant est l'accord du lecteur interne avec la **source** (le CSV de `tests/donnees/`, ou la valeur écrite). Un écart du témoin sur le corpus naturel s'instruit contre la source :

- si le lecteur interne a tort, c'est un problème marquant au sens de l'ADR 0018 (valeur lue fausse) ;
- si `openxlsx` a tort, l'écart prend une ligne dans la liste fermée des écarts attendus du test, datée de la version, sans règle dans le moteur et sans issue.

**Le comportement d'`openxlsx` ne motive plus aucune règle d'admission nouvelle.** Une règle nouvelle se justifie par le contrat (forme que le lecteur interne ne lit pas de façon sûre) ou par un écrivain réel.

**Entretien et sortie.** Le témoin est du code de test (`coder`) et un paquet du job de CI (commit `repo:`). Il est jugé en CI, sous la version de l'instantané (4.2.5.2). Il peut être retiré plus tard par une annotation du présent ADR et un commit `tests:` et `repo:`, sans toucher au moteur ; l'inverse (le rétablir après un retrait complet) coûterait davantage.

### 4. Le job de CI reste, rebaptisé

Le job « Parité des lecteurs de classeur » (`ci.yml`, l. 383) devient le job du témoin et de l'archive. Il garde :

- `openxlsx` 4.2.5.2 **et `zip` 2.3.1**, avec le contrôle bloquant des versions ;
- les quatre fichiers : `test_controles_entree.R`, `test_outdec.R`, `test_defauts_connus.R` (voie « paquet » de `zip`) et `test_application.R` (export xlsx de l'application par `zip::zipr()`) ;
- le critère « aucune ligne [saute] » ;
- sa place dans l'agrégat `tests-moteur` (l. 523-534), qui est le contrôle requis.

Il gagne l'emploi 3 du témoin (absence). La couverture de `zip::zipr()` (#488) et de l'export de l'application ne dépend pas d'`openxlsx` : elle resterait à l'identique sous un retrait complet. Les trois lots restent sans ces deux paquets ; ils exercent le lecteur interne, qui n'est plus un repli, et `utils::zip()`.

### 5. Aucune trace nouvelle dans le résultat

Avec un seul lecteur, le md5 de `R/engine.R` et la version de R, déjà au rapport figé, identifient le lecteur. Aucun champ n'est ajouté à l'objet `usp_engine`. Restent hors de cette identité, à consigner au `.tex` : la méthode interne d'`utils::unzip()`, les moteurs d'expressions régulières de R, et la locale, qui fixe la classe `[[:space:]]` des blancs d'en-tête (limite déjà consignée, non mesurée sous Windows).

### 6. Portée de l'invariant « Architecture » de `CLAUDE.md`

L'invariant est **renforcé**, non déplacé : la lecture rejoint l'écriture, déjà interne depuis #488. Texte proposé pour la troisième puce de « Architecture (contrainte impérative) », à porter par un commit `claude:` sur instruction du mainteneur (Q-68-8) :

> - Lecture et écriture xlsx par le lecteur et l'écrivain internes seuls (ADR 0020 ; nombres relus au bit, #488) : aucun fichier de `R/` ni `app.R` n'appelle `openxlsx`, qui n'est qu'un témoin de test borné, dans `tests/`. Seule exception : l'archive est compressée par le paquet `zip` s'il est installé, sinon par `utils::zip()` ; les calculs n'en dépendent pas. **Ne jamais éclater le moteur en plusieurs fichiers.**

La puce qui précède (« sans dépendance obligatoire hors R base + stats ») ne change pas. `docs/exigences.md` ne cite ni `openxlsx` ni les classeurs (*vérifié*, `grep`) : aucun amendement.

### 7. Annotation de l'ADR 0016, point 6

L'ADR 0016 n'est pas contredit : sa décision (chargeur unique, environnement dédié) ne change pas. Son point 6 (« `openxlsx` reste une dépendance facultative, appelée par `requireNamespace()` puis `openxlsx::` […] avec le repli interne ») devient sans objet. Annotation proposée, **faite au commit du retrait** et non tant que le présent ADR n'est que proposé (précédent : ADR 0003 annoté au commit de #200) :

> *Annotation (ADR 0020).* `openxlsx` n'est plus appelé par le moteur. Le point 6, et la mention d'`openxlsx::` dans l'inventaire des noms et au point 2, sont sans objet pour la lecture. `zip` est la seule dépendance facultative encore appelée par `requireNamespace()` puis `zip::` (`engine_ecrire_xlsx()`) ; la substitution de test de `requireNamespace` dans `environment(run_engine)` ne sert plus que pour elle.

## Options écartées

- **(b) Retrait complet d'`openxlsx`, tests compris.** Presque aussi bonne sur le fond (avis d'`actuary`). Écartée pour trois raisons de forme. (i) Le job de CI reste de toute façon, pour `zip::zipr()` et l'export de l'application : l'économie se réduit à un paquet de plus dans un instantané déjà en cache et à une suite de test bornée. (ii) Elle retire le seul lecteur OOXML tiers qui relise ce qu'écrit l'écrivain interne, alors qu'il n'y a pas de corpus Excel ni LibreOffice. (iii) Le chemin de (a) vers (b) est court et sans effet sur le moteur ; le chemin inverse ne l'est pas. Elle reste le second choix.
- **(c) Statu quo.** Deux lectures possibles, choisies par le poste et non tracées ; classeurs admis lus ici et arrêtés là sur une erreur R ; double justification au dossier ; issues de parité récurrentes.
- **(d) `openxlsx::loadWorkbook(dossier, isUnzipped = TRUE)`.** Elle ne lève que la seconde décompression, qui pèse 0,1 % à 4,5 % de la lecture (mesure de #558). Elle garde les deux interprètes et remplace celui dont la parité est mesurée (`read.xlsx.default()`) par un autre (`read.xlsx.Workbook()`), sur lequel aucune mesure n'existe : tout le capital de mesures serait à refaire. Non mesurée.
- **(e) Contrôle croisé à l'exécution** (lire par les deux, comparer, refuser ou avertir en cas d'écart). Le comparant a des lectures fausses mesurées sur le domaine admis : il faudrait loger dans le fichier quantitatif la liste de ses défauts, version par version. Le comportement dépendrait toujours du poste (contrôle présent ou absent).
- **(f) Un argument explicite `lecteur = c("interne", "openxlsx")`.** Il rendrait la couture visible et traçable, mais garderait dans le moteur le second adaptateur et toute la dette de parité, pour un choix qu'aucun appelant ne demande ; le témoin de test rend le même service sans une ligne dans `R/engine.R`.
- **(g) `openxlsx` (ou un autre paquet, `readxl`) obligatoire et seul lecteur.** Contraire à l'autonomie du moteur (`docs/exigences.md` § 4.2 ; trois lots de CI sans paquet) ; la lecture sortirait du fichier revu ; l'admission, écrite avec les briques du lecteur interne, resterait de toute façon. Aucune mesure sur `readxl`.
- **(h) Témoin hors CI** (script lancé à la main, sur le modèle de `tests/unitaires/generer_valeurs_externes.R`). Un contrôle qui ne tourne pas se périme ; le job existe déjà.
- **(i) Assouplir dans le même commit les règles nées de la parité.** Elle mêlerait un retrait sans effet sur les valeurs, prouvable par `identical()`, à des classeurs refusés devenant lus, qui demandent chacun un avis et un visa.

## Conséquences

- **Résultats.** Les six références sont inchangées (`run_engine()` n'est pas touché). Sur un poste **sans** `openxlsx`, rien ne change. Sur un poste **muni** d'`openxlsx`, changent, hors références :
  - les formes admises du « Contexte », lues au lieu d'une erreur R ;
  - une colonne entièrement booléenne, rendue en caractères et non plus en logique, avec le même refus en aval ;
  - des textes de colonnes non employées (`&amp;lt;1` rendu `&lt;1` et non `<1` ; `true` gardé tel quel) ;
  - sous Windows, un texte à saut de ligne écrit par l'outil, relu `\r\n` tant que #602 n'est pas corrigé.

  Aucun σ_USP, aucun verdict ni aucune p-value ne sont attendus changés : *vérifié* sur le corpus mesuré, *hypothèse* au-delà.
- **Limite nouvelle à dire.** Sur un poste muni d'`openxlsx`, un classeur écrit par Excel ou LibreOffice est aujourd'hui lu par `openxlsx` ; il le sera par le lecteur interne, qui n'est mesuré sur aucun classeur de ces deux écrivains (E-18/11 (corpus)). L'admission, commune, refuse déjà ce qui sort du contrat, et l'application affiche les données lues avant tout calcul ; l'absence de valeur lue fausse sur ces écrivains reste une *hypothèse*. D'où la condition 11.
- **Contrat partagé** (`docs/agents/routage.md`, § 4.2). La signature d'`engine_lire_xlsx()` ne change pas ; son retour change sur les postes munis d'`openxlsx` pour les cas ci-dessus. `app.R` n'est pas modifié.
- **Code.** Un embranchement retiré ; en-têtes de la section 7ter, d'`engine_lire_xlsx()` et d'`.xlsx_admettre()` (« avant les deux adaptateurs ») réécrits ; les mesures d'`openxlsx` gardées en commentaire le sont comme motifs datés, non comme description du code. Le message d'`engine_ecrire_xlsx()` « installer le paquet zip, ou openxlsx qui l'importe » (l. 9074-9076) reste exact et n'est pas touché.
- **Tests.** `test_controles_entree.R` (226 occurrences, 26 emplois d'`avec_openxlsx…`, 606 `verifier()`) et `test_outdec.R` sont repris selon le point 3. La substitution de `requireNamespace` ne sert plus pour la lecture.
- **CI.** Point 4. Les commentaires du job (l. 348-382) sont repris.
- **`.tex`** (`docwriter`, passage unique en fin de branche, règle 9) : 74 occurrences d'`openxlsx`, 29 de « deux chemins », 22 de « voie de repli ». Un seul lecteur ; le paragraphe « Écarts qui subsistent entre les deux chemins » devient la description du lecteur unique et de ses limites ; les lectures fausses d'`openxlsx` mesurées peuvent rester comme motif d'une règle du contrat ; l'histoire de la parité va dans `docs/suivi-documentation/`, sous le `\label` d'origine ; index des fonctions : `engine_lire_xlsx()`.
- **README** (« Prérequis », l. 28-44) et **`DESCRIPTION`** (`Suggests`, Q-68-5). La concordance ne dépend pas de `Suggests` pour `openxlsx` : le `.tex` ne le cite que sous forme qualifiée (*vérifié*, `tests/concordance_doc_moteur.R` l. 355-381 et `grep`).
- **`CLAUDE.md`** : point 6. **ADR 0016** : point 7. **ADR 0004** : inchangé (dossier temporaire propre à l'appel). **`CONTEXT.md`** : à l'acceptation, `architect` ajoute « Lecteur interne de classeur » et « Témoin `openxlsx` », et range « voie de repli », « chemin `openxlsx` » et « parité des lecteurs » parmi les termes à éviter.
- **#558.** La seconde décompression disparaît avec l'appel ; la piste `loadWorkbook()` (reliquat de S4) est close.
- **#594, D-S1-31 et E-18/11 (#594).** D-S1-31 perd toute sa prémisse. L'option (b) bornée n'est plus fausse, mais ses bornes (séries seules, cellules non lues, texte non blanc) n'ont plus de motif, alors que la forme partagée `<si><t xml:space="preserve">` est déjà admise partout. La règle cohérente devient l'admission uniforme de la forme exacte `<t xml:space="preserve">` en chaîne en ligne ; elle supprime l'argument `objet` d'`engine_lire_xlsx()` et la modification d'`app.R`, donc le contrat partagé que #594 introduisait, et `app-review` sort de son circuit. E-18/11 (#594) est à rouvrir par le mainteneur, sur une spécification amendée par `actuary` (Q-68-4). La limite de E-18/11 (corpus) sur le confinement de la lecture fausse est sans objet ; l'absence de corpus Excel et LibreOffice reste une limite, sous la forme dite plus haut.
- **#602.** Le critère « deux lectures d'un même classeur » tombe ; le défaut reste, et le retrait l'expose à tous les postes sous Windows. #602 est donc corrigée **dans la même branche** que le retrait, après lui : sa correction se spécifie alors contre XML 1.0, sur un seul chemin.
- **#603.** Sans effet (écrivain, chemin de sortie).
- **A1.** Une issue de mise en œuvre s'ajoute (rédigée dans la feuille de route, créée sur accord) : A1 compte quatre numéros, sous le plafond de cinq (ADR 0007, annotation du 10/11/2026). Ordre : ADR et retrait, puis #602, puis #603, puis #594 respécifiée. Circuit du retrait : avis amont d'`actuary` rendu (temps 2) → `coder-approfondi` d'office (contrat partagé et invariant, `docs/agents/routage.md` § 10) → `audit` → `docwriter` en fin de branche → validation d'`actuary`. `app-review` et `regulatory` ne sont pas déclenchés.

## Conditions d'acceptation

Les dix conditions d'`actuary` (avis, § 6), reprises et complétées :

1. **Code.** L'embranchement est retiré sans autre changement de comportement ; `grep -n openxlsx R/engine.R | grep -v '^[0-9]*:\s*#'` ne rend plus que la ligne du message d'`engine_ecrire_xlsx()`, et `grep -c openxlsx app.R R/display_helpers.R R/charger_moteur.R` reste à 0 ; les trois en-têtes sont réécrits.
2. **Preuve de non-changement.** `lire_corpus.R` rejoué **avec `openxlsx` installé** rend un objet `identical()` à `interne.rds` sur les 42 classeurs ; l'emploi 3 du témoin est en place dans le job.
3. **Références.** Volet `identical()` vert ; `comparer_references.R --seuil 0` sans écart ; `concordance_doc_moteur.R --strict` à 0 (skill `verifier-reproductibilite`).
4. **Tableau « hors références »** joint à la PR, sur la liste de la rubrique « Conséquences ».
5. **Tests.** Chaque assertion de parité est convertie (valeur attendue explicite), déplacée dans la suite témoin, ou retirée avec son motif ; le rapport de `coder` donne le compte des `verifier()` avant et après, et la liste des assertions retirées. Aucune n'est perdue sans trace.
6. **CI.** Point 4 ; aucune ligne « [saute] » dans le job ; dans les trois lots, seules les lignes du témoin et de la voie « paquet » de `zip` sautent.
7. **`.tex`**, **README**, **`DESCRIPTION`** alignés (`docwriter` pour le `.tex`).
8. **`CLAUDE.md`** (sur instruction du mainteneur), **ADR 0016** annoté, **`CONTEXT.md`** complété.
9. **Liste fermée des écarts attendus du témoin**, datée de la version d'`openxlsx`, dans le test.
10. **Inventaire des écarts consignés** entre les deux chemins (`.tex` l. 5470-5516, en-têtes du code, tests), classés selon le lecteur qui a raison, par `actuary`, versé dans `docs/revues/`. Un écart où le lecteur interne a tort, hors #602, est un problème marquant (ADR 0018).
11. **Recette sur le poste, avant la fusion** : si le mainteneur dispose de classeurs écrits par Excel ou LibreOffice (données réelles non versionnées comprises), ils sont lus par les deux chemins au SHA qui précède le retrait, sorties aval comparées par `identical()` ; à défaut, la limite est consignée au `.tex` (Q-68-10).
12. **#602 corrigée dans la même fusion**, après relecture à la source de XML 1.0 pour la piste de normalisation.

Les conditions 10 à 12 sont des conditions de la fusion, non des préalables à la décision.

## Renvois

- Q-66-3, Q-67-7 et « Examen de Q-66-3 » (`docs/feuille-de-route.md`, § 5) ; fiche S4, « Forme » ; décisions E-18/11 (#594) et E-18/11 (corpus) (§ 4).
- `docs/revues/20261118-q66-3-lecteur-interne/` : `README.md`, `comparaison.txt`, `actuary-avis.md`.
- `docs/revues/20261118-js1-poste-windows/mesure-594/README.md` ; `docs/revues/20261115-s1-rejeu/decisions-mainteneur.md` (D-S1-1, D-S1-9, D-S1-31, D-S1-34, D-S1-37 à D-S1-39).
- Issues #594, #602, #603 ; #558, #572, #574, #579, #595 (dette de parité) ; #488 (écrivain interne).
- ADR 0004, ADR 0007 (annotation du 10/11/2026), ADR 0016 (point 6), ADR 0018.

## Acceptation

**Accepté** par le mainteneur le 18/11/2026, tel que proposé (Q-68-3 (a) : lecteur interne seul en production, `openxlsx` témoin de test borné), avec les décisions qui l'accompagnent, toutes selon la recommandation (a) :

- **Q-68-4 (a)** : E-18/11 (#594) **rouverte** ; admission uniforme de la forme exacte `<t xml:space="preserve">` en chaîne en ligne, sur une spécification amendée par `actuary`, puis décision du mainteneur **avant le codage** de #594 ;
- **Q-68-5 (a)** : `openxlsx` gardé dans `Suggests` de `DESCRIPTION`, pour les tests seulement ;
- **Q-68-6 (a)** : inventaire des écarts consignés entre les deux chemins par `actuary` à l'étape 1 d'A1, versé dans `docs/revues/` avant le commit du retrait (condition 10) ; XML 1.0 relu depuis le poste, préalable de la seule piste de normalisation de #602 (condition 12) ;
- **Q-68-7 (a)** : présent ADR passé à `accepted` dans le premier commit `docs:` d'A1 ; issue de mise en œuvre créée ; ordre d'A1 : ADR, issue de mise en œuvre, #602, #603, #594 ;
- **Q-68-8 (a)** : instruction du mainteneur pour un commit `claude:` de `CLAUDE.md` « Architecture » dans A1 (texte du point 6), poussé avec le commit du retrait ; annotation de l'ADR 0016 (point 7) au même moment ;
- **Q-68-9 (a)** : corpus du témoin (classeurs versés d'openpyxl, de pandas et de XlsxWriter) copié dans `tests/donnees/classeurs/`, avec ses md5 ;
- **Q-68-10 (a)** : recette sur le poste avant la fusion d'A1 si le mainteneur dispose de classeurs écrits par Excel ou LibreOffice (condition 11) ; sinon, limite consignée au `.tex`.

Également décidés le même jour : Q-68-1 (a) (#594 passe à `ready-for-agent` au point d'étape qui planifie A1) et Q-68-2 (a) (`TEXTE_REFUS_R3` maintenu écarté ; le plan d'A1 décide, sur avis d'`actuary`, s'il est repris dans #594) ; ouverture d'A1 (`claude/creneau-a1`, partie de `main` `c013568`). Les entrées « Lecteur interne de classeur » et « Témoin `openxlsx` » de `CONTEXT.md` sont écrites à l'acceptation (rubrique « Conséquences »).

Source : réponses du mainteneur à la session principale, 18/11/2026 ; consignées au § 4 de `docs/feuille-de-route.md` (E-18/11 (Q-68)) par `architect` au soixante-neuvième point d'étape, qui porte aussi le plan d'A1 (§ 3).
