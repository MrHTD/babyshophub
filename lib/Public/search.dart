import 'package:babyshophub/Public/Products/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:babyshophub/Models/product_model.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late List<ProductModel> searchResults;
  String _selectedFilter = 'Name';
  String _selectedSort = 'None';

  @override
  void initState() {
    super.initState();
    searchResults = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 244, 248, 1),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8, right: 4),
                    child: Icon(
                      Icons.search,
                      color: Color.fromRGBO(193, 200, 212, 1),
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    style: const TextStyle(color: Colors.grey),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(193, 200, 212, 1),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: (value) {
                      fetchFirestoreData(value, _selectedFilter,
                          _selectedSort); // Pass the current filter
                    },
                  )),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _showSortOptions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text("Sort By: "),
                      const SizedBox(width: 8),
                      const SizedBox(width: 4),
                      Text(
                        _getSortOptionLabel(_selectedSort),
                        style: const TextStyle(
                          color: Color.fromRGBO(87, 213, 236, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showFilterOptions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt_rounded,
                        color: Color.fromRGBO(87, 213, 236, 1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedFilterLabel(_selectedFilter),
                        style: const TextStyle(
                          color: Color.fromRGBO(87, 213, 236, 1),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Expanded(
              child: searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          color: Color.fromRGBO(87, 213, 236, 1),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        ProductModel product = searchResults[index];
                        return _buildProductCard(context, product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel productModel) {
    return GestureDetector(
      onTap: () {
        navigateToProductDetails(context, productModel);
      },
      child: Card(
        elevation: 1,
        surfaceTintColor: const Color.fromRGBO(253, 253, 253, 1),
        margin: const EdgeInsets.all(10),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    productModel.imageUrls.isNotEmpty
                        ? productModel.imageUrls[0]
                        : 'placeholder_url',
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  productModel.productName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    'Rs. ${productModel.fullPrice}',
                    style: const TextStyle(
                      color: Color.fromRGBO(87, 213, 236, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchFirestoreData(
      String query, String filter, String _selectedSort) async {
    print('Fetching data for query: $query and filter: $filter');

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Products').get();

    List<Map<String, dynamic>> products =
        querySnapshot.docs.map((doc) => doc.data()).toList();

    setState(
      () {
        searchResults = query.isEmpty
            ? []
            : products
                .where((product) {
                  String productName = product['productName'].toLowerCase();
                  String brand = product['brand'].toLowerCase();
                  String category = product['category'].toLowerCase();

                  switch (filter) {
                    case 'Name':
                      return productName.contains(query.toLowerCase());
                    case 'Brand':
                      return brand.contains(query.toLowerCase());
                    case 'Category':
                      return category.contains(query.toLowerCase());
                    default:
                      return false;
                  }
                })
                .map((product) => ProductModel.fromMap(product))
                .toList();
        switch (_selectedSort) {
          case 'PriceLowToHigh':
            searchResults.sort((a, b) =>
                double.parse(a.fullPrice).compareTo(double.parse(b.fullPrice)));
            break;
          case 'PriceHighToLow':
            searchResults.sort((a, b) =>
                double.parse(b.fullPrice).compareTo(double.parse(a.fullPrice)));
            break;
          case 'NameAscending':
            searchResults
                .sort((a, b) => a.productName.compareTo(b.productName));
            break;
          case 'NameDescending':
            searchResults
                .sort((a, b) => b.productName.compareTo(a.productName));
            break;
          case 'None':
            // Do nothing for 'No Sorting'
            break;
          default:
            throw Exception('Invalid sorting option: $_selectedSort');
        }
      },
    );
  }

  void navigateToProductDetails(
      BuildContext context, ProductModel productModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetails(productModel: productModel),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterOption('Name'),
              _buildFilterOption('Brand'),
              _buildFilterOption('Category'),
              // Add more filter options as needed
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String option) {
    bool isActive = option == _selectedFilter;

    return ListTile(
      title: Text(
        option,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? const Color.fromRGBO(87, 213, 236, 1) : null,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet
        setState(() {
          _selectedFilter = option; // Update the filter
        });
        fetchFirestoreData('', _selectedFilter,
            _selectedSort); // Fetch data with the updated filter
      },
    );
  }

  String _selectedFilterLabel(String option) {
    switch (option) {
      case 'Name':
        return 'Name';
      case 'Brand':
        return 'Brand';
      case 'Category':
        return 'Category';
      // Add more options as needed
      default:
        return '';
    }
  }

  String _getSortOptionLabel(String option) {
    switch (option) {
      case 'PriceLowToHigh':
        return 'Low to High';
      case 'PriceHighToLow':
        return 'High to Low';
      case 'NameAscending':
        return 'A to Z';
      case 'NameDescending':
        return 'Z to A';
      case 'None':
        return 'No Sorting';
      default:
        return '';
    }
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSortOption(
                'None',
                'No Sorting',
                Icons.sort_outlined,
              ),
              _buildSortOption(
                'PriceLowToHigh',
                'Sort by Price (Low to High)',
                Icons.arrow_upward_rounded,
              ),
              _buildSortOption(
                'PriceHighToLow',
                'Sort by Price (High to Low)',
                Icons.arrow_downward_rounded,
              ),
              _buildSortOption(
                'NameAscending',
                'Sort by Name (Ascending)',
                Icons.arrow_upward_rounded,
              ),
              _buildSortOption(
                'NameDescending',
                'Sort by Name (Descending)',
                Icons.arrow_downward_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option, String label, IconData icon) {
    bool isActive = option == _selectedSort;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? const Color.fromRGBO(87, 213, 236, 1) : null,
        ),
      ),
      leading: Icon(
        icon,
        color: isActive ? const Color.fromRGBO(87, 213, 236, 1) : null,
      ),
      onTap: () {
        _handleSortOption(option);
        Navigator.pop(context); // Close the bottom sheet
      },
    );
  }

  void _handleSortOption(String option) {
    setState(() {
      _selectedSort = option;

      switch (option) {
        case 'PriceLowToHigh':
          searchResults.sort((a, b) =>
              double.parse(a.fullPrice).compareTo(double.parse(b.fullPrice)));
          break;
        case 'PriceHighToLow':
          searchResults.sort((a, b) =>
              double.parse(b.fullPrice).compareTo(double.parse(a.fullPrice)));
          break;
        case 'NameAscending':
          searchResults.sort((a, b) => a.productName.compareTo(b.productName));
          break;
        case 'NameDescending':
          searchResults.sort((a, b) => b.productName.compareTo(a.productName));
          break;
        case 'None':
          // Do nothing for 'No Sorting'
          break;
        default:
          throw Exception('Invalid sorting option: $option');
      }
    });
  }
}
