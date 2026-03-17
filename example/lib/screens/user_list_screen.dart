import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:super_scroll/super_scroll.dart';

class UserListScreen extends StatefulWidget {
  final UserService? userService;
  const UserListScreen({super.key, this.userService});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

enum UserViewType {
  listBuilder,
  listSeparated,
  gridCount,
  gridExtent,
  masonry,
  sliverList,
  sliverGrid,
  raw,
}

class _UserListScreenState extends State<UserListScreen> {
  late final UserService _userService;
  late final SuperScrollController<UserModel> _controller;
  UserViewType _viewType = UserViewType.listSeparated;

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
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

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: ListTile(
        leading: const SuperSkeleton.circle(size: 40),
        title: const SuperSkeleton(height: 16, width: 120),
        subtitle: const SuperSkeleton(height: 12, width: 180),
      ),
    );
  }

  Widget _buildView(bool isSelectionMode) {
    switch (_viewType) {
      case UserViewType.listBuilder:
        return SuperListView.builder(
          onRefresh: () => _controller.refresh(),
          controller: _controller,
          padding: const EdgeInsets.all(16),
          firstPageProgressIndicator: Column(
            children: List.generate(8, (index) => _buildSkeleton()),
          ),
          newPageProgressIndicator: _buildSkeleton(),
          itemBuilder: (context, user, index) =>
              _buildUserTile(user, isSelectionMode),
        );

      case UserViewType.listSeparated:
        return SuperListView.separated(
          onRefresh: () => _controller.refresh(),
          controller: _controller,
          padding: const EdgeInsets.all(16),
          firstPageProgressIndicator: Column(
            children: List.generate(8, (index) => _buildSkeleton()),
          ),
          newPageProgressIndicator: _buildSkeleton(),
          itemBuilder: (context, user, index) => _buildUserTile(user, isSelectionMode),
          separatorBuilder: (context, index) => const Divider(),
        );

      case UserViewType.gridCount:
        return SuperGridView.count(
          controller: _controller,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.7,
          padding: const EdgeInsets.all(16),
          firstPageProgressIndicator: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const Card(child: SuperSkeleton(height: 150)),
          ),
          newPageProgressIndicator: const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: SuperSkeleton(height: 20),
            ),
          ),
          itemBuilder: (context, user, index) => _buildUserCard(user, isSelectionMode),
        );

      case UserViewType.gridExtent:
        return SuperGridView.extent(
          controller: _controller,
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.7,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, user, index) => _buildUserCard(user, isSelectionMode),
        );

      case UserViewType.masonry:
        return SuperMasonryGridView(
          controller: _controller,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.all(16),
          firstPageProgressIndicator: const Column(
            children: [
              SuperSkeleton(height: 150, margin: EdgeInsets.only(bottom: 12)),
              SuperSkeleton(height: 200, margin: EdgeInsets.only(bottom: 12)),
              SuperSkeleton(height: 120),
            ],
          ),
          newPageProgressIndicator: const SuperSkeleton(height: 40),
          itemBuilder: (context, user, index) => _buildUserCard(user, isSelectionMode, isMasonry: true),
        );


      case UserViewType.sliverList:
        return SuperScroll(
          controller: _controller,
          showFooter: false,
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                floating: true,
                title: Text('SuperSliverList'),
                backgroundColor: Colors.indigo,
              ),
              SuperSliverList(
                controller: _controller,
                itemBuilder: (context, user, index) => _buildUserTile(user, isSelectionMode),
              ),
            ],
          ),
        );

      case UserViewType.sliverGrid:
        return SuperScroll(
          controller: _controller,
          showFooter: false,
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                floating: true,
                title: Text('SuperSliverGrid'),
                backgroundColor: Colors.deepPurple,
              ),
              SuperSliverGrid(
                controller: _controller,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, user, index) => _buildUserCard(user, isSelectionMode),
              ),
            ],
          ),
        );

      case UserViewType.raw:
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SuperScroll(
              controller: _controller,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _controller.items.length,
                itemBuilder: (context, index) => _buildUserTile(_controller.items[index], isSelectionMode),
              ),
            );
          },
        );
    }
  }

  Widget _buildUserTile(UserModel user, bool isSelectionMode) {
    final isSelected = _controller.isSelected(user);
    return ListTile(
      onLongPress: () {
        if (!isSelectionMode) {
          _controller.toggleSelectionMode(true);
          _controller.toggleItemSelection(user);
        }
      },
      onTap: () {
        if (isSelectionMode) {
          _controller.toggleItemSelection(user);
        } else {
          // Normal tap
        }
      },
      selected: isSelected,
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.avatar ?? ''),
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Text(user.email ?? ''),
      trailing: isSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (val) => _controller.toggleItemSelection(user),
            )
          : Text('#${user.id}'),
    );
  }

  Widget _buildUserCard(UserModel user, bool isSelectionMode, {bool isMasonry = false}) {
    final isSelected = _controller.isSelected(user);
    return Card(
      elevation: isSelected ? 8 : 1,
      shape: isSelected ? RoundedRectangleBorder(side: BorderSide(color: Colors.blue, width: 2), borderRadius: BorderRadius.circular(4)) : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () {
          if (!isSelectionMode) {
            _controller.toggleSelectionMode(true);
            _controller.toggleItemSelection(user);
          }
        },
        onTap: () {
          if (isSelectionMode) {
            _controller.toggleItemSelection(user);
          }
        },
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: isMasonry ? (user.id! % 2 == 0 ? 0.8 : 1.2) : 1.0,
                child: Image.network(user.avatar ?? '', fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('${user.firstName} ${user.lastName}', 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (!isMasonry) Text(user.email ?? '', maxLines: 1, 
                        style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              if (isSelectionMode)
                Checkbox(
                  visualDensity: VisualDensity.compact,
                  value: isSelected,
                  onChanged: (val) => _controller.toggleItemSelection(user),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isSelectionMode = _controller.isSelectionMode;
        final selectionCount = _controller.selectedItems.length;

        return Scaffold(
          appBar: AppBar(
            title: isSelectionMode
                ? Text('$selectionCount Selected')
                : const Text('Super Scroll - Users'),
            elevation: 2,
            leading: isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _controller.toggleSelectionMode(false),
                  )
                : null,
            actions: isSelectionMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () => _controller.selectAll(),
                      tooltip: 'Select All',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Action on $selectionCount items')),
                        );
                        _controller.toggleSelectionMode(false);
                      },
                    ),
                  ]
                : [
                    PopupMenuButton<UserViewType>(
                      icon: const Icon(Icons.grid_view),
                      onSelected: (type) => setState(() => _viewType = type),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: UserViewType.listBuilder,
                            child: Text('ListView (Builder)')),
                        const PopupMenuItem(
                            value: UserViewType.listSeparated,
                            child: Text('ListView (Separated)')),
                        const PopupMenuItem(
                            value: UserViewType.gridCount,
                            child: Text('GridView (Count)')),
                        const PopupMenuItem(
                            value: UserViewType.gridExtent,
                            child: Text('GridView (Extent)')),
                        const PopupMenuItem(
                            value: UserViewType.masonry,
                            child: Text('Masonry Layout')),
                        const PopupMenuItem(
                            value: UserViewType.sliverList,
                            child: Text('Sliver List')),
                        const PopupMenuItem(
                            value: UserViewType.sliverGrid,
                            child: Text('Sliver Grid')),
                        const PopupMenuItem(
                            value: UserViewType.raw,
                            child: Text('Raw SuperScroll')),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.business_center),
                      onPressed: () => Navigator.pushNamed(context, '/businesses'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.group),
                      onPressed: () => Navigator.pushNamed(context, '/communities'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => _controller.refresh(),
                    ),
                  ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Super Scroll',
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                      Text('Demo Examples',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Users List'),
                  selected: true,
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.business_center),
                  title: const Text('Businesses List'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/businesses');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Communities List'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/communities');
                  },
                ),
              ],
            ),
          ),
          body: _buildView(isSelectionMode),
        );
      },
    );
  }
}
