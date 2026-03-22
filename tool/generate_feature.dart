import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Masukkan nama fitur!');
    print('Contoh: dart run tool/generate_feature.dart siswa');
    return;
  }

  final featureName = args[0].toLowerCase();
  final basePath = 'lib/features/$featureName';

  final folders = [
    'models',
    'services',
    'providers',
    'screens',
    'widgets',
  ];

  // Create folders
  for (var folder in folders) {
    Directory('$basePath/$folder').createSync(recursive: true);
  }

  // Create files
  File('$basePath/models/${featureName}_model.dart')
      .writeAsStringSync(_modelTemplate(featureName));

  File('$basePath/services/${featureName}_service.dart')
      .writeAsStringSync(_serviceTemplate(featureName));

  File('$basePath/providers/${featureName}_provider.dart')
      .writeAsStringSync(_providerTemplate(featureName));

  File('$basePath/screens/${featureName}_screen.dart')
      .writeAsStringSync(_screenTemplate(featureName));

  File('$basePath/widgets/${featureName}_card.dart')
      .writeAsStringSync(_widgetTemplate(featureName));

  print('✅ Feature "$featureName" berhasil dibuat!');
}

String _modelTemplate(String name) {
  final className = _capitalize(name);

  return '''
class ${className}Model {
  final String? id;
  final String? nama;
  final DateTime? createdAt;

  ${className}Model({
    this.id,
    this.nama,
    this.createdAt,
  });

  factory ${className}Model.fromJson(Map<String, dynamic> json) {
    return ${className}Model(
      id: json['id']?.toString(),
      nama: json['nama'] as String?,
      createdAt: DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ${className}Model copyWith({
    String? id,
    String? nama,
    DateTime? createdAt,
  }) {
    return ${className}Model(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get label => nama ?? '-';
}
''';
}

String _serviceTemplate(String name) {
  final className = _capitalize(name);

  return '''
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/${name}_model.dart';

class ${className}Service {
  final supabase = Supabase.instance.client;

  Future<List<${className}Model>> getAll() async {
    final response = await supabase
        .from('$name')
        .select();

    return (response as List)
        .map((e) => ${className}Model.fromJson(e))
        .toList();
  }

  Future<void> create(${className}Model data) async {
    await supabase.from('$name').insert(data.toJson());
  }

  Future<void> delete(String id) async {
    await supabase.from('$name').delete().eq('id', id);
  }
}
''';
}

String _providerTemplate(String name) {
  final className = _capitalize(name);

  return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/${name}_model.dart';
import '../services/${name}_service.dart';

part '${name}_provider.g.dart';

@riverpod
class ${className}Notifier extends _\$${className}Notifier {
  final service = ${className}Service();

  @override
  Future<List<${className}Model>> build() async {
    return service.getAll();
  }

  Future<void> add(${className}Model data) async {
    await service.create(data);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await service.delete(id);
    ref.invalidateSelf();
  }
}
''';
}

String _screenTemplate(String name) {
  final className = _capitalize(name);

  return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/${name}_provider.dart';

class ${className}Screen extends ConsumerWidget {
  const ${className}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(${name}NotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('$className')),
      body: data.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.label),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: \$e')),
      ),
    );
  }
}
''';
}

String _widgetTemplate(String name) {
  final className = _capitalize(name);

  return '''
import 'package:flutter/material.dart';
import '../models/${name}_model.dart';

class ${className}Card extends StatelessWidget {
  final ${className}Model data;
  final VoidCallback? onTap;

  const ${className}Card({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(data.label),
        onTap: onTap,
      ),
    );
  }
}
''';
}

String _capitalize(String text) {
  return text[0].toUpperCase() + text.substring(1);
}