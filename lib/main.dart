import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todolist/item_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  //const MainPage({ Key? key }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String input = "";
  TextEditingController addtodos = TextEditingController();
  TextEditingController editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("To Do List"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      title: Text("Add To Do List"),
                      content: TextField(
                        controller: addtodos,
                        onChanged: (String value) {
                          input = value;
                        },
                      ),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                //todos.add(input);
                                users.add({'title': addtodos.text});
                              });
                              addtodos.text = "";
                              Navigator.pop(context);
                            },
                            child: Text("Add"))
                      ],
                    );
                  });
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          body: ListView(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: users.snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                          children: snapshot.data.docs
                              .map((e) => ItemCard(
                                    e.data()['title'],
                                    onDelete: () {
                                      users.doc(e.id).delete();
                                    },
                                    onUpdate: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Edit List"),
                                              content: TextField(
                                                controller: editController,
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        users.doc(e.id).update({
                                                          'title':
                                                              editController
                                                                  .text
                                                        });
                                                      });
                                                      editController.text = "";
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Update"))
                                              ],
                                            );
                                          });
                                    },
                                  ))
                              .toList());
                    } else {
                      return Text("Loading");
                    }
                  })
            ],
          )),
    );
  }
}
