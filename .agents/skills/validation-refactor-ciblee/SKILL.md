---
name: validation-refactor-ciblee
description: "Use when: valider rapidement un refactor, choisir les tests impactes, faire des checks minimaux fiables sans lancer toute la suite"
---

# Skill: Validation Refactor Ciblee

## But
Valider un refactor avec un cout minimal (temps + tokens) en executant uniquement les checks utiles.

## Quand l'utiliser
- Apres chaque lot de simplification.
- Quand la suite complete est trop couteuse.
- Quand il faut iterer vite avec un filet de securite.

## Entrees attendues
- Liste des fichiers modifies.
- Niveau de confiance demande (rapide, standard, strict).

## Procedure
1. Associer chaque fichier modifie a ses tests directs.
2. Executer d'abord les tests unitaires les plus proches.
3. Ajouter un smoke run sur le script principal touche.
4. Si echec: corriger localement puis relancer uniquement le sous-ensemble concerne.
5. Reporter clairement ce qui a ete execute et ce qui ne l'a pas ete.

## Verification minimale
- Tests impactes passes.
- Aucun nouvel echec lint/compile dans les fichiers modifies.

## Critere de fin
- Resultat binaire clair: valide / non valide.
- Couverture de verification proportionnee au risque.

## Limites
- Ne pas pretendre a une validation exhaustive si seuls des tests cibles ont ete lances.
- Ne pas lancer des commandes d'installation de dependances.
