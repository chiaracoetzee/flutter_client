/// Fork: whether a message by the account that started a forum post gets the
/// "OP" tag.
///
/// Upstream tags every message by that account. Here the tag follows the
/// identity the post was started as: when it was started as a persona, only
/// messages sent as that persona are tagged, and when it was started as the
/// account itself, only messages sent as the account are. Another persona of
/// the same account, or the account behind a persona, is not presented as the
/// original poster.
bool forkOriginalPosterTagApplies({
  required String? messagePersonaId,
  required String? threadOwnerPersonaId,
}) {
  String? identity(String? personaId) =>
      (personaId == null || personaId.isEmpty) ? null : personaId;
  return identity(messagePersonaId) == identity(threadOwnerPersonaId);
}
