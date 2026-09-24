import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezoneOption {
  const TimezoneOption({
    required this.value,
    required this.label,
    required this.searchText,
    required this.offsetMinutes,
  });

  /// IANA timezone name (e.g. 'America/Los_Angeles').
  /// This is what gets saved to the server/DB.
  final String value;

  /// Human-readable display label including UTC offset prefix.
  final String label;

  /// Searchable text derived from the IANA path and label.
  final String searchText;

  /// Current UTC offset in minutes, computed dynamically.
  /// Always DST-correct at initialization time.
  final int offsetMinutes;
}

/// Curated display labels for well-known IANA timezones.
/// Format: 'Timezone Name - City, City' (WITHOUT UTC offset prefix).
/// The offset prefix is prepended dynamically by `_buildTimezoneOptions`.
///
/// Entries not in this map get an auto-generated label from their IANA path.
const Map<String, String> _kTimezoneLabels = <String, String>{
  // ── Africa ──
  'Africa/Abidjan': 'Greenwich Mean Time - Abidjan, Abobo',
  'Africa/Algiers': 'Central European Time - Algiers, Oran',
  'Africa/Bissau': 'Greenwich Mean Time - Bissau, Gabú',
  'Africa/Cairo': 'Eastern European Time - Cairo, Alexandria',
  'Africa/Casablanca': 'Western European Time - Casablanca, Rabat',
  'Africa/Ceuta': 'Central European Time - Ceuta',
  'Africa/El_Aaiun': 'Western European Time - Laayoune, Dakhla',
  'Africa/Johannesburg': 'South Africa Time - Johannesburg, Cape Town',
  'Africa/Juba': 'Central Africa Time - Juba, Winejok',
  'Africa/Khartoum': 'Central Africa Time - Khartoum, Omdurman',
  'Africa/Lagos': 'West Africa Time - Lagos, Kano',
  'Africa/Maputo': 'Central Africa Time - Maputo, Matola',
  'Africa/Monrovia': 'Greenwich Mean Time - Monrovia, Gbarnga',
  'Africa/Nairobi': 'East Africa Time - Nairobi, Kakamega',
  'Africa/Ndjamena': 'West Africa Time - N\'Djamena',
  'Africa/Sao_Tome': 'Greenwich Mean Time - São Tomé',
  'Africa/Tripoli': 'Eastern European Time - Tripoli, Benghazi',
  'Africa/Tunis': 'Central European Time - Tunis, Sfax',
  'Africa/Windhoek': 'Central Africa Time - Windhoek, Rundu',

  // ── Americas ──
  'America/Adak': 'Hawaii-Aleutian Time - Adak',
  'America/Anchorage': 'Alaska Time - Anchorage, Fairbanks',
  'America/Araguaina': 'Brasilia Time - Araguaína',
  'America/Argentina/Buenos_Aires': 'Argentina Time - Buenos Aires, Córdoba',
  'America/Argentina/Catamarca': 'Argentina Time - Catamarca',
  'America/Argentina/Cordoba': 'Argentina Time - Córdoba',
  'America/Argentina/Jujuy': 'Argentina Time - Jujuy',
  'America/Argentina/La_Rioja': 'Argentina Time - La Rioja',
  'America/Argentina/Mendoza': 'Argentina Time - Mendoza',
  'America/Argentina/Rio_Gallegos': 'Argentina Time - Rio Gallegos',
  'America/Argentina/Salta': 'Argentina Time - Salta',
  'America/Argentina/San_Juan': 'Argentina Time - San Juan',
  'America/Argentina/San_Luis': 'Argentina Time - San Luis',
  'America/Argentina/Tucuman': 'Argentina Time - Tucumán',
  'America/Argentina/Ushuaia': 'Argentina Time - Ushuaia',
  'America/Asuncion': 'Paraguay Time - Asunción, Ciudad del Este',
  'America/Bahia': 'Brasilia Time - Bahia',
  'America/Bahia_Banderas': 'Central Time - Bahía de Banderas',
  'America/Barbados': 'Atlantic Time - Bridgetown',
  'America/Belem': 'Brasilia Time - Belém',
  'America/Belize': 'Central Time - Belize City, San Pedro',
  'America/Boa_Vista': 'Amazon Time - Boa Vista',
  'America/Bogota': 'Colombia Time - Bogotá, Cali',
  'America/Boise': 'Mountain Time - Boise',
  'America/Cambridge_Bay': 'Mountain Time - Cambridge Bay',
  'America/Campo_Grande': 'Amazon Time - Campo Grande',
  'America/Cancun': 'Eastern Time - Cancún, Chetumal',
  'America/Caracas': 'Venezuela Time - Caracas, Maracaibo',
  'America/Cayenne': 'French Guiana Time - Cayenne, Matoury',
  'America/Chicago': 'Central Time - Chicago, Houston',
  'America/Chihuahua': 'Central Mexican Time - Chihuahua',
  'America/Ciudad_Juarez': 'Mountain Time - Ciudad Juárez',
  'America/Costa_Rica': 'Central Time - San José, Limón',
  'America/Coyhaique': 'Chile Time - Coyhaique',
  'America/Cuiaba': 'Amazon Time - Cuiabá',
  'America/Danmarkshavn': 'Greenwich Mean Time - Danmarkshavn',
  'America/Dawson': 'Yukon Time - Dawson',
  'America/Dawson_Creek': 'Mountain Time - Dawson Creek',
  'America/Denver': 'Mountain Time - Denver, El Paso',
  'America/Detroit': 'Eastern Time - Detroit',
  'America/Edmonton': 'Mountain Time - Calgary, Edmonton',
  'America/Eirunepe': 'Acre Time - Eirunepe',
  'America/El_Salvador': 'Central Time - San Salvador, Soyapango',
  'America/Fort_Nelson': 'Mountain Time - Fort Nelson',
  'America/Fortaleza': 'Brasilia Time - Fortaleza',
  'America/Glace_Bay': 'Atlantic Time - Glace Bay',
  'America/Goose_Bay': 'Atlantic Time - Goose Bay',
  'America/Grand_Turk': 'Eastern Time - Providenciales, Cockburn Town',
  'America/Guatemala': 'Central Time - Guatemala City, Villa Nueva',
  'America/Guayaquil': 'Ecuador Time - Quito, Guayaquil',
  'America/Guyana': 'Guyana Time - Georgetown, Linden',
  'America/Halifax': 'Atlantic Time - Halifax, Sydney',
  'America/Havana': 'Cuba Time - Havana, Santiago de Cuba',
  'America/Hermosillo': 'Mexican Pacific Time - Hermosillo, Culiacán',
  'America/Indiana/Indianapolis': 'Eastern Time - Indianapolis',
  'America/Indiana/Knox': 'Central Time - Knox, Indiana',
  'America/Indiana/Marengo': 'Eastern Time - Marengo, Indiana',
  'America/Indiana/Petersburg': 'Eastern Time - Petersburg, Indiana',
  'America/Indiana/Tell_City': 'Central Time - Tell City, Indiana',
  'America/Indiana/Vevay': 'Eastern Time - Vevay, Indiana',
  'America/Indiana/Vincennes': 'Eastern Time - Vincennes, Indiana',
  'America/Indiana/Winamac': 'Eastern Time - Winamac, Indiana',
  'America/Inuvik': 'Mountain Time - Inuvik',
  'America/Iqaluit': 'Eastern Time - Iqaluit',
  'America/Jamaica': 'Eastern Time - Kingston, New Kingston',
  'America/Juneau': 'Alaska Time - Juneau',
  'America/Kentucky/Louisville': 'Eastern Time - Louisville',
  'America/Kentucky/Monticello': 'Eastern Time - Monticello, Kentucky',
  'America/La_Paz': 'Bolivia Time - La Paz, Santa Cruz de la Sierra',
  'America/Lima': 'Peru Time - Lima, Callao',
  'America/Los_Angeles': 'Pacific Time - Los Angeles, San Diego',
  'America/Maceio': 'Brasilia Time - Maceió',
  'America/Managua': 'Central Time - Managua, León',
  'America/Manaus': 'Amazon Time - Manaus',
  'America/Martinique': 'Atlantic Time - Fort-de-France, Le Lamentin',
  'America/Matamoros': 'Central Time - Reynosa, Heroica Matamoros',
  'America/Mazatlan': 'Mexican Pacific Time - Mazatlán',
  'America/Menominee': 'Central Time - Menominee',
  'America/Merida': 'Central Time - Mérida',
  'America/Metlakatla': 'Alaska Time - Metlakatla',
  'America/Mexico_City': 'Central Time - Mexico City, Iztapalapa',
  'America/Miquelon': 'St. Pierre & Miquelon Time - Saint-Pierre',
  'America/Moncton': 'Atlantic Time - Moncton',
  'America/Monterrey': 'Central Time - Monterrey',
  'America/Montevideo': 'Uruguay Time - Montevideo, Salto',
  'America/New_York': 'Eastern Time - New York City, Brooklyn',
  'America/Nome': 'Alaska Time - Nome',
  'America/Noronha': 'Fernando de Noronha Time - Noronha',
  'America/North_Dakota/Beulah': 'Central Time - Beulah, North Dakota',
  'America/North_Dakota/Center': 'Central Time - Center, North Dakota',
  'America/North_Dakota/New_Salem': 'Central Time - New Salem, North Dakota',
  'America/Nuuk': 'Greenland Time - Nuuk',
  'America/Ojinaga': 'Central Time - Ojinaga',
  'America/Panama': 'Eastern Time - Panamá, San Miguelito',
  'America/Paramaribo': 'Suriname Time - Paramaribo, Blauwgrond',
  'America/Phoenix': 'Mountain Time - Phoenix, Tucson',
  'America/Port-au-Prince': 'Eastern Time - Port-au-Prince, Carrefour',
  'America/Porto_Velho': 'Amazon Time - Porto Velho',
  'America/Puerto_Rico': 'Atlantic Time - San Juan, Bayamón',
  'America/Punta_Arenas': 'Chile Time - Punta Arenas',
  'America/Rankin_Inlet': 'Central Time - Rankin Inlet',
  'America/Recife': 'Brasilia Time - Recife',
  'America/Regina': 'Central Time - Saskatoon, Regina',
  'America/Resolute': 'Central Time - Resolute',
  'America/Rio_Branco': 'Acre Time - Rio Branco, Cruzeiro do Sul',
  'America/Santarem': 'Brasilia Time - Santarém',
  'America/Santiago': 'Chile Time - Santiago, Puente Alto',
  'America/Santo_Domingo': 'Atlantic Time - Santo Domingo',
  'America/Sao_Paulo': 'Brasilia Time - São Paulo, Rio de Janeiro',
  'America/Scoresbysund': 'East Greenland Time - Ittoqqortoormiit',
  'America/Sitka': 'Alaska Time - Sitka',
  'America/St_Johns': 'Newfoundland Time - St. John\'s',
  'America/Swift_Current': 'Central Time - Swift Current',
  'America/Tegucigalpa': 'Central Time - Tegucigalpa, San Pedro Sula',
  'America/Thule': 'Atlantic Time - Thule',
  'America/Tijuana': 'Pacific Time - Tijuana, Mexicali',
  'America/Toronto': 'Eastern Time - Toronto, Montréal',
  'America/Vancouver': 'Pacific Time - Vancouver, Surrey',
  'America/Whitehorse': 'Yukon Time - Whitehorse',
  'America/Winnipeg': 'Central Time - Winnipeg, Brandon',
  'America/Yakutat': 'Alaska Time - Yakutat',

  // ── Antarctica ──
  'Antarctica/Casey': 'Australian Western Time - Casey',
  'Antarctica/Davis': 'Davis Time - Davis',
  'Antarctica/Macquarie': 'Australian Eastern Time - Macquarie Island',
  'Antarctica/Mawson': 'Mawson Time - Mawson',
  'Antarctica/Palmer': 'Chile Time - Palmer',
  'Antarctica/Rothera': 'Rothera Time - Rothera',
  'Antarctica/Troll': 'Greenwich Mean Time - Troll',
  'Antarctica/Vostok': 'Vostok Time - Vostok',

  // ── Asia ──
  'Asia/Almaty': 'Kazakhstan Time - Almaty, Shymkent',
  'Asia/Amman': 'Eastern European Time - Amman, Zarqa',
  'Asia/Anadyr': 'Anadyr Time - Anadyr',
  'Asia/Aqtau': 'Kazakhstan Time - Aktau',
  'Asia/Aqtobe': 'Kazakhstan Time - Aktobe',
  'Asia/Ashgabat': 'Turkmenistan Time - Ashgabat, Türkmenabat',
  'Asia/Atyrau': 'Kazakhstan Time - Atyrau',
  'Asia/Baghdad': 'Arabian Time - Baghdad, Basra',
  'Asia/Baku': 'Azerbaijan Time - Baku, Sumqayıt',
  'Asia/Bangkok': 'Indochina Time - Bangkok, Samut Prakan',
  'Asia/Barnaul': 'Barnaul Time - Barnaul',
  'Asia/Beirut': 'Eastern European Time - Beirut',
  'Asia/Bishkek': 'Kyrgyzstan Time - Bishkek, Osh',
  'Asia/Chita': 'Yakutsk Time - Chita',
  'Asia/Colombo': 'India Time - Colombo',
  'Asia/Damascus': 'Eastern European Time - Damascus, Aleppo',
  'Asia/Dhaka': 'Bangladesh Time - Dhaka, Chattogram',
  'Asia/Dili': 'Timor-Leste Time - Dili',
  'Asia/Dubai': 'Gulf Time - Dubai, Abu Dhabi',
  'Asia/Dushanbe': 'Tajikistan Time - Dushanbe',
  'Asia/Famagusta': 'Eastern European Time - Famagusta',
  'Asia/Gaza': 'Eastern European Time - Gaza',
  'Asia/Hebron': 'Eastern European Time - Hebron, East Jerusalem',
  'Asia/Ho_Chi_Minh': 'Indochina Time - Ho Chi Minh City, Cần Thơ',
  'Asia/Hong_Kong': 'Hong Kong Time - Hong Kong',
  'Asia/Hovd': 'Hovd Time - Khovd',
  'Asia/Irkutsk': 'Irkutsk Time - Irkutsk, Ulan-Ude',
  'Asia/Jakarta': 'Western Indonesia Time - Jakarta, Surabaya',
  'Asia/Jayapura': 'Eastern Indonesia Time - Jayapura, Ambon',
  'Asia/Jerusalem': 'Israel Time - Jerusalem, Tel Aviv',
  'Asia/Kabul': 'Afghanistan Time - Kabul, Herāt',
  'Asia/Kamchatka': 'Kamchatka Time - Petropavlovsk-Kamchatsky',
  'Asia/Karachi': 'Pakistan Time - Karachi, Lahore',
  'Asia/Kathmandu': 'Nepal Time - Kathmandu, Pokhara',
  'Asia/Khandyga': 'Yakutsk Time - Khandyga',
  'Asia/Kolkata': 'India Time - Mumbai, Delhi',
  'Asia/Krasnoyarsk': 'Krasnoyarsk Time - Krasnoyarsk',
  'Asia/Kuching': 'Malaysia Time - Kuching',
  'Asia/Macau': 'China Time - Macau',
  'Asia/Magadan': 'Magadan Time - Magadan',
  'Asia/Makassar': 'Central Indonesia Time - Makassar, Samarinda',
  'Asia/Manila': 'Philippine Time - Quezon City, Davao',
  'Asia/Nicosia': 'Eastern European Time - Nicosia, Limassol',
  'Asia/Novokuznetsk': 'Krasnoyarsk Time - Novokuznetsk',
  'Asia/Novosibirsk': 'Novosibirsk Time - Novosibirsk',
  'Asia/Omsk': 'Omsk Time - Omsk',
  'Asia/Oral': 'Kazakhstan Time - Oral',
  'Asia/Pontianak': 'Western Indonesia Time - Pontianak',
  'Asia/Pyongyang': 'Korean Time - Pyongyang, Hamhŭng',
  'Asia/Qatar': 'Arabian Time - Doha',
  'Asia/Qostanay': 'Kazakhstan Time - Kostanay',
  'Asia/Qyzylorda': 'Kazakhstan Time - Qyzylorda',
  'Asia/Riyadh': 'Arabian Time - Riyadh, Jeddah',
  'Asia/Sakhalin': 'Sakhalin Time - Yuzhno-Sakhalinsk',
  'Asia/Samarkand': 'Uzbekistan Time - Samarkand',
  'Asia/Seoul': 'Korean Time - Seoul, Busan',
  'Asia/Shanghai': 'China Time - Shanghai, Beijing',
  'Asia/Singapore': 'Singapore Time - Singapore',
  'Asia/Srednekolymsk': 'Srednekolymsk Time - Srednekolymsk',
  'Asia/Taipei': 'Taiwan Time - Taipei',
  'Asia/Tashkent': 'Uzbekistan Time - Tashkent, Andijon',
  'Asia/Tbilisi': 'Georgia Time - Tbilisi, Batumi',
  'Asia/Tehran': 'Iran Time - Tehran, Mashhad',
  'Asia/Thimphu': 'Bhutan Time - Thimphu',
  'Asia/Tokyo': 'Japan Time - Tokyo, Yokohama',
  'Asia/Tomsk': 'Tomsk Time - Tomsk',
  'Asia/Ulaanbaatar': 'Ulaanbaatar Time - Ulan Bator, Erdenet',
  'Asia/Urumqi': 'China Time - Ürümqi',
  'Asia/Ust-Nera': 'Vladivostok Time - Ust-Nera',
  'Asia/Vladivostok': 'Vladivostok Time - Khabarovsk, Vladivostok',
  'Asia/Yakutsk': 'Yakutsk Time - Yakutsk',
  'Asia/Yangon': 'Myanmar Time - Yangon, Mandalay',
  'Asia/Yekaterinburg': 'Yekaterinburg Time - Yekaterinburg, Chelyabinsk',
  'Asia/Yerevan': 'Armenia Time - Yerevan',

  // ── Atlantic ──
  'Atlantic/Azores': 'Azores Time - Ponta Delgada',
  'Atlantic/Bermuda': 'Atlantic Time - Hamilton',
  'Atlantic/Canary': 'Western European Time - Las Palmas, Tenerife',
  'Atlantic/Cape_Verde': 'Cape Verde Time - Praia, Mindelo',
  'Atlantic/Faroe': 'Western European Time - Tórshavn',
  'Atlantic/Madeira': 'Western European Time - Funchal',
  'Atlantic/South_Georgia': 'South Georgia Time - Grytviken',
  'Atlantic/Stanley': 'Falkland Islands Time - Stanley',

  // ── Australia ──
  'Australia/Adelaide': 'Australian Central Time - Adelaide',
  'Australia/Brisbane': 'Australian Eastern Time - Brisbane, Gold Coast',
  'Australia/Broken_Hill': 'Australian Central Time - Broken Hill',
  'Australia/Darwin': 'Australian Central Time - Darwin',
  'Australia/Eucla': 'Australian Central Western Time - Eucla',
  'Australia/Hobart': 'Australian Eastern Time - Hobart',
  'Australia/Lindeman': 'Australian Eastern Time - Lindeman',
  'Australia/Lord_Howe': 'Lord Howe Time - Lord Howe',
  'Australia/Melbourne': 'Australian Eastern Time - Melbourne',
  'Australia/Perth': 'Australian Western Time - Perth, Mandurah',
  'Australia/Sydney': 'Australian Eastern Time - Sydney',

  // ── Europe ──
  'Europe/Andorra': 'Central European Time - Andorra la Vella',
  'Europe/Astrakhan': 'Astrakhan Time - Astrakhan',
  'Europe/Athens': 'Eastern European Time - Athens, Thessaloníki',
  'Europe/Belgrade': 'Central European Time - Belgrade, Niš',
  'Europe/Berlin': 'Central European Time - Berlin, Hamburg',
  'Europe/Brussels': 'Central European Time - Brussels, Antwerpen',
  'Europe/Bucharest': 'Eastern European Time - Bucharest',
  'Europe/Budapest': 'Central European Time - Budapest, Debrecen',
  'Europe/Chisinau': 'Eastern European Time - Chisinau, Tiraspol',
  'Europe/Dublin': 'Greenwich Mean Time - Dublin',
  'Europe/Gibraltar': 'Central European Time - Gibraltar',
  'Europe/Helsinki': 'Eastern European Time - Helsinki, Espoo',
  'Europe/Istanbul': 'Turkey Time - Istanbul, Ankara',
  'Europe/Kaliningrad': 'Eastern European Time - Kaliningrad',
  'Europe/Kirov': 'Kirov Time - Kirov',
  'Europe/Kyiv': 'Eastern European Time - Kyiv, Kharkiv',
  'Europe/Lisbon': 'Western European Time - Lisbon, Porto',
  'Europe/London': 'Greenwich Mean Time - London, Birmingham',
  'Europe/Madrid': 'Central European Time - Madrid, Barcelona',
  'Europe/Malta': 'Central European Time - Valletta',
  'Europe/Minsk': 'Moscow Time - Minsk',
  'Europe/Moscow': 'Moscow Time - Moscow, Saint Petersburg',
  'Europe/Paris': 'Central European Time - Paris, Marseille',
  'Europe/Prague': 'Central European Time - Prague, Brno',
  'Europe/Riga': 'Eastern European Time - Riga, Daugavpils',
  'Europe/Rome': 'Central European Time - Rome, Milan',
  'Europe/Samara': 'Samara Time - Samara',
  'Europe/Saratov': 'Saratov Time - Saratov',
  'Europe/Simferopol': 'Moscow Time - Simferopol, Sevastopol',
  'Europe/Sofia': 'Eastern European Time - Sofia, Plovdiv',
  'Europe/Tallinn': 'Eastern European Time - Tallinn, Tartu',
  'Europe/Tirane': 'Central European Time - Tirana, Durrës',
  'Europe/Ulyanovsk': 'Ulyanovsk Time - Ulyanovsk',
  'Europe/Vienna': 'Central European Time - Vienna, Graz',
  'Europe/Vilnius': 'Eastern European Time - Vilnius, Kaunas',
  'Europe/Volgograd': 'Volgograd Time - Volgograd',
  'Europe/Warsaw': 'Central European Time - Warsaw, Łódź',
  'Europe/Zurich': 'Central European Time - Zürich, Genève',

  // ── Indian ──
  'Indian/Chagos': 'Indian Ocean Time - Chagos',
  'Indian/Maldives': 'Maldives Time - Malé',
  'Indian/Mauritius': 'Mauritius Time - Port Louis',

  // ── Pacific ──
  'Pacific/Apia': 'Samoa Time - Apia',
  'Pacific/Auckland': 'New Zealand Time - Auckland, Christchurch',
  'Pacific/Bougainville': 'Bougainville Time - Arawa',
  'Pacific/Chatham': 'Chatham Time - Chatham',
  'Pacific/Easter': 'Easter Island Time - Easter',
  'Pacific/Efate': 'Vanuatu Time - Port-Vila',
  'Pacific/Fakaofo': 'Tokelau Time - Fakaofo',
  'Pacific/Fiji': 'Fiji Time - Suva, Nasinu',
  'Pacific/Galapagos': 'Galapagos Time - Galápagos',
  'Pacific/Gambier': 'Gambier Time - Gambier',
  'Pacific/Guadalcanal': 'Solomon Islands Time - Honiara',
  'Pacific/Guam': 'Chamorro Time - Dededo Village',
  'Pacific/Honolulu': 'Hawaii-Aleutian Time - Honolulu',
  'Pacific/Kanton': 'Phoenix Islands Time - Kanton',
  'Pacific/Kiritimati': 'Line Islands Time - Kiritimati',
  'Pacific/Kosrae': 'Kosrae Time - Kosrae',
  'Pacific/Kwajalein': 'Marshall Islands Time - Kwajalein',
  'Pacific/Marquesas': 'Marquesas Time - Marquesas',
  'Pacific/Nauru': 'Nauru Time - Yaren',
  'Pacific/Niue': 'Niue Time - Alofi',
  'Pacific/Norfolk': 'Norfolk Island Time - Kingston',
  'Pacific/Noumea': 'New Caledonia Time - Nouméa',
  'Pacific/Pago_Pago': 'American Samoa Time - Pago Pago',
  'Pacific/Palau': 'Palau Time - Ngerulmud',
  'Pacific/Pitcairn': 'Pitcairn Time - Adamstown',
  'Pacific/Port_Moresby': 'Papua New Guinea Time - Port Moresby, Lae',
  'Pacific/Rarotonga': 'Cook Islands Time - Avarua',
  'Pacific/Tahiti': 'Tahiti Time - Papeete',
  'Pacific/Tarawa': 'Gilbert Islands Time - Tarawa',
  'Pacific/Tongatapu': 'Tonga Time - Nukuʻalofa',
};

