import 'dart:io';

import 'package:agenda_de_contatos_app/helper/dart/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

class ContatoPage extends StatefulWidget {
  Contact contato;

  ContatoPage({this.contato});

  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Contact _contactEditado;
  bool contatoAlterado = false;

  @override
  void initState() {
    super.initState();

    if (widget.contato == null) {
      _contactEditado = Contact();
    } else {
      _contactEditado = Contact.fromMap(widget.contato.paraMap());
      _nomeController.text = _contactEditado.nome;
      _emailController.text = _contactEditado.email;
      _telefoneController.text = _contactEditado.telefone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _exibirDialogo,
      child: Scaffold(
        appBar: buildAppBar(_contactEditado),
        floatingActionButton: buildFloatingAButton(),
        body: buildCorpo(),
      ),
    );
  }

  Future<bool> _exibirDialogo() {
    if (contatoAlterado) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: kPrimaryColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child:
                      Text("Descartar", style: TextStyle(color: kPrimaryColor)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  SingleChildScrollView buildCorpo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(25.00),
      child: Column(
        children: <Widget>[
          buildContainerImagem(),
          buildTextFieldNome(),
          buildTextFieldEmail(),
          buildTextFieldTelefone(),
        ],
      ),
    );
  }

  GestureDetector buildContainerImagem() {
    return GestureDetector(
      child: Container(
        height: 140.00,
        width: 140.00,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: _contactEditado.img != null
                  ? FileImage(File(_contactEditado.img))
                  : AssetImage("images/person.png"),
              fit: BoxFit.cover),
        ),
      ),
      onTap: () {
        ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
          if (file == null) return;
          setState(() {
            _contactEditado.img = file.path;
          });
        });
      },
    );
  }

  TextField buildTextFieldTelefone() {
    return TextField(
      controller: _telefoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: "Telefone",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      style: TextStyle(
        fontSize: 18.00,
        color: kTextColor,
      ),
      onChanged: (text) {
        contatoAlterado = true;
        _contactEditado.telefone = text;
      },
    );
  }

  TextField buildTextFieldEmail() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      style: TextStyle(
        fontSize: 18.00,
        color: kTextColor,
      ),
      onChanged: (text) {
        contatoAlterado = true;
        _contactEditado.email = text;
      },
    );
  }

  TextField buildTextFieldNome() {
    return TextField(
      focusNode: _focusNode,
      controller: _nomeController,
      decoration: InputDecoration(
        labelText: "Nome",
      ),
      style: TextStyle(
        fontSize: 18.00,
        color: kTextColor,
      ),
      onChanged: (text) {
        contatoAlterado = true;
        setState(() {
          _contactEditado.nome = text;
        });
      },
    );
  }

  AppBar buildAppBar(Contact contact) {
    return AppBar(
      title: Text(contact.nome ?? "Novo Contato"),
      centerTitle: true,
      shadowColor: kPrimaryColor,
    );
  }

  FloatingActionButton buildFloatingAButton() {
    return FloatingActionButton(
      child: Icon(Icons.save),
      backgroundColor: kPrimaryColor,
      onPressed: () {
        if (_contactEditado.nome != null && _contactEditado.nome.isNotEmpty) {
          Navigator.pop(context, _contactEditado);
        } else {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
    );
  }
}
