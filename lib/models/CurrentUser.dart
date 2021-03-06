// Model for users
class CurrentUser {
  final String uid;
  final String email;
  final String name;
  final String teamName;
  final int wins;
  final int monthlyWins;
  final int semesterlyWins;
  final int yearlyWins;
  final bool admin;
  List<dynamic>? winDates = [];
  List<dynamic>? monthlyWinDates = [];
  List<dynamic>? semesterlyWinDates = [];
  List<dynamic>? yearlyWinDates = [];

  CurrentUser(
      {required this.uid,
      required this.email,
      required this.name,
      required this.teamName,
      required this.wins,
      required this.monthlyWins,
      required this.semesterlyWins,
      required this.yearlyWins,
      required this.admin,
      required this.winDates,
      required this.monthlyWinDates,
      required this.semesterlyWinDates,
      required this.yearlyWinDates});
}
