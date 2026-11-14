# Avis d'`actuary` : texte du refus M-1 (revue finale de K2b)

> Versé intégralement par la session principale (Q-54-10). Fiche de base. 14/11/2026. Tête `30bed39`. Lecture seule. Décision du mainteneur du 14/11/2026 : refuser dans K2b.

## Texte du refus (a), mot pour mot (ASCII)

```
Classeur illisible : l'archive contient une table des chaines partagees (fichier dont le nom finit par sharedStrings.xml) ailleurs qu'en xl/sharedStrings.xml, ou en contient plusieurs ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.
```

**Un seul texte pour les deux cas** :
- même cause (on ne peut pas être sûr de la table qu'openxlsx lira), même action demandée ;
- les deux cas se recouvrent : une archive à plusieurs tables en a toujours au moins une hors de `xl/`, sauf un zip contenant deux fois l'entrée `xl/sharedStrings.xml`, que « ou en contient plusieurs » couvre ;
- un seul texte suffit au test (classe `usp_refus_lecture` et texte sur les deux classeurs forgés de M-1).

**Registre.** Forme de Q-F, P2 et X1 (`R/engine.R` l. 8963, 8973, 8988), avec deux écarts volontaires :
- pas de « forme non prevue par le format » : OOXML adresse chaque partie par ses relations ; une table hors de `xl/` n'est pas, à la connaissance de l'agent, contraire au format (ECMA-376 non relue) ;
- « mal lue » au lieu de « tronquee » : hors de `xl/`, openxlsx peut lire une autre table que celle que le classeur désigne ; la troncature (11,5 lu 1) n'est que le cas mesuré.

**Mise en œuvre.** Contrôle sur `noms` (entrées de l'archive), après le contrôle de chemin, avant `utils::unzip` : refus si `sum(grepl("sharedStrings.xml$", noms)) > 1` ou si une entrée qui correspond diffère de `xl/sharedStrings.xml`. Même motif qu'openxlsx, sensible à la casse ; refus par `.refus_lecture()` sur les deux chemins.

## (b) : texte X1 inchangé

`<x:t>` est un élément `t` préfixé : « une chaine formee de plusieurs balises <t> successives » reste exacte. Seul le commentaire de code est à compléter (« prefixees ou non »). Vigilance : ne pas compter `<x:tab>` ni d'autres balises préfixées commençant par `t` (garder `XML_ATTRIBUTS_BALISE` derrière `t`) ; vérifier que le retrait des blocs `<r>` et `<rPh>` couvre leurs formes préfixées.

Hors question, non mesuré : `<si>` n'est extrait que sans préfixe (l. 8974) ; une table dont tous les éléments sont préfixés échapperait à X1. À signaler à `audit`.

## La règle (a) ne refuse aucun classeur ordinaire

**Vérifié** (`unzip -Z1` et `docProps/app.xml` sur les 17 classeurs réels d'`extdata` d'openxlsx 4.2.9) :

| Application déclarée | Classeurs | Table des chaînes |
|---|---|---|
| Microsoft Excel | 9 | une seule, `xl/sharedStrings.xml` |
| Microsoft Excel | 3 | aucune |
| Microsoft Macintosh Excel | 2 | une seule, `xl/sharedStrings.xml` |
| Microsoft Excel Online | 1 | une seule, `xl/sharedStrings.xml` |
| LibreOffice 6.4.4.2 | 1 | une seule, `xl/sharedStrings.xml` |
| LibreOffice 7.0.3.1 | 1 | une seule, `xl/sharedStrings.xml` |

**Supposé, non vérifié** : que les versions récentes d'Excel et de LibreOffice, et les autres tableurs (Google Sheets, Numbers, WPS), écrivent aussi la table à `xl/sharedStrings.xml` ; que l'emplacement hors de `xl/` est permis par le format. Un écrivain conforme mais atypique serait refusé avec un message motivé, ce qui est l'effet voulu.

## Retour

- Critères déclenchés : aucun ; aucun résultat numérique ne change.
- Prochaine action recommandée : `coder-approfondi` applique (a) et (b) ; un test par cas (table hors `xl/`, deux tables, `<x:t>`) et un témoin `<x:r><x:t>` conforme ; puis `audit` léger.
