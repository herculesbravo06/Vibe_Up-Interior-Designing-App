import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/screens/project/ar_confirmation_screen.dart';
import 'package:vibe_up/screens/project/three_d_editor_widget.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/utils/catalog_data.dart';
import 'package:vibe_up/services/api_service.dart';


class DiyWorkspaceScreen extends StatefulWidget {
  final String? projectId;
  final Map<String, dynamic>? projectData;
  final bool isFloorPlanMode;
  final String? roomName;
  const DiyWorkspaceScreen({super.key, this.projectId, this.projectData, this.isFloorPlanMode = false, this.roomName});

  @override
  State<DiyWorkspaceScreen> createState() => _DiyWorkspaceScreenState();
}

class _DiyWorkspaceScreenState extends State<DiyWorkspaceScreen> {
  final GlobalKey<ThreeDEditorWidgetState> _editorKey = GlobalKey();
  final GlobalKey _dragTargetKey = GlobalKey();
  int _placedCount = 0;
  String? _selectedItemLabel;
  bool _isSaving = false;
  bool _isSavingToVR = false;
  String _currentViewMode = '3D';

  final List<Map<String, dynamic>> _placedItems = [];

  // Catalogue navigation state
  int _navLevel = 0; // 0=categories, 1=subcategories, 2=items
  int _selectedCatIndex = -1;
  int _selectedSubIndex = -1;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCatalogue = true;

