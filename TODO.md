# TODO - SmartAgriChange Mobile App

## Completed Tasks ✅

- [x] Créer un repository pour récupérer les analyses utilisateur (AnalysisRepository)
- [x] Mettre à jour recentAnalysesProvider pour utiliser l'API réelle
- [x] Mettre à jour allAnalysesProvider pour utiliser l'API réelle
- [x] Ajouter la navigation par onglets à HistoriqueScreen
- [x] Réduire la taille des cartes d'analyses dans HistoriqueScreen
- [x] Modifier la navigation vers HistoriqueScreen pour utiliser les routes nommées
- [x] Ajouter un TODO pour filtrer les champs par utilisateur
- [x] Ajouter la route '/historique' dans main.dart
- [x] Utiliser l'ID utilisateur réel depuis SharedPreferences au lieu de '1'
- [x] Supprimer le rappel d'irrigation du home
- [x] Corriger l'appel API des analyses avec user_id
- [x] Trier les analyses par date décroissante
- [x] Limiter les analyses récentes à 10 dernières
- [x] Implémenter le filtrage des champs par utilisateur (filtrage côté front avec userId)

## Pending Tasks ⏳

- [x] Modify AnalysisRepository.fetchUserAnalyses to fetch both soil and plant analyses from their respective endpoints
- [x] Add helper method to convert AnomalyAnalysisResponse to Analysis
- [x] Combine the lists from both fetches, sort by createdAt descending, and return the unified list
- [x] Update necessary imports for AnomalyAnalysisResponse in analysis_repository.dart
- [x] Remove unused DioClient import from analysis_repository.dart
- [x] Test the updated repository by running the app and checking the HistoriqueScreen for both soil and plant analyses (User tested: found responses with analyses and some with "0 analyses detected")
- [x] Verify API calls work correctly (API calls are working, but some responses show 0 analyses detected)
- [x] Update TODO.md to mark tasks as completed or add new ones if issues arise
- [x] Run flutter analyze to check for any linting errors (339 issues found, many related to TimeoutException constructors, missing dependencies, and other linting issues)

## Notes

- L'endpoint `users/{user}/analyses` est utilisé pour récupérer les analyses
- Les champs sont actuellement récupérés sans filtrage par utilisateur
- L'ID utilisateur est maintenant récupéré depuis SharedPreferences
- La navigation utilise maintenant les routes nommées pour une meilleure cohérence
