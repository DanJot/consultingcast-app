import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/company.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import 'main_navigation.dart';

class CompanySelectionPage extends StatefulWidget {
  final User user;

  const CompanySelectionPage({super.key, required this.user});

  @override
  State<CompanySelectionPage> createState() => _CompanySelectionPageState();
}

class _CompanySelectionPageState extends State<CompanySelectionPage> with TickerProviderStateMixin {
  Company? _selectedCompany;
  bool _isLoadingCompanies = true;
  List<Company> _companies = [];
  List<Company> _filteredCompanies = [];
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

	final AuthService _authService = AuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    _loadUserCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ⚠️ AQUI ESTÁ A MUDANÇA IMPORTANTE:
  // Em vez de chamar um método que ia direto ao MySQL,
  // passamos SEMPRE pelo AuthService.getUserCompanies.
  // No Web, isso usa a API /companies. No Android/Desktop usa MySQL como antes.
  Future<void> _loadUserCompanies() async {
    try {
      setState(() {
        _isLoadingCompanies = true;
        _errorMessage = null;
      });

      final companies = await _authService.getUserCompanies(widget.user.id);

      if (mounted) {
        setState(() {
          _companies = companies;
          _filteredCompanies = companies;
          _isLoadingCompanies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar empresas: $e';
          _isLoadingCompanies = false;
        });
      }
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
          title: const Text(
            'Selecionar Empresa',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Terminar sessão',
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Terminar sessão'),
                    content: const Text('Deseja terminar a sessão e voltar ao login?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWelcomeSectionMinimal(),
                        const SizedBox(height: 16),
                        _buildContent(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: null,
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Center(
        child: Text(
          'Selecione a empresa para continuar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSectionMinimal() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.12),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Text(
                widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(183, 49, 112, 126)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bem-vindo,', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                Text(
                  widget.user.name.isNotEmpty ? widget.user.name : 'Utilizador',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0B1F2A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingCompanies) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_companies.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildCompanyList();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
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
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'A carregar empresas...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFFEF4444),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Ocorreu um erro.',
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadUserCompanies,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: const [
          SizedBox(height: 16),
          Icon(Icons.business_outlined, color: Color(0xFFF59E0B), size: 48),
          SizedBox(height: 16),
          Text(
            'Nenhuma empresa encontrada',
            style: TextStyle(
              color: Color(0xFFF59E0B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Contacte o administrador para associar empresas à sua conta.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyList() {
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildResultCount(),
        const SizedBox(height: 12),
        if (_filteredCompanies.isEmpty)
          _buildNoResultsState()
        else ...[
          if (_selectedCompany == null) ...[
            _buildCompanyCard(_filteredCompanies.first),
            const SizedBox(height: 8),
            _buildInstructionBanner(),
            const SizedBox(height: 8),
            if (_filteredCompanies.length > 1)
              Column(
                children: _filteredCompanies
                    .sublist(1)
                    .map((c) => _buildCompanyCard(c))
                    .toList(),
              ),
          ] else
            _buildCompanyCards(),
        ],
        const SizedBox(height: 12),
        if (_selectedCompany != null)
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _continueToApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continuar'),
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar empresa por nome, NIF ou descrição...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.search,
              color: Color.fromARGB(183, 49, 112, 126),
              size: 20,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.clear,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_off,
              color: Color(0xFF64748B),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Sem resultados' : "Sem resultados para '$_searchQuery'",
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente pesquisar por nome da empresa, NIF ou descrição',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCards() {
    return Column(
      children: _filteredCompanies.map((company) => _buildCompanyCard(company)).toList(),
    );
  }

  Widget _buildCompanyCard(Company company) {
    final isSelected = _selectedCompany?.id == company.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF0891B2).withOpacity(0.5)
              : const Color(0xFFE2E8F0).withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF0891B2).withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedCompany = company;
            });
            HapticFeedback.selectionClick();
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0891B2).withOpacity(0.20)
                        : const Color(0xFFF8FAFC).withOpacity(0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0891B2).withOpacity(0.30)
                          : const Color(0xFFE2E8F0).withOpacity(0.60),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.business_rounded,
                    color: isSelected ? const Color(0xFF0891B2) : const Color(0xFF64748B),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0891B2).withOpacity(0.25),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF0891B2)),
                              SizedBox(width: 10),
                              Text(
                                'Selecionada',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0891B2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        company.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? const Color(0xFF0891B2) : const Color(0xFF1E293B),
                          fontSize: 19,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        company.description,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64748B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NIF: ${company.nif}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF0891B2) : Colors.grey.withOpacity(0.2),
                    border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCount() {
    final total = _filteredCompanies.length;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0891B2).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          total == 1 ? '1 empresa encontrada' : '$total empresas encontradas',
          style: const TextStyle(
            color: Color(0xFF0891B2),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCompanies = List<Company>.from(_companies);
      } else {
        final normalizedQuery = _normalize(query);
        _filteredCompanies = _companies.where((c) {
          final name = _normalize(c.name.toLowerCase());
          final desc = _normalize(c.description.toLowerCase());
          final nif = c.nif.toLowerCase();
          return name.contains(normalizedQuery) || desc.contains(normalizedQuery) || nif.contains(query);
        }).toList();
      }
    });
  }

  String _normalize(String input) {
    return input
        .replaceAll(RegExp('[áàâãäÁÀÂÃÄ]'), 'a')
        .replaceAll(RegExp('[éêèëÉÊÈË]'), 'e')
        .replaceAll(RegExp('[íìîïÍÌÎÏ]'), 'i')
        .replaceAll(RegExp('[óòôõöÓÒÔÕÖ]'), 'o')
        .replaceAll(RegExp('[úùûüÚÙÛÜ]'), 'u')
        .replaceAll(RegExp('[çÇ]'), 'c');
  }

  Future<void> _continueToApp() async {
    if (_selectedCompany == null) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainNavigation(
          user: widget.user,
          initialIndex: 0,
          selectedCompany: _selectedCompany!,
        ),
      ),
    );
  }
}
