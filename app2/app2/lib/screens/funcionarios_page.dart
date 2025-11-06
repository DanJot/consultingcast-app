import 'package:flutter/material.dart';
import '../models/company.dart';
import '../services/database_manager.dart';
import 'invite_employee_page.dart';

class FuncionariosPage extends StatefulWidget {
  final Company company;
  const FuncionariosPage({super.key, required this.company});

  @override
  State<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends State<FuncionariosPage> {
  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    try {
      final dbName = widget.company.id.startsWith('_')
          ? widget.company.id
          : '_${widget.company.id}';
      final DatabaseService conn = DatabaseManager.getConnection(dbName);
      final data = await conn.getEmployees();
      if (!mounted) return;
      setState(() {
        _employees = data;
        _filtered = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar funcionários: ${e.toString()}')),
      );
    }
  }

  void _applyFilter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _employees.where((e) {
        final name = (e['name'] ?? '').toString().toLowerCase();
        final nib = (e['nib'] ?? '').toString().toLowerCase();
        final matchesText = name.contains(q) || nib.contains(q);
        final isActive = (e['ativo'] as bool? ?? true);
        return matchesText && (_showActiveOnly ? isActive : true);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionários'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() { _showActiveOnly = !_showActiveOnly; });
              _applyFilter();
            },
            child: Text(
              _showActiveOnly ? 'Todos' : 'Apenas ativos',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.group_off, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Sem funcionários', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Procurar por nome ou NIB',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final e = _filtered[index];
                      final active = (e['ativo'] as bool? ?? true);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: active ? const Color(0xFF10B981) : Colors.grey,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(e['name'] ?? ''),
                        subtitle: Text('NIB: ${e['nib'] ?? ''}'),
                        trailing: Icon(active ? Icons.check_circle : Icons.block, color: active ? const Color(0xFF10B981) : Colors.redAccent),
                        // Read-only: no navigation on tap
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InviteEmployeePage(company: widget.company),
            ),
          );
        },
        tooltip: 'Convidar funcionário',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  // Read-only: form disabled
}


// Form removido (read-only)


