class Location {
  final int id;
  final String name;
  final String address;
  final String description;
  int countStar;
  bool isStarred;
  final String imageUrl;
  final String continent;

  Location({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.countStar,
    required this.imageUrl,
    required this.continent,
    this.isStarred = false,
  });

  Location copyWith({
    int? id,
    String? name,
    String? address,
    String? description,
    int? countStar,
    bool? isStarred,
    String? imageUrl,
    String? continent,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      countStar: countStar ?? this.countStar,
      isStarred: isStarred ?? this.isStarred,
      imageUrl: imageUrl ?? this.imageUrl,
      continent: continent ?? this.continent,
    );
  }

  static final List<Location> sampleLocations = [
    Location(
      id: 1,
      name: 'Oeschinen Lake Campground',
      address: 'Kandersteg, Switzerland',
      description:
          'Lake Oeschinen lies at the foot of the Blüemlisalp in the Bernese Alps. A beautiful Alpine lake perfect for summer activities.',
      countStar: 41,
      imageUrl: 'assets/img_1.png',
      continent: 'europe',
    ),
    Location(
      id: 2,
      name: 'Matterhorn Mountain',
      address: 'Zermatt, Switzerland',
      description:
          'The iconic pyramid-shaped mountain in the Swiss Alps. One of the highest peaks and most photographed mountains in the world.',
      countStar: 52,
      imageUrl: 'assets/img.png',
      continent: 'europe',
    ),
    Location(
      id: 3,
      name: 'Ha Long Bay',
      address: 'Quang Ninh, Vietnam',
      description: 'A UNESCO World Heritage site with thousands of limestone karsts and isles in various shapes and sizes.',
      countStar: 98,
      imageUrl: 'assets/img_2.png',
      continent: 'asia',
    ),
    Location(
      id: 4,
      name: 'Mount Fuji',
      address: 'Honshu, Japan',
      description: 'An active volcano and the highest mountain in Japan, known for its symmetrical cone.',
      countStar: 105,
      imageUrl: 'assets/img_3.png',
      continent: 'asia',
    ),
    Location(
      id: 5,
      name: 'Grand Canyon',
      address: 'Arizona, USA',
      description: 'A massive canyon carved by the Colorado River, known for its visually overwhelming size and intricate and colorful landscape.',
      countStar: 120,
      imageUrl: 'assets/img_1.png',
      continent: 'america',
    ),
    Location(
      id: 6,
      name: 'Machu Picchu',
      address: 'Cusco Region, Peru',
      description: 'An Incan citadel set high in the Andes Mountains in Peru, renowned for its sophisticated dry-stone walls.',
      countStar: 110,
      imageUrl: 'assets/img.png',
      continent: 'america',
    ),
    // Châu Phi
    Location(
      id: 7,
      name: 'Victoria Falls',
      address: 'Zambia/Zimbabwe',
      description: 'One of the Seven Natural Wonders of the World, it is the largest waterfall in the world by total area.',
      countStar: 95,
      imageUrl: 'assets/img_2.png',
      continent: 'africa',
    ),
    Location(
      id: 8,
      name: 'Serengeti National Park',
      address: 'Tanzania',
      description: 'Famous for its massive annual migration of wildebeest and zebra.',
      countStar: 90,
      imageUrl: 'assets/img_3.png',
      continent: 'africa',
    ),

    Location(
      id: 9,
      name: 'Sydney Opera House',
      address: 'Sydney, Australia',
      description: 'A multi-venue performing arts centre at Sydney Harbour, it is one of the 20th century\'s most famous and distinctive buildings.',
      countStar: 130,
      imageUrl: 'assets/img_1.png',
      continent: 'oceania',
    ),
    Location(
      id: 10,
      name: 'Fiordland National Park',
      address: 'South Island, New Zealand',
      description: 'A national park in the southwest corner of the South Island, known for the glacier-carved fiords of Doubtful and Milford Sounds.',
      countStar: 100,
      imageUrl: 'assets/img.png',
      continent: 'oceania',
    ),
  ];
}
