// database_manager.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart';
import '../models/user.dart';
import '../models/company.dart';
import 'package:mysql_client/mysql_client.dart';

// Base da tua API Node (para Web usa normalmente localhost).
// Troca para o teu ngrok quando quiseres expor publicamente.
const String _apiBase = String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:3000');

class DatabaseManager {
  static final Map<String, DatabaseService> _connections = {};

  static const String _host = '10.1.55.10';
  static const int _port = 3306;
  static const String _username = 'luis';
  static const String _password = 'Admin1234';

  /// Normaliza o nome da BD:
  /// - Garante prefixo "_"
  /// - Garante sufixo "_mobile"
  static String _normalizeDbName(String databaseName) {
    var db = databaseName.trim();
    if (db.isEmpty) return db;
    if (!db.startsWith('_')) db = '_$db';
    if (!db.endsWith('_mobile')) db = '${db}_mobile';
    return db;
  }

  /// DEVOLVE UMA CONEXÃO (OU CRIA UMA NOVA) PARA A BD INDICADA
  static DatabaseService getConnection(String databaseName) {
    final normalized = _normalizeDbName(databaseName);

    // Se a conexão já existe, retorna-a
    if (_connections.containsKey(normalized)) {
      return _connections[normalized]!;
    }

    // Cria nova conexão (HTTP para snapshot; MySQL nativo noutros métodos quando não é Web)
    final connection = DatabaseService(
      host: _host,
      port: _port,
      user: _username,
      password: _password,
      dbName: normalized,
      apiBase: _apiBase,
    );

    // Armazena a conexão
    _connections[normalized] = connection;
    return connection;
  }

  /// Remove uma conexão específica
  static void removeConnection(String databaseName) {
    _connections.remove(_normalizeDbName(databaseName));
  }

  /// Remove todas as conexões
  static void clearAllConnections() {
    _connections.clear();
  }

  /// LISTA BDs DISPONÍVEIS (QUE COMEÇAM POR "_")
  static Future<List<String>> getAvailableDatabases() async {
    // BLOQUEIO PARA WEB
    if (kIsWeb) {
      throw UnsupportedError(
        'Esta versão Web não consegue ligar ao MySQL diretamente.\n'
        'Usa a versão Android ou cria uma API HTTP para acesso remoto.',
      );
    }

    try {
      final conn = await MySQLConnection.createConnection(
        host: _host,
        port: _port,
        userName: _username,
        password: _password,
        databaseName: 'information_schema',
      );

      await conn.connect().timeout(const Duration(seconds: 5));

      final result = await conn
          .execute(
            'SELECT SCHEMA_NAME FROM SCHEMATA WHERE SCHEMA_NAME LIKE "_%" ORDER BY SCHEMA_NAME',
          )
          .timeout(const Duration(seconds: 5));

      final databases = <String>[];
      for (final row in result.rows) {
        final name = row.colByName('SCHEMA_NAME')?.toString();
        if (name != null) databases.add(name);
      }

      await conn.close();
      return databases;
    } catch (_) {
      return [];
    }
  }
}

/// Serviço de dados.
/// - Para **snapshot de vendas** usa SEMPRE a API HTTP (`/sales/snapshot`) — funciona em Web e Mobile.
/// - Podes acrescentar aqui métodos que usem MySQL nativo quando não estás em Web, se precisares.
class DatabaseService {
  final String host;
  final int port;
  final String user;
  final String password;
  final String dbName;

  /// Base da API Node (ex.: http://localhost:3000 ou o teu ngrok)
  final String apiBase;

  DatabaseService({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.dbName,
    required this.apiBase,
  });

  void _guardWeb() {
    if (kIsWeb) {
      throw UnsupportedError(
        'A versão Web não pode ligar diretamente ao MySQL. '
        'Usa a app Android (APK) ou cria uma API HTTP para acesso remoto.',
      );
    }
  }

