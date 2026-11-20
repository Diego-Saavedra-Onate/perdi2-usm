import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:perdi2_usm/constants.dart';
import 'package:perdi2_usm/pages/tabs/tab_publicar.dart';
import 'package:perdi2_usm/services/auth_service.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  User? user;

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, Color(0xFF002644)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: kSecondaryColor,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Icon(MdiIcons.account, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            user?.displayName ?? user?.email ?? 'Cargando usuario...',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton(
              onSelected: (valueSeleccionado) async {
                if (valueSeleccionado == 'logout') {
                  await AuthService().signOut();
                }
              },
              icon: Icon(MdiIcons.logout, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(MdiIcons.logout, color: kPrimaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            indicatorColor: kSecondaryColor,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(MdiIcons.accountEdit), text: 'Mis reportes'),
              Tab(icon: Icon(MdiIcons.viewList), text: 'Publicaciones'),
              Tab(icon: Icon(MdiIcons.plusBox), text: 'Publicar'),
            ],
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(5.0),
          child: TabBarView(
            children: [
              Center(child: Text('Nivel 4: Mis reportes')),
              Center(child: Text('Nivel 3: Todas las publicaciones')),
              TabPublicar(),
            ],
          ),
        ),
      ),
    );
  }
}
