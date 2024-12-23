import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ModificarReceta extends StatefulWidget {
  final String recetaId;
  final Map<String, dynamic> receta;

  ModificarReceta({required this.recetaId, required this.receta});

  @override
  _ModificarRecetaScreenState createState() => _ModificarRecetaScreenState();
}

class _ModificarRecetaScreenState extends State<ModificarReceta> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _ingredientesController;
  late TextEditingController _descripcionController;
  late TextEditingController _pasosController;
  late TextEditingController _horaController;
  late TextEditingController _minutosController;
  String _dificultad = 'Fácil';
  File? _imagen;
  late List<Map<String, dynamic>> _ingredientes = [];
  late List<String> _pasos = [];

  @override
  void initState() {
    super.initState();
    final receta = widget.receta;
    _nombreController = TextEditingController(text: receta['nombre']);
    _horaController = TextEditingController(text: receta['hora'].toString());
    _minutosController = TextEditingController(text: receta['minutos'].toString());
    _dificultad = receta['dificultad'];
    _ingredientes = List<Map<String, dynamic>>.from(
      receta['ingredientes']?.map((ingrediente) => {
            'cantidad': ingrediente['cantidad'] ?? '',
            'ingrediente': ingrediente['ingrediente'] ?? '',
          }) ?? [],
    );


    _pasos = List<String>.from(receta['pasos'] ?? []);
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagen = File(image.path);
      });
    }
  }

  void _addIngrediente() {
    setState(() {
      _ingredientes.add({'cantidad': '', 'ingrediente': ''});
    });
  }

  void _addPaso() {
    setState(() {
      _pasos.add('');
    });
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      try {
        int horas = int.tryParse(_horaController.text) ?? 0;
        int minutos = int.tryParse(_minutosController.text) ?? 0;
        String tiempoLegible = '';
        if (horas > 0) {
          tiempoLegible += '$horas h ';
        }
        if (minutos > 0) {
          tiempoLegible += '$minutos min';
        }
        if (horas == 0 && minutos == 0) {
          tiempoLegible = '0 min';
        }

        final recetaRef = FirebaseFirestore.instance.collection('recetas').doc(widget.recetaId);

        String? nuevaImagenUrl;

        if (_imagen != null) {
          final storageRef = FirebaseStorage.instance.ref();
          final imagenRef = storageRef.child('recetas/${widget.recetaId}.jpg');
          await imagenRef.putFile(_imagen!);
          nuevaImagenUrl = await imagenRef.getDownloadURL();
        }

        Map<String, dynamic> actualizacion = {
          'nombre': _nombreController.text,
          'hora': horas,
          'minutos': minutos,
          'tiempo': tiempoLegible,
          'dificultad': _dificultad,
          'ingredientes': _ingredientes.map((ingrediente) => {
            'cantidad': ingrediente['cantidad'] ?? '',
            'ingrediente': ingrediente['ingrediente'] ?? '',
          }).toList(),
          'pasos': _pasos,
        };

        if (nuevaImagenUrl != null) {
          actualizacion['imagen'] = nuevaImagenUrl;
        }

        await recetaRef.update(actualizacion);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta modificada con éxito')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al modificar la receta')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar Receta'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la receta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Nueva Foto'),
              ),
              if (_imagen != null) Image.file(_imagen!),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Horas'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _minutosController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Minutos'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _dificultad,
                onChanged: (value) {
                  setState(() {
                    _dificultad = value!;
                  });
                },
                items: ['Fácil', 'Medio', 'Difícil', 'Muy difícil']
                    .map((dificultad) => DropdownMenuItem(
                          value: dificultad,
                          child: Text(dificultad),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Dificultad'),
              ),
              SizedBox(height: 20),
              Text('Ingredientes:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._ingredientes.asMap().entries.map((entry) {
                int index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value['cantidad'],
                        onChanged: (value) => _ingredientes[index]['cantidad'] = value,
                        decoration: InputDecoration(labelText: 'Cantidad ${index + 1}'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value['ingrediente'],
                        onChanged: (value) => _ingredientes[index]['ingrediente'] = value,
                        decoration: InputDecoration(labelText: 'Ingrediente ${index + 1}'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => setState(() {
                        _ingredientes.removeAt(index);
                      }),
                    ),
                  ],
                );
              }),

              ElevatedButton(
                onPressed: _addIngrediente,
                child: Text('Agregar Ingrediente'),
              ),
              SizedBox(height: 20),
              Text('Pasos:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._pasos.asMap().entries.map((entry) {
                int index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value, // pasos es List<String>, dejar asi
                        onChanged: (value) => _pasos[index] = value,
                        decoration: InputDecoration(labelText: 'Paso ${index + 1}'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => setState(() {
                        _pasos.removeAt(index);
                      }),
                    ),
                  ],
                );
              }),
              ElevatedButton(
                onPressed: _addPaso,
                child: Text('Agregar Paso'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _guardarCambios,
                    child: Text('Guardar Cambios'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
