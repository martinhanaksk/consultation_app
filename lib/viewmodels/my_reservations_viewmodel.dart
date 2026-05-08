// my_reservations_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the My Reservations screen.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class MyReservationsViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get reservations =>
      List.unmodifiable(_reservations);
  bool get isLoading => _isLoading;

  // ── Public Methods ─────────────────────────────────────────────────────────

  /// Fetches users reservations
  Future<void> initialize() async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final data = await api.getMyReservations(sm.token);
      _reservations = data ?? [];
    } catch (_) {
      _reservations = [];
      notify.showToast("Could not load reservations", isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
