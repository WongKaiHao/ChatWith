import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String? id;
  final String email;
  final String image;
  final Timestamp lastSeen;
  final String name;

  ContactModel({this.id, required this.email, required this.image, required this.lastSeen, required this.name});

  factory ContactModel.fromSnapshot(DocumentSnapshot _snapshot){
    final Map<String, dynamic>? _data = _snapshot.data() as Map<String, dynamic>?;

    if (_data == null) {
      throw Exception("Document data is null.");
    }

    return ContactModel(
      id: _snapshot.id,
      email: _data["email"],
      image: _data["image"],
      lastSeen: _data["lastSeen"],
      name: _data["name"],
    );
  }
}