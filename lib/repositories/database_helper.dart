import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      version: 26,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 25) {
      try {
        await db.execute('ALTER TABLE plans ADD COLUMN userId TEXT DEFAULT ""');
      } catch (e) {}
    }
    if (oldVersion < 26) {
      await db.execute('''
        CREATE TABLE downloaded_articles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          articleId INTEGER NOT NULL,
          userId TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          fullContent TEXT NOT NULL,
          imageUrl TEXT NOT NULL,
          downloadedAt TEXT NOT NULL
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        userId TEXT NOT NULL,
        articleCount INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE plan_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        planId INTEGER NOT NULL,
        locationId INTEGER NOT NULL,
        FOREIGN KEY (planId) REFERENCES plans (id) ON DELETE CASCADE,
        FOREIGN KEY (locationId) REFERENCES locations (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE the_100_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        shortIntro TEXT NOT NULL,
        longIntro TEXT NOT NULL,
        imageUrl TEXT NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE downloaded_articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        articleId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        fullContent TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        downloadedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        provider TEXT,
        duration TEXT,
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
        mainImageUrl TEXT,
        price TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tour_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tourId INTEGER,
        imageUrl TEXT,
        FOREIGN KEY (tourId) REFERENCES tours (id) ON DELETE CASCADE
      )
    ''');

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

    await db.execute('''
      CREATE TABLE tour_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tourId INTEGER,
        userName TEXT,
        rating REAL,
        comment TEXT,
        date TEXT,
        FOREIGN KEY (tourId) REFERENCES tours (id) ON DELETE CASCADE
      )
    ''');

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
      {'name': 'Greece sailing adventure: cyclades islands', 'provider': 'by Intrepid Travel', 'duration': '8 days', 'continent': 'Europe', 'mainImageUrl': 'assets/img.png', 'visiting': 'Santorini, Mykonos, naxos, Amorgos, Ios.', 'price': 'From \$1,200'},
      {'name': 'Highlights of Italy', 'provider': 'by Expat Explore', 'duration': '10 days', 'continent': 'Europe', 'mainImageUrl': 'assets/img_5.png', 'visiting': 'Rome, Florence, Venice, Pisa, Milan.', 'price': 'From \$1,500'},
      {'name': 'Vietnam Express Southbound', 'provider': 'by Intrepid Travel', 'duration': '10 days', 'continent': 'Asia', 'mainImageUrl': 'assets/img_6.png', 'visiting': 'Hanoi, Halong Bay, Hue, Hoi An, HCMC.', 'price': 'From \$800'},
    ];

    List<Map<String, dynamic>> reviewSamples = [
      {'userName': 'Nguyễn Văn Hưng', 'rating': 5.0, 'comment': 'Chuyến đi trên cả tuyệt vời! Hướng dẫn viên cực kỳ có tâm.'},
      {'userName': 'Linh Chi', 'rating': 5.0, 'comment': 'Cảnh đẹp mê hồn, đồ ăn rất ngon.'},
      {'userName': 'John Watson', 'rating': 4.0, 'comment': 'Well organized tour.'},
    ];

    for (int i = 0; i < sampleTours.length; i++) {
      var tourData = sampleTours[i];
      int tourId = await db.insert('tours', {
        'name': tourData['name'], 'provider': tourData['provider'], 'duration': tourData['duration'],
        'continent': tourData['continent'], 'mainImageUrl': tourData['mainImageUrl'],
        'visiting': tourData['visiting'] ?? '', 'views': '${150 + i * 20}K Views',
        'startingEnding': 'Round trip', 'country': 'Various', 'tourOperator': tourData['provider'].replaceAll('by ', ''),
        'tourCode': 'T-${tourData['continent'].substring(0, 1).toUpperCase()}${1000 + i}',
        'guideType': 'Expert Local Guide', 'groupSize': 'Max 12', 'physicalRating': 'Light',
        'ageRange': '8 - 80', 'tourOperatedIn': 'English', 'tripStyle': 'Adventure',
        'overview': 'Discover the soul of ${tourData['continent']} in this journey.',
        'mapImageUrl': 'assets/img_6.png', 'price': tourData['price']
      });

      await db.insert('tour_images', {'tourId': tourId, 'imageUrl': tourData['mainImageUrl']});
      await db.insert('tour_itinerary', {
        'tourId': tourId, 'dayTitle': 'Day 1: Arrival', 'description': 'Welcome dinner.',
        'location': 'Airport', 'accommodation': 'Boutique Hotel'
      });
      await db.insert('tour_features', {'tourId': tourId, 'title': 'Professional Local Guide', 'type': 'highlight'});

      for (int j = 0; j < 3; j++) {
        var rev = reviewSamples[(i * 3 + j) % reviewSamples.length];
        await db.insert('tour_reviews', {
          'tourId': tourId, 'userName': rev['userName'], 'rating': rev['rating'],
          'comment': rev['comment'], 'date': DateTime.now().subtract(Duration(days: j * 7)).toIso8601String(),
        });
      }
    }
  }

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

  Future<List<Map<String, dynamic>>> getAllPlans() async {
    final db = await instance.database;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "";
    return await db.query('plans', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
  }

  Future<int> insertPlan(String name) async {
    final db = await instance.database;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "";
    return await db.insert('plans', {
      'name': name, 
      'userId': userId,
      'articleCount': 0, 
      'createdAt': DateTime.now().toIso8601String()
    });
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
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "";
    final result = await db.rawQuery('''
      SELECT pi.id FROM plan_items pi 
      JOIN plans p ON pi.planId = p.id 
      WHERE pi.locationId = ? AND p.userId = ?
    ''', [locationId, userId]);
    return result.isNotEmpty;
  }

  Future<int> insertDownloadedArticle(Map<String, dynamic> article) async {
    final db = await instance.database;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "";
    
    final existing = await db.query('downloaded_articles', 
      where: 'articleId = ? AND userId = ?', 
      whereArgs: [article['id'], userId]);
      
    if (existing.isNotEmpty) return -1;

    return await db.insert('downloaded_articles', {
      'articleId': article['id'],
      'userId': userId,
      'name': article['name'],
      'description': article['description'],
      'fullContent': article['fullContent'],
      'imageUrl': article['imageUrl'],
      'downloadedAt': DateTime.now().toIso8601String()
    });
  }

  Future<List<Map<String, dynamic>>> getDownloadedArticles() async {
    final db = await instance.database;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "";
    // ĐÃ SỬA: Thêm whereArgs: [userId]
    return await db.query('downloaded_articles', where: 'userId = ?', whereArgs: [userId], orderBy: 'downloadedAt DESC');
  }

  Future<bool> isArticleDownloaded(int articleId) async {
    final db = await instance.database;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "";
    // ĐÃ SỬA: Thêm whereArgs: [userId]
    final result = await db.query('downloaded_articles', 
      where: 'articleId = ? AND userId = ?', 
      whereArgs: [articleId, userId]);
    return result.isNotEmpty;
  }

  Future<int> deleteDownloadedArticle(int id) async {
    final db = await instance.database;
    return await db.delete('downloaded_articles', where: 'id = ?', whereArgs: [id]);
  }

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

  Future<List<TourData>> getAllTours() async {
    final db = await instance.database;
    final result = await db.query('tours');
    return result.map((json) => TourData.fromMap(json)).toList();
  }

  Future<List<TourData>> getToursByContinent(String continent) async {
    final db = await instance.database;
    final result = await db.query('tours', where: 'continent = ?', whereArgs: [continent]);
    return result.map((json) => TourData.fromMap(json)).toList();
  }

  Future<List<TourData>> searchTours(String query) async {
    final db = await instance.database;
    final result = await db.query('tours', where: 'name LIKE ? OR visiting LIKE ?', whereArgs: ['%$query%', '%$query%']);
    return result.map((json) => TourData.fromMap(json)).toList();
  }

  Future<TourData> getFullTourDetails(int tourId) async {
    final db = await instance.database;
    final tourResult = await db.query('tours', where: 'id = ?', whereArgs: [tourId]);
    if (tourResult.isEmpty) throw Exception('Tour not found');
    var tour = TourData.fromMap(tourResult.first);

    final imagesResult = await db.query('tour_images', where: 'tourId = ?', whereArgs: [tourId]);
    tour.images = imagesResult.map((e) => e['imageUrl'] as String).toList();
    if (tour.images.isEmpty) tour.images = [tour.mainImageUrl];

    final featuresResult = await db.query('tour_features', where: 'tourId = ?', whereArgs: [tourId]);
    tour.highlights = []; tour.included = []; tour.notIncluded = [];
    for (var f in featuresResult) {
      var feature = TourFeature(id: f['id'] as int?, tourId: f['tourId'] as int?, title: f['title'] as String, description: f['description'] as String?, type: f['type'] as String);
      if (feature.type == 'highlight') tour.highlights.add(feature);
      else if (feature.type == 'included') tour.included.add(feature);
      else if (feature.type == 'notIncluded') tour.notIncluded.add(feature);
    }
    final itinResult = await db.query('tour_itinerary', where: 'tourId = ?', whereArgs: [tourId]);
    tour.itinerary = itinResult.map((e) => TourItinerary(id: e['id'] as int?, tourId: e['tourId'] as int?, dayTitle: e['dayTitle'] as String, description: e['description'] as String, location: e['location'] as String, accommodation: e['accommodation'] as String)).toList();
    return tour;
  }

  Future<int> insertTour(TourData tour) async {
    final db = await instance.database;
    return await db.insert('tours', tour.toMap());
  }

  Future<int> updateTour(TourData tour) async {
    final db = await instance.database;
    return await db.update('tours', tour.toMap(), where: 'id = ?', whereArgs: [tour.id]);
  }

  Future<int> deleteTour(int id) async {
    final db = await instance.database;
    return await db.delete('tours', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTourFeature(TourFeature feature) async {
    final db = await instance.database;
    return await db.insert('tour_features', feature.toMap());
  }

  Future<int> insertTourItinerary(TourItinerary itinerary) async {
    final db = await instance.database;
    return await db.insert('tour_itinerary', itinerary.toMap());
  }

  Future<int> insertTourImage(int tourId, String imageUrl) async {
    final db = await instance.database;
    return await db.insert('tour_images', {'tourId': tourId, 'imageUrl': imageUrl});
  }

  Future<void> deleteTourImages(int tourId) async {
    final db = await instance.database;
    await db.delete('tour_images', where: 'tourId = ?', whereArgs: [tourId]);
  }

  Future<int> insertReview(int tourId, String userName, double rating, String comment) async {
    final db = await instance.database;
    return await db.insert('tour_reviews', {
      'tourId': tourId, 'userName': userName, 'rating': rating, 'comment': comment,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getReviewsByTourId(int tourId) async {
    final db = await instance.database;
    return await db.query('tour_reviews', where: 'tourId = ?', whereArgs: [tourId], orderBy: 'date DESC');
  }
}
