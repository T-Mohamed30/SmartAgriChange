# SmartAgriChange

SmartAgriChange est une solution numérique intelligente conçue pour accompagner les petits agriculteurs dans leurs décisions agricoles. Le MVP (Minimum Viable Product) cible deux cas d’usage essentiels :

1. **Analyse du sol avec capteur connecté** (interprétation locale)
2. **Analyse de plante par photo avec IA embarquée**

## 🎯 Objectifs du MVP

### 1. Analyse de sol
- Connexion à un capteur (NPK, EC, pH, humidité, etc.)
- Affichage des données + interprétation simple
- Suggestions de cultures compatibles avec le sol

### 2. Analyse de plante (via image)
- Prise de photo par l’utilisateur
- Identification de la plante
- Détection d’éventuelles anomalies (maladies, carences, stress)
- Conseils pratiques adaptés

## 🧑‍🌾 Utilisateurs cibles

- Petits exploitants agricoles (zones rurales ou périurbaines)
- Utilisation possible hors ligne avec synchronisation cloud dès que disponible

## 📁 Structure actuelle du projet

smartagrichange/
├── **frontend**/ # Interfaces utilisateurs
│ ├── mobile/ # Application Flutter (mobile)
│ └── web_admin/ # Dashboard Web pour les administrateurs
├── **backend**/ # API, base de données, logique métier
├── **ai_models**/ # Modèles IA (analyse des plantes)
├── **docs**/ # Spécifications, diagrammes, MCD, MLD, etc.
└── **tests**/ # Scripts ou jeux de tests futurs

---

## ✅ État d’avancement

- [x] Validation des fonctionnalités MVP
- [x] Conception du user flow (analyse sol + plante)
- [ ] Initialisation des dépôts de code
- [ ] Développement mobile (Flutter)
- [ ] Maquette et dev du dashboard web (admin)
- [ ] Développement du backend (API REST)
- [ ] Intégration modèle IA pour la détection d’anomalies végétales

---

## 🧑‍💻 Équipe

Le projet est mené par une équipe pluridisciplinaire déjà constituée. Les responsabilités sont réparties entre :
- Développement mobile/web
- Développement embarqué
- IA & Data
- Cloud
- UI/UX
- Communication

---

## 📌 Particularités

- Fonctionnement **hors-ligne** par défaut avec synchronisation automatique si connexion détectée.
- Recommandations générées localement via modèles IA allégés.