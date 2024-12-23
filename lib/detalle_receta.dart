import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'valorar_receta.dart';

class RecipeDetailsPage extends StatefulWidget {
  final String recipeId;

  RecipeDetailsPage({required this.recipeId});

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      // Obtener el usuario actual autenticado
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print("No hay usuario autenticado.");
        return;
      }

      final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final userSnapshot = await userDoc.get();
      
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;

        // Verificamos si 'favoritos' existe en los datos del usuario, sino inicializamos como una lista vacía
        final favoriteRecipes = List<String>.from(userData['favoritos'] ?? []); 
        
        // Verificamos si la receta está en los favoritos
        setState(() {
          isFavorite = favoriteRecipes.contains(widget.recipeId);
        });
        print("Receta es favorita: $isFavorite");
      } else {
        print("El documento del usuario no existe.");
      }
    } catch (e) {
      print("Error al verificar si la receta es favorita: $e");
    }
  }


  // Función para agregar la receta a los favoritos
  Future<void> _addToFavorites() async {
    try {
      // Obtener el usuario actual autenticado
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print("No hay usuario autenticado.");
        return;
      }

      final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final userSnapshot = await userDoc.get();
      
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        
        // Verificamos si 'favoritos' existe en los datos del usuario, sino inicializamos como una lista vacía
        List<String> favoriteRecipes = List<String>.from(userData['favoritos'] ?? []);
        favoriteRecipes.add(widget.recipeId); // Añadimos la receta a los favoritos

        // Actualizamos la lista de favoritos en Firestore
        await userDoc.update({'favoritos': favoriteRecipes});
        print("Receta agregada a favoritos.");
      } else {
        print("El documento del usuario no existe.");
      }
    } catch (e) {
      print("Error al agregar a favoritos: $e");
    }
  }

  Future<void> _removeFromFavorites() async {
    try {
      // Obtener el usuario actual autenticado
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print("No hay usuario autenticado.");
        return;
      }

      final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final userSnapshot = await userDoc.get();
      
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        
        // Verificamos si 'favoritos' existe en los datos del usuario
        List<String> favoriteRecipes = List<String>.from(userData['favoritos'] ?? []);
        favoriteRecipes.remove(widget.recipeId); // Quitamos la receta de los favoritos

        // Actualizamos la lista de favoritos en Firestore
        await userDoc.update({'favoritos': favoriteRecipes});
        print("Receta eliminada de favoritos.");
      } else {
        print("El documento del usuario no existe.");
      }
    } catch (e) {
      print("Error al quitar de favoritos: $e");
    }
  }

  // Función que se ejecuta cuando el botón es presionado
  void _toggleFavorite() async {
    if (isFavorite) {
      await _removeFromFavorites();  // Si ya es favorito, lo quitamos
    } else {
      await _addToFavorites();  // Si no es favorito, lo agregamos
    }
    setState(() {
      isFavorite = !isFavorite;  // Cambiar el estado de favorito
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Receta'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('recetas').doc(widget.recipeId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Receta no encontrada'));
          }

          final recetaData = snapshot.data!.data() as Map<String, dynamic>;

          final ingredientes = recetaData['ingredientes'] as List<dynamic>? ?? [];
          final pasos = recetaData['pasos'] as List<dynamic>? ?? [];
          final usuarioId = recetaData['uid_usuario'] ?? '';
          final promedioValoracion = recetaData['valoracion_promedio'] ?? 0.0;
          final numeroValoraciones = recetaData['numero_valoraciones'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de la receta
                  Image.network(
                    recetaData['imagen'] ?? '',
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                  ),
                  SizedBox(height: 16),

                  // Nombre de la receta
                  Text(
                    recetaData['nombre'] ?? 'Sin nombre',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 8),

                  // Nombre del usuario que creó la receta
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('usuarios').doc(usuarioId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Text('Cargando autor...');
                      }
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return Text('Autor desconocido');
                      }

                      final usuarioData = userSnapshot.data!.data() as Map<String, dynamic>;
                      return Text(
                        'Creado por: ${usuarioData['nombre'] ?? 'Nombre desconocido'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  ),
                  SizedBox(height: 16),

                  // Tiempo de preparación
                  Text(
                    'Tiempo de preparación: ${recetaData['tiempo'] ?? 'Desconocido'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Text(
                        '${promedioValoracion.toStringAsFixed(1)} ($numeroValoraciones)',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ValorarRecetaPage(recipeId: widget.recipeId),
                            ),
                          );
                        },
                        child: Text('Valorar'),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleFavorite,
                    child: Text(isFavorite ? 'Quitar de Favoritos' : 'Agregar a Favoritos'),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Ingredientes:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  ingredientes.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ingredientes.length,
                          itemBuilder: (context, index) {
                            final ingrediente = ingredientes[index] as Map<String, dynamic>;
                            return ListTile(
                              title: Text(ingrediente['ingrediente'] ?? 'Ingrediente desconocido'),
                              subtitle: Text(ingrediente['cantidad'] ?? 'Cantidad desconocida'),
                            );
                          },
                        )
                      : Text('No hay ingredientes disponibles.'),
                  SizedBox(height: 16),

                  // Pasos
                  Text(
                    'Pasos:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  pasos.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pasos.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(pasos[index]),
                            );
                          },
                        )
                      : Text('No hay pasos disponibles.'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}