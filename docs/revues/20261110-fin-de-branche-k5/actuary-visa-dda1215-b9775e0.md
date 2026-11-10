<!-- Rapport d'`actuary` (fiche de base), visa des corrections `dda1215` (#524) et `b9775e0` (#518), 10/11/2026. Texte intégral rendu par l'agent. -->

# Revue actuarielle des commits dda1215 (Refs #524) et b9775e0 (Refs #518), branche K5 `claude/application`

Rapport complet, à verser dans `docs/revues/20261110-fin-de-branche-k5/`. Je n'ai rien écrit dans le dépôt.

**Conclusion : visa pour dda1215.** Mes réserves R1 à R3 et les constats M1 à M3 de regulatory sont levés. Restent **deux réserves mineures**, aucune bloquante ni majeure :
- **RM-1**, sur le texte de b9775e0 : une phrase affirme plus que ce que le code garantit.
- **RM-2**, hors `.tex` : deux commentaires faux dans `usp_noyau()`.

Aucune des deux ne change un résultat.

Sources lues : le diff des deux commits ; `usp_noyau()` (`R/engine.R`, l. 1300-1318) ; l'encadré de `sec:base-residus` (`.tex`, l. 8340-8380) ; les lignes de `sec:h4` sur le critère (l. 11108-11215) ; `lire_tableau()` (`app.R`, l. 205-252) ; `engine_lire_donnees_csv()` (`R/engine.R`, l. 7492 et suivantes). Pour les citations, j'ai lu B(2)(g) et C(2)(e) dans la version consolidée du règlement (xhtml), en texte, sans formule.

## 1. dda1215, `sec:notations` (R1, R3)

**Loi des résidus : visa.** Avec les $\pi_t$ tenus pour connus, on a $\ln\hat\beta-\ln\beta=\sum_s\sqrt{\pi_s}\,\varepsilon_s/\sum_s\pi_s$. On en tire $z=P\varepsilon$, avec $P=I-uu'/u'u$ et $u=\sqrt{\pi}$ :
- $P$ est un projecteur de rang $T-1$ ;
- la variance de $z_t$ vaut $1-\pi_t/\sum\pi$ ;
- la covariance de $z_t$ et $z_s$ vaut $-\sqrt{\pi_t\pi_s}/\sum\pi$, toujours négative ;
- à $\pi$ constant et $T=8$ : variance $7/8$, corrélation $-(1/8)/(7/8)=-1/7$.

Le texte le dit exactement. Il est cohérent avec la ligne « Résidus standardisés » du tableau de `sec:base-residus` (l. 8351) et avec la fiche de `sec:h4` (l. 11209). La phrase qui avertit que l'estimation de $\hat\delta$ et $\hat\gamma$ n'est pas prise en compte est nécessaire et juste.

