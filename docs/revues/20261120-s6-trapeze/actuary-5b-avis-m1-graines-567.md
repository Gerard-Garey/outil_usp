## Avis actuary sur m1 et les ajouts du script `tests/niveau_mw_trapeze_t8.R` (commit `766b9de`, #567, S6)

Je n'ai modifié aucun fichier. J'ai lu le § 8 (P1 à P8) et les décisions D1' de `/home/user/outil_usp/docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md`, puis le script aux lignes 30-140, 200-260, 556-640, 1015-1080, 1214-1295 et 1380-1540.

### 1. Décision m1 : j'amende P3

**Le chevauchement est confirmé par l'arithmétique.** Le script calcule la graine du bootstrap ainsi : `graine_boot("8x7", ℓ, b)` = 568·10⁶ + 2·10⁶ + 100 000 (ℓ−1) + b. Ce nombre est identique à `graine_ora(ℓ, k = b)`, c'est-à-dire 570·10⁶ + 100 000 (ℓ−1) + b (l. 233-234). Avec la même graine, le flux du bootstrap du triangle b et la génération du triangle oracle k = b consomment les mêmes nombres aléatoires.

**Le couplage touche moins de critères que ne le dit l'audit.**
- **K3, aucun couplage.** K3 confronte les statistiques observées du triangle b (graine `graine_tri`) à l'oracle S0, et le bootstrap n'y intervient pas (l. 1452-1476).
- **Fisher de K-T6, aucun couplage.** Le test compare τ(8×7) à τ(8×8) du brut de #297, sans aucun oracle (l. 1429-1449).
- **Classes de K-T6 du 8×7 contre ρ, couplage formel.** Elles passent par K1 sur 8×7 (l. 1420-1427). Seuls k ≤ R(8×7), soit 500 à 1 000 graines sur N0 = 20 000, sont communes. L'effet sur ρ est très probablement négligeable, mais il n'a pas été mesuré. Le point essentiel est qu'il viole l'indépendance τ / ρ que suppose la séparation des erreurs de P5 (points 1 et 3).
- **Θ4, aucun couplage.** Θ4 compare τ du 8×8 de #297 à ρ du 8×7, et les graines de #297 sont hors plage.

Aucun tirage de la mesure n'a encore été fait. La correction est donc gratuite et rétablit la propriété annoncée par P3. J'adopte le correctif proposé.

**Contrôle des plages (arithmétique, b ≤ R_MAX_PLAN = 2 000, k ≤ N0 = 20 000) :**

| Usage | Plage |
|---|---|
| triangles N / E | 567 000 001-567 002 000 / 567 100 001-567 102 000 |
| bootstrap g = 1 / g = 2 | 568 000 001-568 102 000 / 569 000 001-569 102 000 |
| bootstrap g = 3 | 570 000 001-570 002 000 (N) / 570 100 001-570 102 000 (E) |
| **oracle N / E (nouveau)** | **570 500 001-570 520 000 / 570 600 001-570 620 000** |
| pré-vol (triangle et bootstrap) | 571 000 001-571 100 000 |

