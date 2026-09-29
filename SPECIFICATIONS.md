# VitalLink — Spécifications & Modèle de Données MVP

## 1. Principes Clés Validés
* **Compte Citoyen Universel** : un utilisateur unique peut être demandeur ou donneur bénévole (`Prêt à donner mon sang`).
* **Lancement d'alerte ouvert à tous** : famille, proche ou personnel soignant.
* **Badges de confiance visuels** :
  * 🟠 **Alerte Citoyenne** : déclarée par la famille/proche (défaut).
  * 🟢 **Alerte Médicale Vérifiée** : confirmée ou émise par un soignant/hôpital.
* **Protection de la famille** : après engagement (`Pledge`), le donneur contacte le numéro officiel de l'hôpital/banque de sang pour confirmer sa venue avant de se déplacer.
* **Pharmacies de garde officielles** : annuaire géolocalisé avec contact direct (Appel natif et discussion WhatsApp pré-remplie).
* **IA d'assistance** : extraction du nom de médicament par vision (Rodium AI) avec validation humaine obligatoire.

---

## 2. Parcours Utilisateur du MVP

### A. Urgence Sanguine
1. **Demandeur** :
   * Formulaire express : hôpital, service, groupe recherché, nombre de poches/donneurs, urgence, contact direct.
   * Déduction automatique des groupes compatibles en code Dart.
   * Suivi en direct du nombre de donneurs mobilisés.
2. **Donneur** :
   * Découverte via push ciblée (FCM), fil public sur l'accueil ou lien partagé sur WhatsApp.
   * Fiche détaillée avec badge (Citoyenne / Médicale).
   * Clic sur `Je viens donner` avec délai estimé d'arrivée (`Dans 30 min`, `Dans 1h`).
   * Affichage du numéro du standard hospitalier et du lien Google Maps vers l'établissement.

### B. Recherche de Pharmacie & Scan IA
1. **Scan IA (Rodium AI)** : photo d'ordonnance ou de boîte $\rightarrow$ extraction du nom du médicament $\rightarrow$ confirmation manuelle par l'utilisateur.
2. **Pharmacie de garde** : tri par distance GPS $\rightarrow$ filtre de garde $\rightarrow$ bouton Appel direct ou message WhatsApp pré-rempli avec le médicament recherché.

---

## 3. Schéma de Données MVP (dbdiagram.io)

```dbml
Enum blood_group {
  "A+"
  "A-"
  "B+"
  "B-"
  "AB+"
  "AB-"
  "O+"
  "O-"
}

Enum urgency_level {
  CRITICAL
  HIGH
  MODERATE
}

Enum request_status {
  OPEN
  FULFILLED
  CLOSED
}

Enum pledge_status {
  COMMITTED
  ARRIVED
  COMPLETED
  CANCELLED
}

Table users {
  id varchar [pk, note: "UID Firebase Auth"]
  full_name varchar [not null]
  phone_number varchar [not null, unique]
  city varchar [not null]
  blood_group blood_group [null]
  is_available_donor boolean [not null, default: false]
  fcm_token varchar [null]
  created_at timestamp [not null, default: `now()`]

  indexes {
    (city, is_available_donor, blood_group) [name: "idx_available_donors"]
  }
}

Table hospitals {
  id varchar [pk]
  name varchar [not null]
  city varchar [not null]
  address varchar [not null]
  latitude decimal(10,8) [not null]
  longitude decimal(11,8) [not null]
  emergency_phone varchar [not null, note: "Numéro institutionnel appelé par le donneur"]
}

Table blood_requests {
  id varchar [pk]
  requester_id varchar [not null, ref: > users.id]
  patient_name varchar [not null]
  city varchar [not null]
  blood_group_needed blood_group [not null]
  compatible_groups "blood_group[]" [not null]
  hospital_id varchar [not null, ref: > hospitals.id]
  hospital_department varchar [null, note: "Ex: Maternité, Bloc B"]
  is_medically_verified boolean [not null, default: false, note: "Badge: Citoyenne vs Médicale"]
  urgency urgency_level [not null, default: "HIGH"]
  units_needed int [not null, default: 1]
  units_pledged int [not null, default: 0]
  contact_phone varchar [not null, note: "Numéro famille"]
  status request_status [not null, default: "OPEN"]
  notes text [null]
  created_at timestamp [not null, default: `now()`]

  indexes {
    (city, status, created_at) [name: "idx_active_alerts"]
  }
}

Table pledges {
  id varchar [pk]
  request_id varchar [not null, ref: > blood_requests.id]
  donor_id varchar [not null, ref: > users.id]
  status pledge_status [not null, default: "COMMITTED"]
  estimated_arrival varchar [not null]
  created_at timestamp [not null, default: `now()`]

  indexes {
    (request_id, donor_id) [unique, name: "one_pledge_per_donor_request"]
  }
}

Table pharmacies {
  id varchar [pk]
  name varchar [not null]
  city varchar [not null]
  address varchar [not null]
  latitude decimal(10,8) [not null]
  longitude decimal(11,8) [not null]
  geohash varchar(12) [not null]
  phone_number varchar [not null]
  whatsapp_number varchar [null]
  is_on_duty boolean [not null, default: false]
  duty_end timestamp [null]

  indexes {
    (city, is_on_duty) [name: "idx_duty_lookup"]
  }
}

4. Stack Technique & Dépendances Flutter (pubspec.yaml)

    State Management : flutter_riverpod: ^2.5.1
    Firebase Backend : firebase_core: ^3.6.0, firebase_auth: ^5.3.1, cloud_firestore: ^5.4.4, firebase_messaging: ^15.1.3
    Module IA (Rodium AI) : http: ^1.2.2, image_picker: ^1.1.2
    Géolocalisation & Actions : geolocator: ^13.0.1, geoflutterfire_plus: ^0.0.31, url_launcher: ^6.3.0
