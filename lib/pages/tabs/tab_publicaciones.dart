import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:perdi2_usm/constants.dart';
import 'package:perdi2_usm/pages/detalle_publicacion_page.dart';
import 'package:perdi2_usm/services/fs_service.dart';
import 'package:perdi2_usm/widgets/card_publicacion.dart';

class TabPublicaciones extends StatelessWidget {
  const TabPublicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FsService().publicaciones(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        var docs = snapshot.data!.docs;

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
                  'No hay publicaciones registradas',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
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
    );
  }
}
