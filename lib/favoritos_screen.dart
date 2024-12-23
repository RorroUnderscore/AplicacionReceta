import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalle_receta.dart';

class FavoritosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Favoritos"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var usuario = snapshot.data!;
          var favoritos = List.from(usuario['favoritos'] ?? []);

          if (favoritos.isEmpty) {
            return Center(child: Text("No tienes recetas favoritas aún"));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('recetas').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var recetas = snapshot.data!.docs;
              var recetasFavoritas = recetas.where((receta) {
                return favoritos.contains(receta.id);
              }).toList();

              return SingleChildScrollView(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: List.generate(recetasFavoritas.length, (index) {
                    var receta = recetasFavoritas[index];
                    var nombreReceta = receta['nombre'];
                    var imagenUrl = receta['imagen'];
                    var valoraciones = receta['valoracion'];
                    var tiempoPreparacion = receta['tiempo'];

                    double promedio = 0.0;
                    int numeroValoraciones = valoraciones.length;
                    if (numeroValoraciones > 0) {
                      double sumaPuntajes =
                          valoraciones.fold(0.0, (sum, valoracion) => sum + valoracion['puntaje']);
                      promedio = sumaPuntajes / numeroValoraciones;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailsPage(
                              recipeId: receta.id,
                            ),
                          ),
                        );
                      },
                      child: Card(
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
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.yellow),
                                      Text('${promedio.toStringAsFixed(1)} ($numeroValoraciones)'),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(tiempoPreparacion, style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
