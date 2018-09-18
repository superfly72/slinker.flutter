import 'package:flutter/material.dart';
import 'package:flutter_app/Blackbook.dart';
import 'package:flutter_app/Slink.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class BlackbookItemList extends StatefulWidget{

  final Blackbook blackbook;

  BlackbookItemList(Blackbook blackbook)
      : blackbook = blackbook,
        super(key: new ObjectKey(blackbook));

  @override
  BlackbookItemState createState() {
    return new BlackbookItemState(blackbook);
  }
}

class BlackbookItemState extends State<BlackbookItemList> {

  final Blackbook blackbook;

  BlackbookItemState(this.blackbook);


  @override
  Widget build(BuildContext context) {
    return new ListTile(
        onTap:null,
        leading: new CircleAvatar(
          backgroundColor: Colors.blue
        ),
        title: new Row(
          children: <Widget>[
            new Expanded(child: new Text(blackbook.name)),
            new Checkbox(value: blackbook.isCheck, onChanged: (bool value) {
              setState(() {
                blackbook.isCheck = value;
              });
            })
          ],
        )
    );
  }
}

class BlackbookList extends StatefulWidget {
  BlackbookList({Key key, this.blackbookList}) :super(key: key);

  List<Blackbook> blackbookList;

  @override
  _BlackbookListState createState() {
    return new _BlackbookListState();
  }
}

class _BlackbookListState extends State<BlackbookList> {

  String slinker_url = 'https://www.slinker.link/slink/';
  String bearer_token = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Ik56azVNREl5TVRnNFJqWTBORGswT0VJM1JrRXpORGN4UmtVMU1FWXdNemczT1VKQlFqRTBNZyJ9.eyJuaWNrbmFtZSI6InN1cGVyZmx5NzIiLCJuYW1lIjoic3VwZXJmbHk3MiIsInBpY3R1cmUiOiJodHRwczovL2F2YXRhcnMzLmdpdGh1YnVzZXJjb250ZW50LmNvbS91LzkzNjUyOTg_dj00IiwidXBkYXRlZF9hdCI6IjIwMTgtMDktMTNUMTE6NDU6NDkuNDMzWiIsImVtYWlsIjoicm95aGVubGV5QGhvdG1haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzcyI6Imh0dHBzOi8vc2VydmVybGVzc2luYy5hdXRoMC5jb20vIiwic3ViIjoiZ2l0aHVifDkzNjUyOTgiLCJhdWQiOiJFNFp4cUQ5ak9Kc3JFZXRUUTYwTzF6ellYTURoT2U3dyIsImlhdCI6MTUzNjgzOTE0OSwiZXhwIjoxNTM2ODc1MTQ5LCJhdF9oYXNoIjoiN1N1dUJ5dV9HM0JhUVp5eHdXbGVQUSIsIm5vbmNlIjoiay1tSGljQXJDUVJhMEZRR2N0RXIzMkF6TlRSNWtyd3AifQ.Wxf-V22f2puawAvpVw_3G5JtzjyTyjLAso2D0w8yVx07UNlmrrfuth5Ein7UkhW-wH4GlIF61FCN31OR9XUj4NSr9hQKeiZ8mtvZOx5ueaYCCz8WRMExWBV6BDAuHdsl1jxdX-qu246SWPsxsHOmNDcbloqum_1P74U6C55NYOKQlxKCMkFiAB4gF8ja4vszRRaICDhv6TpeIra4EWNXGcPS2wFka7kpMGdbsPAd9YoHmyFNyfz2jzgvLyi9bnGukSZ-K7hXztQhb6tONjH4uhyaDFjC7YtXQ8uGXpakwApGucnS1NOhP7ThmsGwitdjfomLJuflcWjRL1G7xEh4LA';
  String content_type = 'application/json';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Blackbook List"),
        ),
        body: new Container(
          padding: new EdgeInsets.all(8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              new Expanded(child: new ListView(
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                children: widget.blackbookList.map((Blackbook blackbook) {
                  return new BlackbookItemList(blackbook);
                }).toList(),
              )),
              new RaisedButton(
                child: new Text('Slink it!'),
                onPressed: slinkIt,
              ),

            ],
          ),
        )
    );
  }


  Future<Slink> slinkIt() async {

    List<Blackbook> _selectedBlackbooks = widget.blackbookList.where((bb) => bb.isCheck).toList();
    String post_body = jsonEncode({ 'intent': 'BLACKBOOK', 'payload' : { 'blackbooks' :[ _selectedBlackbooks.map((bb) => bb.name).toList() ]} });

    final response =
      await http.post(slinker_url,
        headers: {
          'authorization' : bearer_token,
          'Content-Type': content_type
        },

        body: post_body
      );

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      //Slink response = Slink.fromJson(json.decode(response.body));


      Slink s =  Slink.fromJson(json.decode(response.body));
      _showDialog(response);
      return s;
    } else {
      // If that call was not successful, throw an error.
      _showDialog(response);
      throw Exception('Failed to save slink data');
    }
  }

  // user defined function
  void _showDialog(http.Response response) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Code " + response.statusCode.toString()),
          content: new Text("Message " + response.body),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}

void main() {
  runApp(new MaterialApp(
    title: 'Demo App',
    home: new BlackbookList(blackbookList:
        [
          new Blackbook('Winx',false),
          new Blackbook('Red Rum',false),
          new Blackbook('PharLap',false),
          new Blackbook('Black Beauty',false),
          new Blackbook('Seabiscuit',false),
          new Blackbook('Black Caviar',false)
        ],),
  ));
}

