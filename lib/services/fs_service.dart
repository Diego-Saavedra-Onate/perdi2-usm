import 'package:cloud_firestore/cloud_firestore.dart';

class FsService {
  Future<QuerySnapshot> categorias() {
    return FirebaseFirestore.instance
        .collection('categorias')
        .orderBy('nombre')
        .get();
  }

  Stream<QuerySnapshot> publicaciones() {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> misPublicaciones(String uid) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .where('autorUid', isEqualTo: uid)
        .snapshots();
  }

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
      'estado': estado,
      'motivo': 'No devuelto',
      'fotoBase64': fotoBase64,
      'autorUid': autorUid,
      'autorNombre': autorNombre,
      'autorEmail': autorEmail,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editarEstadoMotivo(String id, String estado, String motivo) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .update({'estado': estado, 'motivo': motivo});
  }

  Future<void> borrarPublicacion(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .delete();
  }
}