  /// Chama a API e devolve um mapa no formato que a `company_page.dart` já usa:
  /// { current, prevMonth, prevYear }
  ///
  /// - current: VENDAS_AC (acumulado) do período alvo
  /// - prevMonth: VENDAS_AC do mês anterior ao período alvo
  /// - prevYear: valor homólogo (N-1) do período alvo (a API calcula)
  Future<Map<String, double?>> getSalesSnapshot({String mode = 'last_closed'}) async {
    // 1) Período alvo, conforme o "mode"
    final latest = await _fetchSnapshot(mode: mode); // sem ano/mes → usa o modo

    // 2) Período anterior (mês anterior ao período alvo)
    double? prevMonthValue;
    if (latest != null && latest['ano'] != null && latest['mes'] != null) {
      final int ano = (latest['ano'] as num).toInt();
      final int mes = (latest['mes'] as num).toInt();
      final int prevAno = mes == 1 ? ano - 1 : ano;
      final int prevMes = mes == 1 ? 12 : mes - 1;

      final prev = await _fetchSnapshot(ano: prevAno, mes: prevMes);
      prevMonthValue = _toDouble(prev?['vendas_acumuladas']);
    }

    return {
      'current': _toDouble(latest?['vendas_acumuladas']),
      'prevMonth': prevMonthValue,
      'prevYear': _toDouble(latest?['vendas_mes_ano_anterior']),
    };
  }

  /// Helper: chama POST /sales/snapshot
  /// - Se ano/mes forem passados, força esse período (ignora "mode").
  /// - Caso contrário, usa o "mode": 'last_closed' (default) ou 'current_mtd'.
  Future<Map<String, dynamic>?> _fetchSnapshot({int? ano, int? mes, String? mode}) async {
    final uri = Uri.parse('$apiBase/sales/snapshot');
    final body = <String, dynamic>{
      'database': dbName, // exemplo: _501280570_mobile
      if (ano != null) 'ano': ano,
      if (mes != null) 'mes': mes,
      if (ano == null && mes == null && mode != null) 'mode': mode,
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('Falha na API (${resp.statusCode})');
    }
    final json = jsonDecode(resp.body);
    if (json is! Map<String, dynamic>) {
      throw Exception('Resposta inválida da API');
    }
    if (json['success'] != true) {
      final err = json['error'] ?? 'Erro desconhecido';
      throw Exception('Erro API: $err');
    }
    if (json['data'] == null) return null;

    // Mantemos a estrutura original do payload "data"
    return Map<String, dynamic>.from(json['data'] as Map);
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.'));
  }

  // -------------------------------------------------------------
  // Espaço para outros métodos que já possas ter (ex.: getYearlySales)
  // Podes manter os teus métodos atuais aqui sem tocar neles.
  // -------------------------------------------------------------

  // ==== Métodos MySQL (copiados/adaptados do serviço original) ====

  Future<User?> validateCredentials(String email, String inputPassword) async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;

      final byEmail = await conn
          .execute(
            'SELECT id, email, `password` FROM users WHERE LOWER(email) = LOWER(:email) LIMIT 1',
            {'email': email.trim()},
          )
          .timeout(const Duration(seconds: 5));

      if (byEmail.numOfRows > 0) {
        final row = byEmail.rows.first;
        final storedPass = row.colByName('password')?.toString() ?? '';
        final inputPass = inputPassword.trim();

        bool passwordMatches = false;
        if (storedPass.startsWith(r'$2y$') ||
            storedPass.startsWith(r'$2a$') ||
            storedPass.startsWith(r'$2b$')) {
          try {
            passwordMatches = BCrypt.checkpw(inputPass, storedPass);
          } catch (_) {
            passwordMatches = false;
          }
        } else {
          passwordMatches = storedPass == inputPass;
        }

        if (passwordMatches) {
          final fetchedEmail = row.colByName('email')?.toString() ?? '';
          final inferredName =
              fetchedEmail.contains('@') ? fetchedEmail.split('@').first : fetchedEmail;

          return User(
            id: row.colByName('id')?.toString() ?? '',
            email: fetchedEmail,
            name: inferredName,
          );
        }
      }
      return null;
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  Future<List<Map<String, dynamic>>> getYearlySales() async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;

