import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/company.dart';

class TasksPage extends StatefulWidget {
  final User user;
  final Company? selectedCompany;

  const TasksPage({super.key, required this.user, this.selectedCompany});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  String _filter = 'todas';
  late AnimationController _animationController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Enviar declaração trimestral IVA',
      'due': '2025-10-10',
      'status': 'pendente',
      'type': 'fiscal',
      'priority': 'alta',
      'description': 'Declaração do terceiro trimestre de 2024',
    },
    {
      'title': 'Pagar IUC - VW Golf',
      'due': '2025-10-05',
      'status': 'em curso',
      'type': 'fiscal',
      'priority': 'media',
      'description': 'Pagamento do imposto único de circulação',
    },
    {
      'title': 'Assinar contrato com Cliente X',
      'due': '2025-10-01',
      'status': 'concluída',
      'type': 'contrato',
      'priority': 'alta',
      'description': 'Contrato de consultoria empresarial',
    },
    {
      'title': 'Anexar recibos de despesas',
      'due': '2025-10-12',
      'status': 'pendente',
      'type': 'financeiro',
      'priority': 'baixa',
      'description': 'Organizar recibos do último mês',
    },
    {
      'title': 'Atualizar registos comerciais',
      'due': '2025-10-15',
      'status': 'pendente',
      'type': 'administrativo',
      'priority': 'media',
      'description': 'Atualizar dados comerciais na plataforma',
    },
    {
      'title': 'Análise mensal de performance',
      'due': '2025-10-08',
      'status': 'em curso',
      'type': 'relatorio',
      'priority': 'alta',
      'description': 'Relatório de performance empresarial',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyName = widget.selectedCompany?.name ?? 'Empresa';
    final filteredTasks = _tasks.where(
      (task) => _filter == 'todas' ? true : task['status'] == _filter,
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Tarefas · $companyName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: _showSearchDialog,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981),
              Color(0xFF059669),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.4, 0.8],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 80),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 20),
              Expanded(
                child: filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  return AnimatedContainer(
                                    duration: Duration(milliseconds: 300 + index * 100),
                                    curve: Curves.easeOut,
                                    child: _buildTaskCard(task, index),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabController.value,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              onPressed: _addTask,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nova Tarefa'),
              elevation: 4,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((t) => t['status'] == 'concluída').length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso Geral',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Concluídas: $completedTasks',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Total: $totalTasks',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('todas', 'Todas', const Color(0xFF64748B)),
          const SizedBox(width: 8),
          _buildFilterChip('pendente', 'Pendentes', const Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          _buildFilterChip('em curso', 'Em Curso', const Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          _buildFilterChip('concluída', 'Concluídas', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, Color color) {
    final selected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF64748B),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      side: BorderSide(
        color: selected ? color : const Color(0xFFE2E8F0),
        width: selected ? 2 : 1,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, int index) {
    final status = task['status'] as String;
    final priority = task['priority'] as String;
    
    final statusConfig = {
      'pendente': {'color': const Color(0xFFF59E0B), 'icon': Icons.schedule_outlined},
      'em curso': {'color': const Color(0xFF3B82F6), 'icon': Icons.play_circle_outline},
      'concluída': {'color': const Color(0xFF10B981), 'icon': Icons.check_circle_outline},
    }[status] as Map<String, dynamic>;

    final priorityConfig = {
      'alta': {'color': const Color(0xFFEF4444), 'indicator': ''},
      'media': {'color': const Color(0xFFF59E0B), 'indicator': ''},
      'baixa': {'color': const Color(0xFF10B981), 'indicator': ''},
    }[priority] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openTask(task),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: priorityConfig['color'] as Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (statusConfig['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    statusConfig['icon'] as IconData,
                    color: statusConfig['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task['description'] ?? 'Sem descrição',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (statusConfig['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusConfig['color'] as Color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task['due'] as String,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.task_alt_outlined,
              size: 60,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _filter == 'todas' ? 'Nenhuma tarefa encontrada' : 'Nenhuma tarefa ${_filter} encontrada',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque no botão + para adicionar uma nova tarefa',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pesquisar Tarefas'),
        content: const Text('Funcionalidade de pesquisa será implementada em breve'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addTask() {
    setState(() {
      _fabController.reverse().then((_) {
        _fabController.forward();
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Implementar adição de tarefas em breve'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openTask(Map<String, dynamic> task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrir: ${task['title']}'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}