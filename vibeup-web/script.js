/* ═══════════════════════════════════════════════════════════════
   VIBEUP — script.js  
   Cinematic Scroll-Driven 3D Interior Design Experience
   
   Flow:
   1. Loading Screen 0→100%
   2. Door opens on scroll (POV entry)
   3. Wireframe house skeleton appears
   4. House EXPLODES into separated room frames
   5. Each room frame reveals content (materials, furniture, text)
   6. Interactive customization phase
   ═══════════════════════════════════════════════════════════════ */

// ─────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────
const PRESETS = {
    wood:   { floor: '#3d2817', wall: '#2a1f14', accent: '#c9a040', label: 'Natural Wood' },
    marble: { floor: '#e8e4de', wall: '#d4cfc8', accent: '#8a7a6a', label: 'Italian Marble' },
    modern: { floor: '#1a1a1e', wall: '#0d0d10', accent: '#00d4ff', label: 'Ultra Modern' },
};

const GOLD = 0xc9a84c;
const WIRE_COLOR = 0xc9a84c;     // Gold wireframe
const WIRE_DIM   = 0x3a3020;     // Dim gold for subtle edges
const BG_COLOR   = 0x0a0a0a;

const state = {
    material: 'wood',
    isNight: false,
    isWireframe: false,
    showNew: true,
};

// ─────────────────────────────────────────────────────────────
// 1. LOADING SCREEN & MOTION ENGINE (Lenis)
// ─────────────────────────────────────────────────────────────
let lenis;

(function initLoader() {
    const fill = document.getElementById('loader-bar-fill');
    const pct  = document.getElementById('loader-percent');
    const loader = document.getElementById('loader');
    let progress = 0;

    // Initialize Lenis Smooth Scroll immediately
    if (typeof Lenis !== 'undefined') {
        lenis = new Lenis({
            duration: 1.2,
            easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
            orientation: 'vertical',
            gestureOrientation: 'vertical',
            smoothWheel: true,
            wheelMultiplier: 1,
            smoothTouch: false,
            touchMultiplier: 2,
            infinite: false,
        });

        function raf(time) {
            lenis.raf(time);
            requestAnimationFrame(raf);
        }
        requestAnimationFrame(raf);
    }

    function tick() {
        const remaining = 100 - progress;
        const inc = Math.random() * Math.min(remaining * 0.12, 6);
        progress = Math.min(progress + inc, 100);
        fill.style.width = progress + '%';
        pct.textContent = Math.floor(progress) + '%';

        if (progress < 99.5) {
            requestAnimationFrame(tick);
        } else {
            fill.style.width = '100%';
            pct.textContent = '100%';
            setTimeout(() => {
                loader.classList.add('done');
                onLoadingComplete();
            }, 600);
        }
    }
    setTimeout(tick, 400);
})();

function onLoadingComplete() {
    const navbar = document.getElementById('navbar');
    const heroContent = document.querySelector('.hero-content');
    const scrollHint = document.getElementById('scroll-indicator');

    setTimeout(() => navbar && navbar.classList.add('visible'), 100);

    // Make hero content visible (it starts at opacity:0 in CSS)
    setTimeout(() => {
        if (heroContent) {
            heroContent.style.transition = 'opacity 1.2s cubic-bezier(0.16,1,0.3,1), transform 1.2s cubic-bezier(0.16,1,0.3,1)';
            heroContent.style.opacity = '1';
            heroContent.style.transform = 'translateY(0)';
        }
    }, 400);
    setTimeout(() => {
        if (scrollHint) {
            scrollHint.style.transition = 'opacity 1s';
            scrollHint.style.opacity = '1';
        }
    }, 1200);

    // Global Reveal logic for other sections
    initGlobalReveals();
    initMagneticElements();

    setTimeout(() => {
        init3D();
        initScrollEngine();
        initUIHandlers();
    }, 200);
}

function initGlobalReveals() {
    const revealElements = document.querySelectorAll('[data-reveal]');
    revealElements.forEach((el, index) => {
        gsap.to(el, {
            scrollTrigger: {
                trigger: el,
                start: 'top 90%',
                onEnter: () => el.classList.add('reveal-active')
            }
        });
    });
}

function initMagneticElements() {
    const magnetics = document.querySelectorAll('[data-magnetic]');
    magnetics.forEach(el => {
        el.addEventListener('mousemove', (e) => {
            const bound = el.getBoundingClientRect();
            const x = e.clientX - bound.left - bound.width / 2;
            const y = e.clientY - bound.top - bound.height / 2;
            
            gsap.to(el, {
                x: x * 0.45,
                y: y * 0.45,
                duration: 0.6,
                ease: 'power3.out'
            });
        });
        
        el.addEventListener('mouseleave', () => {
            gsap.to(el, {
                x: 0,
                y: 0,
                duration: 0.8,
                ease: 'elastic.out(1, 0.3)'
            });
        });
    });
}

// Navbar scroll
window.addEventListener('scroll', () => {
    const nb = document.getElementById('navbar');
    if (nb) nb.classList.toggle('scrolled', window.scrollY > 80);
}, { passive: true });

// ─────────────────────────────────────────────────────────────
// 2. THREE.JS SCENE SETUP
// ─────────────────────────────────────────────────────────────
let scene, camera, renderer;

// Door refs
let doorL, doorR;

// Wireframe house skeleton group (all edges)
let houseWire;

// Exploded room groups — each is an independently moveable section
let roofGroup, floorGroup;
let roomLiving, roomKitchen, roomBedroom, roomBathroom;
let wallFront, wallBack, wallLeft, wallRight;

// Filled/Rendered versions inside each room
let livingFilled, kitchenFilled, bedroomFilled, bathroomFilled;

// Lighting
let ambientLight, spotFront, sunLight, nightFill;

// Particles and floating background elements
let particles;
let floaters = [];

// Chronos Update: Liquid Glass Portal
let portalMembrane;
let portalShards = [];
let portalMaterials = {}; // for floating theme swaps

function init3D() {
    const container = document.getElementById('three-canvas-container');
    if (!container || typeof THREE === 'undefined') return;

    scene = new THREE.Scene();
    scene.fog = new THREE.Fog(BG_COLOR, 6, 40);

    camera = new THREE.PerspectiveCamera(50, container.clientWidth / container.clientHeight, 0.1, 200);
    camera.position.set(0, 1.6, 8);

    renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.setClearColor(BG_COLOR);
    container.appendChild(renderer.domElement);

    // Lighting
    ambientLight = new THREE.AmbientLight(0x888899, 0.08);
    scene.add(ambientLight);

    spotFront = new THREE.SpotLight(0xe8d5b5, 2, 0, 0.5, 0.8);
    spotFront.position.set(0, 5, 10);
    scene.add(spotFront);

    sunLight = new THREE.DirectionalLight(0xfff5e0, 0.6);
    sunLight.position.set(8, 10, 5);
    scene.add(sunLight);

    nightFill = new THREE.PointLight(0x2244aa, 0, 20);
    nightFill.position.set(0, 2, -5);
    scene.add(nightFill);

    // Build everything
    buildDoorFrame();
    buildPortalMembrane();
    buildWireframeHouse();
    buildFilledRooms();
    buildParticles();
    buildFloaters();

    window.addEventListener('resize', onResize);
    requestAnimationFrame(renderLoop);
}

