import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/items/itemlistvm.dart';
import 'package:e_commerce/data/models/item.dart'; // For ItemType
import 'package:e_commerce/routing/routes.dart'; // Import for navigation
import 'package:e_commerce/presentation/widgets/cart_animation.dart'; // Import the animation helper

/// The Item List Page (View) displays all available items and allows searching, filtering, and sorting.
///
/// It interacts with the [ItemListViewModel] to fetch and manage item data,
/// and uses a [GlobalKey] to facilitate the "add to cart" animation.
class ItemListPage extends StatefulWidget {
  /// A [GlobalKey] used to determine the target position for the cart animation.
  /// This key typically belongs to the shopping cart icon in the app bar.
  final GlobalKey cartKey;

  /// Creates an [ItemListPage].
  ///
  /// The [key] is used for widget identification and the [cartKey] is
  /// required for the add-to-cart animation to function correctly.
  const ItemListPage({super.key, required this.cartKey});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

/// The state class for [ItemListPage].
///
/// Manages the UI state, search functionality, and interaction with the [ItemListViewModel].
class _ItemListPageState extends State<ItemListPage> {
  /// Controller for the search text field, managing user input for item search.
  /// It allows us to read and clear the text in the search bar.
  final TextEditingController _searchController = TextEditingController();

  /// A map to store [GlobalKey] for each item's image. This is crucial
  /// for calculating the starting position of the item's image during the
  /// add-to-cart animation, ensuring a smooth visual effect.
  final Map<String, GlobalKey> _itemImageKeys = {};

