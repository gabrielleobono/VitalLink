# VitaLien — Contexte du projet

## Vision

VitaLien est une application mobile Flutter + Firebase qui aide les patients et leurs familles, partout en Afrique francophone, à trouver en urgence **les médicaments et le sang** dont ils ont besoin. Elle relie en un seul réseau les pharmacies, les hôpitaux, les banques de sang et les donneurs volontaires.

Projet réalisé dans le cadre du Capstone du FlutterFire Summer Camp. ODD visé : **ODD 3 — Bonne santé et bien-être**.

Langue de l'interface : **français**. L'application doit fonctionner pour plusieurs pays et villes (pas seulement un pays) : l'utilisateur choisit son pays et sa ville.

## Périmètre : MVP uniquement

Ne développe **que** les fonctionnalités de cette section. Tout ce qui est listé dans « Hors périmètre » ne doit pas être implémenté, même partiellement, sauf demande explicite.

### 1. Authentification et rôles
- Connexion email/mot de passe et Google Sign-In (Firebase Auth).
- Mode invité : consultation des pharmacies de garde sans compte.
- Trois rôles :
  - `citizen` : patient / citoyen. Peut activer l'option « Je suis donneur » qui crée un profil donneur.
  - `pharmacist` : gère le stock et le statut de garde de sa pharmacie.
  - `medical_staff` : soignant ou banque de sang. **Seul ce rôle peut créer une alerte sang.**
- Les comptes `pharmacist` et `medical_staff` ont un champ `verified` validé manuellement par l'équipe. Un compte non vérifié ne peut pas agir (ni stock, ni alerte).
- Rôle `admin` réservé à l'équipe (validation des comptes via la console Firebase au MVP).

### 2. Module Urgence sanguine
- Création d'alerte (rôle `medical_staff` vérifié) : groupe sanguin du patient, hôpital, niveau de criticité (`critical`, `high`, `medium`), nombre de poches.
- Calcul automatique des groupes donneurs compatibles (voir « Règles métier »).
- **Aucune donnée nominative du patient** n'est stockée dans l'alerte.
- Notification push (FCM) aux donneurs compatibles, disponibles, éligibles, dans un rayon défini autour de l'hôpital.
- Écran donneur « Je viens donner » avec heure d'arrivée estimée choisie dans une liste (30 min, 1 h, 2 h).
- Le soignant voit les réponses en temps réel et peut marquer un donneur « Don reçu ».
- « Don reçu » met à jour `lastDonationAt` du donneur et le rend inéligible pendant le délai réglementaire.
- Une alerte expire automatiquement après une durée fixée.

### 3. Module Pharmacies de garde
- Carte et liste des pharmacies, triées par distance.
- Filtre « De garde maintenant ».
- Fiche pharmacie : horaires, bouton itinéraire (ouvre Google Maps via une URL), bouton appel, bouton WhatsApp avec message pré-rempli.
- Recherche de médicament par **nom commercial ou DCI**.
- Disponibilité par pharmacie en 3 états : `in_stock`, `limited`, `out_of_stock`.
- Espace pharmacien : mise à jour du stock des médicaments et bascule du statut de garde.

### 4. IA
- **Scan d'ordonnance** : l'utilisateur photographie une ordonnance (imprimée ou manuscrite), l'IA extrait la liste des médicaments (nom, dosage si lisible).
- **Obligatoire** : un écran de validation où l'utilisateur corrige ou supprime chaque ligne avant de lancer la recherche. L'IA ne lance jamais une recherche seule.
- Utiliser Firebase AI Logic (package `firebase_ai`, modèle Gemini) avec une réponse en JSON structuré.
- L'IA ne doit jamais donner de diagnostic, de posologie ni de conseil médical.

### 5. Guide du donneur
- Tableau de compatibilité des groupes sanguins (widget).
- Quiz d'éligibilité simple à questions fixes (âge, poids, maladie récente, tatouage récent, grossesse, délai depuis le dernier don). Pas d'IA ici.
- Message clair affiché : « Ce guide est indicatif. La décision finale revient au personnel médical. »

