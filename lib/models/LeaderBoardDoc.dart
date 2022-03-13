// Model for the singleton Leaderboard document in each leaderboard collection
class LeaderboardDoc {

  String? id;
  int? currentSeason;
  List<dynamic>? prizes = [];

  LeaderboardDoc({
    this.id,
    this.currentSeason,
    this.prizes
  });

}