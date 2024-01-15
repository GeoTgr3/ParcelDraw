class GeoPoint {
  double latitude;
  double longitude;

  GeoPoint({required this.latitude, required this.longitude});

  // Method to create a GeoPoint from a Map. This is typically used when
  // deserializing data from a database or a service.
  static GeoPoint fromMap(Map<String, dynamic> map) {
    double parseCoordinate(dynamic value) {
      if (value is Map && value.containsKey('\$numberDouble')) {
        return double.parse(value['\$numberDouble'].toString());
      } else if (value is double) {
        return value;
      } else if (value is String) {
        var parsedValue = double.tryParse(value);
        if (parsedValue != null) {
          return parsedValue;
        } else {
          throw FormatException('Invalid coordinate format');
        }
      } else {
        throw FormatException('Invalid coordinate format');
      }
    }

    // Assuming that the 'coordinates' field is an array with two elements
    // [latitude, longitude]
    return GeoPoint(
      latitude: parseCoordinate(map['coordinates'][0]),
      longitude: parseCoordinate(map['coordinates'][1]),
    );
  }

  // Method to convert a GeoPoint to a Map. This is typically used when
  // serializing data to store in a database or to send to a service.
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
