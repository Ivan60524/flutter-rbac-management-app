import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PublicadoresPage extends StatefulWidget {
  const PublicadoresPage({super.key});

  @override
  State<PublicadoresPage> createState() => _PublicadoresPageState();
}

class _PublicadoresPageState extends State<PublicadoresPage> {
  List<Map<String, String>> publicadores = [
    {'nombre': 'Juan Pérez', 'grupo': 'Grupo 1'},
    {'nombre': 'María López', 'grupo': 'Grupo 2'},
    {'nombre': 'Carlos Hernández', 'grupo': 'Grupo 3'},
  ];

  List<String> grupos = [];

  Future<void> cargarPublicadores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('publicadores');

    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);

      setState(() {
        publicadores = decoded
            .map((item) => Map<String, String>.from(item))
            .toList();
      });
    }
  }

  Future<void> cargarGrupos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('grupos');

    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);

      setState(() {
        grupos = decoded.map((item) => item.toString()).toList();
      });
    }
  }

  Future<void> guardarPublicadores() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(publicadores);
    await prefs.setString('publicadores', data);
  }

  @override
  void initState() {
    super.initState();
    cargarPublicadores();
    cargarGrupos();
  }

  void agregarPublicador(String nombre, String grupo) {
    setState(() {
      publicadores.add({
        'nombre': nombre,
        'grupo': grupo,
      });
    });

    guardarPublicadores();
  }

  void mostrarFormulario() {
    TextEditingController nombreController = TextEditingController();
    String? grupoSeleccionado;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Publicador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
              ),
              DropdownButtonFormField<String>(
                value: grupoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Grupo',
                ),
                items: grupos.map((grupo) {
                  return DropdownMenuItem(
                    value: grupo,
                    child: Text(grupo),
                  );
                }).toList(),
                onChanged: (value) {
                  grupoSeleccionado = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty &&
                    grupoSeleccionado != null) {
                  agregarPublicador(
                    nombreController.text,
                    grupoSeleccionado!,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void editarPublicador(int index) {
    TextEditingController nombreController =
    TextEditingController(text: publicadores[index]['nombre']);

    TextEditingController grupoController =
    TextEditingController(text: publicadores[index]['grupo']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Publicador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
              ),
              TextField(
                controller: grupoController,
                decoration: const InputDecoration(
                  labelText: 'Grupo',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  publicadores[index] = {
                    'nombre': nombreController.text,
                    'grupo': grupoController.text,
                  };
                });

                guardarPublicadores();
                Navigator.pop(context);
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicadores'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormulario,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: publicadores.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(publicadores[index]['nombre']!),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                publicadores.removeAt(index);
              });

              guardarPublicadores();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Publicador eliminado'),
                ),
              );
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              onTap: () {
                editarPublicador(index);
              },
              leading: const Icon(Icons.person),
              title: Text(publicadores[index]['nombre']!),
              subtitle: Text(publicadores[index]['grupo']!),
            ),
          );
        },
      ),
    );
  }
}