import 'package:cloud_firestore/cloud_firestore.dart';

class FsService {
  // Obtener categorías ordenadas alfabéticamente para el Dropdown y filtros
  Future<QuerySnapshot> categorias() {
    return FirebaseFirestore.instance
        .collection('categorias')
        .orderBy('nombre')
        .get();
  }

  // Obtener todas las publicaciones en tiempo real (Nivel 3)
  Stream<QuerySnapshot> publicaciones() {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // Obtener solo las publicaciones del usuario conectado (Nivel 4)
  Stream<QuerySnapshot> misPublicaciones(String uid) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .where('autorUid', isEqualTo: uid)
        .snapshots();
  }

  // Agregar una nueva publicación (Nivel 2)
  Future<void> agregarPublicacion({
    required String titulo,
    required String descripcion,
    required String lugar,
    required String categoria,
    required String estado,
    required String fotoBase64,
    required String autorUid,
    required String autorNombre,
    required String autorEmail,
  }) {
    return FirebaseFirestore.instance.collection('publicaciones').doc().set({
      'titulo': titulo,
      'descripcion': descripcion,
      'lugar': lugar,
      'categoria': categoria,
      'estado': estado, // 'Perdido' o 'Encontrado'
      'motivo': 'No devuelto', // Valor inicial por defecto
      'fotoBase64': fotoBase64,
      'autorUid': autorUid,
      'autorNombre': autorNombre,
      'autorEmail': autorEmail,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  // Editar estado y motivo de una publicación propia (Nivel 4)
  Future<void> editarEstadoMotivo(String id, String estado, String motivo) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .update({'estado': estado, 'motivo': motivo});
  }

  // Borrar una publicación propia (Nivel 4)
  Future<void> borrarPublicacion(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .delete();
  }
}
