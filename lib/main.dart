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
          child: EnhancedResponsiveListGrid(),
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
