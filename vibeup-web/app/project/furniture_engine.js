    const furnitureDefs = {
      // Interior - Living
      sofa: { build: buildSofa, label: 'Sofa' },
      armchair: { build: buildArmchair, label: 'Armchair' },
      sectional: { build: buildSectional, label: 'Sectional' },
      recliner: { build: buildRecliner, label: 'Recliner' },
      chair: { build: buildChair, label: 'Chair' },
      table: { build: buildTable, label: 'Coffee Table' },
      side_table: { build: buildSideTable, label: 'Side Table' },
      round_table: { build: buildRoundTable, label: 'Round Table' },
      dining_table: { build: buildDiningTable, label: 'Dining Table' },
      dining_chair: { build: buildDiningChair, label: 'Dining Chair' },
      lamp: { build: buildLamp, label: 'Floor Lamp' },
      desk_lamp: { build: buildDeskLamp, label: 'Desk Lamp' },
      bookshelf: { build: buildBookshelf, label: 'Bookshelf' },
      rug: { build: buildRug, label: 'Rug' },
      plant: { build: buildPlant, label: 'Plant' },
      bed: { build: buildBed, label: 'Bed' },
      bunk_bed: { build: buildBunkBed, label: 'Bunk Bed' },
      tv_stand: { build: buildTVStand, label: 'TV Stand' },
      cabinet: { build: buildCabinet, label: 'Cabinet' },
      desk: { build: buildDesk, label: 'Desk' },
      study_desk: { build: buildStudyDesk, label: 'Study Desk' },
      // Bedroom
      wardrobe: { build: buildWardrobe, label: 'Wardrobe' },
      nightstand: { build: buildNightstand, label: 'Nightstand' },
      vanity: { build: buildVanity, label: 'Vanity' },
      mirror: { build: buildMirror, label: 'Mirror' },
      dresser: { build: buildDresser, label: 'Dresser' },
      // Kitchen
      kitchen_island: { build: buildKitchenIsland, label: 'Kitchen Island' },
      kitchen_cabinet: { build: buildKitchenCabinet, label: 'Kitchen Cabinet' },
      fridge: { build: buildFridge, label: 'Fridge' },
      oven: { build: buildOven, label: 'Oven' },
      bar_stool: { build: buildBarStool, label: 'Bar Stool' },
      microwave: { build: buildMicrowave, label: 'Microwave' },
      dishwasher: { build: buildDishwasher, label: 'Dishwasher' },
      // Dining
      sideboard: { build: buildSideboard, label: 'Sideboard' },
      wine_rack: { build: buildWineRack, label: 'Wine Rack' },
      // Bathroom
      bathtub: { build: buildBathtub, label: 'Bathtub' },
      shower: { build: buildShower, label: 'Shower' },
      toilet: { build: buildToilet, label: 'Toilet' },
      bath_vanity: { build: buildBathVanity, label: 'Bath Vanity' },
      towel_rack: { build: buildTowelRack, label: 'Towel Rack' },
      // Office
      office_chair: { build: buildOfficeChair, label: 'Office Chair' },
      filing_cabinet: { build: buildFilingCabinet, label: 'Filing Cabinet' },
      shelf_unit: { build: buildShelfUnit, label: 'Shelf Unit' },
      // Kids
      toy_box: { build: buildToyBox, label: 'Toy Box' },
      bean_bag: { build: buildBeanBag, label: 'Bean Bag' },
      // Gym
      treadmill: { build: buildTreadmill, label: 'Treadmill' },
      yoga_mat: { build: buildYogaMat, label: 'Yoga Mat' },
      dumbbell_rack: { build: buildDumbbellRack, label: 'Dumbbell Rack' },
      gaming_chair: { build: buildGamingChair, label: 'Gaming Chair' },
      // Construction
      room: { build: buildRoomPlaceholder, label: 'Room' },
      wall: { build: buildWallSegment, label: 'Wall' },
      glass_wall: { build: buildGlassWall, label: 'Glass Wall' },
      brick_wall: { build: buildBrickWall, label: 'Brick Wall' },
      wood_panel: { build: buildWoodPanel, label: 'Wood Panel' },
      half_wall: { build: buildHalfWall, label: 'Half Wall' },
      door: { build: buildDoorPlaceholder, label: 'Door' },
      sliding_door: { build: buildSlidingDoor, label: 'Sliding Door' },
      double_door: { build: buildDoubleDoor, label: 'Double Door' },
      garage_door: { build: buildGarageDoor, label: 'Garage Door' },
      arch: { build: buildArch, label: 'Arch' },
      window: { build: buildWindowPlaceholder, label: 'Window' },
      bay_window: { build: buildBayWindow, label: 'Bay Window' },
      panoramic_window: { build: buildPanoramicWindow, label: 'Panoramic Window' },
      stained_glass: { build: buildStainedGlass, label: 'Stained Glass' },
      stairs: { build: buildStairs, label: 'Stairs' },
      spiral_stairs: { build: buildSpiralStairs, label: 'Spiral Stairs' },
      floating_steps: { build: buildFloatingSteps, label: 'Floating Steps' },
      column: { build: buildColumn, label: 'Column' },
      steel_pillar: { build: buildSteelPillar, label: 'Steel Pillar' },
      // Exterior - Plants
      tree: { build: buildTree, label: 'Tree' },
      bush: { build: buildBush, label: 'Bush' },
      flower_bed: { build: buildFlowerBed, label: 'Flower Bed' },
      palm: { build: buildPalm, label: 'Palm' },
      lawn: { build: buildLawn, label: 'Lawn' },
      cactus: { build: buildCactus, label: 'Cactus' },
      // Exterior - Furniture
      bench: { build: buildBench, label: 'Bench' },
      patio_set: { build: buildPatioSet, label: 'Patio Set' },
      bbq_grill: { build: buildBBQGrill, label: 'BBQ Grill' },
      gazebo: { build: buildGazebo, label: 'Gazebo' },
      lounger: { build: buildLounger, label: 'Lounger' },
      swing: { build: buildSwing, label: 'Swing' },
      umbrella: { build: buildUmbrella, label: 'Umbrella' },
      // Exterior - Water
      pool: { build: buildPool, label: 'Pool' },
      fountain: { build: buildFountain, label: 'Fountain' },
      jacuzzi: { build: buildJacuzzi, label: 'Jacuzzi' },
      pond: { build: buildPond, label: 'Pond' },
      // Exterior - Structures
      fence: { build: buildFence, label: 'Fence' },
      stone_wall: { build: buildStoneWall, label: 'Stone Wall' },
      pergola: { build: buildPergola, label: 'Pergola' },
      pathway: { build: buildPathway, label: 'Pathway' },
      shed: { build: buildShed, label: 'Shed' },
      path_light: { build: buildPathLight, label: 'Path Light' },
      lantern: { build: buildLantern, label: 'Lantern' },
      decor: { build: buildDecor, label: 'Decor' },
    };

    function makeMat(color, roughness = 0.6, metalness = 0.05) {
      return new THREE.MeshStandardMaterial({ color, roughness, metalness });
    }

    function addM(g, geo, mat, x, y, z, shadow = false, rx = 0, ry = 0, rz = 0) {
      const m = new THREE.Mesh(geo, mat);
      m.position.set(x, y, z);
      if (rx || ry || rz) m.rotation.set(rx, ry, rz);
      m.castShadow = shadow;
      g.add(m);
      return m;
    }

    function buildSofa() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(2.0, 0.4, 0.9), makeMat(0x4a6fa5), 0, 0.35, 0, true);
      addM(g, new THREE.BoxGeometry(2.0, 0.5, 0.15), makeMat(0x3d5f8a), 0, 0.7, -0.38, true);
      addM(g, new THREE.BoxGeometry(0.15, 0.35, 0.9), makeMat(0x3d5f8a), -0.93, 0.52, 0, true);
      addM(g, new THREE.BoxGeometry(0.15, 0.35, 0.9), makeMat(0x3d5f8a), 0.93, 0.52, 0, true);
      const legMat = makeMat(0x2c2c2e, 0.4, 0.3);
      [[-0.85, -0.35], [0.85, -0.35], [-0.85, 0.35], [0.85, 0.35]].forEach(([x, z]) => {
        addM(g, new THREE.CylinderGeometry(0.03, 0.03, 0.15), legMat, x, 0.075, z);
      });
      [[-0.45, 0], [0.45, 0]].forEach(([x, z]) => {
        addM(g, new THREE.BoxGeometry(0.8, 0.12, 0.7), makeMat(0x5a7fb5, 0.8), x, 0.61, 0.05, true);
      });
      return g;
    }

    function buildChair() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(0.55, 0.08, 0.55), makeMat(0xc49a6c), 0, 0.45, 0, true);
      addM(g, new THREE.BoxGeometry(0.55, 0.6, 0.06), makeMat(0xb08850), 0, 0.75, -0.25, true);
      const lMat = makeMat(0x2c2c2e, 0.4, 0.3);
      [[-0.22, -0.22], [0.22, -0.22], [-0.22, 0.22], [0.22, 0.22]].forEach(([x, z]) => {
        addM(g, new THREE.CylinderGeometry(0.02, 0.02, 0.45), lMat, x, 0.225, z);
      });
      return g;
    }

    function buildTable() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(1.0, 0.06, 0.6), makeMat(0x8B6F47), 0, 0.4, 0, true);
      const lMat = makeMat(0x2c2c2e, 0.4, 0.3);
      [[-0.42, -0.22], [0.42, -0.22], [-0.42, 0.22], [0.42, 0.22]].forEach(([x, z]) => {
        addM(g, new THREE.CylinderGeometry(0.025, 0.025, 0.4), lMat, x, 0.2, z);
      });
      return g;
    }

    function buildDiningTable() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(1.6, 0.07, 0.9), makeMat(0x6B4226), 0, 0.75, 0, true);
      const lMat = makeMat(0x2c2c2e, 0.3, 0.4);
      [[-0.7, -0.35], [0.7, -0.35], [-0.7, 0.35], [0.7, 0.35]].forEach(([x, z]) => {
        addM(g, new THREE.BoxGeometry(0.06, 0.75, 0.06), lMat, x, 0.375, z);
      });
      return g;
    }

    function buildLamp() {
      const g = new THREE.Group();
      addM(g, new THREE.CylinderGeometry(0.15, 0.18, 0.04), makeMat(0x2c2c2e, 0.3, 0.5), 0, 0.02, 0);
      addM(g, new THREE.CylinderGeometry(0.02, 0.02, 1.4), makeMat(0xc0c0c0, 0.3, 0.6), 0, 0.72, 0, true);
      addM(g, new THREE.CylinderGeometry(0.06, 0.2, 0.3), makeMat(0xfff5e0, 0.9, 0.0), 0, 1.55, 0, true);
      const lampLight = new THREE.PointLight(0xfff0d0, 0.6, 4);
      lampLight.position.set(0, 1.5, 0);
      g.add(lampLight);
      return g;
    }

    function buildBookshelf() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(1.0, 1.8, 0.3), makeMat(0x654321), 0, 0.9, 0, true);
      for (let i = 0; i < 4; i++) {
        addM(g, new THREE.BoxGeometry(0.92, 0.03, 0.28), makeMat(0x7a5a3a), 0, 0.25 + i * 0.45, 0);
      }
      const bookColors = [0xc0392b, 0x2980b9, 0x27ae60, 0xf39c12, 0x8e44ad];
      for (let shelf = 0; shelf < 3; shelf++) {
        let x = -0.38;
        for (let b = 0; b < 5; b++) {
          const h = 0.2 + Math.random() * 0.15;
          const w = 0.05 + Math.random() * 0.06;
          addM(g, new THREE.BoxGeometry(w, h, 0.18), makeMat(bookColors[(shelf + b) % bookColors.length]), x, 0.27 + shelf * 0.45 + h / 2, 0);
          x += w + 0.02;
        }
      }
      return g;
    }

    function buildRug() {
      const g = new THREE.Group();
      addM(g, new THREE.PlaneGeometry(2.2, 1.6), makeMat(0x8B4513, 0.95, 0.0), 0, 0.01, 0, false, -Math.PI / 2, 0, 0);
      addM(g, new THREE.PlaneGeometry(2.0, 1.4), makeMat(0xCD853F, 0.95, 0.0), 0, 0.015, 0, false, -Math.PI / 2, 0, 0);
      return g;
    }

    function buildPlant() {
      const g = new THREE.Group();
      addM(g, new THREE.CylinderGeometry(0.12, 0.1, 0.22), makeMat(0xa0522d), 0, 0.11, 0, true);
      addM(g, new THREE.CylinderGeometry(0.11, 0.11, 0.03), makeMat(0x3e2723), 0, 0.23, 0);
      const leafMat = makeMat(0x2e7d32);
      addM(g, new THREE.SphereGeometry(0.14, 8, 6), leafMat, 0, 0.4, 0, true);
      addM(g, new THREE.SphereGeometry(0.1, 8, 6), leafMat, 0.08, 0.5, 0.05, true);
      addM(g, new THREE.SphereGeometry(0.1, 8, 6), leafMat, -0.06, 0.48, -0.06, true);
      return g;
    }

    function buildBed() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(1.8, 0.25, 2.2), makeMat(0x5C4033), 0, 0.25, 0, true);
      addM(g, new THREE.BoxGeometry(1.7, 0.2, 2.1), makeMat(0xf5f5f0, 0.9), 0, 0.475, 0, true);
      addM(g, new THREE.BoxGeometry(1.8, 0.8, 0.08), makeMat(0x4a3728), 0, 0.75, -1.05, true);
      [[-0.45, -0.7], [0.45, -0.7]].forEach(([x, z]) => {
        addM(g, new THREE.BoxGeometry(0.5, 0.12, 0.35), makeMat(0xe8e4de, 0.9), x, 0.64, z, true);
      });
      return g;
    }

    function buildTVStand() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(1.6, 0.5, 0.4), makeMat(0x2c2c2e, 0.4, 0.2), 0, 0.25, 0, true);
      addM(g, new THREE.BoxGeometry(1.3, 0.75, 0.04), makeMat(0x1a1a1a, 0.2, 0.5), 0, 0.88, 0, true);
      addM(g, new THREE.BoxGeometry(1.2, 0.65, 0.01), makeMat(0x111133, 0.1, 0.0), 0, 0.88, 0.025);
      return g;
    }

    function buildCabinet() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(0.8, 1.2, 0.45), makeMat(0xdeb887), 0, 0.6, 0, true);
      addM(g, new THREE.BoxGeometry(0.37, 1.1, 0.02), makeMat(0xc8a96e), -0.19, 0.6, 0.24, true);
      addM(g, new THREE.BoxGeometry(0.37, 1.1, 0.02), makeMat(0xc8a96e), 0.19, 0.6, 0.24, true);
      const handleMat = makeMat(0xD4AF37, 0.3, 0.6);
      addM(g, new THREE.SphereGeometry(0.02), handleMat, -0.06, 0.6, 0.26);
      addM(g, new THREE.SphereGeometry(0.02), handleMat, 0.06, 0.6, 0.26);
      return g;
    }

    function buildDesk() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(1.4, 0.06, 0.65), makeMat(0x8B6F47), 0, 0.75, 0, true);
      const lMat = makeMat(0x2c2c2e, 0.3, 0.4);
      [[-0.62, -0.25], [0.62, -0.25], [-0.62, 0.25], [0.62, 0.25]].forEach(([x, z]) => {
        addM(g, new THREE.BoxGeometry(0.05, 0.75, 0.05), lMat, x, 0.375, z);
      });
      return g;
    }


    // New Interior builders
    function buildArmchair() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.7, 0.35, 0.7), makeMat(0x8B2500), 0, 0.35, 0, true); addM(g, new THREE.BoxGeometry(0.7, 0.55, 0.12), makeMat(0x6B1C00), 0, 0.65, -0.29, true); addM(g, new THREE.BoxGeometry(0.12, 0.3, 0.7), makeMat(0x6B1C00), -0.31, 0.5, 0, true); addM(g, new THREE.BoxGeometry(0.12, 0.3, 0.7), makeMat(0x6B1C00), 0.31, 0.5, 0, true); const l = makeMat(0x1a1a1a, 0.3, 0.4);[[-0.25, -0.25], [0.25, -0.25], [-0.25, 0.25], [0.25, 0.25]].forEach(([x, z]) => { addM(g, new THREE.CylinderGeometry(0.03, 0.04, 0.18), l, x, 0.09, z); }); return g; }
    function buildSectional() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(2.4, 0.35, 1.0), makeMat(0x607D8B), 0, 0.3, 0, true); addM(g, new THREE.BoxGeometry(1.0, 0.35, 0.8), makeMat(0x607D8B), 0.7, 0.3, 0.9, true); addM(g, new THREE.BoxGeometry(2.4, 0.45, 0.12), makeMat(0x4a6572), 0, 0.65, -0.44, true); addM(g, new THREE.BoxGeometry(0.12, 0.45, 1.0), makeMat(0x4a6572), -1.14, 0.65, 0, true); addM(g, new THREE.BoxGeometry(1.0, 0.45, 0.12), makeMat(0x4a6572), 0.7, 0.65, 0.5 + 0.8, true); return g; }
    function buildRecliner() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.8, 0.38, 0.9), makeMat(0x4e342e), 0, 0.35, 0, true); addM(g, new THREE.BoxGeometry(0.8, 0.6, 0.12), makeMat(0x3e2723), 0, 0.68, -0.39, true); addM(g, new THREE.BoxGeometry(0.14, 0.3, 0.9), makeMat(0x3e2723), -0.33, 0.5, 0, true); addM(g, new THREE.BoxGeometry(0.14, 0.3, 0.9), makeMat(0x3e2723), 0.33, 0.5, 0, true); addM(g, new THREE.BoxGeometry(0.6, 0.08, 0.5), makeMat(0x5d4037), 0, 0.2, 0.7, true); return g; }
    function buildSideTable() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.25, 0.25, 0.04, 16), makeMat(0xD4AF37, 0.3, 0.5), 0, 0.5, 0, true); addM(g, new THREE.CylinderGeometry(0.04, 0.04, 0.5), makeMat(0x2c2c2e, 0.3, 0.6), 0, 0.25, 0); return g; }
    function buildRoundTable() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.6, 0.6, 0.05, 24), makeMat(0x88ccff, 0.1, 0.1), 0, 0.75, 0, true); addM(g, new THREE.CylinderGeometry(0.08, 0.15, 0.75), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.375, 0, true); addM(g, new THREE.CylinderGeometry(0.3, 0.3, 0.03, 24), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.015, 0); return g; }
    function buildDiningChair() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.5, 0.06, 0.5), makeMat(0x6a1b9a), 0, 0.45, 0, true); addM(g, new THREE.BoxGeometry(0.5, 0.5, 0.05), makeMat(0x4a148c), 0, 0.75, -0.22, true); const l = makeMat(0xD4AF37, 0.3, 0.5);[[-0.2, -0.2], [0.2, -0.2], [-0.2, 0.2], [0.2, 0.2]].forEach(([x, z]) => addM(g, new THREE.CylinderGeometry(0.02, 0.02, 0.45), l, x, 0.225, z)); return g; }
    function buildDeskLamp() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.1, 0.12, 0.03), makeMat(0x2c2c2e, 0.3, 0.5), 0, 0.015, 0); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.4), makeMat(0xc0c0c0, 0.3, 0.6), 0, 0.22, 0); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.25), makeMat(0xc0c0c0, 0.3, 0.6), 0.08, 0.43, 0, false, 0, 0, 0.6); addM(g, new THREE.SphereGeometry(0.06, 8, 8, 0, Math.PI * 2, 0, Math.PI / 2), makeMat(0xfff5e0, 0.8), 0.2, 0.5, 0); const li = new THREE.PointLight(0xfff0d0, 0.4, 2); li.position.set(0.2, 0.5, 0); g.add(li); return g; }
    function buildBunkBed() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.0, 0.15, 2.0), makeMat(0x8B6F47), 0, 0.5, 0, true); addM(g, new THREE.BoxGeometry(0.9, 0.08, 1.9), makeMat(0x4a90d9, 0.9), 0, 0.62, 0); addM(g, new THREE.BoxGeometry(1.0, 0.15, 2.0), makeMat(0x8B6F47), 0, 1.6, 0, true); addM(g, new THREE.BoxGeometry(0.9, 0.08, 1.9), makeMat(0xff7043, 0.9), 0, 1.72, 0); const p = makeMat(0x5C4033);[[-0.45, -0.95], [0.45, -0.95], [-0.45, 0.95], [0.45, 0.95]].forEach(([x, z]) => addM(g, new THREE.BoxGeometry(0.06, 1.8, 0.06), p, x, 0.9, z, true)); addM(g, new THREE.BoxGeometry(0.06, 1.3, 0.04), makeMat(0x5C4033), 0.45, -0.05, 0.4, true); addM(g, new THREE.BoxGeometry(0.06, 1.3, 0.04), makeMat(0x5C4033), 0.45, -0.05, 0.6, true); return g; }
    function buildStudyDesk() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.0, 0.05, 0.5), makeMat(0x29B6F6, 0.7), 0, 0.65, 0, true); const l = makeMat(0xffffff, 0.5);[[-0.42, -0.2], [0.42, -0.2], [-0.42, 0.2], [0.42, 0.2]].forEach(([x, z]) => addM(g, new THREE.BoxGeometry(0.04, 0.65, 0.04), l, x, 0.325, z)); addM(g, new THREE.BoxGeometry(0.3, 0.3, 0.45), makeMat(0x1565C0), 0.3, 0.15, 0, true); return g; }
    // Bedroom
    function buildWardrobe() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.4, 2.2, 0.55), makeMat(0x4e342e), 0, 1.1, 0, true); addM(g, new THREE.BoxGeometry(0.02, 2.0, 0.02), makeMat(0x3e2723), 0, 1.1, 0.28); addM(g, new THREE.BoxGeometry(0.67, 2.0, 0.02), makeMat(0x5d4037), -0.35, 1.1, 0.28, true); addM(g, new THREE.BoxGeometry(0.67, 2.0, 0.02), makeMat(0x5d4037), 0.35, 1.1, 0.28, true); const h = makeMat(0xD4AF37, 0.3, 0.6); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.15), h, -0.08, 1.1, 0.3, false, 0, 0, Math.PI / 2); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.15), h, 0.08, 1.1, 0.3, false, 0, 0, Math.PI / 2); return g; }
    function buildNightstand() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.45, 0.5, 0.4), makeMat(0x37474F), 0, 0.25, 0, true); addM(g, new THREE.BoxGeometry(0.4, 0.18, 0.02), makeMat(0x455A64), 0, 0.35, 0.21, true); addM(g, new THREE.BoxGeometry(0.4, 0.18, 0.02), makeMat(0x455A64), 0, 0.14, 0.21, true); addM(g, new THREE.SphereGeometry(0.015), makeMat(0xD4AF37, 0.3, 0.6), 0, 0.35, 0.23); addM(g, new THREE.SphereGeometry(0.015), makeMat(0xD4AF37, 0.3, 0.6), 0, 0.14, 0.23); return g; }
    function buildVanity() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.0, 0.06, 0.45), makeMat(0xf5f0e8), 0, 0.75, 0, true); const l = makeMat(0xD4AF37, 0.3, 0.5);[[-0.42, -0.18], [0.42, -0.18], [-0.42, 0.18], [0.42, 0.18]].forEach(([x, z]) => addM(g, new THREE.CylinderGeometry(0.025, 0.025, 0.75), l, x, 0.375, z)); addM(g, new THREE.BoxGeometry(0.6, 0.7, 0.04), makeMat(0xc0c0c0, 0.1, 0.8), 0, 1.18, -.18, true); addM(g, new THREE.BoxGeometry(0.64, 0.74, 0.02), makeMat(0xD4AF37, 0.3, 0.6), 0, 1.18, -.19); return g; }
    function buildMirror() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.6, 1.6, 0.04), makeMat(0xc0c0c0, 0.05, 0.9), 0, 0.85, 0, true); addM(g, new THREE.BoxGeometry(0.64, 1.64, 0.02), makeMat(0xD4AF37, 0.3, 0.6), 0, 0.85, -0.01); addM(g, new THREE.BoxGeometry(0.15, 0.04, 0.15), makeMat(0x2c2c2e), 0, 0.02, 0.05); return g; }
    function buildDresser() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.0, 0.8, 0.45), makeMat(0x795548), 0, 0.4, 0, true); for (let i = 0; i < 3; i++) { addM(g, new THREE.BoxGeometry(0.9, 0.2, 0.02), makeMat(0x8D6E63), 0, 0.15 + i * 0.25, 0.24, true); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.08), makeMat(0xD4AF37, 0.3, 0.6), 0, 0.15 + i * 0.25, 0.26, false, 0, 0, Math.PI / 2); } return g; }
    // Kitchen
    function buildKitchenIsland() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.8, 0.9, 0.8), makeMat(0x37474F), 0, 0.45, 0, true); addM(g, new THREE.BoxGeometry(1.85, 0.06, 0.85), makeMat(0xfafafa, 0.2, 0.1), 0, 0.93, 0, true); return g; }
    function buildKitchenCabinet() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.6, 0.9, 0.5), makeMat(0xf5f0e8), 0, 0.45, 0, true); addM(g, new THREE.BoxGeometry(1.65, 0.05, 0.55), makeMat(0x795548), 0, 0.925, 0); addM(g, new THREE.BoxGeometry(1.6, 0.5, 0.35), makeMat(0xf5f0e8), 0, 1.45, -.075, true); for (let i = 0; i < 3; i++) { addM(g, new THREE.SphereGeometry(0.015), makeMat(0xc0c0c0, 0.2, 0.7), -0.45 + i * 0.45, 0.45, 0.26); } return g; }
    function buildFridge() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.75, 1.9, 0.7), makeMat(0xc0c0c0, 0.2, 0.6), 0, 0.95, 0, true); addM(g, new THREE.BoxGeometry(0.71, 0.6, 0.02), makeMat(0xb0b0b0, 0.2, 0.5), 0, 1.55, 0.36); addM(g, new THREE.BoxGeometry(0.71, 1.15, 0.02), makeMat(0xb0b0b0, 0.2, 0.5), 0, 0.63, 0.36); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.4), makeMat(0x808080, 0.3, 0.6), 0.28, 1.55, 0.38, false, 0, 0, Math.PI / 2); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.4), makeMat(0x808080, 0.3, 0.6), 0.28, 0.65, 0.38, false, 0, 0, Math.PI / 2); return g; }
    function buildOven() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.65, 0.9, 0.6), makeMat(0x2c2c2e, 0.4, 0.3), 0, 0.45, 0, true); addM(g, new THREE.BoxGeometry(0.5, 0.45, 0.02), new THREE.MeshStandardMaterial({ color: 0x111111, transparent: true, opacity: 0.7, roughness: 0.05 }), 0, 0.55, 0.31); addM(g, new THREE.BoxGeometry(0.65, 0.05, 0.6), makeMat(0x1a1a1a), 0, 0.925, 0); for (let i = 0; i < 4; i++) { addM(g, new THREE.CylinderGeometry(0.04, 0.04, 0.02, 16), makeMat(0x424242), -0.2 + i * 0.13, 0.96, -.15); } return g; }
    function buildBarStool() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.18, 0.18, 0.06, 16), makeMat(0x2c2c2e), 0, 0.72, 0, true); addM(g, new THREE.CylinderGeometry(0.03, 0.03, 0.72), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.36, 0); addM(g, new THREE.CylinderGeometry(0.2, 0.22, 0.03, 16), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.015, 0); addM(g, new THREE.TorusGeometry(0.12, 0.015, 8, 16), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.45, 0); return g; }
    function buildMicrowave() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.5, 0.3, 0.35), makeMat(0x424242, 0.4, 0.3), 0, 0.15, 0, true); addM(g, new THREE.BoxGeometry(0.3, 0.22, 0.02), new THREE.MeshStandardMaterial({ color: 0x1a1a1a, transparent: true, opacity: 0.6 }), -.05, 0.15, 0.18); addM(g, new THREE.BoxGeometry(0.1, 0.22, 0.02), makeMat(0x616161), 0.17, 0.15, 0.18); return g; }
    function buildDishwasher() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.6, 0.85, 0.55), makeMat(0xeeeeee, 0.3, 0.2), 0, 0.425, 0, true); addM(g, new THREE.BoxGeometry(0.56, 0.8, 0.02), makeMat(0xe0e0e0, 0.3, 0.2), 0, 0.425, 0.28); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.3), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.75, 0.3, false, 0, 0, Math.PI / 2); return g; }
    // Dining
    function buildSideboard() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.5, 0.7, 0.4), makeMat(0x5D4037), 0, 0.35, 0, true); addM(g, new THREE.BoxGeometry(1.55, 0.04, 0.45), makeMat(0x4E342E), 0, 0.72, 0); addM(g, new THREE.BoxGeometry(0.48, 0.6, 0.02), makeMat(0x6D4C41), -.5, 0.35, 0.21, true); addM(g, new THREE.BoxGeometry(0.48, 0.6, 0.02), makeMat(0x6D4C41), 0, 0.35, 0.21, true); addM(g, new THREE.BoxGeometry(0.48, 0.6, 0.02), makeMat(0x6D4C41), .5, 0.35, 0.21, true); return g; }
    function buildWineRack() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.6, 1.2, 0.3), makeMat(0x3E2723), 0, 0.6, 0, true); for (let r = 0; r < 4; r++) { for (let c = 0; c < 3; c++) { addM(g, new THREE.CylinderGeometry(0.04, 0.04, 0.28, 8), makeMat(0x4E342E), -.15 + c * .15, 0.2 + r * 0.28, 0, false, Math.PI / 2, 0, 0); } } const bc = [0x8B0000, 0x006400, 0x4A148C]; for (let i = 0; i < 3; i++) { addM(g, new THREE.CylinderGeometry(0.035, 0.035, 0.25, 8), makeMat(bc[i]), -0.15 + i * 0.15, 0.2, 0, false, Math.PI / 2, 0, 0); } return g; }
    // Bathroom extras
    function buildBathVanity() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.0, 0.5, 0.45), makeMat(0xf5f0e8), 0, 0.25, 0, true); addM(g, new THREE.BoxGeometry(1.05, 0.06, 0.5), makeMat(0xfafafa, 0.2, 0.1), 0, 0.53, 0); addM(g, new THREE.CylinderGeometry(0.18, 0.18, 0.08, 16), makeMat(0xfafafa, 0.1, 0.1), 0, 0.58, 0); addM(g, new THREE.CylinderGeometry(0.02, 0.02, 0.2), makeMat(0xc0c0c0, 0.2, 0.8), 0, 0.72, -.1); addM(g, new THREE.BoxGeometry(0.6, 0.5, 0.04), makeMat(0xc0c0c0, 0.05, 0.8), 0, 1.0, -.2, true); return g; }
    function buildTowelRack() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.6, 0.04, 0.04), makeMat(0xc0c0c0, 0.2, 0.8), 0, 1.0, 0); addM(g, new THREE.BoxGeometry(0.6, 0.04, 0.04), makeMat(0xc0c0c0, 0.2, 0.8), 0, 0.85, 0); addM(g, new THREE.BoxGeometry(0.04, 0.5, 0.04), makeMat(0xc0c0c0, 0.2, 0.8), -.28, 1.0, 0, true); addM(g, new THREE.BoxGeometry(0.04, 0.5, 0.04), makeMat(0xc0c0c0, 0.2, 0.8), 0.28, 1.0, 0, true); addM(g, new THREE.BoxGeometry(0.5, 0.3, 0.04), makeMat(0xffffff, 0.9), 0, 0.92, 0.02); return g; }
    // Office
    function buildOfficeChair() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.5, 0.08, 0.5), makeMat(0x1a1a1a), 0, 0.48, 0, true); addM(g, new THREE.BoxGeometry(0.5, 0.55, 0.06), makeMat(0x1a1a1a), 0, 0.78, -.22, true); addM(g, new THREE.CylinderGeometry(0.03, 0.03, 0.48), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.24, 0); addM(g, new THREE.CylinderGeometry(0.15, 0.15, 0.02, 16), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.01, 0); for (let i = 0; i < 5; i++) { const a = i * Math.PI * 2 / 5; addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.2), makeMat(0x424242), Math.cos(a) * 0.12, 0.01, Math.sin(a) * 0.12, false, 0, 0, Math.PI / 2 + a); } return g; }
    function buildFilingCabinet() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.45, 1.2, 0.5), makeMat(0x78909C), 0, 0.6, 0, true); for (let i = 0; i < 3; i++) { addM(g, new THREE.BoxGeometry(0.41, 0.32, 0.02), makeMat(0x90A4AE), 0, 0.2 + i * 0.38, 0.26, true); addM(g, new THREE.CylinderGeometry(0.01, 0.01, 0.1), makeMat(0x424242), 0, 0.2 + i * 0.38, 0.28, false, 0, 0, Math.PI / 2); } return g; }
    function buildShelfUnit() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.7, 1.4, 0.25), makeMat(0xBDBDBD), 0, 0.7, 0, true); for (let i = 0; i < 4; i++) { addM(g, new THREE.BoxGeometry(0.66, 0.025, 0.23), makeMat(0xE0E0E0), 0, 0.18 + i * 0.35, 0); } return g; }
    // Kids
    function buildToyBox() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.7, 0.45, 0.5), makeMat(0xff7043), 0, 0.225, 0, true); addM(g, new THREE.BoxGeometry(0.72, 0.04, 0.52), makeMat(0xe64a19), 0, 0.47, 0); addM(g, new THREE.SphereGeometry(0.06), makeMat(0xFFEB3B), -.15, 0.55, 0); addM(g, new THREE.BoxGeometry(0.08, 0.08, 0.08), makeMat(0x4CAF50), 0.1, 0.55, 0.05); addM(g, new THREE.CylinderGeometry(0.04, 0.04, 0.08, 6), makeMat(0x2196F3), 0.2, 0.55, -.05); return g; }
    function buildBeanBag() { const g = new THREE.Group(); addM(g, new THREE.SphereGeometry(0.4, 12, 10), makeMat(0xE91E63), 0, 0.25, 0, true); const t = g.children[0]; t.scale.set(1, 0.6, 1); return g; }
    // Gym
    function buildTreadmill() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.7, 0.15, 1.6), makeMat(0x1a1a1a), 0, 0.3, 0, true); addM(g, new THREE.BoxGeometry(0.6, 0.04, 1.4), makeMat(0x424242), 0, 0.4, 0); addM(g, new THREE.BoxGeometry(0.04, 1.2, 0.04), makeMat(0xc0c0c0, 0.2, 0.7), -.28, 0.9, -.7, true); addM(g, new THREE.BoxGeometry(0.04, 1.2, 0.04), makeMat(0xc0c0c0, 0.2, 0.7), 0.28, 0.9, -.7, true); addM(g, new THREE.BoxGeometry(0.5, 0.3, 0.04), makeMat(0x1a1a1a), 0, 1.4, -.7); addM(g, new THREE.BoxGeometry(0.4, 0.2, 0.02), makeMat(0x00BCD4, 0.1), 0, 1.42, -.68); return g; }
    function buildYogaMat() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.7, 0.02, 1.8), makeMat(0x7B1FA2, 0.9), 0, 0.01, 0); return g; }
    function buildDumbbellRack() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.0, 0.8, 0.35), makeMat(0x424242), 0, 0.4, 0, true); for (let i = 0; i < 3; i++) { const c = [0x2c2c2e, 0x37474F, 0x1a1a1a][i]; addM(g, new THREE.CylinderGeometry(0.03, 0.03, 0.3), makeMat(0xc0c0c0, 0.2, 0.7), -.3 + i * 0.3, 0.2 + i * 0.25, 0.1, false, 0, 0, Math.PI / 2); addM(g, new THREE.CylinderGeometry(0.06, 0.06, 0.06), makeMat(c), -.3 + i * 0.3, 0.2 + i * 0.25, -0.05); addM(g, new THREE.CylinderGeometry(0.06, 0.06, 0.06), makeMat(c), -.3 + i * 0.3, 0.2 + i * 0.25, 0.25); } return g; }
    function buildGamingChair() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.55, 0.08, 0.5), makeMat(0x1a1a1a), 0, 0.45, 0, true); addM(g, new THREE.BoxGeometry(0.55, 0.75, 0.08), makeMat(0xd32f2f), 0, 0.85, -0.21, true); addM(g, new THREE.BoxGeometry(0.08, 0.2, 0.06), makeMat(0xd32f2f), -.27, 1.15, -.21); addM(g, new THREE.BoxGeometry(0.08, 0.2, 0.06), makeMat(0xd32f2f), .27, 1.15, -.21); addM(g, new THREE.CylinderGeometry(0.03, 0.03, 0.45), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.225, 0); addM(g, new THREE.CylinderGeometry(0.15, 0.15, 0.02, 5), makeMat(0x1a1a1a), 0, 0.01, 0); return g; }

    // Construction extras
    function buildGlassWall() { const g = new THREE.Group(); const gl = new THREE.MeshStandardMaterial({ color: 0x88ccff, transparent: true, opacity: 0.3, roughness: 0.05, metalness: 0.1 }); const fr = makeMat(0xc0c0c0, 0.2, 0.7); addM(g, new THREE.BoxGeometry(1.8, 2.5, 0.04), gl, 0, 1.25, 0); addM(g, new THREE.BoxGeometry(0.04, 2.5, 0.06), fr, -.88, 1.25, 0); addM(g, new THREE.BoxGeometry(0.04, 2.5, 0.06), fr, 0.88, 1.25, 0); addM(g, new THREE.BoxGeometry(1.8, 0.04, 0.06), fr, 0, 2.48, 0); addM(g, new THREE.BoxGeometry(1.8, 0.04, 0.06), fr, 0, 0.02, 0); return g; }
    function buildBrickWall() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.8, 2.5, 0.18), makeMat(0xB74C2E), 0, 1.25, 0, true); for (let r = 0; r < 10; r++) { for (let c = 0; c < 6; c++) { const ox = (r % 2 === 0) ? 0 : 0.15; addM(g, new THREE.BoxGeometry(0.28, 0.22, 0.005), makeMat(0xA13D20), -.75 + c * 0.3 + ox, 0.12 + r * 0.25, 0.092); } } return g; }
    function buildWoodPanel() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.5, 2.5, 0.12), makeMat(0xDEB887), 0, 1.25, 0, true); for (let i = 0; i < 5; i++) { addM(g, new THREE.BoxGeometry(0.005, 2.5, 0.005), makeMat(0xC8A96E), -.6 + i * 0.3, 1.25, 0.065); } return g; }
    function buildHalfWall() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.8, 1.2, 0.15), makeMat(0xf8f4ef), 0, 0.6, 0, true); addM(g, new THREE.BoxGeometry(1.85, 0.06, 0.2), makeMat(0xe0d8cc), 0, 1.22, 0); return g; }
    function buildSlidingDoor() { const g = new THREE.Group(); const gl = new THREE.MeshStandardMaterial({ color: 0x88ccff, transparent: true, opacity: 0.35, roughness: 0.05 }); addM(g, new THREE.BoxGeometry(1.2, 2.2, 0.06), makeMat(0x424242), 0, 1.1, 0); addM(g, new THREE.BoxGeometry(1.1, 2.0, 0.02), gl, 0, 1.1, 0.02); addM(g, new THREE.BoxGeometry(1.3, 0.06, 0.08), makeMat(0xc0c0c0, 0.2, 0.7), 0, 2.23, 0); return g; }
    function buildDoubleDoor() { const g = new THREE.Group(); const fr = makeMat(0x4a3728, 0.6); const dr = makeMat(0x8B6F47, 0.7); const h = makeMat(0xD4AF37, 0.3, 0.6); addM(g, new THREE.BoxGeometry(1.8, 2.2, 0.1), fr, 0, 1.1, 0); addM(g, new THREE.BoxGeometry(0.8, 2.05, 0.04), dr, -.42, 1.05, 0.04, true); addM(g, new THREE.BoxGeometry(0.8, 2.05, 0.04), dr, .42, 1.05, 0.04, true); addM(g, new THREE.SphereGeometry(0.03), h, -.1, 1.05, 0.08); addM(g, new THREE.SphereGeometry(0.03), h, 0.1, 1.05, 0.08); return g; }
    function buildGarageDoor() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(2.5, 2.2, 0.1), makeMat(0x78909C), 0, 1.1, 0, true); for (let i = 0; i < 5; i++) { addM(g, new THREE.BoxGeometry(2.4, 0.02, 0.02), makeMat(0x90A4AE), 0, 0.2 + i * 0.44, 0.06); } return g; }
    function buildArch() { const g = new THREE.Group(); const m = makeMat(0xf5f0e8); addM(g, new THREE.BoxGeometry(0.15, 2.0, 0.2), m, -.6, 1.0, 0, true); addM(g, new THREE.BoxGeometry(0.15, 2.0, 0.2), m, .6, 1.0, 0, true); addM(g, new THREE.TorusGeometry(0.525, 0.08, 8, 16, Math.PI), m, 0, 2.0, 0); return g; }
    function buildBayWindow() { const g = new THREE.Group(); const gl = new THREE.MeshStandardMaterial({ color: 0x88ccff, transparent: true, opacity: 0.35, roughness: 0.1 }); const fr = makeMat(0xffffff, 0.5); addM(g, new THREE.BoxGeometry(0.5, 1.2, 0.04), gl, -.55, 1.5, -.2); addM(g, new THREE.BoxGeometry(0.8, 1.2, 0.04), gl, 0, 1.5, 0); addM(g, new THREE.BoxGeometry(0.5, 1.2, 0.04), gl, .55, 1.5, -.2); addM(g, new THREE.BoxGeometry(1.5, 0.06, 0.5), fr, 0, 0.88, -.1); return g; }
    function buildPanoramicWindow() { const g = new THREE.Group(); const gl = new THREE.MeshStandardMaterial({ color: 0x88ccff, transparent: true, opacity: 0.3, roughness: 0.05 }); const fr = makeMat(0x424242, 0.3, 0.5); addM(g, new THREE.BoxGeometry(2.5, 1.8, 0.04), gl, 0, 1.5, 0); addM(g, new THREE.BoxGeometry(2.6, 0.04, 0.06), fr, 0, 2.42, 0); addM(g, new THREE.BoxGeometry(2.6, 0.04, 0.06), fr, 0, 0.58, 0); addM(g, new THREE.BoxGeometry(0.04, 1.8, 0.06), fr, -1.28, 1.5, 0); addM(g, new THREE.BoxGeometry(0.04, 1.8, 0.06), fr, 1.28, 1.5, 0); return g; }
    function buildStainedGlass() { const g = new THREE.Group(); const fr = makeMat(0x5D4037); addM(g, new THREE.BoxGeometry(1.0, 1.4, 0.06), fr, 0, 1.5, 0); const cs = [0xff1744, 0x2979ff, 0x00e676, 0xffea00, 0xd500f9]; for (let i = 0; i < 5; i++) { addM(g, new THREE.BoxGeometry(0.16, 1.3, 0.02), new THREE.MeshStandardMaterial({ color: cs[i], transparent: true, opacity: 0.6, roughness: 0.3 }), -.32 + i * 0.16, 1.5, 0); } return g; }
    function buildSpiralStairs() { const g = new THREE.Group(); for (let i = 0; i < 10; i++) { const a = i * Math.PI / 5; const x = Math.cos(a) * 0.4; const z = Math.sin(a) * 0.4; addM(g, new THREE.BoxGeometry(0.8, 0.1, 0.3), makeMat(0x8B6F47), x, i * 0.2, z, true, 0, a, 0); } addM(g, new THREE.CylinderGeometry(0.04, 0.04, 2.0), makeMat(0xc0c0c0, 0.2, 0.7), 0, 1.0, 0); return g; }
    function buildFloatingSteps() { const g = new THREE.Group(); for (let i = 0; i < 8; i++) { addM(g, new THREE.BoxGeometry(0.8, 0.06, 0.3), makeMat(0x8B6F47), i % 2 === 0 ? -.1 : .1, i * 0.22, i * 0.3, true); } return g; }
    function buildSteelPillar() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.2, 3.0, 0.2), makeMat(0x616161, 0.3, 0.7), 0, 1.5, 0, true); addM(g, new THREE.BoxGeometry(0.35, 0.05, 0.35), makeMat(0x424242, 0.3, 0.7), 0, 0.025, 0); addM(g, new THREE.BoxGeometry(0.35, 0.05, 0.35), makeMat(0x424242, 0.3, 0.7), 0, 2.975, 0); return g; }
    // Exterior - Plants
    function buildTree() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.08, 0.12, 1.2), makeMat(0x5D4037), 0, 0.6, 0, true); addM(g, new THREE.SphereGeometry(0.5, 8, 8), makeMat(0x2E7D32), 0, 1.5, 0, true); addM(g, new THREE.SphereGeometry(0.35, 8, 8), makeMat(0x388E3C), 0.3, 1.3, 0.2, true); addM(g, new THREE.SphereGeometry(0.3, 8, 8), makeMat(0x43A047), -.25, 1.2, -.15, true); return g; }
    function buildBush() { const g = new THREE.Group(); addM(g, new THREE.SphereGeometry(0.35, 8, 8), makeMat(0x33691E), 0, 0.3, 0, true); addM(g, new THREE.SphereGeometry(0.25, 8, 8), makeMat(0x558B2F), 0.25, 0.25, 0.15, true); addM(g, new THREE.SphereGeometry(0.2, 8, 8), makeMat(0x689F38), -.2, 0.2, -.1, true); return g; }
    function buildFlowerBed() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.2, 0.15, 0.6), makeMat(0x5D4037), 0, 0.075, 0); addM(g, new THREE.BoxGeometry(1.1, 0.05, 0.5), makeMat(0x3E2723), 0, 0.175, 0); const fc = [0xE91E63, 0xFFEB3B, 0x9C27B0, 0xFF5722, 0x2196F3]; for (let i = 0; i < 5; i++) { addM(g, new THREE.SphereGeometry(0.06), makeMat(fc[i]), -.4 + i * 0.2, 0.26, Math.random() * 0.2 - .1); } for (let i = 0; i < 5; i++) { addM(g, new THREE.CylinderGeometry(0.01, 0.01, 0.08), makeMat(0x4CAF50), -.4 + i * 0.2, 0.22, Math.random() * 0.2 - .1); } return g; }
    function buildPalm() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.06, 0.1, 2.0), makeMat(0x795548), 0, 1.0, 0, true); for (let i = 0; i < 6; i++) { const a = i * Math.PI / 3; const leaf = new THREE.Mesh(new THREE.PlaneGeometry(0.15, 1.0), makeMat(0x2E7D32)); leaf.position.set(Math.cos(a) * 0.3, 2.0, Math.sin(a) * 0.3); leaf.rotation.set(-.8, a, 0); leaf.castShadow = true; g.add(leaf); } return g; }
    function buildLawn() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(2.0, 0.03, 2.0), makeMat(0x4CAF50, 0.9), 0, 0.015, 0); return g; }
    function buildCactus() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.1, 0.12, 0.2), makeMat(0xa0522d), 0, 0.1, 0, true); addM(g, new THREE.CylinderGeometry(0.06, 0.08, 0.5, 8), makeMat(0x2E7D32), 0, 0.45, 0, true); addM(g, new THREE.CylinderGeometry(0.04, 0.05, 0.25, 8), makeMat(0x388E3C), .12, 0.5, .02, true, 0, 0, .5); addM(g, new THREE.CylinderGeometry(0.04, 0.05, 0.2, 8), makeMat(0x388E3C), -.1, 0.4, -.02, true, 0, 0, -.6); return g; }
    // Exterior - Furniture
    function buildBench() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.4, 0.06, 0.4), makeMat(0x8B6F47), 0, 0.42, 0, true); addM(g, new THREE.BoxGeometry(1.4, 0.5, 0.06), makeMat(0x795548), 0, 0.67, -.17, true); const l = makeMat(0x424242, 0.4, 0.3); addM(g, new THREE.BoxGeometry(0.06, 0.42, 0.4), l, -.6, 0.21, 0); addM(g, new THREE.BoxGeometry(0.06, 0.42, 0.4), l, 0.6, 0.21, 0); return g; }
    function buildPatioSet() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.5, 0.5, 0.05, 16), makeMat(0x795548), 0, 0.7, 0, true); addM(g, new THREE.CylinderGeometry(0.06, 0.06, 0.7), makeMat(0x5D4037), 0, 0.35, 0); const ch = makeMat(0xBDBDBD); for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2; const x = Math.cos(a) * 0.8; const z = Math.sin(a) * 0.8; addM(g, new THREE.BoxGeometry(0.4, 0.06, 0.4), ch, x, 0.42, z, true); addM(g, new THREE.BoxGeometry(0.4, 0.35, 0.04), ch, x, 0.62, z - 0.18); } return g; }
    function buildBBQGrill() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.9, 0.5, 0.5), makeMat(0x424242), 0, 0.7, 0, true); addM(g, new THREE.BoxGeometry(0.85, 0.03, 0.45), makeMat(0x2c2c2e), -0, 0.97, 0); const l = makeMat(0x424242, 0.4, 0.3);[[-0.35, -0.2], [0.35, -0.2], [-0.35, 0.2], [0.35, 0.2]].forEach(([x, z]) => addM(g, new THREE.CylinderGeometry(0.03, 0.03, 0.45), l, x, 0.225, z)); addM(g, new THREE.BoxGeometry(0.45, 0.6, 0.04), makeMat(0x616161), 0.47, 1.2, 0); return g; }
    function buildGazebo() { const g = new THREE.Group(); const p = makeMat(0x8B6F47);[[-1, -1], [1, -1], [-1, 1], [1, 1]].forEach(([x, z]) => addM(g, new THREE.CylinderGeometry(0.06, 0.06, 2.5), p, x, 1.25, z, true)); addM(g, new THREE.ConeGeometry(1.8, 0.8, 4), makeMat(0x5D4037), 0, 2.9, 0, true); addM(g, new THREE.BoxGeometry(2.2, 0.06, 2.2), makeMat(0xDEB887), 0, 0.03, 0); return g; }
    function buildLounger() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.7, 0.12, 1.8), makeMat(0xffffff), 0, 0.35, 0, true); addM(g, new THREE.BoxGeometry(0.65, 0.06, 1.2), makeMat(0x4FC3F7, 0.8), 0, 0.43, -.2); addM(g, new THREE.BoxGeometry(0.65, 0.4, 0.06), makeMat(0xffffff), 0, 0.5, -.85, true); const l = makeMat(0xc0c0c0, 0.2, 0.7); addM(g, new THREE.CylinderGeometry(0.025, 0.025, 0.3), l, -.28, 0.15, -.75); addM(g, new THREE.CylinderGeometry(0.025, 0.025, 0.3), l, .28, 0.15, -.75); addM(g, new THREE.CylinderGeometry(0.025, 0.025, 0.3), l, -.28, 0.15, .75); addM(g, new THREE.CylinderGeometry(0.025, 0.025, 0.3), l, .28, 0.15, .75); return g; }
    function buildSwing() { const g = new THREE.Group(); const fr = makeMat(0x8B6F47); addM(g, new THREE.CylinderGeometry(0.04, 0.04, 2.5), fr, -.6, 1.25, 0, true); addM(g, new THREE.CylinderGeometry(0.04, 0.04, 2.5), fr, .6, 1.25, 0, true); addM(g, new THREE.BoxGeometry(1.3, 0.04, 0.04), fr, 0, 2.5, 0); const ch = makeMat(0xc0c0c0, 0.2, 0.7); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 1.5), ch, -.2, 1.75, 0); addM(g, new THREE.CylinderGeometry(0.015, 0.015, 1.5), ch, .2, 1.75, 0); addM(g, new THREE.BoxGeometry(0.5, 0.04, 0.3), makeMat(0x795548), 0, 1.0, 0, true); return g; }
    function buildUmbrella() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.03, 0.03, 2.2), makeMat(0x795548), 0, 1.1, 0, true); addM(g, new THREE.ConeGeometry(1.2, 0.4, 16), makeMat(0xE53935), 0, 2.4, 0, true); addM(g, new THREE.CylinderGeometry(0.2, 0.2, 0.06, 16), makeMat(0x424242), 0, 0.03, 0); return g; }
    // Exterior - Water
    function buildPool() { const g = new THREE.Group(); const wm = new THREE.MeshStandardMaterial({ color: 0x29B6F6, transparent: true, opacity: 0.6, roughness: 0.1 }); addM(g, new THREE.BoxGeometry(3.0, 0.3, 1.8), makeMat(0x90CAF9, 0.3), 0, 0.15, 0); addM(g, new THREE.BoxGeometry(2.8, 0.2, 1.6), wm, 0, 0.25, 0); return g; }
    function buildFountain() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.5, 0.6, 0.3, 16), makeMat(0x9E9E9E), 0, 0.15, 0, true); const wm = new THREE.MeshStandardMaterial({ color: 0x64B5F6, transparent: true, opacity: 0.5, roughness: 0.1 }); addM(g, new THREE.CylinderGeometry(0.45, 0.45, 0.1, 16), wm, 0, 0.35, 0); addM(g, new THREE.CylinderGeometry(0.04, 0.04, 0.6), makeMat(0xBDBDBD), 0, 0.65, 0); addM(g, new THREE.CylinderGeometry(0.25, 0.3, 0.15, 16), makeMat(0x9E9E9E), 0, 0.95, 0); return g; }
    function buildJacuzzi() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.9, 0.9, 0.5, 16), makeMat(0x795548), 0, 0.25, 0, true); const wm = new THREE.MeshStandardMaterial({ color: 0x4FC3F7, transparent: true, opacity: 0.6, roughness: 0.1 }); addM(g, new THREE.CylinderGeometry(0.8, 0.8, 0.15, 16), wm, 0, 0.45, 0); return g; }
    function buildPond() { const g = new THREE.Group(); const wm = new THREE.MeshStandardMaterial({ color: 0x26C6DA, transparent: true, opacity: 0.5, roughness: 0.15 }); addM(g, new THREE.CylinderGeometry(1.0, 1.2, 0.1, 24), makeMat(0x5D4037), 0, 0.05, 0); addM(g, new THREE.CylinderGeometry(0.9, 0.9, 0.08, 24), wm, 0, 0.1, 0); for (let i = 0; i < 5; i++) { const a = i * Math.PI * 2 / 5; addM(g, new THREE.SphereGeometry(0.15), makeMat(0x757575), .9 * Math.cos(a), 0.12, .9 * Math.sin(a)); } return g; }
    // Exterior - Structures
    function buildFence() { const g = new THREE.Group(); for (let i = 0; i < 6; i++) { addM(g, new THREE.BoxGeometry(0.06, 1.0, 0.04), makeMat(0xDEB887), -.5 + i * 0.2, 0.5, 0, true); } addM(g, new THREE.BoxGeometry(1.2, 0.06, 0.04), makeMat(0xC8A96E), 0, 0.8, 0); addM(g, new THREE.BoxGeometry(1.2, 0.06, 0.04), makeMat(0xC8A96E), 0, 0.3, 0); return g; }
    function buildStoneWall() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.8, 1.2, 0.2), makeMat(0x9E9E9E), 0, 0.6, 0, true); for (let r = 0; r < 4; r++) { for (let c = 0; c < 4; c++) { const w = 0.35 + Math.random() * 0.1; addM(g, new THREE.BoxGeometry(w, 0.25, 0.01), makeMat(0x757575 + Math.floor(Math.random() * 0x222222)), -.6 + c * 0.4, 0.15 + r * 0.3, 0.11); } } return g; }
    function buildPergola() { const g = new THREE.Group(); const w = makeMat(0x8B6F47);[[-1, -.5], [1, -.5], [-1, .5], [1, .5]].forEach(([x, z]) => addM(g, new THREE.CylinderGeometry(0.05, 0.05, 2.5), w, x, 1.25, z, true)); for (let i = 0; i < 5; i++) { addM(g, new THREE.BoxGeometry(0.08, 0.08, 1.2), w, -.8 + i * 0.4, 2.5, 0); } addM(g, new THREE.BoxGeometry(2.2, 0.06, 0.06), w, 0, 2.45, -.45); addM(g, new THREE.BoxGeometry(2.2, 0.06, 0.06), w, 0, 2.45, .45); return g; }
    function buildPathway() { const g = new THREE.Group(); for (let i = 0; i < 6; i++) { addM(g, new THREE.CylinderGeometry(0.2, 0.2, 0.03, 6), makeMat(0x9E9E9E + Math.floor(Math.random() * 0x111111)), i % 2 === 0 ? -.1 : .1, 0.015, i * 0.35 - 0.7); } return g; }
    function buildShed() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(1.5, 1.5, 1.2), makeMat(0x795548), 0, 0.75, 0, true); addM(g, new THREE.BoxGeometry(0.5, 1.0, 0.04), makeMat(0x5D4037), 0, 0.5, 0.62, true); addM(g, new THREE.SphereGeometry(0.02), makeMat(0xD4AF37, 0.3, 0.6), 0.15, 0.55, 0.64); const roof = new THREE.Mesh(new THREE.BoxGeometry(1.7, 0.06, 1.4), makeMat(0x4E342E)); roof.position.set(0, 1.53, 0); roof.rotation.z = 0.15; roof.castShadow = true; g.add(roof); return g; }
    function buildPathLight() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.02, 0.02, 0.6), makeMat(0x424242, 0.3, 0.5), 0, 0.3, 0); addM(g, new THREE.SphereGeometry(0.06), makeMat(0xFFF9C4, 0.8), 0, 0.65, 0); const li = new THREE.PointLight(0xfff5cc, 0.3, 2); li.position.set(0, 0.65, 0); g.add(li); return g; }
    function buildLantern() { const g = new THREE.Group(); addM(g, new THREE.BoxGeometry(0.15, 0.15, 0.15), makeMat(0x424242), 0, 0.075, 0); addM(g, new THREE.BoxGeometry(0.12, 0.2, 0.12), new THREE.MeshStandardMaterial({ color: 0xFFD54F, transparent: true, opacity: 0.6 }), 0, 0.25, 0); addM(g, new THREE.BoxGeometry(0.16, 0.03, 0.16), makeMat(0x424242), 0, 0.36, 0); const li = new THREE.PointLight(0xffd740, 0.4, 3); li.position.set(0, 0.25, 0); g.add(li); return g; }
    function buildDecor() { const g = new THREE.Group(); addM(g, new THREE.CylinderGeometry(0.12, 0.08, 0.35), makeMat(0xE8D5B7), 0, 0.175, 0, true); addM(g, new THREE.SphereGeometry(0.08), makeMat(0x4CAF50), 0, 0.4, 0, true); return g; }

    // ─── Missing Builder Implementations ───
    function buildRoomPlaceholder() {
      const g = new THREE.Group();
      // Outline box to represent a room
      addM(g, new THREE.BoxGeometry(3.0, 0.04, 3.0), makeMat(0x78909C, 0.5), 0, 0.02, 0);
      // Corner posts
      const postMat = makeMat(0xBDBDBD, 0.3, 0.5);
      [[-1.45, -1.45], [1.45, -1.45], [-1.45, 1.45], [1.45, 1.45]].forEach(([x, z]) => {
        addM(g, new THREE.CylinderGeometry(0.04, 0.04, 2.5), postMat, x, 1.25, z, true);
      });
      // Top frame
      addM(g, new THREE.BoxGeometry(3.0, 0.04, 0.04), postMat, 0, 2.5, -1.45);
      addM(g, new THREE.BoxGeometry(3.0, 0.04, 0.04), postMat, 0, 2.5, 1.45);
      addM(g, new THREE.BoxGeometry(0.04, 0.04, 3.0), postMat, -1.45, 2.5, 0);
      addM(g, new THREE.BoxGeometry(0.04, 0.04, 3.0), postMat, 1.45, 2.5, 0);
      return g;
    }

    function buildWallSegment() {
      const g = new THREE.Group();
      addM(g, new THREE.BoxGeometry(1.8, 2.5, 0.12), makeMat(0xf5f0e8, 0.8), 0, 1.25, 0, true);
      // Baseboard
      addM(g, new THREE.BoxGeometry(1.85, 0.1, 0.14), makeMat(0xddd8d0), 0, 0.05, 0);
      // Crown moulding
      addM(g, new THREE.BoxGeometry(1.85, 0.06, 0.14), makeMat(0xddd8d0), 0, 2.47, 0);
      return g;
    }

    function buildDoorPlaceholder() {
      const g = new THREE.Group();
      // Frame
      const frameMat = makeMat(0x4a3728, 0.6);
      addM(g, new THREE.BoxGeometry(1.0, 2.2, 0.1), frameMat, 0, 1.1, 0);
      // Door panel
      addM(g, new THREE.BoxGeometry(0.85, 2.05, 0.05), makeMat(0x8B6F47, 0.7), 0, 1.05, 0.04, true);
      // Door panels detail
      addM(g, new THREE.BoxGeometry(0.6, 0.7, 0.02), makeMat(0x7a5f37), 0, 1.5, 0.07);
      addM(g, new THREE.BoxGeometry(0.6, 0.7, 0.02), makeMat(0x7a5f37), 0, 0.6, 0.07);
      // Handle
      addM(g, new THREE.SphereGeometry(0.03), makeMat(0xD4AF37, 0.3, 0.6), 0.3, 1.05, 0.08);
      return g;
    }

    function buildWindowPlaceholder() {
      const g = new THREE.Group();
      const glassMat = new THREE.MeshStandardMaterial({ color: 0x88ccff, transparent: true, opacity: 0.35, roughness: 0.1 });
      const frameMat = makeMat(0xffffff, 0.5);
      // Frame
      addM(g, new THREE.BoxGeometry(1.0, 1.2, 0.06), frameMat, 0, 1.5, 0);
      // Glass
      addM(g, new THREE.BoxGeometry(0.9, 1.1, 0.02), glassMat, 0, 1.5, 0);
      // Crossbar
      addM(g, new THREE.BoxGeometry(0.04, 1.1, 0.04), frameMat, 0, 1.5, 0);
      addM(g, new THREE.BoxGeometry(0.9, 0.04, 0.04), frameMat, 0, 1.5, 0);
      // Sill
      addM(g, new THREE.BoxGeometry(1.1, 0.05, 0.12), frameMat, 0, 0.88, 0.03);
      return g;
    }

    function buildBathtub() {
      const g = new THREE.Group();
      // Outer shell
      addM(g, new THREE.BoxGeometry(1.6, 0.55, 0.75), makeMat(0xfafafa, 0.2, 0.1), 0, 0.275, 0, true);
      // Inner cavity (darker)
      addM(g, new THREE.BoxGeometry(1.4, 0.4, 0.6), makeMat(0xf0f0f0, 0.15, 0.05), 0, 0.35, 0);
      // Water surface
      const waterMat = new THREE.MeshStandardMaterial({ color: 0x64B5F6, transparent: true, opacity: 0.5, roughness: 0.1 });
      addM(g, new THREE.BoxGeometry(1.35, 0.02, 0.55), waterMat, 0, 0.44, 0);
      // Faucet
      addM(g, new THREE.CylinderGeometry(0.025, 0.025, 0.2), makeMat(0xc0c0c0, 0.2, 0.8), 0, 0.65, -0.3);
      addM(g, new THREE.CylinderGeometry(0.025, 0.025, 0.12), makeMat(0xc0c0c0, 0.2, 0.8), 0, 0.74, -0.24, false, 0, 0, Math.PI / 3);
      // Feet
      const footMat = makeMat(0xD4AF37, 0.3, 0.6);
      [[-0.65, -0.3], [0.65, -0.3], [-0.65, 0.3], [0.65, 0.3]].forEach(([x, z]) => {
        addM(g, new THREE.SphereGeometry(0.04), footMat, x, 0.04, z);
      });
      return g;
    }

    function buildShower() {
      const g = new THREE.Group();
      // Base tray
      addM(g, new THREE.BoxGeometry(1.0, 0.08, 1.0), makeMat(0xfafafa, 0.2, 0.1), 0, 0.04, 0);
      // Glass walls (L-shaped)
      const glassMat = new THREE.MeshStandardMaterial({ color: 0x88ccff, transparent: true, opacity: 0.2, roughness: 0.05 });
      addM(g, new THREE.BoxGeometry(1.0, 2.0, 0.04), glassMat, 0, 1.08, -0.48);
      addM(g, new THREE.BoxGeometry(0.04, 2.0, 1.0), glassMat, -0.48, 1.08, 0);
      // Shower frame
      const frameMat = makeMat(0xc0c0c0, 0.2, 0.8);
      addM(g, new THREE.CylinderGeometry(0.02, 0.02, 2.0), frameMat, -0.48, 1.08, -0.48, true);
      // Shower head
      addM(g, new THREE.CylinderGeometry(0.02, 0.02, 0.8), frameMat, 0, 1.7, -0.44);
      addM(g, new THREE.CylinderGeometry(0.08, 0.08, 0.03, 16), frameMat, 0, 2.08, -0.44);
      // Handle
      addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.15), frameMat, 0.15, 1.2, -0.44, false, 0, 0, Math.PI / 2);
      return g;
    }

    function buildToilet() {
      const g = new THREE.Group();
      // Base / bowl
      addM(g, new THREE.CylinderGeometry(0.2, 0.22, 0.35, 16), makeMat(0xfafafa, 0.2, 0.1), 0, 0.175, 0.1, true);
      // Seat rim
      addM(g, new THREE.TorusGeometry(0.18, 0.04, 8, 16), makeMat(0xf5f5f5, 0.2, 0.05), 0, 0.38, 0.1, false, Math.PI / 2, 0, 0);
      // Tank
      addM(g, new THREE.BoxGeometry(0.38, 0.45, 0.18), makeMat(0xfafafa, 0.2, 0.1), 0, 0.5, -0.2, true);
      // Lid
      addM(g, new THREE.BoxGeometry(0.4, 0.04, 0.2), makeMat(0xf0f0f0, 0.2, 0.05), 0, 0.74, -0.2);
      // Flush button
      addM(g, new THREE.CylinderGeometry(0.03, 0.03, 0.02, 8), makeMat(0xc0c0c0, 0.2, 0.7), 0, 0.76, -0.2);
      return g;
    }

    function buildStairs() {
      const g = new THREE.Group();
      const stepMat = makeMat(0x8B6F47);
      const railMat = makeMat(0xc0c0c0, 0.2, 0.7);
      for (let i = 0; i < 8; i++) {
        addM(g, new THREE.BoxGeometry(1.0, 0.08, 0.3), stepMat, 0, i * 0.22 + 0.04, i * 0.3, true);
      }
      // Side rails
      addM(g, new THREE.CylinderGeometry(0.025, 0.025, 2.5), railMat, -0.52, 1.0, 0.8, true, 0, 0, 0.68);
      addM(g, new THREE.CylinderGeometry(0.025, 0.025, 2.5), railMat, 0.52, 1.0, 0.8, true, 0, 0, 0.68);
      // Rail posts
      for (let i = 0; i < 4; i++) {
        addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.4 + i * 0.2), railMat, -0.52, 0.2 + i * 0.22, i * 0.6);
        addM(g, new THREE.CylinderGeometry(0.015, 0.015, 0.4 + i * 0.2), railMat, 0.52, 0.2 + i * 0.22, i * 0.6);
      }
      return g;
    }

    function buildColumn() {
      const g = new THREE.Group();
      // Base
      addM(g, new THREE.BoxGeometry(0.4, 0.15, 0.4), makeMat(0xE0E0E0, 0.3, 0.1), 0, 0.075, 0, true);
      // Shaft
      addM(g, new THREE.CylinderGeometry(0.12, 0.14, 2.5, 12), makeMat(0xEEEEEE, 0.3, 0.1), 0, 1.4, 0, true);
      // Capital
      addM(g, new THREE.BoxGeometry(0.45, 0.15, 0.45), makeMat(0xE0E0E0, 0.3, 0.1), 0, 2.725, 0);
      // Fluting detail (subtle lines via thin cylinders)
      for (let i = 0; i < 8; i++) {
        const a = i * Math.PI / 4;
        addM(g, new THREE.CylinderGeometry(0.005, 0.005, 2.3), makeMat(0xD5D5D5), Math.cos(a) * 0.13, 1.4, Math.sin(a) * 0.13);
      }
      return g;
    }

    