/// Curated search text for timezone entries, including country names,
/// ISO codes, abbreviations (PST, EST, etc.), IANA aliases, and
/// additional city names. Sourced from @vvo/tzdb.
///
/// When an entry isn't in this map, search text is auto-generated
/// from the IANA path and display label.
const Map<String, String> _kTimezoneSearchText = <String, String>{
  'Pacific/Pago_Pago': 'Pacific/Pago_Pago Pacific/Pago_Pago US/Samoa Pacific/Samoa Pacific/Midway American Samoa Time American Samoa AS Pago Pago',
  'Pacific/Niue': 'Pacific/Niue Pacific/Niue Niue Time Niue NU Alofi',
  'Pacific/Rarotonga': 'Pacific/Rarotonga Pacific/Rarotonga Cook Islands Time Cook Islands CK Avarua',
  'Pacific/Honolulu': 'Pacific/Honolulu Pacific/Honolulu US/Hawaii Pacific/Johnston HST Hawaii-Aleutian Time United States US Honolulu East Honolulu Pearl City Makakilo / Kapolei / Honokai Hale',
  'Pacific/Tahiti': 'Pacific/Tahiti Pacific/Tahiti Tahiti Time French Polynesia PF Faaa Papeete Punaauia',
  'Pacific/Marquesas': 'Pacific/Marquesas Pacific/Marquesas Marquesas Time French Polynesia PF Marquesas',
  'Pacific/Gambier': 'Pacific/Gambier Pacific/Gambier Gambier Time French Polynesia PF Gambier',
  'America/Adak': 'America/Adak America/Adak US/Aleutian America/Atka Hawaii-Aleutian Time United States US Adak',
  'America/Anchorage': 'America/Anchorage America/Anchorage America/Juneau America/Metlakatla America/Nome America/Sitka America/Yakutat US/Alaska Alaska Time United States US Anchorage Fairbanks Juneau Eagle River',
  'Pacific/Pitcairn': 'Pacific/Pitcairn Pacific/Pitcairn Pitcairn Time Pitcairn PN Adamstown',
  'America/Hermosillo': 'America/Hermosillo America/Hermosillo America/Mazatlan Mexico/BajaSur Mexican Pacific Time Mexico MX Hermosillo Culiacán Mazatlán Tepic',
  'America/Phoenix': 'America/Phoenix America/Phoenix MST US/Arizona America/Creston Mountain Time United States US Phoenix Tucson Mesa Chandler',
  'America/Los_Angeles': 'America/Los_Angeles America/Los_Angeles US/Pacific PST8PDT Pacific Time United States US Los Angeles San Diego San Jose San Francisco',
  'America/Tijuana': 'America/Tijuana America/Tijuana Mexico/BajaNorte America/Ensenada America/Santa_Isabel Pacific Time Mexico MX Tijuana Mexicali Ensenada Rosarito',
  'America/Vancouver': 'America/Vancouver America/Vancouver Canada/Pacific Pacific Time Canada CA Vancouver Surrey Victoria Burnaby',
  'America/Whitehorse': 'America/Whitehorse America/Creston America/Dawson America/Dawson_Creek America/Fort_Nelson America/Whitehorse Canada/Yukon Yukon Time Canada CA Whitehorse Fort St. John Creston Dawson',
  'America/Belize': 'America/Belize America/Belize Central Time Belize BZ Belize City San Pedro Orange Walk Belmopan',
  'America/Guatemala': 'America/Guatemala America/Guatemala Central Time Guatemala GT Guatemala City Villa Nueva Mixco Cobán',
  'America/Managua': 'America/Managua America/Managua Central Time Nicaragua NI Managua León Masaya Chinandega',
  'America/Mexico_City': 'America/Mexico_City America/Bahia_Banderas America/Chihuahua America/Merida America/Mexico_City America/Monterrey Mexico/General Central Time Mexico MX Mexico City Iztapalapa Puebla Ecatepec de Morelos',
  'America/Costa_Rica': 'America/Costa_Rica America/Costa_Rica Central Time Costa Rica CR San José Limón San Francisco Alajuela',
  'America/El_Salvador': 'America/El_Salvador America/El_Salvador Central Time El Salvador SV San Salvador Soyapango San Miguel Santa Ana',
  'America/Regina': 'America/Regina America/Regina America/Swift_Current Canada/Saskatchewan Central Time Canada CA Saskatoon Regina Prince Albert Moose Jaw',
  'America/Tegucigalpa': 'America/Tegucigalpa America/Tegucigalpa Central Time Honduras HN Tegucigalpa San Pedro Sula La Ceiba Choloma',
  'Pacific/Galapagos': 'Pacific/Galapagos Pacific/Galapagos Galapagos Time Ecuador EC Galapagos',
  'America/Edmonton': 'America/Edmonton America/Cambridge_Bay America/Edmonton America/Inuvik Canada/Mountain America/Yellowknife Mountain Time Canada CA Calgary Edmonton Lethbridge Red Deer',
  'America/Ciudad_Juarez': 'America/Ciudad_Juarez America/Ciudad_Juarez Mountain Time Mexico MX Ciudad Juárez',
  'America/Denver': 'America/Denver America/Boise America/Denver MST7MDT Navajo US/Mountain America/Shiprock Mountain Time United States US Denver El Paso Albuquerque Colorado Springs',
  'America/Rio_Branco': 'America/Rio_Branco America/Eirunepe America/Rio_Branco Brazil/Acre America/Porto_Acre Acre Time Brazil BR Rio Branco Cruzeiro do Sul Tarauacá Sena Madureira',
  'America/Chicago': 'America/Chicago America/Chicago America/Indiana/Knox America/Indiana/Tell_City America/Menominee America/North_Dakota/Beulah America/North_Dakota/Center America/North_Dakota/New_Salem CST6CDT US/Central US/Indiana-Starke America/Knox_IN Central Time United States US Chicago Houston San Antonio Dallas',
  'America/Matamoros': 'America/Matamoros America/Matamoros America/Ojinaga Central Time Mexico MX Reynosa Heroica Matamoros Nuevo Laredo Ciudad Acuña',
  'America/Winnipeg': 'America/Winnipeg America/Rankin_Inlet America/Resolute America/Winnipeg Canada/Central America/Rainy_River Central Time Canada CA Winnipeg Brandon Steinbach Kenora',
  'America/Bogota': 'America/Bogota America/Bogota Colombia Time Colombia CO Bogotá Cali Medellín Barranquilla',
  'Pacific/Easter': 'Pacific/Easter Pacific/Easter Chile/EasterIsland Easter Island Time Chile CL Easter',
  'America/Cancun': 'America/Cancun America/Cancun Eastern Time Mexico MX Cancún Chetumal Playa del Carmen Cozumel',
  'America/Jamaica': 'America/Jamaica America/Jamaica Jamaica Eastern Time Jamaica JM Kingston New Kingston Spanish Town Portmore',
  'America/Panama': 'America/Panama America/Panama EST America/Atikokan America/Cayman America/Coral_Harbour Eastern Time Panama PA Panamá San Miguelito Juan Díaz David',
  'America/Guayaquil': 'America/Guayaquil America/Guayaquil Ecuador Time Ecuador EC Quito Guayaquil Cuenca Santo Domingo de los Colorados',
  'America/Lima': 'America/Lima America/Lima Peru Time Peru PE Lima Callao Arequipa Trujillo',
  'America/Manaus': 'America/Manaus America/Boa_Vista America/Campo_Grande America/Cuiaba America/Manaus America/Porto_Velho Brazil/West Amazon Time Brazil BR Manaus Campo Grande Cuiabá Porto Velho',
  'America/Barbados': 'America/Barbados America/Barbados Atlantic Time Barbados BB Bridgetown',
  'America/Martinique': 'America/Martinique America/Martinique Atlantic Time Martinique MQ Fort-de-France Le Lamentin Le Robert Sainte-Marie',
  'America/Puerto_Rico': 'America/Puerto_Rico America/Puerto_Rico America/Virgin America/Anguilla America/Antigua America/Aruba America/Blanc-Sablon America/Curacao America/Dominica America/Grenada America/Guadeloupe America/Kralendijk America/Lower_Princes America/Marigot America/Montserrat America/Port_of_Spain America/St_Barthelemy America/St_Kitts America/St_Lucia America/St_Thomas America/St_Vincent America/Tortola Atlantic Time Puerto Rico PR San Juan Bayamón Carolina Ponce',
  'America/Santo_Domingo': 'America/Santo_Domingo America/Santo_Domingo Atlantic Time Dominican Republic DO Santo Domingo Santiago de los Caballeros Santo Domingo Oeste Santo Domingo Este',
  'America/La_Paz': 'America/La_Paz America/La_Paz Bolivia Time Bolivia BO La Paz Santa Cruz de la Sierra Cochabamba Sucre',
  'America/Havana': 'America/Havana America/Havana Cuba Cuba Time Cuba CU Havana Santiago de Cuba Camagüey Holguín',
  'America/New_York': 'America/New_York America/Detroit America/Indiana/Indianapolis America/Indiana/Marengo America/Indiana/Petersburg America/Indiana/Vevay America/Indiana/Vincennes America/Indiana/Winamac America/Kentucky/Louisville America/Kentucky/Monticello America/New_York US/Michigan US/East-Indiana America/Indianapolis America/Fort_Wayne America/Louisville EST5EDT US/Eastern Eastern Time United States US New York City Brooklyn Queens Philadelphia',
  'America/Port-au-Prince': 'America/Port-au-Prince America/Port-au-Prince Eastern Time Haiti HT Port-au-Prince Carrefour Delmas Port-de-Paix',
  'America/Grand_Turk': 'America/Grand_Turk America/Grand_Turk Eastern Time Turks and Caicos Islands TC Providenciales Cockburn Town',
  'America/Toronto': 'America/Toronto America/Iqaluit America/Toronto America/Pangnirtung Canada/Eastern America/Nassau America/Montreal America/Nipigon America/Thunder_Bay Eastern Time Canada CA Toronto Montréal Ottawa Mississauga',
  'America/Guyana': 'America/Guyana America/Guyana Guyana Time Guyana GY Georgetown Linden New Amsterdam',
  'America/Caracas': 'America/Caracas America/Caracas Venezuela Time Venezuela VE Caracas Maracaibo Valencia Barquisimeto',
  'America/Argentina/Buenos_Aires': 'America/Argentina/Buenos_Aires America/Argentina/Buenos_Aires America/Argentina/Catamarca America/Argentina/Cordoba America/Argentina/Jujuy America/Argentina/La_Rioja America/Argentina/Mendoza America/Argentina/Rio_Gallegos America/Argentina/Salta America/Argentina/San_Juan America/Argentina/San_Luis America/Argentina/Tucuman America/Argentina/Ushuaia America/Buenos_Aires America/Catamarca America/Argentina/ComodRivadavia America/Cordoba America/Rosario America/Jujuy America/Mendoza Argentina Time Argentina AR Buenos Aires Córdoba Rosario Mar del Plata',
  'America/Halifax': 'America/Halifax America/Glace_Bay America/Goose_Bay America/Halifax America/Moncton Canada/Atlantic Atlantic Time Canada CA Halifax Sydney Dartmouth Moncton',
  'Atlantic/Bermuda': 'Atlantic/Bermuda Atlantic/Bermuda Atlantic Time Bermuda BM Hamilton',
  'America/Thule': 'America/Thule America/Thule Atlantic Time Greenland GL Thule',
  'America/Sao_Paulo': 'America/Sao_Paulo America/Araguaina America/Bahia America/Belem America/Fortaleza America/Maceio America/Recife America/Santarem America/Sao_Paulo Brazil/East Brasilia Time Brazil BR São Paulo Rio de Janeiro Belo Horizonte Salvador',
  'Antarctica/Palmer': 'Antarctica/Palmer Antarctica/Palmer Antarctica/Rothera Chile Time Antarctica AQ Palmer Rothera',
  'America/Punta_Arenas': 'America/Punta_Arenas America/Coyhaique America/Punta_Arenas Chile Time Chile CL Punta Arenas Coyhaique Puerto Natales Puerto Aysén',
  'America/Santiago': 'America/Santiago America/Santiago Chile/Continental Chile Time Chile CL Santiago Puente Alto Maipú Antofagasta',
  'Atlantic/Stanley': 'Atlantic/Stanley Atlantic/Stanley Falkland Islands Time Falkland Islands FK Stanley',
  'America/Cayenne': 'America/Cayenne America/Cayenne French Guiana Time French Guiana GF Cayenne Matoury Saint-Laurent-du-Maroni Kourou',
  'America/Asuncion': 'America/Asuncion America/Asuncion Paraguay Time Paraguay PY Asunción Ciudad del Este San Lorenzo Capiatá',
  'America/Paramaribo': 'America/Paramaribo America/Paramaribo Suriname Time Suriname SR Paramaribo Blauwgrond Rainville Flora',
  'America/Montevideo': 'America/Montevideo America/Montevideo Uruguay Time Uruguay UY Montevideo Salto Paysandú Las Piedras',
  'America/Noronha': 'America/Noronha America/Noronha Brazil/DeNoronha Fernando de Noronha Time Brazil BR Noronha',
  'Atlantic/South_Georgia': 'Atlantic/South_Georgia Atlantic/South_Georgia South Georgia Time South Georgia and the South Sandwich Islands GS Grytviken',
  'America/Miquelon': 'America/Miquelon America/Miquelon St. Pierre & Miquelon Time Saint Pierre and Miquelon PM Saint-Pierre',
  'Atlantic/Cape_Verde': 'Atlantic/Cape_Verde Atlantic/Cape_Verde Cape Verde Time Cabo Verde CV Praia Mindelo Espargos Assomada',
  'America/Nuuk': 'America/Nuuk America/Nuuk America/Scoresbysund America/Godthab Greenland Time Greenland GL Nuuk Scoresbysund',
  'Atlantic/Azores': 'Atlantic/Azores Atlantic/Azores Azores Time Portugal PT Ponta Delgada',
  'Africa/Abidjan': 'Africa/Abidjan Africa/Abidjan Iceland Africa/Accra Africa/Bamako Africa/Banjul Africa/Conakry Africa/Dakar Africa/Freetown Africa/Lome Africa/Nouakchott Africa/Ouagadougou Atlantic/Reykjavik Atlantic/St_Helena Africa/Timbuktu Greenwich Mean Time Ivory Coast CI Abidjan Abobo Bouaké Korhogo',
  'Africa/Bissau': 'Africa/Bissau Africa/Bissau Greenwich Mean Time Guinea-Bissau GW Bissau Gabú Bafatá Xitole',
  'America/Danmarkshavn': 'America/Danmarkshavn America/Danmarkshavn Greenwich Mean Time Greenland GL Danmarkshavn',
  'Africa/Monrovia': 'Africa/Monrovia Africa/Monrovia Greenwich Mean Time Liberia LR Monrovia Gbarnga Buchanan Ganta',
  'Africa/Sao_Tome': 'Africa/Sao_Tome Africa/Sao_Tome Greenwich Mean Time Sao Tome and Principe ST São Tomé',
  'UTC': 'UTC Etc/UTC Etc/UCT UCT UTC Universal Zulu Coordinated Universal Time (UTC)',
  'Africa/Algiers': 'Africa/Algiers Africa/Algiers Central European Time Algeria DZ Algiers Oran Constantine Annaba',
  'Africa/Tunis': 'Africa/Tunis Africa/Tunis Central European Time Tunisia TN Tunis Sfax Sousse Kairouan',
  'Europe/Dublin': 'Europe/Dublin Europe/Dublin Eire Greenwich Mean Time Ireland IE Dublin South Dublin Cork Limerick',
  'Europe/London': 'Europe/London Europe/London GB GB-Eire Europe/Guernsey Europe/Isle_of_Man Europe/Jersey Europe/Belfast Greenwich Mean Time United Kingdom GB London Birmingham Glasgow Manchester',
  'Africa/Lagos': 'Africa/Lagos Africa/Lagos Africa/Bangui Africa/Brazzaville Africa/Douala Africa/Kinshasa Africa/Libreville Africa/Luanda Africa/Malabo Africa/Niamey Africa/Porto-Novo West Africa Time Nigeria NG Lagos Kano Ibadan Abuja',
  'Africa/Casablanca': 'Africa/Casablanca Africa/Casablanca Western European Time Morocco MA Casablanca Rabat Fes Tangier',
  'Africa/El_Aaiun': 'Africa/El_Aaiun Africa/El_Aaiun Western European Time Western Sahara EH Laayoune Dakhla Boujdour',
  'Atlantic/Canary': 'Atlantic/Canary Atlantic/Canary Western European Time Spain ES Las Palmas de Gran Canaria Santa Cruz de Tenerife La Laguna Telde',
  'Europe/Lisbon': 'Europe/Lisbon Atlantic/Madeira Europe/Lisbon Portugal WET Western European Time Portugal PT Lisbon Porto Amadora Braga',
  'Atlantic/Faroe': 'Atlantic/Faroe Atlantic/Faroe Atlantic/Faeroe Western European Time Faroe Islands FO Tórshavn',
  'Africa/Juba': 'Africa/Juba Africa/Juba Central Africa Time South Sudan SS Juba Winejok Yei Malakal',
  'Africa/Khartoum': 'Africa/Khartoum Africa/Khartoum Central Africa Time Sudan SD Khartoum Omdurman Khartoum North Nyala',
  'Africa/Maputo': 'Africa/Maputo Africa/Maputo Africa/Blantyre Africa/Bujumbura Africa/Gaborone Africa/Harare Africa/Kigali Africa/Lubumbashi Africa/Lusaka Central Africa Time Mozambique MZ Maputo Matola Nampula Beira',
  'Africa/Windhoek': 'Africa/Windhoek Africa/Windhoek Central Africa Time Namibia NA Windhoek Rundu Walvis Bay Swakopmund',
  'Europe/Andorra': 'Europe/Andorra Europe/Andorra Central European Time Andorra AD Andorra la Vella les Escaldes',
  'Europe/Belgrade': 'Europe/Belgrade Europe/Belgrade Europe/Ljubljana Europe/Podgorica Europe/Sarajevo Europe/Skopje Europe/Zagreb Central European Time Serbia RS Belgrade Niš Novi Sad Zemun',
  'Europe/Berlin': 'Europe/Berlin Europe/Berlin Europe/Busingen Arctic/Longyearbyen Europe/Copenhagen Europe/Oslo Europe/Stockholm Atlantic/Jan_Mayen Central European Time Germany DE Berlin Hamburg Munich Köln',
  'Europe/Brussels': 'Europe/Brussels Europe/Brussels CET MET Europe/Amsterdam Europe/Luxembourg Central European Time Belgium BE Brussels Antwerpen Gent Charleroi',
  'Europe/Budapest': 'Europe/Budapest Europe/Budapest Central European Time Hungary HU Budapest Debrecen Szeged Miskolc',
  'Europe/Gibraltar': 'Europe/Gibraltar Europe/Gibraltar Central European Time Gibraltar GI Gibraltar',
  'Europe/Madrid': 'Europe/Madrid Africa/Ceuta Europe/Madrid Central European Time Spain ES Madrid Barcelona Valencia Zaragoza',
  'Europe/Paris': 'Europe/Paris Europe/Paris Europe/Monaco Central European Time France FR Paris Marseille Lyon Toulouse',
  'Europe/Prague': 'Europe/Prague Europe/Prague Europe/Bratislava Central European Time Czechia CZ Prague Brno Ostrava Pilsen',
  'Europe/Rome': 'Europe/Rome Europe/Rome Europe/San_Marino Europe/Vatican Central European Time Italy IT Rome Milan Naples Turin',
  'Europe/Malta': 'Europe/Malta Europe/Malta Central European Time Malta MT San Pawl il-Baħar Birkirkara Mosta Sliema',
  'Europe/Tirane': 'Europe/Tirane Europe/Tirane Central European Time Albania AL Tirana Durrës Vlorë Elbasan',
  'Europe/Vienna': 'Europe/Vienna Europe/Vienna Central European Time Austria AT Vienna Graz Linz Favoriten',
  'Europe/Warsaw': 'Europe/Warsaw Europe/Warsaw Poland Central European Time Poland PL Warsaw Łódź Kraków Wrocław',
  'Europe/Zurich': 'Europe/Zurich Europe/Zurich Europe/Busingen Europe/Vaduz Central European Time Switzerland CH Zürich Genève Basel Lausanne',
  'Europe/Kaliningrad': 'Europe/Kaliningrad Europe/Kaliningrad Eastern European Time Russia RU Kaliningrad Chernyakhovsk Sovetsk Baltiysk',
  'Africa/Tripoli': 'Africa/Tripoli Africa/Tripoli Libya Eastern European Time Libya LY Tripoli Benghazi Misratah Zliten',
  'Antarctica/Troll': 'Antarctica/Troll Antarctica/Troll Greenwich Mean Time Antarctica AQ Troll',
  'Africa/Johannesburg': 'Africa/Johannesburg Africa/Johannesburg Africa/Maseru Africa/Mbabane South Africa Time South Africa ZA Johannesburg Cape Town Durban Pretoria',
  'Asia/Baghdad': 'Asia/Baghdad Asia/Baghdad Arabian Time Iraq IQ Baghdad Al Mawşil al Jadīdah Al Başrah al Qadīmah Mosul',
  'Asia/Qatar': 'Asia/Qatar Asia/Qatar Asia/Bahrain Arabian Time Qatar QA Doha Ar Rayyān Al Maţār al \'Atīq Al Manşūrah',
  'Asia/Riyadh': 'Asia/Riyadh Asia/Riyadh Antarctica/Syowa Asia/Aden Asia/Kuwait Arabian Time Saudi Arabia SA Jeddah Riyadh Makkah Madinah',
  'Asia/Amman': 'Asia/Amman Asia/Amman Asia/Amman Jordan JO Amman Zarqa Irbid Russeifa',
  'Asia/Damascus': 'Asia/Damascus Asia/Damascus Asia/Damascus Syria SY Aleppo Damascus Homs Latakia',
  'Africa/Nairobi': 'Africa/Nairobi Africa/Nairobi Africa/Addis_Ababa Africa/Asmara Africa/Dar_es_Salaam Africa/Djibouti Africa/Kampala Africa/Mogadishu Indian/Antananarivo Indian/Comoro Indian/Mayotte Africa/Asmera East Africa Time Kenya KE Nairobi Kakamega Mombasa Nakuru',
  'Europe/Athens': 'Europe/Athens Europe/Athens EET Eastern European Time Greece GR Athens Thessaloníki Pátra Piraeus',
  'Asia/Beirut': 'Asia/Beirut Asia/Beirut Eastern European Time Lebanon LB Beirut Ra\'s Bayrūt Tripoli Sidon',
  'Europe/Bucharest': 'Europe/Bucharest Europe/Bucharest Eastern European Time Romania RO Bucharest Sector 3 Iaşi Sector 6',
  'Africa/Cairo': 'Africa/Cairo Africa/Cairo Egypt Eastern European Time Egypt EG Cairo Alexandria Giza Shubrā al Khaymah',
  'Europe/Chisinau': 'Europe/Chisinau Europe/Chisinau Europe/Tiraspol Eastern European Time Moldova MD Chisinau Tiraspol Bălţi Bender',
  'Asia/Hebron': 'Asia/Hebron Asia/Gaza Asia/Hebron Eastern European Time Palestinian Territory PS East Jerusalem Gaza Khān Yūnis Jabālyā',
  'Europe/Helsinki': 'Europe/Helsinki Europe/Helsinki Europe/Mariehamn Eastern European Time Finland FI Helsinki Espoo Tampere Vantaa',
  'Europe/Kyiv': 'Europe/Kyiv Europe/Kyiv Europe/Uzhgorod Europe/Zaporozhye Europe/Kiev Eastern European Time Ukraine UA Kyiv Kharkiv Odesa Dnipro',
  'Asia/Nicosia': 'Asia/Nicosia Asia/Famagusta Asia/Nicosia Europe/Nicosia Eastern European Time Cyprus CY Nicosia Limassol Larnaca Stróvolos',
  'Europe/Riga': 'Europe/Riga Europe/Riga Eastern European Time Latvia LV Riga Daugavpils Liepāja Jelgava',
  'Europe/Sofia': 'Europe/Sofia Europe/Sofia Eastern European Time Bulgaria BG Sofia Plovdiv Varna Burgas',
  'Europe/Tallinn': 'Europe/Tallinn Europe/Tallinn Eastern European Time Estonia EE Tallinn Tartu Narva Pärnu',
  'Europe/Vilnius': 'Europe/Vilnius Europe/Vilnius Eastern European Time Lithuania LT Vilnius Kaunas Klaipėda Šiauliai',
  'Asia/Jerusalem': 'Asia/Jerusalem Asia/Jerusalem Israel Asia/Tel_Aviv Israel Time Israel IL Jerusalem Tel Aviv West Jerusalem Haifa',
  'Europe/Moscow': 'Europe/Moscow Europe/Kirov Europe/Moscow Europe/Volgograd W-SU Moscow Time Russia RU Moscow Saint Petersburg Nizhniy Novgorod Kazan',
  'Europe/Simferopol': 'Europe/Simferopol Europe/Simferopol Moscow Time Ukraine UA Sevastopol Simferopol Kerch Yevpatoriya',
  'Europe/Istanbul': 'Europe/Istanbul Europe/Istanbul Turkey Asia/Istanbul Turkey Time Turkey TR Istanbul Ankara Bursa İzmir',
  'Asia/Tehran': 'Asia/Tehran Asia/Tehran Iran Iran Time Iran IR Tehran Mashhad Isfahan Karaj',
  'Asia/Yerevan': 'Asia/Yerevan Asia/Yerevan Armenia Time Armenia AM Yerevan Malatia-Sebastia Shengavit Nor Nork',
  'Asia/Baku': 'Asia/Baku Asia/Baku Azerbaijan Time Azerbaijan AZ Baku Sumqayıt Ganja Lankaran',
  'Asia/Tbilisi': 'Asia/Tbilisi Asia/Tbilisi Georgia Time Georgia GE Tbilisi Batumi Kutaisi Rustavi',
  'Asia/Dubai': 'Asia/Dubai Asia/Dubai Asia/Muscat Indian/Mahe Indian/Reunion Gulf Time United Arab Emirates AE Dubai Abu Dhabi Sharjah Al Ain City',
  'Indian/Mauritius': 'Indian/Mauritius Indian/Mauritius Mauritius Time Mauritius MU Port Louis Vacoas Beau Bassin-Rose Hill Curepipe',
  'Europe/Samara': 'Europe/Samara Europe/Astrakhan Europe/Samara Europe/Saratov Europe/Ulyanovsk Samara Time Russia RU Samara Saratov Tolyatti Izhevsk',
  'Asia/Kabul': 'Asia/Kabul Asia/Kabul Afghanistan Time Afghanistan AF Kabul Herāt Mazār-e Sharīf Kandahār',
  'Asia/Almaty': 'Asia/Almaty Asia/Almaty Asia/Aqtau Asia/Aqtobe Asia/Atyrau Asia/Oral Asia/Qostanay Asia/Qyzylorda Kazakhstan Time Kazakhstan KZ Almaty Shymkent Aktobe Karagandy',
  'Indian/Maldives': 'Indian/Maldives Indian/Maldives Indian/Kerguelen Maldives Time Maldives MV Male',
  'Antarctica/Mawson': 'Antarctica/Mawson Antarctica/Mawson Antarctica/Vostok Mawson Time Antarctica AQ Mawson Vostok',
  'Asia/Karachi': 'Asia/Karachi Asia/Karachi Pakistan Time Pakistan PK Lahore Karachi Peshawar Faisalabad',
  'Asia/Dushanbe': 'Asia/Dushanbe Asia/Dushanbe Tajikistan Time Tajikistan TJ Dushanbe Isfara Istaravshan Kŭlob',
  'Asia/Ashgabat': 'Asia/Ashgabat Asia/Ashgabat Asia/Ashkhabad Turkmenistan Time Turkmenistan TM Ashgabat Türkmenabat Daşoguz Mary',
  'Asia/Tashkent': 'Asia/Tashkent Asia/Samarkand Asia/Tashkent Uzbekistan Time Uzbekistan UZ Tashkent Andijon Namangan Samarkand',
  'Asia/Yekaterinburg': 'Asia/Yekaterinburg Asia/Yekaterinburg Yekaterinburg Time Russia RU Yekaterinburg Chelyabinsk Ufa Perm',
  'Asia/Colombo': 'Asia/Colombo Asia/Colombo India Time Sri Lanka LK Colombo Dehiwala-Mount Lavinia Maharagama Jaffna',
  'Asia/Kolkata': 'Asia/Kolkata Asia/Kolkata Asia/Calcutta India Time India IN Mumbai Delhi Bengaluru Hyderabad',
  'Asia/Kathmandu': 'Asia/Kathmandu Asia/Kathmandu Asia/Katmandu Nepal Time Nepal NP Kathmandu Pokhara Bharatpur Pātan',
  'Asia/Dhaka': 'Asia/Dhaka Asia/Dhaka Asia/Dacca Bangladesh Time Bangladesh BD Dhaka Chattogram Gazipur Khulna',
  'Asia/Thimphu': 'Asia/Thimphu Asia/Thimphu Asia/Thimbu Bhutan Time Bhutan BT Thimphu Phuntsholing Tsirang Punākha',
  'Asia/Urumqi': 'Asia/Urumqi Asia/Urumqi Asia/Kashgar China Time China CN Ürümqi Shihezi Korla Aqsu',
  'Indian/Chagos': 'Indian/Chagos Indian/Chagos Indian Ocean Time British Indian Ocean Territory IO Chagos',
  'Asia/Bishkek': 'Asia/Bishkek Asia/Bishkek Kyrgyzstan Time Kyrgyzstan KG Bishkek Osh Jalal-Abad Karakol',
  'Asia/Omsk': 'Asia/Omsk Asia/Omsk Omsk Time Russia RU Omsk Tara Kalachinsk Isil\'kul\'',
  'Asia/Yangon': 'Asia/Yangon Asia/Yangon Indian/Cocos Asia/Rangoon Myanmar Time Myanmar MM Yangon Mandalay Nay Pyi Taw Hlaingthaya Township',
  'Antarctica/Davis': 'Antarctica/Davis Antarctica/Davis Davis Time Antarctica AQ Davis',
  'Asia/Hovd': 'Asia/Hovd Asia/Hovd Hovd Time Mongolia MN Ulaangom Khovd Ölgii Altai',
  'Asia/Bangkok': 'Asia/Bangkok Asia/Bangkok Asia/Phnom_Penh Asia/Vientiane Indian/Christmas Indochina Time Thailand TH Bangkok Samut Prakan Mueang Nonthaburi Chon Buri',
  'Asia/Ho_Chi_Minh': 'Asia/Ho_Chi_Minh Asia/Ho_Chi_Minh Asia/Saigon Indochina Time Vietnam VN Ho Chi Minh City Cần Thơ Da Nang Biên Hòa',
  'Asia/Novosibirsk': 'Asia/Novosibirsk Asia/Barnaul Asia/Krasnoyarsk Asia/Novokuznetsk Asia/Novosibirsk Asia/Tomsk Novosibirsk Time Russia RU Novosibirsk Krasnoyarsk Barnaul Tomsk',
  'Asia/Jakarta': 'Asia/Jakarta Asia/Jakarta Asia/Pontianak Western Indonesia Time Indonesia ID Jakarta Surabaya Bekasi Bandung',
  'Antarctica/Casey': 'Antarctica/Casey Antarctica/Casey Australian Western Time Antarctica AQ Casey',
  'Australia/Perth': 'Australia/Perth Australia/Perth Australia/West Australian Western Time Australia AU Perth Mandurah Bunbury Geraldton',
  'Asia/Makassar': 'Asia/Makassar Asia/Makassar Asia/Ujung_Pandang Central Indonesia Time Indonesia ID Makassar Samarinda Denpasar Balikpapan',
  'Asia/Macau': 'Asia/Macau Asia/Macau Asia/Macao China Time Macao MO Macau Taipa Sé Luhuan',
  'Asia/Shanghai': 'Asia/Shanghai Asia/Shanghai PRC Asia/Chongqing Asia/Harbin Asia/Chungking China Time China CN Shanghai Beijing Shenzhen Guangzhou',
  'Asia/Hong_Kong': 'Asia/Hong_Kong Asia/Hong_Kong Hongkong Hong Kong Time Hong Kong HK Hong Kong New Territories Kowloon Hong Kong Island',
  'Asia/Irkutsk': 'Asia/Irkutsk Asia/Irkutsk Irkutsk Time Russia RU Irkutsk Ulan-Ude Bratsk Angarsk',
  'Asia/Manila': 'Asia/Manila Asia/Manila Philippine Time Philippines PH Quezon City Davao Caloocan City Manila',
  'Asia/Singapore': 'Asia/Singapore Asia/Singapore Singapore Asia/Kuala_Lumpur Singapore Time Singapore SG Singapore Ulu Bedok Bedok New Town Tampines Estate',
  'Asia/Taipei': 'Asia/Taipei Asia/Taipei ROC Taiwan Time Taiwan TW Taipei New Taipei City Taichung Kaohsiung',
  'Asia/Ulaanbaatar': 'Asia/Ulaanbaatar Asia/Ulaanbaatar Asia/Choibalsan Asia/Ulan_Bator Ulaanbaatar Time Mongolia MN Ulan Bator Erdenet Darhan Choibalsan',
  'Australia/Eucla': 'Australia/Eucla Australia/Eucla Australian Central Western Time Australia AU Eucla',
  'Asia/Jayapura': 'Asia/Jayapura Asia/Jayapura Eastern Indonesia Time Indonesia ID Jayapura Ambon Sorong Ternate',
  'Asia/Tokyo': 'Asia/Tokyo Asia/Tokyo Japan Japan Time Japan JP Tokyo Yokohama Osaka Nagoya',
  'Asia/Pyongyang': 'Asia/Pyongyang Asia/Pyongyang Korean Time North Korea KP Pyongyang Hamhŭng Namp\'o Sunch\'ŏn',
  'Asia/Seoul': 'Asia/Seoul Asia/Seoul ROK Korean Time South Korea KR Seoul Busan Incheon Daegu',
  'Pacific/Palau': 'Pacific/Palau Pacific/Palau Palau Time Palau PW Ngerulmud',
  'Asia/Dili': 'Asia/Dili Asia/Dili Timor-Leste Time Timor Leste TL Dili Maliana Suai Likisá',
  'Asia/Chita': 'Asia/Chita Asia/Chita Asia/Khandyga Asia/Yakutsk Yakutsk Time Russia RU Chita Yakutsk Blagoveshchensk Belogorsk',
  'Australia/Adelaide': 'Australia/Adelaide Australia/Adelaide Australia/Broken_Hill Australia/South Australia/Yancowinna Australian Central Time Australia AU Adelaide Adelaide Hills Mount Gambier Morphett Vale',
  'Australia/Darwin': 'Australia/Darwin Australia/Darwin Australia/North Australian Central Time Australia AU Darwin Palmerston Alice Springs',
  'Australia/Brisbane': 'Australia/Brisbane Australia/Brisbane Australia/Lindeman Australia/Queensland Australian Eastern Time Australia AU Brisbane Gold Coast Sunshine Coast Logan City',
  'Australia/Sydney': 'Australia/Sydney Antarctica/Macquarie Australia/Hobart Australia/Melbourne Australia/Sydney Australia/Tasmania Australia/Currie Australia/Victoria Australia/ACT Australia/NSW Australia/Canberra Australian Eastern Time Australia AU Sydney Melbourne Newcastle Canberra',
  'Pacific/Guam': 'Pacific/Guam Pacific/Guam Pacific/Saipan Chamorro Time Guam GU Dededo Village Yigo Village Tamuning-Tumon-Harmon Village Tamuning',
  'Pacific/Port_Moresby': 'Pacific/Port_Moresby Pacific/Port_Moresby Antarctica/DumontDUrville Pacific/Chuuk Pacific/Yap Pacific/Truk Papua New Guinea Time Papua New Guinea PG Port Moresby Lae Mount Hagen Popondetta',
  'Asia/Vladivostok': 'Asia/Vladivostok Asia/Ust-Nera Asia/Vladivostok Vladivostok Time Russia RU Khabarovsk Vladivostok Khabarovsk Vtoroy Komsomolsk-on-Amur',
  'Australia/Lord_Howe': 'Australia/Lord_Howe Australia/Lord_Howe Australia/LHI Lord Howe Time Australia AU Lord Howe',
  'Pacific/Bougainville': 'Pacific/Bougainville Pacific/Bougainville Bougainville Time Papua New Guinea PG Arawa',
  'Pacific/Kosrae': 'Pacific/Kosrae Pacific/Kosrae Pacific/Pohnpei Kosrae Time Micronesia FM Kosrae Palikir',
  'Pacific/Noumea': 'Pacific/Noumea Pacific/Noumea New Caledonia Time New Caledonia NC Nouméa Mont-Dore Dumbéa',
  'Pacific/Norfolk': 'Pacific/Norfolk Pacific/Norfolk Norfolk Island Time Norfolk Island NF Kingston',
  'Asia/Sakhalin': 'Asia/Sakhalin Asia/Magadan Asia/Sakhalin Asia/Srednekolymsk Sakhalin Time Russia RU Yuzhno-Sakhalinsk Magadan Korsakov Kholmsk',
  'Pacific/Guadalcanal': 'Pacific/Guadalcanal Pacific/Guadalcanal Pacific/Pohnpei Pacific/Ponape Solomon Islands Time Solomon Islands SB Honiara Panatina Nggosi Tandai',
  'Pacific/Efate': 'Pacific/Efate Pacific/Efate Vanuatu Time Vanuatu VU Port-Vila',
  'Pacific/Fiji': 'Pacific/Fiji Pacific/Fiji Fiji Time Fiji FJ Nasinu Suva Lautoka Nadi',
  'Pacific/Tarawa': 'Pacific/Tarawa Pacific/Tarawa Pacific/Funafuti Pacific/Majuro Pacific/Wake Pacific/Wallis Gilbert Islands Time Kiribati KI Tarawa',
  'Asia/Kamchatka': 'Asia/Kamchatka Asia/Anadyr Asia/Kamchatka Kamchatka Time Russia RU Petropavlovsk-Kamchatsky Yelizovo Vilyuchinsk Anadyr',
  'Pacific/Nauru': 'Pacific/Nauru Pacific/Nauru Nauru Time Nauru NR Yaren',
  'Pacific/Auckland': 'Pacific/Auckland Pacific/Auckland NZ Antarctica/McMurdo Antarctica/South_Pole New Zealand Time New Zealand NZ Auckland Christchurch Wellington Manukau City',
  'Pacific/Chatham': 'Pacific/Chatham Pacific/Chatham NZ-CHAT Chatham Time New Zealand NZ Chatham',
  'Pacific/Kanton': 'Pacific/Kanton Pacific/Kanton Pacific/Enderbury Phoenix Islands Time Kiribati KI Kanton',
  'Pacific/Apia': 'Pacific/Apia Pacific/Apia Samoa Time Samoa WS Apia',
  'Pacific/Fakaofo': 'Pacific/Fakaofo Pacific/Fakaofo Tokelau Time Tokelau TK Fakaofo',
  'Pacific/Tongatapu': 'Pacific/Tongatapu Pacific/Tongatapu Tonga Time Tonga TO Nuku\'alofa',
  'Pacific/Kiritimati': 'Pacific/Kiritimati Pacific/Kiritimati Line Islands Time Kiribati KI Kiritimati',
};

