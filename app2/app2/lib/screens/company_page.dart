import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/company.dart';
import 'company_selection_page.dart';
import 'funcionarios_page.dart';
import 'document_management_page.dart';
import '../services/database_manager.dart';

class CompanyPage extends StatefulWidget {
  final User user;
  final Company? selectedCompany;

  const CompanyPage({super.key, required this.user, this.selectedCompany});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _salesData = [];
  List<Map<String, dynamic>> _yearlySalesData = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _fetchSalesData();
    _fetchYearlySalesData();
  }

  Widget _buildSalesEvolutionCard() {
    final currentSales = _salesData.isNotEmpty ? (_salesData[0]['vendas_ac'] as double? ?? 0.0) : 0.0;
    final previousSales = _salesData.length > 1 ? (_salesData[1]['vendas_ac'] as double? ?? 0.0) : 0.0;
    final previousYearSales = _salesData.isNotEmpty ? (_salesData[0]['vendas_n_1'] as double? ?? 0.0) : 0.0;
    final growth = previousSales > 0 ? ((currentSales - previousSales) / previousSales) * 100 : 0.0;
    final goalProgress = previousYearSales > 0 ? (currentSales / previousYearSales).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Evolução de Vendas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: goalProgress,
                        strokeWidth: 12,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation(const Color(0xFF0EA5E9)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${(goalProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0EA5E9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'vs Ano Anterior',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (previousYearSales > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        previousYearSales >= 1000000
                            ? 'Meta: €${(previousYearSales / 1000000).toStringAsFixed(1)}M'
                            : 'Meta: €${(previousYearSales / 1000).toStringAsFixed(0)}K',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSalesMetric('Este Mês', '€${currentSales.toStringAsFixed(2).replaceAll('.00', '')}', const Color(0xFF10B981)),
                    const SizedBox(height: 16),
                    _buildSalesMetric('Mês Anterior', '€${previousSales.toStringAsFixed(2).replaceAll('.00', '')}', const Color(0xFFEF4444)),
                    const SizedBox(height: 16),
                    _buildSalesMetric('Ano Anterior (N-1)', '€${previousYearSales.toStringAsFixed(2).replaceAll('.00', '')}', const Color(0xFF0EA5E9)),
                    const SizedBox(height: 16),
                    _buildSalesMetric('Crescimento (MoM)', '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%', growth >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFBAE6FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.apartment, color: Color(0xFF0284C7), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedCompany?.name ?? 'ConsultingCast',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'NIF: ${widget.selectedCompany?.nif ?? 'N/A'}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchSalesData() async {
    if (widget.selectedCompany == null) return;
    final dbName = widget.selectedCompany!.id.startsWith('_')
        ? widget.selectedCompany!.id
        : '_${widget.selectedCompany!.id}';
    try {
      final DatabaseService conn = DatabaseManager.getConnection(dbName);
      // Prefer snapshot; fallback to list
      try {
        final snap = await conn.getSalesSnapshot();
        if (mounted) {
          setState(() {
            _salesData = [
              {
                'vendas_ac': (snap['current'] as double?) ?? 0.0,
                'vendas_n_1': (snap['prevYear'] as double?) ?? 0.0,
              },
              {
                'vendas_ac': (snap['prevMonth'] as double?) ?? 0.0,
              }
            ];
          });
        }
        return;
      } catch (_) {}

      final data = await conn.getSalesResults();
      if (mounted) setState(() { _salesData = data; });
    } catch (e) {
      debugPrint('Erro ao carregar vendas: $e');
    }
  }

  Future<void> _fetchYearlySalesData() async {
    if (widget.selectedCompany == null) return;
    final dbName = widget.selectedCompany!.id.startsWith('_')
        ? widget.selectedCompany!.id
        : '_${widget.selectedCompany!.id}';
    try {
      final DatabaseService conn = DatabaseManager.getConnection(dbName);
      final data = await conn.getYearlySales();
      if (mounted) setState(() { _yearlySalesData = data; });
    } catch (e) {
      debugPrint('Erro ao carregar vendas anuais: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0FDFA),
            Color(0xFFF0F9FF),
            Color(0xFFFAFBFC),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(183, 49, 112, 126),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _openCompanyDetails(context),
          ),
          title: const Text(
            'Minha Empresa',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
              IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _fetchSalesData();
                _fetchYearlySalesData();
              },
              tooltip: 'Atualizar informação',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMiniCompanyCard(),
                  const SizedBox(height: 20),
                  _buildYearlySalesChart(),
                  const SizedBox(height: 20),
                  _buildSalesEvolutionCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Gestão Empresarial'),
                  const SizedBox(height: 16),
                  _buildManagementOptions(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Relatórios e Análises'),
                  const SizedBox(height: 16),
                  _buildReportOptions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildYearlySalesChart() {
    if (_yearlySalesData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = _yearlySalesData
        .map((e) => (e['vendas_ac'] as double? ?? 0.0))
        .fold(0.0, (a, b) => a > b ? a : b);

    final monthLabels = ['Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart, color: Color(0xFF0284C7), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Últimos 6 Meses 2024',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 210,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _yearlySalesData.asMap().entries.map((entry) {
                final vendas = (entry.value['vendas_ac'] as double? ?? 0.0);
                final height = maxValue > 0 ? (vendas / maxValue) * 150 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Valor acima da barra
                        if (vendas > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              vendas >= 1000000
                                  ? '${(vendas / 1000000).toStringAsFixed(1)}M'
                                  : vendas >= 1000
                                      ? '${(vendas / 1000).toStringAsFixed(0)}K'
                                      : vendas.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          height: height.clamp(2.0, 150.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFF0EA5E9), Color(0xFF7DD3FC)],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthLabels[entry.key],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildManagementOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                'RH',
                'Funcionários e equipas',
                Icons.groups_outlined,
                const Color(0xFF10B981),
                () => _openFuncionarios(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                'Gestão Documental',
                'Uploads e digitalizações',
                Icons.folder_copy_outlined,
                const Color(0xFF0EA5E9),
                () => _openDocumentos(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                'Contratos',
                'Documentos legais',
                Icons.description_outlined,
                const Color(0xFF059669),
                () => _showSnackBar('Contratos'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                'Configurações',
                'Definições empresa',
                Icons.settings_outlined,
                const Color(0xFF8B5CF6),
                () => _showSnackBar('Configurações'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                'Relatórios',
                'Análises e métricas',
                Icons.analytics_outlined,
                const Color(0xFF06B6D4),
                () => _showSnackBar('Relatórios'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                'Dashboard',
                'Painel principal',
                Icons.dashboard_outlined,
                const Color(0xFF6366F1),
                () => _showSnackBar('Dashboard'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                'Exportação',
                'Dados da empresa',
                Icons.file_download_outlined,
                const Color(0xFF64748B),
                () => _showSnackBar('Exportação'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          const Text(
            'Info',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajuda',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openFuncionarios() {
    if (widget.selectedCompany == null) {
      _showSnackBar('Selecione uma empresa');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FuncionariosPage(company: widget.selectedCompany!),
      ),
    );
  }

  void _openDocumentos() {
    if (widget.selectedCompany == null) {
      _showSnackBar('Selecione uma empresa');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentManagementPage(company: widget.selectedCompany!),
      ),
    );
  }

  void _changeCompany(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mudar de Empresa'),
          content: const Text('Tem a certeza que deseja mudar de empresa?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => CompanySelectionPage(user: widget.user),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Mudar'),
            ),
          ],
        );
      },
    );
  }

  void _openCompanyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.apartment, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedCompany?.name ?? 'ConsultingCast',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'NIF: ${widget.selectedCompany?.nif ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_circle, color: Color(0xFF0EA5E9)),
                      title: const Text('Dados da Empresa'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Color(0xFF0EA5E9)),
                      title: const Text('Atualizar Dados'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _fetchSalesData();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.swap_horiz, color: Color(0xFF0EA5E9)),
                      title: const Text('Mudar de Empresa'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _changeCompany(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Sair'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}