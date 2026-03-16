import 'package:flutter/material.dart';
import 'package:super_scroll/super_scroll.dart';
import '../models/business_model.dart';
import '../services/business_service.dart';

enum BusinessViewType {
  listViewBuilder,
  listViewSeparated,
  gridViewCount,
  gridViewExtent,
  rawSuperScroll,
}

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final BusinessService _businessService = BusinessService();
  late final SuperScrollController<BusinessModel> _controller;
  final TextEditingController _searchController = TextEditingController();
  BusinessViewType _viewType = BusinessViewType.listViewSeparated;

  @override
  void initState() {
    super.initState();
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
                child: const Icon(Icons.business, size: 40, color: Colors.blue),
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
        child: const Icon(Icons.business, color: Colors.blue),
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
      case BusinessViewType.rawSuperScroll:
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SuperScroll(
              controller: _controller,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _controller.items.length,
                itemBuilder: (context, index) =>
                    _buildItem(_controller.items[index]),
              ),
            );
          },
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
