
class TourData {
  final int? id;
  final String name;
  final String provider;
  final String duration;
  final String continent;
  final String views;
  final String startingEnding;
  final String country;
  final String visiting;
  final String tourOperator;
  final String tourCode;
  final String guideType;
  final String groupSize;
  final String physicalRating;
  final String ageRange;
  final String tourOperatedIn;
  final String tripStyle;
  final String overview;
  final String mapImageUrl;
  final String mainImageUrl;
  final String price;

  List<String> images = [];
  List<TourFeature> highlights = [];
  List<TourFeature> included = [];
  List<TourFeature> notIncluded = [];
  List<TourItinerary> itinerary = [];

  TourData({
    this.id,
    required this.name,
    required this.provider,
    required this.duration,
    required this.continent,
    required this.views,
    required this.startingEnding,
    required this.country,
    required this.visiting,
    required this.tourOperator,
    required this.tourCode,
    required this.guideType,
    required this.groupSize,
    required this.physicalRating,
    required this.ageRange,
    required this.tourOperatedIn,
    required this.tripStyle,
    required this.overview,
    required this.mapImageUrl,
    required this.mainImageUrl,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'duration': duration,
      'continent': continent,
      'views': views,
      'startingEnding': startingEnding,
      'country': country,
      'visiting': visiting,
      'tourOperator': tourOperator,
      'tourCode': tourCode,
      'guideType': guideType,
      'groupSize': groupSize,
      'physicalRating': physicalRating,
      'ageRange': ageRange,
      'tourOperatedIn': tourOperatedIn,
      'tripStyle': tripStyle,
      'overview': overview,
      'mapImageUrl': mapImageUrl,
      'mainImageUrl': mainImageUrl,
      'price': price,
    };
  }

  factory TourData.fromMap(Map<String, dynamic> map) {
    return TourData(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      provider: map['provider'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      continent: map['continent'] as String? ?? '',
      views: map['views'] as String? ?? '',
      startingEnding: map['startingEnding'] as String? ?? '',
      country: map['country'] as String? ?? '',
      visiting: map['visiting'] as String? ?? '',
      tourOperator: map['tourOperator'] as String? ?? '',
      tourCode: map['tourCode'] as String? ?? '',
      guideType: map['guideType'] as String? ?? '',
      groupSize: map['groupSize'] as String? ?? '',
      physicalRating: map['physicalRating'] as String? ?? '',
      ageRange: map['ageRange'] as String? ?? '',
      tourOperatedIn: map['tourOperatedIn'] as String? ?? '',
      tripStyle: map['tripStyle'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      mapImageUrl: map['mapImageUrl'] as String? ?? '',
      mainImageUrl: map['mainImageUrl'] as String? ?? 'assets/img.png',
      price: map['price'] as String? ?? 'From \$0', // Đã thêm \ để fix lỗi syntax
    );
  }

  TourData copyWith({
    int? id,
    String? name,
    String? provider,
    String? duration,
    String? continent,
    String? views,
    String? startingEnding,
    String? country,
    String? visiting,
    String? tourOperator,
    String? tourCode,
    String? guideType,
    String? groupSize,
    String? physicalRating,
    String? ageRange,
    String? tourOperatedIn,
    String? tripStyle,
    String? overview,
    String? mapImageUrl,
    String? mainImageUrl,
    String? price,
  }) {
    return TourData(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      duration: duration ?? this.duration,
      continent: continent ?? this.continent,
      views: views ?? this.views,
      startingEnding: startingEnding ?? this.startingEnding,
      country: country ?? this.country,
      visiting: visiting ?? this.visiting,
      tourOperator: tourOperator ?? this.tourOperator,
      tourCode: tourCode ?? this.tourCode,
      guideType: guideType ?? this.guideType,
      groupSize: groupSize ?? this.groupSize,
      physicalRating: physicalRating ?? this.physicalRating,
      ageRange: ageRange ?? this.ageRange,
      tourOperatedIn: tourOperatedIn ?? this.tourOperatedIn,
      tripStyle: tripStyle ?? this.tripStyle,
      overview: overview ?? this.overview,
      mapImageUrl: mapImageUrl ?? this.mapImageUrl,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      price: price ?? this.price,
    );
  }
}

class TourFeature {
  final int? id;
  final int? tourId;
  final String title;
  final String? description;
  final String type;

  TourFeature({this.id, this.tourId, required this.title, this.description, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tourId': tourId,
      'title': title,
      'description': description,
      'type': type,
    };
  }
}

class TourItinerary {
  final int? id;
  final int? tourId;
  final String dayTitle;
  final String description;
  final String location;
  final String accommodation;

  TourItinerary({
    this.id,
    this.tourId,
    required this.dayTitle,
    required this.description,
    required this.location,
    required this.accommodation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tourId': tourId,
      'dayTitle': dayTitle,
      'description': description,
      'location': location,
      'accommodation': accommodation,
    };
  }
}
