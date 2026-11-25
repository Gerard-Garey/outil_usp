# JS2 : visa ciblé du diff du `.tex` après l'étape 7 (`e04e8a3..886de47`)

> Rapport d'`actuary-approfondi` (IA), versé intégralement par la session principale (Q-54-10). Saisi selon la décision (ii) du mainteneur au point d'arrêt PJ-3 (E-25/11 (JS2, PJ-3)). L'agent n'a rien écrit, ni dans le dépôt ni sur GitHub.

*Rédigé par l'agent `actuary` (IA), le 25/11/2026. J'ai seulement lu `claude/jalon-js2` à la tête `886de47`, dont l'arbre est propre pour `docs/`.*

## Verdict : **visa**

Je ne relève ni bloquant ni majeur. Il n'y a donc aucun texte de remplacement à exiger. Cinq mineurs sont écartés (ADR 0018), en fin de rapport.

**Périmètre.** J'ai lu en entier `git diff e04e8a3..886de47 -- docs/latex/ docs/suivi-documentation/IV.md` :
- `doc_tests_usp.tex` : préambule, introduction de la partie III (l. 10597-10611) et `sec:biblio` (l. 21657-21692) ;
- `CONVENTIONS.md` : E4 et E11 ;
- `IV.md` : trois entrées.

J'ai confronté ce diff aux pièces suivantes :
- `etape-4b-sources.md` ;
- `regulatory-pj3-avis-acpr.md` ;
- la ligne E-25/11 (JS2, PJ-3) de `docs/feuille-de-route.md` (l. 5022) ;
- le texte anglais d'EIOPA-BoS-25/249, téléchargé le 25/11/2026 depuis la page de l'AEAPP : PDF de 5 pages, créé le 14/10/2025, md5 `2f207b21d959e284cafa48fb7b6d9c27`.

## 1. Point 5 (introduction de la partie III, l. 10607-10610) : exact, utile, ne tranche aucune lecture