      const int targetYear = 2024;
      final result = await conn
          .execute(
            'SELECT mes, VENDAS_AC AS vendas_ac FROM resultados_mensais WHERE ano = :ano AND mes >= 7 ORDER BY mes ASC',
            {'ano': targetYear},
          )
          .timeout(const Duration(seconds: 5));

      final Map<int, double> salesByMonth = {};
      for (final row in result.rows) {
        final mes = int.tryParse(row.colByName('mes')?.toString() ?? '1') ?? 1;
        final vendas = double.tryParse(row.colByName('vendas_ac')?.toString() ?? '0') ?? 0.0;
        salesByMonth[mes] = vendas;
      }

      final monthlyData = <Map<String, dynamic>>[];
      for (int mes = 7; mes <= 12; mes++) {
        monthlyData.add({'mes': mes, 'vendas_ac': salesByMonth[mes] ?? 0.0});
      }
      return monthlyData;
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSalesResults() async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;

      final result = await conn
          .execute(
            'SELECT vendas_ac, VENDAS_N_1 AS vendas_n_1, mes, ano FROM resultados_mensais ORDER BY ano DESC, mes DESC LIMIT 2',
          )
          .timeout(const Duration(seconds: 5));

      final list = <Map<String, dynamic>>[];
      for (final row in result.rows) {
        final vendas = row.colByName('vendas_ac')?.toString() ?? '0';
        final vendasN1 = row.colByName('vendas_n_1')?.toString() ?? '0';
        list.add({
          'vendas_ac': double.tryParse(vendas) ?? 0.0,
          'vendas_n_1': double.tryParse(vendasN1) ?? 0.0,
          'mes': int.tryParse(row.colByName('mes')?.toString() ?? '1') ?? 1,
          'ano': int.tryParse(row.colByName('ano')?.toString() ?? '2024') ?? 2024,
        });
      }
      return list;
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  Future<Map<String, dynamic>> getEfaturaCredentialByNif(String nif) async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;

      final result = await conn
          .execute(
            'SELECT nome_empresa, nif, morada, localidade, cod_postal, telefone, email, natureza_juridica, data_constituicao_sociedade, tipo_contabilidade, enquadramento_iva, estado FROM fatura_credential WHERE nif = :nif LIMIT 1',
            {'nif': nif},
          )
          .timeout(const Duration(seconds: 5));
      if (result.numOfRows == 0) return {};
      final row = result.rows.first;
      return {
        'nome_empresa': row.colByName('nome_empresa')?.toString() ?? '',
        'nif': row.colByName('nif')?.toString() ?? '',
        'morada': row.colByName('morada')?.toString() ?? '',
        'localidade': row.colByName('localidade')?.toString() ?? '',
        'cod_postal': row.colByName('cod_postal')?.toString() ?? '',
        'telefone': row.colByName('telefone')?.toString() ?? '',
        'email': row.colByName('email')?.toString() ?? '',
        'natureza_juridica': row.colByName('natureza_juridica')?.toString() ?? '',
        'data_constituicao_sociedade': row.colByName('data_constituicao_sociedade')?.toString() ?? '',
        'tipo_contabilidade': row.colByName('tipo_contabilidade')?.toString() ?? '',
        'enquadramento_iva': row.colByName('enquadramento_iva')?.toString() ?? '',
        'estado': row.colByName('estado')?.toString() ?? '',
      };
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  Future<List<Company>> getUserCompaniesFromFaturaCredencial(String userId) async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;
      final result = await conn
          .execute(
            'SELECT DISTINCT fc.nif AS company_id, fc.nome_empresa AS company_name, fc.nif AS company_nif FROM fatura_credential fc WHERE fc.id_user_cc = :userId AND fc.estado = 1 ORDER BY fc.nome_empresa',
            {'userId': userId},
          )
          .timeout(const Duration(seconds: 5));
      final companies = <Company>[];
      for (final row in result.rows) {
        companies.add(Company(
          id: row.colByName('company_id')?.toString() ?? '',
          name: row.colByName('company_name')?.toString() ?? '',
          nif: row.colByName('company_nif')?.toString() ?? '',
          description: 'Empresa de faturação eletrónica',
        ));
      }
      return companies;
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  Future<List<Company>> getEfaturaCompaniesForUser({required String userId, required String email}) async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;

