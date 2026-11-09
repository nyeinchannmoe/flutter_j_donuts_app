enum ConnectionStatus {
  unknown,
  online,
  offline;

  bool get isOffline => this == offline;
}
