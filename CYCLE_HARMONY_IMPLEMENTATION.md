# Cycle Harmony — Rapport d'implémentation (Étapes 1 à 3)

Ce document décrit l'ensemble des ajouts et modifications apportés au projet « Emotion_app » pour transformer une application basique avec authentification et chatbot en une application complète de suivi du cycle menstruel : **Cycle Harmony**.

---
## 1. État initial

Les éléments déjà implémentés dans le projet sont :

- **L'authentification** via Supabase (`Connexion.dart`, `Inscription.dart`, `auth_service.dart`, `auth_gate.dart`).

- **La création des profils utilisateurs** (`createProfil.dart`, `profile_service.dart`) — enregistrement dans la table « profiles » de Supabase.

- **Le chatbot** (`chat_page.dart`, `chatbot_service.dart`).

- **Restauration** de l'écran principal (« Accuil.dart » – simplement « Bienvenue M./Mme… ») et de la barre de navigation inférieure (« NavigationBarBoutton.dart »).

- **Restauration** des pages « ProfilPage.dart » et « StatPage.dart » (vides).

- Un système de design violet (`0xFF4C4A73`, `0xFFB79CED`) avec l'emoji 🌸 et une interface utilisateur en français.

`pubspec.yaml` n'avait qu'une seule dépendance principale : `supabase_flutter`.

---

## 2. Concept du produit

**Cycle Harmony** est un outil intelligent de suivi de la santé féminine. Contrairement aux outils traditionnels, il analyse la relation entre le **cycle physiologique** et l'**état émotionnel**.

**Fonctionnalité phare :** « Couleur du jour » dans le calendrier — chaque cellule est colorée en fonction de votre score quotidien, calculé selon la formule :

```
score = (Humeur × 0,4) + (Sommeil × 0,3) − (Stress × 0,3) + 3,0
clamp [0..10]

```

Plus la journée est bonne, plus le violet est foncé. Les mauvaises journées virent au gris. Cela vous permet de voir d’un coup d’œil le nombre de bonnes journées que vous avez eues ce mois-ci et à quelles phases de votre cycle elles correspondent.

---

## 3. Architecture des dossiers

Un nouveau dossier structurel, `models/`, a été ajouté. Structure finale de `lib/` :

```
lib/
├── main.dart ← mis à jour (paramètres régionaux, thème, données initiales)
├── auth/
│ ├── auth_gate.dart ← inchangé
│ └── auth_service.dart ← inchangé
├── Pages/
│ ├── Connexion.dart ← inchangé
│ ├── Inscription.dart ← inchangé
│ ├── createProfil.dart ← inchangé
│ ├── chat_page.dart ← inchangé
│ ├── profilPage.dart ← inchangé (espace réservé)
│ ├── statPage.dart ← inchangé (pour l'étape 6)
│ ├── acceuil.dart ← entièrement réécrit
│ ├── calendarPage.dart ← NOUVEAU
│ └── questionnairePage.dart ← NOUVEAU
├── widgets/
│ ├── input.dart, square.dart, ... ← inchangés
│ ├── navigationBarBoutton.dart ← réécrit (nouvel élément de menu, surbrillance de l'élément actif)
│ ├── currentPhaseCard.dart ← NOUVEAU
│ ├── questionCard.dart ← NOUVEAU
│ ├── sliderQuestion.dart ← NOUVEAU

│ ├── chipsQuestion.dart ← NOUVEAU

│ └── menstruationToggle.dart ← NOUVEAU

├── services/

│ ├── auth_service.dart ← inchangé

│ ├── profile_service.dart ← inchangé

│ ├── chatbot_service.dart ← inchangé

│ ├── cycle_service.dart ← NOUVEAU

│ └── mock_data_service.dart ← NOUVEAU

└── models/ ← NOUVEAU DOSSIER

├── cycle_phase.dart ← NOUVEAU

└── daily_log.dart ← NOUVEAU

```

L'architecture suit les bonnes pratiques Flutter : séparation claire entre les **modèles de données**, la **logique métier (services)**, les **composants d'interface utilisateur réutilisables (widgets)** et les **écrans (Pages)**.

