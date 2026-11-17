import 'package:flutter/material.dart';

class CatalogItem {
  final String id;
  final String name;
  final int price;
  final String type3d; // For the 3D editor mapping

  CatalogItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type3d,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    '3dType': type3d,
  };
}

class CatalogData {
  static final List<Map<String, dynamic>> categories = [
    {
      'title': 'Construction',
      'icon': Icons.home_work_rounded,
      'sub': [
        {
          'name': 'Rooms', 
          'items': [
            {'id': 'c1', 'name': 'Square Room', 'price': 15000, 'type3d': 'room'},
            {'id': 'c2', 'name': 'L-Shaped Room', 'price': 22000, 'type3d': 'room'},
            {'id': 'c3', 'name': 'T-Shaped Room', 'price': 25000, 'type3d': 'room'},
            {'id': 'c4', 'name': 'Circular Room', 'price': 35000, 'type3d': 'room'},
            {'id': 'c5', 'name': 'Custom Studio', 'price': 45000, 'type3d': 'room'},
            {'id': 'c6', 'name': 'Duplex Space', 'price': 85000, 'type3d': 'room'},
            {'id': 'c7', 'name': 'Basement', 'price': 30000, 'type3d': 'room'},
          ]
        },
        {
          'name': 'Walls & Partitions', 
          'items': [
            {'id': 'w1', 'name': 'Standard Wall', 'price': 1200, 'type3d': 'wall'},
            {'id': 'w2', 'name': 'Glass Wall', 'price': 8500, 'type3d': 'glass_wall'},
            {'id': 'w3', 'name': 'Brick Wall', 'price': 3200, 'type3d': 'brick_wall'},
            {'id': 'w4', 'name': 'Wooden Panel', 'price': 4500, 'type3d': 'wood_panel'},
            {'id': 'w5', 'name': 'Half Wall', 'price': 1000, 'type3d': 'half_wall'},
            {'id': 'w6', 'name': 'Acoustic Panel', 'price': 6000, 'type3d': 'wall'},
          ]
        },
        {
          'name': 'Doors & Openings', 
          'items': [
            {'id': 'd1', 'name': 'Single Oak Door', 'price': 12000, 'type3d': 'door'},
            {'id': 'd2', 'name': 'Sliding Glass Door', 'price': 25000, 'type3d': 'sliding_door'},
            {'id': 'd3', 'name': 'Double Entry Door', 'price': 45000, 'type3d': 'double_door'},
            {'id': 'd4', 'name': 'Arcade Opening', 'price': 5000, 'type3d': 'arch'},
            {'id': 'd5', 'name': 'Garage Roller', 'price': 65000, 'type3d': 'garage_door'},
            {'id': 'd6', 'name': 'Barn Door', 'price': 18000, 'type3d': 'door'},
            {'id': 'd7', 'name': 'Bifold Door', 'price': 22000, 'type3d': 'door'},
          ]
        },
        {
          'name': 'Windows', 
          'items': [
            {'id': 'win1', 'name': 'Standard Window', 'price': 4500, 'type3d': 'window'},
            {'id': 'win2', 'name': 'Bay Window', 'price': 18000, 'type3d': 'bay_window'},
            {'id': 'win3', 'name': 'Panoramic Wall', 'price': 55000, 'type3d': 'panoramic_window'},
            {'id': 'win4', 'name': 'Skylight', 'price': 28000, 'type3d': 'window'},
            {'id': 'win5', 'name': 'Awning Window', 'price': 6000, 'type3d': 'window'},
            {'id': 'win6', 'name': 'Stained Glass', 'price': 35000, 'type3d': 'stained_glass'},
          ]
        },
        {
          'name': 'Stairs & Columns', 
          'items': [
            {'id': 'st1', 'name': 'Straight Stairs', 'price': 45000, 'type3d': 'stairs'},
            {'id': 'st2', 'name': 'Spiral Stairs', 'price': 120000, 'type3d': 'spiral_stairs'},
            {'id': 'st3', 'name': 'Roman Column', 'price': 15000, 'type3d': 'column'},
            {'id': 'st4', 'name': 'Modern Steel Pillar', 'price': 22000, 'type3d': 'steel_pillar'},
            {'id': 'st5', 'name': 'Floating Steps', 'price': 85000, 'type3d': 'floating_steps'},
          ]
        },
      ]
    },
    {
      'title': 'Interior',
      'icon': Icons.chair_rounded,
      'sub': [
        {
          'name': 'Living Room', 
          'items': [
            {'id': 'lr1', 'name': 'Corner Sofa', 'price': 65000, 'type3d': 'sofa'},
            {'id': 'lr2', 'name': 'Leather Armchair', 'price': 28000, 'type3d': 'armchair'},
            {'id': 'lr3', 'name': 'Minimalist TV Unit', 'price': 15000, 'type3d': 'tv_stand'},
            {'id': 'lr4', 'name': 'Marble Coffee Table', 'price': 12000, 'type3d': 'table'},
            {'id': 'lr5', 'name': 'Modern Bookshelf', 'price': 18000, 'type3d': 'bookshelf'},
            {'id': 'lr6', 'name': 'Sectional Couch', 'price': 95000, 'type3d': 'sectional'},
            {'id': 'lr7', 'name': 'Recliner', 'price': 35000, 'type3d': 'recliner'},
            {'id': 'lr8', 'name': 'Nest of Tables', 'price': 8000, 'type3d': 'side_table'},
          ]
        },
        {
          'name': 'Bedroom', 
          'items': [
            {'id': 'br1', 'name': 'King Sized Bed', 'price': 45000, 'type3d': 'bed'},
            {'id': 'br2', 'name': 'Double Wardrobe', 'price': 35000, 'type3d': 'wardrobe'},
            {'id': 'br3', 'name': 'Glass Nightstand', 'price': 6000, 'type3d': 'nightstand'},
            {'id': 'br4', 'name': 'Makeup Vanity', 'price': 12000, 'type3d': 'vanity'},
            {'id': 'br5', 'name': 'Queen Size Bed', 'price': 35000, 'type3d': 'bed'},
            {'id': 'br6', 'name': 'Floor Mirror', 'price': 4500, 'type3d': 'mirror'},
            {'id': 'br7', 'name': 'Chest of Drawers', 'price': 15000, 'type3d': 'dresser'},
          ]
        },
        {
          'name': 'Kitchen', 
          'items': [
            {'id': 'kt1', 'name': 'Marble Island', 'price': 85000, 'type3d': 'kitchen_island'},
            {'id': 'kt2', 'name': 'Cabinet Set', 'price': 150000, 'type3d': 'kitchen_cabinet'},
            {'id': 'kt3', 'name': 'Smart Fridge', 'price': 95000, 'type3d': 'fridge'},
            {'id': 'kt4', 'name': 'Industrial Oven', 'price': 45000, 'type3d': 'oven'},
            {'id': 'kt5', 'name': 'Bar Stool', 'price': 3500, 'type3d': 'bar_stool'},
            {'id': 'kt6', 'name': 'Microwave', 'price': 12000, 'type3d': 'microwave'},
            {'id': 'kt7', 'name': 'Dishwasher', 'price': 38000, 'type3d': 'dishwasher'},
          ]
        },
        {
          'name': 'Dining Room', 
          'items': [
            {'id': 'dr1', 'name': 'Oak Dining Table', 'price': 42000, 'type3d': 'dining_table'},
            {'id': 'dr2', 'name': 'Velvet Dining Chair', 'price': 6500, 'type3d': 'dining_chair'},
            {'id': 'dr3', 'name': 'Modern Sideboard', 'price': 22000, 'type3d': 'sideboard'},
            {'id': 'dr4', 'name': 'Designer Wine Rack', 'price': 15000, 'type3d': 'wine_rack'},
            {'id': 'dr5', 'name': 'Round Glass Table', 'price': 28000, 'type3d': 'round_table'},
          ]
        },
        {
          'name': 'Bathroom', 
          'items': [
            {'id': 'bt1', 'name': 'Freestanding Bathtub', 'price': 75000, 'type3d': 'bathtub'},
            {'id': 'bt2', 'name': 'Walk-in Shower', 'price': 45000, 'type3d': 'shower'},
            {'id': 'bt3', 'name': 'Double Vanity', 'price': 32000, 'type3d': 'bath_vanity'},
            {'id': 'bt4', 'name': 'Smart Toilet', 'price': 55000, 'type3d': 'toilet'},
            {'id': 'bt5', 'name': 'Towel Warmer', 'price': 8500, 'type3d': 'towel_rack'},
          ]
        },
        {
          'name': 'Office', 
          'items': [
            {'id': 'of1', 'name': 'Ergonomic Desk', 'price': 22000, 'type3d': 'desk'},
            {'id': 'of2', 'name': 'Executive Chair', 'price': 18000, 'type3d': 'office_chair'},
            {'id': 'of3', 'name': 'Modern Filing Cabinet', 'price': 12000, 'type3d': 'filing_cabinet'},
            {'id': 'of4', 'name': 'Desk Lamp', 'price': 3500, 'type3d': 'desk_lamp'},
            {'id': 'of5', 'name': 'Stationery Rack', 'price': 1500, 'type3d': 'shelf_unit'},
          ]
        },
        {
          'name': 'Kids Room',
          'items': [
            {'id': 'kd1', 'name': 'Bunk Bed', 'price': 55000, 'type3d': 'bunk_bed'},
            {'id': 'kd2', 'name': 'Study Table', 'price': 8500, 'type3d': 'study_desk'},
            {'id': 'kd3', 'name': 'Toy Storage', 'price': 12000, 'type3d': 'toy_box'},
            {'id': 'kd4', 'name': 'Bean Bag', 'price': 2500, 'type3d': 'bean_bag'},
          ]
        },
        {
          'name': 'Gym & Hobby',
          'items': [
            {'id': 'gm1', 'name': 'Treadmill', 'price': 45000, 'type3d': 'treadmill'},
            {'id': 'gm2', 'name': 'Yoga Mat Set', 'price': 2500, 'type3d': 'yoga_mat'},
            {'id': 'gm3', 'name': 'Dumbbell Rack', 'price': 15000, 'type3d': 'dumbbell_rack'},
            {'id': 'gm4', 'name': 'Gaming Chair', 'price': 14000, 'type3d': 'gaming_chair'},
          ]
        },
      ]
    },
    {
      'title': 'Exterior',
      'icon': Icons.park_rounded,
      'sub': [
        {
          'name': 'Plants & Trees', 
          'items': [
            {'id': 'pt1', 'name': 'Maple Tree', 'price': 2500, 'type3d': 'tree'},
            {'id': 'pt2', 'name': 'Boxwood Bush', 'price': 800, 'type3d': 'bush'},
            {'id': 'pt3', 'name': 'Rose Garden Bed', 'price': 4500, 'type3d': 'flower_bed'},
            {'id': 'pt4', 'name': 'Date Palm', 'price': 6000, 'type3d': 'palm'},
            {'id': 'pt5', 'name': 'Bonsai Collection', 'price': 15000, 'type3d': 'plant'},
            {'id': 'pt6', 'name': 'Lawn Turf', 'price': 150, 'type3d': 'lawn'},
            {'id': 'pt7', 'name': 'Lavender Row', 'price': 1200, 'type3d': 'flower_bed'},
            {'id': 'pt8', 'name': 'Cactus Pot', 'price': 450, 'type3d': 'cactus'},
          ]
        },
        {
          'name': 'Garden Furniture', 
          'items': [
            {'id': 'gf1', 'name': 'Teak Bench', 'price': 15000, 'type3d': 'bench'},
            {'id': 'gf2', 'name': 'Rattan Patio Set', 'price': 55000, 'type3d': 'patio_set'},
            {'id': 'gf3', 'name': 'Stone BBQ Grill', 'price': 35000, 'type3d': 'bbq_grill'},
            {'id': 'gf4', 'name': 'Wooden Gazebo', 'price': 180000, 'type3d': 'gazebo'},
            {'id': 'gf5', 'name': 'Luxury Sun Lounger', 'price': 12000, 'type3d': 'lounger'},
            {'id': 'gf6', 'name': 'Garden Swing', 'price': 25000, 'type3d': 'swing'},
            {'id': 'gf7', 'name': 'Patio Umbrella', 'price': 8500, 'type3d': 'umbrella'},
          ]
        },
        {
          'name': 'Pool & Water', 
          'items': [
            {'id': 'pw1', 'name': 'Olympic Pool', 'price': 1200000, 'type3d': 'pool'},
            {'id': 'pw2', 'name': 'Zen Fountain', 'price': 45000, 'type3d': 'fountain'},
            {'id': 'pw3', 'name': 'Luxury Jacuzzi', 'price': 150000, 'type3d': 'jacuzzi'},
            {'id': 'pw4', 'name': 'Infinity Pool', 'price': 2500000, 'type3d': 'pool'},
            {'id': 'pw5', 'name': 'Garden Pond', 'price': 35000, 'type3d': 'pond'},
            {'id': 'pw6', 'name': 'Waterfall Feature', 'price': 85000, 'type3d': 'fountain'},
          ]
        },
        {
          'name': 'Structures & Lighting', 
          'items': [
            {'id': 'gs1', 'name': 'Wooden Slat Fence', 'price': 800, 'type3d': 'fence'},
            {'id': 'gs2', 'name': 'Modern Stone Wall', 'price': 2200, 'type3d': 'stone_wall'},
            {'id': 'gs3', 'name': 'Garden Arch', 'price': 12000, 'type3d': 'arch'},
            {'id': 'gs4', 'name': 'Modern Pergola', 'price': 95000, 'type3d': 'pergola'},
            {'id': 'gs5', 'name': 'Driveway Stones', 'price': 450, 'type3d': 'pathway'},
            {'id': 'gs6', 'name': 'Tool Shed', 'price': 45000, 'type3d': 'shed'},
            {'id': 'gs7', 'name': 'Solar Path Light', 'price': 1200, 'type3d': 'path_light'},
            {'id': 'gs8', 'name': 'Outdoor Lantern', 'price': 3500, 'type3d': 'lantern'},
          ]
        },
      ]
    },
  ];
}