// ─────────────────────────────────────────────────────────────
// 3. DOOR FRAME (entry point)
// ─────────────────────────────────────────────────────────────
function buildDoorFrame() {
    const frameMat = new THREE.MeshStandardMaterial({ color: 0x1a1a1c, roughness: 0.8 });
    const goldMat  = new THREE.MeshStandardMaterial({ color: GOLD, metalness: 0.9, roughness: 0.15 });
    const woodMat  = new THREE.MeshStandardMaterial({ color: 0x2a1810, roughness: 0.35, metalness: 0.05 });

    // Frame around door
    const fL = new THREE.Mesh(new THREE.BoxGeometry(2.5, 3.2, 0.15), frameMat);
    fL.position.set(-2.25, 1.6, 0);
    const fR = new THREE.Mesh(new THREE.BoxGeometry(2.5, 3.2, 0.15), frameMat);
    fR.position.set(2.25, 1.6, 0);
    const fT = new THREE.Mesh(new THREE.BoxGeometry(2, 0.6, 0.15), frameMat);
    fT.position.set(0, 2.9, 0);
    scene.add(fL, fR, fT);

    // Gold sill
    const sill = new THREE.Mesh(new THREE.BoxGeometry(2.1, 0.03, 0.12), goldMat);
    sill.position.set(0, 0.005, 0.05);
    scene.add(sill);

    // Left door
    doorL = new THREE.Group();
    doorL.position.set(-1, 0, 0);
    const panelL = new THREE.Mesh(new THREE.BoxGeometry(0.98, 2.38, 0.06), woodMat);
    panelL.position.set(0.5, 1.2, 0);
    const moldL1 = new THREE.Mesh(new THREE.BoxGeometry(0.6, 0.7, 0.012), new THREE.MeshStandardMaterial({ color: 0x231208 }));
    moldL1.position.set(0.5, 1.75, 0.035);
    const moldL2 = moldL1.clone(); moldL2.position.y = 0.65;
    const handleL = new THREE.Mesh(new THREE.CylinderGeometry(0.012, 0.012, 0.12, 8), goldMat.clone());
    handleL.rotation.x = Math.PI / 2; handleL.position.set(0.85, 1.2, 0.06);
    doorL.add(panelL, moldL1, moldL2, handleL);
    scene.add(doorL);

    // Right door (mirror)
    doorR = new THREE.Group();
    doorR.position.set(1, 0, 0);
    const panelR = new THREE.Mesh(new THREE.BoxGeometry(0.98, 2.38, 0.06), woodMat.clone());
    panelR.position.set(-0.5, 1.2, 0);
    const moldR1 = moldL1.clone(); moldR1.position.set(-0.5, 1.75, 0.035);
    const moldR2 = moldL1.clone(); moldR2.position.set(-0.5, 0.65, 0.035);
    const handleR = handleL.clone(); handleR.position.set(-0.85, 1.2, 0.06);
    doorR.add(panelR, moldR1, moldR2, handleR);
    scene.add(doorR);
}

// ─────────────────────────────────────────────────────────────
// 3.5 LIQUID GLASS PORTAL & SHARDS (The Chronos Update)
// ─────────────────────────────────────────────────────────────
function buildPortalMembrane() {
    // 1. A dense plane right behind the doors
    // Plane is slightly wider than the doorframe (2w x 3.2h)
    const geo = new THREE.PlaneGeometry(2.2, 3.4, 32, 32); 
    const mat = new THREE.MeshPhysicalMaterial({
        color: 0xaaeeff,
        metalness: 0.1,
        roughness: 0.05,
        transmission: 0.95, // glass refraction effect
        thickness: 0.5,
        transparent: true,
        opacity: 0.8,
        side: THREE.DoubleSide
    });
    portalMembrane = new THREE.Mesh(geo, mat);
    portalMembrane.position.set(0, 1.6, -0.05); // slightly behind the doors
    scene.add(portalMembrane);

    // 2. The Shard Pool (hidden initially)
    const baseShardMat = new THREE.MeshPhysicalMaterial({
        color: 0xffffff,
        metalness: 0.2,
        roughness: 0.1,
        transmission: 0.9,
        transparent: true,
        opacity: 1
    });

    for(let i=0; i<40; i++) {
        // Random irregular shards
        const shardGeo = new THREE.TetrahedronGeometry(Math.random() * 0.2 + 0.1, 0);
        shardGeo.scale(1, Math.random()*2+0.5, 1);
        const shard = new THREE.Mesh(shardGeo, baseShardMat.clone());
        shard.visible = false;
        
        // Setup shard physics vectors
        shard.userData = {
            velocity: new THREE.Vector3(
                (Math.random() - 0.5) * 8, // throw left/right
                (Math.random() - 0.5) * 8, // throw up/down
                (Math.random() * 5) + 5    // throw deeply backwards away from camera (-z)
            ),
            rotSpeed: new THREE.Vector3(
                Math.random() * 0.4 - 0.2,
                Math.random() * 0.4 - 0.2,
                Math.random() * 0.4 - 0.2
            ),
            active: false
        };
        scene.add(shard);
        portalShards.push(shard);
    }
}

