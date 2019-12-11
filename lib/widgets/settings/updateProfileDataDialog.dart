import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/widgets/settings/reauthenticate_form.dart';
import 'package:listassist/widgets/settings/update_email_view.dart';
import 'package:listassist/widgets/settings/update_password_view.dart';
class UpdateProfileDataDialog {

  showLoginDialog(BuildContext context, FirebaseUser firebaseUser, User user, String mode){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Einloggen"),
          content: ReauthenticateForm(context, firebaseUser, user, mode)
        );
      }
    );
  }

  showUpdateEmailDialog(context, FirebaseUser firebaseUser){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Email ändern"),
              content: UpdateEmailView(firebaseUser)
          );
        }
    );
  }

  showUpdatePasswordDialog(context, FirebaseUser firebaseUser){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Passwort ändern"),
              content: UpdatePasswordView(firebaseUser)
          );
        }
    );
  }
}
