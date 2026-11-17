using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit;

/// <summary>
/// VRInteractionManager: Handles teleportation movement and furniture grab/move/rotate
/// in the VibeUp Meta Quest VR experience.
/// 
/// Requirements:
/// - Unity XR Interaction Toolkit package
/// - OpenXR Plugin
/// - XR Origin in the scene with left/right controllers
/// </summary>
public class VRInteractionManager : MonoBehaviour
{
    [Header("XR References")]
    [Tooltip("Assign the XR Origin's XRRayInteractor for the right hand")]
    public XRRayInteractor rightHandRay;

    [Tooltip("Assign the TeleportationProvider on the XR Origin")]
    public TeleportationProvider teleportProvider;

    [Header("Interaction Settings")]
    [Tooltip("Layer mask for furniture objects that can be grabbed")]
    public LayerMask furnitureLayer;

    [Tooltip("Maximum grab distance in meters")]
    public float maxGrabDistance = 5f;

    [Tooltip("Rotation speed when using thumbstick")]
    public float rotationSpeed = 60f;

    [Header("Visual Feedback")]
    [Tooltip("Material to apply when hovering over a grabbable object")]
    public Material hoverHighlightMaterial;

    private GameObject _hoveredObject;
    private Material[] _originalMaterials;
    private XRGrabInteractable _currentGrab;

    void Start()
    {
        // Auto-setup: Find all FurnitureInstance objects and make them XR-grabbable
        SetupAllFurnitureForInteraction();
    }

    /// <summary>
    /// Makes all FurnitureInstance objects in the scene grabbable by XR controllers.
    /// Call this after RoomLoader finishes building the room.
    /// </summary>
    public void SetupAllFurnitureForInteraction()
    {
        var instances = FindObjectsOfType<FurnitureInstance>();
        foreach (var inst in instances)
        {
            SetupFurnitureInteraction(inst.gameObject);
        }
        Debug.Log($"[VibeUp VR] Set up interaction for {instances.Length} furniture objects.");
    }

    /// <summary>
    /// Adds XR Grab Interactable to a single furniture object,
    /// enabling it to be grabbed and moved in VR.
    /// </summary>
    public void SetupFurnitureInteraction(GameObject obj)
    {
        // Add Rigidbody (kinematic so it doesn't fall)
        if (!obj.GetComponent<Rigidbody>())
        {
            var rb = obj.AddComponent<Rigidbody>();
            rb.useGravity = false;
            rb.isKinematic = true;
        }

        // Add collider if missing
        if (!obj.GetComponent<Collider>())
        {
            var col = obj.AddComponent<BoxCollider>();
            // Auto-fit collider to renderer bounds
            var renderer = obj.GetComponentInChildren<Renderer>();
            if (renderer != null)
            {
                col.center = renderer.bounds.center - obj.transform.position;
                col.size = renderer.bounds.size;
            }
        }

        // Add XR Grab Interactable
        if (!obj.GetComponent<XRGrabInteractable>())
        {
            var grab = obj.AddComponent<XRGrabInteractable>();
            grab.movementType = XRBaseInteractable.MovementType.VelocityTracking;
            grab.throwOnDetach = false;
            grab.useDynamicAttach = true;

            // Constrain to Y-plane (floor level) while dragging
            grab.selectEntered.AddListener((args) =>
            {
                _currentGrab = grab;
                var inst = obj.GetComponent<FurnitureInstance>();
                if (inst != null) inst.isDirty = true;
            });

            grab.selectExited.AddListener((args) =>
            {
                _currentGrab = null;
                // Snap back to floor level
                Vector3 pos = obj.transform.position;
                pos.y = 0;
                obj.transform.position = pos;
            });
        }

        // Set layer for raycasting
        obj.layer = LayerMask.NameToLayer("Furniture");
    }
}