  /// Called when this widget is inserted into the tree.
  ///
  /// It sets up a listener on the [_searchController] to update the
  /// [ItemListViewModel]'s search query whenever the text changes. This
  /// ensures that the item list is dynamically filtered as the user types.
  @override
  void initState() {
    super.initState();
    // Ensures that the listener is added after the first frame is rendered,
    // preventing potential issues with the ViewModel being accessed too early
    // before the widget's context is fully available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We set listen to false here because we only need to access the ViewModel's
      // methods, not rebuild the widget when the ViewModel notifies changes.
      final viewModel = Provider.of<ItemListViewModel>(context, listen: false);
      _searchController.addListener(() {
        // Updates the search query in the ViewModel based on the text field's content.
        // This will trigger a filter operation in the ViewModel and notify listeners.
        viewModel.updateSearchQuery(_searchController.text);
      });
    });
  }

  /// Called when this [State] object will be removed from the tree permanently.
  ///
  /// Disposes of the [_searchController] to free up resources and prevent
  /// memory leaks when the widget is no longer needed.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the UI of the Item List Page.
  ///
  /// This method constructs the visual representation of the page, including
  /// the interactive search bar, sorting options, and the dynamic list of items.
  /// It conditionally renders loading states, error messages, or the item list.
  @override
  Widget build(BuildContext context) {
    // Access the ItemListViewModel using Provider.of.
    // listen: true ensures that this widget will rebuild whenever the
    // ItemListViewModel notifies its listeners of changes (e.g., items updated,
    // loading state changed, error occurred).
    final viewModel = Provider.of<ItemListViewModel>(context);

    return Container(
      // The overall background decoration for the entire page, providing a subtle
      // linear gradient for an appealing visual effect.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // --- Search and Filter Bar Area ---
          // This section is dedicated to user input for searching items and
          // options for sorting the displayed list.
          Container(
            decoration: BoxDecoration(
              // A distinct gradient background for the search bar area,
              // making it stand out from the main content.
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(
                    255,
                    255,
                    120,
                    205,
                  ), // A vibrant pinkish color.
                  Colors.purpleAccent, // Complementary purple.
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // Adds a subtle shadow to give the search bar a lifted,
              // three-dimensional appearance, separating it from the items below.
              boxShadow: const [
                BoxShadow(
                  color:
                      Colors.black26, // Semi-transparent black for the shadow.
                  blurRadius: 10, // Blurs the shadow, making it softer.
                  offset: Offset(0, 5), // Shifts the shadow vertically.
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 0, 8.0, 0),
            // SafeArea ensures that the content is not obscured by system UI elements
            // like the status bar or notches on devices. `bottom: false`
            // is used to prevent unnecessary padding at the bottom of the bar itself.
            child: SafeArea(
              bottom: false,
              child: Row(
                // This Row widget arranges the search input field and the sort button
                // horizontally.
                children: [
                  Expanded(
                    // The Expanded widget ensures the TextField takes up
                    // as much horizontal space as possible, pushing the sort button to the right.
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for amazing items...',
                        // Using `withValues` for `withOpacity` as recommended by deprecation warning.
                        hintStyle: TextStyle(
                          color: Colors.white.withAlpha((0.7 * 255).round()),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Highly rounded corners for a modern look.
                          borderSide:
                              BorderSide
                                  .none, // Removes the default border line.
                        ),
                        filled: true,
                        // Using `withValues` for `withOpacity` as recommended by deprecation warning.
                        fillColor: Colors.white.withAlpha(
                          (0.2 * 255).round(),
                        ), // Semi-transparent fill for the input field.
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ), // Text style for user input.
                      cursorColor:
                          Colors
                              .white, // White cursor for better visibility on the dark input field.
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ), // Provides horizontal spacing between the search field and the sort button.
                  // The PopupMenuButton allows users to select a sorting preference
                  // from a predefined list of options.
                  PopupMenuButton<SortType>(
                    tooltip:
                        "Sort Items", // Text shown on long press for accessibility.
                    initialValue:
                        viewModel
                            .currentSortType, // The currently active sort type is highlighted.
                    onSelected: (SortType result) {
                      // Callback function invoked when a sort option is selected.
                      // It updates the ViewModel, which in turn re-sorts the item list.
                      viewModel.updateSortOrder(result);
                    },
                    icon: const Icon(
                      Icons.sort,
                      color: Colors.white,
                      size: 28,
                    ), // The icon representing sorting functionality.
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<SortType>>[
                          // Individual PopupMenuItem widgets representing different sorting criteria.
                          const PopupMenuItem<SortType>(
                            value: SortType.newest,
                            child: Text('Sort by: Newest'),
                          ),
                          const PopupMenuItem<SortType>(
                            value: SortType.oldest,
                            child: Text('Sort by: Oldest'),
                          ),
                          const PopupMenuDivider(), // A visual divider to group related options.
                          const PopupMenuItem<SortType>(
                            value: SortType.priceLowToHigh,
                            child: Text('Price: Low to High'),
                          ),
                          const PopupMenuItem<SortType>(
                            value: SortType.priceHighToLow,
                            child: Text('Price: High to Low'),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<SortType>(
                            value: SortType.nameAZ,
                            child: Text('Name: A-Z'),
                          ),
                          const PopupMenuItem<SortType>(
                            value: SortType.nameZA,
                            child: Text('Name: Z-A'),
                          ),
                        ],
                  ),
                ],
              ),
            ),
          ),
          // --- Main Content Area: Item List or Status Message ---
          // This Expanded widget ensures that the remaining vertical space is
          // occupied by either the loading indicator, error message, empty state,
          // or the actual list of items.
          Expanded(
            child: Consumer<ItemListViewModel>(
              // The Consumer widget listens for changes in the ItemListViewModel
              // and rebuilds only this part of the widget tree when `notifyListeners()` is called.
              builder: (context, viewModel, child) {
                // Conditional rendering based on the ViewModel's state:

                // Display a loading indicator and message if items are currently being fetched.
                if (viewModel.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.blueAccent,
                        ), // A spinning progress indicator.
                        SizedBox(height: 16), // Vertical spacing.
                        Text(
                          'Fetching awesome products...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                // Display a detailed error message if there was an issue fetching data.
                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline, // An error icon.
                            color: Colors.redAccent, // Red color for errors.
                            size: 50,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! ${viewModel.errorMessage!}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please try again later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Display a message if no items are found after a search or filter operation.
                if (viewModel.items.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied, // A sad face icon.
                          color: Colors.blueGrey,
                          size: 60,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No items found matching your search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blueGrey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try a different search term!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // --- Item List Display ---
                // If items are available and there are no errors, display them
                // in a scrollable list view.
                return ListView.builder(
                  padding: const EdgeInsets.all(
                    12.0,
                  ), // Padding around the entire list.
                  itemCount:
                      viewModel.items.length, // Number of items to display.
                  itemBuilder: (context, index) {
                    final item = viewModel.items[index];
                    final sellerName = viewModel.getSellerName(item.sellerId);
                    // Ensure each item has a unique GlobalKey associated with its image.
                    // This key is essential for precisely positioning the start of the
                    // "add to cart" animation. We use `putIfAbsent` to create the key
                    // only if it doesn't already exist for this item ID.
                    _itemImageKeys.putIfAbsent(item.id, () => GlobalKey());

                    return AnimatedOpacity(
                      // Provides a subtle fade-in animation for each item as it appears
                      // in the list, enhancing the user experience.
                      opacity: 1.0, // Fully opaque.
                      duration: const Duration(
                        milliseconds: 500,
                      ), // Animation duration.
                      curve:
                          Curves.easeIn, // Animation curve for a smooth start.
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ), // Vertical spacing between items.
                        child: GestureDetector(
                          // Enables tap detection on the entire card to navigate to item details.
                          onTap: () {
                            // Navigates to the item detail page, passing the item's ID as an argument.
                            Navigator.of(context).pushNamed(
                              AppRoutes.itemDetailRoute,
                              arguments: item.id,
                            );
                          },
                          child: Card(
                            margin:
                                EdgeInsets
                                    .zero, // Removes default card margin, controlled by Padding.
                            elevation:
                                8, // Adds a prominent shadow to the card, giving it depth.
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                20,
                              ), // Applies rounded corners to the card.
                            ),
                            clipBehavior:
                                Clip.antiAlias, // Ensures that any content within the card is
                            // clipped to its rounded borders, preventing overflow.
                            child: Container(
                              // Inner container for the card content with its own background gradient.
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.grey[50]!,
                                  ], // A subtle white to light grey gradient.
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              padding: const EdgeInsets.all(
                                12.0,
                              ), // Padding within the card for content.
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start, // Aligns content to the top of the row.
                                children: [
                                  // --- Item Image Section ---
                                  Container(
                                    key:
                                        _itemImageKeys[item
                                            .id], // Assigns the GlobalKey for animation.
                                    width:
                                        90, // Fixed width for the image container.
                                    height:
                                        90, // Fixed height for the image container.
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ), // Rounded corners for the image.
                                      // Conditionally displays a network image if URLs are available.
                                      image:
                                          (item.imageUrls.isNotEmpty)
                                              ? DecorationImage(
                                                image: NetworkImage(
                                                  item.imageUrls.first,
                                                ),
                                                fit:
                                                    BoxFit
                                                        .cover, // Covers the entire container.
                                              )
                                              : null, // No image if imageUrls is empty.
                                    ),
                                    // Fallback UI for items without an image: displays a placeholder icon
                                    // based on the item type (product or service).
                                    child:
                                        (item.imageUrls.isEmpty)
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Container(
                                                color:
                                                    Colors
                                                        .blueGrey[100], // Light grey background for the placeholder.
                                                child: Icon(
                                                  item.type == ItemType.product
                                                      ? Icons
                                                          .shopping_bag // Shopping bag icon for products.
                                                      : Icons
                                                          .miscellaneous_services, // Services icon for services.
                                                  color:
                                                      Colors
                                                          .blueGrey, // Icon color.
                                                  size: 40, // Icon size.
                                                ),
                                              ),
                                            )
                                            : null, // No placeholder if image exists.
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ), // Horizontal spacing between the image and item details.
                                  // --- Item Details Section ---
                                  Expanded(
                                    // Allows the text details to take up available horizontal space.
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start, // Aligns text to the left.
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.blueGrey,
                                          ),
                                          maxLines:
                                              1, // Restricts name to a single line.
                                          overflow:
                                              TextOverflow
                                                  .ellipsis, // Adds "..." for long names.
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ), // Vertical spacing.
                                        Text(
                                          'Seller: $sellerName',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis, // Truncates long seller names.
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.description,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                          maxLines:
                                              2, // Limits description to two lines.
                                          overflow:
                                              TextOverflow
                                                  .ellipsis, // Truncates long descriptions.
                                        ),
                                        const SizedBox(height: 8),
                                        // Item type and category displayed as a small, styled badge.
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${item.type.toString().split('.').last}: ${item.category}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ), // Spacing before price and add button.
                                  // --- Price and Add to Cart Section ---
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end, // Aligns price and button to the right.
                                    children: [
                                      Text(
                                        'RM${item.price.toStringAsFixed(2)}', // Displays price formatted to 2 decimal places.
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          color:
                                              Colors
                                                  .green, // Price is highlighted in green.
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Displays stock quantity only if the item is a product.
                                      if (item.type == ItemType.product)
                                        Text(
                                          'Stock: ${item.quantity}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            // Red text if out of stock, green otherwise.
                                            color:
                                                (item.quantity ?? 0) <= 0
                                                    ? Colors.red
                                                    : Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      // The "Add to Cart" button.
                                      ElevatedButton.icon(
                                        // Button is disabled if it's a product and currently out of stock.
                                        onPressed:
                                            item.type == ItemType.product &&
                                                    (item.quantity ?? 0) <= 0
                                                ? null // If disabled, onPressed is null.
                                                : () {
                                                  // Determines the image to use for the cart animation.
                                                  // If the item has images, use the first one; otherwise, it will be null.
                                                  ImageProvider? imageProvider;
                                                  if (item
                                                      .imageUrls
                                                      .isNotEmpty) {
                                                    imageProvider =
                                                        NetworkImage(
                                                          item.imageUrls.first,
                                                        );
                                                  }
                                                  // Triggers the "add to cart" animation.
                                                  // The `runCartAnimation` function is expected to handle the visual effect
                                                  // of an item flying towards the cart.
                                                  runCartAnimation(
                                                    context, // Current build context.
                                                    _itemImageKeys[item
                                                        .id]!, // GlobalKey of the item's image for start position.
                                                    widget
                                                        .cartKey, // GlobalKey of the cart icon for end position.
                                                    imageProvider, // The image to animate.
                                                    () {
                                                      // This callback is executed once the animation is complete.
                                                      // It then adds the item to the cart via the ViewModel.
                                                      viewModel.addItemToCart(
                                                        item.id,
                                                        1,
                                                      );
                                                    },
                                                  );
                                                },
                                        icon: const Icon(
                                          Icons.add_shopping_cart, // Cart icon.
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Add',
                                        ), // Button text.
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              item.type == ItemType.product &&
                                                      (item.quantity ?? 0) <= 0
                                                  ? Colors
                                                      .grey[400] // Grey for disabled state.
                                                  : Colors
                                                      .deepOrangeAccent, // Vibrant orange for active state.
                                          foregroundColor:
                                              Colors
                                                  .white, // White text and icon.
                                          minimumSize: const Size(
                                            100,
                                            40,
                                          ), // Consistent button size.
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ), // Rounded button corners.
                                          ),
                                          elevation:
                                              5, // Shadow for the button.
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