      Future<IResultSet> q(String sql, Map<String, dynamic> params) =>
          conn.execute(sql, params).timeout(const Duration(seconds: 5));

      IResultSet result = await q(
        'SELECT DISTINCT fc.nif AS company_id, fc.nome_empresa AS company_name, fc.nif AS company_nif FROM fatura_credential fc WHERE fc.id_user_cc = :userId AND fc.estado = 1 ORDER BY fc.nome_empresa',
        {'userId': userId},
      );
      if (result.numOfRows == 0) {
        result = await q(
          'SELECT DISTINCT fc.nif AS company_id, fc.nome_empresa AS company_name, fc.nif AS company_nif FROM fatura_credential fc WHERE fc.estado = 1 AND (LOWER(fc.email) = LOWER(:email) OR LOWER(COALESCE(fc.email_notificacoes, "")) = LOWER(:email) OR LOWER(COALESCE(fc.email_2, "")) = LOWER(:email) OR LOWER(fc.email) LIKE LOWER(CONCAT(:emailPrefix, "%")) OR LOWER(COALESCE(fc.email_notificacoes, "")) LIKE LOWER(CONCAT(:emailPrefix, "%")) OR LOWER(COALESCE(fc.email_2, "")) LIKE LOWER(CONCAT(:emailPrefix, "%"))) ORDER BY fc.nome_empresa',
          {'email': email.trim(), 'emailPrefix': email.trim()},
        );
      }
      if (result.numOfRows == 0) {
        result = await q(
          'SELECT DISTINCT fc.nif AS company_id, fc.nome_empresa AS company_name, fc.nif AS company_nif FROM fatura_credential fc WHERE fc.id_user_cc = :userId ORDER BY fc.nome_empresa',
          {'userId': userId},
        );
      }
      if (result.numOfRows == 0) {
        result = await q(
          'SELECT DISTINCT fc.nif AS company_id, fc.nome_empresa AS company_name, fc.nif AS company_nif FROM fatura_credential fc WHERE (LOWER(fc.email) = LOWER(:email) OR LOWER(COALESCE(fc.email_notificacoes, "")) = LOWER(:email) OR LOWER(COALESCE(fc.email_2, "")) = LOWER(:email)) ORDER BY fc.nome_empresa',
          {'email': email.trim(), 'emailPrefix': email.trim()},
        );
      }

