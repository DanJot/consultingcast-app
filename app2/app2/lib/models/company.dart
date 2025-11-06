class Company {
  final String id;
  final String name;
  final String nif;
  final String description;
  final String logoUrl;
  final bool isActive;

  const Company({
    required this.id,
    required this.name,
    required this.nif,
    required this.description,
    this.logoUrl = '',
    this.isActive = true,
  });

  // Método para criar uma empresa a partir de um Map (útil para dados da base de dados)
  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nif: map['nif'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logo_url'] ?? '',
      isActive: map['is_active'] ?? true,
    );
  }

  // Método para converter a empresa para um Map (útil para guardar na base de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nif': nif,
      'description': description,
      'logo_url': logoUrl,
      'is_active': isActive,
    };
  }

  // Método para criar uma cópia da empresa com alguns campos alterados
  Company copyWith({
    String? id,
    String? name,
    String? nif,
    String? description,
    String? logoUrl,
    bool? isActive,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      nif: nif ?? this.nif,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Company(id: $id, name: $name, nif: $nif, description: $description, logoUrl: $logoUrl, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Company &&
        other.id == id &&
        other.name == name &&
        other.nif == nif &&
        other.description == description &&
        other.logoUrl == logoUrl &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        nif.hashCode ^
        description.hashCode ^
        logoUrl.hashCode ^
        isActive.hashCode;
  }
}
