import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GruposPage extends StatefulWidget {
  const GruposPage({super.key});

  @override
  State<GruposPage> createState() => _GruposPageState();
}

class _GruposPageState extends State<GruposPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool esSecretario = false;

  @override
  void initState() {
    super.initState();
    verificarUsuario();
    crearGruposIniciales();
  }

  Future<void> verificarUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email == 'ivan.suarez@tenantitla.app') {
      setState(() {
        esSecretario = true;
      });
    }
  }

  Future<void> crearGruposIniciales() async {
    final snapshot = await firestore.collection('grupos').get();

    if (snapshot.docs.isEmpty) {
      await firestore.collection('grupos').add({'nombre': 'Grupo 1'});
      await firestore.collection('grupos').add({'nombre': 'Grupo 2'});
      await firestore.collection('grupos').add({'nombre': 'Grupo 3'});
    }
  }

  Color colorGrupo(String grupo) {
    return const Color(0xFF7C3AED);
  }

  void mostrarFormularioNuevoGrupo() {
    TextEditingController grupoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Nuevo Grupo'),
          content: TextField(
            controller: grupoController,
            decoration: InputDecoration(
              labelText: 'Nombre del grupo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
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
                if (grupoController.text.isNotEmpty) {
                  await firestore.collection('grupos').add({
                    'nombre': grupoController.text,
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

  void editarGrupo(String docId, String nombreActual) {
    if (!esSecretario) return;

    TextEditingController grupoController =
    TextEditingController(text: nombreActual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Editar Grupo'),
          content: TextField(
            controller: grupoController,
            decoration: InputDecoration(
              labelText: 'Nombre del grupo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
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
                await firestore.collection('grupos').doc(docId).update({
                  'nombre': grupoController.text,
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

  void eliminarGrupo(String docId) async {
    if (!esSecretario) return;

    await firestore.collection('grupos').doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grupo eliminado'),
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
                    'Grupos',
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
              'Administración de grupos',
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

  Widget cardGrupo(String id, String nombre) {
    final color = colorGrupo(nombre);

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
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
      onDismissed: (_) => eliminarGrupo(id),
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
          editarGrupo(id, nombre);
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
        onPressed: mostrarFormularioNuevoGrupo,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: Column(
        children: [
          encabezado(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('grupos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay grupos registrados',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final grupos = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 90),
                  itemCount: grupos.length,
                  itemBuilder: (context, index) {
                    final grupo = grupos[index];

                    return cardGrupo(
                      grupo.id,
                      grupo['nombre'],
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