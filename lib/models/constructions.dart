/* class Construction {
  int? id;
  String type;
  Map<String, dynamic> geometry;
  String address;
  String contact;

  Construction({
    this.id,
    required this.type,
    required this.geometry,
    required this.address,
    required this.contact,
  });

  factory Construction.fromMap(Map<String, dynamic> map) => Construction(
        id: map['id'],
        type: map['type'],
        geometry: map['geometry'],
        address: map['address'],
        contact: map['contact'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'geometry': geometry,
      'address': address,
      'contact': contact,
    };
  }
}
 */

class Construction {
  int? id;
  String type;
  Map<String, dynamic> geometry;
  String address;
  String contact;
  String type_construction;

  Construction({
    this.id,
    required this.type,
    required this.geometry,
    required this.address,
    required this.contact,
    required this.type_construction,
  });

  factory Construction.fromMap(Map<String, dynamic> map) => Construction(
        id: map['id'],
        type: 'Feature',
        geometry: map['geometry'],
        address: map['address'],
        contact: map['contact'],
        type_construction: map['type'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': 'Feature',
      'geometry': geometry,
      'address': address,
      'contact': contact,
      'type_construction': type_construction,
    };
  }
}
