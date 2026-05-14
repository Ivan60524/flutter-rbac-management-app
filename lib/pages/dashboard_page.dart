import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'publicadores_page.dart';
import 'grupos_page.dart';
import 'informes_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String nombre = '';
  String rol = '';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          cargando = false;
        });
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: user.email)
          .get();

      if (query.docs.isNotEmpty) {
        final Map<String, dynamic> datos = query.docs.first.data();

        setState(() {
          nombre = datos['nombre'] ?? '';
          rol = datos['rol'] ?? '';
          cargando = false;
        });
      } else {
        setState(() {
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  Widget tarjetaModulo(
      String titulo,
      IconData icono,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: SizedBox(
          width: 140,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                size: 40,
                color: Colors.blue,
              ),
              const SizedBox(height: 10),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido $nombre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            tarjetaModulo(
              'Publicadores',
              Icons.people,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublicadoresPage(),
                  ),
                );
              },
            ),
            if (rol == 'secretario' || rol == 'coordinador')
              tarjetaModulo(
                'Grupos',
                Icons.groups,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GruposPage(),
                    ),
                  );
                },
              ),
            tarjetaModulo(
              'Informes',
              Icons.bar_chart,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InformesPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}