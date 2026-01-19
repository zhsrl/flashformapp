import 'dart:convert';
import 'package:flashform_app/data/model/form_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateFormScreen extends StatefulWidget {
  const CreateFormScreen({Key? key}) : super(key: key);

  @override
  State<CreateFormScreen> createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends State<CreateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();

  String _theme = 'light';
  final List<FormFields> _fields = [];
  bool _isLoading = false;

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _slugController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _addField() {
    showDialog(
      context: context,
      builder: (context) {
        String fieldLabel = '';
        String fieldType = 'text';

        return AlertDialog(
          title: const Text('Добавить поле'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Название поля',
                  hintText: 'Например: Ваше имя',
                ),
                onChanged: (value) => fieldLabel = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: fieldType,
                decoration: const InputDecoration(labelText: 'Тип поля'),
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Текст')),
                  DropdownMenuItem(value: 'phone', child: Text('Телефон')),
                ],
                onChanged: (value) {
                  if (value != null) fieldType = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (fieldLabel.isNotEmpty) {
                  setState(() {
                    _fields.add(
                      FormFields(
                        label: fieldLabel,
                        type: fieldType,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  Future<void> _publishForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добавьте хотя бы одно поле в форму'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      // КРИТИЧНО: Используем правильную кодировку для кириллицы
      final slug = _slugController.text.trim();
      final title = _titleController.text.trim();
      final subtitle = _subtitleController.text.trim();

      // Создаем JSON вручную, чтобы гарантировать UTF-8
      final fieldsData = _fields
          .map(
            (f) => {
              'type': f.type,
              'label': f.label,
            },
          )
          .toList();

      // Создаем payload с явным указанием типов
      final Map<String, dynamic> payload = {
        'user_id': user.id,
        'slug': slug,
        'title': title,
        'subtitle': subtitle,
        'theme': _theme,
        'fields': fieldsData,
        'is_active': true,
      };

      print('Отправляем данные:');
      print(jsonEncode(payload, toEncodable: (e) => e));

      // Отправляем в Supabase
      final response = await _supabase
          .from('forms')
          .insert(payload)
          .select()
          .single();

      print('Ответ от Supabase:');
      print(response);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Форма опубликована!\nURL: https://bilgviofjcaoxeruzita.supabase.co/functions/v1/flashform-function?slug=$slug',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Открыть',
            textColor: Colors.white,
            onPressed: () {
              // Здесь можно добавить открытие URL в браузере
            },
          ),
        ),
      );

      // Очистка формы после успешной публикации
      _slugController.clear();
      _titleController.clear();
      _subtitleController.clear();
      setState(() {
        _fields.clear();
        _theme = 'light';
      });
    } catch (e) {
      print('Ошибка: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при публикации: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать форму'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Slug (URL)
              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(
                  labelText: 'URL формы (slug)',
                  hintText: 'myshop',
                  helperText: 'Только латинские буквы, цифры и дефис',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите URL';
                  }
                  if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                    return 'Только строчные латинские буквы, цифры и дефис';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Заголовок
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  hintText: 'Закажите наш продукт',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите заголовок';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Подзаголовок
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Подзаголовок',
                  hintText: 'Заполните форму и мы свяжемся с вами',
                  prefixIcon: Icon(Icons.subtitles),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Тема
              Row(
                children: [
                  const Icon(Icons.palette),
                  const SizedBox(width: 16),
                  const Text('Тема:', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'light',
                        label: Text('Светлая'),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: 'dark',
                        label: Text('Темная'),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: {_theme},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _theme = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Поля формы
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Поля формы:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addField,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить поле'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Список полей
              if (_fields.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Нет полей. Нажмите "Добавить поле"',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _fields.length,
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          field.type == 'phone'
                              ? Icons.phone
                              : Icons.text_fields,
                        ),
                        title: Text(field.label),
                        subtitle: Text(
                          field.type == 'phone' ? 'Телефон' : 'Текст',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeField(index),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),

              // Кнопка публикации
              ElevatedButton(
                onPressed: _isLoading ? null : _publishForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Опубликовать',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