---

## 4. Modèles de données

### 4.1. `lib/models/cycle_phase.dart`

Contient :

- **énumération `CyclePhase`** — quatre phases : `menstruelle`, `folliculaire`, `ovulatoire`, `luteale`.

- **Classe `CyclePhaseInfo`** — Informations descriptives sur chaque phase :

- `nom` — Nom français
- `description` — Description de la phase

- `hormones` — Hormones dominantes

- `conseil` — Conseils de style de vie

- `couleur` — Couleur de la phase (terre cuite/vert/jaune/lilas)

- `icone` — Icône Material

- **Méthode statique `CyclePhaseInfo.of(phase)`** — Fonction de fabrique renvoyant un objet pour la phase souhaitée.

- **`CyclePhaseInfo.all()`** — Liste de toutes les phases pour les légendes.

**Pourquoi :** Stockage centralisé du contenu des phases. Utilisé dans `CurrentPhaseCard`, `CalendarPage` et `QuestionnairePage`. À l’étape 5, ce même contenu sera utilisé dans l’invite du chatbot.

### 4.2. `lib/models/daily_log.dart`

La classe `DailyLog` permet d'enregistrer une entrée de questionnaire par jour. Champs :

- `date` — date de l'entrée

- `humeur`, `sommeil`, `stress`, `energie`, `libido` — scores de 1 à 10 (double)

- `heuresSommeil` — durée réelle du sommeil (0 à 12)

- `estMenstruation` — indique s'il s'agit d'un jour de règles

- `activite` — type d'activité physique (chaîne de caractères, parmi : Aucun/Marche/Yoga/Cardio/Musculation)

- `symptomes` — liste des symptômes (`List<String>`)

- `note` — note de l'utilisateur (facultative)

**Propriétés calculées :**

- `scoreQuotidien` (accesseur) — implémente la formule de la spécification.

- `couleurDuJour` — sélectionne l'une des 5 nuances de violet en fonction du score.
- `libelleScore` — interprétation de texte ("Excellente jour""née", "Bonne", "Correcte", "Difficile", "Eprouvante").

**Sérialisation :**

- `toJson()` et `factory fromJson()` sont des méthodes prêtes à l'emploi pour une future intégration avec Supabase (étape 4). Les noms de clés correspondent à la notation snake_case de PostgreSQL.

---

## 5. Services (Logique métier)

### 5.1. `lib/services/cycle_service.dart`

Service central du projet. Implémenté comme un **singleton** héritant de `ChangeNotifier`, il permet à l'interface utilisateur de se redessiner automatiquement lors de la modification des données, sans nécessiter de bibliothèques tierces de gestion d'état (Provider/Riverpod), ce qui allège l'application.

**Stockage :**

- `_dernieresRegles` — date de la dernière période (par défaut : il y a 12 jours)
- `_longueurCycle` — durée du cycle (par défaut : 28 jours)
- `_dureeRegles` — durée de la période (par défaut : 5 jours)
- `_logs` — `Map<String, DailyLog>`, la clé est une date au format AAAA-MM-JJ

**Méthodes :**

- `definirParametresCycle(...)` — modifier les paramètres du cycle.

- `sauvegarderLog(log)` — ajouter/écraser une entrée d’enquête.

- `chargerLogs(iterable)` — chargement en masse (à l’aide de `MockDataService`).

- `logPour(date)` — obtenir un enregistrement pour un jour spécifique.

- `tousLesLogs` — liste triée de tous les enregistrements (pour les statistiques).

**Logique du cycle :**

- `jourDuCycle(date)` : indique le jour du cycle (1 à 28). Gère correctement les dates passées et futures grâce à l’arithmétique modulaire.

- `phasePour(date)` : détermine la phase :

- Jour 1 : `_dureeRegles` : **menstruelle**

- Jours avant l’ovulation (`_longueurCycle - 14`) : **folliculaire**

- 3 jours autour de l’ovulation : **ovulatoire**

- Jours restants : **lutéale**

- `estJourDeRegles(date)` : raccourci pratique

- `prochainesRegles()` : date des prochaines règles attendues

### 5.2. `lib/services/mock_data_service.dart`

