import 'package:flutter/foundation.dart'; // debugPrint + kIsWeb
import 'package:mysql_client/mysql_client.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user.dart';
import '../models/company.dart';

/// SERVIÇO DE BASE DE DADOS
///
/// Esta classe gere todas as operações de base de dados para a aplicação.
/// Utiliza MySQL como motor de base de dados e implementa:
/// - Autenticação de utilizadores com validação de passwords (bcrypt + texto plano)
/// - Obtenção de empresas associadas a um utilizador através de JOINs
/// - Fallback automático quando tabelas não existem
///
/// IMPORTANTE: Em ambiente Web (PWA), o browser não permite ligações TCP (MySQL).
/// Por isso, todos os métodos abaixo travam na Web com UnsupportedError.
/// Usa APK Android para testes nativos ou cria uma API HTTP para suportar Web.
class DatabaseService {
  final String host;      // Endereço do servidor MySQL
  final int port;         // Porta do servidor MySQL (geralmente 3306)
  final String user;      // Nome de utilizador da base de dados
  final String password;  // Password da base de dados
  final String dbName;    // Nome da base de dados a utilizar

  const DatabaseService({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.dbName,
  });

  // Travão para Web: impedir tentativa de ligação MySQL em PWA
  void _guardWeb() {
    if (kIsWeb) {
      throw UnsupportedError(
        'A versão Web não pode ligar diretamente ao MySQL. '
        'Usa a app Android (APK) ou cria uma API HTTP para acesso remoto.'
      );
    }
  }

  /// VALIDAÇÃO DE CREDENCIAIS DE UTILIZADOR
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

  /// Retorna vendas dos últimos 6 meses de 2024
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

      final List<Map<String, dynamic>> monthlyData = [];
      final Map<int, double> salesByMonth = {};

      for (final row in result.rows) {
        final mes = int.tryParse(row.colByName('mes')?.toString() ?? '1') ?? 1;
        final vendas = double.tryParse(row.colByName('vendas_ac')?.toString() ?? '0') ?? 0.0;
        salesByMonth[mes] = vendas;
      }

      for (int mes = 7; mes <= 12; mes++) {
        monthlyData.add({
          'mes': mes,
          'vendas_ac': salesByMonth[mes] ?? 0.0,
        });
      }

      debugPrint('[YearlySales] Last 6 months of $targetYear: ${monthlyData.length} months');
      return monthlyData;
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /// Lista resultados mensais de vendas
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

      debugPrint('[Sales] Found ${result.numOfRows} rows');

