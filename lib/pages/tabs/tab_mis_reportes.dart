import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:perdi2_usm/constants.dart';
import 'package:perdi2_usm/pages/detalle_publicacion_page.dart';
import 'package:perdi2_usm/services/auth_service.dart';
import 'package:perdi2_usm/services/fs_service.dart';
import 'package:perdi2_usm/widgets/card_publicacion.dart';

class TabMisReportes extends StatefulWidget {
  const TabMisReportes({super.key});

  @override
  State<TabMisReportes> createState() => _TabMisReportesState();
}

class _TabMisReportesState extends State<TabMisReportes> {
  User? user;
  bool guardando = false;
  bool borrando = false;

  @override
  void initState() {
    super.initState();
    AuthService().currentUser().then((currentU) {
      if (!mounted) return;
      setState(() {
        user = currentU;
      });
    });
  }

  void _mostrarDialogoEditar(QueryDocumentSnapshot pub) {
    final data = pub.data() as Map<String, dynamic>;
    String estadoSeleccionado = data['estado'] ?? 'Perdido';
    String motivoSeleccionado = data['motivo'] ?? 'No devuelto';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (editDialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Actualizar Estado del Reporte',
              style: TextStyle(
                fontSize: 17,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['titulo'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: estadoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Estado (Perdido / Encontrado)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Perdido', child: Text('Perdido')),
                    DropdownMenuItem(
                      value: 'Encontrado',
                      child: Text('Encontrado'),
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor != null) {
                      setDialogState(() => estadoSeleccionado = valor);
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: motivoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Motivo (Devuelto / No devuelto)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'No devuelto',
                      child: Text('No devuelto'),
                    ),
                    DropdownMenuItem(
                      value: 'Devuelto',
                      child: Text('Devuelto'),
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor != null) {
                      setDialogState(() => motivoSeleccionado = valor);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(editDialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  if (guardando) return;
                  guardando = true;

                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    await FsService().editarEstadoMotivo(
                      pub.id,
                      estadoSeleccionado,
                      motivoSeleccionado,
                    );

                    if (!mounted || !editDialogContext.mounted) return;

                    Navigator.pop(editDialogContext);
                    messenger.showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 2),
                        backgroundColor: kSecondaryColor,
                        content: Text('Publicación actualizada correctamente'),
                      ),
                    );
                  } finally {
                    guardando = false;
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: kPrimaryColor),
                child: const Text('Guardar cambios'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarBorrado(QueryDocumentSnapshot pub) {
    final data = pub.data() as Map<String, dynamic>;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (alertDialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Borrar Publicación',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text('¿Confirma borrar el reporte "${data['titulo'] ?? ''}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertDialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (borrando) return;
              borrando = true;

              final messenger = ScaffoldMessenger.of(context);

              try {
                await FsService().borrarPublicacion(pub.id);

                if (!mounted || !alertDialogContext.mounted) return;

                Navigator.pop(alertDialogContext);
                messenger.showSnackBar(
                  const SnackBar(
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    content: Text('Publicación eliminada'),
                  ),
                );
              } finally {
                borrando = false;
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimaryColor),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FsService().misPublicaciones(user!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        var misDocs = snapshot.data!.docs;

        if (misDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.folderOpenOutline,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aún no has creado publicaciones.\nVe a la pestaña "Publicar" para crear tu primer reporte.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: misDocs.length,
          itemBuilder: (context, index) {
            var pub = misDocs[index];

            return Slidable(
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _mostrarDialogoEditar(pub),
                    icon: MdiIcons.pen,
                    label: 'Editar',
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _confirmarBorrado(pub),
                    icon: MdiIcons.trashCan,
                    label: 'Borrar',
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
              child: CardPublicacion(
                publicacion: pub,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetallePublicacionPage(publicacion: pub),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
