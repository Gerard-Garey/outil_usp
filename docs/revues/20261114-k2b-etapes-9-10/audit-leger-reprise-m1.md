# Audit léger de la reprise M-1 (règle 10)

> Versé par la session principale (condensé fidèle). `audit`, fiche de base. 14/11/2026. Diff non commité sur `30bed39`, commité ensuite en `c848562`, `585a40d`, `20f7d50`. openxlsx 4.2.9. Sondes : `scratchpad/audit2/` de la session (non versées).

**Verdict : conforme avec réserves.** M-1, m-1, m-2 et m-3 résolus ; aucun constat bloquant ni majeur.

## Résolution

- **M-1** (`R/engine.R:8972-8974`) : sonde rejouée ; table en `xl/strings/sharedStrings.xml` refusée avec le texte fixé, avant extraction, sur les deux chemins ; deux exemplaires de même nom refusés. Tests l. 3169-3183.
- **m-1** (`R/engine.R:9022-9028`) : refusées par X1 : deux `<t>` séparés par des fins de ligne entre deux blocs `<r>` multilignes ; attribut `a="</r>"` avant deux `<t>`. Lues 11,5 sans faux refus : `<x:tab/>`, `<tx/>`, blocs `<r>` multilignes conformes, attributs contenant `>` ou `'</r>'`, `<x:rPh>` ouvrant avec `<x:t>`, fermetures de préfixes mélangés, `<t>` dans `<rPr>`. 17 classeurs réels d'openxlsx : aucun touché par M-1 (deux refusés par le contrôle de ligne 1 préexistant).
- **Performance** : 50 001 `<si>` avec `<r>` et `<rPh>`, interne : 7,2 s (6,6 s avant) ; pire cas adverse (20 000 `<r>` non fermés) : 43,3 s (43,5 s avant), quadratique déjà avant ; attribut de 2·10⁶ caractères : 0,46 s.
- **m-2**, **m-3** : résolus.

## Réserves (mineures)

1. Surface documentaire : le `.tex` (l. 4594-4615) n'énumère pas encore le refus M-1 → passage de `docwriter`.
2. Antérieur, hors diff : octet UTF-8 invalide dans la table → `grepl`/`gregexpr` avertissent et rendent vide, Q-F, P2 et X1 sautés ; aucune valeur fausse acceptée (NA, refus en aval) ; même résultat avant. Issue si le mainteneur le souhaite.

## Limites déclarées par coder

- `<x:si>` préfixé : non bloquant pour K2b, relève d'une issue ; table entièrement préfixée → refus en aval (interne) ou erreur R « SET_STRING_ELT() » (openxlsx) ; seul le mélange `<x:si>`/`<si>` fait accepter une valeur fausse (forme artificielle). Limite consignée (`R/engine.R:8902-8906`), figée par le test l. 3208.
- Segfault d'openxlsx 4.2.9 sur indice hors bornes : non bloquant, issue (contrôle de bornes avant l'appel) ; non rejoué.

Aucune question pour `actuary` ; architecture respectée (`perl = TRUE` est de R base) ; aucun résultat numérique changé.