// ─────────────────────────────────────────────────────────────
// 4. WIREFRAME HOUSE — The "Skeleton" Blueprint
//    Gold neon edges on black, 2-story house outline
// ─────────────────────────────────────────────────────────────
function buildWireframeHouse() {
    houseWire = new THREE.Group();
    houseWire.position.set(0, 0, -8);  // Behind the door
    houseWire.visible = false;         // Hidden until door opens
    scene.add(houseWire);

    const wireMat = new THREE.LineBasicMaterial({ color: WIRE_COLOR, linewidth: 1 });
    const wireDim = new THREE.LineBasicMaterial({ color: WIRE_DIM, linewidth: 1, transparent: true, opacity: 0.4 });

    // House dimensions: 10 wide, 6 deep, 3.2 tall per floor, 2 floors
    const W = 10, D = 6, H1 = 3.2, H2 = 6.4;

    // Helper: create wireframe box (EdgesGeometry)
    function wireBox(w, h, d) {
        const geo = new THREE.BoxGeometry(w, h, d);
        const edges = new THREE.EdgesGeometry(geo);
        return edges;
    }

    // ── ROOF (triangular prism outline) ──
    roofGroup = new THREE.Group();
    // Flat roof slab for simplicity (we'll use box edges)
    const roofEdges = new THREE.LineSegments(wireBox(W + 0.4, 0.15, D + 0.4), wireMat.clone());
    roofEdges.position.y = H2 + 0.08;
    roofGroup.add(roofEdges);
    // Roof accent line
    const roofLine = new THREE.LineSegments(wireBox(W - 0.5, 0.05, D - 0.5), wireDim.clone());
    roofLine.position.y = H2 + 0.2;
    roofGroup.add(roofLine);
    houseWire.add(roofGroup);

    // ── FLOOR SLAB (between stories + ground) ──
    floorGroup = new THREE.Group();
    const g1 = new THREE.LineSegments(wireBox(W, 0.1, D), wireMat.clone());
    g1.position.y = 0;
    const g2 = new THREE.LineSegments(wireBox(W, 0.1, D), wireMat.clone());
    g2.position.y = H1;
    floorGroup.add(g1, g2);
    houseWire.add(floorGroup);

    // ── OUTER WALLS (4 walls, each is a wireframe outline) ──
    // Front wall (with door cutout represented by 2 sections)
    wallFront = new THREE.Group();
    const wfL = new THREE.LineSegments(wireBox(3, H2, 0.1), wireMat.clone());
    wfL.position.set(-3.5, H2 / 2, D / 2);
    const wfR = new THREE.LineSegments(wireBox(3, H2, 0.1), wireMat.clone());
    wfR.position.set(3.5, H2 / 2, D / 2);
    const wfT = new THREE.LineSegments(wireBox(4, H2 - H1, 0.1), wireMat.clone());
    wfT.position.set(0, H1 + (H2 - H1) / 2, D / 2);
    wallFront.add(wfL, wfR, wfT);
    houseWire.add(wallFront);

    wallBack = new THREE.Group();
    const wb = new THREE.LineSegments(wireBox(W, H2, 0.1), wireMat.clone());
    wb.position.set(0, H2 / 2, -D / 2);
    wallBack.add(wb);
    houseWire.add(wallBack);

    wallLeft = new THREE.Group();
    const wl = new THREE.LineSegments(wireBox(0.1, H2, D), wireMat.clone());
    wl.position.set(-W / 2, H2 / 2, 0);
    wallLeft.add(wl);
    houseWire.add(wallLeft);

    wallRight = new THREE.Group();
    const wr = new THREE.LineSegments(wireBox(0.1, H2, D), wireMat.clone());
    wr.position.set(W / 2, H2 / 2, 0);
    wallRight.add(wr);
    houseWire.add(wallRight);

    // ── INTERIOR ROOM DIVIDERS (cross-shaped) ──
    // Vertical divider (left-right split)
    const divV = new THREE.LineSegments(wireBox(0.06, H1, D), wireDim.clone());
    divV.position.set(0, H1 / 2, 0);
    houseWire.add(divV);

    // Horizontal divider (front-back split)
    const divH = new THREE.LineSegments(wireBox(W, H1, 0.06), wireDim.clone());
    divH.position.set(0, H1 / 2, 0);
    houseWire.add(divH);

    // ── ROOM WIREFRAME GROUPS (for explosion) ──
    // These are groups that wrap the "room section" concept
    // Living Room = Front-Left
    roomLiving = new THREE.Group();
    roomLiving.userData = { origPos: new THREE.Vector3(0, 0, 0) };
    const rlBox = new THREE.LineSegments(wireBox(5, H1, 3), new THREE.LineBasicMaterial({ color: WIRE_COLOR }));
    rlBox.position.set(-2.5, H1 / 2, 1.5);
    roomLiving.add(rlBox);
    // Room label (simple sprite)
    roomLiving.userData.label = 'Living Room';
    houseWire.add(roomLiving);

    // Kitchen = Front-Right
    roomKitchen = new THREE.Group();
    roomKitchen.userData = { origPos: new THREE.Vector3(0, 0, 0) };
    const rkBox = new THREE.LineSegments(wireBox(5, H1, 3), new THREE.LineBasicMaterial({ color: WIRE_COLOR }));
    rkBox.position.set(2.5, H1 / 2, 1.5);
    roomKitchen.add(rkBox);
    roomKitchen.userData.label = 'Kitchen';
    houseWire.add(roomKitchen);

    // Bedroom = Back-Left
    roomBedroom = new THREE.Group();
    roomBedroom.userData = { origPos: new THREE.Vector3(0, 0, 0) };
    const rbBox = new THREE.LineSegments(wireBox(5, H1, 3), new THREE.LineBasicMaterial({ color: WIRE_COLOR }));
    rbBox.position.set(-2.5, H1 / 2, -1.5);
    roomBedroom.add(rbBox);
    roomBedroom.userData.label = 'Bedroom';
    houseWire.add(roomBedroom);

    // Bathroom = Back-Right
    roomBathroom = new THREE.Group();
    roomBathroom.userData = { origPos: new THREE.Vector3(0, 0, 0) };
    const rbtBox = new THREE.LineSegments(wireBox(5, H1, 3), new THREE.LineBasicMaterial({ color: WIRE_COLOR }));
    rbtBox.position.set(2.5, H1 / 2, -1.5);
    roomBathroom.add(rbtBox);
    roomBathroom.userData.label = 'Bathroom';
    houseWire.add(roomBathroom);
}