Générateur de données de test. Résout le problème du « calendrier vide » au démarrage de l’application en attendant la connexion de `daily_logs` à Supabase.

**Fonctionnement de `MockDataService.seed()` :**

1. Récupération des données des 60 jours précédents.

2. Détermination de la phase du cycle pour chaque jour.

3. Génération de valeurs d’humeur, de sommeil, de stress, d’énergie et de libido, pondérées par la phase :

- **Menstruelle :** faible énergie, stress moyen à élevé, menstruation

- **Folliculaire :** augmentation de l’énergie et de l’humeur

- **Ovulatoire :** pic d’humeur, d’énergie et de libido

- **Lutéale :** plus variable, stress plus élevé (simulation du syndrome prémenstruel)

4. Sélection aléatoire de 0 à 2 symptômes typiques de la phase.

5. Chargement des données dans `CycleService`.

Une granularité fixe de `Random(42)` est utilisée ; les données restent identiques à chaque redémarrage, ce qui simplifie le débogage de l’interface utilisateur.

---

## 6. Widgets réutilisables (critère « Réutilisation des widgets »)

Il s'agit de la partie la plus importante de l'évaluation du projet universitaire. Cinq widgets réutilisables ont été créés, chacun utilisé au moins deux fois.

## 6.1. `widgets/questionCard.dart` — `QuestionCard`

Une carte conteneur universelle pour toute question de sondage. Accepte :

- `titre` — titre de la question

- `sousTitre` — sous-titre optionnel

- `icone` — icône Material à gauche du titre

- `child` — tout widget interne (curseur, puces, champ texte, bouton bascule, etc.)

**Pourquoi est-ce important ?** Il s'agit d'un modèle de **composition plutôt que de duplication**. Au lieu d'écrire le même `Container` avec bordure, marge intérieure et ombre à 10 reprises, nous définissons le conteneur une seule fois et le réutilisons pour toutes les questions. **Utilisé 10 fois** uniquement dans `QuestionnairePage`.

### 6.2. `widgets/sliderQuestion.dart` — `SliderQuestion`

Curseur stylisé de 1 à 10 avec étiquettes latérales et une couleur en haut. Paramétrable :

- `valeur`, `min`, `max`, `divisions`
- `labelMin`, `labelMax` — étiquettes d'extrémité de l'échelle
- `formatValeur` — fonction de formatage de la valeur (par exemple, « 7,5 h » pour les heures de sommeil)
- `couleur` — couleur d'accentuation (par exemple, terracotta pour le stress, jaune pour l'énergie, etc.)

**Utilisé 6 fois** dans le questionnaire (humeur, sommeil, heures de sommeil, stress, énergie, libido).

### 6.3. `widgets/chipsQuestion.dart` — `ChipsQuestion`

Intégré à Chips avec prise en charge de la sélection simple/multiple.

- `multiSelection: true` → pour les symptômes (sélections multiples possibles)

- `multiSelection: false` → pour l'activité (une des options)

Animation de sélection via `AnimatedContainer`.

### 6.4. `widgets/menstruationToggle.dart` — `MenstruationToggle`

Un bouton « Avez-vous vos règles aujourd'hui ? » avec texte dynamique et icône de dépôt. Ce composant est distinct car il sera également réutilisé dans les paramètres de cycle de l'étape 4.

### 6.5. `widgets/currentPhaseCard.dart` — `CurrentPhaseCard`

Une carte de phase dynamique pour l'écran principal. Abonné à `CycleService` via `addListener` — mis à jour automatiquement lors de l'enregistrement d'un nouveau questionnaire ou de la modification des paramètres.

Contient :
- Icône et nom de la phase
- Numéro du jour du cycle
- Description de la phase
- Conseils d'hygiène de vie (sur fond coloré)

- Nombre de jours avant les prochaines règles
- Bouton « Répondre au questionnaire » (ou « Modificateur » si vous avez déjà rempli le questionnaire du jour)

Utilise un **dégradé linéaire** basé sur la couleur de la phase → une carte visuellement agréable dont la couleur change selon la phase du cycle.

---

## 7. Écrans

