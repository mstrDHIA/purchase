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
        // Assume the API returns a list or a response with a 'results' field
        if (response.data is List) {
          return response.data as List<dynamic>;
        } else if (response.data is Map && response.data.containsKey('results')) {
          return response.data['results'] as List<dynamic>;
        } else {
          return [];
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
  }) async {
    try {
      print('Creating supplier with data: name=$name, email=$contactEmail');
      
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
        print('Failed to create supplier: ${response.data}');
        throw Exception('Failed to create supplier');
      }
    } catch (e) {
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
  }) async {
    try {
      print('Updating supplier with id=$id');
      
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
        print('Failed to update supplier: ${response.data}');
        throw Exception('Failed to update supplier');
      }
    } catch (e) {
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
}
