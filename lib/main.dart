import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Responsive List/Grid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Responsive List/Grid'),
        ),
        body: const Center(
          child: UniqueResponsiveListGrid(),
        ),
      ),
    );
  }
}

class ResponsiveListGrid extends StatelessWidget {
  const ResponsiveListGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.blue[100 * (index % 9 + 1)],
                child: Center(
                  child: Text('Grid Item $index'),
                ),
              );
            },
          );
        } else {
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                color: Colors.green[100 * (index % 9 + 1)],
                child: ListTile(title: Text('List Item $index')),
              );
            },
          );
        }
      },
    );
  }
}

class ItemProvider with ChangeNotifier {
  final List<String> _allItems = List.generate(20, (index) => 'Item $index');
  List<String> _items = List.generate(10, (index) => 'Item $index');
  int _selectedColumns = 3;

  List<String> get items => _items;

  int get selectedColumns => _selectedColumns;

  void refreshItems() {
    _items = List.generate(10, (index) => 'Item ${index + 10}');
    notifyListeners();
  }

  void filterItems(String query) {
    _items = _allItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void setSelectedColumns(int columns) {
    _selectedColumns = columns;
    notifyListeners();
  }
}

class ProviderResponsiveListGrid extends StatelessWidget {
  const ProviderResponsiveListGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemProvider(),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: Consumer<ItemProvider>(
                builder: (context, provider, child) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      provider.refreshItems();
                    },
                    child: constraints.maxWidth > 600
                        ? _buildGridView(provider)
                        : _buildListView(provider),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search...',
        ),
        onChanged: (value) {
          Provider.of<ItemProvider>(context, listen: false).filterItems(value);
        },
      ),
    );
  }

  Widget _buildGridView(ItemProvider provider) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          return _buildItemCard(provider.items[index], index);
        });
  }

  Widget _buildListView(ItemProvider provider) {
    return ListView.builder(
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        return _buildItemTile(provider.items[index], index);
      },
    );
  }

  Widget _buildItemCard(String item, int index) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.blue[100 * (index % 9 + 1)],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(item, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildItemTile(String item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: Colors.green[100 * (index % 9 + 1)],
      child: ListTile(
        title: Text(item),
      ),
    );
  }
}

class EnhancedResponsiveListGrid extends StatelessWidget {
  const EnhancedResponsiveListGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemProvider(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SearchBar(
                onChanged: (value) {
                  Provider.of<ItemProvider>(context, listen: false)
                      .filterItems(value);
                },
              ),
              _buildColumnSelector(context),
              Expanded(
                child: Consumer<ItemProvider>(
                  builder: (context, provider, child) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        try {
                          provider.refreshItems();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error refreshing items: $e')),
                          );
                        }
                      },
                      child: constraints.maxWidth > 600
                          ? _buildGridView(provider, provider.selectedColumns)
                          : _buildListView(provider),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColumnSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<int>(
        value: Provider.of<ItemProvider>(context).selectedColumns,
        items: [2, 3, 4].map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text('$value Columns'),
          );
        }).toList(),
        onChanged: (int? newValue) {
          if (newValue != null) {
            Provider.of<ItemProvider>(context, listen: false)
                .setSelectedColumns(newValue);
          }
        },
      ),
    );
  }

  Widget _buildListView(ItemProvider provider) {
    return ListView.builder(
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          return _buildItemTile(provider.items[index], index);
        });
  }

  Widget _buildGridView(ItemProvider provider, int columns) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(provider.items[index], index);
      },
    );
  }

  Widget _buildItemCard(String item, int index) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.blue[100 * (index % 9 + 1)],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(item, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildItemTile(String item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: Colors.green[100 * (index % 9 + 1)],
      child: ListTile(
        title: Text(item),
      ),
    );
  }
}

class Item {
  final String name;
  final String description;
  final String imageUrl;

