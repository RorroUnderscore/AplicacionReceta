import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalle_receta.dart';
import 'modificar_receta.dart';

class MisRecetasScreen extends StatelessWidget {
  void eliminarReceta(String recetaId) async {
    try {
      await FirebaseFirestore.instance.collection('recetas').doc(recetaId).delete();
      print("Receta eliminada correctamente");
    } catch (e) {
      print("Error al eliminar la receta: $e");
    }
  }

  void modificarReceta(BuildContext context, String recetaId) async {
    final recetaDoc = await FirebaseFirestore.instance.collection('recetas').doc(recetaId).get();

    if (recetaDoc.exists) {
      final recetaData = recetaDoc.data() as Map<String, dynamic>;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModificarReceta(
            recetaId: recetaId,
            receta: recetaData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La receta no se encontró.')),
      );
    }
  }


  Future<void> _confirmarEliminacion(BuildContext context, String recetaId) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Receta'),
          content: Text('¿Estás seguro de que deseas eliminar esta receta?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      try {
        await FirebaseFirestore.instance.collection('recetas').doc(recetaId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta eliminada con éxito')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la receta')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Recetas"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recetas')
            .where('uid_usuario', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var recetas = snapshot.data!.docs;

          if (recetas.isEmpty) {
            return Center(child: Text("No has creado recetas aún"));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
              children: List.generate(recetas.length, (index) {
                var receta = recetas[index];
                var nombreReceta = receta['nombre'];
                var imagenUrl = receta['imagen'];
                var tiempoPreparacion = receta['tiempo'];
                var recetaId = receta.id;

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Image.network(
                            imagenUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombreReceta,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(tiempoPreparacion, style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => modificarReceta(context, recetaId),
                                  child: Text("Modificar"),
                                ),
                                TextButton(
                                  onPressed: () => _confirmarEliminacion(context, recetaId),
                                  child: Text("Eliminar", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class EditarRecetaScreen extends StatelessWidget {
  final String recetaId;

  EditarRecetaScreen({required this.recetaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Receta"),
      ),
      body: Center(
        child: Text("Funcionalidad de edición para receta $recetaId"),
      ),
    );
  }
}
