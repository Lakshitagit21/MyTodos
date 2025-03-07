import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //get box
  final myBox = Hive.box("My_Box");

  final _controller = TextEditingController();
  TodoPriority priority = TodoPriority.Normal;

  @override
  void initState() {
    //load data, if none exists then normal view

    //type cast here as it is not dynamic
    MyTodo.todos = (myBox.get("Todo_List") as List?)?.cast<MyTodo>() ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addTodo();
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          title: Text(
            "My ToDos",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: MyTodo.todos.isEmpty
            ? Center(
                child: Text("Nothing to do!"),
              )
            : buildListView());
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: MyTodo.todos.length,
      itemBuilder: (context, index) {
        final todo = MyTodo.todos[index];
        return TodoItem(
            todo: todo,
            onChanged: (value) {
              setState(() {
                //MyTodo.todos[index].completed = value;
                if (value == true) {
                  MyTodo.todos.removeAt(index);
                  saveToDatabase();
                } else {
                  MyTodo.todos[index].completed = value;
                }
              });
            });
      },
    );
  }

  //save to database
  void saveToDatabase() {
    myBox.put("Todo_List", MyTodo.todos);
  }

  void addTodo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBuilderState) => FractionallySizedBox(
            heightFactor: 0.75, // 3/4 of the screen height
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'What to do?'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Select your Priority"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<TodoPriority>(
                          value: TodoPriority.Low,
                          groupValue: priority,
                          onChanged: (value) {
                            setBuilderState(() {
                              priority = value!;
                            });
                          }),
                      Text(TodoPriority.Low.name),
                      Radio<TodoPriority>(
                          value: TodoPriority.Normal,
                          groupValue: priority,
                          onChanged: (value) {
                            setBuilderState(() {
                              priority = value!;
                            });
                          }),
                      Text(TodoPriority.Normal.name),
                      Radio<TodoPriority>(
                          value: TodoPriority.High,
                          groupValue: priority,
                          onChanged: (value) {
                            setBuilderState(() {
                              priority = value!;
                            });
                          }),
                      Text(TodoPriority.High.name),
                    ],
                  ),
                  ElevatedButton(onPressed: _save, child: Text("SAVE"))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _save() {
    if (_controller.text.isEmpty) {
      showMsg(context, 'Input field must not be empty!');
      return;
    }

    final todo = MyTodo(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _controller.text,
        priority: priority);

    MyTodo.todos.add(todo);
    _controller.clear();
    setState(() {});
    Navigator.pop(context);
    saveToDatabase();
  }
}

void showMsg(BuildContext context, String s) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Caution!"),
            content: Text(s),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CLOSE')),
            ],
          ));
}

class TodoItem extends StatelessWidget {
  final MyTodo todo;
  final Function(bool) onChanged;

  const TodoItem({super.key, required this.todo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        title: Text(todo.name),
        subtitle: Text("Priority: ${todo.priority.name}"),
        value: todo.completed,
        onChanged: (value) {
          onChanged(value!);
        });
  }
}

@HiveType(typeId: 0) // Assign a unique type ID
class MyTodo {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  TodoPriority priority;

  MyTodo({
    required this.id,
    required this.name,
    this.completed = false,
    required this.priority,
  });

  static List<MyTodo> todos = [];
}

@HiveType(typeId: 1) // Unique type ID for enum
enum TodoPriority {
  @HiveField(0)
  Low,
  @HiveField(1)
  Normal,
  @HiveField(2)
  High
}
//enum TodoPriority { Low, Normal, High }

class MyTodoAdapter extends TypeAdapter<MyTodo> {
  @override
  final int typeId = 0;

  @override
  MyTodo read(BinaryReader reader) {
    return MyTodo(
      id: reader.readInt(),
      name: reader.readString(),
      completed: reader.readBool(),
      priority: TodoPriority.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, MyTodo obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeBool(obj.completed);
    writer.writeInt(obj.priority.index);
  }
}

class TodoPriorityAdapter extends TypeAdapter<TodoPriority> {
  @override
  final int typeId = 1;

  @override
  TodoPriority read(BinaryReader reader) {
    return TodoPriority.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, TodoPriority obj) {
    writer.writeInt(obj.index);
  }
}