- Les plages sont deux à deux disjointes.
- Le maximum reste 571 100 000, inférieur à 2³¹ − 1.
- Tout reste dans [567·10⁶ ; 572·10⁶[ et hors des plages de #206/#297, #305, #387 et de 360 380 123, qui ne changent pas.
- Le contrôle (graines) du script devra le confirmer à l'exécution. Mon contrôle est arithmétique, je ne l'ai pas exécuté.

**Texte à consigner** à la fin de `actuary-2a-specification-567.md`, sous un intertitre « Amendement de P3 par actuary, 20/11/2026 (audit léger de `766b9de`, constat m1) » :

> **Amendement de P3 (m1), avant tout tirage de la mesure.** La graine du bootstrap du 8×7 (g = 3), 568 000 000 + 1 000 000 × 2 + 100 000 (ℓ−1) + b, coïncidait avec celle de l'oracle k = b de la même loi (570 000 000 + 100 000 (ℓ−1) + k) : le flux du bootstrap du triangle b et la génération du triangle oracle k = b consommaient les mêmes nombres aléatoires, contraire à l'indépendance τ / ρ supposée par P5 (points 1 et 3). Le couplage ne touchait que les classes du 8×7 contre ρ (K-T6, volet K1) ; K3, le test de Fisher de K-T6 et Θ4 n'en dépendaient pas. **La ligne « oracle k » de P3 devient : 570 500 000 + 100 000 (ℓ−1) + k (k ≤ 20 000).** Plages de la mesure : triangles 567 000 001-567 102 000 ; bootstrap 568 000 001-570 102 000 (par sous-plages g, ℓ) ; oracle 570 500 001-570 620 000 ; pré-vol 571 000 001-571 100 000 : disjointes deux à deux, maximum 571 100 000 < 2³¹ − 1, toutes dans la plage réservée [567·10⁶ ; 572·10⁶[ et disjointes des plages externes listées par P3. Aucun chevauchement interne n'est admis : le contrôle (graines) le rend bloquant. Les autres lignes de P3 sont inchangées. Aucun résultat de mesure n'existait à la date de l'amendement.

### 2. Visa des sept ajouts hors P6/P7

| Ajout (localisation) | Visa | Motif |
|---|---|---|
| Θ4 contre ρ du 8×7 (l. 1519-1524) | **Accepté**, avec mention obligatoire | Le 8×7 a les mêmes 13 statistiques que le 8×8, contrôlées triangle par triangle (colonne `o8`, l. 626-631, et critère (o)). Son oracle a donc la loi de celui du 8×8 sous le plan, ce qui reste une hypothèse [H] appuyée sur (o), (g′), `o8` et (r297). Le rapport doit dire que ρ est celui du 8×7 et non celui de #297, et donner le taux `o8`. |
| K-T7 contre ρ_F (l. 257, 1492-1502) | **Accepté**, en descriptif | C'est la référence et la lecture de #297 (`docs/tableaux/20261026-issue297-calibration-famille-ln.md`, l. 45 et 57 : ρ_F = 0,099 / 0,049, majorant en présence d'atomes). Le résultat ne nourrit aucun profil. Il faut écrire « majorant » et rappeler que ρ_F est établi à B_eff = 999. |
| Θ5 par (G, clé) (l. 1511-1518) | **Amendé** | Le découpage par (G, clé) et l'union des deux α sont fidèles à P7. En revanche, Θ5 est évalué aussi sur le 8×7, qui n'est qu'un contrôle d'implémentation (K-T6). Ses clés valent celles du carré, donc un Θ5 sur 8×7 ne renseigne pas sur le trapèze et ne doit pas pouvoir proposer un profil. Il faut restreindre le profil à 8×5 et 8×6, afficher à part le 8×7 en descriptif, et indiquer l'α de chaque côté. |
| Échecs au dénominateur de τ (l. 1216, 1400) | **Accepté** | Un échec est un triangle admis dont toutes les p sont absentes. P7 le compte déjà comme non-rejet, compté à part, dans τ = k/n sur les admis. K4 le borne. |
| Lecture de K4 (l. 1479-1490) | **Accepté** | La lecture par triangle (« au moins une p_mc absente sur 13 ») est plus stricte qu'une lecture clé par clé. Le détail par clé figure en K5 (l. 1666). Une clé absente par construction sur une géométrie doit être nommée comme telle dans la lecture de Θ0. |
| Θ0 dès un K-T6 significatif (l. 1529-1531, 1689) | **Accepté**, avec libellé | Le script ne peut pas juger le « non expliqué » de P7. Il propose donc Θ0 mécaniquement, et l'explication revient à actuary. Le libellé doit dire « Θ0 candidat, explication à juger par actuary ». Une absence de KT6 ou de K3 qui met Θ0 est acceptée, puisque le contrôle manque. |
| Tolérance aux cas vides de (g′) et (rep) (l. 1218-1226, 1270-1281) | **Accepté** | Les cas exclus sont des refus « erreur » ou des cellules sans admis. K4 les met déjà en défaut, ce qui mène à Θ0, et ils sont comptés et affichés. Il reste à interdire le succès à vide de (g′) lorsque tous les triangles sont `sans_gp` (`all(logical(0))` vaut TRUE). |

### 3. Consignes pour la reprise de `coder-approfondi`

1. **P3 amendé**
   - Mettre `GRAINE_ORA <- 570500000` (l. 230).
   - Corriger l'en-tête (l. 70 et 73-76 : retirer le paragraphe sur le chevauchement) et la ligne markdown des graines (l. 1569).
   - Rendre bloquant le contrôle (graines) dès qu'un chevauchement interne apparaît : ajouter `!length(inter)` à `ok` (l. 1060) et retirer « non bloquant » (l. 1068, 1570).
2. **Θ5** : restreindre le profil à 8×5 et 8×6, lister à part le 8×7 en descriptif, et indiquer l'α de chaque côté.
3. **Libellés**
   - Θ0 : « candidat » et « explication à juger par actuary » quand K-T6 est significatif.
   - K-T7 : « référence ρ_F majorante (#297, § 5.3), descriptif ».
   - Θ4 : « ρ du 8×7 », avec le taux `o8`.
4. **(g′)** : échec si `sum(!sans_gp) == 0`.
5. **Fisher de K-T6** : rapporter dans la sortie l'effectif des lignes `rep` du brut de #297 dont le statut n'est pas « admis », pour vérifier que les dénominateurs n7 et n8 sont traités de la même façon (l. 1434). Les échecs du 8×7 sont dans n7, ceux de #297 sont exclus de n8.
6. Le md5 du script change, donc le contexte des tranches d'un dossier de travail d'essai sera refusé : repartir d'un dossier neuf. Relancer `--essai` et constater (graines) OK sans chevauchement avant la mesure (b).
7. Ce changement ne modifie aucun résultat du moteur. Il ne touche pas `tests/reference/`.

### Retour

- **Statut** : `complet` pour les deux questions, sur lecture du protocole et du code. Je n'ai rien exécuté.
- **Résultat**
  - J'amende P3 : l'oracle passe à 570 500 000 + 100 000 (ℓ−1) + k. Le texte à consigner est au § 1.
  - Cinq ajouts sont acceptés, dont trois avec un libellé ou une mention à ajouter (Θ4, K-T7, Θ0).
  - Un ajout est amendé (Θ5, restreint à 8×5 et 8×6).
  - Une condition s'ajoute pour (g′) : pas de succès à vide.
- **Preuves**
  - *Vérifié* :
    - formules des graines (l. 230-236) et arithmétique des plages ;
    - périmètre du couplage, établi par lecture de K3 (l. 1452-1476), du Fisher de K-T6 (l. 1429-1449) et de K1 (l. 1420-1427) ;
    - origine de ρ_F (#297, tableau famille LN, l. 45 et 57) ;
    - colonne `o8` (l. 626-631) ;
    - décompte des échecs (l. 1216, 1400, 1484).
  - *Hypothèses* :
    - un effet du couplage négligeable sur ρ, non mesuré ;
    - l'égalité en loi entre l'oracle du 8×7 et celui du 8×8, [H] appuyée sur (o), `o8` et (r297).
  - *Non vérifié* :
    - le codage des statuts dans le brut de #297 (consigne 5) ;
    - l'absence d'autres littéraux dans 570,5-570,62·10⁶ ailleurs dans le dépôt, que le contrôle (graines) établira.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune qui relève du mainteneur. L'amendement de P3 précède tout tirage et ne change aucun résultat.
- **Critères déclenchés** : désaccord partiel avec `audit`. Selon l'audit, l'effet est « négligeable sur K3 et le Fisher de K-T6 ». Selon ma lecture, il est nul sur ces deux critères, et le couplage ne touche que les classes du 8×7 contre ρ. Ce désaccord n'a pas de conséquence sur la décision.
- **Constats hors périmètre** : aucun (ADR 0018 : aucun).
- **Prochaine action recommandée** : la session consigne le texte du § 1 dans `/home/user/outil_usp/docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md`. Elle relance ensuite `coder-approfondi` avec les consignes 1 à 6, puis un audit léger sur le diff et un `--essai` avant la mesure (b).
