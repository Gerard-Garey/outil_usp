# Revue KR, étape 4, consultation (ii) « entrées-sorties » : rapport d'`audit` (effort `high`, lecture seule)

> Versé intégralement par la session principale (Q-54-10). SHA du gel `a2f9c3a`.

**Conclusion : conforme avec réserves.** Aucun motif d'arrêt :
- les six cas de référence sont identiques (écart maximal 0) : aucun σ_USP ni verdict ne change ;
- aucun défaut de conformité majeur.

En revanche, une entrée booléenne passe pour la valeur 1 sur le chemin `openxlsx`. C'est le constat M1 : majeur, mais il ne touche pas les données du dossier.

**État examiné.** Gel `a2f9c3a`. HEAD est passé à `547afd3` pendant la revue, mais `git diff --stat a2f9c3a HEAD -- R app.R DESCRIPTION tests` est vide : le code examiné est bien celui du gel. Assiette : `git diff 9f7290f...a2f9c3a`. `R/charger_moteur.R` n'est pas dans le diff ; relu en entier quand même. Rien n'a été écrit dans le dépôt ; sondes hors dépôt (`probe/`, scratchpad de la session).

**openxlsx.** Au début de la revue, `openxlsx` n'était pas dans la bibliothèque. Il y était ensuite, en version **4.2.5.2** (avec `zip` 2.3.1), sans verrou d'installation. Les tests du domaine ont donc été rejoués avec la bibliothèque temporaire de la session.

---

## Constats

**M1 — majeur. Une cellule booléenne, ou une colonne de textes « TRUE », est lue comme le nombre 1 sur le chemin `openxlsx`.**
- **Emplacement :** `R/engine.R:8013-8018`, fonction `.en_numerique()`. Le défaut est antérieur à `9f7290f`, mais il est atteint par `engine_lire_triangle()` (l. 8206) et `engine_lire_donnees_csv()` (l. 8094-8095), qui sont dans le diff et dans le périmètre.
- **Mécanisme :** `openxlsx::read.xlsx` rend en logique une colonne dont toutes les cellules sont booléennes (`t="b"`) ou des textes « TRUE »/« FALSE ». Ensuite, `suppressWarnings(as.numeric(v))` transforme TRUE en 1.
- **Divergence entre les deux chemins :** le lecteur interne rend « TRUE » en texte et refuse la cellule. Le commentaire des l. 9068-9069 (« rendue "TRUE"/"FALSE", comme openxlsx : sa valeur brute "1"/"0" passerait pour un nombre ») est donc faux pour `openxlsx`.
- **Mesure :** sonde `p4.R`, sous `LC_ALL=C.UTF-8`.
  - **Triangle 5×5 avec C(0,4) booléen ou texte en ligne « TRUE » :**
    - avec `openxlsx` 4.2.5.2, `j4` est lu en `"logical"`, `engine_lire_triangle` donne `ok TRUE C(0,4) = 1` ;
    - sans `openxlsx`, la colonne est lue en `"character"` et la lecture est refusée : `ok FALSE Cellule(s) non numerique(s) en (i = 0, j = 4)` ;
    - `run_engine` refuse ensuite ce triangle, mais par chance et avec un motif trompeur : « Reserve chain-ladder totale negative ou nulle (R = -416.359) ». Avec des cumuls exprimés dans une petite unité, la valeur 1 resterait plausible.
  - **Série dont la colonne `xt` est entièrement booléenne, avec `openxlsx` :** `engine_lire_donnees_csv` donne `ok TRUE xt = 1 1 1 1 1 1 1 1`, puis `run_engine` donne `ok TRUE sigma 0.20176`.
  - **Appel direct :** même résultat avec un data.frame à colonne logique (`p1.R`), donc aussi après un `read.csv()` lancé avec ses réglages par défaut.
- **Correction proposée :** dans `.en_numerique()`, rendre `NA_real_` pour un vecteur logique. Une colonne entièrement NA reste « vide » ; une cellule TRUE ou FALSE devient « non vide et non numérique » et elle est refusée avec sa position. Corriger aussi le commentaire des l. 9068-9069. Ajouter un test de parité sur les deux chemins.
- **Issue proposée (gel) :** « moteur: cellule booléenne ou colonne "TRUE"/"FALSE" lue 1 par le chemin openxlsx (`.en_numerique()`) ». Circuit 3, références identiques attendues. Le texte du motif reste celui des cellules non numériques. À traiter après la remise, si le mainteneur l'accepte.

**m1 — mineur. Deux cellules de même référence : la dernière l'emporte, sans message.**
- **Emplacement :** `R/engine.R:8709-8738` (`.xlsx_controler_cellules()`), conséquence à la l. 9073.
- **Mesure :** `<c r="E2"><v>130</v></c><c r="E2"><v>999</v></c>` donne `ok TRUE C(0,4) = 999`, avec et sans `openxlsx`. Pas d'écart de parité, mais une valeur forgée est acceptée.
- **Correction proposée :** refuser toute référence `r` présente plusieurs fois dans la feuille.
- **Suite :** compléter #574 (formes forgées), plutôt qu'ouvrir une issue nouvelle.

