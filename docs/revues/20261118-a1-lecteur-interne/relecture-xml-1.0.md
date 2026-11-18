# Relecture à la source de XML 1.0 (étape 1c d'A1)

*Relecture faite par la session principale (IA) le 18/11/2026, sur la branche `claude/creneau-a1`. Elle remplit l'étape 1c de la fiche A1 (`docs/feuille-de-route.md`, § 3), préalable de l'étape 3b de #602 (Q-68-6 (a), Q-69-3 (a)). Elle a été rendue possible par l'autorisation de `www.w3.org` dans l'environnement de la session, le 18/11 ; jusque-là, le proxy de la session refusait ce domaine (403). La lecture d'`actuary`, prévue par la fiche, est demandée à l'étape 1b et reste à verser.*

## Source

- **Extensible Markup Language (XML) 1.0 (Fifth Edition)**, W3C Recommendation, 26 November 2008. La page porte une note : modifiée en place le 7 février 2013, pour remplacer des liens rompus vers les RFC 4646 et 4647.
- URL : <https://www.w3.org/TR/2008/REC-xml-20081126/> (« This version ») ; version la plus récente : <https://www.w3.org/TR/xml/>.
- Page lue le 18/11/2026 : HTTP 200, 219 926 octets, md5 `4e6657a2b8cdb45d68fd69ecf92e0b7b`. Le texte a été extrait des balises HTML ; les citations ci-dessous en sont reprises mot pour mot, seuls les espaces étant ramenés à un seul.

## Citations

### § 2.2 Characters

> Legal characters are tab, carriage return, line feed, and the legal characters of Unicode and ISO/IEC 10646.

> [2] Char ::= #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]

### § 2.10 White Space Handling

> An XML processor MUST always pass all characters in a document that are not markup through to the application.

> A special attribute named xml:space may be attached to an element to signal an intention that in that element, white space should be preserved by applications.

> The value "default" signals that applications' default white-space processing modes are acceptable for this element; the value "preserve" indicates the intent that applications preserve all the white space.

> This specification does not give meaning to any value of xml:space other than "default" and "preserve". It is an error for other values to be specified; the XML processor MAY report the error or MAY recover by ignoring the attribute specification or by reporting the (erroneous) value to the application. Applications may ignore or reject erroneous values.

### § 2.11 End-of-Line Handling

> To simplify the tasks of applications, the XML processor MUST behave as if it normalized all line breaks in external parsed entities (including the document entity) on input, before parsing, by translating both the two-character sequence #xD #xA and any #xD that is not followed by #xA to a single #xA character.

### § 3.3.3 Attribute-Value Normalization

> Before the value of an attribute is passed to the application or checked for validity, the XML processor MUST normalize the attribute value by applying the algorithm below, or by using some other method such that the value passed to the application is the same as that produced by the algorithm.

> All line breaks MUST have been normalized on input to #xA as described in 2.11 End-of-Line Handling, so the rest of this algorithm operates on text normalized in this way.

> For a character reference, append the referenced character to the normalized value. […] For a white space character (#x20, #xD, #xA, #x9), append a space character (#x20) to the normalized value.

> Note that if the unnormalized attribute value contains a character reference to a white space character other than space (#x20), the normalized value contains the referenced character itself (#xD, #xA or #x9).

> All attributes for which no declaration has been read SHOULD be treated by a non-validating processor as if declared CDATA.

## Ce que la source établit pour A1

Ce que la source établit (*vérifié*, citations ci-dessus) :

1. **Fins de ligne littérales, #602.**
   - Le processeur XML doit se comporter comme s'il remplaçait, avant l'analyse, toute suite littérale #xD #xA, et tout #xD isolé, par un seul #xA (§ 2.11).
   - Un classeur dont une partie porte un saut de ligne écrit `\r\n` en clair doit donc être lu `\n`. C'est le cas d'une partie écrite par `writeLines()` en mode texte sous Windows (constat de JS1, #602).
   - Un lecteur qui rend `\r\n` n'est donc pas conforme sur ce point. La normalisation des fins de ligne littérales de l'étape 3b est **conforme** à XML 1.0.
   - En revanche, une **référence de caractère** `&#xD;` reste le caractère #xD (§ 3.3.3, note), car la normalisation du § 2.11 ne porte que sur les caractères littéraux du document.
2. **Le #xD est un caractère légal** (§ 2.2). Le lire n'est pas une erreur de forme ; seule sa normalisation au § 2.11 est en cause.
3. **`xml:space="preserve"`, #594.**
   - Le processeur doit transmettre à l'application tout caractère qui n'est pas du balisage, blancs compris (§ 2.10, première citation). Le texte d'un `<t>` bordé de blancs est donc transmis avec ses blancs, que l'attribut soit présent ou non.
   - L'attribut ne change pas ce que le processeur transmet. Il signale une **intention** à l'application, qui doit garder les blancs.
   - Une valeur autre que `default` ou `preserve` est une erreur que l'application peut ignorer ou rejeter (§ 2.10). Le refus des formes non exactes par le contrat fermé reste donc permis.
4. **Valeurs d'attribut** (§ 3.3.3) : un blanc littéral dans une valeur d'attribut devient une espace, et un attribut non déclaré se traite comme `CDATA`. Cela touche la lecture des attributs `r`, `t` et `s`. Le contrat fermé refuse déjà les formes d'attribut non attendues (règles R3 à R8, #574).

Ce que la source n'établit pas (*non vérifié* ici) :

- le comportement actuel du lecteur interne sur `\r\n` littéral et sur `&#xD;` : à mesurer par `coder-approfondi` à l'étape 3a ou 3b, avant toute modification ;
- l'effet de la normalisation sur l'écrivain interne : c'est l'objet de l'étape 3a (écriture d'octets).

## Suite

- L'étape 3b n'attend plus la relecture (Q-69-3 (a) satisfaite).
- `actuary` relit cette note dans le cadre de l'étape 1b, ou à la validation de l'étape 3b.
