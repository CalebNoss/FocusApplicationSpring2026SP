import '../models/focus_session.dart';

class ProgressService {

  int getTotalMinutes(List<FocusSession> sessions) {
    int total = 0;

    for (final session in sessions) {
      total += session.durationMinutes;
    }

    return total;
  }

  int getTotalSessions(List<FocusSession> sessions) {
    return sessions.length;
  }

  int getLongestSession(List<FocusSession> sessions) {
    int longest = 0;

    for (final session in sessions) {
      if (session.durationMinutes > longest) {
        longest = session.durationMinutes;
      }
    }

    return longest;
  }

}