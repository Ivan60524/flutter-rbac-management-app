import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GruposPage extends StatefulWidget {
  const GruposPage({super.key});

  @override
  State<GruposPage> createState() => _GruposPageState();
}

class _GruposPageState extends State<GruposPage> {
  List<String> grupos = [
    'Grupo 1',
    'Grupo 2',
    'Grupo 3',
  ];

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

  Future<void> guardarGrupos() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(grupos);
    await prefs.setString('grupos', data);
  }

  @override
  void initState() {
    super.initState();
    cargarGrupos();
  }

  void mostrarFormularioNuevoGrupo() {
    TextEditingController grupoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Grupo'),
          content: TextField(
            controller: grupoController,
            decoration: const InputDecoration(
              labelText: 'Nombre del grupo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (grupoController.text.isNotEmpty) {
                  setState(() {
                    grupos.add(grupoController.text);
                  });

                  guardarGrupos();
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

  void editarGrupo(int index) {
    TextEditingController grupoController =
    TextEditingController(text: grupos[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Grupo'),
          content: TextField(
            controller: grupoController,
            decoration: const InputDecoration(
              labelText: 'Nombre del grupo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  grupos[index] = grupoController.text;
                });

                guardarGrupos();
                Navigator.pop(context);
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void eliminarGrupo(int index) {
    setState(() {
      grupos.removeAt(index);
    });

    guardarGrupos();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grupo eliminado'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormularioNuevoGrupo,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: grupos.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(grupos[index]),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              eliminarGrupo(index);
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
                editarGrupo(index);
              },
              leading: const Icon(Icons.groups),
              title: Text(grupos[index]),
            ),
          );
        },
      ),
    );
  }
}