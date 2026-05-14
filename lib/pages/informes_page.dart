import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InformesPage extends StatefulWidget {
  const InformesPage({super.key});

  @override
  State<InformesPage> createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> {
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

  Future<void> cargarInformes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('informes');

    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);

      setState(() {
        informes = decoded
            .map((item) => Map<String, String>.from(item))
            .toList();
      });
    }
  }

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

  Future<void> guardarInformes() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(informes);
    await prefs.setString('informes', data);
  }

  void agregarInforme(
      String nombre,
      String cursos,
      String tipo,
      String comentarios,
      String horas,
      String participacion,
      ) {
    informes.removeWhere(
          (informe) =>
      informe['nombre'] == nombre &&
          informe['mes'] == mesSeleccionado,
    );

    setState(() {
      informes.add({
        'nombre': nombre,
        'cursos': cursos,
        'tipo': tipo,
        'comentarios': comentarios,
        'horas': horas,
        'participacion': participacion,
        'mes': mesSeleccionado,
      });
    });

    guardarInformes();
  }

  Future<void> cargarAsistencias() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('asistencias');

    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);

      setState(() {
        asistencias = decoded
            .map((item) => Map<String, String>.from(item))
            .toList();
      });
    }
  }

  Future<void> guardarAsistencias() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(asistencias);
    await prefs.setString('asistencias', data);
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opciones'),
          content: const Text('¿Qué deseas hacer con este informe?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                mostrarFormulario(informeEditar: informe);
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                eliminarInforme(informe);
              },
              child: const Text('Eliminar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void eliminarInforme(Map<String, String> informe) {
    setState(() {
      informes.remove(informe);
    });

    guardarInformes();
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Asistencia $mesSeleccionado'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Reunión entre semana (Martes)'),

                TextField(
                  controller: martes1,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Martes 1'),
                ),
                TextField(
                  controller: martes2,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Martes 2'),
                ),
                TextField(
                  controller: martes3,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Martes 3'),
                ),
                TextField(
                  controller: martes4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Martes 4'),
                ),
                TextField(
                  controller: martes5,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Martes 5 (opcional)'),
                ),

                const SizedBox(height: 20),
                const Text('Reunión fin de semana (Sábado)'),

                TextField(
                  controller: sabado1,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sábado 1'),
                ),
                TextField(
                  controller: sabado2,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sábado 2'),
                ),
                TextField(
                  controller: sabado3,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sábado 3'),
                ),
                TextField(
                  controller: sabado4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sábado 4'),
                ),
                TextField(
                  controller: sabado5,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sábado 5 (opcional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                asistencias.removeWhere((a) => a['mes'] == mesSeleccionado);

                setState(() {
                  asistencias.add({
                    'mes': mesSeleccionado,

                    'martes1': martes1.text,
                    'martes2': martes2.text,
                    'martes3': martes3.text,
                    'martes4': martes4.text,
                    'martes5': martes5.text,

                    'sabado1': sabado1.text,
                    'sabado2': sabado2.text,
                    'sabado3': sabado3.text,
                    'sabado4': sabado4.text,
                    'sabado5': sabado5.text,
                  });
                });

                guardarAsistencias();
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
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
              title: Text(
                informeEditar == null ? 'Nuevo Informe' : 'Editar Informe',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: publicadorSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Publicador',
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
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tipoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de servicio',
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
                    const SizedBox(height: 10),
                    if (tipoSeleccionado == 'Publicador')
                      DropdownButtonFormField<String>(
                        value: participacionSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Participación',
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
                        decoration: const InputDecoration(
                          labelText: 'Horas',
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cursosController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cursos bíblicos',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: comentariosController,
                      decoration: const InputDecoration(
                        labelText: 'Comentarios',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (publicadorSeleccionado != null &&
                        tipoSeleccionado != null) {
                      agregarInforme(
                        publicadorSeleccionado!,
                        cursosController.text,
                        tipoSeleccionado!,
                        comentariosController.text,
                        horasController.text,
                        participacionSeleccionada ?? '',
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
      appBar: AppBar(
        title: const Text('Informes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: mesSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Mes del informe',
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: mostrarFormularioAsistencia,
                    icon: const Icon(Icons.groups),
                    label: const Text('Asistencia'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: exportarPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exportar PDF'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Resumen $mesSeleccionado',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
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
          ),
          Expanded(
            child: ListView.builder(
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

                return ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(informe['nombre'] ?? ''),
                  subtitle: Text(subtitulo),
                  onTap: () {
                    mostrarOpcionesInforme(informe);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mostrarFormulario();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}