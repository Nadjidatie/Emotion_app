# Mood Tracker 🌸

Application mobile Flutter de suivi du cycle menstruel et des émotions, avec backend Supabase.

---

## Objectifs

L'application vise à aider les utilisatrices à mieux comprendre les liens entre leur cycle menstruel et leur bien-être émotionnel. L'idée centrale est que les fluctuations hormonales influencent l'humeur, l'énergie et le sommeil — et que visualiser ces corrélations sur la durée permet de mieux se connaître et d'anticiper les variations de forme.

Les objectifs concrets sont :
- permettre un suivi quotidien rapide (questionnaire en moins de deux minutes)
- calculer automatiquement la phase du cycle et afficher des conseils adaptés
- produire des statistiques et tendances personnalisées sur la période choisie
- offrir une expérience bienveillante et non médicale, centrée sur l'auto-observation

---

## Choix d'architecture

**Flutter** a été choisi pour disposer d'une seule base de code déployable sur iOS et Android, avec un rendu natif performant.

**Supabase** remplace un backend custom : il fournit l'authentification (email/password), une base PostgreSQL hébergée et un SDK Dart prêt à l'emploi, ce qui évite de gérer un serveur.

**`CycleService` (singleton `ChangeNotifier`)** centralise tout l'état lié au cycle : calcul de phase, marquage des jours de règles, synchronisation avec Supabase. Les widgets s'y abonnent via `addListener` pour se rafraîchir automatiquement. Ce pattern a été préféré à Provider ou Riverpod pour rester simple dans le cadre d'un projet universitaire.

**`StatistiquesService` (classe statique)** regroupe tous les calculs d'analyse (score moyen, tendances, répartition des humeurs) sous forme de méthodes pures sans état. Cela facilite les tests et sépare clairement la logique de présentation.

Les **modèles** (`JournalQuotidien`, `CyclePhase`, `HumeurOption`) sont des classes Dart simples avec `toJson`/`fromJson` pour la sérialisation Supabase. Le score quotidien est calculé côté client pour rester indépendant du backend.

---

## Fonctionnalités

### Accueil
- Salutation personnalisée avec photo de profil
- Carte de la **phase actuelle du cycle** (couleur, description, conseil)
- Sélecteur de jours de règles : bande horizontale de chips pour marquer manuellement les jours de menstruation
- Raccourci vers le calendrier

