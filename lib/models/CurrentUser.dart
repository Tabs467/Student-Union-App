// Model for the currently logged-in user
class CurrentUser {

  final String uid;
  final String email;
  final String name;
  final String teamName;
  final int wins;
  final bool admin;

  CurrentUser(
      {required this.uid,
      required this.email,
      required this.name,
      required this.teamName,
      required this.wins,
      required this.admin});

}
