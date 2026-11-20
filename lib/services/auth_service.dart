import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static bool _inicializado = false;

  Future<void> _asegurarInicializacion() async {
    if (!_inicializado) {
      await GoogleSignIn.instance.initialize();
      _inicializado = true;
    }
  }

  Future<User?> currentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<UserCredential?> signInWithGoogle() async {
    await _asegurarInicializacion();

    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      // Si el usuario cierra la ventana de selección de cuenta, no lo tratamos como error
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _asegurarInicializacion();
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