**m2 — mineur. Résolution du chemin de sortie dans `engine_ecrire_xlsx()`.**
- **Emplacement :** `R/engine.R:8383`, `grepl("^(/|[A-Za-z]:)", chemin)`. Ni « ~ » ni un chemin UNC Windows (`\\serveur\...`) ne sont reconnus comme absolus.
- **Mesure :** `engine_ecrire_xlsx(df, "~/zz_probe_usp.xlsx")` donne `usp_refus_ecriture` « Echec de la creation du fichier .xlsx (commande zip, statut 15) ». La cible devient `<wd>/~/…`.
- **Gravité :** le refus est sûr, sans fichier faux. `engine_ecrire_csv()` traite « ~ » correctement, via `file()`. L'application passe un chemin temporaire absolu et n'est pas touchée.
- **Correction proposée :** `path.expand()`, puis `normalizePath(dirname(chemin), mustWork = FALSE)` avant `setwd(d)`.
- **Issue proposée :** groupée avec m3.

**m3 — mineur. Les caractères de contrôle ne sont pas filtrés à l'écriture xlsx.**
- **Emplacement :** `R/engine.R:8266-8270` (`.xml_echap()`) et 8335.
- **Mesure :** une chaîne `"x\001y"` est écrite telle quelle dans `sheet1.xml`. Ce XML 1.0 n'est pas valide et un tableur refuserait le fichier ; les lecteurs du moteur, eux, le relisent.
- **Gravité :** les exports de l'application ne portent que des en-têtes fixes et des nombres, donc ils ne sont pas exposés.
- **Correction proposée :** refus `usp_refus_ecriture`, ou retrait des caractères interdits. Même issue que m2 (« écrivain xlsx : chemins et caractères hors XML 1.0 »), ou complément à #558.

**Hors constat, déjà au plan.** `docs/latex/doc_tests_usp.tex` l. 4398 et ~4409 décrivent encore le rappel « reste ouverte » de la méthode n° 2, que #573 a retiré du code : écart prévu, traité par `docwriter` (étape 7).

---

## Vérifications exécutées (toutes sous `LC_ALL=C.UTF-8`)

**Tests du domaine, sans `openxlsx` :**

| Fichier | Résultat | Sauts |
|---|---|---|
| `test_controles_entree.R` | 428/428 ok | 7 sauts `openxlsx`/`zip` |
| `test_outdec.R` | 96/96 ok | — |
| `test_chargement_moteur.R` | 9/9 ok | — |
| `test_defauts_connus.R` | 127/127 ok | — |

**Les mêmes avec `openxlsx` 4.2.5.2, `zip` 2.3.1 :**

| Fichier | Résultat | Sauts |
|---|---|---|
| `test_controles_entree.R` | 444/444 ok | 0 |
| `test_outdec.R` | 97/97 ok | — |
| `test_chargement_moteur.R` | 9/9 ok | — |
| `test_defauts_connus.R` | 127/127 ok | — |

**`tests/test_reproductibilite.R` :** OK sur les 6 cas, CONFORME, écart maximal `0.000e+00` partout.
- premium 0.1114524114 ; reserve1 0.1073524114 ; reserve2 0.0497764613 ;
- premium_ii6 0.1483524114 ; premium_net 0.1032524114 ; premium_interieur 0.0871308679.

**Sondes adverses :**
- Aller-retour xlsx (lecteur interne) et CSV avec `1/3` et `.Machine$double.xmax` : identique au bit.
- Les lectures et écritures xlsx laissent `.Random.seed` et `OutDec` intacts, avec et sans `openxlsx`.
- `run_engine` avec `xt` en liste ou en data.frame : `ok = FALSE` avec un motif, sans erreur R.
- Triangle et séries de type entier à 1e9 : σ identique à l'entrée double.
- Formes numériques limites de `.cellules_en_nombre()` (« 1d5 », « 1_000 », U+00A0, chiffres pleine chasse, hexadécimal flottant) : toutes NA, aucune n'est acceptée à tort.

**Chargeur :** dans l'environnement fermé de `charger_moteur()`, aucun nom de fonction appelé n'est introuvable. La sonde statique ne signale que `.()`, qui relève de la syntaxe de `bquote`.

**Relecture du périmètre :** lus en entier `run_engine()`, `.run_engine_mw()`, `.engine_verifier_usage()`, `.engine_calcul_protege()`, les cinq validations, `usp_lire_vecteur()`, `usp_charger()`, tout le bloc de lecture et d'écriture (l. 7680-9188, CSV, xlsx et zip compris) et `R/charger_moteur.R`. La modification #573 d'`usp_valider_ajustement()` est conforme : la phrase est retirée des deux formes, et le test de `test_controles_entree.R` l. 4814 passe.

**Questions pour `actuary` :** aucune.

**Issues proposées, à créer sur accord du mainteneur :**
- M1, nouvelle issue (texte ci-dessus) ;
- m1, en complément de #574 ;
- m2 et m3, une issue « écrivain xlsx », ou un complément à #558.
