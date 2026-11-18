# JS1, étape 2 (iii) : `engine_ecrire_xlsx(df, "C:f.xlsx")` sur le poste Windows (18/11/2026)

> Relevé de la session principale (IA), faite en session locale de Claude Code sur le poste du mainteneur. Critère de la fiche JS1 : un refus motivé, ou un fichier écrit dans le dossier courant de `C:` et nulle part ailleurs.

## Conditions

- `git rev-parse HEAD` : `c75a112214d757ad778b89aaf2e680ba719d6c0f`, le SHA de la batterie. Tête détachée ; arbre propre, hors `?? prompt-poste-local.md`, fichier du mainteneur hors dépôt.
- md5 de `R/engine.R` : `26220144141d922f4ea85d259004f093`.
- Plateforme :
  - Windows 11 x64 (build 26300) ;
  - `R version 4.3.3 (2024-02-29 ucrt)` ;
  - locale `French_France.utf8` (`LC_NUMERIC=C`) ;
  - `openxlsx` 4.2.9 et `zip` 2.3.0 ; la compression passe par `zip::zipr()`.
- Le moteur est chargé par `charger_moteur()` (ADR 0016).
- Script : `etape-2-iii/scenario_c.R`, lancé par `Rscript scenario_c.R <racine du dépôt>` depuis un dossier de travail de la session, sur le lecteur `C:`.
- Sortie brute : `etape-2-iii/sortie_scenario_c.txt`. Les chemins du poste y sont abrégés en `<scratchpad>`, `<TEMP>` et `<depot>` ; rien d'autre n'est retouché.
- Première exécution au SHA `c75a112`. Après le `/code-review` de l'étape 6, le script a été repris : avertissements relevés sans interrompre l'appel, `tempdir()` imprimé. La sortie versée est celle de cette reprise, à la tête `8022501`, dont le code est identique (`git diff c75a112 8022501 -- R/ app.R DESCRIPTION tests/` vide). Elle reproduit la première au chemin du dossier de travail près.

## Sortie, en résumé

| Relevé | Valeur |
|---|---|
| `tempdir()` | `<TEMP>\RtmpkJpk9e`, sur le lecteur `C:` |
| `getwd()`, avant et après | `<scratchpad>/e2iii_b` |
| `normalizePath("C:")`, dossier courant du lecteur `C:` | `<scratchpad>\e2iii_b`, le même dossier |
| `file.exists("C:f.xlsx")` avant l'appel | `FALSE` |
| Valeur rendue | `"C:f.xlsx"`, sans erreur ni avertissement |
| `f.xlsx` dans le dossier de travail et dossier courant de `C:` | absent |
| `C:/f.xlsx` | absent |
| `<depot>/f.xlsx` | absent |

## Localisation du fichier

Sonde `etape-2-iii/sonde_unlink.R` (`trace()` sur `base::unlink`), lancée par `Rscript sonde_unlink.R <racine du dépôt>` à la tête `8022501` (code identique). Sortie : `etape-2-iii/sortie_trace_unlink.txt`.

```
dirname: .
cible: C:f.xlsx
unlink <TEMP>\RtmpI7ZVEc\xlsx_c201929194d ; f.xlsx present dans d : TRUE
rendu: C:f.xlsx
```

## Constat

- **Succès annoncé, aucun fichier.** `engine_ecrire_xlsx()` rend `"C:f.xlsx"`. Aucun `f.xlsx` n'existe ensuite, ni dans le dossier courant de `C:`, ni ailleurs parmi les emplacements relevés.
- **Mécanisme**, lu dans le code et confirmé par la sonde :
  1. `.xlsx_chemin_absolu()` tient `"C:f.xlsx"` pour absolu.
  2. `dirname("C:f.xlsx")` vaut `"."`. La branche `!unix && identical(dossier, ".")` de `.xlsx_chemin_sortie()` rend donc le chemin tel quel : la cible reste relative au dossier courant du lecteur `C:`.
  3. Après `setwd(d)`, le dossier courant de `C:` est le dossier temporaire `d` de l'appel. `zip::zipr()` y écrit `f.xlsx`, et le contrôle `file.exists(cible)` réussit.
  4. `on.exit(unlink(d, recursive = TRUE))` supprime ensuite le fichier avec `d`.
- **Critère non tenu** : il n'y a ni refus motivé, ni fichier dans le dossier courant de `C:`. Le fichier est écrit ailleurs (dans `d`) sous un succès annoncé, puis effacé.
- **Portée** :
  - aucune donnée existante n'est écrasée : `unlink(cible)` vise `d\f.xlsx`, absent ;
  - aucun nombre, aucun verdict ni aucun σ_USP n'est touché ;
  - l'application n'emprunte pas ce chemin : `downloadHandler` passe à `engine_ecrire_xlsx()` le fichier temporaire de Shiny (`app.R`, `dl_donnees_xlsx`) ;
  - l'appelant touché écrit sans Shiny (« Usage sans Shiny » du README) et passe une forme de lecteur sans barre (`X:f.xlsx`) ;
  - le défaut ne vaut que si `X:` est **le lecteur de `tempdir()`** : `setwd(d)` ne change que le dossier courant du lecteur de `d`. Pour un autre lecteur, la cible reste relative à son propre dossier courant, et l'écriture devrait y aboutir. Ce cas n'est **pas mesuré** : le poste n'a que le lecteur `C:`.
- **Tri ADR 0018** (fiche JS1, étape 5) : « un fichier de (iii) écrit ailleurs sous un succès annoncé » devient une issue gardée **courante**, rattachée à A1. L'issue est rédigée dans la synthèse (`README.md`) et sera créée sur accord du mainteneur. Elle n'empêche ni la sortie du brouillon ni l'étiquette (Q-67-8).
