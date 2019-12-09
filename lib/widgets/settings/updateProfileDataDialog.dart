import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/widgets/settings/reauthenticate_form.dart';
import 'package:listassist/widgets/settings/update_email_view.dart';
class UpdateProfileDataDialog {

  showLoginDialog(context, FirebaseUser firebaseUser, User user){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Einloggen"),
          content: ReauthenticateForm(firebaseUser, user)
        );
      }
    );
  }

  showUpdateEmailDialog(context, FirebaseUser user){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Email ändern"),
              content: UpdateEmailView(user)
          );
        }
    );
  }
}
