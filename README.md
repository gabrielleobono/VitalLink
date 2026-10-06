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

Organisation modulaire en Clean Architecture / Feature-First avec Flutter Riverpod :

lib/
├── core/
│   ├── constants/             # donor_eligibility_constants.dart
│   ├── network/               # Clients réseau et connectivité
│   ├── providers/             # firestore_providers.dart (instances & streams globaux)
│   ├── router/                # app_router.dart (GoRouter, redirections auth & session)
│   ├── services/              # firestore_offline_config, launcher_service, 
│   │                          # local_notifications_service, location_service
│   ├── theme/                 # app_colors, app_palette, app_theme, theme_mode_provider
│   ├── utils/                 # blood_compatibility.dart (matrice hématologique Dart)
│   └── widgets/               # vital_link_logo.dart et composants transverses
├── features/
│   ├── auth/                  # Session citoyenne, OTP, AfricaLocations
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── blood_requests/        # Création et détail des urgences de sang, suivi
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── donor_guide/           # Guide du donneur & Quiz IA (VitaAIService)
│   │   ├── data/              # vita_ai_service.dart
│   │   └── presentation/      # Écrans du quiz interactif et compatibilité
│   ├── home/                  # Dashboard, alertes récentes, pharmacies de garde
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── pharmacy/              # Annuaire des officines, consultation des gardes
│   │   ├── data/
│   │   └── presentation/
│   ├── profile/               # Profil citoyen, statut donneur, EditLocationScreen
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── scan_ai/               # Vision Rodium AI et validation d'ordonnance
│       ├── data/
│       ├── domain/
│       └── presentation/
├── firebase_options.dart      # Configuration multi-plateformes Firebase
└── main.dart                  # Point d'entrée de l'application
tool/
└── seed_demo_data.dart        # Script de seed officiel pour l'initialisation multi-pays

 ### Modèle de Données Firestore

users/{uid}
  id, fullName, phoneNumber, country, region, city
  bloodGroup: "O-" | "O+" | "A-" | "A+" | "B-" | "B+" | "AB-" | "AB+"
  isAvailableDonor: bool
  role: "citizen" | "pharmacist" | "medical_staff" | "admin"
  fcmToken, createdAt

donors/{uid}                # Données sensibles séparées
  bloodGroup, location: GeoPoint, geohash
  available: bool, lastDonationAt: Timestamp

hospitals/{id}              # Lecture publique, écriture protégée
  name, address, city, region, country, location: GeoPoint
  emergencyPhone, isVerified

pharmacies/{id}             # Lecture publique
  name, address, city, region, country, location: GeoPoint, geohash
  phoneNumber, whatsappNumber, isOnDuty: bool, dutyEnd: Timestamp

bloodAlerts/{id}            # Fil des urgences (ZÉRO nom de patient)
  recipientBloodGroup, compatibleGroups: string[]
  unitsNeeded, unitsPledged, urgency: "CRITICAL" | "HIGH" | "MODERATE"
  hospitalId, hospitalDepartment, city, region, country
  source: "citizen" | "medical_staff"
  alertBadgeVariant: "citizen" | "verified"
  contactPhone, status: "OPEN" | "FULFILLED" | "CLOSED"
  createdAt, expiresAt

bloodAlerts/{id}/responses/{donorUid}
  status: "COMMITTED" | "ARRIVED" | "COMPLETED" | "CANCELLED"
  estimatedArrival: string ("30 min", "1 h", "2 h")
  createdAt

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
