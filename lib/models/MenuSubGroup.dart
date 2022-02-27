// Model for Menu Sub Groups on the Food/Drink Menu
class MenuSubGroup {

  String? id;
  String? menuGroupID;
  String? name;
  List<dynamic>? menuItems = [];

  MenuSubGroup({this.id, this.menuGroupID, this.name, this.menuItems});

}