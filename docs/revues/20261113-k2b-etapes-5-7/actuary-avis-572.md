# Avis amont d'`actuary` sur #572 (P2, X1, M1), K2b

> Versé intégralement par la session principale (Q-54-10). Fiche de base, routine. 13/11/2026.

## Décision du mainteneur (13/11/2026, questionnaire)

- #572 créée et placée **dans K2b** (sixième numéro, au-delà du plafond indicatif de cinq).
- **Refus P2 et X1 ratifiés** (recommandation d'`actuary` ci-dessous) ; M1 corrigé par le motif tenant compte des guillemets, employé aussi dans la détection de P2.

## Avis

**1. Refus ou lecture corrigée**
- **P2 : refus** (`usp_refus_lecture`, avant `openxlsx`, sur les deux chemins). C'est le cas de la décision 7 : `openxlsx`, chemin par défaut, accepte une valeur fausse sans message. La forme est hors schéma, puisque `<rPh>` exige un `<t>`. Que le lecteur interne lise juste (11,5) n'y change rien : Q-F refuse déjà, par parité, une forme que l'interne lit juste. Condition : la table `xl/sharedStrings.xml` contient au moins une balise `<rPh …/>` auto-fermante.
- **X1 : refus**, pour la même raison. `openxlsx` lit 1 avec `ok = TRUE`. La forme est hors schéma : d'après la lecture de CT_Rst (`<t>` au plus une fois, puis `<r>`*, puis `<rPh>`*), non revérifiée dans `sml.xsd` pour cet avis. La valeur « vraie » d'une telle chaîne n'est d'ailleurs pas définie. Condition : une `<si>` qui contient plus d'un `<t>` (`<t…>` ou `<t/>`) une fois retirés les blocs `<r>…</r>` et `<rPh>`.
- **Une chaîne `<t>` suivie de `<r>` reste admise** : elle est conforme au schéma. Le codeur mesure ce qu'en lit `openxlsx` ; s'il la lit faux, il le signale sans ajouter de refus.
- **M1 : la correction du motif est nécessaire mais ne suffit pas seule.**
  - Le motif tenant compte des guillemets, `([ \t\r\n]([^>"']|"[^"]*"|'[^']*')*)?`, va dans les deux motifs de `.xml_textes()`. L'interne lit alors juste, et le commentaire l. 8527-8528 doit être corrigé.
  - La parité s'obtient par le refus P2, à condition que sa détection emploie **ce même motif**. Avec `[^>]*`, `<rPh sb="0>" eb="0"/>` échapperait au refus et `openxlsx` lirait 1.
  - Pas de refus propre à M1 : M1 n'est qu'une forme de P2.

**2. Textes (deux textes distincts, préférés à un texte unique)**
- P2 : « Classeur illisible : la table des chaines partagees (xl/sharedStrings.xml) contient une indication phonetique vide (balise <rPh .../> sans texte), forme non prevue par le format ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre tronquee). Enregistrer de nouveau le classeur depuis un tableur. »
- X1 : « Classeur illisible : la table des chaines partagees (xl/sharedStrings.xml) contient une chaine formee de plusieurs balises <t> successives, forme non prevue par le format ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre tronquee). Enregistrer de nouveau le classeur depuis un tableur. »
- Ordre des refus : Q-F inchangé d'abord, puis P2, puis X1, tous avant le contrôle de la ligne 1.

**3. Qui tranche**
- Par délégation : la correction du motif de M1, les deux textes, l'ordre des refus et le périmètre des contrôles (table partagée seulement, les chaînes en ligne étant mesurées d'abord).
- Ratification du mainteneur pour les refus P2 et X1 (au-delà de la lettre de Q-F ; fichiers acceptés devenus refusés) : **obtenue le 13/11/2026**.
- Aucun σ_USP ni verdict sur des données saines n'est touché. Hypothèse non vérifiée, comme pour Q-F : aucun tableur n'écrit ces formes.

**4. Points de vigilance pour `coder-approfondi`**
- Faux refus à exclure, chacun par un test sur les deux chemins : `<si><t>…</t></si>` et `<si><t xml:space="preserve">…</t></si>` ; `<si><t/></si>` ; `<si><r><rPr>…</rPr><t>…</t></r><r>…</r></si>` ; le cas japonais d'Excel : `<rPh sb="0" eb="1"><t>…</t></rPh>` ouvrant, suivi de `<phoneticPr fontId="1"/>` (le motif P2 ne doit viser ni `<phoneticPr…/>` ni `<rPhX…/>`).
- Comptage de X1 sur le texte de la `<si>` après retrait des `<r>…</r>` et des `<rPh>` avec le motif tenant compte des guillemets ; ne pas compter `<tab` ni d'autres balises commençant par `t`.
- Parité à mesurer et à figer (4.2.9 et 4.2.5.2) : P2, M1 (`sb="0>"`, `sb='0>'`, avec saut de ligne) et X1 refusés au texte exact, avec ou sans `openxlsx` ; classeur produit par un vrai tableur (fixtures du job de parité de #565) accepté, valeurs identiques avant et après.
- Chaînes en ligne (`<is>`) portant P2 ou X1 : mesurer ce que lit `openxlsx` ; NA (refus en aval) : limite consignée ; valeur fausse acceptée : signaler à `actuary` sans étendre le refus.
- `<rPh>` préfixé (`<x:rPh>`) : mesurer et consigner.
- Non-régression : `comparer_references.R --seuil 0` nul, `concordance_doc_moteur.R --strict` propre ; surface documentaire listée pour `docwriter`.

**Retour** — statut partiel (effet sur les chaînes en ligne non mesuré). Non vérifié : CT_Rst dans `sml.xsd` ; `openxlsx` sur `<is>` avec P2 ou X1, et sur `<t>` suivi de `<r>`.
