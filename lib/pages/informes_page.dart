import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InformesPage extends StatefulWidget {
  const InformesPage({super.key});

  @override
  State<InformesPage> createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, String>> informes = [];
  List<Map<String, String>> publicadores = [];
  List<Map<String, String>> asistencias = [];

  String mesSeleccionado = 'Enero 2026';

  List<String> meses = [
    'Enero 2026',
    'Febrero 2026',
    'Marzo 2026',
    'Abril 2026',
    'Mayo 2026',
    'Junio 2026',
    'Julio 2026',
    'Agosto 2026',
    'Septiembre 2026',
    'Octubre 2026',
    'Noviembre 2026',
    'Diciembre 2026',
    'Enero 2027',
  ];

  Future<void> agregarInforme(
      String nombre,
      String cursos,
      String tipo,
      String comentarios,
      String horas,
      String participacion,
      {String? docId}
      ) async {
    final datos = {
      'nombre': nombre,
      'cursos': cursos,
      'tipo': tipo,
      'comentarios': comentarios,
      'horas': horas,
      'participacion': participacion,
      'mes': mesSeleccionado,
    };

    try {
      final existentes = await firestore
          .collection('informes')
          .where('nombre', isEqualTo: nombre)
          .where('mes', isEqualTo: mesSeleccionado)
          .get();

      if (docId == null && existentes.docs.isNotEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Este publicador ya tiene un informe en este mes',
            ),
          ),
        );
        return;
      }

      if (docId != null) {
        await firestore.collection('informes').doc(docId).update(datos);
      } else {
        await firestore.collection('informes').add(datos);
      }

      await cargarInformes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar informe: $e'),
        ),
      );
    }
  }

  Future<void> cargarPublicadores() async {
    final snapshot = await firestore.collection('publicadores').get();

    setState(() {
      publicadores = snapshot.docs.map((doc) {
        return {
          'nombre': doc['nombre'].toString(),
          'grupo': doc['grupo'].toString(),
        };
      }).toList();
    });
  }

  Future<void> cargarInformes() async {
    final snapshot = await firestore.collection('informes').get();

    setState(() {
      informes = snapshot.docs.map((doc) {
        return {
          ...Map<String, String>.from(doc.data()),
          'id': doc.id,
        };
      }).toList();
    });
  }

  Future<void> cargarAsistencias() async {
    final snapshot = await firestore.collection('asistencias').get();

    setState(() {
      asistencias = snapshot.docs.map((doc) {
        return Map<String, String>.from(doc.data());
      }).toList();
    });
  }

  Future<void> guardarAsistencias(Map<String, String> datos) async {
    final existentes = await firestore
        .collection('asistencias')
        .where('mes', isEqualTo: mesSeleccionado)
        .get();

    if (existentes.docs.isNotEmpty) {
      await firestore
          .collection('asistencias')
          .doc(existentes.docs.first.id)
          .update(datos);
    } else {
      await firestore.collection('asistencias').add(datos);
    }

    await cargarAsistencias();
  }

  Future<void> exportarPDF() async {
    print('EXPORTAR PDF EJECUTADO');
    final pdf = pw.Document();

    final informesDelMes = informes
        .where((informe) => informe['mes'] == mesSeleccionado)
        .toList();

    int activosCongregacion = publicadores.length;
    int informaron = informesDelMes.length;
    int noInformaron = activosCongregacion - informaron;

    if (noInformaron < 0) noInformaron = 0;

    int totalPublicadores =
        informesDelMes.where((i) => i['tipo'] == 'Publicador').length;

    int participaron =
        informesDelMes.where((i) => i['participacion'] == 'Participó').length;

    int noParticiparon =
        informesDelMes.where((i) => i['participacion'] == 'No participó').length;

    int precursoresRegulares =
        informesDelMes.where((i) => i['tipo'] == 'Precursor regular').length;

    int precursoresAuxiliares =
        informesDelMes.where((i) => i['tipo'] == 'Precursor auxiliar').length;

    int horasPR = informesDelMes
        .where((i) => i['tipo'] == 'Precursor regular')
        .fold(0, (sum, i) => sum + int.tryParse(i['horas'] ?? '0')!);

    int horasPA = informesDelMes
        .where((i) => i['tipo'] == 'Precursor auxiliar')
        .fold(0, (sum, i) => sum + int.tryParse(i['horas'] ?? '0')!);

    int cursosTotales = informesDelMes
        .fold(0, (sum, i) => sum + int.tryParse(i['cursos'] ?? '0')!);

    final asistenciaMes = asistencias.firstWhere(
          (a) => a['mes'] == mesSeleccionado,
      orElse: () => {},
    );

    List<int> asistenciasMartes = [
      int.tryParse(asistenciaMes['martes1'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['martes2'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['martes3'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['martes4'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['martes5'] ?? '') ?? 0,
    ].where((v) => v > 0).toList();

    List<int> asistenciasSabado = [
      int.tryParse(asistenciaMes['sabado1'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['sabado2'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['sabado3'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['sabado4'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['sabado5'] ?? '') ?? 0,
    ].where((v) => v > 0).toList();

    int promedioMartes = asistenciasMartes.isNotEmpty
        ? (asistenciasMartes.reduce((a, b) => a + b) ~/ asistenciasMartes.length)
        : 0;

    int promedioSabado = asistenciasSabado.isNotEmpty
        ? (asistenciasSabado.reduce((a, b) => a + b) ~/ asistenciasSabado.length)
        : 0;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Tenantitla Congregación',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Informe mensual - $mesSeleccionado'),
          pw.SizedBox(height: 20),

          pw.Text('Resumen congregacional',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Activos congregación: $activosCongregacion'),
          pw.Text('Informaron: $informaron'),
          pw.Text('No informaron: $noInformaron'),

          pw.SizedBox(height: 20),

          pw.Text('Ministerio',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Publicadores: $totalPublicadores'),
          pw.Text('Participaron: $participaron'),
          pw.Text('No participaron: $noParticiparon'),
          pw.Text('Precursores regulares: $precursoresRegulares'),
          pw.Text('Horas PR: $horasPR'),
          pw.Text('Precursores auxiliares: $precursoresAuxiliares'),
          pw.Text('Horas PA: $horasPA'),
          pw.Text('Cursos bíblicos: $cursosTotales'),

          pw.SizedBox(height: 20),

          pw.Text('Asistencia',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Promedio martes: $promedioMartes'),
          pw.Text('Promedio sábado: $promedioSabado'),

          pw.SizedBox(height: 20),

          pw.Text('Detalle individual',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

          ...informesDelMes.map((i) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(i['nombre'] ?? '',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Tipo: ${i['tipo']}'),
                  if (i['tipo'] == 'Publicador')
                    pw.Text('Participación: ${i['participacion']}'),
                  if (i['tipo'] != 'Publicador')
                    pw.Text('Horas: ${i['horas']}'),
                  pw.Text('Cursos: ${i['cursos']}'),
                  pw.Text('Comentarios: ${i['comentarios']}'),
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  void mostrarOpcionesInforme(Map<String, String> informe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                informe['nombre'] ?? 'Informe',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Selecciona una acción',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 28),

              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                tileColor: const Color(0xFFF5F3FF),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF7C3AED),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'Editar informe',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  mostrarFormulario(informeEditar: informe);
                },
              ),

              const SizedBox(height: 14),

              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                tileColor: const Color(0xFFFFF1F2),
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'Eliminar informe',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  eliminarInforme(informe);
                },
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> eliminarInforme(Map<String, String> informe) async {
    final id = informe['id'];

    if (id != null) {
      await firestore.collection('informes').doc(id).delete();
      await cargarInformes();
    }
  }

  void mostrarFormularioAsistencia() {
    TextEditingController martes1 = TextEditingController();
    TextEditingController martes2 = TextEditingController();
    TextEditingController martes3 = TextEditingController();
    TextEditingController martes4 = TextEditingController();
    TextEditingController martes5 = TextEditingController();

    TextEditingController sabado1 = TextEditingController();
    TextEditingController sabado2 = TextEditingController();
    TextEditingController sabado3 = TextEditingController();
    TextEditingController sabado4 = TextEditingController();
    TextEditingController sabado5 = TextEditingController();

    final existente = asistencias.firstWhere(
          (a) => a['mes'] == mesSeleccionado,
      orElse: () => {},
    );

    if (existente.isNotEmpty) {
      martes1.text = existente['martes1'] ?? '';
      martes2.text = existente['martes2'] ?? '';
      martes3.text = existente['martes3'] ?? '';
      martes4.text = existente['martes4'] ?? '';
      martes5.text = existente['martes5'] ?? '';

      sabado1.text = existente['sabado1'] ?? '';
      sabado2.text = existente['sabado2'] ?? '';
      sabado3.text = existente['sabado3'] ?? '';
      sabado4.text = existente['sabado4'] ?? '';
      sabado5.text = existente['sabado5'] ?? '';
    }

    InputDecoration campo(String label) {
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );
    }

    Widget seccionTitulo(String texto, IconData icono) {
      return Row(
        children: [
          Icon(icono, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Asistencia $mesSeleccionado',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      seccionTitulo(
                        'Reunión entre semana',
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: martes1,
                        keyboardType: TextInputType.number,
                        decoration: campo('Martes 1'),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: martes2,
                        keyboardType: TextInputType.number,
                        decoration: campo('Martes 2'),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: martes3,
                        keyboardType: TextInputType.number,
                        decoration: campo('Martes 3'),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: martes4,
                        keyboardType: TextInputType.number,
                        decoration: campo('Martes 4'),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: martes5,
                        keyboardType: TextInputType.number,
                        decoration: campo('Martes 5 (opcional)'),
                      ),

                      const SizedBox(height: 28),

                      seccionTitulo(
                        'Reunión fin de semana',
                        Icons.groups,
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: sabado1,
                        keyboardType: TextInputType.number,
                        decoration: campo('Sábado 1'),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: sabado2,
                        keyboardType: TextInputType.number,
                        decoration: campo('Sábado 2'),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: sabado3,
                        keyboardType: TextInputType.number,
                        decoration: campo('Sábado 3'),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: sabado4,
                        keyboardType: TextInputType.number,
                        decoration: campo('Sábado 4'),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: sabado5,
                        keyboardType: TextInputType.number,
                        decoration: campo('Sábado 5 (opcional)'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        try {
                          final Map<String, String> datos = {
                            'mes': mesSeleccionado,
                            'martes1': martes1.text.trim(),
                            'martes2': martes2.text.trim(),
                            'martes3': martes3.text.trim(),
                            'martes4': martes4.text.trim(),
                            'martes5': martes5.text.trim(),
                            'sabado1': sabado1.text.trim(),
                            'sabado2': sabado2.text.trim(),
                            'sabado3': sabado3.text.trim(),
                            'sabado4': sabado4.text.trim(),
                            'sabado5': sabado5.text.trim(),
                          };

                          print('GUARDANDO ASISTENCIA...');
                          print(datos);

                          await guardarAsistencias(datos);

                          if (!mounted) return;

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Asistencia guardada correctamente'),
                            ),
                          );
                        } catch (e) {
                          print('ERROR ASISTENCIAS: $e');

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al guardar: $e'),
                            ),
                          );
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void mostrarFormulario({Map<String, String>? informeEditar}) {
    String? publicadorSeleccionado = informeEditar?['nombre'];
    String? tipoSeleccionado = informeEditar?['tipo'];
    String? participacionSeleccionada = informeEditar?['participacion'];

    TextEditingController cursosController =
    TextEditingController(text: informeEditar?['cursos'] ?? '');

    TextEditingController comentariosController =
    TextEditingController(text: informeEditar?['comentarios'] ?? '');

    TextEditingController horasController =
    TextEditingController(text: informeEditar?['horas'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Text(
                informeEditar == null ? 'Nuevo Informe' : 'Editar Informe',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: publicadorSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Publicador',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: publicadores.map((publicador) {
                          return DropdownMenuItem(
                            value: publicador['nombre'],
                            child: Text(publicador['nombre']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            publicadorSeleccionado = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: tipoSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Tipo de servicio',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Publicador',
                            child: Text('Publicador'),
                          ),
                          DropdownMenuItem(
                            value: 'Precursor regular',
                            child: Text('Precursor regular'),
                          ),
                          DropdownMenuItem(
                            value: 'Precursor auxiliar',
                            child: Text('Precursor auxiliar'),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            tipoSeleccionado = value;

                            if (tipoSeleccionado != 'Publicador') {
                              participacionSeleccionada = '';
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      if (tipoSeleccionado == 'Publicador')
                        DropdownButtonFormField<String>(
                          value: participacionSeleccionada,
                          decoration: InputDecoration(
                            labelText: 'Participación',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Participó',
                              child: Text('Participó'),
                            ),
                            DropdownMenuItem(
                              value: 'No participó',
                              child: Text('No participó'),
                            ),
                          ],
                          onChanged: (value) {
                            setModalState(() {
                              participacionSeleccionada = value;
                            });
                          },
                        ),

                      if (tipoSeleccionado == 'Precursor regular' ||
                          tipoSeleccionado == 'Precursor auxiliar')
                        TextField(
                          controller: horasController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Horas',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: cursosController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cursos bíblicos',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: comentariosController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Comentarios',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    if (publicadorSeleccionado != null &&
                        tipoSeleccionado != null) {
                      await agregarInforme(
                        publicadorSeleccionado!,
                        cursosController.text,
                        tipoSeleccionado!,
                        comentariosController.text,
                        horasController.text,
                        participacionSeleccionada ?? '',
                        docId: informeEditar?['id'],
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
    cargarInformes();
    cargarPublicadores();
    cargarAsistencias();
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
                    'Informes',
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
              'Resumen y reportes congregacionales',
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

  @override
  Widget build(BuildContext context) {
    final informesDelMes = informes
        .where((informe) => informe['mes'] == mesSeleccionado)
        .toList();

    int totalPublicadores =
        informesDelMes.where((i) => i['tipo'] == 'Publicador').length;

    int participaron =
        informesDelMes.where((i) => i['participacion'] == 'Participó').length;

    int noParticiparon =
        informesDelMes.where((i) => i['participacion'] == 'No participó').length;

    int precursoresRegulares =
        informesDelMes.where((i) => i['tipo'] == 'Precursor regular').length;

    int precursoresAuxiliares =
        informesDelMes.where((i) => i['tipo'] == 'Precursor auxiliar').length;

    int horasPR = informesDelMes
        .where((i) => i['tipo'] == 'Precursor regular')
        .fold(0, (sum, i) => sum + int.tryParse(i['horas'] ?? '0')!);

    int horasPA = informesDelMes
        .where((i) => i['tipo'] == 'Precursor auxiliar')
        .fold(0, (sum, i) => sum + int.tryParse(i['horas'] ?? '0')!);

    int cursosTotales = informesDelMes
        .fold(0, (sum, i) => sum + int.tryParse(i['cursos'] ?? '0')!);

    int activosCongregacion = publicadores.length;
    int informaron = informesDelMes.length;
    int noInformaron = activosCongregacion - informaron;

    if (noInformaron < 0) {
      noInformaron = 0;
    }

    final asistenciaMes = asistencias.firstWhere(
          (a) => a['mes'] == mesSeleccionado,
      orElse: () => {},
    );

    List<int> asistenciasMartes = [
      int.tryParse(asistenciaMes['martes1'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['martes2'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['martes3'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['martes4'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['martes5'] ?? '') ?? 0,
    ].where((v) => v > 0).toList();

    List<int> asistenciasSabado = [
      int.tryParse(asistenciaMes['sabado1'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['sabado2'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['sabado3'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['sabado4'] ?? '') ?? 0,
      int.tryParse(asistenciaMes['sabado5'] ?? '') ?? 0,
    ].where((v) => v > 0).toList();

    int promedioMartes = asistenciasMartes.isNotEmpty
        ? (asistenciasMartes.reduce((a, b) => a + b) ~/ asistenciasMartes.length)
        : 0;

    int promedioSabado = asistenciasSabado.isNotEmpty
        ? (asistenciasSabado.reduce((a, b) => a + b) ~/ asistenciasSabado.length)
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          encabezado(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: mesSeleccionado,
              decoration: InputDecoration(
                labelText: 'Mes del informe',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              items: meses.map((mes) {
                return DropdownMenuItem(
                  value: mes,
                  child: Text(mes),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  mesSeleccionado = value!;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: mostrarFormularioAsistencia,
                    icon: const Icon(Icons.groups),
                    label: const Text('Asistencia'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: exportarPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Resumen $mesSeleccionado',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text('🏘 Activos congregación: $activosCongregacion'),
                Text('📨 Informaron: $informaron'),
                Text('❗ No informaron: $noInformaron'),
                const SizedBox(height: 10),
                Text('👥 Publicadores: $totalPublicadores'),
                Text('✅ Participaron: $participaron'),
                Text('❌ No participaron: $noParticiparon'),
                const SizedBox(height: 10),
                Text('⭐ Precursores regulares: $precursoresRegulares'),
                Text('⏱ Horas PR: $horasPR'),
                const SizedBox(height: 10),
                Text('🌟 Precursores auxiliares: $precursoresAuxiliares'),
                Text('⏱ Horas PA: $horasPA'),
                const SizedBox(height: 10),
                Text('📘 Cursos bíblicos: $cursosTotales'),
                const SizedBox(height: 10),
                Text('🏛 Promedio martes: $promedioMartes'),
                Text('🏛 Promedio sábado: $promedioSabado'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: informesDelMes.length,
              itemBuilder: (context, index) {
                final informe = informesDelMes[index];

                String subtitulo = '';

                if (informe['tipo'] == 'Publicador') {
                  subtitulo =
                  '${informe['tipo']} • ${informe['participacion']} • Cursos: ${informe['cursos']}';
                } else {
                  subtitulo =
                  '${informe['tipo']} • Horas: ${informe['horas']} • Cursos: ${informe['cursos']}';
                }

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF7C3AED),
                      child: const Icon(
                        Icons.assignment,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      informe['nombre'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(subtitulo),
                    onTap: () {
                      mostrarOpcionesInforme(informe);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF7C3AED),
          onPressed: () {
            mostrarFormulario();
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
    );
  }
}