import 'dart:io';

import 'package:agenda_de_contatos_app/helper/dart/contact_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import 'contato_page.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contatos = List();
  ContactHelper Helper = ContactHelper();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      floatingActionButton: buildFloatingAButton(),
      body: buildBuildListView(),
    );
  }

  ListView buildBuildListView() {
    return ListView.builder(
        padding: EdgeInsets.all(kDefaultPadding),
        itemCount: contatos.length,
        // ignore: missing_return
        itemBuilder: (context, index) {
          return _contatsCard(context, index);
        });
  }

  void _showContatoPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContatoPage(
                  contato: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await Helper.updateContact(recContact);
      } else {
        await Helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  Widget buildFloatingAButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: kPrimaryColor,
      onPressed: () {
        _showContatoPage();
      },
    );
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text("Agenda de Contatos"),
      centerTitle: true,
      shadowColor: kPrimaryColor,
      actions: <Widget>[
        PopupMenuButton<OrderOptions>(
          itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordenar de A-Z"),
              value: OrderOptions.orderaz,
            ),
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordenar de Z-A"),
              value: OrderOptions.orderza,
            ),
          ],
          onSelected: _orderList,
        )
      ],
    );
  }

  GestureDetector _contatsCard(BuildContext context, int index) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Card(
          child: Row(
            children: <Widget>[buildContainerFoto(index), buildPadding(index)],
          ),
        ),
      ),
      onTap: () {
        _exibirOpcoes(context, index);
      },
    );
  }

  _exibirOpcoes(context, index) {
    showModalBottomSheet(
        context: context,
        // ignore: missing_return
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: FlatButton(
                        child: Text(
                          "Ligar",
                          style:
                              TextStyle(color: kPrimaryColor, fontSize: 20.0),
                        ),
                        onPressed: () {
                          if (contatos[index].telefone != null) {
                            launch("tel:${contatos[index].telefone}");
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: FlatButton(
                        child: Text(
                          "Editar",
                          style:
                              TextStyle(color: kPrimaryColor, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContatoPage(contact: contatos[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: FlatButton(
                        child: Text(
                          "Excluir",
                          style:
                              TextStyle(color: kPrimaryColor, fontSize: 20.0),
                        ),
                        onPressed: () {
                          _exibirDialogoExcluir(context, index);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Future<bool> _exibirDialogoExcluir(context, index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Excluir contato"),
            content: Text("Deseja realemtne excluir esse contato?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar", style: TextStyle(color: kPrimaryColor)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Excluir", style: TextStyle(color: kPrimaryColor)),
                onPressed: () {
                  Helper.deleteContact(contatos[index].id);
                  setState(() {
                    contatos.removeAt(index);
                    Navigator.pop(context);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
    return Future.value(false);
  }

  Padding buildPadding(int index) {
    return Padding(
      padding: EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            contatos[index].nome ?? "",
            style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.bold),
          ),
          Text(
            contatos[index].email ?? "",
            style: TextStyle(
              fontSize: 16.00,
            ),
          ),
          Text(
            contatos[index].telefone ?? "",
            style: TextStyle(
              fontSize: 16.00,
            ),
          ),
        ],
      ),
    );
  }

  Container buildContainerFoto(int index) {
    return Container(
      height: 80.00,
      width: 80.00,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: contatos[index].img != null
              ? FileImage(File(contatos[index].img))
              : AssetImage("images/person.png"),
            fit: BoxFit.cover
        ),
      ),
    );
  }

  void _getAllContacts() {
    Helper.getAllContacts().then((list) {
      setState(() {
        contatos = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contatos.sort((a, b) {
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contatos.sort((a, b) {
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