**Ratios et paramètres vrais : visa.** Le texte précise désormais que les ratios sont indépendants « sachant les $x_t$ ». Il distingue aussi la condition sur les paramètres vrais de son pendant estimé, qui renvoie à `usp_volumes_constants()` (présente à l'l. 1956 du moteur ; « au sens de » couvre sa tolérance).

**M1, indépendance des années : visa.** La qualification posée sur la ligne du modèle est exacte. Elle concorde avec `sec:h4`, qui parle de « log-vraisemblance d'observations indépendantes ».

## 2. dda1215, encadré de `sec:h3` : R2 fusionné avec M1 à M3 (écart 1 de docwriter)

**Visa.** La fusion ne déforme ni ma réserve R2 ni les constats de regulatory.

**Les citations sont exactes à la lettre** dans la version consolidée :
- B(2)(g)(i)-(ii) : « pour un segment et une année d'accident particuliers » ;
- C(2)(e)(i)-(ii) : « pour un segment et un exercice particuliers » (le (ii) de C est sous le marqueur ►C4).

**Le texte est plus juste qu'une simple citation.** Il attribue la précision aux seules hypothèses i. et ii. C'est exact : iii. (« suivent une distribution log-normale ») ne la porte pas. Lire iii. année par année reste donc une inférence, et le texte la présente bien ainsi : elle vient de la précision portée par i. et ii. et de la forme du critère, sous l'étiquette « lecture de l'outil ».

**Le reste de l'encadré est juste :**
- M3 : la forme en « $Y_t$ lognormal sachant $x_t$ » est en place.
- L'équivalence avec « $\varepsilon_t$ i.i.d. $\mathcal{N}(0,1)$ aux paramètres vrais » est exacte dans les deux sens, à $x_t$ donnés.
- La conclusion (un rejet sur les $z_t$ peut venir de H1, de H2 ou de l'indépendance des années) est juste.

Quelques redites (« propres à l'année » deux fois, « sachant le volume » puis « à $x_t$ connu ») ne touchent pas le fond. Je n'en fais pas une réserve.

## 3. Écart 2 de docwriter : « moins deux fois la log-vraisemblance gaussienne… profilée en $\ln\beta$ »

**Visa. Cette formulation est meilleure que la mienne, qui était fausse.** Le montant de B(6) et C(6) est un critère que l'on minimise ; ce n'est pas « la vraisemblance ».

Vérification sur `usp_noyau()` :
- `obj = sum(p*v^2) - sum(log(p))` est, à $T\ln 2\pi$ près, $-2\ln L$ des $\ln r_t\sim\mathcal{N}(\ln\beta-1/(2\pi_t),\,1/\pi_t)$.
- Le minimiseur en $\ln\beta$ annule $-2\sum\pi_t v_t$, ce qui donne $\ln\hat\beta=(T/2+\sum\pi_t r_t)/\sum\pi_t$. C'est la ligne `ln_beta` du code : le critère est bien profilé.

Parler de vraisemblance « gaussienne des $\ln r_t$ » plutôt que « lognormale des $y_t$ » est équivalent. Le jacobien $\sum\ln y_t$ ne dépend pas des paramètres, et « à une constante près » le couvre. C'est aussi cohérent avec `sec:h4` (« $-2\ln L$ du modèle lognormal, profilée en $\ln\beta$ »).

## 4. b9775e0, `sec:controles` (écart 3 de docwriter)

**Retrait de la mesure : visa.** La mesure n'avait ni protocole ni graine versionnés, et elle était périmée depuis le contrôle `count.fields` de `lire_tableau()`. La retirer est la bonne correction. La description du contrôle correspond au code (`app.R`, l. 232-240 : refus de toute ligne qui compte plus de champs que l'en-tête, avant `read.csv`). L'ajout dans `docs/suivi-documentation/I.md` est correct : il qualifie les remesures « sans script versionné », ce qui est un comportement observé et non une garantie.

**Réserve RM-1, mineure.** La phrase gardée, « un fichier binaire que cette lecture accepte est refusé par le moteur », énonce une propriété universelle. Ni le code ni une mesure versionnée ne l'établissent :
- Le refus vient de contrôles génériques : colonnes `xt` et `yt` exigées (`engine_lire_donnees_csv()`), puis cellules numériques. Il n'y a aucune détection de fichier binaire.
- Le cas d'un octet aléatoire qui passerait ces contrôles est négligeable, mais il n'est pas exclu.

Exigence de rigueur appliquée : ne pas présenter une observation comme une garantie.

Texte de remplacement exact, de « et qu'un fichier binaire » jusqu'au point final du paragraphe :

> et qu'un fichier binaire que cette lecture accepte passe par les mêmes contrôles du moteur que tout tableau (colonnes attendues, cellules numériques), sans détection propre aux fichiers binaires~: un fichier binaire est ainsi arrêté soit à la lecture, par R ou par le contrôle de structure de \code{lire\_tableau()}, qui refuse avant lecture toute ligne comptant plus de valeurs que l'en-tête, soit par ces contrôles du moteur.

## 5. Commentaires de `usp_noyau()` (`R/engine.R`, l. 1313 et 1315)

**Réserve RM-2, mineure.** À corriger par un commit `moteur:` séparé (circuit 3 : `coder`, puis `audit` léger). Aucun effet numérique. Il y a deux commentaires faux, pas un :
- l. 1315, `# residus standardises ~ N(0,1)` contredit `sec:base-residus` et le texte de dda1215 ;
- l. 1313, `(loi normale, var = 1/pi_t)` est faux pour la même raison : la variance de $v_t$ vaut $(1/\pi_t)(1-\pi_t/\sum_s\pi_s)$, à cause du terme commun $\ln\hat\beta$.

Texte de remplacement exact (commentaires sans accents, conformément à la règle du dépôt) :

```r
  v <- r + 1 / (2 * p) - ln_beta            # residus bruts (normaux a pi_t tenus pour connus, var = (1 - pi_t / somme(pi)) / pi_t, lies par ln_beta)
```
```r
    z       = v * sqrt(p),                  # residus standardises : a pi_t tenus pour connus, z ~ N(0, P), P projecteur de rang T - 1, et non N(0, I_T) (doc, sec:base-residus)
```

Facultatif : sur la ligne `obj`, `# -2 log-vraisemblance (a une constante pres)` est juste mais incomplet ; ajouter `, profilee en ln(beta)`.

## Classement

| Point | Verdict | Gravité |
|---|---|---|
| R1 (loi $\mathcal{N}(0,P)$) | visa | — |
| R2 + M1-M3 fusionnés (écart 1) | visa | — |
| R3 (ratios, paramètres vrais) | visa | — |
| Critère $-2\ln L$ profilée (écart 2) | visa | — |
| b9775e0, retrait de la mesure | visa | — |
| b9775e0, phrase universelle (écart 3) | réserve RM-1 | mineur |
| Commentaires de `usp_noyau()` l. 1313 et 1315 | réserve RM-2 | mineur |

## Retour

- **Statut** : complet.
- **Résultat** : visa pour dda1215. Visa pour b9775e0 sous la réserve mineure RM-1. Réserve mineure RM-2 sur deux commentaires du moteur. Les textes de remplacement sont donnés ci-dessus.
- **Preuves vérifiées** :
  - les deux diffs (`git show`) ;
  - le calcul de $P$ et des valeurs $7/8$ et $-1/7$ ;
  - `obj` et `ln_beta` de `usp_noyau()`, profilage par la condition de premier ordre ;
  - les citations de B(2)(g) et C(2)(e) dans le xhtml consolidé, et l'absence de la précision sur iii. ;
  - `lire_tableau()` (`app.R`, l. 230-252) et `engine_lire_donnees_csv()` (contrôle des colonnes `xt` et `yt`) ;
  - la cohérence avec `sec:base-residus` (l. 8351, 8372-8380) et `sec:h4`.
- **Hypothèse** : la version consolidée fait foi pour la lecture (CLAUDE.md). Je n'ai pas relu le JOUE de 2015 pour C(2)(e)(ii), qui porte le marqueur ►C4.
- **Non vérifié** : compilation du `.tex` ; `concordance_doc_moteur.R --strict`, dont le diff ne change aucun nom de fonction.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : la session décide si RM-1 est appliqué par un commit `docs:` de docwriter avant la sortie du brouillon, et si RM-2 entre dans le périmètre de K5 ou devient une issue (correctif de commentaire, aucune référence changée).
- **Critères déclenchés** : aucun. Pas de changement de résultat, pas de désaccord avec audit ni avec regulatory, pas de double lecture du texte.
- **Prochaine action recommandée** :
  1. docwriter applique RM-1, puis la skill `compiler-doc`.
  2. coder fait RM-2 dans un commit `moteur:` à part, avec un audit léger sur son diff.
  3. Verser ce rapport dans `docs/revues/20261110-fin-de-branche-k5/`.