  @override
  void initState() {
    super.initState();
    _loadSyncCatalogue();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _loadSyncCatalogue() async {
    try {
      final syncData = await ApiService.getSyncedCatalogue();
      bool loadedSync = false;
      if (syncData.isNotEmpty) {
        try {
          final mapped = syncData.map((c) => {
            'name': (c['title'] as String).toLowerCase(),
            'display': c['title'],
            'icon': _getIconForCategory(c['title']),
            'sub': c['sub'],
          }).toList();
          if (mounted) {
            setState(() { _categories = mapped; });
          }
          loadedSync = true;
        } catch (e) {
          print('Mapping sync data failed: $e');
        }
      } 
      
      if (!loadedSync) {
        // Fallback
        if (mounted) {
          setState(() {
            _categories = CatalogData.categories.map((c) => {
              'name': (c['title'] as String).toLowerCase(),
              'display': c['title'],
              'icon': c['icon'],
              'sub': c['sub'],
            }).toList();
          });
        }
      }
    } catch (e) {
      print('Sync error in DIY: $e');
      if (mounted) {
        setState(() {
          _categories = CatalogData.categories.map((c) => {
            'name': (c['title'] as String).toLowerCase(),
            'display': c['title'],
            'icon': c['icon'],
            'sub': c['sub'],
          }).toList();
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingCatalogue = false);
    }
  }

  IconData _getIconForCategory(String title) {
    if (title.contains('Construction')) return Icons.home_work_rounded;
    if (title.contains('Interior')) return Icons.chair_rounded;
    if (title.contains('Exterior')) return Icons.park_rounded;
    return Icons.category_rounded;
  }


  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _map3DType(String? category, String? itemName) {
    final name = (itemName ?? '').toLowerCase();
    if (name.contains('sofa') || name.contains('couch')) return 'sofa';
    if (name.contains('lounge') || name.contains('chair') || name.contains('armchair')) return 'chair';
    if (name.contains('dining')) return 'dining_table';
    if (name.contains('coffee') || name.contains('table') || name.contains('side')) return 'table';
    if (name.contains('desk')) return 'desk';
    if (name.contains('lamp') || name.contains('light')) return 'lamp';
    if (name.contains('shelf') || name.contains('book')) return 'bookshelf';
    if (name.contains('rug') || name.contains('carpet')) return 'rug';
    if (name.contains('plant') || name.contains('pot') || name.contains('vase')) return 'plant';
    if (name.contains('bed') || name.contains('mattress')) return 'bed';
    if (name.contains('tv') || name.contains('stand') || name.contains('console')) return 'tv_stand';
    if (name.contains('cabinet') || name.contains('drawer') || name.contains('wardrobe')) return 'cabinet';
    return 'table';
  }

  void _onSceneEvent(Map<String, dynamic> event) {
    if (!mounted) return;
    setState(() {
      if (event.containsKey('count')) {
        _placedCount = (event['count'] as num?)?.toInt() ?? 0;
      }
      if (event.containsKey('items') && event['items'] is List) {
        _placedItems.clear();
        for (final item in event['items']) {
          if (item is Map) {
            _placedItems.add(Map<String, dynamic>.from(item));
          }
        }
      }
      if (event['event'] == 'ready') {
        _loadExistingScene();
      }
      if (event['event'] == 'selected') {
        _selectedItemLabel = event['label'] ?? event['type'];
      } else if (event['event'] == 'deselected' || event['event'] == 'removed' || event['event'] == 'cleared') {
        _selectedItemLabel = null;
      }
    });
  }

  void _loadExistingScene() {
    if (widget.projectData != null) {
      final wVal = widget.projectData!['room_width'] ?? widget.projectData!['width_ft'] ?? 12.0;
      final lVal = widget.projectData!['room_length'] ?? widget.projectData!['length_ft'] ?? 12.0;
      
      final widthFt = double.tryParse(wVal.toString()) ?? 12.0;
      final lengthFt = double.tryParse(lVal.toString()) ?? 12.0;

      _editorKey.currentState?.sendCommand({
        'action': 'setRoomSize',
        'width': widthFt,
        'length': lengthFt,
      });

      if (widget.projectData!['scene_data'] != null && widget.projectData!['scene_data'].toString().isNotEmpty) {
        _editorKey.currentState?.sendCommand({
          'action': 'load',
          'data': widget.projectData!['scene_data'],
        });
      }
    }
  }

  void _onConfirmSave() async {
    setState(() => _isSaving = true);
    try {
      final topViewFuture = _editorKey.currentState?.captureTopView();
      final view3DFuture = _editorKey.currentState?.capture3DView();
      final sceneDataFuture = _editorKey.currentState?.getSceneData();
      final glbFuture = _editorKey.currentState?.exportGLB();

      final topView = await topViewFuture;
      final view3D = await view3DFuture;
      final sceneDataStr = await sceneDataFuture;
      final glbBase64 = await glbFuture;

      if (!mounted) return;

      // Restore portrait for the preview/confirmation page
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArConfirmationScreen(
            source: 'DIY',
            projectId: widget.projectId,
            topViewBase64: topView,
            view3DBase64: view3D,
            placedItems: _placedItems,
            sceneData: sceneDataStr,
            glbBase64: glbBase64,
            isFloorPlanMode: widget.isFloorPlanMode,
            roomName: widget.roomName,
          ),
        ),
      );

      // Re-enable landscape when returning to the editor
      if (mounted) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }

      if (mounted) {
        if (result != null && result is Map && result['success'] == true) {
          Navigator.pop(context, result);
        } else if (result == true) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing views: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Save the current scene to the Node.js VR backend for Meta Quest consumption.
  void _onSaveToVR() async {
    if (_isSavingToVR) return;
    setState(() => _isSavingToVR = true);
    try {
      final vrDataStr = await _editorKey.currentState?.serializeSceneForVR();
      if (vrDataStr == null || vrDataStr.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to serialize scene for VR'), backgroundColor: Colors.redAccent),
          );
        }
        return;
      }

      final vrData = jsonDecode(vrDataStr);
      final layoutData = vrData['items'] as List<dynamic>? ?? [];
      final projectId = widget.projectId ?? '1';

      final result = await ApiService.saveRoomLayout(projectId, layoutData);

      if (mounted) {
        if (result['success'] == true) {
          final layoutId = result['layout_id'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Room saved to VR Cloud! Layout ID: $layoutId'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ VR Sync failed: ${result["message"]}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving to VR: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingToVR = false);
    }
  }

  // ─── Catalogue Drawer Content ───
  Widget _buildDrawerContent() {
    return Container(
      width: 300,
      color: const Color(0xFF111111),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              child: Row(
                children: [
                  if (_navLevel > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.primaryAccent),
                      onPressed: () {
                        setState(() {
                          if (_navLevel == 2) {
                            _navLevel = 1;
                            _selectedSubIndex = -1;
                          } else if (_navLevel == 1) {
                            _navLevel = 0;
                            _selectedCatIndex = -1;
                          }
                        });
                      },
                    ),
                  Expanded(
                    child: Text(
                      _getDrawerTitle(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                _navLevel == 0 ? 'SELECT CATEGORY' : _navLevel == 1 ? 'SELECT SUBCATEGORY' : 'DRAG TO CANVAS',
                style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
            Expanded(
              child: _isLoadingCatalogue
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent, strokeWidth: 2))
                  : _navLevel == 0
                      ? _buildCategoryList()
                      : _navLevel == 1
                          ? _buildSubcategoryList()
                          : _buildItemList(),
            ),

          ],
        ),
      ),
    );
  }

  String _getDrawerTitle() {
    if (_navLevel == 0) return 'Design Atelier';
    if (_navLevel == 1 && _selectedCatIndex >= 0) {
      return _categories[_selectedCatIndex]['display'] as String;
    }
    if (_navLevel == 2 && _selectedCatIndex >= 0 && _selectedSubIndex >= 0) {
      final subs = _categories[_selectedCatIndex]['sub'] as List;
      return subs[_selectedSubIndex]['name'] as String;
    }
    return 'Catalogue';
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final subs = cat['sub'] as List;
        int itemCount = 0;
        for (var sub in subs) {
          itemCount += (sub['items'] as List).length;
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCatIndex = index;
                  _navLevel = 1;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(cat['icon'] as IconData, color: AppTheme.primaryAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat['display'] as String,
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          Text(
                            '$itemCount items • ${subs.length} groups',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDim),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubcategoryList() {
    if (_selectedCatIndex < 0 || _selectedCatIndex >= _categories.length) return const SizedBox();
    final subs = _categories[_selectedCatIndex]['sub'] as List;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: subs.length,
      itemBuilder: (context, index) {
        final sub = subs[index];
        final items = sub['items'] as List;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSubIndex = index;
                  _navLevel = 2;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${items.length}',
                          style: GoogleFonts.poppins(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        sub['name'] as String,
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemList() {
    if (_selectedCatIndex < 0 || _selectedSubIndex < 0) return const SizedBox();
    final subs = _categories[_selectedCatIndex]['sub'] as List;
    if (_selectedSubIndex >= subs.length) return const SizedBox();
    final items = subs[_selectedSubIndex]['items'] as List;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemName = item['name'] as String? ?? 'Item';
        final rawPrice = item['price'];
        final priceNum = rawPrice is String ? (double.tryParse(rawPrice) ?? 0) : ((rawPrice as num?)?.toDouble() ?? 0);
        final priceString = '₹ ${priceNum.toStringAsFixed(0)}';
        final type3D = item['type3d'] as String? ?? _map3DType(_categories[_selectedCatIndex]['name'], itemName);

        final dragData = <String, dynamic>{
          'name': itemName,
          'price': priceNum,
          'category': _categories[_selectedCatIndex]['name'],
          '3dType': type3D,
        };

        return Draggable<Map<String, dynamic>>(
          data: dragData,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryAccent, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, spreadRadius: 2),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_categories[_selectedCatIndex]['icon'] as IconData, size: 28, color: AppTheme.primaryAccent),
                  const SizedBox(height: 4),
                  Text(itemName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ),
          onDragStarted: () => _editorKey.currentState?.showDropZone(true),
          onDragEnd: (_) => _editorKey.currentState?.showDropZone(false),
          child: GestureDetector(
            onTap: () {
              _editorKey.currentState?.addFurniture(type3D, name: itemName, price: priceNum);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added $itemName to room'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_categories[_selectedCatIndex]['icon'] as IconData, size: 18, color: AppTheme.primaryAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itemName, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        Text(priceString, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryAccent)),
                      ],
                    ),
                  ),
                  Icon(Icons.drag_indicator_rounded, color: Colors.white.withOpacity(0.2), size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: Drawer(
        width: 300,
        backgroundColor: Colors.transparent,
        child: _buildDrawerContent(),
      ),
      body: Stack(
        children: [
          // ─── Full-Screen 3D Editor with DragTarget ───
          Positioned.fill(
            child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (details) {
                _editorKey.currentState?.showDropZone(true);
                return true;
              },
              onLeave: (_) => _editorKey.currentState?.showDropZone(false),
              onAcceptWithDetails: (details) {
                _editorKey.currentState?.showDropZone(false);
                final data = details.data;
                final type3D = data['3dType'] as String? ?? 'table';
                final itemName = data['name'] as String? ?? '';
                final itemPrice = (data['price'] as num?)?.toDouble() ?? 0;

                final RenderBox? box = _dragTargetKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  final localPos = box.globalToLocal(details.offset);
                  final editorSize = box.size;
                  final relX = (localPos.dx / editorSize.width).clamp(0.1, 0.9);
                  final relZ = (localPos.dy / editorSize.height).clamp(0.1, 0.9);
                  _editorKey.currentState?.addFurnitureAt(type3D, relX, relZ, name: itemName, price: itemPrice);
                } else {
                  _editorKey.currentState?.addFurniture(type3D, name: itemName, price: itemPrice);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  key: _dragTargetKey,
                  decoration: BoxDecoration(
                    border: candidateData.isNotEmpty
                        ? Border.all(color: AppTheme.primaryAccent, width: 2)
                        : null,
                  ),
                  child: ThreeDEditorWidget(key: _editorKey, onSceneEvent: _onSceneEvent),
                );
              },
            ),
          ),

          // ─── Top-Left: Hamburger Menu Button ───
          Positioned(
            top: 12,
            left: 12,
            child: Builder(
              builder: (ctx) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.menu_rounded, color: AppTheme.primaryAccent, size: 22),
                  ),
                ),
              ),
            ),
          ),

          // ─── Top-Center: Title & Asset Count ───
          Positioned(
            top: 12,
            left: 60,
            right: 60,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.roomName != null ? widget.roomName! : 'Design Studio',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    if (_placedCount > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_placedCount ASSETS',
                          style: GoogleFonts.inter(color: AppTheme.primaryAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ─── Top-Right: Action Buttons ───
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                // Close Button
                _buildFloatingButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Exit',
                  onTap: () => Navigator.pop(context),
                  color: Colors.white54,
                ),
                const SizedBox(width: 8),
                // Finalize Button
                _isSaving
                    ? Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryAccent)),
                      )
                    : _buildFloatingButton(
                        icon: Icons.check_rounded,
                        tooltip: 'Finalize',
                        onTap: _onConfirmSave,
                        color: Colors.black,
                        bgColor: AppTheme.primaryAccent,
                      ),
                // Save to VR Button removed from here as it's now in the view mode selector
              ],
            ),
          ),

          // ─── Right-Side: Editor Controls ───
          Positioned(
            right: 12,
            top: 70,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildActionButton(icon: Icons.fullscreen_exit_rounded, tooltip: 'Focus Room', onTap: () => _editorKey.currentState?.fitRoomInView()),
                  const SizedBox(height: 8),
                  _buildActionButton(icon: Icons.refresh_rounded, tooltip: 'Reset Camera', onTap: () => _editorKey.currentState?.resetCamera()),
                  const SizedBox(height: 8),
                  Container(height: 1, width: 24, color: Colors.white10),
                  const SizedBox(height: 8),
                  _buildActionButton(icon: Icons.rotate_left_rounded, tooltip: 'Rotate Left', onTap: () => _editorKey.currentState?.rotateSelected(-3.14159 / 6)),
                  const SizedBox(height: 8),
                  _buildActionButton(icon: Icons.rotate_right_rounded, tooltip: 'Rotate Right', onTap: () => _editorKey.currentState?.rotateSelected(3.14159 / 6)),
                  const SizedBox(height: 8),
                  Container(height: 1, width: 24, color: Colors.white10),
                  const SizedBox(height: 8),
                  _buildActionButton(icon: Icons.delete_outline_rounded, tooltip: 'Remove', color: Colors.redAccent, onTap: () => _editorKey.currentState?.removeSelected()),
                ],
              ),
            ),
          ),

          // ─── Bottom-Left: Selected Item Label ───
          if (_selectedItemLabel != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryAccent, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      _selectedItemLabel!.toUpperCase(),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Bottom-Center: View Mode Selector ───
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton('3D', Icons.view_in_ar_rounded),
                    const SizedBox(width: 4),
                    _buildModeButton('Panorama', Icons.panorama_horizontal_rounded),
                    const SizedBox(width: 4),
                    _isSavingToVR
                        ? Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryAccent),
                              ),
                            ),
                          )
                        : _buildModeButton('VR', Icons.vrpano_rounded, isCta: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
    Color? bgColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor ?? Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, size: 20, color: color ?? Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    final btnColor = color ?? AppTheme.primaryAccent;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: btnColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: btnColor.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 16, color: btnColor),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, IconData icon, {bool isCta = false}) {
    final isSelected = _currentViewMode == mode;
    final colorBasis = isCta ? const Color(0xFF6200EA) : AppTheme.primaryAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_currentViewMode == mode && !isCta) return;
          
          if (mode == '3D') {
            setState(() => _currentViewMode = mode);
            _editorKey.currentState?.setCameraMode('3d');
          } else if (mode == 'Panorama') {
            setState(() => _currentViewMode = mode);
            _editorKey.currentState?.setCameraMode('panorama');
          } else if (mode == 'VR') {
            // VR acts as an action
            setState(() => _currentViewMode = '3D');
            _editorKey.currentState?.setCameraMode('3d');
            _onSaveToVR();
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorBasis : (isCta ? colorBasis.withOpacity(0.15) : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            border: isCta && !isSelected ? Border.all(color: colorBasis.withOpacity(0.5)) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : (isCta ? colorBasis : Colors.white70),
              ),
              const SizedBox(width: 8),
              Text(
                mode,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : (isCta ? colorBasis : Colors.white70),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
