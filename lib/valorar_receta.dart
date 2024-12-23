import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ValorarRecetaPage extends StatefulWidget {
  final String recipeId;

  ValorarRecetaPage({required this.recipeId});

  @override
  _ValorarRecetaPageState createState() => _ValorarRecetaPageState();
}

class _ValorarRecetaPageState extends State<ValorarRecetaPage> {
  final _formKey = GlobalKey<FormState>();
  int _puntaje = 1;
  String _descripcion = '';

  Future<void> _guardarValoracion() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Usuario no autenticado.");
        return;
      }

      final recetaDoc =
          FirebaseFirestore.instance.collection('recetas').doc(widget.recipeId);

      final recetaSnapshot = await recetaDoc.get();
      if (!recetaSnapshot.exists) {
        print("La receta no existe.");
        return;
      }

      final recetaData = recetaSnapshot.data() as Map<String, dynamic>;
      List<dynamic> valoraciones = recetaData['valoraciones'] ?? [];

      final existingIndex =
          valoraciones.indexWhere((v) => v['uid'] == user.uid);
      if (existingIndex != -1) {
        valoraciones[existingIndex] = {
          'uid': user.uid,
          'puntaje': _puntaje,
          'descripcion': _descripcion,
        };
      } else {
        valoraciones.add({
          'uid': user.uid,
          'puntaje': _puntaje,
          'descripcion': _descripcion,
        });
      }

      await recetaDoc.update({'valoraciones': valoraciones});
      print("Valoración guardada correctamente.");

      double promedioValoracion = valoraciones
              .map((v) => v['puntaje'])
              .reduce((a, b) => a + b) /
          valoraciones.length;

      await recetaDoc.update({
        'valoracion_promedio': promedioValoracion,
        'numero_valoraciones': valoraciones.length,
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error al guardar la valoración: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valorar Receta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Puntuación:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Slider(
                value: _puntaje.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _puntaje.toString(),
                onChanged: (value) {
                  setState(() {
                    _puntaje = value.toInt();
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Comentario'),
                maxLines: 3,
                onChanged: (value) {
                  _descripcion = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un comentario.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _guardarValoracion();
                  }
                },
                child: Text('Guardar Valoración'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
