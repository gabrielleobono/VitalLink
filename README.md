### VitalLink 🩸

    Application mobile citoyenne facilitant l'accès d'urgence au sang et aux médicaments essentiels en Afrique francophone.
    Projet Capstone développé dans le cadre du FlutterFire Summer Camp (FFCS 2026) — Aligné sur l'ODD 3 (Bonne santé et bien-être).

### Contexte & Mission

Dans de nombreuses métropoles africaines (Douala, Yaoundé, Kinshasa, Cotonou, Bujumbura, Dakar, Abidjan, Lomé…), le temps perdu à chercher une poche de sang compatible ou une pharmacie de garde ouverte la nuit coûte des vies.

VitalLink fédère demandeurs, donneurs bénévoles, hôpitaux et officines avec trois règles non négociables :

    Zéro donnée inventée : Aucune structure fictive, aucun faux stock. Données réelles, vérifiées et sourcées.
    Protection stricte des données médicales : Aucune donnée nominative de patient n'est stockée ni publiée dans les alertes de sang.
    Appel direct institutionnel : Tout contact avec un hôpital ou une pharmacie s'effectue via le composeur natif (tel:) ou WhatsApp officiel (launcher_service.dart).

### Nos Fonctionnalités
 1. Périmètre du MVP (Version Hackathon FFCS 2026)

Le MVP regroupe l'ensemble des fonctionnalités livrées et validées pour la démonstration officielle :
### A. Compte Citoyen Universel & Authentification

    Inscription & Connexion rapide par téléphone : Authentification fluide par numéro de téléphone et vérification OTP (Firebase Auth).
    Statut Donneur en 1 clic : Tout utilisateur citoyen peut à la fois émettre une alerte pour un proche et basculer en mode « Prêt à donner mon sang » (isAvailableDonor) avec indication de son groupe sanguin.
    Référentiel Territorial Décentralisé (AfricaLocations) : Sélection du pays et de la subdivision administrative officielle dès l'inscription ou modifiable via le profil (Région pour le Cameroun, Département pour le Bénin, Province pour la RD Congo et le Burundi).

### B. Module Urgences Sanguines & Mobilisation Citoyenne

    Lancement d'Alerte Express (Demandeur) : Formulaire rapide en un écran : sélection de l'hôpital répertorié, service/département, groupe sanguin recherché, nombre de poches nécessaires, degré d'urgence (CRITICAL, HIGH, MODERATE) et numéro de téléphone direct.
    Algorithme Médical de Compatibilité Sanguine (Dart) : Déduction automatique et instantanée des groupes compatibles (ABO et Rhésus) sans calcul manuel pour sécuriser les appels.
    Badges de Confiance Visuels :
        🟠 Alerte Citoyenne : Déclarée par un proche ou la famille (statut par défaut).
        🟢 Alerte Médicale Vérifiée : Certifiée par un soignant ou une banque de sang partenaire.
    Fil Public d'Urgences & Diffusion :
        Flux des alertes en cours visible sur l'écran d'accueil (DashboardScreen), filtré automatiquement selon la région du profil.
        Bouton de partage rapide sur WhatsApp pour mobiliser au-delà de l'application.
        Notifications push ciblées (FCM) vers les donneurs compatibles de la même zone.
    Engagement Donneur en 1 Clic (Pledge) :
        Fiche détaillée de l'urgence avec localisation de l'hôpital et estimation de la distance.
        Déclaration de délai d'arrivée estimé (Dans 30 min, Dans 1 h, Dans 2 h).
        Contact téléphonique direct du standard hospitalier pour confirmation avant déplacement et ouverture de l'itinéraire cartographique.
    Suivi en Direct (Temps Réel) : Compteur dynamique des donneurs mobilisés par rapport aux besoins exprimés, et clôture de l'alerte dès couverture du besoin.

### C. Guide du Donneur & Quiz IA d'Éligibilité en Ligne (VitaAIService)

    Quiz Interactif d'Éligibilité en Ligne : Questionnaire dynamique propulsé par une IA en ligne (VitaAIService) évaluant les critères médicaux d'aptitude au don (poids, antécédents médicaux récents, tatouages, prise de médicaments, voyages).
    Tableau de Compatibilité Universelle : Matrice hématologique complète consultable à tout moment, fonctionnant sans connexion Internet.
    Avertissement Éthique & Légal : Mention systématique rappelant que le guide est informatif et que seul le personnel médical sur place valide l'aptitude finale.

### D. Scanner Médical IA (Rodium AI)

    Capture Photo : Prise de vue directe ou sélection dans la galerie d'une ordonnance papier ou d'une boîte de médicament.
    Extraction Multimodale par Vision : Identification automatique du nom commercial du médicament et de sa DCI (Dénomination Commune Internationale).
    Validation Humaine Obligatoire : Écran intermédiaire de vérification permettant à l'utilisateur de modifier, corriger ou supprimer chaque molécule détectée avant de lancer la recherche en pharmacie (zéro prescription automatique).

