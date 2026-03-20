import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/location.dart';
import '../models/tour_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('travel_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 23, // Nâng lên 23 để cập nhật nội dung Visiting và xóa khoảng trống
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 23) {
      await db.execute('DROP TABLE IF EXISTS locations');
      await db.execute('DROP TABLE IF EXISTS plans');
      await db.execute('DROP TABLE IF EXISTS plan_items');
      await db.execute('DROP TABLE IF EXISTS the_100_categories');
      await db.execute('DROP TABLE IF EXISTS the_100_items');
      await db.execute('DROP TABLE IF EXISTS tours');
      await db.execute('DROP TABLE IF EXISTS tour_images');
      await db.execute('DROP TABLE IF EXISTS tour_features');
      await db.execute('DROP TABLE IF EXISTS tour_itinerary');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    // 1. Locations
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        countStar INTEGER NOT NULL,
        isStarred INTEGER NOT NULL,
        continent TEXT NOT NULL,
        type TEXT
      )
    ''');

    // 2. Plans
    await db.execute('''
      CREATE TABLE plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        articleCount INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // 3. Plan Items
    await db.execute('''
      CREATE TABLE plan_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        planId INTEGER NOT NULL,
        locationId INTEGER NOT NULL,
        FOREIGN KEY (planId) REFERENCES plans (id) ON DELETE CASCADE,
        FOREIGN KEY (locationId) REFERENCES locations (id) ON DELETE CASCADE
      )
    ''');

    // 4. The 100 Categories
    await db.execute('''
      CREATE TABLE the_100_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        shortIntro TEXT NOT NULL,
        longIntro TEXT NOT NULL,
        imageUrl TEXT NOT NULL
      )
    ''');

    // 5. The 100 Items
    await db.execute('''
      CREATE TABLE the_100_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        fullContent TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES the_100_categories (id) ON DELETE CASCADE
      )
    ''');

    // 6. Tours
    await db.execute('''
      CREATE TABLE tours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        provider TEXT,
        duration TEXT,
        price TEXT,
        oldPrice TEXT,
        continent TEXT,
        views TEXT,
        startingEnding TEXT,
        country TEXT,
        visiting TEXT,
        tourOperator TEXT,
        tourCode TEXT,
        guideType TEXT,
        groupSize TEXT,
        physicalRating TEXT,
        ageRange TEXT,
        tourOperatedIn TEXT,
        tripStyle TEXT,
        overview TEXT,
        mapImageUrl TEXT,
        mainImageUrl TEXT
      )
    ''');

    // 7. Tour Images
    await db.execute('''
      CREATE TABLE tour_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tourId INTEGER,
        imageUrl TEXT,
        FOREIGN KEY (tourId) REFERENCES tours (id) ON DELETE CASCADE
      )
    ''');

    // 8. Tour Features
    await db.execute('''
      CREATE TABLE tour_features (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tourId INTEGER,
        title TEXT,
        description TEXT,
        type TEXT,
        FOREIGN KEY (tourId) REFERENCES tours (id) ON DELETE CASCADE
      )
    ''');

    // 9. Tour Itinerary
    await db.execute('''
      CREATE TABLE tour_itinerary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tourId INTEGER,
        dayTitle TEXT,
        description TEXT,
        location TEXT,
        accommodation TEXT,
        FOREIGN KEY (tourId) REFERENCES tours (id) ON DELETE CASCADE
      )
    ''');

    // Nạp dữ liệu mẫu cho Locations
    for (var loc in Location.sampleLocations) {
      await db.insert('locations', {
        'id': loc.id, 'name': loc.name, 'address': loc.address, 'description': loc.description,
        'imageUrl': loc.imageUrl, 'countStar': loc.countStar, 'isStarred': loc.isStarred ? 1 : 0,
        'continent': loc.continent, 'type': loc.type,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await _insertThe100SampleData(db);
    await _insertTourSampleData(db);
  }

  Future<void> _insertThe100SampleData(Database db) async {
    final categories = [
      {
        'title': 'Unique Food Cities',
        'shortIntro': 'Delicious metropolitan centers.',
        'longIntro': 'Explore culinary experiences that define culture.',
        'imageUrl': 'assets/img_1.png'
      },
      {
        'title': 'Otherworldly Landscapes',
        'shortIntro': 'Nature at its most surreal.',
        'longIntro': 'Discover salt flats and volcanic islands.',
        'imageUrl': 'assets/img_2.png'
      }
    ];

    for (var cat in categories) {
      int catId = await db.insert('the_100_categories', cat);
      await db.insert('the_100_items', {
        'categoryId': catId,
        'name': 'San Francisco, USA',
        'description': 'Famous for its sourdough bread.',
        'fullContent': 'San Francisco is a city known for its landmark Golden Gate Bridge. It is a food lover\'s paradise.',
        'imageUrl': 'assets/img_1.png'
      });
    }
  }

  Future<void> _insertTourSampleData(Database db) async {
    List<Map<String, dynamic>> sampleTours = [
      // Europe
      {
        'name': 'Greece sailing adventure: cyclades islands',
        'provider': 'by Intrepid Travel',
        'duration': '8 days',
        'price': '\$2372',
        'continent': 'Europe',
        'mainImageUrl': 'assets/img.png',
        'visiting': 'Santorini, Mykonos, Naxos, Amorgos, Ios, and more beautiful Cyclades islands.'
      },
      {
        'name': 'Highlights of Italy',
        'provider': 'by Expat Explore',
        'duration': '10 days',
        'price': '\$1850',
        'continent': 'Europe',
        'mainImageUrl': 'assets/img_5.png',
        'visiting': 'Rome, Florence, Venice, Pisa, Lake Garda, Milan, and the Vatican City.'
      },
      // Asia
      {
        'name': 'Delhi to goa',
        'provider': 'by Intrepid Travel',
        'duration': '15 days',
        'price': '\$747',
        'continent': 'Asia',
        'mainImageUrl': 'assets/img_1.png',
        'visiting': 'Delhi, Agra (Taj Mahal), Jaipur, Udaipur, Mumbai, and the beaches of Goa.'
      },
      {
        'name': 'Vietnam Express Southbound',
        'provider': 'by Intrepid Travel',
        'duration': '10 days',
        'price': '\$1250',
        'continent': 'Asia',
        'mainImageUrl': 'assets/img_6.png',
        'visiting': 'Hanoi, Halong Bay, Hue, Hoi An, Ho Chi Minh City, and the Mekong Delta.'
      },
      // Africa
      {
        'name': 'Cape town to zanzibar',
        'provider': 'by Intrepid Travel',
        'duration': '41 days',
        'price': '\$4953',
        'continent': 'Africa',
        'mainImageUrl': 'assets/img_2.png',
        'visiting': 'Cape Town, Victoria Falls, Serengeti National Park, Ngorongoro Crater, and Zanzibar beaches.'
      },
      {
        'name': 'Kenya Wildlife Safari',
        'provider': 'by G Adventures',
        'duration': '8 days',
        'price': '\$2100',
        'continent': 'Africa',
        'mainImageUrl': 'assets/img.png',
        'visiting': 'Nairobi, Masai Mara National Reserve, Lake Nakuru, and Amboseli National Park.'
      },
      // South America
      {
        'name': 'The great south american journey: quito to rio adventure',
        'provider': 'by G Adventures',
        'duration': '65 days',
        'price': '\$8659',
        'continent': 'South America',
        'mainImageUrl': 'assets/img_3.png',
        'visiting': 'Quito, Amazon Rainforest, Machu Picchu, Lake Titicaca, Buenos Aires, Iguassu Falls, and Rio de Janeiro.'
      },
      {
        'name': 'Machu Picchu Adventure',
        'provider': 'by Intrepid Travel',
        'duration': '7 days',
        'price': '\$1500',
        'continent': 'South America',
        'mainImageUrl': 'assets/img_1.png',
        'visiting': 'Cusco, Sacred Valley, Inca Trail, and the lost city of Machu Picchu.'
      },
      // Australia
      {
        'name': 'The wonders of australia with new zealand',
        'provider': 'by Travelsphere',
        'duration': '48 days',
        'price': '£ 15.298',
        'continent': 'Australia',
        'mainImageUrl': 'assets/img_4.png',
        'visiting': 'Sydney, Great Barrier Reef, Ayers Rock (Uluru), Melbourne, Auckland, Rotorua, and Queenstown.'
      },
      {
        'name': 'Great Ocean Road Tour',
        'provider': 'by Go West Tours',
        'duration': '3 days',
        'price': '\$450',
        'continent': 'Australia',
        'mainImageUrl': 'assets/img_2.png',
        'visiting': 'Melbourne, Torquay, Lorne, Apollo Bay, and the Twelve Apostles.'
      },
    ];

    for (var tourData in sampleTours) {
      int tourId = await db.insert('tours', {
        'name': tourData['name'],
        'provider': tourData['provider'],
        'duration': tourData['duration'],
        'price': tourData['price'],
        'continent': tourData['continent'],
        'mainImageUrl': tourData['mainImageUrl'],
        'visiting': tourData['visiting'] ?? '',
        'views': '125K Views',
        'startingEnding': '', // Xóa nội dung cũ để tránh khoảng trống
        'country': '', // Xóa nội dung cũ
        'tourOperator': tourData['provider'].replaceAll('by ', ''),
        'tourCode': 'TOUR-${tourData['continent'].substring(0, 2).toUpperCase()}-${DateTime.now().millisecond}',
        'guideType': 'Fully Guided',
        'groupSize': '1 - 20',
        'physicalRating': 'Medium',
        'ageRange': '12+',
        'tourOperatedIn': 'English',
        'tripStyle': 'Adventure, Discovery',
        'overview': 'Explore the wonders of ${tourData['continent']} in this amazing tour.',
        'mapImageUrl': 'assets/img_6.png',
      });

      await db.insert('tour_images', {'tourId': tourId, 'imageUrl': tourData['mainImageUrl']});
      await db.insert('tour_itinerary', {
        'tourId': tourId, 
        'dayTitle': 'Day 1: Arrival', 
        'description': 'Welcome to your adventure!', 
        'location': 'Start Point', 
        'accommodation': 'Hotel'
      });
    }
  }

  // --- Location CRUD ---
  Future<List<Location>> getAllLocations() async {
    final db = await instance.database;
    final result = await db.query('locations');
    return result.map((json) => Location(
      id: json['id'] as int, name: json['name'] as String, address: json['address'] as String,
      description: json['description'] as String, imageUrl: json['imageUrl'] as String,
      countStar: json['countStar'] as int, isStarred: (json['isStarred'] as int) == 1,
      continent: json['continent'] as String, type: json['type'] as String?,
    )).toList();
  }

  Future<int> insertLocation(Location location) async {
    final db = await instance.database;
    return await db.insert('locations', {
      'id': location.id, 'name': location.name, 'address': location.address,
      'description': location.description, 'imageUrl': location.imageUrl,
      'countStar': location.countStar, 'isStarred': location.isStarred ? 1 : 0,
      'continent': location.continent, 'type': location.type,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateLocation(Location location) async {
    final db = await instance.database;
    return await db.update('locations', {
      'name': location.name, 'address': location.address, 'description': location.description,
      'imageUrl': location.imageUrl, 'countStar': location.countStar,
      'isStarred': location.isStarred ? 1 : 0, 'continent': location.continent, 'type': location.type,
    }, where: 'id = ?', whereArgs: [location.id]);
  }

  Future<int> deleteLocation(int id) async {
    final db = await instance.database;
    return await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  // --- Plan CRUD ---
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    final db = await instance.database;
    return await db.query('plans', orderBy: 'createdAt DESC');
  }

  Future<int> insertPlan(String name) async {
    final db = await instance.database;
    return await db.insert('plans', {'name': name, 'articleCount': 0, 'createdAt': DateTime.now().toIso8601String()});
  }

  Future<int> updatePlanName(int id, String newName) async {
    final db = await instance.database;
    return await db.update('plans', {'name': newName}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePlan(int id) async {
    final db = await instance.database;
    return await db.delete('plans', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addItemToPlan(int planId, int locationId) async {
    final db = await instance.database;
    final existing = await db.query('plan_items', where: 'planId = ? AND locationId = ?', whereArgs: [planId, locationId]);
    if (existing.isNotEmpty) return -1;
    final id = await db.insert('plan_items', {'planId': planId, 'locationId': locationId});
    await db.execute('UPDATE plans SET articleCount = articleCount + 1 WHERE id = ?', [planId]);
    return id;
  }

  Future<List<Location>> getLocationsByPlanId(int planId) async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT l.* FROM locations l JOIN plan_items pi ON l.id = pi.locationId WHERE pi.planId = ?', [planId]);
    return result.map((json) => Location(
      id: json['id'] as int, name: json['name'] as String, address: json['address'] as String,
      description: json['description'] as String, imageUrl: json['imageUrl'] as String,
      countStar: json['countStar'] as int, isStarred: (json['isStarred'] as int) == 1,
      continent: json['continent'] as String, type: json['type'] as String?,
    )).toList();
  }

  Future<void> removeItemFromPlan(int planId, int locationId) async {
    final db = await instance.database;
    final count = await db.delete('plan_items', where: 'planId = ? AND locationId = ?', whereArgs: [planId, locationId]);
    if (count > 0) await db.execute('UPDATE plans SET articleCount = articleCount - 1 WHERE id = ?', [planId]);
  }

  Future<bool> isLocationInAnyPlan(int locationId) async {
    final db = await instance.database;
    final result = await db.query('plan_items', where: 'locationId = ?', whereArgs: [locationId], limit: 1);
    return result.isNotEmpty;
  }

  // --- The 100 CRUD ---
  Future<List<Map<String, dynamic>>> getThe100Categories() async {
    final db = await instance.database;
    return await db.query('the_100_categories');
  }

  Future<int> insertThe100Category(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('the_100_categories', row);
  }

  Future<int> updateThe100Category(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('the_100_categories', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteThe100Category(int id) async {
    final db = await instance.database;
    return await db.delete('the_100_categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getThe100ItemsByCategoryId(int catId) async {
    final db = await instance.database;
    return await db.query('the_100_items', where: 'categoryId = ?', whereArgs: [catId]);
  }

  Future<int> insertThe100Item(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('the_100_items', row);
  }

  Future<int> updateThe100Item(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('the_100_items', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteThe100Item(int id) async {
    final db = await instance.database;
    return await db.delete('the_100_items', where: 'id = ?', whereArgs: [id]);
  }

  // --- Tour Operations ---
  Future<List<TourData>> getToursByContinent(String continent) async {
    final db = await instance.database;
    final result = await db.query('tours', where: 'continent = ?', whereArgs: [continent]);
    return result.map((json) {
      var tour = TourData(
        id: json['id'] as int?, name: json['name'] as String? ?? '', provider: json['provider'] as String? ?? '',
        duration: json['duration'] as String? ?? '', price: json['price'] as String? ?? '',
        oldPrice: json['oldPrice'] as String? ?? '', continent: json['continent'] as String? ?? '',
        views: json['views'] as String? ?? '', startingEnding: json['startingEnding'] as String? ?? '',
        country: json['country'] as String? ?? '', visiting: json['visiting'] as String? ?? '',
        tourOperator: json['tourOperator'] as String? ?? '', tourCode: json['tourCode'] as String? ?? '',
        guideType: json['guideType'] as String? ?? '', groupSize: json['groupSize'] as String? ?? '',
        physicalRating: json['physicalRating'] as String? ?? '', ageRange: json['ageRange'] as String? ?? '',
        tourOperatedIn: json['tourOperatedIn'] as String? ?? '', tripStyle: json['tripStyle'] as String? ?? '',
        overview: json['overview'] as String? ?? '', mapImageUrl: json['mapImageUrl'] as String? ?? '',
      );
      tour.images = [json['mainImageUrl'] as String? ?? 'assets/img.png'];
      return tour;
    }).toList();
  }

  Future<TourData> getFullTourDetails(int tourId) async {
    final db = await instance.database;
    final tourResult = await db.query('tours', where: 'id = ?', whereArgs: [tourId]);
    if (tourResult.isEmpty) throw Exception('Tour not found');
    var json = tourResult.first;
    TourData tour = TourData(
      id: json['id'] as int?, name: json['name'] as String? ?? '', provider: json['provider'] as String? ?? '',
      duration: json['duration'] as String? ?? '', price: json['price'] as String? ?? '',
      oldPrice: json['oldPrice'] as String? ?? '', continent: json['continent'] as String? ?? '',
      views: json['views'] as String? ?? '', startingEnding: json['startingEnding'] as String? ?? '',
      country: json['country'] as String? ?? '', visiting: json['visiting'] as String? ?? '',
      tourOperator: json['tourOperator'] as String? ?? '', tourCode: json['tourCode'] as String? ?? '',
      guideType: json['guideType'] as String? ?? '', groupSize: json['groupSize'] as String? ?? '',
      physicalRating: json['physicalRating'] as String? ?? '', ageRange: json['ageRange'] as String? ?? '',
      tourOperatedIn: json['tourOperatedIn'] as String? ?? '', tripStyle: json['tripStyle'] as String? ?? '',
      overview: json['overview'] as String? ?? '', mapImageUrl: json['mapImageUrl'] as String? ?? '',
    );
    final imagesResult = await db.query('tour_images', where: 'tourId = ?', whereArgs: [tourId]);
    tour.images = imagesResult.map((e) => e['imageUrl'] as String).toList();
    if (tour.images.isEmpty) tour.images = [json['mainImageUrl'] as String? ?? 'assets/img.png'];
    final featuresResult = await db.query('tour_features', where: 'tourId = ?', whereArgs: [tourId]);
    for (var f in featuresResult) {
      var feature = TourFeature(title: f['title'] as String, description: f['description'] as String?, type: f['type'] as String);
      if (feature.type == 'highlight') tour.highlights.add(feature);
      else if (feature.type == 'included') tour.included.add(feature);
      else if (feature.type == 'notIncluded') tour.notIncluded.add(feature);
    }
    final itinResult = await db.query('tour_itinerary', where: 'tourId = ?', whereArgs: [tourId]);
    tour.itinerary = itinResult.map((e) => TourItinerary(dayTitle: e['dayTitle'] as String, description: e['description'] as String, location: e['location'] as String, accommodation: e['accommodation'] as String)).toList();
    return tour;
  }
}
