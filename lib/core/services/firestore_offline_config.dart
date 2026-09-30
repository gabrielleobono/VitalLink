import 'package:cloud_firestore/cloud_firestore.dart';

/// Active la persistance hors ligne de Firestore (cache local illimité) sur
/// toutes les plateformes, avec synchronisation multi-onglets sur le web.
///
/// À appeler une seule fois, après [Firebase.initializeApp] et avant toute
/// autre lecture/écriture Firestore.
void configureFirestoreOfflinePersistence() {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    webPersistentTabManager: WebPersistentMultipleTabManager(),
  );
}