  Item({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

class ItemsProvider with ChangeNotifier {
  final List<Item> _allItems = List.generate(
    20,
    (index) => Item(
      name: 'Item $index',
      description:
          'Description for item $index, an elegant and concise detail.',
      imageUrl: 'https://picsum.photos/seed/$index/100',
    ),
  );

  List<Item> _items = [];
  final Set<Item> _selectedItems = {};

  ItemsProvider() {
    _items = _allItems.take(10).toList();
  }

  List<Item> get items => _items;
  Set<Item> get selectedItems => _selectedItems;

  bool isSelected(Item item) => _selectedItems.contains(item);

  Future<void> refreshIndicator() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _items = _allItems.skip(10).take(10).toList();
    _selectedItems.clear();
    notifyListeners();
  }

  void filterItems(String query) {
    _items = _allItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _selectedItems.clear();
    notifyListeners();
  }

  void toggleSelection(Item item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }
}

class UniqueResponsiveListGrid extends StatelessWidget {
  const UniqueResponsiveListGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemsProvider>(
      create: (_) => ItemsProvider(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const maxContentWidth = 1200.0;
          final width = constraints.maxWidth > maxContentWidth
              ? maxContentWidth
              : constraints.maxWidth;
          return Center(
            child: Container(
              width: width,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 24),
                  const SearchedBar(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Consumer<ItemsProvider>(
                        builder: (context, provider, _) {
                      return RefreshIndicator(
                        onRefresh: provider.refreshIndicator,
                        displacement: 60.0,
                        child: constraints.maxWidth > 600
                            ? _AnimatedGridView(
                                columns: 3, keyProvider: provider)
                            : _AnimatedListView(keyProvider: provider),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Build your Component Library',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade900,
        height: 1.1,
      ),
    );
  }
}

class SearchedBar extends StatelessWidget {
  const SearchedBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        hintText: 'Search...',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      style: TextStyle(color: Colors.grey.shade900),
      onChanged: (query) {
        Provider.of<ItemsProvider>(context, listen: false).filterItems(query);
      },
    );
  }
}

class _AnimatedGridView extends StatefulWidget {
  final int columns;
  final ItemsProvider keyProvider;

  const _AnimatedGridView({
    super.key,
    required this.columns,
    required this.keyProvider,
  });

  @override
  State<_AnimatedGridView> createState() => _AnimatedGridViewState();
}

class _AnimatedGridViewState extends State<_AnimatedGridView>
    with SingleTickerProviderStateMixin {
  late final GlobalKey<AnimatedListState> _listKey;
  List<Item> _oldItems = [];

  @override
  void initState() {
    super.initState();
    _listKey = GlobalKey<AnimatedListState>();
    _oldItems = List.from(widget.keyProvider.items);
  }

  @override
  void didUpdateWidget(covariant _AnimatedGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItems(oldWidget.keyProvider.items, widget.keyProvider.items);
  }

  void _syncItems(List<Item> oldList, List<Item> newList) {
    for (var i = 0; i < oldList.length; i++) {
      if (!newList.contains(oldList[i])) {
        final removedIndex = i;
        _listKey.currentState?.removeItem(
          removedIndex,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: _ItemCard(
              item: oldList[removedIndex],
              isSelected: widget.keyProvider.isSelected(oldList[removedIndex]),
              onTap: () =>
                  widget.keyProvider.toggleSelection(oldList[removedIndex]),
            ),
          ),
        );
        _oldItems.removeAt(removedIndex);
      }
    }
    for (var i = 0; i < newList.length; i++) {
      if (!_oldItems.contains(newList[i])) {
        _listKey.currentState?.insertItem(i);
        _oldItems.insert(i, newList[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.keyProvider.items;
    return AnimatedList(
      key: _listKey,
      initialItemCount: items.length,
      itemBuilder: (context, index, animation) {
        final item = items[index];
        return SizeTransition(
          sizeFactor: animation,
          child: _ItemCard(
            item: item,
            isSelected: widget.keyProvider.isSelected(item),
            onTap: () => widget.keyProvider.toggleSelection(item),
          ),
        );
      },
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}

class _AnimatedListView extends StatefulWidget {
  final ItemsProvider keyProvider;

  const _AnimatedListView({
    super.key,
    required this.keyProvider,
  });

  @override
  State<_AnimatedListView> createState() => _AnimatedListViewState();
}

class _AnimatedListViewState extends State<_AnimatedListView>
    with SingleTickerProviderStateMixin {
  late final GlobalKey<AnimatedListState> _listKey;
  List<Item> _oldItems = [];

  @override
  void initState() {
    super.initState();
    _listKey = GlobalKey<AnimatedListState>();
    _oldItems = List.from(widget.keyProvider.items);
  }

  @override
  void didUpdateWidget(covariant _AnimatedListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItems(oldWidget.keyProvider.items, widget.keyProvider.items);
  }

  void _syncItems(List<Item> oldList, List<Item> newList) {
    for (var i = 0; i < oldList.length; i++) {
      if (!newList.contains(oldList[i])) {
        final removedIndex = i;
        _listKey.currentState?.removeItem(
          removedIndex,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: _ItemTile(
              item: oldList[removedIndex],
              isSelected: widget.keyProvider.isSelected(oldList[removedIndex]),
              onTap: () =>
                  widget.keyProvider.toggleSelection(oldList[removedIndex]),
            ),
          ),
        );
        _oldItems.removeAt(removedIndex);
      }
    }
    for (var i = 0; i < newList.length; i++) {
      if (!_oldItems.contains(newList[i])) {
        _listKey.currentState?.insertItem(i);
        _oldItems.insert(i, newList[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.keyProvider.items;
    return AnimatedList(
      key: _listKey,
      initialItemCount: items.length,
      itemBuilder: (context, index, animation) {
        final item = items[index];
        return SizeTransition(
          sizeFactor: animation,
          child: _ItemTile(
            item: item,
            isSelected: widget.keyProvider.isSelected(item),
            onTap: () => widget.keyProvider.toggleSelection(item),
          ),
        );
      },
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final baseColor = Colors.white;
    final selectedOverlayColor = Colors.blue.withOpacity(0.15);

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        selected: isSelected,
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: isSelected
                ? Border.all(color: Colors.blueAccent, width: 2)
                : null,
          ),
          foregroundDecoration: isSelected
              ? BoxDecoration(
                  color: selectedOverlayColor,
                  borderRadius: borderRadius,
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 120,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 120,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Item item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white;
    final selectedOverlayColor = Colors.blue.withOpacity(0.10);

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        selected: isSelected,
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
            border: isSelected
                ? Border.all(color: Colors.blueAccent, width: 2)
                : null,
          ),
          foregroundDecoration: isSelected
              ? BoxDecoration(
                  color: selectedOverlayColor,
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 64,
                      height: 64,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
