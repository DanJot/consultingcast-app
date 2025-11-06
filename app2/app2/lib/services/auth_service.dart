import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user.dart';
import '../models/company.dart';
import 'database_manager.dart';

/// Lê o API_BASE do --dart-define (ex.: --dart-define=API_BASE=https://...ngrok...)
const String kApiBase =
    String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:3000');

class AuthService {
  // Permite passar override (opcional). Se não passares, usa kApiBase.
  AuthService([String? overrideBase]) : _apiBase = overrideBase ?? kApiBase;

  final String _apiBase;
  String get apiBase => _apiBase;

  // ---------- Helpers ----------
  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_apiBase$path');
    // debug útil — deixa por agora
    // ignore: avoid_print
    print('POST => $uri');

    final resp = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 12));

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} em $path: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // ---------- LOGIN ----------
  /// Web/iOS: via API HTTP
  /// Android/Desktop: mantém MySQL direto (como tinhas)
  Future<User?> login(String email, String password) async {
    if (kIsWeb) {
      try {
        final data = await _postJson('/login', {
          'email': email,
          'password': password,
          'database': 'consultingcast2',
        });

        if (data['success'] == true) {
          final u = (data['user'] as Map<String, dynamic>? ?? {});
          return User(
            id: (u['id'] ?? '').toString(),
            email: (u['email'] ?? '').toString(),
            name: (u['name'] ?? '').toString(),
          );
        }
        // Credenciais inválidas - retorna null sem lançar exceção
        return null;
      } catch (e) {
        // Problema de rede/conectividade - lança exceção para mostrar mensagem específica
        // ignore: avoid_print
        print('login() falhou: $e');
        if (e.toString().contains('Failed to fetch') || 
            e.toString().contains('ClientException') ||
            e.toString().contains('Connection refused')) {
          throw Exception(
            'Não foi possível conectar ao servidor.\n'
            'Verifique se a API está a correr em http://localhost:3000'
          );
        }
        // Outros erros também são lançados
        rethrow;
      }
    }

    // 🤖 Android/Desktop → MySQL direto
    const databaseName = 'consultingcast2';
    final db = DatabaseManager.getConnection(databaseName);
    return db.validateCredentials(email, password);
  }

  // ---------- EMPRESAS ----------
  /// Web/iOS: chama API /companies
  /// Android/Desktop: mantém MySQL direto
  Future<List<Company>> getUserCompanies(String userId) async {
    if (kIsWeb) {
      // ignore: avoid_print
      print('🔍 getUserCompanies chamado com userId: $userId');
      
      // Tentativa 1: Buscar empresas diretamente associadas ao userId
      try {
        final data = await _postJson('/companies', {
          'userId': userId,
          'database': 'efatura', // onde está fatura_credential
        });

        // ignore: avoid_print
        print('📦 Resposta da API /companies: $data');

        if (data['success'] == true && data['companies'] is List) {
          final list = (data['companies'] as List).cast<Map<String, dynamic>>();
          // ignore: avoid_print
          print('✅ Empresas encontradas (método direto): ${list.length}');
          
          // Se encontrou empresas, retorna
          if (list.isNotEmpty) {
            return list
                .map((c) => Company(
                      id: (c['company_id'] ?? '').toString(),
                      name: (c['company_name'] ?? '').toString(),
                      nif: (c['company_nif'] ?? '').toString(),
                      description: 'Empresa de faturação eletrónica',
                    ))
                .toList();
          }
          
          // Se não encontrou, tenta método alternativo (buscar por NIFs)
          // ignore: avoid_print
          print('⚠️ Nenhuma empresa encontrada diretamente. Tentando método alternativo por NIFs...');
        }
      } catch (e) {
        // ignore: avoid_print
        print('❌ Erro no método direto: $e');
      }
      
      // Tentativa 2: Buscar empresas por NIFs associados ao utilizador
      try {
        // Primeiro, busca NIFs do utilizador na base consultingcast2
        final nifsData = await _postJson('/user/nifs', {
          'userId': userId,
          'database': 'consultingcast2',
        });
        
        if (nifsData['success'] == true && nifsData['nifs'] is List) {
          final nifs = (nifsData['nifs'] as List).cast<String>();
          if (nifs.isNotEmpty) {
            // ignore: avoid_print
            print('📋 NIFs encontrados para o utilizador: $nifs');
            
            // Agora busca empresas por esses NIFs
            final companiesData = await _postJson('/companies/by-nifs', {
              'nifs': nifs,
              'database': 'efatura',
            });
            
            if (companiesData['success'] == true && companiesData['companies'] is List) {
              final list = (companiesData['companies'] as List).cast<Map<String, dynamic>>();
              // ignore: avoid_print
              print('✅ Empresas encontradas (método por NIFs): ${list.length}');
              return list
                  .map((c) => Company(
                        id: (c['company_id'] ?? '').toString(),
                        name: (c['company_name'] ?? '').toString(),
                        nif: (c['company_nif'] ?? '').toString(),
                        description: 'Empresa de faturação eletrónica',
                      ))
                  .toList();
            }
          } else {
            // ignore: avoid_print
            print('⚠️ Utilizador não tem NIFs associados');
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('❌ Erro no método alternativo: $e');
      }
      
      // Se ambos os métodos falharam, retorna lista vazia
      // ignore: avoid_print
      print('⚠️ Nenhum método encontrou empresas. Retornando lista vazia.');
      return [];
    }

    // 🤖 Android/Desktop → MySQL direto
    const databaseName = 'efatura';
    final db = DatabaseManager.getConnection(databaseName);
    return db.getUserCompaniesFromFaturaCredencial(userId);
  }

  // ---------- RESTO (mantém como tinhas; podes migrar para API mais tarde) ----------
  Future<List<Company>> getEfaturaCompaniesForUser({
    required User user,
  }) async {
    final efDb = DatabaseManager.getConnection('efatura');
    final direct = await efDb.getEfaturaCompaniesForUser(
      userId: user.id,
      email: user.email,
    );
    if (direct.isNotEmpty) return direct;

    final ccDb = DatabaseManager.getConnection('consultingcast2');
    final nifs = await ccDb.getUserNifs(user.id);
    if (nifs.isEmpty) return [];

    final byNifs = await efDb.getEfaturaCompaniesByNifs(nifs);
    return byNifs;
  }

  Future<Map<String, dynamic>> getEfaturaCredentialByNif(String nif) async {
    final efDb = DatabaseManager.getConnection('efatura');
    return efDb.getEfaturaCredentialByNif(nif);
  }

  Future<List<String>> getAvailableDatabases() async {
    return DatabaseManager.getAvailableDatabases();
  }
}
