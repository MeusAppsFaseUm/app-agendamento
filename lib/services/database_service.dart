import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cliente.dart';
import '../models/agendamento.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'agendamento.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        telefone TEXT NOT NULL,
        atendimento TEXT NOT NULL,
        fotoPath TEXT,
        instagram TEXT,
        whatsapp TEXT,
        facebook TEXT,
        dataCadastro INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE agendamentos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clienteId INTEGER NOT NULL,
        dataHora INTEGER NOT NULL,
        servico TEXT NOT NULL,
        status TEXT NOT NULL,
        observacoes TEXT,
        FOREIGN KEY(clienteId) REFERENCES clientes(id)
      )
    ''');
  }

  // CRUD Clientes
  static Future<int> insertCliente(Cliente cliente) async {
    final db = await database;
    return await db.insert('clientes', cliente.toMap());
  }

  static Future<List<Cliente>> getClientes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clientes');
    return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
  }

  static Future<void> updateCliente(Cliente cliente) async {
    final db = await database;
    await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  static Future<void> deleteCliente(int id) async {
    final db = await database;
    await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Agendamentos
  static Future<int> insertAgendamento(Agendamento agendamento) async {
    final db = await database;
    return await db.insert('agendamentos', agendamento.toMap());
  }

  static Future<List<Agendamento>> getAgendamentos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('agendamentos');
    return List.generate(maps.length, (i) => Agendamento.fromMap(maps[i]));
  }

  static Future<List<Agendamento>> getAgendamentosPorData(DateTime data) async {
    final db = await database;
    final startOfDay = DateTime(data.year, data.month, data.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'agendamentos',
      where: 'dataHora >= ? AND dataHora < ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => Agendamento.fromMap(maps[i]));
  }

  static Future<void> updateAgendamento(Agendamento agendamento) async {
    final db = await database;
    await db.update(
      'agendamentos',
      agendamento.toMap(),
      where: 'id = ?',
      whereArgs: [agendamento.id],
    );
  }

  static Future<void> deleteAgendamento(int id) async {
    final db = await database;
    await db.delete('agendamentos', where: 'id = ?', whereArgs: [id]);
  }
}
