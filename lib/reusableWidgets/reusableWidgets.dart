import 'package:flutter/material.dart';
import 'package:icon_badge/icon_badge.dart';



class ReusableAppBar extends StatelessWidget {
  final String title;
  final bool backButton;
  final bool cartButton;
  final int cartCount;

  const ReusableAppBar({
    Key? key,
    required this.title,
    required this.backButton,
    this.cartButton = false,
    this.cartCount = 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              if (backButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                ),
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.0, // Adjust font size
                    fontWeight: FontWeight.bold, // Adjust font weight
                  ),
                  textAlign: TextAlign.center, // Ensure text is centered
                ),
              ),
              if (cartButton)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconBadge(
                    icon: Icon(Icons.shopping_cart, color: Colors.grey, size: 30,),
                    itemCount: cartCount,
                    badgeColor: Colors.red,
                    right: 6,
                    top: 0,
                    hideZero: true,
                    itemColor: Colors.white,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Placeholder()));
                    },
                  ),
                ),
            ],
          ),
          Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.5),
                    width: 2.0,
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
}

class BasicTile {
  final String title;
  final List<BasicTile> tiles;

  const BasicTile({
    required this.title,
    this.tiles = const [],
  });
}