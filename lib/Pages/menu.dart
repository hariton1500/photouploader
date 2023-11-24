import 'package:flutter/material.dart';
import 'package:photouploader/Pages/create_ip.dart';
import 'package:photouploader/Pages/groups.dart';

class NormalModePage extends StatefulWidget {
  const NormalModePage({super.key});

  @override
  State<NormalModePage> createState() => _NormalModePageState();
}

class _NormalModePageState extends State<NormalModePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      print('app inactive, is lock screen:'); // ${await isLockScreen()}');
    } else if (state == AppLifecycleState.resumed) {
      print('app resumed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Главное меню'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CreatePage2()));
              },
              icon: const Icon(Icons.group_add),
              label: const Text('Создание группы фотографий')),
          TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const GroupsPage()));
              },
              icon: const Icon(Icons.upload),
              label: const Text('Операции с группами фотографий')),
          /*
          TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Настройки работы GPS')),*/
        ],
      ),
    );
  }
}
