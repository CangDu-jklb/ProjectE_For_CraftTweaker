#!/usr/bin/python
from pprint import pprint
from collections import defaultdict
import math
import sys

Items_And_EMC = [
    ('minecraft:cobblestone', 1, 0),
    ('minecraft:stone', 1, 1),
    ('minecraft:stone', 1, 3),
    ('minecraft:stone', 1, 5),
    ('minecraft:dirt', 1, 0),
    ('minecraft:sand', 1, 0),
    ('minecraft:sand', 1, 1),
    ('minecraft:netherrack', 1, 0),
    ('minecraft:glass', 1, 0),
    ('minecraft:grass', 1, 0),
    ('minecraft:dirt', 1, 2),
    ('minecraft:dirt', 1, 1),
    ('minecraft:dye', 1, 0),
    ('minecraft:mycelium', 1, 0),
    ('minecraft:soul_sand', 1, 0),
    ('minecraft:gravel', 1, 0),
    ('minecraft:gold_ingot', 16, 0),
    ('minecraft:iron_ingot', 8, 0),
    ('minecraft:redstone', 4, 0),
    ('minecraft:diamond', 32, 0),
    ('minecraft:emerald', 32, 0),
    ('minecraft:log', 4, 0),
    ('minecraft:log', 4, 1),
    ('minecraft:log', 4, 2),
    ('minecraft:log', 4, 3),
    ('minecraft:log2', 4, 0),
    ('minecraft:log2', 4, 1),
    ('minecraft:ice', 1, 0),
    ('minecraft:packed_ice', 1, 0),
    ('minecraft:blue_ice', 1, 0),
    ('minecraft:obsidian', 4, 0),
    ('minecraft:quartz', 4, 0),
    ('minecraft:coal', 4, 0),
    ('minecraft:glowstone', 4, 0),
    ('minecraft:magma', 4, 0),
    ('minecraft:snowball', 4, 0),
    ('minecraft:wool', 4, 0),
    ('minecraft:brick_block', 8, 0),
    ('minecraft:purpur_block', 4, 0),
    ('minecraft:chorus_fruit', 4, 0),
    ('minecraft:apple', 4, 0),
    ('minecraft:clay', 4, 0),
    ('minecraft:end_stone', 1, 0),
    ('minecraft:nether_wart', 4, 0),
    ('minecraft:phantom_membrane', 4, 0),
    ('minecraft:blaze_rod', 4, 0),
    ('minecraft:melon_slice', 4, 0),
    ('minecraft:slime_ball', 4, 0),
    ('minecraft:rabbit_foot', 4, 0),
    ('minecraft:totem_of_undying', 16, 0),
    ('minecraft:elytra', 16, 0),
    ('minecraft:flint', 4, 0),
    ('minecraft:string', 1, 0),
]

def adjust_emc_value(emc, item_name=""):
    if emc > 8 and emc % 2 != 0:
        new_emc = emc - (emc % 2)
        sys.stderr.write("\n" + "!" * 60 + "\n")
        sys.stderr.write(f"⚠️ FATEL: {item_name}'s EMC {emc} isn't multiples of 2\n")
        sys.stderr.write(f"⚠️ For compatibility, it has been adjusted to {new_emc}\n")
        sys.stderr.write(f"⚠️ It is highly recommended to modify the EMC configuration to make it a multiple of 2.\n")
        sys.stderr.write("!" * 60 + "\n\n")
        
        return new_emc
    return emc

def generate_shapeless_emc_recipes(Items_And_EMC):
    item_dict = {}
    emc_groups = defaultdict(list)
    for name, emc, meta in Items_And_EMC:
        if emc <= 0:
            emc = 1
            sys.stderr.write("\n" + "!" * 60 + "\n")
            sys.stderr.write(f"⚠️ FATEL: {name}'s EMC {emc} isn't multiples of 2\n")
            sys.stderr.write(f"⚠️ For compatibility, it has been adjusted to {new_emc}\n")
            sys.stderr.write(f"⚠️ It is highly recommended to modify the EMC configuration to make it a multiple of 2.\n")
            sys.stderr.write("!" * 60 + "\n\n")
        adjusted_emc = adjust_emc_value(emc, name)
        key = name if meta == 0 else f"{name}:{meta}"
        item_dict[key] = adjusted_emc
        emc_groups[adjusted_emc].append(key)
    
    obj = {}
    
    for target_key, target_emc in item_dict.items():
        recipes = []
        
        # 1. 相同EMC物品的转换
        if target_emc in emc_groups:
            # 找到所有相同EMC的其他物品
            other_items = [item for item in emc_groups[target_emc] if item != target_key]
            for item in other_items:
                recipes.append([f'<{item}>'])
        
        # 2. 单一类型物品的组合配方
        # 只考虑EMC小于目标EMC的物品
        for source_key, source_emc in item_dict.items():
            if source_emc >= target_emc or source_key == target_key:
                continue
            
            # 计算需要的物品数量
            quantity = target_emc // source_emc
            
            # 检查是否可以整除
            if quantity * source_emc != target_emc:
                continue
            
            # 检查物品数量是否在有效范围内
            if 2 <= quantity <= 8:
                recipes.append([f'<{source_key}>'] * quantity)
        
        if recipes:
            obj[target_key] = recipes
    
    return obj
obj = generate_shapeless_emc_recipes(Items_And_EMC)
print("Generated Shapeless Recipes:")
pprint(obj)
def generate_shapeless_zs_script(recipes):
    script_lines = []
    catalyst = "contenttweaker:philosophers_stone"
    script_lines.append("// =================================================")
    script_lines.append("// ProjectE For CraftTweaker")
    script_lines.append(f"// Use Script {__file__}")
    script_lines.append("// Powered by Cangdu-Jklb(GitHub)")
    script_lines.append("// =================================================")
    script_lines.append("")
    script_lines.append("")
    
    for item, recipe_list in recipes.items():
        for i, recipe in enumerate(recipe_list):
            full_recipe = recipe + [f'<{catalyst}>.anyDamage().transformerDamage()']
            
            safe_name = item.replace(':', '_').replace('/', '_')
            recipe_name = f"projecte_{safe_name}_{i}"
            script_lines.append(f'recipes.addShapeless("{recipe_name}", <{item}>, [')
            script_lines.append(f'    {", ".join(full_recipe)}')
            script_lines.append(']);')
            script_lines.append("")
    
    return "\n".join(script_lines)

if obj:
    zs_script = generate_shapeless_zs_script(obj)
    print("\nGenerated CraftTweaker Shapeless Script:")
    print(zs_script)
else:
    print("\nNo recipes generated.")