**Exact.**
- Le § 6 d'EIOPA-BoS-25/249 dit mot pour mot : « The Guidelines repeal and replace the Guidelines on undertaking-specific parameters (EIOPA-BoS-14-178) ». Je l'ai vérifié sur le PDF.
- L'abrogation suit l'applicabilité. La page de l'AEAPP, relue le 25/11 par WebFetch, dit en effet « Until then, the Guidelines issued in 2015 are applicable ». La condition « une fois […] applicables » est donc la bonne.
- Le rattachement du § 171 à l'orientation 6 vient de l'entrée de la notice dans `sec:biblio` (l. 21651-21652, « au titre de l'orientation~6 »). Cette entrée est hors du diff, déjà visée, et je ne l'ai pas relue sur la notice.
- La précision « (l'orientation~6 de 2015) » est nécessaire, et pas seulement exacte. Dans le texte de 2025, la **Guideline 6** est « Remedial of non-compliance » (§ 16, vérifié). Sans cette précision, un lecteur pourrait rattacher le § 171 à la nouvelle orientation 6. La conformité continue est désormais la Guideline 5 (§§ 13-15, vérifiés) : suivi dans l'ORSA, sans tests statistiques ni périodicité.
- « l'exigence reste celle de la notice tant que celle-ci n'est pas révisée » constate un texte. Le § 171 de la notice (version du 17/07/2023) n'a pas changé. L'avis de l'ACPR ne dit rien de la notice (texte intégral au § 2 d'`etape-4b-sources.md`). Rien, dans les pièces, n'établit que le § 171 tombe avec l'orientation à laquelle il renvoie. La phrase n'affirme pas non plus de force juridique propre à la notice.

**Utile pour le dossier.**
- Elle prévient une objection prévisible d'un relecteur : les tests annuels de l'outil reposeraient sur une orientation abrogée.
- Elle situe l'exigence de tests annuels dans la notice, sous les deux versions des orientations. Le rôle de la batterie de tests reste donc inchangé.
- Elle est sans effet sur une statistique, une p-value, un verdict ou σ_USP, conformément au § 3 de `regulatory`.

**Ne tranche aucune lecture.**
- « une fois […] applicables » ne porte ni date ni moment.
- Sous L2, la condition peut être déjà remplie. Sous L1 et L3, elle peut l'être ou non. Le texte reste vrai dans les trois cas.
- La conséquence énoncée (la notice tient tant qu'elle n'est pas révisée) est la même sous L1, L2 et L3.

## 2. « la date d'application reste non établie par les sources consultées » : juste sous L1, L2 et L3

- **L1** (la date dépend de la publication de toutes les traductions, plus deux mois) : les traductions ne sont pas datées (« AI induced translations », § 1 de `regulatory`), et la page n'a pas bougé depuis le 08/09/2026. Rapprocher le délai de deux mois du § 29 des orientations (confirmation des autorités « within two months after the issuance of the translated versions ») reste une inférence. **Juste.**
- **L3** (la phrase de l'AEAPP tient tant que la page n'est pas mise à jour) : mêmes faits, plus la phrase « Until then » maintenue. **Juste.**
- **L2** (la date est celle de l'avis de l'ACPR) : ni la date de la déclaration ni celle de la première mise en ligne ne sont établies. On a seulement le fichier, daté du 10/11, et la mise à jour affichée du 12/11 (§ 1 de `regulatory`). Le `.tex` le dit lui-même à la l. 21690. La date reste donc non établie sous L2 aussi ; seule une borne supérieure, la date affichée, en ressort. Le texte ne nie pas cette borne et la donne par `sec:biblio`. **Juste.**
- Ce qui précède la formule expose les appuis des deux camps sans choisir :
  - la phrase de l'AEAPP pour L1 et L3 ;
  - « les dit applicables aux organismes » pour L2.
- La règle « version en vigueur à la date de référence du calcul » reste neutre.

**Observation pour le mainteneur, à verser au dossier des lectures, sans effet sur ce visa.** La formule de l'avis « sont applicables aux organismes d'assurance et de réassurance » reprend le § 4 des orientations (« The Guidelines 1 to 9 are applicable for both individual insurance and reinsurance undertakings »). Elle peut donc se lire comme une indication de **portée** (à qui s'appliquent les orientations) plutôt que de **date** (à partir de quand). Cela affaiblit l'appui textuel de L2 sans le supprimer. La paraphrase du `.tex` garde la même ambiguïté, ce qui est correct.

## 3. Bibliographie : rien au-delà des pièces

- **EIOPA-BoS-14/178** (l. 21659-21661) :
  - « conforme selon la notice (§~2) » : exact (point 3 de `regulatory`) ;
  - « sa conformité aux orientations EIOPA-BoS-25/249 est déclarée par l'avis » : exact (texte de l'avis).
- **EIOPA-BoS-25/249** (l. 21671-21673) :
  - « Date de cette publication non établie au \dateconsultation{} » : exact ;
  - « l'avis […] n'en fixe pas » : exact pour la date de publication des traductions comme pour la date d'application (voir m2).
- **Nouvelle entrée de l'avis** (l. 21675-21691). Chaque élément a sa pièce :
  - titre : `etape-4b`, l. 21, et `regulatory`, § 1 ;
  - « registre officiel » ;
  - deux URL, identiques au relevé ;
  - « mise à jour affichée du 12.11.2026 » ;
  - « PDF d'une page », « non daté dans son corps » ;
  - « fichier daté du 10.11.2026 par son nom et ses métadonnées » : `CreationDate` relevée par `regulatory`, nom du fichier relevé par la session ;
  - « consultés le \dateconsultation{} » : 18:53:26 et 18:54:15 UTC ;
  - portée : paraphrase fidèle du texte intégral, sans guillemets, avec article 16 du règlement (UE) n° 1094/2010 ;
  - « ne fixe aucune date d'application et ne dit rien des orientations EIOPA-BoS-14/178 ni de la notice » : conforme au texte intégral ;
  - « ni la date de la déclaration ni celle de la première mise en ligne ne sont établies » : `regulatory`, § 1 ;
  - « Relu sur la page et sur le PDF » : la session a relu le texte, `regulatory` le rendu graphique. `docwriter` n'a pas lu le PDF (HTTP 403), ce que `IV.md` déclare.
- La virgule ajoutée devant « qui doivent » est une paraphrase, pas une citation : elle ne change pas le sens.

## 4. Préambule : cohérent avec la consultation du 25/11

- **`\dateconsultation` au 25 novembre 2026.**
  - La liste d'E11 compte cinq sources : 2015/498, EIOPA-BoS-25/249, l'avis de l'ACPR, la question 2580 et le code des assurances. Ce sont les cinq sources du relevé, consultées en une seule séance (18:48:37-18:54:17 UTC).
  - Les sept ancrages, aux l. 10597, 21633, 21666, 21672, 21686, 21697 et 21708, sont tous couverts par ce relevé.
  - Un élément de la l. 10597-10599, « la même page donne ces traductions […] non datées », a pour pièce du 25/11 le § 1 de `regulatory` (24 langues, « AI induced translations »), et non le relevé de la session (voir m5).
  - La décision (iii) du mainteneur est respectée.
- **`\versiondoc` 4.7.** C'est le changement que mon visa de l'étape 7 jugeait nécessaire (§ 4). `CONVENTIONS.md` ne fixe aucune règle de numérotation.
- **`\datedoc` = `\dateconsultation`** (25 novembre 2026). E10 et E11 exigent deux macros distinctes, pas deux valeurs distinctes : il n'y a pas d'écart.

## 5. Contrôles exécutés à la tête `886de47`

| Contrôle | Résultat |
|---|---|
| `Rscript tests/concordance_doc_moteur.R --strict` | « BILAN : 0 ecart(s) (mode strict) » |
| `Rscript tests/controle_doc_nd.R` | 0 occurrence de la liste A, 0 fiche en violation (76 fiches en partie III), 0 débordement, 0 avertissement |
| Journal LaTeX | `.log` à 20:18:50, postérieur au `.tex` (20:18:40) ; 477 pages, 0 `Overfull` |

Les dates « 10.11.2026 » et « 12.11.2026 » passent bien E4.

## Constats mineurs écartés (ADR 0018)

- **m1**, `doc_tests_usp.tex:10600` : « À la même date, un avis […] déclare » peut se lire comme un avis daté du 25/11. `sec:biblio` lève le doute. Tournure possible : « Consulté à la même date, un avis… ». Aucun critère.
- **m2**, `doc_tests_usp.tex:21672-21673` : l'antécédent grammatical de « n'en fixe pas » est la date de publication des traductions, alors que l'intention vise la date d'application. L'énoncé est vrai dans les deux lectures. Aucun critère.
- **m3**, `doc_tests_usp.tex:21660` : « sa conformité » renvoie à l'ACPR alors que le sujet de l'entrée est au pluriel. Lisible. Aucun critère.
- **m4**, `IV.md`, entrée « Correction du constat… » : « était donc déjà contredite par une source publiée » s'appuie sur la date affichée (12/11) et sur la date du fichier (10/11). La première mise en ligne n'est pas établie (§ 1 de `regulatory`). « selon la date affichée par la page » serait plus exact. Le texte est au suivi, pas dans le `.tex`. Aucun critère.
- **m5**, `IV.md`, entrée « JS2, étape 4b », source (1) : elle ne consigne pas le constat sur les traductions (listées, produites par IA, non datées) qui fonde la l. 10597-10599 au 25/11. Sa pièce du jour est le § 1 de `regulatory`. Une demi-ligne de renvoi suffirait. Aucun critère.

## Retour

- **Statut** : `complet`.
- **Résultat** : **visa** du diff `e04e8a3..886de47` (`.tex`, `CONVENTIONS.md`, `IV.md`), préambule compris. Avec le visa de l'étape 7, cela couvre tout `git diff main...HEAD -- docs/latex/` jusqu'à `886de47`.
- **Hypothèses** : la lecture « portée » de « applicables aux organismes » (§ 2) est une lecture possible, pas établie.
- **Non vérifiés** : texte de l'avis et métadonnées du PDF, non relus par l'agent (il s'appuie sur la session et sur `regulatory`) ; § 171 de la notice et son renvoi à l'orientation 6, non relus sur la notice ; version française d'EIOPA-BoS-25/249.
- **Informations manquantes** : date de la déclaration et de la première mise en ligne de l'avis ; date de publication des traductions.
- **Décisions non résolues** : lectures L1 à L3, laissées ouvertes par le mainteneur (E-25/11 (JS2, PJ-3)). Le texte visé reste vrai sous chacune.
- **Critères déclenchés** (routage, § 4) : aucun nouveau.
- **Constats hors périmètre** : l'observation « portée ou date » sur le § 4 des orientations et l'avis (§ 2), aucun critère, information pour une décision future sur L1 à L3.
