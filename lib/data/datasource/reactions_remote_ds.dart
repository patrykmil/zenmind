import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reaction_entry.dart';

class ReactionsRemoteDataSource {
  final FirebaseFirestore firestore;
  ReactionsRemoteDataSource(this.firestore);

  Future<void> createReaction(String userId, ReactionEntry entry) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('reactions')
        .doc(entry.id)
        .set(entry.toMap());
  }
}
