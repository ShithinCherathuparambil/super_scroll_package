import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:super_scroll/super_scroll.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  late final SuperScrollController<UserModel> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SuperScrollController<UserModel>(
      onFetch: (page) async {
        final response = await _userService.fetchUsers(page);
        return SuperScrollResult(
          items: response.data ?? [],
          hasMore: response.page! < response.totalPages!,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Scroll - Users'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () => Navigator.pushNamed(context, '/communities'),
            tooltip: 'View Communities',
          ),
          IconButton(
            icon: const Icon(Icons.business),
            onPressed: () => Navigator.pushNamed(context, '/businesses'),
            tooltip: 'View Businesses',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refresh(),
          ),
        ],
      ),
      body: SuperListView.separated(
        onRefresh: null,
        controller: _controller,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, user, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar ?? ''),
            ),
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text(user.email ?? ''),
            trailing: Text('#${user.id}'),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
