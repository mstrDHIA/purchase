import 'package:flutter/material.dart';
import '../network/supplier_network.dart';
import '../models/supplier.dart';

class SupplierController extends ChangeNotifier {
  final SupplierNetwork _network = SupplierNetwork();

  List<Supplier> suppliers = [];
  bool isLoading = false;
  String? errorMessage;

  /// Fetch all suppliers from the API
  Future<List<Supplier>> fetchSuppliers() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _network.fetchSuppliers();
      // Convert List<dynamic>/Iterable to List<Supplier> defensively and ensure native Dart list/items
      suppliers = List<Supplier>.from(data.map<Supplier>((item) {
        // If the item is already a Supplier (e.g., JS proxy or mixed), rebuild it from json
        if (item is Supplier) {
          try {
            return Supplier.fromJson(Map<String, dynamic>.from(item.toJson()));
          } catch (_) {
            // If toJson isn't available or fails, return the item as-is
            return item;
          }
        }
        if (item is Map<String, dynamic>) return Supplier.fromJson(item);
        if (item is Map) return Supplier.fromJson(Map<String, dynamic>.from(item));
        // fallback: attempt dynamic cast (may throw if not a map)
        return Supplier.fromJson(item as Map<String, dynamic>);
      }));
      isLoading = false;
      notifyListeners();
      return suppliers;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to fetch suppliers: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Create a new supplier
  Future<Supplier> createSupplier({
    required String name,
    required String contactEmail,
    String? phoneNumber,
    String? address,
    String? groupName,
    String? contactName,
    String? matricule,
    String? cin,
    String? codeFournisseur,
  }) async {
    try {
      final response = await _network.createSupplier(
        name: name,
        contactEmail: contactEmail,
        phoneNumber: phoneNumber,
        address: address,
        groupName: groupName,
        contactName: contactName,
        matricule: matricule,
        cin: cin,
        codeFournisseur: codeFournisseur,
      );
      
      // Convert response to Supplier and add to list
      final supplier = Supplier.fromJson(response);
      // Client-side fallback: if server omitted code_fournisseur, preserve the one we sent
      if ((supplier.codeFournisseur == null || supplier.codeFournisseur!.isEmpty) && codeFournisseur != null && codeFournisseur.isNotEmpty) {
        supplier.codeFournisseur = codeFournisseur;
      }
      suppliers.add(supplier);
      notifyListeners();
      return supplier;
    } catch (e) {
      errorMessage = 'Failed to create supplier: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing supplier
  Future<Supplier> editSupplier({
    required int id,
    required String name,
    required String contactEmail,
    String? phoneNumber,
    String? address,
    String? groupName,
    String? contactName,
    String? matricule,
    String? cin,
    String? codeFournisseur,
  }) async {
    try {
      final response = await _network.editSupplier(
        id: id,
        name: name,
        contactEmail: contactEmail,
        phoneNumber: phoneNumber,
        address: address,
        groupName: groupName,
        contactName: contactName,
        matricule: matricule,
        cin: cin,
        codeFournisseur: codeFournisseur,
      );
      
      // Convert response to Supplier and update in list
      final supplier = Supplier.fromJson(response);
      // Client-side fallback: if server omitted code_fournisseur, preserve the one we sent
      if ((supplier.codeFournisseur == null || supplier.codeFournisseur!.isEmpty) && codeFournisseur != null && codeFournisseur.isNotEmpty) {
        supplier.codeFournisseur = codeFournisseur;
      }
      final index = suppliers.indexWhere((s) => s.id == id);
      if (index != -1) {
        suppliers[index] = supplier;
      }
      notifyListeners();
      return supplier;
    } catch (e) {
      errorMessage = 'Failed to update supplier: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a supplier by ID
  Future<void> deleteSupplier(int id) async {
    try {
      await _network.deleteSupplier(id);
      
      // Remove the supplier from the local list
      suppliers.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete supplier: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Retry loading suppliers after an error
  Future<void> retryFetch() async {
    await fetchSuppliers();
  }

  /// Clear error message
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
