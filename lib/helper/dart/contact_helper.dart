import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idCampo = "idCampo";
final String nomeCampo = "nomeCampo";
final String emailCampo = "emailCampo";
final String telefoneCampo = "telefoneCampo";
final String imgCampo = "imgCampo";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  //Minha base de dados!
  Database _db;

  //Retorna a base de dados
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }



  // Cria o banco de dados em um futuro próximo!
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsnew.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idCampo INTEGER PRIMARY KEY, $nomeCampo TEXT, $emailCampo TEXT,"
          "$telefoneCampo TEXT, $imgCampo TEXT)");
    });
  }

  //Salva um contato no banco de dados
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.paraMap());
    return contact;
  }

  //Recupera um contato por id
  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idCampo, nomeCampo, emailCampo, telefoneCampo, imgCampo],
        where: "$idCampo = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //Deleta um contato do banco
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idCampo = ?", whereArgs: [id]);
  }

  //Atualiza um contato do banco
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.paraMap(),
        where: "$idCampo = ?", whereArgs: [contact.id]);
  }

  //Recupera todos os contatos do banco de dados
  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //Pega o numero de contatos
  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //Fecha o banco de dados
  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

//Classe de entidade Contato
class Contact {
  int id;
  String nome;
  String email;
  String telefone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idCampo];
    nome = map[nomeCampo];
    email = map[emailCampo];
    telefone = map[telefoneCampo];
    img = map[imgCampo];
  }

  Map paraMap() {
    Map<String, dynamic> map = {
      nomeCampo: nome,
      emailCampo: email,
      telefoneCampo: telefone,
      imgCampo: img
    };

    if (id != null) {
      map[idCampo] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contato ( id=$id, nome=$nome, email=$email, telefone=$telefone, img=$img)";
  }
}
