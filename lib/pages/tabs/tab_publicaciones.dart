import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:perdi2_usm/constants.dart';
import 'package:perdi2_usm/pages/detalle_publicacion_page.dart';
import 'package:perdi2_usm/services/fs_service.dart';
import 'package:perdi2_usm/widgets/card_publicacion.dart';

class TabPublicaciones extends StatefulWidget {
  const TabPublicaciones({super.key});

  @override
  State<TabPublicaciones> createState() => _TabPublicacionesState();
}

class _TabPublicacionesState extends State<TabPublicaciones> {
  String categoriaSeleccionada = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra superior de filtro por categoría desde Firestore
        Container(
          margin: const EdgeInsets.fromLTRB(6, 6, 6, 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: FutureBuilder<QuerySnapshot>(
            future: FsService().categorias(),
            builder: (context, snapshot) {
              List<DropdownMenuItem<String>> opciones = [
                const DropdownMenuItem(
                  value: 'Todas',
                  child: Text('Todas las categorías'),
                ),
              ];

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final nombre = doc['nombre'].toString();
                  opciones.add(
                    DropdownMenuItem(value: nombre, child: Text(nombre)),
                  );
                }
              }

              return DropdownButtonFormField<String>(
                initialValue: categoriaSeleccionada,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    MdiIcons.filterVariant,
                    color: kPrimaryColor,
                  ),
                  labelText: 'Filtrar por categoría',
                  border: InputBorder.none,
                ),
                items: opciones,
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() => categoriaSeleccionada = valor);
                  }
                },
              );
            },
          ),
        ),

        // Listado en tiempo real de publicaciones
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FsService().publicaciones(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              }

              var docs = snapshot.data!.docs;

              // Aplicar filtro si no está en 'Todas'
              if (categoriaSeleccionada != 'Todas') {
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['categoria'] == categoriaSeleccionada;
                }).toList();
              }

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.textBoxSearchOutline,
                        size: 56,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No hay publicaciones en esta categoría',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var pub = docs[index];
                  return CardPublicacion(
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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
