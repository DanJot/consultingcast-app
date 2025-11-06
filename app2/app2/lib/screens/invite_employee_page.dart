import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/database_manager.dart';
import '../models/company.dart';

class InviteEmployeePage extends StatefulWidget {
  final Company company;
  const InviteEmployeePage({super.key, required this.company});

  @override
  State<InviteEmployeePage> createState() => _InviteEmployeePageState();
}

class _InviteEmployeePageState extends State<InviteEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  String? _token;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convidar Funcionário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createInvite,
                      child: const Text('Gerar convite'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_token != null) ...[
              const Text('Convite criado:'),
              const SizedBox(height: 8),
              SelectableText(_inviteUrl),
              const SizedBox(height: 16),
              Center(
                child: QrImageView(
                  data: _inviteUrl,
                  version: QrVersions.auto,
                  size: 180,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Partilhe o QR ou o link por email.'),
            ],
          ],
        ),
      ),
    );
  }

  String get _inviteUrl => 'https://consultingcast.app/invite?token=$_token';

  Future<void> _createInvite() async {
    if (!_formKey.currentState!.validate()) return;
    final dbName = widget.company.id.startsWith('_') ? widget.company.id : '_${widget.company.id}';
    final DatabaseService conn = DatabaseManager.getConnection(dbName);
    final result = await conn.createUserInvite(
      email: _email.text.trim(),
      name: _name.text.trim(),
      companyId: widget.company.id,
    );
    setState(() { _token = result['token']; });
  }
}


