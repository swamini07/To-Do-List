import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'create_todo_screen.dart';
import 'db.helper.dart';
import 'todo_item.dart';

class ToDoListScreen extends StatefulWidget {
  final String username;
  const ToDoListScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<ToDoItem> todos = [];
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final data = await dbHelper.getAllTodos();
      print("Loaded Todos: ${data.length}");
    setState(() => todos = data);
  }

  Future<void> _addToDoItem(ToDoItem item) async {
    await dbHelper.insert(item);
    await _loadTodos();
  }

  Future<void> _editToDoItem(int index, ToDoItem newItem) async {
    if (todos[index].id != null) {
      newItem.id = todos[index].id;
      await dbHelper.update(todos[index].id!, newItem);
      await _loadTodos();
    }
  }

  Future<void> _deleteToDoItem(int index) async {
    if (todos[index].id != null) {
      await dbHelper.delete(todos[index].id!);
      await _loadTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Good morning\n${widget.username}',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text('CREATE TO DO LIST', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        itemCount: todos.length,
                        itemBuilder: (context, index) => Slidable(
                          key: ValueKey(todos[index].id),
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  final updatedItem = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateToDoScreen(item: todos[index]),
                                    ),
                                  );
                                  if (updatedItem != null && updatedItem is ToDoItem) {
                                    await _editToDoItem(index, updatedItem);
                                  }
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                              SlidableAction(
                                onPressed: (_) => _deleteToDoItem(index),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 4,
                            color: Colors.deepPurple.shade50,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                child: Icon(Icons.image),
                              ),
                              title: Text(todos[index].title, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(todos[index].description),
                                  SizedBox(height: 4),
                                  Text(todos[index].date, style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateToDoScreen()),
          );
          if (result != null && result is ToDoItem) {
            await _addToDoItem(result);
          }
        },
      ),
    );
  }
}
