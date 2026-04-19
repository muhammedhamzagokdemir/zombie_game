import 'weapon.dart';

class WeaponInstance {
  WeaponInstance({required this.weapon})
    : currentMagazineAmmo = weapon.magazineSize;

  final Weapon weapon;
  int currentMagazineAmmo;
  bool isReloading = false;
  double reloadRemaining = 0;

  void startReload() {
    isReloading = true;
    reloadRemaining = weapon.reloadTime;
  }

  void cancelReload() {
    isReloading = false;
    reloadRemaining = 0;
  }
}

class InventorySlot {
  InventorySlot({required this.label, this.weapon});

  final String label;
  WeaponInstance? weapon;
}

enum InventoryAddAction { inserted, replaced, refreshed }

class InventoryAddResult {
  const InventoryAddResult({
    required this.action,
    required this.slotIndex,
    this.previousWeapon,
    required this.weaponState,
  });

  final InventoryAddAction action;
  final int slotIndex;
  final WeaponInstance? previousWeapon;
  final WeaponInstance weaponState;
}

/// Small slot-based inventory used by the player.
/// Weapons store per-slot magazine state, while reserve ammo is shared by ammo type.
class PlayerInventory {
  PlayerInventory()
    : slots = <InventorySlot>[
        InventorySlot(label: '1'),
        InventorySlot(label: '2'),
        InventorySlot(label: '3'),
      ];

  final List<InventorySlot> slots;
  final Map<AmmoType, int> _reserveAmmo = <AmmoType, int>{};
  int activeIndex = 0;

  WeaponInstance? get activeWeaponState => slots[activeIndex].weapon;
  Weapon? get activeWeapon => activeWeaponState?.weapon;

  int reserveAmmoFor(AmmoType ammoType) => _reserveAmmo[ammoType] ?? 0;

  int maxReserveAmmoFor(AmmoType ammoType) {
    return weaponCatalog
        .where((weapon) => weapon.ammoType == ammoType)
        .fold<int>(0, (max, weapon) => weapon.maxReserveAmmo > max ? weapon.maxReserveAmmo : max);
  }

  void clear() {
    for (final slot in slots) {
      slot.weapon = null;
    }
    _reserveAmmo.clear();
    activeIndex = 0;
  }

  void initialize(Weapon weapon) {
    clear();
    final instance = WeaponInstance(weapon: weapon);
    slots.first.weapon = instance;
    activeIndex = 0;
    addAmmo(weapon.ammoType, weapon.startingReserveAmmo);
  }

  bool selectSlot(int index) {
    if (index < 0 || index >= slots.length || slots[index].weapon == null) {
      return false;
    }

    activeIndex = index;
    return true;
  }

  InventoryAddResult addWeapon(Weapon weapon) {
    final existingIndex = slots.indexWhere(
      (slot) => slot.weapon?.weapon.type == weapon.type,
    );
    if (existingIndex != -1) {
      final existing = slots[existingIndex].weapon!;
      existing.currentMagazineAmmo = weapon.magazineSize;
      existing.cancelReload();
      addAmmo(weapon.ammoType, weapon.startingReserveAmmo);
      activeIndex = existingIndex;
      return InventoryAddResult(
        action: InventoryAddAction.refreshed,
        slotIndex: existingIndex,
        previousWeapon: existing,
        weaponState: existing,
      );
    }

    final instance = WeaponInstance(weapon: weapon);
    addAmmo(weapon.ammoType, weapon.startingReserveAmmo);

    final emptyIndex = slots.indexWhere((slot) => slot.weapon == null);
    if (emptyIndex != -1) {
      slots[emptyIndex].weapon = instance;
      activeIndex = emptyIndex;
      return InventoryAddResult(
        action: InventoryAddAction.inserted,
        slotIndex: emptyIndex,
        weaponState: instance,
      );
    }

    final replaced = slots[activeIndex].weapon;
    slots[activeIndex].weapon = instance;
    return InventoryAddResult(
      action: InventoryAddAction.replaced,
      slotIndex: activeIndex,
      previousWeapon: replaced,
      weaponState: instance,
    );
  }

  int addAmmo(AmmoType ammoType, int amount) {
    final current = reserveAmmoFor(ammoType);
    final maxReserve = maxReserveAmmoFor(ammoType);
    final next = (current + amount).clamp(0, maxReserve).toInt();
    _reserveAmmo[ammoType] = next;
    return next - current;
  }

  bool canReload(WeaponInstance weaponState) {
    return !weaponState.isReloading &&
        weaponState.currentMagazineAmmo < weaponState.weapon.magazineSize &&
        reserveAmmoFor(weaponState.weapon.ammoType) > 0;
  }

  int consumeAmmoFromMagazine(WeaponInstance weaponState, {int amount = 1}) {
    if (weaponState.currentMagazineAmmo < amount) {
      return 0;
    }
    weaponState.currentMagazineAmmo -= amount;
    return amount;
  }

  int finishReload(WeaponInstance weaponState) {
    final needed = weaponState.weapon.magazineSize - weaponState.currentMagazineAmmo;
    if (needed <= 0) {
      weaponState.cancelReload();
      return 0;
    }

    final ammoType = weaponState.weapon.ammoType;
    final reserve = reserveAmmoFor(ammoType);
    final loaded = reserve < needed ? reserve : needed;
    _reserveAmmo[ammoType] = reserve - loaded;
    weaponState.currentMagazineAmmo += loaded;
    weaponState.cancelReload();
    return loaded;
  }

  void cancelReloads() {
    for (final slot in slots) {
      slot.weapon?.cancelReload();
    }
  }
}
