
class TourData {
  final int? id;
  final String name;
  final String provider;
  final String duration;
  final String price;
  final String oldPrice;
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
  
  // These will be fetched from related tables
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
    required this.price,
    required this.oldPrice,
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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'duration': duration,
      'price': price,
      'oldPrice': oldPrice,
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
    };
  }
}

class TourFeature {
  final String title;
  final String? description;
  final String type; // 'highlight', 'included', 'notIncluded'

  TourFeature({required this.title, this.description, required this.type});
}

class TourItinerary {
  final String dayTitle;
  final String description;
  final String location;
  final String accommodation;

  TourItinerary({
    required this.dayTitle,
    required this.description,
    required this.location,
    required this.accommodation,
  });
}
