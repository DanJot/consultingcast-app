class Employee {
  final String id;
  final String name;
  final String nib;
  final bool active;
  final String? field1;
  final String? field2;
  final String? field3;
  final String? field4;
  final String? field5;

  const Employee({
    required this.id,
    required this.name,
    required this.nib,
    required this.active,
    this.field1,
    this.field2,
    this.field3,
    this.field4,
    this.field5,
  });
}


