import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:perdi2_usm/constants.dart';

class DetallePublicacionPage extends StatelessWidget {
  const DetallePublicacionPage({super.key, required this.publicacion});

  final QueryDocumentSnapshot publicacion;

  Uint8List? _decodificarFoto(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  String _formatearFecha(Timestamp? timestamp) {
    if (timestamp == null) return 'Recién publicado';
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final data = publicacion.data() as Map<String, dynamic>;
    final String titulo = data['titulo'] ?? 'Sin título';
    final String descripcion = data['descripcion'] ?? 'Sin descripción';
    final String lugar = data['lugar'] ?? 'No especificado';
    final String categoria = data['categoria'] ?? 'General';
    final String estado = data['estado'] ?? 'Perdido';
    final String motivo = data['motivo'] ?? 'No devuelto';
    final String autorNombre = data['autorNombre'] ?? 'Usuario USM';
    final String autorEmail = data['autorEmail'] ?? 'Sin correo';
    final Timestamp? fecha = data['fecha'] as Timestamp?;
    final Uint8List? fotoBytes = _decodificarFoto(data['fotoBase64']);

    final bool esPerdido = estado == 'Perdido';
    final bool esDevuelto = motivo == 'Devuelto';

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, Color(0xFF002644)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Detalle del Reporte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotografía principal
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: fotoBytes != null
                  ? Image.memory(
                      fotoBytes,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Icon(
                        MdiIcons.imageOffOutline,
                        size: 50,
                        color: Colors.grey.shade500,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Etiquetas de Estado y Motivo
            Row(
              children: [
                Chip(
                  backgroundColor: esPerdido
                      ? Colors.red.shade100
                      : Colors.blue.shade100,
                  side: BorderSide.none,
                  label: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: esPerdido
                          ? Colors.red.shade900
                          : Colors.blue.shade900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  backgroundColor: esDevuelto
                      ? Colors.green.shade100
                      : Colors.amber.shade100,
                  side: BorderSide.none,
                  label: Text(
                    motivo.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: esDevuelto
                          ? Colors.green.shade900
                          : Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Título
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const Divider(color: kSecondaryColor, thickness: 3),
            const SizedBox(height: 8),

            // Detalles estructurados
            _filaDetalle(MdiIcons.tagOutline, 'Categoría', categoria),
            const SizedBox(height: 10),
            _filaDetalle(MdiIcons.mapMarker, 'Lugar', lugar),
            const SizedBox(height: 10),
            _filaDetalle(
              MdiIcons.clockOutline,
              'Fecha de publicación',
              _formatearFecha(fecha),
            ),
            const SizedBox(height: 16),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                descripcion,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de contacto del autor
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Publicado por',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(MdiIcons.accountCircle, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          autorNombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(MdiIcons.emailOutline, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          autorEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaDetalle(IconData icono, String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: kSecondaryColor),
        const SizedBox(width: 8),
        Text(
          '$etiqueta: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Expanded(child: Text(valor, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}
