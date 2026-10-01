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
}
