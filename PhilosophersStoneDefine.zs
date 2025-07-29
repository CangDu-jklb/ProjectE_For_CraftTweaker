#loader contenttweaker
import mods.contenttweaker.VanillaFactory;
import mods.contenttweaker.Item;
var as Item = VanillaFactory.createItem("philosophers_stone");
philosophers_stone.rarity = "epic";philosophers_stone.maxDamage = 100philosophers_stone.creativeTab = <creativetab:misc>;
philosophers_stone.beaconPayment = true;
philosophers_stone.maxStackSize = 999；
philosophers_stone.register();