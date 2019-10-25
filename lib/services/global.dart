import 'package:listassist/models/User.dart';
import 'package:scoped_model/scoped_model.dart';

class GlobalService extends Model {
  User _user = new User();

  User get user => _user;

  void setUser(User newUser) {
    _user = newUser;
    print(_user.displayName);
    notifyListeners();
  }

//  static GlobalService of(BuildContext context) => ScopedModel.of<GlobalService>(context);
}


final globalService = GlobalService();