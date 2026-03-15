enum SidebarTab {
  status,
  files,
  branches,
  commits,
  stash;

  String get label {
    switch (this) {
      case SidebarTab.status:
        return 'Status';
      case SidebarTab.files:
        return 'Files';
      case SidebarTab.branches:
        return 'Branches';
      case SidebarTab.commits:
        return 'Commits';
      case SidebarTab.stash:
        return 'Stash';
    }
  }

  String get shortcut {
    switch (this) {
      case SidebarTab.status:
        return '1';
      case SidebarTab.files:
        return '2';
      case SidebarTab.branches:
        return '3';
      case SidebarTab.commits:
        return '4';
      case SidebarTab.stash:
        return '5';
    }
  }
}

class UiState {
  final SidebarTab activeTab;
  final bool showCommandLog;
  final bool showHelp;
  final String? searchQuery;
  final bool isPopupOpen;
  final String? popupId;
  final int sidebarWidthPercent;
  final String? statusMessage;
  final String? errorMessage;

  const UiState({
    this.activeTab = SidebarTab.files,
    this.showCommandLog = false,
    this.showHelp = false,
    this.searchQuery,
    this.isPopupOpen = false,
    this.popupId,
    this.sidebarWidthPercent = 40,
    this.statusMessage,
    this.errorMessage,
  });

  UiState copyWith({
    SidebarTab? activeTab,
    bool? showCommandLog,
    bool? showHelp,
    String? searchQuery,
    bool? isPopupOpen,
    String? popupId,
    int? sidebarWidthPercent,
    String? statusMessage,
    String? errorMessage,
    bool clearSearch = false,
    bool clearPopup = false,
    bool clearStatus = false,
    bool clearError = false,
  }) {
    return UiState(
      activeTab: activeTab ?? this.activeTab,
      showCommandLog: showCommandLog ?? this.showCommandLog,
      showHelp: showHelp ?? this.showHelp,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      isPopupOpen: isPopupOpen ?? this.isPopupOpen,
      popupId: clearPopup ? null : (popupId ?? this.popupId),
      sidebarWidthPercent: sidebarWidthPercent ?? this.sidebarWidthPercent,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
