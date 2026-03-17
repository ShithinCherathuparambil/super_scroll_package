import 'package:flutter/material.dart';
import 'package:super_scroll/super_scroll.dart';
import '../models/business_model.dart';
import '../services/business_service.dart';

enum BusinessViewType {
  listViewBuilder,
  listViewSeparated,
  gridViewCount,
  gridViewExtent,
  gridViewStandard,
  masonryGrid,
  sliverList,
  sliverGrid,
  rawSuperScroll,
}

class BusinessListScreen extends StatefulWidget {
  final BusinessService? businessService;
  const BusinessListScreen({super.key, this.businessService});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  late final BusinessService _businessService;
  late final SuperScrollController<BusinessModel> _controller;
  final TextEditingController _searchController = TextEditingController();
  BusinessViewType _viewType = BusinessViewType.listViewSeparated;

  @override
  void initState() {
    super.initState();
    _businessService = widget.businessService ?? BusinessService();
    _controller = SuperScrollController<BusinessModel>(
      onFetch: (page) async {
        final response = await _businessService.fetchBusinesses(
          page,
          search: _searchController.text,
        );
        return SuperScrollResult(
          items: response.record,
          hasMore: response.hasNext,
        );
      },
    );
  }

  void _onSearchChanged() {
    _controller.refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildItem(BusinessModel business) {
    if (_viewType == BusinessViewType.gridViewCount ||
        _viewType == BusinessViewType.gridViewExtent) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.blue[50],
                child: business.logo['url'] != null
                    ? Image.network(
                        business.logo['url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.business,
                              size: 40,
                              color: Colors.blue,
                            ),
                      )
                    : const Icon(Icons.business, size: 40, color: Colors.blue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    business.businessType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[50],
        backgroundImage: business.logo['url'] != null
            ? NetworkImage(business.logo['url'])
            : null,
        child: business.logo['url'] == null
            ? const Icon(Icons.business, color: Colors.blue)
            : null,
      ),
      title: Text(business.name),
      subtitle: Text(business.businessType),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildView() {
    switch (_viewType) {
      case BusinessViewType.listViewBuilder:
        return SuperListView.builder(
          controller: _controller,
          onRefresh: () => _controller.refresh(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, business, index) => _buildItem(business),
        );
      case BusinessViewType.listViewSeparated:
        return SuperListView.separated(
          controller: _controller,
          onRefresh: () => _controller.refresh(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, business, index) => _buildItem(business),
          separatorBuilder: (context, index) => const Divider(height: 1),
        );
      case BusinessViewType.gridViewCount:
        return SuperGridView.count(
          controller: _controller,
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
          onRefresh: () => _controller.refresh(),
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, business, index) => _buildItem(business),
        );
      case BusinessViewType.gridViewExtent:
        return SuperGridView.extent(
          controller: _controller,
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
          onRefresh: () => _controller.refresh(),
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, business, index) => _buildItem(business),
        );
      case BusinessViewType.gridViewStandard:
        return SuperGridView(
          controller: _controller,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          onRefresh: () => _controller.refresh(),
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, business, index) => _buildItem(business),
        );
      case BusinessViewType.masonryGrid:
        return SuperMasonryGridView(
          controller: _controller,
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, business, index) => _buildItem(business),
        );
      case BusinessViewType.sliverList:
        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              title: Text('Inside CustomScrollView'),
              backgroundColor: Colors.blueGrey,
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'The list below is a SuperSliverList',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SuperSliverList(
              controller: _controller,
              itemBuilder: (context, business, index) => _buildItem(business),
            ),
          ],
        );
      case BusinessViewType.sliverGrid:
        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              title: Text('Sliver Grid Pattern'),
              backgroundColor: Colors.indigo,
            ),
            SuperSliverGridGroup(
              controller: _controller,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, business, index) => _buildItem(business),
            ),
          ],
        );
      case BusinessViewType.rawSuperScroll:
        return SuperScroll(
          controller: _controller,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _controller.items.length,
            itemBuilder: (context, index) =>
                _buildItem(_controller.items[index]),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Businesses'),
        elevation: 2,
        actions: [
          PopupMenuButton<BusinessViewType>(
            icon: const Icon(Icons.grid_view),
            onSelected: (value) => setState(() => _viewType = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: BusinessViewType.listViewBuilder,
                child: Text('ListView.builder'),
              ),
              const PopupMenuItem(
                value: BusinessViewType.listViewSeparated,
                child: Text('ListView.separated'),
              ),
              const PopupMenuItem(
                value: BusinessViewType.gridViewCount,
                child: Text('GridView.count'),
              ),
              const PopupMenuItem(
                value: BusinessViewType.gridViewExtent,
                child: Text('GridView.extent'),
              ),
              const PopupMenuItem(
                value: BusinessViewType.gridViewStandard,
                child: Text('GridView (Standard)'),
              ),
              const PopupMenuItem(
                value: BusinessViewType.masonryGrid,
                child: Text('Masonry Grid'),
              ),
              const PopupMenuItem(
                value: BusinessViewType.sliverList,
                child: Text('Sliver List'),
              ),
              const PopupMenuItem(
                value: BusinessViewType.sliverGrid,
                child: Text('Sliver Grid'),
              ),
              const PopupMenuItem(
                value: BusinessViewType.rawSuperScroll,
                child: Text('Raw SuperScroll'),
              ),
            ],
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
                  Text(
                    'Super Scroll',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    'Demo Examples',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Users List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center),
              title: const Text('Businesses List'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Communities List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/communities');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search businesses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                ),
              ),
              onSubmitted: (_) => _onSearchChanged(),
            ),
          ),
          Expanded(child: _buildView()),
        ],
      ),
    );
  }
}