### Questionnaire quotidien
Rempli une fois par jour (modifiable). Saisie de :
- Humeurs (choix multiple parmi une palette d'émojis)
- Qualité du sommeil, heures dormies, niveau de stress, énergie
- Activité physique, symptômes
- Note libre

Un **score quotidien** (0–10) est calculé automatiquement :
```
score_brut = humeur × 0.4 + sommeil × 0.3 − stress × 0.3
```
puis normalisé dans la plage 0–10.

### Calendrier
Visualisation mensuelle avec couleur par jour selon le score et la phase du cycle.

### Statistiques
Analyse sur 7 jours / 1 mois / 3 mois :
- Score moyen, sommeil moyen, total de symptômes
- Graphe d'évolution du score
- Répartition des humeurs (camembert)
- Score moyen par phase du cycle
- Tendances automatiques (progression, humeur dominante, symptôme fréquent, meilleure phase)

### Profil
Modification du prénom, photo, genre, date de naissance et paramètres du cycle (date des dernières règles, longueur du cycle, durée des règles).

### Authentification
Inscription / connexion par email via Supabase Auth. Création de profil à la première connexion.

---

## Calcul des phases du cycle

| Phase | Durée (par défaut) | Couleur |
|---|---|---|
| Menstruelle | jours 1 à `dureeRegles` | Rose `#E8A0A0` |
| Folliculaire | après les règles jusqu'à J(cycle−14) | Vert `#B7D4A8` |
| Ovulatoire | J(cycle−14) ± 1 jour | Jaune `#F5C97E` |
| Lutéale | du lendemain de l'ovulation jusqu'aux prochaines règles | Violet `#B79CED` |

---

## Structure du projet

```
lib/
├── main.dart                    # Point d'entrée, init Supabase
├── auth/
│   ├── auth_gate.dart           # Redirection selon l'état d'authentification
│   └── auth_service.dart        # Connexion / inscription / déconnexion
├── model/
│   ├── cycle_phase.dart         # Enum CyclePhase + CyclePhaseInfo (nom, couleur, conseil)
│   ├── humeurOption.dart        # Catalogue des humeurs avec valeurs numériques
│   └── journalQuotidien.dart    # Modèle du journal : champs, scoreQuotidien, toJson/fromJson
├── services/
│   ├── cycleService.dart        # Singleton ChangeNotifier : calcul de phase, marquage règles, sync Supabase
│   ├── statistiqueService.dart  # Calculs statistiques purs (score moyen, tendances, répartition)
│   ├── profile_service.dart     # Lecture / mise à jour du profil utilisateur
│   └── chatbot_service.dart     # Service chatbot
├── Pages/
│   ├── acceuil.dart             # Page d'accueil
│   ├── ajouterHumeurQuestionnaire.dart  # Questionnaire quotidien
│   ├── CalendrierPage.dart      # Calendrier mensuel
│   ├── statPage.dart            # Page statistiques
│   ├── profilPage.dart          # Page profil
│   ├── editPage.dart            # Édition du profil
│   ├── createProfil.dart        # Création de profil (première connexion)
│   ├── Connexion.dart           # Page de connexion
│   ├── Inscription.dart         # Page d'inscription
│   └── chat_page.dart           # Page chatbot
└── widgets/                     # Composants réutilisables
    ├── phaseActuelle.dart        # Carte de la phase du cycle
    ├── selecteurJoursRegles.dart # Sélecteur horizontal de jours de règles
    ├── grapheEvolutionScore.dart # Graphe linéaire du score
    ├── grapheRepartitionHumeurs.dart  # Graphe en camembert des humeurs
    ├── grapheLienCycle.dart      # Score moyen par phase
    ├── selecteurHumeurs.dart     # Grille de sélection d'humeurs
    ├── curseurEvaluation.dart    # Sliders de saisie (sommeil, stress…)
    ├── choixEtiquettes.dart      # Sélection multiple (symptômes, activité)
    └── ...
```

---

## Base de données (Supabase)

### Table `profiles`
| Colonne | Type | Description |
|---|---|---|
| `id` | uuid | Identifiant utilisateur (FK auth) |
| `prenom` | text | Prénom |
| `genre` | text | Genre |
| `date_naissance` | date | Date de naissance |
| `image_url` | text | URL photo de profil |
| `dernieres-regles` | date | Date du premier jour du dernier cycle |
| `longueur-cycle` | int | Durée du cycle en jours (défaut : 28) |
| `duree-regles` | int | Durée des règles en jours (défaut : 5) |

### Table `journal_quotidien`
| Colonne | Type | Description |
|---|---|---|
| `user_id` | uuid | FK vers profiles |
| `date` | date | Date du journal (unique par user) |
| `humeur` | float | Valeur numérique moyenne des humeurs |
| `sommeil` | float | Qualité du sommeil (0–10) |
| `stress` | float | Niveau de stress (0–10) |
| `energie` | float | Niveau d'énergie (0–10) |
| `heures_sommeil` | float | Heures dormies |
| `est_menstruation` | bool | Jour de règles (via questionnaire) |
| `activite` | text | Activité physique du jour |
| `symptomes` | text | Liste JSON des symptômes |
| `note` | text | Note libre |
| `score` | float | Score quotidien calculé |

---

## Ce que nous aurions aimé avoir le temps de faire

- **Persistance des jours de règles marqués** : les jours cochés dans le sélecteur sont actuellement en mémoire uniquement. Nous aurions voulu les sauvegarder dans une table dédiée pour les restaurer à chaque ouverture de l'application.
- **Notifications push** : rappel quotidien pour remplir le questionnaire, et alerte quelques jours avant les prochaines règles prévues.
- **Historique multi-cycles** : afficher plusieurs cycles passés dans le calendrier avec des statistiques comparatives entre cycles.
- **Personnalisation du score** : permettre à l'utilisatrice de pondérer elle-même les critères (humeur, sommeil, stress) selon ce qui compte le plus pour elle.
- **Export des données** : générer un PDF ou CSV du journal pour partager avec un médecin.

---

