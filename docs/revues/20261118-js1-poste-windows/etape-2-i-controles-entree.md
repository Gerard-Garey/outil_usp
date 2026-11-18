# JS1, étape 2 (i) : rejeu de `test_controles_entree.R` sur le poste Windows (18/11/2026)

> Relevé de la session principale (IA), session locale de Claude Code sur le poste du mainteneur. Critère de la fiche JS1 (D-S1-29) : aucun échec.

## Conditions

- `git rev-parse HEAD` : `c75a112214d757ad778b89aaf2e680ba719d6c0f`, détaché, arbre propre (hors `?? prompt-poste-local.md`). `git status --porcelain` est identique après les quatre exécutions des étapes 2 (i) et 4.
- Windows 11 x64 (build 26300), `R version 4.3.3 (2024-02-29 ucrt)`, locale `French_France.utf8` (`LC_NUMERIC=C`). Lancement sous PowerShell.
- Commande : `Rscript tests/unitaires/test_controles_entree.R`, exécutée deux fois :
  - **avec `openxlsx`** 4.2.9 et `zip` 2.3.0, de la bibliothèque du poste ;
  - **sans `openxlsx`**, avec `R_LIBS_USER` pointé sur un dossier vide. Ce dossier masque aussi `zip` : l'écrivain passe alors par `utils::zip()`.
- Sorties brutes : `etape-2-i/sortie_avec_openxlsx.txt` et `etape-2-i/sortie_sans_openxlsx.txt`. Le fichier de test n'imprime que les échecs, les lignes « [saute] » et le bilan.

## Bilan

| Exécution | Assertions | ok | Échecs | Échecs attendus | Succès inattendus | Lignes « [saute] » | Durée | Code de sortie |
|---|---|---|---|---|---|---|---|---|
| avec `openxlsx` | 608 | 606 | **2** | 0 | 0 | 2 | 507 s | 1 |
| sans `openxlsx` | 592 | 590 | **2** | 0 | 0 | 14 | 549 s | 1 |

Lignes « [saute] » communes aux deux exécutions ; elles tiennent à la plateforme :
- « `.echapper_texte()` sous `LC_ALL = C.UTF-8` (#588) : locale indisponible » ;
- « chemin "~" (#580) : HOME non redirigeable sur ce systeme ».

Sans `openxlsx`, les douze lignes de plus sont les parités qui exigent le paquet `openxlsx` ou le paquet `zip`.

L'assertion de #522 (octet 0x89 déclaré Latin-1), seule en échec au relevé de KR le 14/11, **passe** désormais. Sa correction date de S1 (#588).

## Les deux échecs (les mêmes sur les deux chemins)

### Échec 1 : chemin UNC en barres obliques (`test_controles_entree.R`, l. 6960)

- Assertion : `.xlsx_chemin_sortie("//serveur/partage/f.xlsx", wd)` doit rendre `"//serveur/partage/f.xlsx"`.
- Valeur obtenue sous Windows : `"\\\\serveur/partage/f.xlsx"`, soit deux barres inverses en tête puis des barres obliques. La sonde se reproduit en ligne de commande.
- Cause : sous Windows, `dirname("//serveur/partage/f.xlsx")` rend `"\\\\serveur/partage"`. `normalizePath(winslash = "/")` le laisse tel quel, puisque le dossier n'existe pas.
- Jugement de la session :
  - le chemin rendu désigne le même partage UNC ; il reste absolu et n'est pas préfixé du répertoire courant, ce qu'est l'objet de l'assertion ;
  - l'écart tient à la **forme attendue par le test**, mesurée sous Linux, et non à une cible fausse ;
  - aucune écriture vers un partage réel n'a été essayée.
- Tri ADR 0018 : **mineur**, aucun critère ; une ligne sous « Constats mineurs écartés » de la synthèse.

### Échec 2 : tabulation et saut de ligne admis en cellule (`test_controles_entree.R`, l. 7064)

Sonde : `etape-2-i/sonde_tab.R`, lancée par `Rscript sonde_tab.R <racine du dépôt>`, sortie `etape-2-i/sortie_sonde_tab.txt`. La sortie versée est celle de la reprise après le `/code-review` : restauration garantie de `requireNamespace`, lecture du XML entier. Elle a été faite à la tête `8022501`, dont le code est identique à `c75a112`.

- **Écriture** : `engine_ecrire_xlsx()` écrit `sheet1.xml` par `writeLines(..., useBytes = TRUE)` sur une connexion en mode texte. Sous Windows, chaque `\n` du texte d'une cellule y devient `\r\n`. Le XML écrit contient donc `<t>a\r\nb</t>` pour la cellule `"a\nb"`, et `<t>e\tn\r\ntéte</t>` pour l'en-tête.
- **Relecture**, pour la cellule `"a\nb"` :

  | Chemin | Valeur relue | Octets | `identical()` avec l'écrit |
  |---|---|---|---|
  | `openxlsx` 4.2.9 | `"a\nb"` | `61 0a 62` | vrai |
  | lecteur interne | `"a\r\nb"` | `61 0d 0a 62` | **faux** |

  `openxlsx` applique la normalisation des fins de ligne de XML 1.0 (§ 2.11), contrairement au lecteur interne.
- **En-tête** : le motif `<t>e\tn\ntéte</t>` est absent du XML écrit, puisque le `\n` y est devenu `\r\n`.
- Les autres cellules sont relues `identical()` sur les deux chemins : tabulation, `"cé"`, et `"café"` marqué latin1.
- Sous Linux (CI et sessions cloud), l'assertion passe. `writeLines()` n'y convertit pas les fins de ligne.
- **Portée** :
  - textes seuls ; aucun nombre, aucun verdict ni aucun σ_USP n'est touché ;
  - les deux chemins de lecture divergent sur un classeur que l'outil écrit lui-même sous Windows, ce que D-S1-31 veut exclure ;
  - le commentaire de `.xlsx_defaut_texte()` dit la tabulation et le saut de ligne « admis en cellule et en en-tete » et refuse le retour chariot parce qu'il « ne survit pas a la relecture » ; or, sous Windows, l'écrivain introduit lui-même ce retour chariot, et l'assertion « relus `identical()` » est fausse pour le lecteur interne ;
  - le lecteur interne ne normalise pas `\r\n` en `\n` (XML 1.0, § 2.11) pour un classeur tiers qui en porterait.
- Tri ADR 0018 : **gardé**, sur les critères « affirmation fausse sur le code » et « deux lectures du même classeur ». C'est une issue **courante**, du même module qu'A1 (§ 5.2). Elle est rédigée dans la synthèse, à créer sur accord du mainteneur.

## Constat

- **Critère (i) non tenu** : il reste deux échecs, propres à Windows, sur l'écrivain xlsx de #580 (S4). Le premier est un biais de forme du test. Le second est un défaut réel des fins de ligne sous Windows, sur du texte seul.
- Le code est gelé jusqu'à la fusion (fiche JS1) : aucune correction dans JS1.
- La fiche ne fait pas de ce critère une condition de l'étiquette : seules la batterie refusée et une issue urgente la retiennent (Q-67-8 (a)). La décision revient au mainteneur.
