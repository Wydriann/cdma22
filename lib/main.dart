import 'package:flutter/material.dart';

import 'client_model.dart';
import 'database.dart';

void main() => runApp(
      MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static List<Cliente> testClients = [];
  int _id = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CDMA22 - Clientes"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              DBProvider.db.deleteAll();
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<List<Cliente>>(
        future: DBProvider.db.getAllClientes(),
        builder: (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Cliente item = snapshot.data[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.green),
                  onDismissed: (direction) {
                    DBProvider.db.deleteCliente(item.id);
                  },
                  child: ListTile(
                    title: Text(item.nome + " " + item.sobrenome),
                    leading: Text(item.id.toString()),
                    trailing: Checkbox(
                      onChanged: (bool value) {
                        DBProvider.db.blockOrUnblock(item);
                        setState(() {});
                      },
                      value: item.marcado,
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          _addCustomer(context);
          setState(() {});
        },
      ),
    );
  }

  void _addCustomer(BuildContext context) {
    String _firstName;
    String _lastName;
    Cliente _customer;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Novo Cliente"),
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  _customer = Cliente(
                    id: ++_id,
                    nome: _firstName,
                    sobrenome: _lastName,
                    marcado: false,
                  );
                  await DBProvider.db.newCliente(_customer);
                  Navigator.of(context).pop();
                  setState(() => testClients.add(_customer));
                },
                child: Text("Incluir"),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancelar"),
              )
            ],
            content: Column(
              children: <Widget>[
                TextField(
                  // Espaço para digitar com titulo e exemplo
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Nome",
                    hintText: "Digite seu primeiro nome",
                  ),
                  onChanged: (value) {
                    _firstName = value;
                  },
                ),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Sobrenome",
                    hintText: "Digite seu sobrenome",
                  ),
                  onChanged: (value) {
                    _lastName = value;
                  },
                ),
              ],
            ),
          );
        });
  }
}
