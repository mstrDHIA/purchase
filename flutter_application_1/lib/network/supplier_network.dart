import 'package:dio/dio.dart';
import 'api.dart';

class SupplierNetwork {
  final APIS api = APIS();

  /// Fetch all suppliers from the API
  Future<List<dynamic>> fetchSuppliers() async {
    try {
      print('Fetching suppliers from API: ${APIS.baseUrl}${APIS.fetchSuppliers}');
      
      final Response response = await api.dio.get(
        APIS.baseUrl + APIS.fetchSuppliers,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('Suppliers fetched successfully');
        // Normalize the response into a Dart List to handle web JSArray or other Iterable types
        final body = response.data;
        if (body is Iterable) {
          return List<dynamic>.from(body);
        } else if (body is Map && body['results'] is Iterable) {
          return List<dynamic>.from(body['results']);
        } else {
          return <dynamic>[];
        }
      } else {
        print('Failed to fetch suppliers: ${response.data}');
        throw Exception('Failed to load suppliers');
      }
    } catch (e) {
      print('Error fetching suppliers: $e');
      rethrow;
    }
  }

  /// Create a new supplier
  Future<Map<String, dynamic>> createSupplier({
    required String name,
    required String contactEmail,
    String? phoneNumber,
    String? address,
    String? groupName,
    String? contactName,
    String? matricule,
    String? cin,
    String? codeFournisseur,
    String? approvalStatus,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'name': name,
        'contact_email': contactEmail,
      };

      // Add optional fields if provided
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        payload['phone_number'] = phoneNumber;
      }
      if (address != null && address.isNotEmpty) {
        payload['address'] = address;
      }
      if (groupName != null && groupName.isNotEmpty) {
        payload['group_name'] = groupName;
      }
      if (contactName != null && contactName.isNotEmpty) {
        payload['contact_name'] = contactName;
      }
      if (matricule != null && matricule.isNotEmpty) {
        payload['matricule_fiscale'] = matricule;
      }
      if (cin != null && cin.isNotEmpty) {
        payload['cin'] = cin;
      }
      if (codeFournisseur != null && codeFournisseur.isNotEmpty) {
        payload['code_fournisseur'] = codeFournisseur;
      }
      if (approvalStatus != null && approvalStatus.isNotEmpty) {
        payload['approval_status'] = approvalStatus;
      }

      // Log payload for debugging
      print('Creating supplier - payload: $payload');

      final Response response = await api.dio.post(
        APIS.baseUrl + APIS.createSupplier,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Supplier created successfully');
        return response.data as Map<String, dynamic>;
      } else {
        // This branch is less likely because Dio will throw on non-2xx statuses
        final body = response.data;
        print('Failed to create supplier - body: $body');
        throw Exception('Failed to create supplier: $body');
      }
    } catch (e) {
      // If DioException with response, extract validation details to a friendly message
      if (e is DioException) {
        final resp = e.response?.data;
        print('DioException while creating supplier - status: ${e.response?.statusCode} data: $resp');
        if (resp is Map) {
          final msg = resp.entries.map((ent) => '${ent.key}: ${ent.value}').join('; ');
          throw Exception('Server validation error: $msg');
        }
        throw Exception('Server validation error: ${resp ?? e.message}');
      }
      print('Error creating supplier: $e');
      rethrow;
    }
  }

  /// Update an existing supplier
  Future<Map<String, dynamic>> editSupplier({
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
    String? approvalStatus,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'name': name,
        'contact_email': contactEmail,
      };

      // Add optional fields if provided
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        payload['phone_number'] = phoneNumber;
      }
      if (address != null && address.isNotEmpty) {
        payload['address'] = address;
      }
      if (groupName != null && groupName.isNotEmpty) {
        payload['group_name'] = groupName;
      }
      if (contactName != null && contactName.isNotEmpty) {
        payload['contact_name'] = contactName;
      }
      if (matricule != null && matricule.isNotEmpty) {
        payload['matricule_fiscale'] = matricule;
      }
      if (cin != null && cin.isNotEmpty) {
        payload['cin'] = cin;
      }
      if (codeFournisseur != null && codeFournisseur.isNotEmpty) {
        payload['code_fournisseur'] = codeFournisseur;
      }
      if (approvalStatus != null && approvalStatus.isNotEmpty) {
        payload['approval_status'] = approvalStatus;
      }

      // Log payload for debugging
      print('Updating supplier (id=$id) - payload: $payload');

      final Response response = await api.dio.put(
        '${APIS.baseUrl}${APIS.editSupplier}$id/',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Supplier updated successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final body = response.data;
        print('Failed to update supplier - body: $body');
        throw Exception('Failed to update supplier: $body');
      }
    } catch (e) {
      if (e is DioException) {
        final resp = e.response?.data;
        print('DioException while updating supplier - status: ${e.response?.statusCode} data: $resp');
        if (resp is Map) {
          final msg = resp.entries.map((ent) => '${ent.key}: ${ent.value}').join('; ');
          throw Exception('Server validation error: $msg');
        }
        throw Exception('Server validation error: ${resp ?? e.message}');
      }
      print('Error updating supplier: $e');
      rethrow;
    }
  }

  /// Delete a supplier by ID
  Future<void> deleteSupplier(int id) async {
    try {
      print('Deleting supplier with id=$id');
      
      final Response response = await api.dio.delete(
        '${APIS.baseUrl}${APIS.deleteSupplier}$id/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('Supplier deleted successfully');
      } else {
        print('Failed to delete supplier: ${response.data}');
        throw Exception('Failed to delete supplier');
      }
    } catch (e) {
      print('Error deleting supplier: $e');
      rethrow;
    }
  }

  /// Fetch a single supplier by ID
  Future<Map<String, dynamic>?> fetchSupplierById(int id) async {
    try {
      final Response response = await api.dio.get(
        '${APIS.baseUrl}${APIS.fetchSuppliers}$id/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
        return null;
      } else {
        print('Failed to fetch supplier by id: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error fetching supplier by id: $e');
      return null;
    }
  }
}
