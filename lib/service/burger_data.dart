
import 'package:fooddeliveryapp/model/burger_model.dart';


List<BurgerModel> getBurger(){
List<BurgerModel> burger=[];
BurgerModel burgerModel= new BurgerModel();

burgerModel.name="Cheese Burger";
burgerModel.image="images/burger1.png";
burgerModel.price="50";
burger.add(burgerModel);
burgerModel= new BurgerModel();

burgerModel.name="Veggie Burger";
burgerModel.image="images/burger2.png";
burgerModel.price="80";
burger.add(burgerModel);
burgerModel= new BurgerModel();

burgerModel.name="Butter burger";
burgerModel.image="images/burger2.png";
burgerModel.price="30";
burger.add(burgerModel);
burgerModel= new BurgerModel();

burgerModel.name="Big Mac";
burgerModel.image="images/burger2.png";
burgerModel.price="40";
burger.add(burgerModel);
burgerModel= new BurgerModel();




return burger;
}