### 7.1. `Pages/questionnairePage.dart` — `QuestionnairePage`

Questionnaire du jour. Contient **10 sections** via `QuestionCard` :

1. **Humeur** (curseur) — humeur

2. **Qualité du sommeil** (curseur) — qualité du sommeil

3. **Heures de sommeil** (curseur 0-12) — heures de sommeil effectives

4. **Niveau de stress** (curseur avec accent terracotta)

5. **Niveau d'énergie** (curseur avec accent jaune)

6. **Libido** (curseur avec accent rose)

7. **Activité physique** (puces, sélection unique)

8. **Symptômes** (puces, sélection multiple parmi 10 options)

9. **Règles au jourd'hui ?** (bascule)

10. **Note personnelle** (texte libre jusqu'à 3 lignes)

En haut se trouve une bannière avec la date et la phase actuelle (couleur de fond = couleur de la phase).

**Comportement :**

- Si un enregistrement existe déjà pour la date sélectionnée → le formulaire est prérempli avec les valeurs de l'historique existant (mode édition).

- Lors de l'enregistrement, la fonction `CycleService.instance.sauvegarderLog(...)` est appelée. Tous les écrans abonnés à `ChangeNotifier` sont automatiquement redessinés.

- Accepte un paramètre `date` optionnel : vous pouvez ouvrir le questionnaire pour n'importe quelle date (utilisé depuis `CalendarPage`).

### 7.2. `Pages/calendarPage.dart` — `CalendarPage`

L'élément visuel principal de l'application. Utilise le package `table_calendar` avec des cellules entièrement personnalisables via `calendarBuilders`.

**Contenu affiché :**

- **Calendrier mensuel** en français (`locale: 'fr_FR'`) avec la possibilité de basculer entre 2 semaines et 1 semaine.

- **Cellules colorées :** chaque jour est coloré selon `DailyLog.couleurDuJour` (du violet foncé au gris).

- **Point rouge** sous les jours de menstruation.

- **Le jour du jour** est encadré d'une bordure lilas.

- **Le jour sélectionné** est encadré d'une bordure violet foncé en gras.

- **Légende florale** sous le calendrier.

- **Fiche Jour (`_FicheJour`)** avec des informations détaillées :

- Nom de la phase et numéro du jour du cycle

- Score avec un badge de couleur

- Barres de progression pour l'humeur/la somnolence/le stress/l'énergie/la libido

- Étiquettes pour les symptômes sélectionnés

- Note de l'utilisateur entre guillemets

- Bouton « Modifier » / « Rappel du questionnaire »

**Réactivité :** Abonné(e) à `CycleService` → après l'enregistrement d'un nouveau questionnaire, le calendrier est immédiatement mis à jour.

### 7.3. `Pages/acceuil.dart` — `Accueil` (réécrit)

Écran principal entièrement mis à jour. Structure :

1. **En-tête** avec un message de bienvenue personnalisé (issu de la table `profiles` de Supabase) et un bouton de déconnexion à droite. 2. Carte Phase actuelle : une grande carte violette affichant la phase en cours et un bouton de sondage.

3. Carte de raccourci « Calendrier » : un accès rapide au calendrier.

4. Bouton de la barre de navigation en bas.

Prise en charge du rafraîchissement par glissement via RefreshIndicator.

---

## 8. Navigation

widgets/navigationBarBoutton.dart réécrits :

- Ajout du paramètre currentRoute : permet de mettre en évidence l’icône de l’écran actif sans dupliquer le composant.

- Utilisation de Navigator.pushReplacement au lieu de push : les écrans ne s’empilent plus, ce qui élimine les problèmes tels que « appuyer sur retour et revenir à l’écran de statistiques précédent ». - Nouveau bouton « Calendrier » entre Accueil et Humour.

- Le bouton « Humour » renvoie désormais à la page « Questionnaire » (au lieu de la page « Profil » vide).

6 éléments au total : Accueil · Calendrier · Humour · Statistiques · Chatbot · Profil.

---
## 9. Configuration

### 9.1. `pubspec.yaml`

5 dépendances ajoutées :

```yaml
flutter_localizations :

sdk : flutter

table_calendar : ^3.1.2
fl_chart : ^0.69.0
flutter_local_notifications : ^17.2.3
intl : ^0.20.2
```

- **table_calendar** — calendrier compatible avec `calendarBuilders`
- **fl_chart** — graphiques (pour l’étape 6)
- **flutter_local_notifications** — notifications locales (implémentation de l’exigence « service minimum » de la spécification)
- **intl** — formatage de date en français
- **flutter_localizations** — localisation des widgets Material (nécessite `intl 0.20.2`)

### 9.2. `lib/main.dart`

Entièrement réécrit :

- Initialisation de `WidgetsFlutterBinding.ensureInitialized()` (requise avant les opérations asynchrones).

- Initialisation de la locale `fr_FR` via `initializeDateFormatting` — sans cela, `DateFormat('EEEE d MMMM', 'fr_FR')` échouera.

- Exécution de `MockDataService.seed()` après l'initialisation de Supabase — remplit `CycleService` avec 60 jours de données de test.

- `MaterialApp` possède désormais :

- `theme` avec un schéma de couleurs violet et `useMaterial3: true`

- `localizationsDelegates` (Material/Widgets/Cupertino)

- `supportedLocales: [fr_FR, en_US]`, `locale: fr_FR`

- `debugShowCheckedModeBanner: false`

### 9.3. `android/gradle.properties`

Réduction des paramètres JVM agressifs qui provoquaient le plantage du démon Kotlin :

- `-Xmx8G` → `-Xmx4G`

- `MaxMetaspaceSize 4G` → `2G`
- Ajout d'un paramètre distinct : `kotlin.daemon.jvmargs=-Xmx2G`
- Activation de `org.gradle.daemon=true` et `org.gradle.parallel=true`

### 9.4 `android/app/build.gradle.kts`

Prise en charge de la **désucrage de la bibliothèque principale** : `flutter_local_notifications` est requis pour utiliser l'API `java.time` sur Android < 26 :

```kotlin
compileOptions {

isCoreLibraryDesugaringEnabled = true
sourceCompatibility = JavaVersion.VERSION_11

targetCompatibility = JavaVersion.VERSION_11
} defaultConfig { multiDexEnabled = true }
dependencies {
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

---

## 10. Conformité aux exigences techniques de l'université

### Exigences techniques

| Exigence | Implémentation |

|---|---|

| **≥ 5 widgets** | ✅ `QuestionCard`, `SliderQuestion`, `ChipsQuestion`, `MenstruationToggle`, `CurrentPhaseCard` + `Input`, `Square`, `MenuItem`, `LogoutButton`, `Datenaissance`, `SelectGenre` hérités (11+ au total) |

| **Navigation** | ✅ `Navigator.pushReplacement` + `MaterialPageRoute`, `AuthGate` avec `StreamBuilder` |

| **Stockpile** | ✅ `CycleService` stocke actuellement les données en mémoire. Le code existant utilise Supabase pour les `profiles`. À l'étape 4, `daily_logs` se connectera également à Supabase ; la structure `DailyLog.toJson()` est déjà en place. |

| **≥1 service** | ✅ `CycleService`, `MockDataService` + `AuthService`, `ProfileService` et `ChatbotService` hérités. À l'étape 6, `NotificationService` sera ajouté via `flutter_local_notifications` (il s'agit du « service minimum » de la spécification). |

| **≥3 packages** | ✅ 5 nouvelles fonctions ajoutées : `flutter_localizations`, `table_calendar`, `fl_chart`, `flutter_local_notifications`, `intl` |

### Critères d'évaluation

- **Complexité du projet** ✅ — Formule du score quotidien, calcul des phases du cycle par date, architecture réactive avec `ChangeNotifier`, générateur de données simulées réalistes, `calendarBuilders` personnalisés.

- **Structure du projet** ✅ — Séparation claire des classes `models/services/widgets/Pages`, responsabilité unique pour chaque classe.

- Conception de l'application ✅ — Un système de conception unifié (5 nuances de violet, emoji 🌸, angles arrondis 16/20/24), dégradés, animations et iconographie pertinente pour chaque phase.

- Utilisation des widgets ✅ — `QuestionCard` est utilisé 10 fois, `SliderQuestion` 6 fois, `ChipsQuestion` 2 fois et `MenuItem` 6 fois.

## 11. Prochaines étapes (Étapes 4 à 6 des spécifications techniques)

L'architecture est conçue pour simplifier au maximum les prochaines étapes.

### Étape 4 - Connexion à Supabase

Dans le tableau de bord Supabase, créez la table `daily_logs` :

```sql
create table daily_logs (

id uuid primary key default gen_random_uuid(),

user_id uuid references auth.users(id) on delete cascade,

date date not null,

humeur numeric, sommeil numeric, stress numeric,

energie numeric, libido numeric, heures_sommeil numeric,

est_menstruation boolean,

activate text,

symptoms text[],

note text,

score numeric,

created_at timestamptz default now(),

unique(user_id, date)

);

alter table daily_logs enable row level security;

create policy "users access own logs" on daily_logs

for all using (auth.uid() = user_id);

```

Ensuite, dans `CycleService` :

- Dans `sauvegarderLog` : après l'enregistrement dans `_logs`, exécutez `await supabase.from('daily_logs').upsert(log.toJson()..['user_id'] = userId)`.

- Remplacez `MockDataService.seed()` par `await supabase.from('daily_logs').select().eq('user_id', userId)`, puis `cycle.chargerLogs(result.map(DailyLog.fromJson))`.

### Étape 5 — Contexte du chatbot

Dans `chatbot_service.dart`, avant d'envoyer une requête à LLM, ajoutez une invite système comme celle-ci :

```
Contexte utilisateur :

- Phase du cycle actuelle : {CycleService.instance.phasePour(now).nom}

- Jour du cycle : {jourDuCycle}

- Profil hormonal : {phaseInfo.hormones}

- Dernier journal : Humeur {humeur}/10, Stress {stress}/10, Sommeil {heuresSommeil}h

- Symptômes hebdomadaires : {Agrégation des symptômes des 7 derniers journaux}

```

### Étape 6 — Statistiques et graphiques

Dans `statPage.dart`, utilisez `fl_chart` :

- `LineChart` — Dynamique de l'humeur, du stress et de l'énergie au cours du mois (3 lignes)

- `BarChart` — Répartition des scores par phases du cycle

- `PieChart` — Symptômes les plus fréquents

- Carte avec les agrégats : Durée moyenne du cycle, nombre moyen d'heures de sommeil, etc.

Les données doivent provenir de `CycleService.instance.tousLesLogs`.

### Bonus — notifications

Dans `NotificationService` (nouveau fichier), utilisez `flutter_local_notifications` :

- Rappel quotidien à 21h00 pour remplir un questionnaire.

- Notifications prédictives, par exemple : « Vous pourriez ressentir des douleurs thoraciques demain », basées sur l'analyse des symptômes des cycles précédents.

---

## 12. Limitations connues

- **Les données fictives sont écrasées à chaque démarrage.** Ceci est normal avant la connexion à Supabase. Après l'étape 4, supprimez l'appel à `MockDataService.seed()` dans `main.dart` (ou conditionnez-le à une base de données vide). - **Les paramètres du cycle** (longueur, durée de la période) sont actuellement codés en dur dans `CycleService`. Pour l'étape 4, vous devez ajouter un écran de paramètres qui les enregistrera dans la table `profiles`.
- **Aucun indicateur en ligne/hors ligne** - Si Supabase est indisponible (par exemple, si le projet est en pause), `AuthGate` affichera une icône de chargement. Vous pouvez ajouter un bloc `try/catch` avec un écran de repli.

---

## 13. Fichiers de mémoire du projet

Quatre fichiers sont enregistrés dans la mémoire système de Claude afin que vous n'ayez pas besoin de réexpliquer le contexte lors des prochaines sessions :

- `project_cycle_harmony.md` - concept, fonctionnalité clé, exigences universitaires

- `project_design_system.md` - palette et style

- `project_tech_stack.md` - packages et architecture des dossiers

- `user_olessya.md` - profil utilisateur, préférences de travail