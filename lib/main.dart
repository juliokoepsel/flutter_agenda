import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
//loading animatons from: https://pub.dev/packages/loading_animation_widget
import 'package:flutter_native_splash/flutter_native_splash.dart';

late SharedPreferences prefs;
late ValueNotifier<ThemeMode> _notifier;

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  prefs = await SharedPreferences.getInstance();
  final bool? dark = prefs.getBool('dark');
  _notifier = ValueNotifier(ThemeMode.light);
  if (dark == true) {
    _notifier = ValueNotifier(ThemeMode.dark);
  }

  /*
  runApp(MaterialApp(
    title: "Agenda",
    initialRoute: '/',
    routes: {
      '/': (context) => const Agenda(),
      '/novo': (context) => const Novo(),
      '/recentes': (context) => const Recentes(),
    },
    //theme: appTheme,
  ));
  */

  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _notifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: "Agenda",
          initialRoute: '/',
          routes: {
            '/': (context) => const Agenda(),
            '/novo': (context) => const Novo(),
            '/recentes': (context) => const Recentes(),
          },
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
        );
      },
    );
  }
}

class Contato {
  String nome, telefone, email, endereco;

  Contato(this.nome, this.telefone, this.email, this.endereco);
}

var contatos = [];
SplayTreeSet<Contato> contatosOrdenado = SplayTreeSet.from(
  contatos,
  (a, b) => a.nome.compareTo(b.nome),
);

class Agenda extends StatelessWidget {
  const Agenda({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <TableRow>[];
    rows.add(
      const TableRow(
        children: <Widget>[
          Text(
            "NOME:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "TELEFONE:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "EMAIL:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "ENDEREÇO:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "REMOVER:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    for (var contato in contatosOrdenado) {
      rows.add(TableRow(
        children: <Widget>[
          Text(
            contato.nome,
            textAlign: TextAlign.center,
          ),
          Text(
            contato.telefone,
            textAlign: TextAlign.center,
          ),
          Text(
            contato.email,
            textAlign: TextAlign.center,
          ),
          Text(
            contato.endereco,
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              contatos.removeWhere((c) =>
                  c.nome == contato.nome &&
                  c.telefone == contato.telefone &&
                  c.email == contato.email &&
                  c.endereco == contato.endereco);
              contatosOrdenado = SplayTreeSet.from(
                contatos,
                (a, b) => a.nome.compareTo(b.nome),
              );
              showAlertDialog(context);
            },
            child: const Text("X"),
          ),
        ],
      ));
    }
    // -------------------------------------------------------------------------
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Contatos'),
      ),
      body: Table(
        border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  color: Color(0xFF424242),
                  image: DecorationImage(
                      image: AssetImage("assets/icon.png"), fit: BoxFit.cover)),
              child: Text(
                'Agenda de Contatos',
                style: TextStyle(fontSize: 30),
              ),
            ),
            ListTile(
              title: const Text('Contatos'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            ListTile(
              title: const Text('Recentes'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/recentes');
              },
            ),
            ListTile(
              title: const Text('+ Novo Contato'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/novo');
              },
            ),
            ListTile(
              title: const Text('Mudar Tema'),
              onTap: () async {
                final bool? dark = prefs.getBool('dark');
                if (dark == true) {
                  await prefs.setBool('dark', false);
                  _notifier.value = ThemeMode.light;
                } else {
                  await prefs.setBool('dark', true);
                  _notifier.value = ThemeMode.dark;
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/novo');
        },
        tooltip: 'Adicionar Novo Contato',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final enderecoController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    enderecoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: nomeController,
            decoration: const InputDecoration(hintText: "Nome"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Não pode ser vazio';
              }
              return null;
            },
          ),
          TextFormField(
            controller: telefoneController,
            decoration: const InputDecoration(hintText: "Telefone"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Não pode ser vazio';
              }
              return null;
            },
          ),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(hintText: "Email"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Não pode ser vazio';
              }
              return null;
            },
          ),
          TextFormField(
            controller: enderecoController,
            decoration: const InputDecoration(hintText: "Endereço"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Não pode ser vazio';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contato Adicionado')),
                );

                contatos.add(Contato(
                    nomeController.text,
                    telefoneController.text,
                    emailController.text,
                    enderecoController.text));

                contatosOrdenado = SplayTreeSet.from(
                  contatos,
                  (a, b) => a.nome.compareTo(b.nome),
                );

                Navigator.popAndPushNamed(context, '/recentes');
              }
            },
            child: const Text('Adicionar'),
          ),
          LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.lightBlue, size: 200)
        ],
      ),
    );
  }
}

class Novo extends StatelessWidget {
  const Novo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Contato'),
      ),
      body: const MyCustomForm(),
    );
  }
}

class Recentes extends StatelessWidget {
  const Recentes({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <TableRow>[];
    rows.add(
      const TableRow(
        children: <Widget>[
          Text(
            "NOME:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "TELEFONE:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "EMAIL:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "ENDEREÇO:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "REMOVER:",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    for (var contato in contatos.reversed.toList()) {
      rows.add(TableRow(
        children: <Widget>[
          Text(
            contato.nome,
            textAlign: TextAlign.center,
          ),
          Text(
            contato.telefone,
            textAlign: TextAlign.center,
          ),
          Text(
            contato.email,
            textAlign: TextAlign.center,
          ),
          Text(
            contato.endereco,
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              contatos.removeWhere((c) =>
                  c.nome == contato.nome &&
                  c.telefone == contato.telefone &&
                  c.email == contato.email &&
                  c.endereco == contato.endereco);
              contatosOrdenado = SplayTreeSet.from(
                contatos,
                (a, b) => a.nome.compareTo(b.nome),
              );
              showAlertDialog(context);
            },
            child: const Text("X"),
          ),
        ],
      ));
    }
    // -------------------------------------------------------------------------
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Contatos - Recentes'),
      ),
      body: Table(
        border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  color: Color(0xFF424242),
                  image: DecorationImage(
                      image: AssetImage("assets/icon.png"), fit: BoxFit.cover)),
              child: Text(
                'Agenda de Contatos',
                style: TextStyle(fontSize: 30),
              ),
            ),
            ListTile(
              title: const Text('Contatos'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            ListTile(
              title: const Text('Recentes'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/recentes');
              },
            ),
            ListTile(
              title: const Text('+ Novo Contato'),
              onTap: () {
                Navigator.pushNamed(context, '/novo');
              },
            ),
            ListTile(
              title: const Text('Mudar Tema'),
              onTap: () async {
                final bool? dark = prefs.getBool('dark');
                if (dark == true) {
                  await prefs.setBool('dark', false);
                  _notifier.value = ThemeMode.light;
                } else {
                  await prefs.setBool('dark', true);
                  _notifier.value = ThemeMode.dark;
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/novo');
        },
        tooltip: 'Adicionar Novo Contato',
        child: const Icon(Icons.add),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  Widget okButton = TextButton(
    onPressed: () {
      Navigator.popAndPushNamed(context, '/');
    },
    child: const Text("OK"),
  );
  AlertDialog alert = AlertDialog(
    title: const Text("Aviso"),
    content: const Text("Contato removido."),
    actions: [
      okButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
