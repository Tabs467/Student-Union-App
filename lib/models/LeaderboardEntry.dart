// Model for a Leaderboard Entry
class LeaderboardEntry {

  String? id;
  int? seasonNumber;
  String? userID;
  int? totalWins;
  int? totalPoints;

  LeaderboardEntry({
    this.id,
    this.seasonNumber,
    this.userID,
    this.totalWins,
    this.totalPoints
  });

}