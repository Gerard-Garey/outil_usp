# Conventions de la documentation LaTeX

Règles **obligatoires** pour toute modification de `doc_tests_usp.tex`, par un humain ou un agent (`docwriter`, `coder`). Elles protègent la rigueur actuelle du document : sa structure, son contenu et sa traçabilité avec le code. Une modification qui les enfreint est refusée en relecture.

## 1. Structure : invariants

- **Plan fixe** : Objet du document, Sommaire, puis **Partie I** (Présentation de l'outil), **Partie II** (Cadre statistique général), **Partie III** (Fiches de tests par hypothèse), **Partie IV** (Validation, références et synthèse), **Annexe** (Flux détaillés entre fonctions). On n'ajoute, ne supprime, ne renomme ni ne réordonne aucune partie. Les parties se déclarent par `\partie{…}{…}`.
- **Sections** : l'ordre et les titres des `\section` existantes sont conservés. Une nouvelle section ou sous-section se place dans la partie dont elle relève, sans déplacer les autres. Un titre ne change que s'il est faux.
- **Fiches de test** : tout test restitué par le moteur a sa fiche dans la partie III, dans la section de son hypothèse (H1 à H4, stabilité, robustesse, M1 à M6). Une fiche s'écrit **exactement** ainsi :

  ```latex
  \begin{fiche}{Nom exact du test}
  \refl{Référence(s) fondatrice(s).}
  \Cadre   % 1. Cadre, notations et hypothèses de validité (non testées)
  \Hzero   % 2. Hypothèse nulle (H0 contre H1)
  \Stat    % 3. Statistique de test
  \Loi     % 4. Loi sous H0 (exacte, asymptotique ou simulée : le dire)
  \Pval    % 5. p-value (méthode effectivement retenue par le moteur)
  \Usage   % 6. Usage et limites (dont l'interprétation à T = 8)
  \end{fiche}
  ```

  Les six rubriques sont toutes présentes, dans cet ordre, sans rubrique supplémentaire. Un diagnostic (au sens de `CONTEXT.md`) garde le même gabarit ; sa rubrique 6 dit pourquoi il ne porte pas de verdict (ADR 0001).
- **Renvois** : toujours par `\label` / `\ref`, jamais par un numéro écrit en dur (« fiche 40 », « section 3.2 »). Les numéros de fiche changent quand on insère une fiche : seuls les `\ref` restent justes. Un `\label` existant n'est jamais renommé ni supprimé tant qu'un `\ref` y renvoie.
- **Tableaux de synthèse** : le tableau 1 (disponibilité et choix des p-values) et le tableau 2 (nature et vitesse des convergences) gardent leurs colonnes, fixées par `docs/exigences.md` § 3.2 et 3.3. Chaque test présent dans une fiche a sa ligne dans les deux tableaux, et dans l'index des fonctions de la partie I ; un test ajouté ou retiré l'est partout dans le même changement.
- **Préambule et charte** : ni paquet ajouté, ni macro redéfinie, ni couleur modifiée. On utilise les macros existantes : `\code{}` pour tout identifiant R, `\refl{}` pour la référence d'une fiche, `\reglement{titre}{texte}` pour une citation du règlement, l'environnement `encadre` pour un point de revue. Une nouvelle macro ne s'introduit qu'en cas de besoin répété, définie dans le préambule avec un commentaire.
- **Fichier unique** : le document reste un seul `.tex`, sans `\input` ni `\include`.

## 2. Contenu : invariants

- **Conservation** : aucun développement, aucune justification, aucune limite, aucune référence n'est supprimé au seul motif d'alléger. Une suppression n'est admise que si le passage est faux ou décrit un code qui n'existe plus ; elle est alors signalée dans le compte rendu avec le texte retiré.
- **Concordance avec le code** : la doc décrit ce que fait `R/engine.R`, y compris la variante exacte d'un test, le sens (unilatéral, bilatéral), la statistique réellement comparée et la p-value réellement retenue (`nature_p`). En cas d'écart dont le code semble fautif, on ne réécrit pas la doc pour la conformer à ce que le code devrait faire : on ouvre une issue.
- **Formules réglementaires** : toute formule de l'annexe XVII reproduite dans la doc l'est à la lettre (indices, bornes des sommes, ensembles d'indices), avec sa référence précise (section, paragraphe, point). Une interprétation retenue par l'outil est présentée comme telle, distincte du texte.
- **Statuts épistémiques** : résultat exact, résultat asymptotique, approximation numérique et constat de simulation sont toujours nommés et jamais confondus (`docs/exigences.md` § 2). Une p-value n'est dite « exacte » qu'au sens de `CONTEXT.md` (ADR 0002).
- **Deux sources d'erreur** : l'erreur Monte-Carlo (fonction de B, en 1/√B) et l'erreur d'approximation statistique (fonction de T) sont toujours distinguées.
- **T = 8** : toute conclusion statistique est qualifiée pour T = 8 ; la rubrique 6 de chaque fiche le fait explicitement. L'existence d'une loi limite ou l'implémentation par défaut d'une fonction R n'est jamais présentée comme une justification suffisante.
- **Vocabulaire** : les termes de `CONTEXT.md` (modèle réglementaire, test, diagnostic, verdict, test inopérant, p-value exacte / Monte-Carlo / asymptotique / retenue, sensibilité à δ) sont employés dans leur sens et remplacent leurs synonymes écartés.
- **Références** :
  - chacune a été retrouvée et soutient l'affirmation qui la cite ; aucune référence, aucun théorème, aucun numéro de page ou vitesse de convergence inventé ;
  - format : initiales et nom (`A.\,C. Berry`), titre en `\emph{}`, revue en `\emph{}`, volume(numéro), année, `p.~x--y` ;
  - la référence fondatrice d'un test va dans le `\refl{}` de sa fiche ; une affirmation sur la qualité d'approximation à T = 8 ou la validité du bootstrap va dans « Compléments bibliographiques » (partie IV), avec la portée exacte de la référence ;
  - une référence remplacée reste citée si elle demeure utile, et le remplacement est justifié.
- **Quand la littérature ne permet pas de conclure** à T = 8, le document l'écrit.

## 3. Typographie et notations

- Français, avec accents ; espace insécable avant les signes doubles (`~:`, `~;`, `~?`, `~!`) ; guillemets « » ; `p.~` devant un numéro de page ; `\,` entre les initiales.
- Nombres : virgule décimale, écrite `{,}` en mode mathématique (`0{,}10`) ; `\%` précédé d'une espace insécable (`10~\%`).
- Notations fixes : $T$ (profondeur), $x_t$, $y_t$, $z_t$ (résidus standardisés), $\delta$, $\gamma$, $\beta$, $\pi_t$, $\sigma$, $\alpha$ (seuil), $B$ (réplications) ; estimateurs chapeautés ($\hat\delta$) ; $H_0$ et $H_1$ ; méthode Merz-Wüthrich : $C(i,j)$, $f_j$, $\sigma_j^2$. Une nouvelle notation est définie à sa première occurrence et ne redéfinit aucune des précédentes.
- Indicatrice : `\mathds{1}` (paquet `dsfont`, chargé par le préambule), jamais `\mathbb{1}` (`amssymb` ne définit pas le 1 en gras tableau noir).
- Mise en valeur sobre : `\textbf` pour ce qui change une lecture (rôles inversés de H0/H1, mise en garde), `\emph` pour un terme défini ou un titre.

## 4. Manière de modifier

1. Modifications **ciblées** : on corrige le passage fautif, on ne réécrit pas une section correcte. Le diff doit rester lisible par un relecteur.
2. Avant de modifier, relever ce que le passage affirme et ce qui y renvoie (`\ref`, tableaux, index) ; après, vérifier que tout ce qui y renvoie reste juste.
3. Compiler en suivant la skill `compiler-doc` : aucune erreur, aucun renvoi indéfini.
4. Contrôler que le plan (table des matières) est inchangé, sauf ajout voulu, et que le nombre de fiches correspond aux tests restitués par le moteur.
5. Rendre compte : modifications par section, avec avant / après pour toute modification de fond, références ajoutées ou retirées et pourquoi, suppressions et leur motif.