### E. Annuaire Géolocalisé des Pharmacies de Garde

    Géolocalisation & Proximité : Calcul de la distance GPS en temps réel jusqu'à chaque officine répertoriée (geolocator, geoflutterfire_plus).
    Filtre Officiel « De garde maintenant » : Affichage prioritaire des pharmacies ouvertes de nuit et le week-end, avec heure limite de fin de garde.
    Actions 1-Clic :
        Bouton Appeler : Déclenchement immédiat de l'appel téléphonique natif (tel:).
        Bouton WhatsApp : Ouverture d'une conversation avec message pré-rempli contenant le nom du médicament recherché.
        Bouton Itinéraire : Tracé direct via Google Maps.
    Indicateurs de Disponibilité des Produits : Statuts de stock essentiels (in_stock, limited, out_of_stock).

### 2. Vision de l'Application Complète (Post-Hackathon)

Fonctionnalités avancées constituant la feuille de route du produit global :

    Espaces Professionnels Dédiés & Certifiés :
        Espace Personnel Médical / Banques de Sang (CNTS) avec validation officielle des alertes et certification par signature numérique.
        Espace Pharmacien sécurisé pour la gestion autonome des tours de garde et la synchronisation des stocks.
    Preuve Physique du Don (Validation sur Place) :
        Confirmation du don réalisé à l'hôpital via scan de QR code sécurisé, validant le statut en COMPLETED.
        Historique personnel et carnet numérique du donneur citoyen.
    Gestion Médicale Automatisée des Délais Physiologiques :
        Blocage strict de la disponibilité des donneurs pendant 90 jours (3 mois) après un don confirmé pour respecter la récupération biologique.
    Campagnes & Collectes Mobiles Communautaires :
        Cartographie interactive et calendrier des camions de collecte mobile (Croix-Rouge, universités, places publiques).
        Notifications géolocalisées annonçant l'arrivée d'une collecte dans le quartier de l'utilisateur.
    Mode Hors-Ligne Renforcé & Synchronisation Dégradée :
        Cache Firestore persistant complet des annuaires d'urgence et numéros de permanence hospitalière, accessible en zone blanche.

### Architecture du Projet
Le projet applique une approche Feature-First et les principes de la Clean Architecture couplés à Riverpod pour la gestion d'état réactive et découplée :

```
lib/
├── core/
│   ├── constants/          # Constantes médicales (éligibilité don)
│   ├── network/            # Connectivité et clients réseau
│   ├── providers/          # Providers Firestore globaux
│   ├── router/             # app_router.dart (GoRouter, redirections auth)
│   ├── services/           # Services système natifs (GPS, WhatsApp, appels tel:)
│   ├── theme/              # Couleurs et thèmes
│   ├── utils/              # blood_compatibility.dart (matrice de compatibilité)
│   └── widgets/            # vital_link_logo.dart et composants réutilisables
│
├── features/
│   ├── auth/               # Authentification OTP et référentiel AfricaLocations
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── blood_requests/     # Urgences de sang et promesses de don (pledges)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── donor_guide/        # Guide du donneur et Quiz IA (VitaAIService)
│   │   ├── data/
│   │   └── presentation/
│   ├── home/               # Tableau de bord et alertes de la zone
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── pharmacy/           # Annuaire des officines et gardes nocturnes
│   │   ├── data/
│   │   └── presentation/
│   ├── profile/            # Profil citoyen et changement de localisation
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── scan_ai/            # Scanner ordonnances / médicaments (Rodium AI)
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── firebase_options.dart   # Configuration multi-plateformes Firebase
└── main.dart               # Point d'entrée de l'application

tool/
├── seed_demo_data.dart     # Seed hôpitaux et pharmacies multi-pays
└── seed_test_alerts.dart   # Seed alertes de test
```


##  Modèle de Données Firestore

### 1. `users/{uid}`
Profil citoyen unique et paramètres du compte.

| Champ | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Identifiant Firebase Auth (`uid`) |
| `fullName` | String | Nom complet d'usage |
| `phoneNumber` | String | Numéro de téléphone au format international |
| `country` | String | Pays (`Cameroun`, `Bénin`, `RD Congo`, `Burundi`...) |
| `region` | String | Subdivision officielle (`Centre`, `Littoral`, `Kinshasa`...) |
| `city` | String | Ville de résidence |
| `bloodGroup` | String | Groupe sanguin (`O+`, `O-`, `A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`) |
| `isAvailableDonor` | bool | Statut bénévole « Prêt à donner mon sang » |
| `role` | String | Fixé à `citizen` (compte citoyen universel) |
| `fcmToken` | String | Jeton de notification push ciblée |
| `createdAt` | Timestamp | Date de création du profil |

---

### 2. `donors/{uid}`
Index géospatial et médical séparé pour protéger les données sensibles.

| Champ | Type | Description |
| :--- | :--- | :--- |
| `bloodGroup` | String | Groupe sanguin pour ciblage d'urgence |
| `location` | GeoPoint | Coordonnées GPS du donneur |
| `geohash` | String | Index de proximité géographique |
| `available` | bool | Disponibilité active déclarée |
| `lastDonationAt` | Timestamp | Date du dernier don (délai de 90 jours) |

---

