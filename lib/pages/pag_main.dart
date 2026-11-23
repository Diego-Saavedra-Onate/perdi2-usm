import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:perdi2_usm/constants.dart';
import 'package:perdi2_usm/services/auth_service.dart';

class PagMain extends StatefulWidget {
  const PagMain({super.key});

  @override
  State<PagMain> createState() => _PagMainState();
}

class _PagMainState extends State<PagMain> {
  String mensajeError = "";
  bool hayError = false;
  bool cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kSecondaryColor, kBackgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  MdiIcons.compassOutline,
                  size: 64,
                  color: const Color(0xFFD60019),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bienvenido ingrese un correo ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD60019),
                  ),
                ),

                const SizedBox(height: 24),
                cargando
                    ? const CircularProgressIndicator(color: kPrimaryColor)
                    : SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () async {
                            setState(() {
                              hayError = false;
                              cargando = true;
                            });
                            try {
                              await AuthService().signInWithGoogle();
                            } catch (ex) {
                              if (!mounted) return;
                              setState(() {
                                hayError = true;
                                mensajeError =
                                    "No se pudo iniciar sesión con Google";
                              });
                            } finally {
                              if (mounted) {
                                setState(() => cargando = false);
                              }
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD60019),
                          ),
                          icon: Icon(MdiIcons.google, color: Colors.white),
                          label: const Text(
                            'Continuar con Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                hayError
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(MdiIcons.alert, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mensajeError,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
