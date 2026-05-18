import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicadoresPage extends StatefulWidget {
  const PublicadoresPage({super.key});

  @override
  State<PublicadoresPage> createState() => _PublicadoresPageState();
}

class _PublicadoresPageState extends State<PublicadoresPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool esSecretario = false;
  List<String> grupos = [];

  @override
  void initState() {
    super.initState();
    verificarUsuario();
    cargarGrupos();
  }

  Future<void> verificarUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email == 'ivan.suarez@tenantitla.app') {
      setState(() {
        esSecretario = true;
      });
    }
  }

  Future<void> cargarGrupos() async {
    final snapshot = await firestore.collection('grupos').get();

    setState(() {
      grupos = snapshot.docs
          .map((doc) => doc['nombre'].toString())
          .toList();
    });
  }

  Color colorGrupo(String grupo) {
    final colores = [
      const Color(0xFF2563EB),
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFF59E0B),
    ];

    return colores[grupo.hashCode % colores.length];
  }

  void mostrarFormulario() {
    TextEditingController nombreController = TextEditingController();
    String? grupoSeleccionado;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Nuevo Publicador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: grupoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Grupo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nombreController.text.isNotEmpty &&
                    grupoSeleccionado != null) {
                  await firestore.collection('publicadores').add({
                    'nombre': nombreController.text,
                    'grupo': grupoSeleccionado,
                    'fechaCreacion': FieldValue.serverTimestamp(),
                  });

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

  void editarPublicador(
      String docId,
      String nombreActual,
      String grupoActual,
      ) {
    if (!esSecretario) return;

    TextEditingController nombreController =
    TextEditingController(text: nombreActual);

    String grupoSeleccionado = grupoActual;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Editar Publicador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: grupoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Grupo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: grupos.map((grupo) {
                  return DropdownMenuItem(
                    value: grupo,
                    child: Text(grupo),
                  );
                }).toList(),
                onChanged: (value) {
                  grupoSeleccionado = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await firestore.collection('publicadores').doc(docId).update({
                  'nombre': nombreController.text,
                  'grupo': grupoSeleccionado,
                });

                Navigator.pop(context);
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void eliminarPublicador(String docId) async {
    if (!esSecretario) return;

    await firestore.collection('publicadores').doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Publicador eliminado'),
      ),
    );
  }

  Widget encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF7C3AED),
            Color(0xFF6366F1),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Publicadores',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Administración de publicadores',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardPublicador(String id, String nombre, String grupo) {
    final color = colorGrupo(grupo);

    Widget contenido = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Text(
              nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    grupo,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (esSecretario)
            const Icon(
              Icons.edit_rounded,
              color: Colors.grey,
            ),
        ],
      ),
    );

    if (!esSecretario) return contenido;

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => eliminarPublicador(id),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.only(right: 28),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          editarPublicador(id, nombre, grupo);
        },
        child: contenido,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: esSecretario
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF7C3AED),
        onPressed: mostrarFormulario,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: Column(
        children: [
          encabezado(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('publicadores').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay publicadores registrados',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final publicadores = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 90),
                  itemCount: publicadores.length,
                  itemBuilder: (context, index) {
                    final publicador = publicadores[index];

                    return cardPublicador(
                      publicador.id,
                      publicador['nombre'],
                      publicador['grupo'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}