      final list = <Map<String, dynamic>>[];
      for (final row in result.rows) {
        final vendas = row.colByName('vendas_ac')?.toString() ?? '0';
        final vendasN1 = row.colByName('vendas_n_1')?.toString() ?? '0';
        debugPrint('[Sales] vendas_ac=$vendas, vendas_n_1=$vendasN1, mes=${row.colByName('mes')}, ano=${row.colByName('ano')}');
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
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /// Devolve vendas do mês atual, mês anterior e ano anterior (N-1)
  Future<Map<String, dynamic>> getSalesSnapshot() async {
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

      double current = 0.0;
      double prevMonth = 0.0;
      double prevYear = 0.0;
      final int baseAno = DateTime.now().year;
      final int baseMes = DateTime.now().month;
      const bool isCurrentMonth = true;

      IResultSet r = await conn
          .execute(
            'SELECT VENDAS_AC AS vendas_ac, VENDAS_N_1 AS vendas_n_1 FROM resultados_mensais WHERE ano = :ano AND mes = :mes LIMIT 1',
            { 'ano': baseAno, 'mes': baseMes },
          )
          .timeout(const Duration(seconds: 5));
      if (r.numOfRows > 0) {
        final row = r.rows.first;
        final vendasAcStr = row.colByName('vendas_ac')?.toString() ?? '0';
        final vendasN1Str = row.colByName('vendas_n_1')?.toString() ?? '0';
        current = double.tryParse(vendasAcStr) ?? 0.0;
        prevYear = double.tryParse(vendasN1Str) ?? 0.0;
        debugPrint('[SalesSnapshot] Row found: vendas_ac=$vendasAcStr, vendas_n_1=$vendasN1Str');
      } else {
        debugPrint('[SalesSnapshot] No row found for $baseAno/$baseMes');
      }

      if (prevYear == 0.0) {
        final ry = await conn
            .execute(
              'SELECT VENDAS_AC AS prev_y FROM resultados_mensais WHERE ano = :ano AND mes = :mes LIMIT 1',
              { 'ano': baseAno - 1, 'mes': baseMes },
            )
            .timeout(const Duration(seconds: 5));
        if (ry.numOfRows > 0) {
          prevYear = double.tryParse(ry.rows.first.colByName('prev_y')?.toString() ?? '0') ?? 0.0;
          debugPrint('[SalesSnapshot] PrevYear from previous year month ${baseAno - 1}/$baseMes: $prevYear');
        }
      }

      final int prevAno = baseMes == 1 ? baseAno - 1 : baseAno;
      final int prevMes = baseMes == 1 ? 12 : baseMes - 1;
      r = await conn
          .execute(
            'SELECT VENDAS_AC AS vendas_ac FROM resultados_mensais WHERE ano = :ano AND mes = :mes LIMIT 1',
            { 'ano': prevAno, 'mes': prevMes },
          )
          .timeout(const Duration(seconds: 5));
      if (r.numOfRows > 0) {
        prevMonth = double.tryParse(r.rows.first.colByName('vendas_ac')?.toString() ?? '0') ?? 0.0;
        debugPrint('[SalesSnapshot] Prev month $prevAno/$prevMes: $prevMonth');
      } else {
        debugPrint('[SalesSnapshot] No prev month found for $prevAno/$prevMes');
      }

      debugPrint('[SalesSnapshot] base=$baseAno/$baseMes current=$current prev=$prevAno/$prevMes prevMonth=$prevMonth prevYear=$prevYear isCurrent=$isCurrentMonth');
      return {
        'current': current,
        'prevMonth': prevMonth,
        'prevYear': prevYear,
        'baseAno': baseAno,
        'baseMes': baseMes,
        'isCurrentMonth': isCurrentMonth,
      };
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /// Cria um convite de utilizador (token único) na BD corrente
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

  /// Lista todos os funcionários da BD corrente
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

  /// Cria um novo funcionário
  Future<void> insertEmployee({
    required String name,
    String? nib,
    bool active = true,
    String? campo1,
    String? campo2,
    String? campo3,
    String? campo4,
    String? campo5,
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
      await conn
          .execute(
            'INSERT INTO funcionarios (nome, nib, ativo, campo_1, campo_2, campo_3, campo_4, campo_5) '
            'VALUES (:nome, :nib, :ativo, :c1, :c2, :c3, :c4, :c5)',
            {
              'nome': name,
              'nib': nib ?? '',
              'ativo': active ? 1 : 0,
              'c1': campo1 ?? '',
              'c2': campo2 ?? '',
              'c3': campo3 ?? '',
              'c4': campo4 ?? '',
              'c5': campo5 ?? '',
            },
          )
          .timeout(const Duration(seconds: 5));
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /// Atualiza um funcionário existente
  Future<void> updateEmployee({
    required String id,
    required String name,
    String? nib,
    bool active = true,
    String? campo1,
    String? campo2,
    String? campo3,
    String? campo4,
    String? campo5,
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
      await conn
          .execute(
            'UPDATE funcionarios SET nome=:nome, nib=:nib, ativo=:ativo, campo_1=:c1, campo_2=:c2, campo_3=:c3, campo_4=:c4, campo_5=:c5 WHERE id=:id',
            {
              'id': id,
              'nome': name,
              'nib': nib ?? '',
              'ativo': active ? 1 : 0,
              'c1': campo1 ?? '',
              'c2': campo2 ?? '',
              'c3': campo3 ?? '',
              'c4': campo4 ?? '',
              'c5': campo5 ?? '',
            },
          )
          .timeout(const Duration(seconds: 5));
    } finally {
      if (isConnected) {
        await conn.close();
      } else {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /// Em BD efatura: devolve detalhes da fatura_credential por NIF
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
            '''
            SELECT 
              nome_empresa,
              nif,
              morada,
              localidade,
              cod_postal,
              telefone,
              email,
              natureza_juridica,
              data_constituicao_sociedade,
              tipo_contabilidade,
              enquadramento_iva,
              estado
            FROM fatura_credential
            WHERE nif = :nif
            LIMIT 1
            ''',
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
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /// OBTÉM EMPRESAS ASSOCIADAS A UM UTILIZADOR DA BD efatura
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

      debugPrint('[DB] getUserCompaniesFromFaturaCredencial: a buscar empresas da BD efatura');

      final result = await conn
          .execute(
            '''
            SELECT DISTINCT 
              fc.nif           AS company_id,
              fc.nome_empresa  AS company_name,
              fc.nif           AS company_nif
            FROM fatura_credential fc
            WHERE fc.id_user_cc = :userId
              AND fc.estado = 1
            ORDER BY fc.nome_empresa
            ''',
            {'userId': userId},
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('[DB] getUserCompaniesFromFaturaCredencial: query executada com sucesso');

      final companies = <Company>[];
      for (final row in result.rows) {
        companies.add(
          Company(
            id: row.colByName('company_id')?.toString() ?? '',
            name: row.colByName('company_name')?.toString() ?? '',
            nif: row.colByName('company_nif')?.toString() ?? '',
            description: 'Empresa de faturação eletrónica',
          ),
        );
      }

      debugPrint('[DB] getUserCompaniesFromFaturaCredencial: total empresas devolvidas = ${companies.length}');
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

  /// Obtém empresas da efatura com fallbacks progressivos
  Future<List<Company>> getEfaturaCompaniesForUser({
    required String userId,
    required String email,
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

      Future<IResultSet> q(String sql, Map<String, dynamic> params) =>
          conn.execute(sql, params).timeout(const Duration(seconds: 5));

      IResultSet result;

      debugPrint('[efatura] procurar empresas para userId=$userId, email=$email');

      // 1) id_user_cc + estado=1
      result = await q(
        '''
        SELECT DISTINCT 
          fc.nif           AS company_id,
          fc.nome_empresa  AS company_name,
          fc.nif           AS company_nif
        FROM fatura_credential fc
        WHERE fc.id_user_cc = :userId AND fc.estado = 1
        ORDER BY fc.nome_empresa
        ''',
        {'userId': userId},
      );
      debugPrint('[efatura] passo 1 (id_user_cc & ativo) -> ${result.numOfRows}');
      if (result.numOfRows == 0) {
        // 2) emails + estado=1
        result = await q(
          '''
          SELECT DISTINCT 
            fc.nif           AS company_id,
            fc.nome_empresa  AS company_name,
            fc.nif           AS company_nif
          FROM fatura_credential fc
          WHERE fc.estado = 1 AND (
            LOWER(fc.email) = LOWER(:email)
            OR LOWER(COALESCE(fc.email_notificacoes, '')) = LOWER(:email)
            OR LOWER(COALESCE(fc.email_2, '')) = LOWER(:email)
            OR LOWER(fc.email) LIKE LOWER(CONCAT(:emailPrefix, '%'))
            OR LOWER(COALESCE(fc.email_notificacoes, '')) LIKE LOWER(CONCAT(:emailPrefix, '%'))
            OR LOWER(COALESCE(fc.email_2, '')) LIKE LOWER(CONCAT(:emailPrefix, '%'))
          )
          ORDER BY fc.nome_empresa
          ''',
          {
            'email': email.trim(),
            'emailPrefix': email.trim(),
          },
        );
        debugPrint('[efatura] passo 2 (emails & ativo) -> ${result.numOfRows}');
      }
      if (result.numOfRows == 0) {
        // 3) id_user_cc sem estado
        result = await q(
          '''
          SELECT DISTINCT 
            fc.nif           AS company_id,
            fc.nome_empresa  AS company_name,
            fc.nif           AS company_nif
          FROM fatura_credential fc
          WHERE fc.id_user_cc = :userId
          ORDER BY fc.nome_empresa
          ''',
          {'userId': userId},
        );
        debugPrint('[efatura] passo 3 (id_user_cc sem estado) -> ${result.numOfRows}');
      }
      if (result.numOfRows == 0) {
        // 4) emails sem estado
        result = await q(
          '''
          SELECT DISTINCT 
            fc.nif           AS company_id,
            fc.nome_empresa  AS company_name,
            fc.nif           AS company_nif
          FROM fatura_credential fc
          WHERE (
            LOWER(fc.email) = LOWER(:email)
            OR LOWER(COALESCE(fc.email_notificacoes, '')) = LOWER(:email)
            OR LOWER(COALESCE(fc.email_2, '')) = LOWER(:email)
          )
          ORDER BY fc.nome_empresa
          ''',
          {
            'email': email.trim(),
            'emailPrefix': email.trim(),
          },
        );
        debugPrint('[efatura] passo 4 (emails sem estado) -> ${result.numOfRows}');
      }

      if (result.numOfRows == 0) {
        // 5) diagnóstico
        try {
          final diag1 = await q(
              'SELECT COUNT(*) c FROM fatura_credential WHERE id_user_cc = :userId',
              {'userId': userId});
          final diag2 = await q(
              'SELECT COUNT(*) c FROM fatura_credential WHERE LOWER(email)=LOWER(:e) OR LOWER(COALESCE(email_notificacoes, ""))=LOWER(:e) OR LOWER(COALESCE(email_2, ""))=LOWER(:e)',
              {'e': email.trim()});
          final c1 = diag1.rows.isNotEmpty ? diag1.rows.first.colAt(0) : '0';
          final c2 = diag2.rows.isNotEmpty ? diag2.rows.first.colAt(0) : '0';
          debugPrint('[efatura] diag: por id_user_cc=$c1, por email=$c2');
        } catch (_) {}
      }

      final companies = <Company>[];
      for (final row in result.rows) {
        companies.add(
          Company(
            id: row.colByName('company_id')?.toString() ?? '',
            name: row.colByName('company_name')?.toString() ?? '',
            nif: row.colByName('company_nif')?.toString() ?? '',
            description: 'Empresa de faturação eletrónica',
          ),
        );
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

  /// Em BD consultingcast2: obtém a lista de NIFs associados ao utilizador
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
            '''
            SELECT DISTINCT un.nif
            FROM user_nifs un
            WHERE un.user_id = :userId
            ORDER BY un.nif
            ''',
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
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /// Em BD efatura: obtém empresas por lista de NIFs
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
            '''
            SELECT DISTINCT 
              fc.nif           AS company_id,
              fc.nome_empresa  AS company_name,
              fc.nif           AS company_nif
            FROM fatura_credential fc
            WHERE fc.nif IN ($placeholders)
            ORDER BY fc.nome_empresa
            ''',
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
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /// OBTÉM EMPRESAS ASSOCIADAS A UM UTILIZADOR (MÉTODO ORIGINAL)
  Future<List<Company>> getUserCompanies(String userId) async {
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

      dynamic result;

      try {
        debugPrint('[DB] getUserCompanies: tentar JOIN com tabela empresas');
        result = await conn
            .execute(
              '''
              SELECT DISTINCT 
                c.id           AS company_id,
                c.nome         AS company_name,
                c.nif          AS company_nif
              FROM users u
              INNER JOIN user_nifs un ON u.id = un.user_id
              INNER JOIN empresas c ON c.nif = un.nif
              WHERE u.id = :userId
              ORDER BY c.nome
              ''',
              {'userId': userId},
            )
            .timeout(const Duration(seconds: 5));
        debugPrint('[DB] getUserCompanies: JOIN empresas bem-sucedido');

      } catch (e) {
        debugPrint('[DB] getUserCompanies: falha JOIN empresas, a usar fallback user_nifs. Erro: ${e.toString()}');
        result = await conn
            .execute(
              '''
              SELECT DISTINCT 
                un.id   AS company_id,
                un.nif  AS company_nif
              FROM users u
              INNER JOIN user_nifs un ON u.id = un.user_id
              WHERE u.id = :userId
              ORDER BY un.nif
              ''',
              {'userId': userId},
            )
            .timeout(const Duration(seconds: 5));
        debugPrint('[DB] getUserCompanies: fallback user_nifs executado');
      }

      final companies = <Company>[];

      for (final row in result.rows) {
        final hasRealFields = row.colByName('company_name') != null;

        final company = hasRealFields
            ? Company(
                id: row.colByName('company_id')?.toString() ?? '',
                name: row.colByName('company_name')?.toString() ?? '',
                nif: row.colByName('company_nif')?.toString() ?? '',
                description: 'Empresa associada ao NIF ${row.colByName('company_nif')?.toString() ?? ''}',
              )
            : Company(
                id: row.colByName('company_id')?.toString() ?? '',
                name: 'Empresa NIF: ${row.colByName('company_nif')?.toString() ?? ''}',
                nif: row.colByName('company_nif')?.toString() ?? '',
                description: 'Empresa associada ao NIF ${row.colByName('company_nif')?.toString() ?? ''}',
              );

        companies.add(company);
      }

      debugPrint('[DB] getUserCompanies: total empresas devolvidas = ${companies.length}');
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
}
