import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:perdi2_usm/constants.dart';

class CardPublicacion extends StatelessWidget {
  const CardPublicacion({
    super.key,
    required this.publicacion,
    required this.onTap,
  });

  final QueryDocumentSnapshot publicacion;
  final VoidCallback onTap;

  Uint8List? _decodificarFoto(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = publicacion.data() as Map<String, dynamic>;
    final String titulo = data['titulo'] ?? 'Sin título';
    final String lugar = data['lugar'] ?? 'Sin ubicación';
    final String categoria = data['categoria'] ?? 'General';
    final String estado = data['estado'] ?? 'Perdido';
    final String motivo = data['motivo'] ?? 'No devuelto';
    final Uint8List? fotoBytes = _decodificarFoto(data['fotoBase64']);

    final bool esPerdido = estado == 'Perdido';
    final bool esDevuelto = motivo == 'Devuelto';

    return Card(
      color: kCardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: fotoBytes != null
                    ? Image.memory(
                        fotoBytes,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 75,
                        height: 75,
                        color: Colors.grey.shade200,
                        child: Icon(
                          MdiIcons.imageOffOutline,
                          color: Colors.grey.shade500,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges de Estado y Motivo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: esPerdido
                                ? Colors.red.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            estado,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: esPerdido
                                  ? Colors.red.shade800
                                  : Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: esDevuelto
                                ? Colors.green.shade100
                                : Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            motivo,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: esDevuelto
                                  ? Colors.green.shade800
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          MdiIcons.mapMarker,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lugar,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Categoría: $categoria',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
