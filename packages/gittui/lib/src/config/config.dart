class AppConfig {
  final bool showCommandLog;
  final int sidebarWidth;
  final String? defaultBranch;
  final Map<String, String> customKeybindings;

  const AppConfig({
    this.showCommandLog = false,
    this.sidebarWidth = 40,
    this.defaultBranch,
    this.customKeybindings = const {},
  });

  AppConfig copyWith({
    bool? showCommandLog,
    int? sidebarWidth,
    String? defaultBranch,
    Map<String, String>? customKeybindings,
  }) {
    return AppConfig(
      showCommandLog: showCommandLog ?? this.showCommandLog,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      customKeybindings: customKeybindings ?? this.customKeybindings,
    );
  }
}
