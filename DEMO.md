VitalLink : Runbook de Démo Officiel (FFCS 2026)

Projet : VitalLink
Cible : Hackathon FFCS 2026 — ODD 3 (Bonne santé et bien-être)
Durée de présentation : 3 minutes chrono + 2 minutes Q&R
Rôle de l'application : Passerelle citoyenne d'urgence vitale (don de sang ciblé, orientation pharmacies de garde, lecture d'ordonnances assistée par IA).
1. Checklist Avant Démo (T-10 minutes)

    Appareil de test : Téléphone chargé (> 50%), mode "Ne pas déranger" activé.
    Galerie photos : 2 photos nettes d'ordonnances témoins enregistrées en local.
    Connectivité & Cache : Connexion internet active (pour Rodium AI) ; persistance hors-ligne Firestore vérifiée.
    Base Firestore : Données de démo injectées (2 hôpitaux de référence, 4 pharmacies de garde, 2 alertes urgentes de sang O+ et B+).
    Session active : Application ouverte sur le profil citoyen prêt à naviguer.

2. Déroulé Chrono de la Présentation (3 Minutes)
Minute 0:00 – 0:45 : L'Urgence Sang (ODD 3)

    Message clé : En Afrique subsaharienne, le manque de sang d'urgence coûte des vies chaque jour. VitalLink transforme chaque citoyen en donneur potentiel ciblé.
    Action écran :
        Ouvrir l'accueil VitalLink.
        Montrer le bandeau d'alerte urgente en temps réel (ex: Besoin urgent O+ à l'Hôpital Général).
        Cliquer sur le détail de l'urgence : afficher la compatibilité sanguine et l'engagement citoyen ("Je me mobilise").
    Ce qu'on dit au jury :

        "Notre modèle repose sur la fiabilité absolue : nous n'inventons aucun faux stock de poches de sang. L'alerte est médicale et localisée, mobilisant directement les citoyens compatibles."

Minute 0:45 – 1:45 : Le Scan IA d'Ordonnance (Module Rodium AI)

    Message clé : Déchiffrer une ordonnance manuscrite sans délai et sans risque d'erreur médicale.
    Action écran :
        Ouvrir l'onglet Scan IA.
        Sélectionner l'ordonnance témoin depuis la galerie.
        Lancer l'analyse (appel Rodium AI avec Gemini 2.5 Flash).
        Montrer la carte de résultat avec le médicament identifié, la posologie et le champ de validation humaine modifiable.
    Ce qu'on dit au jury :

        "L'IA analyse et extrait les principes actifs via Rodium AI, mais la validation humaine reste obligatoire avant toute recherche. Zéro hallucination, zéro automédication aveugle."

Minute 1:45 – 2:30 : Orientation Pharmacies & Appel Direct

    Message clé : Trouver rapidement une pharmacie ouverte sans faire de fausses promesses de stocks.
    Action écran :
        Valider le médicament scanné et basculer sur l'annuaire des pharmacies.
        Visualiser la liste ordonnée par proximité et statut de garde.
        Appuyer sur l'icône téléphone : l'application ouvre instantanément le composeur natif avec le numéro prérempli.
    Ce qu'on dit au jury :

        "Plutôt que d'afficher des stocks théoriques souvent périmés, nous garantissons l'adresse et les horaires réels, et connectons le citoyen directement avec l'officine en un tap."

Minute 2:30 – 3:00 : Architecture Technique & Impact

    Message clé : Robustesse d'ingénierie prête pour l'échelle continentale.
    Action écran : Revenir sur le profil citoyen unique (groupe sanguin, ville, historique solidaire).
    Ce qu'on dit au jury :

        "VitalLink est conçu en Clean Architecture et Riverpod avec une approche offline-first. Qu'on soit connecté en 4G ou hors réseau, l'accès aux données vitales reste garanti."

3. Réponses aux Questions Pièges du Jury
Question possible du jury 	Réponse d'ingénierie VitalLink
"Comment connaissez-vous le stock réel de médicaments en pharmacie ?" 	"Nous ne prétendons pas connaître les stocks internes sans interfaçage logiciel agréé. VitalLink garantit la garde, les horaires et la géolocalisation certifiée, et facilite le contact téléphonique immédiat."
"Pourquoi un seul type de compte citoyen ?" 	"Pour maximiser l'adoption sans friction. Les alertes critiques sont validées institutionnellement par les structures sanitaires partenaires, évitant le spam et les faux signalements."
"L'application fonctionne-t-elle sans réseau internet ?" 	"Oui. Les données de référence (pharmacies, hôpitaux, antécédents et alertes récentes) sont mises en cache localement via Firestore offline. Seule l'inférence IA nécessite une connexion ponctuelle."
"Comment protégez-vous les clés API ?" 	"En production, les appels d'inférence passent par un proxy backend sécurisé et Secret Manager, garantissant qu'aucune clé privée ne réside dans le binaire client."