/// Formats a UTC offset in minutes as 'UTC±HH:MM'.
String _formatOffsetPrefix(int offsetMinutes) {
  final String sign = offsetMinutes >= 0 ? '+' : '-';
  final int abs = offsetMinutes.abs();
  final int hours = abs ~/ 60;
  final int minutes = abs % 60;
  return "UTC$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
}

/// Generates a human-readable label from an IANA timezone path.
/// E.g. 'America/Indiana/Knox' → 'Indiana, Knox'
///      'America/Los_Angeles' → 'Los Angeles'
String _formatFallbackCity(String ianaName) {
  final List<String> parts = ianaName.split('/');
  // Drop the region prefix (e.g. 'America/', 'Asia/')
  final List<String> cityParts = parts.length > 1 ? parts.sublist(1) : parts;
  return cityParts.map((p) => p.replaceAll('_', ' ')).join(', ');
}

/// Generates searchable text from an IANA timezone name, its display label,
/// and its current abbreviation (e.g. 'PST', 'CEST').
///
/// Uses curated search text from `_kTimezoneSearchText` when available,
/// falling back to auto-generated text from the IANA path and label.
/// The abbreviation and IANA name variants are always appended.
String _formatSearchText(String ianaName, String label, String abbreviation) {
  final String normalizedIana =
      ianaName.replaceAll('_', ' ').replaceAll('/', ' ');
  final String? curated = _kTimezoneSearchText[ianaName];
  if (curated != null) {
    return '$curated $label $abbreviation $ianaName $normalizedIana';
  }
  return '$ianaName $normalizedIana $label $abbreviation';
}

