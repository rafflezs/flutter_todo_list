import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    title: "To-do List",
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _todoList = [];
  final _todoController = TextEditingController();
  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedIndex;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _todoList = json.decode(data!);
      });
    });
  }

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = {};
      newTodo["name"] = _todoController.text;
      _todoController.text = "";
      newTodo["isDone"] = false;
      _todoList.add(newTodo);
      _saveData();
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/savedData.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "To-do List",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(10, 1, 1, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: Colors.blue)),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Text("Adcionar"),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue)),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _todoList.length,
                  itemBuilder: buildItem),
            ),
          )
        ],
      ),
    );
  }

  Future<Null> _refresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _todoList.sort((a, b) {
        if (a["isDone"] && !b["isDone"]) {
          return 1;
        } else if (a["isDone"] && b["isDone"]) {
          return 0;
        } else {
          return -1;
        }
      });
      _saveData();
    });
    return null;
  }

  Widget buildItem(context, index) {
    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.startToEnd,
        background: Container(
          color: Colors.red,
          child: const Align(
            alignment: Alignment(-1, 0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(_todoList[index]);
            _lastRemovedIndex = index;
            _todoList.removeAt(index);
            _saveData();
            final snack = SnackBar(
              content: Text("Tarefa: \"${_lastRemoved["name"]}\" removida"),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _todoList.insert(_lastRemovedIndex, _lastRemoved);
                  });
                },
              ),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(snack);
          });
        },
        child: CheckboxListTile(
          title: Text(_todoList[index]["name"]),
          value: _todoList[index]["isDone"],
          secondary: CircleAvatar(
            child: Icon(_todoList[index]["isDone"] ? Icons.check : Icons.error),
          ),
          onChanged: (c) {
            setState(() {
              _todoList[index]["isDone"] = c;
              _saveData();
            });
          },
        ));
  }
}