### 3. `hospitals/{id}`
Annuaire de référence des formations sanitaires.

| Champ | Type | Description |
| :--- | :--- | :--- |
| `name` | String | Dénomination officielle de l'hôpital |
| `address` | String | Adresse physique / quartier |
| `country` / `region` / `city` | String | Rattachement territorial |
| `location` | GeoPoint | Coordonnées GPS pour l'itinéraire |
| `emergencyPhone` | String | Ligne directe du standard ou des urgences (déclenche `tel:`) |
| `isVerified` | bool | Établissement certifié |

---

### 4. `pharmacies/{id}`
Annuaire des officines pharmaceutiques et gardes de nuit.

| Champ | Type | Description |
| :--- | :--- | :--- |
| `name` | String | Nom de l'officine |
| `address` | String | Adresse physique et quartier |
| `country` / `region` / `city` | String | Localisation territoriale |
| `location` | GeoPoint | Coordonnées GPS |
| `phoneNumber` | String | Appel vocal natif direct (`tel:`) |
| `whatsappNumber` | String | Contact WhatsApp avec message prérempli |
| `isOnDuty` | bool | Statut de garde active (nuit et week-end) |
| `dutyEnd` | Timestamp | Date et heure de fin de garde |

---

### 5. `bloodAlerts/{id}`
Flux des alertes de sang en direct (**zéro donnée nominative de patient**).

| Champ | Type | Description |
| :--- | :--- | :--- |
| `recipientBloodGroup` | String | Groupe sanguin recherché |
| `compatibleGroups` | List&lt;String&gt; | Groupes compatibles calculés par l'algorithme |
| `unitsNeeded` | int | Nombre de poches requises |
| `unitsPledged` | int | Nombre de promesses de don enregistrées |
| `urgency` | String | Niveau de criticité (`CRITICAL`, `HIGH`, `MODERATE`) |
| `hospitalId` | String | Référence de l'hôpital |
| `hospitalDepartment` | String | Service demandeur (ex: Réanimation, Maternité) |
| `country` / `region` / `city` | String | Localisation de l'urgence |
| `alertBadgeVariant` | String | Badge visuel (`citizen` ou `verified`) |
| `contactPhone` | String | Numéro direct d'appel d'urgence |
| `status` | String | État (`OPEN`, `FULFILLED`, `CLOSED`) |
| `createdAt` / `expiresAt` | Timestamp | Création et expiration de l'alerte |

#### Sous-collection `bloodAlerts/{id}/responses/{donorUid}`
Engagement des donneurs en temps réel :
- **`status`** : `COMMITTED` (engagé), `ARRIVED` (sur place), `COMPLETED` (don validé), `CANCELLED`.
- **`estimatedArrival`** : Délai annoncé (`Dans 30 min`, `Dans 1 h`, `Dans 2 h`).
- **`createdAt`** : Horodatage de la promesse de don.


###  Sécurité & Règles Firestore (firestore.rules)

    Anonymat médical strict : Tout document d'alerte contenant des informations nominatives de patient (patientName, patientFullName) est systématiquement rejeté à l'écriture.
    Rôles verrouillés : Inscription cliente obligatoirement fixée sur role == 'citizen' avec verified == false.
    Intégrité des annuaires : Interdiction totale des écritures clientes directes sur hospitals et pharmacies en production (allow write: if false;). L'alimentation des structures de référence passe par le script de seed.

### Stack Technique

    #Langage & Framework : Flutter 3.x / Dart 3.x (Null safety)
    Gestion d'état : flutter_riverpod (^2.5.1)
    Services Firebase : firebase_core, firebase_auth (OTP), cloud_firestore, firebase_messaging
    Modules IA :
        Quiz Éligibilité Donneur : Service IA en ligne (VitaAIService)
        Scanner Ordonnances & Boîtes : Vision API Rodium AI (http, image_picker)
    Cartographie & Téléphonie : geolocator, geoflutterfire_plus, url_launcher

 Installation & Démarrage
### 1. Installation du projet

git clone https://github.com/gabrielleobono/VitalLink.git
cd VitalLink
flutter pub get

2. Configuration locale

Ajoutez votre clé d'API Rodium locale (strictement ignorée par Git, jamais intégrée dans un APK distribué) :

# Soit dans un fichier .env à la racine :
RODIUM_API_KEY=votre_cle_locale_rodium

# Soit via --dart-define lors du lancement :
flutter run --dart-define=RODIUM_API_KEY=votre_cle_locale_rodium

3. Exécution

# Mode Debug avec Hot Reload
flutter run

# Mode Release (validation finale)
flutter run --release

4. Peuplement des données de démonstration (Seed)

# Hôpitaux et pharmacies multi-pays (Cameroun, Bénin, Burundi, RDC)
flutter run -t tool/seed_demo_data.dart

# Alertes de sang de test (avec utilisateur connecté)
flutter run -t tool/seed_test_alerts.dart

5. Vérification du code

dart format .
flutter analyze

👥 Équipe Projet & Remerciements

Développé pour le FlutterFire Summer Camp 2026.
Runbook de soutenance et protocole de démonstration disponibles dans DEMO.md.
