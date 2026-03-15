enum SidebarPane {
  files,
  branches,
  commits;

  String get label {
    switch (this) {
      case SidebarPane.files:
        return 'Files';
      case SidebarPane.branches:
        return 'Branches';
      case SidebarPane.commits:
        return 'Commits';
    }
  }

  String get shortcut {
    switch (this) {
      case SidebarPane.files:
        return '1';
      case SidebarPane.branches:
        return '2';
      case SidebarPane.commits:
        return '3';
    }
  }
}

class UiState {
  final SidebarPane activePane;
  final bool showCommandLog;
  final bool showHelp;
  final String? searchQuery;
  final bool isPopupOpen;
  final String? popupId;
  final int sidebarWidthPercent;
  final String? statusMessage;
  final String? errorMessage;

  const UiState({
    this.activePane = SidebarPane.files,
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
    SidebarPane? activePane,
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
      activePane: activePane ?? this.activePane,
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
