import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class CrearReceta extends StatefulWidget {
  @override
  _CrearRecetaScreenState createState() => _CrearRecetaScreenState();
}

class _CrearRecetaScreenState extends State<CrearReceta> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ingredientesController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _pasosController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _minutosController = TextEditingController();

  TimeOfDay _tiempo = TimeOfDay(hour: 0, minute: 0);
  String _dificultad = 'Fácil';
  List<Map<String, String>> _ingredientes = [];
  List<Map<String, String>> _pasos = [];

  File? _imagen;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagen = File(image.path);
        });
      }
    }

    Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _imagen != null) {
      try {
        // Calcular el tiempo legible
        int horas = int.tryParse(_horaController.text) ?? 0;
        int minutos = int.tryParse(_minutosController.text) ?? 0;
        String tiempoLegible = '';
        if (horas > 0) tiempoLegible += '$horas h ';
        if (minutos > 0) tiempoLegible += '$minutos min';
        if (horas == 0 && minutos == 0) tiempoLegible = '0 min';

        // Mostrar mensaje de progreso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subiendo imagen...')),
        );

        // Subir la imagen a Firebase Storage
        String imageUrl = await _uploadImageToFirebase(_imagen!);
        if (imageUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir la imagen')),
          );
          return;
        }

        // Guardar los datos en Firestore
        await FirebaseFirestore.instance.collection('recetas').add({
          'nombre': _nombreController.text,
          'imagen': imageUrl,
          'hora': horas,
          'minutos': minutos,
          'tiempo': tiempoLegible,
          'dificultad': _dificultad,
          'ingredientes': _ingredientes,
          'pasos': _pasos.map((e) => e['descripcion']).toList(),
          'valoraciones': [],
          'uid_usuario': FirebaseAuth.instance.currentUser?.uid,
        });

        // Notificar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta creada con éxito')),
        );

        // Regresar a la pantalla anterior
        Navigator.pop(context);
      } catch (e) {
        print('Error al crear la receta: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar receta')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos e incluye una imagen.')),
      );
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      // Define la referencia en el Storage (carpeta "recetas" dentro de tu bucket)
      final ref = FirebaseStorage.instance
          .ref()
          .child('recetas/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Subir la imagen
      await ref.putFile(image);

      // Obtener la URL de descarga
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Receta'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre de la receta
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la receta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  } else if (value.length > 50) {
                    return 'El nombre no puede tener más de 50 caracteres';
                  }
                  return null;
                },
              ),

              // Foto de la receta
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Foto'),
              ),
              if (_imagen != null) Image.file(_imagen!),

              // Tiempo de preparación
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Horas',
                        hintText: 'Ej. 1',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return 'Por favor, ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _minutosController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Minutos',
                        hintText: 'Ej. 30',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return 'Por favor, ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),


              // Dificultad
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _dificultad,
                onChanged: (value) {
                  setState(() {
                    _dificultad = value!;
                  });
                },
                items: [
                  'Fácil',
                  'Medio',
                  'Difícil',
                  'Muy difícil'
                ].map((String dificultad) {
                  return DropdownMenuItem<String>(
                    value: dificultad,
                    child: Text(dificultad),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Dificultad'),
              ),

              // Ingredientes
              SizedBox(height: 10),
              Text('Ingredientes'),
              SingleChildScrollView(  // Agregar un SingleChildScrollView
                scrollDirection: Axis.vertical,  // Asegúrate de que se desplace en vertical
                child: Column(
                  children: List.generate(_ingredientes.length, (index) {
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: TextEditingController(text: _ingredientes[index]['cantidad']),
                              decoration: InputDecoration(labelText: 'Cantidad del ingrediente'),
                              onChanged: (value) {
                                setState(() {
                                  _ingredientes[index]['cantidad'] = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: TextEditingController(text: _ingredientes[index]['ingrediente']),
                              decoration: InputDecoration(labelText: 'Ingrediente'),
                              onChanged: (value) {
                                setState(() {
                                  _ingredientes[index]['ingrediente'] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            _ingredientes.removeAt(index);
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _ingredientes.add({'cantidad': '', 'ingrediente': ''});
                  });
                },
              ),

              // Pasos
              SizedBox(height: 10),
              Text('Pasos'),
              SingleChildScrollView(  // Agregar un SingleChildScrollView
                scrollDirection: Axis.vertical,
                child: Column(
                  children: List.generate(_pasos.length, (index) {
                    return ListTile(
                      title: TextField(
                        controller: TextEditingController(text: _pasos[index]['nombre']),
                        decoration: InputDecoration(labelText: 'Nombre del paso'),
                        onChanged: (value) {
                          setState(() {
                            _pasos[index]['nombre'] = value;
                          });
                        },
                      ),
                      subtitle: TextFormField(
                        controller: TextEditingController(text: _pasos[index]['descripcion']),
                        decoration: InputDecoration(labelText: 'Descripción del paso'),
                        onChanged: (value) {
                          setState(() {
                            _pasos[index]['descripcion'] = value;
                          });
                        },
                        maxLines: 5,
                        minLines: 3,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _pasos.removeAt(index);
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _pasos.add({'nombre': '', 'descripcion': ''});
                  });
                },
              ),

              // Botón para enviar el formulario
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Guardar Receta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