// ─────────────────────────────────────────────────────────────
// 5. FILLED ROOMS — Rendered interiors inside each room frame
//    These start invisible/scaled to 0, and "pop in" during reveal
// ─────────────────────────────────────────────────────────────
function buildFilledRooms() {
    // Living Room filled
    livingFilled = new THREE.Group();
    livingFilled.visible = false;

    const sofaMat = new THREE.MeshStandardMaterial({ color: new THREE.Color(PRESETS.wood.accent), roughness: 0.4 });
    const sofa = new THREE.Mesh(new THREE.BoxGeometry(1.6, 0.45, 0.7), sofaMat);
    sofa.position.set(-3, 0.225, 2);
    const sofaBack = new THREE.Mesh(new THREE.BoxGeometry(1.6, 0.35, 0.15), sofaMat);
    sofaBack.position.set(-3, 0.5, 1.65);
    const table = new THREE.Mesh(new THREE.BoxGeometry(0.8, 0.04, 0.5), new THREE.MeshPhysicalMaterial({ color: 0xc9a040, clearcoat: 1, metalness: 0.5 }));
    table.position.set(-3, 0.4, 2.8);
    const rug = new THREE.Mesh(new THREE.PlaneGeometry(2.5, 2), new THREE.MeshStandardMaterial({ color: 0x4a3520, roughness: 0.9 }));
    rug.rotation.x = -Math.PI / 2; rug.position.set(-3, 0.01, 2.2);
    const lamp1 = makeLampMesh(-1.8, 0, 1.2);
    livingFilled.add(sofa, sofaBack, table, rug, lamp1);
    // Floor for this room
    const lFloor = new THREE.Mesh(new THREE.PlaneGeometry(5, 3), new THREE.MeshStandardMaterial({ color: 0x2a1f14, roughness: 0.5 }));
    lFloor.rotation.x = -Math.PI / 2; lFloor.position.set(-2.5, 0.005, 1.5);
    livingFilled.add(lFloor);
    houseWire.add(livingFilled);
    livingFilled.userData = { room: roomLiving };

    // Kitchen filled
    kitchenFilled = new THREE.Group();
    kitchenFilled.visible = false;
    const counter = new THREE.Mesh(new THREE.BoxGeometry(3.5, 0.9, 0.6), new THREE.MeshStandardMaterial({ color: 0x555555, roughness: 0.3, metalness: 0.4 }));
    counter.position.set(2.5, 0.45, 0.6);
    const island = new THREE.Mesh(new THREE.BoxGeometry(1.5, 0.85, 0.8), new THREE.MeshStandardMaterial({ color: 0xe8e4de, roughness: 0.15, metalness: 0.2 }));
    island.position.set(2.5, 0.425, 2.2);
    const stool1 = new THREE.Mesh(new THREE.CylinderGeometry(0.15, 0.12, 0.6, 8), new THREE.MeshStandardMaterial({ color: 0x333333, metalness: 0.7 }));
    stool1.position.set(2, 0.3, 2.7);
    const stool2 = stool1.clone(); stool2.position.x = 3;
    const kFloor = new THREE.Mesh(new THREE.PlaneGeometry(5, 3), new THREE.MeshStandardMaterial({ color: 0xe8e4de, roughness: 0.1, metalness: 0.2 }));
    kFloor.rotation.x = -Math.PI / 2; kFloor.position.set(2.5, 0.005, 1.5);
    kitchenFilled.add(counter, island, stool1, stool2, kFloor);
    houseWire.add(kitchenFilled);
    kitchenFilled.userData = { room: roomKitchen };

    // Bedroom filled
    bedroomFilled = new THREE.Group();
    bedroomFilled.visible = false;
    const bed = new THREE.Mesh(new THREE.BoxGeometry(1.8, 0.4, 2), new THREE.MeshStandardMaterial({ color: 0x2a1f14, roughness: 0.5 }));
    bed.position.set(-2.5, 0.2, -1.5);
    const mattress = new THREE.Mesh(new THREE.BoxGeometry(1.7, 0.15, 1.9), new THREE.MeshStandardMaterial({ color: 0xf5f0e8, roughness: 0.8 }));
    mattress.position.set(-2.5, 0.475, -1.5);
    const headboard = new THREE.Mesh(new THREE.BoxGeometry(1.8, 0.8, 0.1), new THREE.MeshStandardMaterial({ color: 0x3d2817, roughness: 0.4 }));
    headboard.position.set(-2.5, 0.8, -2.45);
    const nightstand = new THREE.Mesh(new THREE.BoxGeometry(0.4, 0.45, 0.35), new THREE.MeshStandardMaterial({ color: 0x2a1f14 }));
    nightstand.position.set(-1.4, 0.225, -2.2);
    const lamp2 = makeLampMesh(-1.4, 0.45, -2.2);
    const bFloor = new THREE.Mesh(new THREE.PlaneGeometry(5, 3), new THREE.MeshStandardMaterial({ color: 0x3d2817, roughness: 0.6 }));
    bFloor.rotation.x = -Math.PI / 2; bFloor.position.set(-2.5, 0.005, -1.5);
    bedroomFilled.add(bed, mattress, headboard, nightstand, lamp2, bFloor);
    houseWire.add(bedroomFilled);
    bedroomFilled.userData = { room: roomBedroom };

    // Bathroom filled
    bathroomFilled = new THREE.Group();
    bathroomFilled.visible = false;
    const tub = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.5, 1.6), new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 0.05, metalness: 0.1 }));
    tub.position.set(3.8, 0.25, -1.5);
    const vanity = new THREE.Mesh(new THREE.BoxGeometry(1.2, 0.8, 0.5), new THREE.MeshStandardMaterial({ color: 0x555555, metalness: 0.3 }));
    vanity.position.set(2.2, 0.4, -2.6);
    const mirror = new THREE.Mesh(new THREE.PlaneGeometry(0.8, 1), new THREE.MeshPhysicalMaterial({ color: 0xaabbcc, metalness: 0.95, roughness: 0.05, clearcoat: 1 }));
    mirror.position.set(2.2, 1.3, -2.95);
    const btFloor = new THREE.Mesh(new THREE.PlaneGeometry(5, 3), new THREE.MeshStandardMaterial({ color: 0xe8e4de, roughness: 0.08, metalness: 0.3 }));
    btFloor.rotation.x = -Math.PI / 2; btFloor.position.set(2.5, 0.005, -1.5);
    bathroomFilled.add(tub, vanity, mirror, btFloor);
    houseWire.add(bathroomFilled);
    bathroomFilled.userData = { room: roomBathroom };
}

function makeLampMesh(x, y, z) {
    const g = new THREE.Group();
    const base = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.1, 0.03, 10), new THREE.MeshStandardMaterial({ color: 0x333333, metalness: 0.9 }));
    base.position.y = 0.015;
    const pole = new THREE.Mesh(new THREE.CylinderGeometry(0.012, 0.012, 0.8, 6), new THREE.MeshStandardMaterial({ color: 0x555555, metalness: 0.7 }));
    pole.position.y = 0.42;
    const shade = new THREE.Mesh(new THREE.ConeGeometry(0.14, 0.18, 10, 1, true), new THREE.MeshStandardMaterial({ color: 0xffeebb, side: THREE.DoubleSide, emissive: 0xffcc44, emissiveIntensity: 0.3 }));
    shade.position.y = 0.85;
    const light = new THREE.PointLight(0xffd080, 0.5, 3);
    light.position.y = 0.75;
    g.add(base, pole, shade, light);
    g.position.set(x, y, z);
    return g;
}

// ─────────────────────────────────────────────────────────────
// 6. FLOATING PARTICLES (dust motes in the void)
// ─────────────────────────────────────────────────────────────
function buildParticles() {
    const count = 300;
    const geo = new THREE.BufferGeometry();
    const positions = new Float32Array(count * 3);
    for (let i = 0; i < count; i++) {
        positions[i * 3]     = (Math.random() - 0.5) * 40;
        positions[i * 3 + 1] = Math.random() * 15;
        positions[i * 3 + 2] = (Math.random() - 0.5) * 40 - 10;
    }
    geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const mat = new THREE.PointsMaterial({ color: GOLD, size: 0.03, transparent: true, opacity: 0.6 });
    particles = new THREE.Points(geo, mat);
    scene.add(particles);
}

// ─────────────────────────────────────────────────────────────
// 6.5. FLOATING BACKGROUND OBJECTS (for deep dive)
// ─────────────────────────────────────────────────────────────
function buildFloaters() {
    portalMaterials.primary = new THREE.MeshStandardMaterial({ color: 0xe8e4de, roughness: 0.1, metalness: 0.3 }); // Marble
    portalMaterials.accent = new THREE.MeshStandardMaterial({ color: GOLD, roughness: 0.2, metalness: 0.8 }); // Gold

    // Pillar
    const pillar = new THREE.Mesh(new THREE.CylinderGeometry(0.3, 0.3, 3, 16), portalMaterials.primary);
    pillar.position.set(-5, -5, -4);
    // Gold ring
    const ring = new THREE.Mesh(new THREE.TorusGeometry(1, 0.05, 16, 50), portalMaterials.accent);
    ring.position.set(4, -8, -6);
    // Modern chair placeholder (made of basic shapes)
    const chair = new THREE.Group();
    const c1 = new THREE.Mesh(new THREE.BoxGeometry(1, 0.1, 1), portalMaterials.primary);
    const c2 = new THREE.Mesh(new THREE.BoxGeometry(0.1, 1, 1), portalMaterials.primary);
    c2.position.set(-0.45, 0.5, 0);
    chair.add(c1, c2);
    chair.position.set(2, -12, -2);
    
    // Wireframe abstract shape
    portalMaterials.wire = new THREE.LineBasicMaterial({ color: WIRE_COLOR });
    const abstract = new THREE.LineSegments(
        new THREE.EdgesGeometry(new THREE.IcosahedronGeometry(1.5, 0)),
        portalMaterials.wire
    );
    abstract.position.set(-3, -16, -5);

    floaters = [
        { mesh: pillar, rotSpeed: [0.005, 0.01, 0],   floatSpeed: 0.5, floatRange: 1 },
        { mesh: ring,   rotSpeed: [0.02, 0.01, 0.01], floatSpeed: 0.8, floatRange: 0.5 },
        { mesh: chair,  rotSpeed: [0.002, 0.008, 0],  floatSpeed: 0.4, floatRange: 1.5 },
        { mesh: abstract, rotSpeed: [0.01, 0.01, 0.01], floatSpeed: 0.3, floatRange: 2 }
    ];

    floaters.forEach(f => {
        f.baseY = f.mesh.position.y;
        scene.add(f.mesh);
    });
}

