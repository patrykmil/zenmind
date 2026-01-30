import '../datasource/reactions_remote_ds.dart';
import '../models/reaction_entry.dart';

class ReactionsRepository {
  final ReactionsRemoteDataSource remote;
  ReactionsRepository(this.remote);

  Future<void> createReaction(String userId, ReactionEntry entry) =>
      remote.createReaction(userId, entry);
}
