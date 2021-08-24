import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
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

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["name"] = _todoController.text;
      _todoController.text = "";
      newTodo["isDone"] = false;
      _todoList.add(newTodo);
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
        title: Text(
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
            padding: EdgeInsets.fromLTRB(10, 1, 1, 1),
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
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(_todoList[index]["name"]),
                      value: _todoList[index]["isDone"],
                      secondary: CircleAvatar(
                        child: Icon(_todoList[index]["isDone"]
                            ? Icons.check
                            : Icons.error),
                      ),
                      onChanged: (c) {
                        setState(() {
                          _todoList[index]["isDone"] = c;
                        });
                      },
                    );
                  }))
        ],
      ),
    );
  }
}