// ─────────────────────────────────────────────────────────────
// 7. RENDER LOOP
// ─────────────────────────────────────────────────────────────
function renderLoop() {
    requestAnimationFrame(renderLoop);
    if (!renderer) return;

    const t = Date.now() * 0.001;

    // Particle drift
    if (particles) {
        particles.rotation.y = t * 0.02;
        particles.material.opacity = 0.25 + Math.sin(t * 0.5) * 0.1;
    }

    // Shard physics (Chronos Update)
    if (portalShards.length > 0 && portalShards[0].userData.active) {
        portalShards.forEach(s => {
            const v = s.userData.velocity;
            s.position.x += v.x * 0.016; 
            s.position.y += v.y * 0.016;
            s.position.z -= v.z * 0.016; // fly away
            // gravity
            v.y -= 9.8 * 0.016; 
            
            s.rotation.x += s.userData.rotSpeed.x;
            s.rotation.y += s.userData.rotSpeed.y;
            s.rotation.z += s.userData.rotSpeed.z;
        });
    }

    // Floater drift
    floaters.forEach(f => {
        f.mesh.rotation.x += f.rotSpeed[0];
        f.mesh.rotation.y += f.rotSpeed[1];
        f.mesh.rotation.z += f.rotSpeed[2];
        f.mesh.position.y = f.baseY + Math.sin(t * f.floatSpeed) * f.floatRange;
    });

    // Day/Night smooth lerp
    if (ambientLight) ambientLight.intensity += ((state.isNight ? 0.02 : 0.08) - ambientLight.intensity) * 0.03;
    if (sunLight) sunLight.intensity += ((state.isNight ? 0 : 0.6) - sunLight.intensity) * 0.03;
    if (nightFill) nightFill.intensity += ((state.isNight ? 2 : 0) - nightFill.intensity) * 0.03;
    if (scene.fog) {
        scene.fog.color.lerp(new THREE.Color(state.isNight ? 0x020208 : BG_COLOR), 0.03);
    }

    renderer.render(scene, camera);
}

