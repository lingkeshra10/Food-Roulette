/// Result of attempting to add a food shop to a category.
enum AddShopResult {
  /// The shop was added successfully.
  success,

  /// The provided name was empty or whitespace-only.
  emptyName,

  /// A shop with the same name (case-insensitive) already exists.
  duplicateName,

  /// The shop was added in memory but could not be persisted to storage.
  storageFailed,
}

/// Result of attempting to remove a food shop from a category.
enum RemoveShopResult {
  /// The shop was removed successfully.
  success,

  /// The removal succeeded in memory but could not be persisted to storage.
  storageFailed,
}
