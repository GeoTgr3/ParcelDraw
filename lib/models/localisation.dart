import './GeoPoint.dart';

class Localization {
  String? id; // Identifiant unique
  final String? name;
  GeoPoint geometry; // Coordonnée déterminée par le superviseur

  Localization({
    this.id,
    required this.name,
    required this.geometry,
  });

  // Convertit un objet Localisation en Map pour la sérialisation
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'geometry': {
        'type': 'Point',
        'coordinates': [geometry.latitude, geometry.longitude]
      },
    };
  }

  // Crée un objet Localisation à partir d'une Map
  static Localization fromMap(Map<String, dynamic> map) {
    return Localization(
      id: map['id'],
      name: map['name'],
      geometry: GeoPoint.fromMap(map['geometry']),
    );
  }
}
