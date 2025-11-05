import 'package:flutter/material.dart';

class ProfileUserScreen extends StatelessWidget {
	const ProfileUserScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Edit Profile'),
			),
			body: const Center(
				child: Text('Profile Edit Page'),
			),
		);
	}
}
