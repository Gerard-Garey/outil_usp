---
status: accepted
date: 2026-09-21
---

# Les tests dégénérés ou inopérants sont restitués comme diagnostics, pas retirés

À T = 8, certains tests ne peuvent rien conclure : leur statistique est constante par construction dans le cas courant (centrage et variance unitaire des résidus standardisés quand δ̂ est au bord de [0, 1], issues #3 et #5), ou leur plus petite p-value atteignable dépasse le seuil α retenu pour le calcul (Cox-Stuart, suites). Nous les restituons comme **diagnostics** — valeur affichée, sans verdict, avec la raison et, pour un test inopérant, la p-value minimale atteignable — plutôt que de les retirer ou de les garder comme tests. Le dossier ACPR montre ainsi que la vérification a été examinée et pourquoi elle ne porte pas de verdict, sans donner la fausse assurance d'un « OK » impossible à perdre.

## Considered Options

- **Retirer ces tests** : écarté, la trace de l'examen disparaîtrait du dossier.
- **Les garder comme tests marqués « non applicable » au bord** : écarté, un test applicable seulement hors du cas courant à T = 8 induit le lecteur en erreur.
- **Seuil fixe de 0,10 pour qualifier un test d'inopérant** : écarté au profit du α du calcul, cohérent avec le verdict qui en dépend déjà ; α figure dans les métadonnées de chaque calcul.

## Consequences

Le statut test / diagnostic d'une vérification peut changer avec les données et avec α ; il est déterminé par le moteur et documenté. Voir `CONTEXT.md` (test, diagnostic, test inopérant).
