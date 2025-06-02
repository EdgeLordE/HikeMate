class User{
  static int _id = 0;
  static String _firstName = "";
  static String _lastName = "";
  static String _username = "";

  static int get id => _id;
  static String get firstName => _firstName;
  static String get lastName => _lastName;
  static String get username => _username;

  static set id(int value) => _id = value;
  static set firstName(String value) => _firstName = value;
  static set lastName(String value) => _lastName = value;
  static set username(String value) => _username = value;

  static void setUser(int id, String firstName, String lastName, String username) {
    User._id = id;
    User._firstName = firstName;
    User._lastName = lastName;
    User._username = username;
  }

  static void clearUser() {
    _id = 0;
    _firstName = "";
    _lastName = "";
    _username = "";
  }


}