// ─────────────────────────────────────────────────────────────
// 8. GSAP SCROLL ENGINE — The Cinematic Journey
// ─────────────────────────────────────────────────────────────
function initScrollEngine() {
    if (typeof gsap === 'undefined' || typeof ScrollTrigger === 'undefined') return;
    gsap.registerPlugin(ScrollTrigger);

    function easeIO(t) { return t < 0.5 ? 4*t*t*t : 1 - Math.pow(-2*t + 2, 3) / 2; }

    // ── Master timeline mapped to full page scroll ──
    ScrollTrigger.create({
        trigger: document.body,
        start: 'top top',
        end: 'bottom bottom',
        scrub: 0.5,
        onUpdate: (self) => {
            const p = self.progress;
            if (!camera || !doorL) return;

            /*
             * SCROLL TIMELINE (Mapped to full document, p = 0 → 1):
             * Because the document is very tall (experience + features + cta + footer),
             * we compress Phase 1-6 into the top ~50% of the scroll (p=0 to 0.55),
             * and use 0.55→1.00 for diving deep into the 3D void behind the standard HTML sections.
             */

            const tDoor    = clamp01((p - 0.00) / 0.05); // 0-5%
            const tEnter   = clamp01((p - 0.05) / 0.10); // 5-15%
            const tPullback= clamp01((p - 0.15) / 0.10); // 15-25%
            const tExplode = clamp01((p - 0.25) / 0.15); // 25-40%
            const tOrbit   = clamp01((p - 0.40) / 0.10); // 40-50%
            const tRoom1   = clamp01((p - 0.42) / 0.05); // 42-47%
            const tRoom2   = clamp01((p - 0.44) / 0.05); // 44-49%
            const tRoom3   = clamp01((p - 0.46) / 0.05); // 46-51%
            const tRoom4   = clamp01((p - 0.48) / 0.05); // 48-53%
            const tControls= clamp01((p - 0.52) / 0.05); // 52-57%
            const tDeepDive= clamp01((p - 0.55) / 0.45); // 55-100% (diving down into features/cta)

            // ─── DOORS ───
            const doorAngle = easeIO(tDoor) * (Math.PI * 0.45);
            doorL.rotation.y = doorAngle;
            doorR.rotation.y = -doorAngle;

            // ─── CAMERA PATH ───
            // Phase 1: Move through door & stretch portal
            if (p < 0.15) {
                const e = easeIO(tEnter);
                camera.position.x = 0;
                camera.position.y = 1.6;
                camera.position.z = 8 - e * 14; // 8 → -6
                camera.lookAt(0, 1.6, -8);

                // Stretch portal membrane
                if (portalMembrane) {
                    const posAttrib = portalMembrane.geometry.attributes.position;
                    // The camera pushes into it, stretching the center vertices towards it (+z)
                    // At e = 0.5, we cross threshold
                    const stretch = Math.min(e, 0.45) * 12; // stretch heavily
                    for (let i = 0; i < posAttrib.count; i++) {
                        // Original x,y 
                        // It's a plane, so we apply a simple bulge function
                        const vx = posAttrib.getX(i);
                        const vy = posAttrib.getY(i);
                        const dist = Math.sqrt(vx*vx + vy*vy);
                        const bulge = Math.max(0, 1 - dist/1.5); // bulge radius
                        posAttrib.setZ(i, bulge * stretch);
                    }
                    posAttrib.needsUpdate = true;
                    
                    // Show membrane
                    portalMembrane.visible = e < 0.45;

                    // Trigger Shard Explosion once we breach
                    if (e >= 0.45 && portalMembrane._shattered !== true) {
                        portalMembrane._shattered = true;
                        portalShards.forEach(shard => {
                            shard.visible = true;
                            shard.position.copy(camera.position); // spawn at camera
                            shard.position.z -= 1.5; // throw in front of cam
                            shard.userData.active = true;
                        });
                    }
                    // Reset if scrolling back
                    if (e < 0.4) {
                        portalMembrane._shattered = false;
                        portalShards.forEach(s => s.userData.active = false);
                    }
                }
            }
            // Phase 2: Pull back to isometric overview
            else if (p < 0.25) {
                const e = easeIO(tPullback);
                camera.position.x = e * 8;
                camera.position.y = 1.6 + e * 10;
                camera.position.z = -6 + e * 12;
                camera.lookAt(0, 3.2, -8);
            }
            // Phase 3 & 4: Orbit during explosion and zooms
            else if (p < 0.55) {
                // Orbit and zoom in combination
                const baseAngle = tOrbit * Math.PI * 0.4;
                const eZoom = easeIO(clamp01((p - 0.40) / 0.15)); // Zoom in as rooms fill
                const orbitR = 18 - eZoom * 6;
                camera.position.x = Math.sin(baseAngle) * orbitR;
                camera.position.y = 11 + tOrbit * 2 - eZoom * 3;
                camera.position.z = Math.cos(baseAngle) * orbitR - 8;
                camera.lookAt(0, 3 - eZoom * 0.5, -8);
            }
            // Phase 5: Deep dive into the void for Features/CTA
            else {
                // p > 0.55 means user scrolling into Features/Showcase/CTA
                const e = easeIO(tDeepDive);
                // Slowly fall downwards and look around the floating objects
                camera.position.y = 10 - e * 30; // Drop way down
                camera.position.z = -8 + e * 5;  // Move forward slightly
                camera.lookAt(0, camera.position.y - 10, -8); // Keep looking down into the void
            }

            // Subtle breathing
            camera.position.y += Math.sin(Date.now() * 0.001) * 0.03;

            // ─── HOUSE WIREFRAME VISIBILITY ───
            if (houseWire) {
                houseWire.visible = tEnter > 0.3;
                // Fade in via material opacity
                houseWire.traverse(child => {
                    if (child.material && child.material.opacity !== undefined) {
                        child.material.transparent = true;
                        child.material.opacity = Math.min(tEnter * 2, child.material.userData?.maxOpacity || 1);
                    }
                });
            }

            // ─── SPOTLIGHT dim as we enter ───
            if (spotFront) spotFront.intensity = 2 * (1 - tEnter);

            // ─── EXPLOSION ───
            const ex = easeIO(tExplode);

            // Roof lifts up  
            if (roofGroup) {
                roofGroup.position.y = ex * 6;
            }

            // Floor drops
            if (floorGroup) {
                floorGroup.position.y = ex * -3;
            }

            // Walls spread outward
            if (wallFront) wallFront.position.z = ex * 5;
            if (wallBack)  wallBack.position.z = ex * -5;
            if (wallLeft)  wallLeft.position.x = ex * -5;
            if (wallRight) wallRight.position.x = ex * 5;

            // Rooms separate into floating frames (move apart + slight rotation)
            if (roomLiving) {
                roomLiving.position.x = ex * -3;
                roomLiving.position.y = ex * 2;
                roomLiving.position.z = ex * 3;
                roomLiving.rotation.y = ex * 0.15;
                roomLiving.rotation.x = ex * 0.05;
            }
            if (roomKitchen) {
                roomKitchen.position.x = ex * 3;
                roomKitchen.position.y = ex * 2.5;
                roomKitchen.position.z = ex * 3;
                roomKitchen.rotation.y = ex * -0.12;
                roomKitchen.rotation.x = ex * 0.04;
            }
            if (roomBedroom) {
                roomBedroom.position.x = ex * -3;
                roomBedroom.position.y = ex * -1;
                roomBedroom.position.z = ex * -3;
                roomBedroom.rotation.y = ex * 0.1;
                roomBedroom.rotation.z = ex * 0.03;
            }
            if (roomBathroom) {
                roomBathroom.position.x = ex * 3;
                roomBathroom.position.y = ex * -0.5;
                roomBathroom.position.z = ex * -3;
                roomBathroom.rotation.y = ex * -0.08;
                roomBathroom.rotation.z = ex * -0.04;
            }

            // ─── ROOM FILLS — Content reveals one by one ───
            revealRoom(livingFilled, tRoom1, roomLiving);
            revealRoom(kitchenFilled, tRoom2, roomKitchen);
            revealRoom(bedroomFilled, tRoom3, roomBedroom);
            revealRoom(bathroomFilled, tRoom4, roomBathroom);

            // ─── WIREFRAME GLOW on rooms during explosion ───
            [roomLiving, roomKitchen, roomBedroom, roomBathroom].forEach(r => {
                if (!r) return;
                r.traverse(child => {
                    if (child.material && child.material.color) {
                        const intensity = ex > 0.5 ? 1 : ex * 2;
                        child.material.color.setHex(intensity > 0.8 ? WIRE_COLOR : WIRE_DIM);
                    }
                });
            });

            // ─── CONTROLS visibility ───
            const ctrl = document.getElementById('three-controls');
            if (ctrl) ctrl.classList.toggle('hidden', tControls < 0.3);

            // ─── TEXT PANEL opacity ───
            updatePanelVisibility(p);
        }
    });

    // ─── Scroll-triggered text panels ───
    document.querySelectorAll('.exp-panel-inner').forEach((panel) => {
        gsap.fromTo(panel,
            { opacity: 0, y: 50 },
            { opacity: 1, y: 0, duration: 1, ease: 'power3.out',
              scrollTrigger: { trigger: panel, start: 'top 80%', end: 'top 45%', scrub: true }
            }
        );
        gsap.to(panel, {
            opacity: 0, y: -30,
            scrollTrigger: { trigger: panel, start: 'top 25%', end: 'top 5%', scrub: true }
        });
    });

    // ─── HORIZONTAL SCROLL RAIL (Phase 7 UI) ───
    const scrollContainer = document.getElementById('horizontal-scroll-container');
    const cards = document.querySelectorAll('.feature-card');
    
    if (scrollContainer) {
        // Main horizontal movement
        gsap.to(scrollContainer, {
            x: () => -(scrollContainer.scrollWidth - window.innerWidth),
            ease: 'none',
            scrollTrigger: {
                trigger: '.features',
                start: 'top top',
                end: () => `+=${scrollContainer.scrollWidth - window.innerWidth}`,
                scrub: 1,
                pin: true,
                invalidateOnRefresh: true,
                anticipatePin: 1,
                onUpdate: (self) => {
                    const p = self.progress;
                    updateEraMaterials(p);
                    if (houseWire) {
                        houseWire.rotation.y = p * Math.PI * 2;
                        houseWire.rotation.x = Math.sin(p * Math.PI) * 0.12;
                    }
                }
            }
        });

        // Individual Card Scale & Shatter
        cards.forEach((card, i) => {
            gsap.to(card, {
                scrollTrigger: {
                    trigger: ".features",
                    start: "top top",
                    end: () => `+=${scrollContainer.scrollWidth - window.innerWidth}`,
                    scrub: true,
                    onUpdate: (self) => {
                        const rect = card.getBoundingClientRect();
                        const pLeft = rect.left / window.innerWidth;
                        
                        if (pLeft < 0.8 && pLeft > 0.1) {
                            const scale = 1 + (0.8 - pLeft) * 0.25;
                            gsap.set(card, { scale: Math.min(scale, 1.25) });
                        }

                        if (pLeft < 0.1 && !card._shattered) {
                            card._shattered = true;
                            triggerShatter(card);
                        }
                        
                        // REASSEMBLE on scroll back
                        if (pLeft > 0.12 && card._shattered) {
                            card._shattered = false;
                            triggerReassemble(card);
                        }
                    }
                }
            });
        });

        // Massive text parallax
        gsap.to('.bg-title-massive', {
            x: '-30%',
            ease: 'none',
            scrollTrigger: {
                trigger: '.features',
                start: 'top bottom',
                end: 'bottom top',
                scrub: 1
            }
        });
    }

    // ─── VIEWFINDER / FINAL RENDER (Phase 7 UI) ───
    gsap.fromTo('.vf-content',
        { opacity: 0, scale: 0.95 },
        { opacity: 1, scale: 1, duration: 1.5, ease: 'power3.out',
          scrollTrigger: { trigger: '.final-render', start: 'top 70%', toggleActions: 'play none none none' }
        }
    );

    // Stats Counter
    document.querySelectorAll('.vf-stat span').forEach(el => {
        const txt = el.innerText;
        const target = parseInt(txt.replace(/\D/g, ''), 10);
        if(!target) return;
        const hasK = txt.includes('K');
        gsap.fromTo(el, { innerText: 0 }, {
            innerText: target, duration: 2, ease: 'power2.out', snap: { innerText: 1 },
            scrollTrigger: { trigger: el, start: 'top 85%', toggleActions: 'play none none none' },
            onUpdate() { el.textContent = Math.floor(parseFloat(el.innerText)) + (hasK ? 'K+' : (txt.includes('s') ? 's' : '')); }
        });
    });

    // ─── GLOBAL HUD & MAGNETIC PHYSICS ───
    const crosshair = document.getElementById('hud-crosshair');
    const coords = document.querySelector('.hud-coords');
    
    let mx = window.innerWidth / 2, my = window.innerHeight / 2;
    let cx = mx, cy = my;

    window.addEventListener('mousemove', (e) => {
        mx = e.clientX;
        my = e.clientY;
        if(coords) coords.innerText = `[ X: ${String(Math.round(mx)).padStart(3, '0')} | Y: ${String(Math.round(my)).padStart(3, '0')} ]`;
    });

    document.querySelectorAll('[data-magnetic]').forEach(btn => {
        btn.addEventListener('mousemove', (e) => {
            const rect = btn.getBoundingClientRect();
            if(!rect) return;
            const px = e.clientX - rect.left - rect.width / 2;
            const py = e.clientY - rect.top - rect.height / 2;
            gsap.to(btn, { 
                x: px * 0.2, y: py * 0.2, 
                rotationX: -py * 0.05, rotationY: px * 0.05,
                duration: 0.4, ease: 'power2.out'
            });
            const glare = btn.querySelector('.btn-glare');
            if (glare) {
                gsap.to(glare, { x: px * 1.5, y: py * 1.5, opacity: 1, duration: 0.2 });
            }
        });
        btn.addEventListener('mouseleave', () => {
            gsap.to(btn, { x: 0, y: 0, rotationX: 0, rotationY: 0, duration: 0.7, ease: 'elastic.out(1, 0.3)' });
            const glare = btn.querySelector('.btn-glare');
            if (glare) gsap.to(glare, { opacity: 0, duration: 0.4 });
        });
    });

    function hudLoop() {
        cx += (mx - cx) * 0.2;
        cy += (my -cy) * 0.2;
        if(crosshair) crosshair.style.transform = `translate(${cx}px, ${cy}px)`;
        requestAnimationFrame(hudLoop);
    }
    hudLoop();

    ScrollTrigger.create({
        start: 100,
        onEnter: () => { const s = document.getElementById('scroll-indicator'); if (s) s.style.opacity = '0'; },
        onLeaveBack: () => { const s = document.getElementById('scroll-indicator'); if (s) s.style.opacity = '1'; }
    });
}

