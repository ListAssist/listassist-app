import 'package:flutter/material.dart';

class SettingsModal{
  mainBottomSheet(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, 'Foto machen', Icons.camera_alt, _action1),
              _createTile(context, 'Galerie', Icons.photo_library, _action2),
              _createTile(context, 'Löschen', Icons.delete, _action3),
            ],
          );
        }
    );
  }

  ListTile _createTile(BuildContext context, String name, IconData icon, Function action){
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: (){
        Navigator.pop(context);
        action();
      },
    );
  }

  _action1(){
    print('Foto machen');
  }

  _action2(){
    print('Galerie');
  }

  _action3(){
    print('Löschen');
  }
}