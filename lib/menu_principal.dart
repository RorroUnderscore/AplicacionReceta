import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'detalle_receta.dart'; // Importamos la pantalla de detalles

class MenuPrincipal extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Recetas App"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favoritos');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text("Menú"),
            ),
            ListTile(
              title: Text('Ver Favoritos'),
              onTap: () {
                Navigator.pushNamed(context, '/favoritos');
              },
            ),
            ListTile(
              title: Text('Crear Receta'),
              onTap: () {
                Navigator.pushNamed(context, '/crearReceta');
              },
            ),
            ListTile(
              title: Text('Ver mis Recetas'),
              onTap: () {
                Navigator.pushNamed(context, '/misRecetas');
              },
            ),
            ListTile(
              title: Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recetas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var recetas = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
              children: List.generate(recetas.length, (index) {
                var receta = recetas[index];
                var nombreReceta = receta['nombre'];
                var imagenUrl = receta['imagen'];
                var valoraciones = receta['valoraciones'];
                var tiempoPreparacion = receta['tiempo'];
                var uidUsuario = receta['uid_usuario'];

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
                          height: 200, // Limita la altura de la imagen
                          width: double.infinity, // La imagen ocupará todo el ancho
                          child: Image.network(
                            imagenUrl,
                            fit: BoxFit.cover, // Para ajustar la imagen sin distorsionarla
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
      ),
    );
  }
}