### 6. Hors-ligne
- Garder la persistance hors-ligne de Firestore activée.
- Le tableau de compatibilité et le guide donneur fonctionnent sans connexion (données locales).

## Hors périmètre (ne pas implémenter au MVP)
OTP par SMS, justificatif médical téléversé, suivi GPS du donneur en route, sonnerie d'urgence dédiée, carnet numérique complet, badges et gamification, tableau des stocks des banques de sang, réservation de poches, réservation de médicaments, prix et multi-devises, suggestion de génériques, scan de boîte / code-barres, assistant vocal, NLP, passerelle SMS, articles, signalement de fausses alertes, tableau de statistiques.

## Stack technique
- Flutter (dernière version stable), Dart avec null safety.
- Gestion d'état : **Riverpod**.
- Architecture : **Clean Architecture**, organisée par fonctionnalité (feature-first) :
  ```
  lib/
    core/          # thème, routing, erreurs, utilitaires, constantes
    features/
      auth/
      blood_alerts/
      donors/
      pharmacies/
      prescription_scan/
      donor_guide/
    each feature/  → data/ (sources, modèles, repositories impl)
                     domain/ (entités, repositories abstraits, use cases)
                     presentation/ (écrans, widgets, providers)
  ```
- Navigation : `go_router`, avec redirection selon l'état de connexion et le rôle.
- Firebase : Auth, Cloud Firestore, Cloud Functions (TypeScript, dans `functions/`), Cloud Messaging, AI Logic.
- Carte : `flutter_map` avec OpenStreetMap (pas de clé API nécessaire).
- Requêtes géographiques : geohash (par exemple `geoflutterfire_plus` côté app et une logique équivalente côté Functions).
- Liens externes (itinéraire, appel, WhatsApp) : `url_launcher`.

## Modèle de données Firestore

```
users/{uid}
  role: "citizen" | "pharmacist" | "medical_staff" | "admin"
  displayName, email, phone
  country, city
  verified: bool            # comptes pros uniquement
  isDonor: bool
  fcmTokens: string[]
  createdAt

donors/{uid}                # séparé de users pour limiter l'accès aux données sensibles
  bloodGroup: "O-" | "O+" | "A-" | "A+" | "B-" | "B+" | "AB-" | "AB+"
  location: GeoPoint, geohash
  available: bool
  lastDonationAt: Timestamp | null

hospitals/{id}
  name, address, phone, country, city
  location: GeoPoint, geohash

pharmacies/{id}
  name, address, phone, whatsapp, country, city
  location: GeoPoint, geohash
  ownerUid
  isOnDuty: bool
  openingHours

pharmacies/{id}/stock/{medicineId}
  medicineId, status: "in_stock" | "limited" | "out_of_stock"
  updatedAt

medicines/{id}
  brandName, dci, form, dosage
  searchKeywords: string[]  # minuscules, sans accents, préfixes pour la recherche

bloodAlerts/{id}
  recipientBloodGroup
  compatibleGroups: string[]
  units: int
  criticality: "critical" | "high" | "medium"
  hospitalId, location: GeoPoint, geohash
  createdBy (uid du soignant)
  status: "open" | "fulfilled" | "expired" | "cancelled"
  createdAt, expiresAt

bloodAlerts/{id}/responses/{donorUid}
  status: "coming" | "donated" | "cancelled"
  eta: Timestamp
  respondedAt
```

## Règles métier

### Compatibilité sanguine (globules rouges)
| Receveur | Peut recevoir de |
|---|---|
| O− | O− |
| O+ | O−, O+ |
| A− | O−, A− |
| A+ | O−, O+, A−, A+ |
| B− | O−, B− |
| B+ | O−, O+, B−, B+ |
| AB− | O−, A−, B−, AB− |
| AB+ | tous |