      final companies = <Company>[];
      for (final row in result.rows) {
        companies.add(Company(
          id: row.colByName('company_id')?.toString() ?? '',
          name: row.colByName('company_name')?.toString() ?? '',
          nif: row.colByName('company_nif')?.toString() ?? '',
          description: 'Empresa de faturação eletrónica',
        ));
      }
      return companies;
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  Future<List<String>> getUserNifs(String userId) async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;
      final result = await conn
          .execute(
            'SELECT DISTINCT un.nif FROM user_nifs un WHERE un.user_id = :userId ORDER BY un.nif',
            {'userId': userId},
          )
          .timeout(const Duration(seconds: 5));
      final nifs = <String>[];
      for (final row in result.rows) {
        nifs.add(row.colByName('nif')?.toString() ?? '');
      }
      return nifs.where((e) => e.isNotEmpty).toList();
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  Future<List<Company>> getEfaturaCompaniesByNifs(List<String> nifs) async {
    _guardWeb();
    if (nifs.isEmpty) return [];

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;

      final placeholders = List.generate(nifs.length, (i) => ':n$i').join(',');
      final params = <String, dynamic>{};
      for (int i = 0; i < nifs.length; i++) {
        params['n$i'] = nifs[i];
      }
      final result = await conn
          .execute(
            'SELECT DISTINCT fc.nif AS company_id, fc.nome_empresa AS company_name, fc.nif AS company_nif FROM fatura_credential fc WHERE fc.nif IN ($placeholders) ORDER BY fc.nome_empresa',
            params,
          )
          .timeout(const Duration(seconds: 5));
      final companies = <Company>[];
      for (final row in result.rows) {
        companies.add(Company(
          id: row.colByName('company_id')?.toString() ?? '',
          name: row.colByName('company_name')?.toString() ?? '',
          nif: row.colByName('company_nif')?.toString() ?? '',
          description: 'Empresa de faturação eletrónica',
        ));
      }
      return companies;
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;

      final result = await conn
          .execute(
            'SELECT id, nome AS name, COALESCE(nib, "") AS nib, COALESCE(ativo, 1) AS ativo, '
            'COALESCE(campo_1, "") AS campo_1, COALESCE(campo_2, "") AS campo_2, COALESCE(campo_3, "") AS campo_3, '
            'COALESCE(campo_4, "") AS campo_4, COALESCE(campo_5, "") AS campo_5 FROM funcionarios',
          )
          .timeout(const Duration(seconds: 5));

      final list = <Map<String, dynamic>>[];
      for (final row in result.rows) {
        list.add({
          'id': row.colByName('id')?.toString() ?? '',
          'name': row.colByName('name')?.toString() ?? '',
          'nib': row.colByName('nib')?.toString() ?? '',
          'ativo': (row.colByName('ativo')?.toString() ?? '1') == '1',
          'campo_1': row.colByName('campo_1')?.toString(),
          'campo_2': row.colByName('campo_2')?.toString(),
          'campo_3': row.colByName('campo_3')?.toString(),
          'campo_4': row.colByName('campo_4')?.toString(),
          'campo_5': row.colByName('campo_5')?.toString(),
        });
      }
      return list;
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  Future<Map<String, String>> createUserInvite({
    required String email,
    required String name,
    required String companyId,
    Duration ttl = const Duration(days: 7),
  }) async {
    _guardWeb();

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: dbName,
    );
    bool isConnected = false;
    try {
      await conn.connect().timeout(const Duration(seconds: 5));
      isConnected = true;

      final now = DateTime.now();
      final exp = now.add(ttl);
      final token = '${now.millisecondsSinceEpoch}-${email.hashCode}-${exp.millisecondsSinceEpoch}';

      await conn
          .execute(
            'CREATE TABLE IF NOT EXISTS user_invites (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(255), nome VARCHAR(255), token VARCHAR(255), company_id VARCHAR(64), created_at DATETIME, expires_at DATETIME)'
          )
          .timeout(const Duration(seconds: 5));

      await conn
          .execute(
            'INSERT INTO user_invites (email, nome, token, company_id, created_at, expires_at) VALUES (:e, :n, :t, :c, :ca, :ea)',
            {
              'e': email,
              'n': name,
              't': token,
              'c': companyId,
              'ca': now.toIso8601String().substring(0, 19).replaceFirst('T', ' '),
              'ea': exp.toIso8601String().substring(0, 19).replaceFirst('T', ' '),
            },
          )
          .timeout(const Duration(seconds: 5));

      return {'token': token, 'expiresAt': exp.toIso8601String()};
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try { await conn.close(); } catch (_) {}
      }
    }
  }
}
