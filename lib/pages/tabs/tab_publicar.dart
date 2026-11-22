import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perdi2_usm/constants.dart';
import 'package:perdi2_usm/services/auth_service.dart';
import 'package:perdi2_usm/services/fs_service.dart';

class TabPublicar extends StatefulWidget {
  const TabPublicar({super.key});

  @override
  State<TabPublicar> createState() => _TabPublicarState();
}

class _TabPublicarState extends State<TabPublicar> {
  final formKey = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();

  String estadoSeleccionado = 'Perdido';
  String? categoriaSeleccionada;
  String? fotoBase64;
  Uint8List? fotoBytes;
  bool guardando = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    tituloCtrl.dispose();
    descripcionCtrl.dispose();
    lugarCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto(ImageSource fuente) async {
    final XFile? imagen = await _picker.pickImage(
      source: fuente,
      maxWidth: 800,
      imageQuality: 60,
    );

    if (imagen == null) return;

    final Uint8List bytes = await imagen.readAsBytes();
    if (!mounted) return;

    setState(() {
      fotoBytes = bytes;
      fotoBase64 = base64Encode(bytes);
    });
  }

  void _limpiarFormulario() {
    formKey.currentState?.reset();
    tituloCtrl.clear();
    descripcionCtrl.clear();
    lugarCtrl.clear();
    setState(() {
      estadoSeleccionado = 'Perdido';
      categoriaSeleccionada = null;
      fotoBase64 = null;
      fotoBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            const Text(
              'Nueva Publicación',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: estadoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de reporte',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Perdido',
                  child: Text('Objeto Perdido'),
                ),
                DropdownMenuItem(
                  value: 'Encontrado',
                  child: Text('Objeto Encontrado'),
                ),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => estadoSeleccionado = valor);
                }
              },
            ),
            const SizedBox(height: 12),

            // Título
            TextFormField(
              controller: tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Audífonos JBL negros',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'El título es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Descripción
            TextFormField(
              controller: descripcionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Detalles, color, marca o cómo contactarte',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'La descripción es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: lugarCtrl,
              decoration: const InputDecoration(
                labelText: 'Lugar (campus / sala / sector)',
                hintText: 'Ej: Biblioteca Sede Viña del Mar, piso 2',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'El lugar es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            FutureBuilder(
              future: FsService().categorias(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Cargando categorías...'),
                  );
                }

                var datos = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  initialValue: categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  validator: (categoria) {
                    if (categoria == null) {
                      return 'Seleccione una categoría';
                    }
                    return null;
                  },
                  items: datos.map((dato) {
                    return DropdownMenuItem<String>(
                      value: dato['nombre'].toString(),
                      child: Text(dato['nombre'].toString()),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() => categoriaSeleccionada = valor);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Fotografía del objeto',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarFoto(ImageSource.camera),
                    icon: Icon(MdiIcons.camera, color: kPrimaryColor),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarFoto(ImageSource.gallery),
                    icon: Icon(MdiIcons.imageMultiple, color: kPrimaryColor),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (fotoBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  fotoBytes!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.cameraOffOutline,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sin foto seleccionada',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Botón Publicar
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  if (fotoBase64 == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Debe tomar o seleccionar una foto'),
                      ),
                    );
                    return;
                  }

                  if (guardando) return;
                  setState(() => guardando = true);

                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    User? user = await AuthService().currentUser();
                    if (user == null) return;

                    await FsService().agregarPublicacion(
                      titulo: tituloCtrl.text.trim(),
                      descripcion: descripcionCtrl.text.trim(),
                      lugar: lugarCtrl.text.trim(),
                      categoria: categoriaSeleccionada!,
                      estado: estadoSeleccionado,
                      fotoBase64: fotoBase64!,
                      autorUid: user.uid,
                      autorNombre: user.displayName ?? 'Usuario USM',
                      autorEmail: user.email ?? '',
                    );

                    if (!mounted) return;

                    _limpiarFormulario();
                    messenger.showSnackBar(
                      const SnackBar(
                        backgroundColor: kSecondaryColor,
                        content: Text('Publicación creada exitosamente'),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Error al guardar la publicación'),
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() => guardando = false);
                    }
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: kPrimaryColor),
                icon: guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(MdiIcons.send, color: Colors.white),
                label: Text(
                  guardando ? 'Publicando...' : 'Crear Publicación',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
