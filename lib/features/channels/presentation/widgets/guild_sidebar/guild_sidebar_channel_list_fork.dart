part of 'guild_sidebar.dart';

// Fork: keeps the channel list from staying blank. See
// ForkHiddenListWatchdog for why; this file holds the parts that need the
// list's private state.

final Expando<ForkHiddenListWatchdog> _forkHiddenListWatchdogs =
    Expando<ForkHiddenListWatchdog>('forkHiddenListWatchdog');

extension _ForkHiddenChannelListWatch on _GuildSidebarChannelListState {
  bool get _forkListHidden =>
      _needsSelectedReveal && _indicatorOrder.isNotEmpty;

  /// Called from upstream's build while the list is active.
  void _forkWatchHiddenList() {
    final ForkHiddenListWatchdog watchdog = _forkHiddenListWatchdogs[this] ??=
        ForkHiddenListWatchdog();
    watchdog.watch(
      isHidden: () => _forkListHidden,
      canRun: () => mounted && widget.isActive,
      retry: _scheduleSelectedReveal,
      onGiveUp: () {
        talker.warning(
          '[GuildSidebar] Fork: channel list was still hidden after '
          '${watchdog.maxHiddenFrames} frames waiting to reveal the selected '
          'channel; showing it anyway. ${_forkRevealDiagnostics()}',
        );
        _finishSelectedReveal();
      },
    );
  }

  String _forkRevealDiagnostics() {
    final String? channelId = ref.read(activeChannelIdProvider);
    final int positions = _scrollController.positions.length;
    final String scroll = positions == 1
        ? '${_scrollController.position.pixels.toStringAsFixed(0)}/'
              '${_scrollController.position.maxScrollExtent.toStringAsFixed(0)}'
        : 'n/a';
    return 'guild=${widget.guildId} '
        'location=${ref.read(routeStateProvider).location} '
        'channel=$channelId '
        'inOrder=${channelId != null && _indicatorOrder.contains(channelId)} '
        'entries=${_indicatorOrder.length} '
        'tile=${channelId != null && _selectedTile(channelId) != null} '
        'scrollPositions=$positions '
        'scroll=$scroll '
        'steps=$_selectedRevealSteps '
        'stepScheduled=$_selectedRevealScheduled '
        'savedOffset=${_scrollStore?.offsetFor(widget.guildId)}';
  }
}
