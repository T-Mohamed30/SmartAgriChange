# SmartAgriChange API Documentation

## Vue d'ensemble

Cette API fournit des endpoints complets pour la gestion d'une plateforme agricole intelligente, incluant la gestion des cultures, analyses de sol, capteurs IoT, et bien plus.

## Base URL

```
http://localhost:5000/api
```

## Authentification

Toutes les routes protégées nécessitent un token d'authentification. Incluez le token dans l'en-tête `Authorization`:

```
Authorization: Bearer <votre_token>
```

## Endpoints

### 1. Espèces Végétales

#### GET /especes-vegetales
Récupère toutes les espèces végétales actives.

**Paramètres de requête:**
- `type` (optionnel): Filtrer par type (fruit, légume, céréale, etc.)
- `search` (optionnel): Recherche par nom commun ou scientifique

**Exemple:**
```bash
curl -H "Authorization: Bearer <token>" \
  http://localhost:5000/api/especes-vegetales?type=fruit&search=mangue
```

#### GET /especes-vegetales/:id
Récupère une espèce végétale spécifique avec ses maladies et galerie.

#### GET /especes-vegetales/:id/optimal-params
Récupère les paramètres optimaux d'une espèce (pH, température, etc.).

### 2. Analyses de Sol

#### GET /analyses-sol
Récupère toutes les analyses de sol de l'utilisateur connecté.

#### POST /analyses-sol
Crée une nouvelle analyse de sol.

**Body:**
```json
{
  "parcelle_id": 1,
  "capteur_id": 1,
  "ph": 6.5,
  "temperature": 25.0,
  "humidite": 65.0,
  "azote": 2.1,
  "phosphore": 1.8,
  "potassium": 3.2,
  "notes": "Analyse du sol de la parcelle principale"
}
```

#### GET /analyses-sol/:id/recommendations
Récupère les recommandations générées pour une analyse.

### 3. Analyses de Plantes

#### GET /analyses-plantes
Récupère toutes les analyses de plantes de l'utilisateur.

#### POST /analyses-plantes
Crée une nouvelle analyse de plante.

**Body:**
```json
{
  "parcelle_id": 1,
  "espece_id": 1,
  "image_url": "path/to/image.jpg",
  "confiance_identification": 0.95,
  "maladies_detectees": ["Oidium", "Mildiou"],
  "anomalies_detectees": ["Taches foliaires", "Décoloration"],
  "recommandations": "Appliquer un traitement fongicide"
}
```

#### GET /analyses-plantes/stats
Récupère les statistiques des analyses de plantes.

### 4. Capteurs IoT

#### GET /capteurs
Récupère tous les capteurs de l'utilisateur.

#### POST /capteurs
Crée un nouveau capteur.

**Body:**
```json
{
  "nom": "Capteur température/humidité",
  "type": "temperature_humidity",
  "parcelle_id": 1,
  "emplacement": "Nord de la parcelle",
  "est_actif": true
}
```

#### POST /capteurs/:id/data
Enregistre des données depuis un capteur.

**Body:**
```json
{
  "temperature": 24.5,
  "humidite": 68.0,
  "ph": 6.8,
  "conductivite": 1.2
}
```

### 5. Campagnes Agricoles

#### GET /campagnes
Récupère toutes les campagnes de l'utilisateur.

#### POST /campagnes
Crée une nouvelle campagne.

**Body:**
```json
{
  "nom": "Campagne Mangue 2024",
  "parcelle_id": 1,
  "espece_id": 1,
  "analyse_sol_id": 1,
  "date_debut": "2024-01-15",
  "date_fin_prevue": "2024-06-15",
  "description": "Production de mangues Kent",
  "statut": "en_cours"
}
```

#### PATCH /campagnes/:id/progress
Met à jour la progression d'une campagne.

**Body:**
```json
{
  "progression": 75
}
```

### 6. Données Météorologiques

#### GET /weather/forecast
Récupère les prévisions météorologiques.

**Paramètres:**
- `location`: Localisation (ville, région)
- `days`: Nombre de jours (défaut: 7)

#### GET /weather/current
Récupère les conditions météorologiques actuelles.

#### POST /weather/sync
Synchronise les données météorologiques (service externe).

## Codes de Réponse

### Succès
- `200`: OK - Requête traitée avec succès
- `201`: Created - Ressource créée avec succès

### Erreurs Client
- `400`: Bad Request - Requête malformée
- `401`: Unauthorized - Authentification requise
- `403`: Forbidden - Accès interdit
- `404`: Not Found - Ressource non trouvée

### Erreurs Serveur
- `500`: Internal Server Error - Erreur interne du serveur

## Format des Réponses

Toutes les réponses suivent ce format:

### Succès
```json
{
  "success": true,
  "data": { /* données */ },
  "message": "Opération réussie"
}
```

### Erreur
```json
{
  "success": false,
  "message": "Description de l'erreur",
  "error": "Détails techniques (en développement seulement)"
}
```

## Exemples d'Utilisation

### 1. Créer une analyse de sol et obtenir des recommandations

```bash
# 1. Créer l'analyse
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "parcelle_id": 1,
    "ph": 6.2,
    "temperature": 26.0,
    "humidite": 70.0,
    "azote": 1.8,
    "phosphore": 2.1,
    "potassium": 3.5
  }' \
  http://localhost:5000/api/analyses-sol

# 2. Récupérer les recommandations générées
curl -H "Authorization: Bearer <token>" \
  http://localhost:5000/api/analyses-sol/1/recommendations
```

### 2. Analyser une plante avec IA

```bash
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "parcelle_id": 1,
    "espece_id": 1,
    "image_url": "uploads/plant_images/mangue_001.jpg",
    "confiance_identification": 0.92,
    "maladies_detectees": ["Anthracnose"],
    "recommandations": "Appliquer un fongicide à base de cuivre"
  }' \
  http://localhost:5000/api/analyses-plantes
```

### 3. Gérer une campagne agricole

```bash
# Créer une campagne
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Campagne Tomates 2024",
    "parcelle_id": 2,
    "espece_id": 5,
    "date_debut": "2024-03-01",
    "date_fin_prevue": "2024-07-01",
    "description": "Production de tomates cerises biologiques"
  }' \
  http://localhost:5000/api/campagnes

# Mettre à jour la progression
curl -X PATCH \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"progression": 45}' \
  http://localhost:5000/api/campagnes/1/progress
```

## Notes Techniques

### Base de Données
L'API utilise Sequelize ORM avec SQLite en développement et peut être configurée pour PostgreSQL/MySQL en production.

### Gestion des Erreurs
Toutes les erreurs sont capturées et retournées dans un format standardisé. Les logs détaillés sont disponibles en mode développement.

### Sécurité
- Authentification JWT requise pour toutes les routes protégées
- Validation des données d'entrée
- Sanitisation des paramètres
- Limitation du taux de requêtes (à implémenter)

### Performance
- Index optimisés sur les tables principales
- Pagination automatique pour les listes volumineuses
- Cache Redis recommandé pour la production

## Support

Pour toute question ou problème, consultez les logs du serveur ou contactez l'équipe de développement.