Ordre de priorité des notifications : donneurs du **même groupe** d'abord, puis les autres compatibles, **O− en dernier recours**. À groupe égal, trier par distance.

Un fichier `blood_compatibility.dart` existe déjà (enum `BloodGroup`, classe `BloodCompatibility`, widget `CompatibilityTable`) : le placer dans `lib/features/donor_guide/` (ou `core/` si partagé) et le réutiliser, ne pas le réécrire.

### Éligibilité d'un donneur
Un donneur est notifié seulement si : `available == true`, groupe compatible, dans le rayon, et `lastDonationAt` est nul ou plus ancien que le délai minimal.

### Constantes configurables (dans `core/constants`)
- Délai minimal entre deux dons : 90 jours.
- Rayon de recherche des donneurs : 10 km.
- Durée de vie d'une alerte : 24 heures.

## Cloud Functions (TypeScript)
- `onBloodAlertCreated` : trouve les donneurs éligibles (geohash + groupes compatibles + disponibilité + délai) et leur envoie une notification FCM, dans l'ordre de priorité.
- `onDonorResponse` : notifie le créateur de l'alerte quand un donneur répond.
- `onDonationConfirmed` : quand une réponse passe à `donated`, met à jour `donors/{uid}.lastDonationAt`.
- `expireBloodAlerts` (planifiée) : passe en `expired` les alertes dont `expiresAt` est dépassé.

L'envoi des notifications se fait **uniquement côté serveur**, jamais depuis l'application.

## Sécurité (Firestore Rules)
- Un utilisateur ne lit et n'écrit que son propre document `users/{uid}` et `donors/{uid}`.
- Les données `donors` ne sont jamais listables par les clients (lecture réservée aux Cloud Functions).
- Seul un `medical_staff` vérifié peut créer une `bloodAlert`, et seul son créateur peut la modifier.
- Seul le `pharmacist` vérifié propriétaire (`ownerUid`) peut modifier sa pharmacie et son stock.
- `pharmacies`, `hospitals`, `medicines` et le stock sont lisibles par tous, y compris en mode invité.
- Écrire des tests des règles avec l'émulateur Firebase.

## Conventions de développement
- Code (noms de classes, variables, fichiers) en anglais ; textes de l'interface et commentaires en français.
- Respecter `flutter_lints`, pas d'avertissement d'analyse.
- Aucun secret ni clé en dur dans le code.
- Écrire des tests unitaires pour la logique métier (compatibilité, éligibilité, priorité des alertes).
- Utiliser les émulateurs Firebase en développement.
- Prévoir un script de données de test (`seed`) avec des pharmacies, hôpitaux, médicaments et donneurs réalistes dans plusieurs villes d'Afrique francophone (Dakar, Abidjan, Yaoundé, Kinshasa, Cotonou, Lomé…).
- Avancer par petites étapes vérifiables et proposer un plan avant toute grosse modification.

## Ordre de développement suggéré
1. Structure du projet, thème, routing, configuration Firebase et émulateurs.
2. Authentification, rôles, mode invité.
3. Module pharmacies : carte, liste, filtre de garde, fiche, espace pharmacien.
4. Recherche de médicaments et disponibilité.
5. Profil donneur et guide du donneur.
6. Alertes sang : création, Cloud Functions de notification, réponses en temps réel, « Don reçu ».
7. Scan d'ordonnance avec écran de validation.
8. Règles de sécurité, tests, données de test, préparation de la démo.

## Scénario de démo à garantir
1. Un soignant crée une alerte pour un patient A+.
2. Un donneur O+ proche reçoit la notification sur un second téléphone et répond « Je viens ».
3. Le soignant voit la réponse en temps réel, puis marque « Don reçu ».
4. Un patient scanne une ordonnance, valide la liste, trouve une pharmacie de garde qui a le médicament et lance l'itinéraire.
