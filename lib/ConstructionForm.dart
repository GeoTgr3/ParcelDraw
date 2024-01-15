import 'package:flutter/material.dart';

import './models/GeoPoint.dart';
import './mongoHelpers/mongoHelpers.dart';
import 'models/localisation.dart';

class ConstructionForm extends StatefulWidget {
  final String lat;
  final String lng;
  final Function(Localization) onSubmit;

  ConstructionForm(
      {required this.lat, required this.lng, required this.onSubmit});

  @override
  _ConstructionFormState createState() => _ConstructionFormState();
}

class _ConstructionFormState extends State<ConstructionForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedUser;

  late double _lat;
  late double _lng;
  late GeoPoint _coordonneeSuperviseur;

  @override
  void initState() {
    super.initState();
    _lat =
        double.tryParse(widget.lat) ?? 0.0; // Default to 0.0 if parsing fails
    _lng =
        double.tryParse(widget.lng) ?? 0.0; // Default to 0.0 if parsing fails
    _coordonneeSuperviseur = GeoPoint(latitude: _lat, longitude: _lng);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          FutureBuilder<List<String>>(
            future: MongoHelpers.instance.fetchUserNames(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.hasData) {
                return DropdownButtonFormField<String>(
                  value: _selectedUser,
                  items: snapshot.data!
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedUser = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a user';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'User'),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),

          // Other TextFormField widgets...
          TextFormField(
            initialValue: widget.lat,
            decoration: InputDecoration(labelText: 'Latitude'),
          ),
          TextFormField(
            initialValue: widget.lng,
            decoration: InputDecoration(labelText: 'Longitude'),
          ),
          // ... other fields here ...
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                var localization = Localization(
                  name: _selectedUser!,
                  geometry: _coordonneeSuperviseur,
                );
                widget.onSubmit(localization);
                Navigator.of(context).pop();
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