// Helper: clamp 0-1
function clamp01(v) { return Math.max(0, Math.min(1, v)); }

// Helper: Reveal a filled room group
function revealRoom(filledGroup, t, wireGroup) {
    if (!filledGroup) return;
    
    if (t > 0.05) {
        filledGroup.visible = true;
        // Scale up smoothly
        const s = easeOutBack(clamp01(t));
        filledGroup.scale.set(s, s, s);
        
        // Match the wire group's explosion position 
        if (wireGroup) {
            filledGroup.position.copy(wireGroup.position);
            filledGroup.rotation.copy(wireGroup.rotation);
        }

        // Dim the wireframe for this room as filled content appears
        if (wireGroup && t > 0.5) {
            wireGroup.traverse(child => {
                if (child.material && child.material.opacity !== undefined) {
                    child.material.transparent = true;
                    child.material.opacity = Math.max(0.15, 1 - (t - 0.5) * 2);
                }
            });
        }
    } else {
        filledGroup.visible = false;
    }
}

// Easing: Back easeOut (slight overshoot for "pop" effect)
function easeOutBack(t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
}

// Helper: Update text panel visibility
function updatePanelVisibility(p) {
    const panels = document.querySelectorAll('.exp-panel');
    // Map each panel to a scroll range
    const ranges = [
        [0.05, 0.20],  // door
        [0.25, 0.45],  // foyer / explosion
        [0.50, 0.70],  // rooms float
        [0.72, 0.92],  // customize
    ];
    panels.forEach((panel, i) => {
        if (i < ranges.length) {
            const [start, end] = ranges[i];
            const visible = p >= start && p <= end;
            panel.style.pointerEvents = visible ? 'auto' : 'none';
        }
    });
}

// ─────────────────────────────────────────────────────────────
// 9. UI HANDLERS
// ─────────────────────────────────────────────────────────────
function initUIHandlers() {
    // Material
    document.querySelectorAll('.ctrl-btn[data-material]').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.ctrl-btn[data-material]').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            state.material = btn.getAttribute('data-material');
            applyMaterialToRooms();
        });
    });

    // Lighting
    const lightBtn = document.getElementById('ctrl-lighting');
    if (lightBtn) lightBtn.addEventListener('click', () => {
        state.isNight = !state.isNight;
        lightBtn.setAttribute('data-state', state.isNight ? 'night' : 'day');
        lightBtn.textContent = state.isNight ? '🌙 NIGHT' : '☀️ DAY';
    });

    // Wireframe
    const renderBtn = document.getElementById('ctrl-render');
    if (renderBtn) renderBtn.addEventListener('click', () => {
        state.isWireframe = !state.isWireframe;
        renderBtn.setAttribute('data-state', state.isWireframe ? 'wireframe' : 'rendered');
        renderBtn.textContent = state.isWireframe ? '◈ WIREFRAME' : '◉ RENDERED';
        applyWireframeToRooms();
    });

    // Transform
    const transBtn = document.getElementById('ctrl-transform');
    if (transBtn) transBtn.addEventListener('click', () => {
        state.showNew = !state.showNew;
        transBtn.setAttribute('data-state', state.showNew ? 'after' : 'before');
        transBtn.textContent = state.showNew ? '✦ AFTER' : '✧ BEFORE';
        [livingFilled, kitchenFilled, bedroomFilled, bathroomFilled].forEach(g => {
            if (g && typeof gsap !== 'undefined') {
                const ts = state.showNew ? 1 : 0.001;
                gsap.to(g.scale, { x: ts, y: ts, z: ts, duration: 0.6, ease: 'power2.inOut' });
            }
        });
    });

    // Hamburger
    const ham = document.getElementById('nav-hamburger');
    const links = document.getElementById('nav-links');
    if (ham && links) ham.addEventListener('click', () => {
        links.style.display = links.style.display === 'flex' ? 'none' : 'flex';
    });
}

