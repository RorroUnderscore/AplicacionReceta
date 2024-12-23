import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'login_screen.dart';
import 'register_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'menu_principal.dart';
import 'favoritos_screen.dart';
import 'crear_receta.dart';
import 'mis_recetas.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetas App',
      home: LoginScreen(),
      routes: {
        '/menuPrincipal': (context) => MenuPrincipal(),
        '/favoritos': (context) => FavoritosScreen(),
        '/crearReceta': (context) => CrearReceta(),
        '/misRecetas': (context) => MisRecetasScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
