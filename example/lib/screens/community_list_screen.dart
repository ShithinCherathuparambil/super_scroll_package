import 'package:flutter/material.dart';
import 'package:super_scroll/super_scroll.dart';
import '../models/community_model.dart';
import '../services/community_service.dart';

class CommunityListScreen extends StatefulWidget {
  final CommunityService? communityService;
  const CommunityListScreen({super.key, this.communityService});

  @override
  State<CommunityListScreen> createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends State<CommunityListScreen> {
  late final CommunityService _communityService;
  late final SuperScrollController<CommunityModel> _controller;

  @override
  void initState() {
    super.initState();
    _communityService = widget.communityService ?? CommunityService();
    _controller = SuperScrollController<CommunityModel>(
      onFetch: (page) async {
        final response = await _communityService.fetchCommunities(page);
        return SuperScrollResult(
          items: response.records,
          hasMore: response.hasNext,
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
        title: const Text('Communities'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refresh(page: 5),
          ),
        ],
      ),
      body: SuperListView.separated(
        controller: _controller,
        onRefresh: () => _controller.refresh(),
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, community, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: community.logo != null
                  ? NetworkImage(community.logo!)
                  : null,
              child: community.logo == null ? const Icon(Icons.group) : null,
            ),
            title: Text(community.name),
            subtitle: Text(
              '${community.member} Members • ${community.post} Posts',
            ),
            trailing: community.isFollowed
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