function applyMaterialToRooms() {
    const p = PRESETS[state.material];
    const accent = new THREE.Color(p.accent);
    const floor  = new THREE.Color(p.floor);
    const wall   = new THREE.Color(p.wall);

    [livingFilled, kitchenFilled, bedroomFilled, bathroomFilled].forEach(group => {
        if (!group) return;
        group.traverse(child => {
            if (child.isMesh && child.material) {
                // Floors
                if (child.geometry.type === 'PlaneGeometry') {
                    child.material.color.lerp(floor, 0.3);
                }
            }
        });
    });
}

function applyWireframeToRooms() {
    [livingFilled, kitchenFilled, bedroomFilled, bathroomFilled].forEach(group => {
        if (!group) return;
        group.traverse(child => {
            if (child.isMesh && child.material) {
                child.material.wireframe = state.isWireframe;
            }
        });
    });
}

// ─────────────────────────────────────────────────────────────
// 10. RESIZE
// ─────────────────────────────────────────────────────────────
function onResize() {
    const c = document.getElementById('three-canvas-container');
    if (!c || !camera || !renderer) return;
    camera.aspect = c.clientWidth / c.clientHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(c.clientWidth, c.clientHeight);
}

// ─────────────────────────────────────────────────────────────
// 11. SCROLL HELPERS (ERA EVOLUTION & SHATTER)
// ─────────────────────────────────────────────────────────────
function updateEraMaterials(p) {
    if (typeof portalMaterials === 'undefined' || !portalMaterials.primary) return;
    const GOLD_HEX = 0xc9a84c;
    const c1Prim = new THREE.Color(0xe8e4de);
    const c1Acc = new THREE.Color(GOLD_HEX);
    const c2Prim = new THREE.Color(0x222222);
    const c2Acc = new THREE.Color(0x999999);
    const c3Prim = new THREE.Color(0x050505);
    const c3Acc = new THREE.Color(0x00d4ff);

    let tPrim = c1Prim.clone(), tAcc = c1Acc.clone(), rPrim = 0.1, mPrim = 0.3;

    if (p < 0.33) {
        const localP = p / 0.33;
        tPrim.lerpColors(c1Prim, c2Prim, localP);
        tAcc.lerpColors(c1Acc, c2Acc, localP);
        rPrim = 0.1 + localP * 0.7; mPrim = 0.3 - localP * 0.2;
    } else if (p < 0.66) {
        const localP = (p - 0.33) / 0.33;
        tPrim.lerpColors(c2Prim, c3Prim, localP);
        tAcc.lerpColors(c2Acc, c3Acc, localP);
        rPrim = 0.8 - localP * 0.75; mPrim = 0.1 + localP * 0.8;
    } else {
        tPrim.copy(c3Prim); tAcc.copy(c3Acc); rPrim = 0.05; mPrim = 0.9;
    }

    portalMaterials.primary.color.copy(tPrim);
    portalMaterials.primary.roughness = rPrim;
    portalMaterials.primary.metalness = mPrim;
    portalMaterials.accent.color.copy(tAcc);
    portalMaterials.wire.color.copy(tAcc);
    if (typeof nightFill !== 'undefined' && nightFill) { 
        nightFill.intensity = p * 3.0; 
        nightFill.color.copy(tAcc); 
    }
}

function triggerShatter(card) {
    const rect = card.getBoundingClientRect();
    const overlay = document.getElementById('shatter-overlay');
    if (!overlay) return;

    // Fade out original
    gsap.to(card, { opacity: 0, scale: 1.5, duration: 0.3, ease: "power2.in" });

    // Create fragments
    for (let i = 0; i < 30; i++) {
        const frag = document.createElement('div');
        frag.className = 'shatter-fragment';
        frag.style.cssText = `
            position: absolute;
            left: ${rect.left + rect.width/2}px;
            top: ${rect.top + rect.height/2}px;
            width: ${Math.random() * 40 + 10}px;
            height: ${Math.random() * 40 + 10}px;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            backdrop-filter: blur(10px);
            clip-path: polygon(${Math.random()*100}% 0%, 100% ${Math.random()*100}%, ${Math.random()*100}% 100%, 0% ${Math.random()*100}%);
            z-index: 10000;
        `;
        overlay.appendChild(frag);

        const angle = (Math.random() * Math.PI * 2);
        const force = Math.random() * 600 + 200;
        
        gsap.to(frag, {
            x: Math.cos(angle) * force,
            y: Math.sin(angle) * force - 300, 
            rotation: Math.random() * 720 - 360,
            opacity: 0,
            duration: Math.random() * 1 + 1,
            ease: "power2.out",
            onComplete: () => frag.remove()
        });
    }
}

function triggerReassemble(card) {
    const rect = card.getBoundingClientRect();
    const overlay = document.getElementById('shatter-overlay');
    if (!overlay) return;

    // Show card back from invisible/scaled-up state
    gsap.to(card, { opacity: 1, scale: 1, duration: 0.5, ease: "power2.out" });

    // Create fragments FAR AWAY and pull them IN
    for (let i = 0; i < 30; i++) {
        const frag = document.createElement('div');
        frag.className = 'shatter-fragment';
        const angle = (Math.random() * Math.PI * 2);
        const force = Math.random() * 600 + 200;
        const startX = Math.cos(angle) * force;
        const startY = Math.sin(angle) * force - 300;

        frag.style.cssText = `
            position: absolute;
            left: ${rect.left + rect.width/2}px;
            top: ${rect.top + rect.height/2}px;
            width: ${Math.random() * 40 + 10}px;
            height: ${Math.random() * 40 + 10}px;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            backdrop-filter: blur(10px);
            clip-path: polygon(${Math.random()*100}% 0%, 100% ${Math.random()*100}%, ${Math.random()*100}% 100%, 0% ${Math.random()*100}%);
            z-index: 10000;
            transform: translate(${startX}px, ${startY}px) rotate(${Math.random() * 720}deg);
            opacity: 0;
        `;
        overlay.appendChild(frag);

        gsap.to(frag, {
            x: 0,
            y: 0,
            rotation: 0,
            opacity: 1,
            duration: 0.6,
            ease: "circ.in", // Fast arrival to center
            onComplete: () => {
                gsap.to(frag, { opacity: 0, duration: 0.1, onComplete: () => frag.remove() });
            }
        });
    }
}
