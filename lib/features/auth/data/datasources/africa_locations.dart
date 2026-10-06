/// Pays et villes d'Afrique francophone proposés à l'inscription — cf.
/// CONTEXT.md ("plusieurs villes d'Afrique francophone : Dakar, Abidjan,
/// Yaoundé, Kinshasa, Cotonou, Lomé…").
abstract final class AfricaLocations {
  static const Map<String, List<String>> citiesByCountry = {
    'Cameroun': ['Douala', 'Yaoundé', 'Garoua'],
    'Bénin': ['Cotonou', 'Porto-Novo', 'Parakou'],
    'RD Congo': ['Kinshasa', 'Lubumbashi', 'Goma'],
    'Burundi': ['Bujumbura', 'Gitega', 'Ngozi'],
    'Sénégal': ['Dakar', 'Thiès', 'Saint-Louis'],
    "Côte d'Ivoire": ['Abidjan', 'Yamoussoukro', 'Bouaké'],
    'Togo': ['Lomé', 'Kara', 'Sokodé'],
  };

  static const Map<String, String> flagByCountry = {
    'Cameroun': '🇨🇲',
    'Bénin': '🇧🇯',
    'RD Congo': '🇨🇩',
    'Burundi': '🇧🇮',
    'Sénégal': '🇸🇳',
    "Côte d'Ivoire": '🇨🇮',
    'Togo': '🇹🇬',
  };

  static const Map<String, String> dialCodeByCountry = {
    'Cameroun': '+237',
    'Bénin': '+229',
    'RD Congo': '+243',
    'Burundi': '+257',
    'Sénégal': '+221',
    "Côte d'Ivoire": '+225',
    'Togo': '+228',
  };

  /// Premier niveau de subdivision administrative, pour le filtrage
  /// géographique des alertes (un utilisateur ne voit que les alertes de son
  /// pays ET de sa région/province). Peu importe le nom local du niveau
  /// (région, département, province) : seule la valeur compte pour filtrer.
  ///
  /// Couvre pour l'instant uniquement les 4 pays validés (Cameroun, Bénin,
  /// RD Congo, Burundi — Burundi vérifié post-réforme 2023 : 18 → 5
  /// provinces). Les 3 autres pays de [citiesByCountry] n'ont pas encore de
  /// liste de régions vérifiée ; [regionOptionsFor] retombe alors sur la
  /// liste des villes en attendant.
  static const Map<String, List<String>> regionsByCountry = {
    'Cameroun': [
      'Adamaoua',
      'Centre',
      'Est',
      'Extrême-Nord',
      'Littoral',
      'Nord',
      'Nord-Ouest',
      'Ouest',
      'Sud',
      'Sud-Ouest',
    ],
    'Bénin': [
      'Alibori',
      'Atacora',
      'Atlantique',
      'Borgou',
      'Collines',
      'Couffo',
      'Donga',
      'Littoral',
      'Mono',
      'Ouémé',
      'Plateau',
      'Zou',
    ],
    'RD Congo': [
      'Bas-Uele',
      'Équateur',
      'Haut-Katanga',
      'Haut-Lomami',
      'Haut-Uele',
      'Ituri',
      'Kasaï',
      'Kasaï-Central',
      'Kasaï-Oriental',
      'Kinshasa',
      'Kongo-Central',
      'Kwango',
      'Kwilu',
      'Lomami',
      'Lualaba',
      'Mai-Ndombe',
      'Maniema',
      'Mongala',
      'Nord-Kivu',
      'Nord-Ubangi',
      'Sankuru',
      'Sud-Kivu',
      'Sud-Ubangi',
      'Tanganyika',
      'Tshopo',
      'Tshuapa',
    ],
    'Burundi': ['Buhumuza', 'Bujumbura', 'Burunga', 'Butanyerera', 'Gitega'],
  };

  /// Nom local du niveau de subdivision ("Région", "Province", ...), pour
  /// l'étiquette affichée à l'écran.
  static const Map<String, String> regionLabelByCountry = {
    'Cameroun': 'Région',
    'Bénin': 'Département',
    'RD Congo': 'Province',
    'Burundi': 'Province',
  };

  /// Options à proposer pour le sélecteur de région d'un [country] donné :
  /// la vraie liste si elle est vérifiée, sinon la liste des villes en repli.
  static List<String> regionOptionsFor(String country) =>
      regionsByCountry[country] ?? citiesByCountry[country] ?? const [];

  /// Étiquette à afficher pour le sélecteur de région d'un [country] donné.
  static String regionLabelFor(String country) =>
      regionLabelByCountry[country] ?? 'Ville';
}
