import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  // Obtiene una instancia de Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ejemplo de función para agregar datos a Firestore
  Future<void> addData(String collectionName, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionName).add(data);
      print("Datos agregados correctamente.");
    } catch (e) {
      print("Error al agregar datos: $e");
    }
  }

  // Ejemplo de función para obtener datos desde una colección de Firestore
  Future<List<Map<String, dynamic>>> getData(String collectionName) async {
    try {
      QuerySnapshot snapshot = await _db.collection(collectionName).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error al obtener datos: $e");
      return [];
    }
  }
}
