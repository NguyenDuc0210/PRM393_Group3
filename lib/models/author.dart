class Author {
  final String name;
  final String role;
  final String bio;
  final String imageUrl;
  final int age;
  final String country;
  final List<String> hobbies;
  final String lifeView;
  final int countriesVisited;

  Author({
    required this.name,
    required this.role,
    required this.bio,
    required this.imageUrl,
    required this.age,
    required this.country,
    required this.hobbies,
    required this.lifeView,
    required this.countriesVisited,
  });

  static final Author sampleAuthor = Author(
    name: 'Cassam Looch',
    role: 'Editorial Manager',
    imageUrl: 'assets/img_5.png',
    age: 35,
    country: 'United Kingdom',
    hobbies: ['Film', 'Travel Writing', 'Photography', 'Cycling'],
    lifeView: 'The world is a book and those who do not travel read only one page.',
    countriesVisited: 50,
    bio: 'Cassam Looch has been working within travel for more than a decade. An expert on film locations and set jetting destinations, Cassam is also a keen advocate of the many unique things to do in his home city of London. With more than 50 countries visited (so far), Cassam also has a great take on the rest of the world.',
  );
}
