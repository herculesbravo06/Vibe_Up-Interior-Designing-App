using UnityEngine;

/// <summary>
/// FurnitureInstance: Attached to each instantiated furniture object in VR.
/// Tracks metadata and whether the user has modified it.
/// Used by SyncManager to detect changes and push updates to the API.
/// </summary>
public class FurnitureInstance : MonoBehaviour
{
    [Header("Metadata")]
    public string furnitureType;
    public string furnitureLabel;
    public float furniturePrice;

    [Header("Sync State")]
    public bool isDirty = false;

    // Store the last-synced transform to detect changes
    private Vector3 _lastSyncedPosition;
    private Vector3 _lastSyncedRotation;
    private Vector3 _lastSyncedScale;

    void Start()
    {
        SnapshotCurrentTransform();
    }

    /// <summary>
    /// Records the current transform as the "last synced" state.
    /// Called after a successful sync to the backend.
    /// </summary>
    public void SnapshotCurrentTransform()
    {
        _lastSyncedPosition = transform.position;
        _lastSyncedRotation = transform.eulerAngles;
        _lastSyncedScale = transform.localScale;
        isDirty = false;
    }

    /// <summary>
    /// Checks if the transform has changed since the last sync snapshot.
    /// </summary>
    public bool HasChanged()
    {
        float threshold = 0.001f;
        bool posChanged = Vector3.Distance(transform.position, _lastSyncedPosition) > threshold;
        bool rotChanged = Vector3.Distance(transform.eulerAngles, _lastSyncedRotation) > threshold;
        bool scaleChanged = Vector3.Distance(transform.localScale, _lastSyncedScale) > threshold;
        return posChanged || rotChanged || scaleChanged;
    }

    void Update()
    {
        // Flag as dirty if the user has moved/rotated/scaled this object
        if (HasChanged())
        {
            isDirty = true;
        }
    }

    /// <summary>
    /// Serializes this furniture item's current state back into the JSON format
    /// expected by the Node.js backend.
    /// Converts Unity coords back to Three.js coords (negate Z, negate Y rotation).
    /// </summary>
    public string ToJson()
    {
        // Convert back to Three.js coordinate system
        Vector3 pos = transform.position;
        float threeX = pos.x;
        float threeY = pos.y;
        float threeZ = -pos.z; // Flip Z back

        Vector3 rot = transform.eulerAngles * Mathf.Deg2Rad;
        float rotX = rot.x;
        float rotY = -rot.y; // Flip Y rotation back
        float rotZ = rot.z;

        Vector3 sc = transform.localScale;

        return $@"{{
            ""type"": ""{furnitureType}"",
            ""label"": ""{furnitureLabel}"",
            ""name"": ""{furnitureLabel}"",
            ""price"": {furniturePrice},
            ""position"": {{ ""x"": {threeX:F3}, ""y"": {threeY:F3}, ""z"": {threeZ:F3} }},
            ""rotation"": {{ ""x"": {rotX:F3}, ""y"": {rotY:F3}, ""z"": {rotZ:F3} }},
            ""scale"": {{ ""x"": {sc.x:F3}, ""y"": {sc.y:F3}, ""z"": {sc.z:F3} }}
        }}";
    }
}
