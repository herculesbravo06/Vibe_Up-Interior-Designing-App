/**
 * VIBEUP CATALOG DATA
 * Hierarchical data structure for the 3D Workspace catalogue.
 * Ported from mobile app: CatalogData.dart
 * Includes: Flooring, Wall Colors, Construction, Interior, Exterior
 */

const CATALOG_DATA = [
    {
        title: 'Flooring',
        icon: '🪵',
        sub: [
            {
                name: 'Wood Flooring',
                items: [
                    { id: 'fl1', name: 'Classic Oak Wood', price: 250, type3d: '_floor_wood', floorMat: 'wood' },
                    { id: 'fl2', name: 'Dark Walnut', price: 350, type3d: '_floor_dark_walnut', floorMat: 'dark_walnut' },
                    { id: 'fl3', name: 'Light Ash', price: 280, type3d: '_floor_light_ash', floorMat: 'light_ash' },
                    { id: 'fl4', name: 'Cherry Hardwood', price: 420, type3d: '_floor_cherry', floorMat: 'cherry' },
                    { id: 'fl5', name: 'Bamboo Natural', price: 300, type3d: '_floor_bamboo', floorMat: 'bamboo' },
                ]
            },
            {
                name: 'Stone & Tile',
                items: [
                    { id: 'fl6', name: 'Italian Marble', price: 1200, type3d: '_floor_marble', floorMat: 'marble' },
                    { id: 'fl7', name: 'Modern Ceramic Tile', price: 180, type3d: '_floor_tile', floorMat: 'tile' },
                    { id: 'fl8', name: 'Slate Grey Stone', price: 400, type3d: '_floor_slate', floorMat: 'slate' },
                    { id: 'fl9', name: 'Travertine', price: 800, type3d: '_floor_travertine', floorMat: 'travertine' },
                    { id: 'fl10', name: 'Terrazzo', price: 600, type3d: '_floor_terrazzo', floorMat: 'terrazzo' },
                ]
            },
            {
                name: 'Soft Flooring',
                items: [
                    { id: 'fl11', name: 'Navy Blue Carpet', price: 150, type3d: '_floor_carpet', floorMat: 'carpet' },
                    { id: 'fl12', name: 'Plush Cream Carpet', price: 200, type3d: '_floor_cream_carpet', floorMat: 'cream_carpet' },
                    { id: 'fl13', name: 'Berber Grey', price: 220, type3d: '_floor_berber', floorMat: 'berber' },
                ]
            },
            {
                name: 'Industrial',
                items: [
                    { id: 'fl14', name: 'Polished Concrete', price: 100, type3d: '_floor_concrete', floorMat: 'concrete' },
                    { id: 'fl15', name: 'Epoxy Resin', price: 500, type3d: '_floor_epoxy', floorMat: 'epoxy' },
                    { id: 'fl16', name: 'Raw Cement', price: 80, type3d: '_floor_cement', floorMat: 'cement' },
                ]
            }
        ]
    },
    {
        title: 'Wall Colors',
        icon: '🎨',
        sub: [
            {
                name: 'Neutral Tones',
                items: [
                    { id: 'wc1', name: 'Warm Ivory', price: 50, type3d: '_wall_color', wallColor: '#f5f0e8' },
                    { id: 'wc2', name: 'Pearl White', price: 50, type3d: '_wall_color', wallColor: '#faf8f5' },
                    { id: 'wc3', name: 'Soft Beige', price: 50, type3d: '_wall_color', wallColor: '#e8dcd0' },
                    { id: 'wc4', name: 'Warm Grey', price: 50, type3d: '_wall_color', wallColor: '#b0a8a0' },
                    { id: 'wc5', name: 'Charcoal', price: 50, type3d: '_wall_color', wallColor: '#3a3a3a' },
                    { id: 'wc6', name: 'Antique White', price: 50, type3d: '_wall_color', wallColor: '#f0ebe0' },
                ]
            },
            {
                name: 'Bold & Modern',
                items: [
                    { id: 'wc7', name: 'Midnight Navy', price: 60, type3d: '_wall_color', wallColor: '#1a1a2e' },
                    { id: 'wc8', name: 'Forest Green', price: 60, type3d: '_wall_color', wallColor: '#1a3a1a' },
                    { id: 'wc9', name: 'Burgundy Red', price: 60, type3d: '_wall_color', wallColor: '#4a1a1a' },
                    { id: 'wc10', name: 'Dusty Rose', price: 60, type3d: '_wall_color', wallColor: '#c4a0a0' },
                    { id: 'wc11', name: 'Ocean Teal', price: 60, type3d: '_wall_color', wallColor: '#1a4a4a' },
                    { id: 'wc12', name: 'Matte Black', price: 70, type3d: '_wall_color', wallColor: '#1a1a1a' },
                ]
            },
            {
                name: 'Pastels',
                items: [
                    { id: 'wc13', name: 'Sky Blue', price: 55, type3d: '_wall_color', wallColor: '#c0d8e8' },
                    { id: 'wc14', name: 'Lavender', price: 55, type3d: '_wall_color', wallColor: '#d0c0e0' },
                    { id: 'wc15', name: 'Mint Green', price: 55, type3d: '_wall_color', wallColor: '#c0e0d0' },
                    { id: 'wc16', name: 'Pale Peach', price: 55, type3d: '_wall_color', wallColor: '#f0d8c0' },
                    { id: 'wc17', name: 'Butter Yellow', price: 55, type3d: '_wall_color', wallColor: '#f0e8c0' },
                ]
            },
            {
                name: 'Accent Walls',
                items: [
                    { id: 'wc18', name: 'Exposed Brick Red', price: 120, type3d: '_wall_color', wallColor: '#8b4513' },
                    { id: 'wc19', name: 'Deep Purple', price: 80, type3d: '_wall_color', wallColor: '#2a1a3a' },
                    { id: 'wc20', name: 'Gold Shimmer', price: 100, type3d: '_wall_color', wallColor: '#8a7030' },
                    { id: 'wc21', name: 'Sage Green', price: 65, type3d: '_wall_color', wallColor: '#7a8a6a' },
                ]
            }
        ]
    },
    {
        title: 'Construction',
        icon: '🧱',
        sub: [
            {
                name: 'Rooms',
                items: [
                    { id: 'c1', name: 'Square Room', price: 15000, type3d: 'room' },
                    { id: 'c2', name: 'L-Shaped Room', price: 22000, type3d: 'room' },
                    { id: 'c3', name: 'T-Shaped Room', price: 25000, type3d: 'room' },
                    { id: 'c4', name: 'Circular Room', price: 35000, type3d: 'room' },
                    { id: 'c5', name: 'Custom Studio', price: 45000, type3d: 'room' }
                ]
            },
            {
                name: 'Walls & Partitions',
                items: [
                    { id: 'w1', name: 'Standard Wall', price: 1200, type3d: 'wall' },
                    { id: 'w2', name: 'Glass Wall', price: 8500, type3d: 'glass_wall' },
                    { id: 'w3', name: 'Brick Wall', price: 3200, type3d: 'brick_wall' },
                    { id: 'w4', name: 'Wooden Panel', price: 4500, type3d: 'wood_panel' },
                    { id: 'w5', name: 'Half Wall', price: 1000, type3d: 'half_wall' }
                ]
            },
            {
                name: 'Doors & Openings',
                items: [
                    { id: 'd1', name: 'Single Oak Door', price: 12000, type3d: 'door' },
                    { id: 'd2', name: 'Sliding Glass Door', price: 25000, type3d: 'sliding_door' },
                    { id: 'd3', name: 'Double Entry Door', price: 45000, type3d: 'double_door' },
                    { id: 'd4', name: 'Arcade Opening', price: 5000, type3d: 'arch' },
                    { id: 'd5', name: 'Garage Roller', price: 65000, type3d: 'garage_door' }
                ]
            },
            {
                name: 'Windows',
                items: [
                    { id: 'win1', name: 'Standard Window', price: 4500, type3d: 'window' },
                    { id: 'win2', name: 'Bay Window', price: 18000, type3d: 'bay_window' },
                    { id: 'win3', name: 'Panoramic Wall', price: 55000, type3d: 'panoramic_window' },
                    { id: 'win6', name: 'Stained Glass', price: 35000, type3d: 'stained_glass' }
                ]
            },
            {
                name: 'Stairs & Columns',
                items: [
                    { id: 'st1', name: 'Straight Stairs', price: 45000, type3d: 'stairs' },
                    { id: 'st2', name: 'Spiral Stairs', price: 120000, type3d: 'spiral_stairs' },
                    { id: 'st3', name: 'Roman Column', price: 15000, type3d: 'column' },
                    { id: 'st4', name: 'Modern Steel Pillar', price: 22000, type3d: 'steel_pillar' },
                    { id: 'st5', name: 'Floating Steps', price: 85000, type3d: 'floating_steps' }
                ]
            }
        ]
    },
    {
        title: 'Interior',
        icon: '🛋️',
        sub: [
            {
                name: 'Living Room',
                items: [
                    { id: 'lr1', name: 'Corner Sofa', price: 65000, type3d: 'sofa' },
                    { id: 'lr2', name: 'Leather Armchair', price: 28000, type3d: 'armchair' },
                    { id: 'lr3', name: 'Minimalist TV Unit', price: 15000, type3d: 'tv_stand' },
                    { id: 'lr4', name: 'Marble Coffee Table', price: 12000, type3d: 'table' },
                    { id: 'lr5', name: 'Modern Bookshelf', price: 18000, type3d: 'bookshelf' },
                    { id: 'lr6', name: 'Sectional Couch', price: 95000, type3d: 'sectional' },
                    { id: 'lr7', name: 'Recliner', price: 35000, type3d: 'recliner' }
                ]
            },
            {
                name: 'Bedroom',
                items: [
                    { id: 'br1', name: 'King Sized Bed', price: 45000, type3d: 'bed' },
                    { id: 'br2', name: 'Double Wardrobe', price: 35000, type3d: 'wardrobe' },
                    { id: 'br3', name: 'Glass Nightstand', price: 6000, type3d: 'nightstand' },
                    { id: 'br4', name: 'Makeup Vanity', price: 12000, type3d: 'vanity' },
                    { id: 'br7', name: 'Chest of Drawers', price: 15000, type3d: 'dresser' }
                ]
            },
            {
                name: 'Kitchen',
                items: [
                    { id: 'kt1', name: 'Marble Island', price: 85000, type3d: 'kitchen_island' },
                    { id: 'kt2', name: 'Cabinet Set', price: 150000, type3d: 'kitchen_cabinet' },
                    { id: 'kt3', name: 'Smart Fridge', price: 95000, type3d: 'fridge' },
                    { id: 'kt4', name: 'Industrial Oven', price: 45000, type3d: 'oven' },
                    { id: 'kt5', name: 'Bar Stool', price: 3500, type3d: 'bar_stool' }
                ]
            },
            {
                name: 'Dining Room',
                items: [
                    { id: 'dr1', name: 'Oak Dining Table', price: 42000, type3d: 'dining_table' },
                    { id: 'dr2', name: 'Velvet Dining Chair', price: 6500, type3d: 'dining_chair' },
                    { id: 'dr3', name: 'Modern Sideboard', price: 22000, type3d: 'sideboard' },
                    { id: 'dr5', name: 'Round Glass Table', price: 28000, type3d: 'round_table' }
                ]
            },
            {
                name: 'Office',
                items: [
                    { id: 'of1', name: 'Ergonomic Desk', price: 22000, type3d: 'desk' },
                    { id: 'of2', name: 'Executive Chair', price: 18000, type3d: 'office_chair' },
                    { id: 'of4', name: 'Desk Lamp', price: 3500, type3d: 'desk_lamp' }
                ]
            },
            {
                name: 'Bathroom',
                items: [
                    { id: 'ba1', name: 'Modern Bathtub', price: 35000, type3d: 'bathtub' },
                    { id: 'ba2', name: 'Rain Shower', price: 18000, type3d: 'shower' },
                    { id: 'ba3', name: 'Wall-mounted Toilet', price: 12000, type3d: 'toilet' },
                    { id: 'ba4', name: 'Vanity Mirror Cabinet', price: 8000, type3d: 'vanity' }
                ]
            }
        ]
    },
    {
        title: 'Lighting',
        icon: '💡',
        sub: [
            {
                name: 'Ceiling Lights',
                items: [
                    { id: 'lt1', name: 'Crystal Chandelier', price: 45000, type3d: 'chandelier' },
                    { id: 'lt2', name: 'Recessed LED Panel', price: 3500, type3d: 'ceiling_light' },
                    { id: 'lt3', name: 'Track Lighting', price: 8000, type3d: 'track_light' },
                    { id: 'lt4', name: 'Pendant Globe', price: 5500, type3d: 'pendant_light' },
                ]
            },
            {
                name: 'Floor & Table Lamps',
                items: [
                    { id: 'lt5', name: 'Arc Floor Lamp', price: 12000, type3d: 'floor_lamp' },
                    { id: 'lt6', name: 'Nordic Desk Lamp', price: 3500, type3d: 'desk_lamp' },
                    { id: 'lt7', name: 'Lantern Table Lamp', price: 4500, type3d: 'table_lamp' },
                ]
            },
            {
                name: 'Decorative',
                items: [
                    { id: 'lt8', name: 'LED Strip Ambient', price: 2000, type3d: 'led_strip' },
                    { id: 'lt9', name: 'Wall Sconce', price: 3000, type3d: 'wall_sconce' },
                    { id: 'lt10', name: 'Fairy Lights', price: 800, type3d: 'fairy_lights' },
                ]
            }
        ]
    },
    {
        title: 'Exterior',
        icon: '🌳',
        sub: [
            {
                name: 'Plants & Trees',
                items: [
                    { id: 'pt1', name: 'Maple Tree', price: 2500, type3d: 'tree' },
                    { id: 'pt2', name: 'Boxwood Bush', price: 800, type3d: 'bush' },
                    { id: 'pt3', name: 'Rose Garden Bed', price: 4500, type3d: 'flower_bed' },
                    { id: 'pt4', name: 'Date Palm', price: 6000, type3d: 'palm' },
                    { id: 'pt6', name: 'Lawn Turf', price: 150, type3d: 'lawn' },
                    { id: 'pt8', name: 'Cactus Pot', price: 450, type3d: 'cactus' }
                ]
            },
            {
                name: 'Garden Furniture',
                items: [
                    { id: 'gf1', name: 'Teak Bench', price: 15000, type3d: 'bench' },
                    { id: 'gf2', name: 'Rattan Patio Set', price: 55000, type3d: 'patio_set' },
                    { id: 'gf3', name: 'Stone BBQ Grill', price: 35000, type3d: 'bbq_grill' },
                    { id: 'gf5', name: 'Luxury Sun Lounger', price: 12000, type3d: 'lounger' }
                ]
            },
            {
                name: 'Pool & Water',
                items: [
                    { id: 'pw1', name: 'Olympic Pool', price: 1200000, type3d: 'pool' },
                    { id: 'pw2', name: 'Zen Fountain', price: 45000, type3d: 'fountain' },
                    { id: 'pw3', name: 'Luxury Jacuzzi', price: 150000, type3d: 'jacuzzi' },
                    { id: 'pw5', name: 'Garden Pond', price: 35000, type3d: 'pond' }
                ]
            }
        ]
    }
];
