# Lecture de la mesure de #608 au poste Windows (créneau A2, étape W)

*Rapport de l'agent `audit` (fiche de base, lecture seule), 23/11/2026. Versé par la session principale (Q-54-10).*

**Conclusion : conforme.** La sortie soutient le verdict **NON REPRODUIT** (règle Q-73-2 (a)). Le commentaire de `.xlsx_chemin_sortie()` dans `R/engine.R` est à corriger à l'étape 5.

Fichiers relus :
- `docs/revues/20261123-a2-creneau/sortie_mesure_608.txt` (`9fbe3f5`) ;
- `docs/revues/20261123-a2-creneau/mesure_608.R` (`f429b8c`) ;
- `docs/revues/20261123-a2-creneau/audit-lecture-608.md` ;
- `R/engine.R` l. 8934-8958 et 9216-9300.

## 1. Verdict

**Contexte de la mesure, conforme :**
- `HEAD` est `1954e6c`. `git diff --stat f429b8c 1954e6c -- mesure_608.R R/engine.R` est vide.
- Moteur : diff vide contre `8d7bf2f` ; md5 `0f8167e59e3507dd40bd8a87d122e189`.
- R 4.3.3 ucrt, sous Windows.
- Paquet `zip` 2.3.0 et commande zip présents : les deux voies d'écriture ont été essayées.
- Lecteur virtuel `Z:` (lettre choisie libre) ; `Z:/<nom>` n'a pas été créé.
- Nettoyage : `[OK]` sur les trois lignes de contrôle.

**Résultats des quatre essais :**
- **(a) Sonde.** Les quatre sondes rendent `Z:/<nom>/f.xlsx`, avec `C:/<nom>` absent puis présent.
- **(b) Écriture.** Les deux chemins sont refusés par `usp_refus_ecriture` « Echec de la creation… ». Aucun fichier n'apparaît en `C:`.
- **(c) Témoin.** Le fichier témoin est intact : md5 `b2d350c5…` avant et après.
- **(d) Témoin négatif.** Refus, sans dossier ni fichier créé.

**Cohérence externe.** Le message de zip nomme `Z:/<nom>/f.xlsx` : après `setwd(d)`, l'écriture a bien visé `Z:`.

**Lecture de la règle.** `lire_608()`, confrontée aux valeurs imprimées, ne trouve aucun motif REPRODUIT et aucun manque.

## 2. Portée

La mesure tranche la **ligne 4** du tableau du § 2 de `audit-lecture-608.md` : le dossier est absent du lecteur de l'appelant et présent sur celui de `tempdir()`. Elle vérifie aussi la **ligne 3** sur ce poste.

**Vérifié** sur un poste, sous R 4.3.3 ucrt, avec un lecteur courant créé par `subst` :
- Pour un dossier inexistant, le repli de `normalizePath(…, mustWork = FALSE)` rend un chemin complet avec la lettre du lecteur courant, et non l'entrée inchangée. C'est vrai que `C:/d` existe ou non.
- La cible garde donc sa lettre après `setwd(d)`. Rien n'est écrit sur le lecteur de `tempdir()`.
- `unlink(cible)` (l. 9291) ne touche rien de ce lecteur. Le constat (ii) de la lecture est infirmé sur ce poste.

**Hypothèse, non mesurée :**
- même repli sur deux lecteurs physiques distincts, ou sur un lecteur réseau mappé ;
- même repli sous une autre version de R ou de Windows.

La généralisation est plausible si le repli est purement textuel, mais c'est un raisonnement, pas une mesure.

## 3. Commentaire proposé pour l'étape 5

À poser dans `R/engine.R`, l. 8949-8951, en-tête de `.xlsx_chemin_sortie()`. Il remplace la phrase fausse « Le resultat ne depend pas de getwd() … ni ecrit. ». Le début de la l. 8949 est gardé.

```
# branche n'est plus atteinte par l'ecrivain. Le resultat depend de wd, de
# HOME pour "~" et, par normalizePath(), des liens du dossier s'il existe.
# Sous Windows, il depend aussi du repertoire courant (getwd()) au moment de
# l'appel pour un chemin a barre initiale unique ("\d\f.xlsx", "/d/f.xlsx") :
# normalizePath() le complete avec le lecteur courant, et non avec wd ;
# engine_ecrire_xlsx() appelle donc cette fonction avant setwd(d), avec
# wd = getwd(). Dossier absent compris, la cible garde ce lecteur et ne se
# resout pas sur celui de tempdir() apres setwd(d) (#608) : releve au poste
# Windows le 23/11/2026 (R 4.3.3 ucrt, un seul poste, lecteur courant cree par
# subst), docs/revues/20261123-a2-creneau/sortie_mesure_608.txt, commit
# 9fbe3f5 ; non mesure sur deux lecteurs physiques. Aucun fichier ni dossier
# n'est lu, cree ni ecrit.
```

Ajout optionnel, l. 9216 : « ; voir l'en-tete de .xlsx_chemin_sortie() pour la barre initiale unique sous Windows (#608) ».

## 4. Autres points

Tous mineurs, sans critère ADR 0018 :
- **Double barre de « Z://<nom>/f.xlsx ».** Elle apparaît dans les lignes `file.exists` de (b) et vient du script (`mesure_608.R:103`, `file.path("Z:/", …)`), non du moteur. Le constat (iii) porte sur un fichier placé à la racine : il n'est pas mesuré ici.
- **Libellés figés « L: ».** Le script imprime « L: » aux l. 61, 67 et 119, alors que la lettre réelle est Z:. C'est cosmétique : le calcul emploie bien la lettre réelle.
- **Fichiers non suivis sur le poste.** `prompt-poste-local.md` et `sorties-p/` sont hors moteur et sans effet sur la mesure. Ils ne sont pas à commiter.
