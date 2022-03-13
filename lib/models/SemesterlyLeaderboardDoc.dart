import 'LeaderBoardDoc.dart';

// Model for the singleton Semesterly Leaderboard document in
// the SemesterlyLeaderboardEntries collection
class SemesterlyLeaderboardDoc extends LeaderboardDoc {

  SemesterlyLeaderboardDoc({id, currentSeason, prizes})
      : super(
      id: id,
      currentSeason: currentSeason,
      prizes: prizes);

}
