import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_todo/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['id'];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        navigateToEditPage(item);
                      } else if (value == 'delete') {
                        if (id != null) {
                          deleteById(id);
                        } else {
                          print('ID inválido');
                        }
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text("Edit"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete"),
                        ),
                      ];
                    },
                  ),
                );
              }),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: const Text("Add todo")),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(int id) async {
    final newId = int.parse(id.toString());
    final url = "http://localhost:8080/api/v1/todo/$newId";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if (response.statusCode == 204) {
      final filtered = items.where((element) => element['id'] != id).toList();
      setState(() {
        items = filtered;
      });
      showSuccessMessage('Deletado com sucesso');
    } else {
      erroSuccessMessage('Falha ao deletar');
    }
    // print(response.body);
  }

  Future fetchTodo() async {
    setState(() {
      isLoading = true;
    });

    const url = 'http://localhost:8080/api/v1/todo';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = json;
      setState(() {
        items = result;
      });
      // print(response.body);
      // print(response.statusCode);
    }
    setState(() {
      isLoading = false;
    });
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void erroSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