/// Builds the timezone options list from Dart's timezone database.
///
/// Each entry is a real IANA timezone with dynamically computed offset.
/// The list is sorted by UTC offset (ascending), then alphabetically by label.
List<TimezoneOption> _buildTimezoneOptions() {
  tz.initializeTimeZones();

  final List<TimezoneOption> options = <TimezoneOption>[];

  // Always include UTC as first-class entry.
  options.add(
    const TimezoneOption(
      value: 'UTC',
      label: 'UTC+00:00 UTC',
      searchText: 'UTC Etc/UTC GMT Coordinated Universal Time',
      offsetMinutes: 0,
    ),
  );

  final Map<String, tz.Location> locations = tz.timeZoneDatabase.locations;

  for (final MapEntry<String, tz.Location> entry in locations.entries) {
    final String name = entry.key;

    // Skip Etc/ entries (confusing inverted-sign offsets) and Factory.
    if (name.startsWith('Etc/') || name == 'Factory') {
      continue;
    }

    final tz.TZDateTime now = tz.TZDateTime.now(entry.value);
    final int offsetMinutes = now.timeZoneOffset.inMinutes;
    final String abbreviation = now.timeZoneName;
    final String offsetPrefix = _formatOffsetPrefix(offsetMinutes);

    final String? curatedLabel = _kTimezoneLabels[name];
    final String description =
        curatedLabel ?? _formatFallbackCity(name);
    final String label = '$offsetPrefix $description';
    final String searchText = _formatSearchText(name, description, abbreviation);

    options.add(
      TimezoneOption(
        value: name,
        label: label,
        searchText: searchText,
        offsetMinutes: offsetMinutes,
      ),
    );
  }

  // Sort by offset first, then alphabetically by label.
  options.sort((TimezoneOption a, TimezoneOption b) {
    final int cmp = a.offsetMinutes.compareTo(b.offsetMinutes);
    if (cmp != 0) return cmp;
    return a.label.compareTo(b.label);
  });

  return List<TimezoneOption>.unmodifiable(options);
}

/// All available timezone options, built from Dart's timezone database.
///
/// Lazily initialized on first access. Offsets are computed dynamically
/// and are DST-correct at initialization time.
final List<TimezoneOption> kTimezoneOptions = _buildTimezoneOptions();
