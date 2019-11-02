import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:provider/provider.dart';
import 'settings-modal.dart';

class ProfilesettingsView extends StatelessWidget {
  String img = "https://www.indiewire.com/wp-content/uploads/2019/05/shutterstock_8999492b.jpg?w=780";
  SettingsModal modal = new SettingsModal();

  @override
  Widget build(BuildContext context) {

    User user  = Provider.of<User>(context);

    return Scaffold(
      //backgroundColor: Colors.transparent,
        appBar: new AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () => modal.mainBottomSheet(context),
                      child:
                        Hero(
                          tag: "profilePicture",
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl),
                            radius: 50,
                          ),
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 50.0),

                    child: GestureDetector(
                        onTap: () => modal.mainBottomSheet(context),
                        child:
                      Text(
                        "Foto ändern",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        textAlign: TextAlign.center,
                      )
                    )
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child:
                      TextFormField(
                        initialValue: "Tobias Seczer",
                        decoration: InputDecoration(
                          labelText: 'Name',

                        ),
                      ),
                  ),
                  TextFormField(
                    initialValue: "tobias.seczer@gmail.com",
                    decoration: InputDecoration(
                      labelText: 'E-Mail',

                    ),
                  ),


                ])
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          child: Icon(Icons.check),
          backgroundColor: Colors.green,
        ),
    );
  }
}