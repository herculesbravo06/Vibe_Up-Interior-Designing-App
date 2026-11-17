using UnityEngine;
using UnityEngine.Networking;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// RoomLoader: Fetches JSON layout from the VibeUp Node.js API
/// and instantiates furniture prefabs at their correct world positions.
/// Attach this to a GameObject in your Quest scene.
/// </summary>
public class RoomLoader : MonoBehaviour
{
    [Header("API Configuration")]
    [Tooltip("Base URL of the Node.js VibeUp backend")]
    public string apiBaseUrl = "http://192.168.1.10:5000/api";

    [Tooltip("Room layout ID to load from the database")]
    public int layoutId = 1;

    [Header("Room Visuals")]
    [Tooltip("Material for the floor")]
    public Material floorMaterial;
    [Tooltip("Material for the walls")]
    public Material wallMaterial;

    [Header("Prefab Registry")]
    [Tooltip("Drag all furniture prefabs here. The prefab name MUST match the 'type' field from the JSON (e.g., 'sofa', 'table', 'bed').")]
    public GameObject[] furniturePrefabs;

    // Internal lookup: type string -> prefab
    private Dictionary<string, GameObject> _prefabMap = new Dictionary<string, GameObject>();

    // Reference to all instantiated furniture for later sync
    private List<FurnitureInstance> _instances = new List<FurnitureInstance>();

    // Parsed room data
    private RoomLayoutResponse _currentLayout;

    void Start()
    {
        // Build the prefab lookup dictionary from the array
        foreach (var prefab in furniturePrefabs)
        {
            if (prefab != null)
            {
                string key = prefab.name.ToLower().Replace(" ", "_");
                _prefabMap[key] = prefab;
            }
        }

        StartCoroutine(FetchAndBuildRoom());
    }

    /// <summary>
    /// Fetches room layout JSON from the API and builds the room.
    /// </summary>
    public IEnumerator FetchAndBuildRoom()
    {
        string url = $"{apiBaseUrl}/rooms/{layoutId}";
        Debug.Log($"[VibeUp] Fetching room layout from: {url}");

        using (UnityWebRequest req = UnityWebRequest.Get(url))
        {
            yield return req.SendWebRequest();

            if (req.result != UnityWebRequest.Result.Success)
            {
                Debug.LogError($"[VibeUp] API Error: {req.error}");
                yield break;
            }

            string json = req.downloadHandler.text;
            Debug.Log($"[VibeUp] Received JSON: {json.Substring(0, Mathf.Min(json.Length, 200))}...");

            // Parse the API response wrapper
            ApiResponse response = JsonUtility.FromJson<ApiResponse>(json);
            if (!response.success)
            {
                Debug.LogError("[VibeUp] API returned success=false");
                yield break;
            }

            // Parse the inner layout_data (which is a JSON string inside the response)
            _currentLayout = response.data;

            BuildRoom(_currentLayout);
        }
    }

    /// <summary>
    /// Constructs the room geometry and instantiates all furniture.
    /// </summary>
    void BuildRoom(RoomLayoutResponse layout)
    {
        // Clear previous instances
        foreach (var inst in _instances)
        {
            if (inst.gameObject != null) Destroy(inst.gameObject);
        }
        _instances.Clear();

        // --- Build Floor ---
        // layout_data is stored as a JSON array in MySQL. The room dimensions come from
        // the web editor's serialization. We use defaults if not in the item data.
        float roomW = 8f;  // Default from web editor
        float roomD = 8f;
        float roomH = 3f;

        GameObject floor = GameObject.CreatePrimitive(PrimitiveType.Plane);
        floor.name = "VR_Floor";
        floor.transform.localScale = new Vector3(roomW / 10f, 1f, roomD / 10f);
        floor.transform.position = Vector3.zero;
        if (floorMaterial != null) floor.GetComponent<Renderer>().material = floorMaterial;

        // --- Build Walls ---
        CreateWall("Wall_Back",  new Vector3(0, roomH / 2f, -roomD / 2f), new Vector3(roomW, roomH, 0.15f));
        CreateWall("Wall_Front", new Vector3(0, roomH / 2f,  roomD / 2f), new Vector3(roomW, roomH, 0.15f));
        CreateWall("Wall_Left",  new Vector3(-roomW / 2f, roomH / 2f, 0), new Vector3(0.15f, roomH, roomD));
        CreateWall("Wall_Right", new Vector3( roomW / 2f, roomH / 2f, 0), new Vector3(0.15f, roomH, roomD));

        // --- Instantiate Furniture ---
        if (layout.layout_data_parsed != null)
        {
            foreach (var item in layout.layout_data_parsed)
            {
                InstantiateFurniture(item);
            }
        }

        Debug.Log($"[VibeUp] Room built! {_instances.Count} furniture items placed.");
    }

    void CreateWall(string name, Vector3 position, Vector3 scale)
    {
        GameObject wall = GameObject.CreatePrimitive(PrimitiveType.Cube);
        wall.name = name;
        wall.transform.position = position;
        wall.transform.localScale = scale;
        if (wallMaterial != null) wall.GetComponent<Renderer>().material = wallMaterial;
    }

    /// <summary>
    /// Instantiates a single furniture item from the parsed JSON data.
    /// Three.js and Unity both use 1 unit = 1 meter, so positions translate directly.
    /// </summary>
    void InstantiateFurniture(FurnitureData item)
    {
        string typeKey = item.type.ToLower().Replace(" ", "_");

        if (!_prefabMap.ContainsKey(typeKey))
        {
            Debug.LogWarning($"[VibeUp] No prefab found for type: '{typeKey}'. Using fallback cube.");
            // Create a placeholder cube
            GameObject placeholder = GameObject.CreatePrimitive(PrimitiveType.Cube);
            placeholder.name = $"Unknown_{typeKey}";
            placeholder.transform.position = item.GetPosition();
            placeholder.transform.eulerAngles = item.GetRotationEuler();
            placeholder.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);

            var inst = placeholder.AddComponent<FurnitureInstance>();
            inst.furnitureType = typeKey;
            inst.furnitureLabel = item.label;
            _instances.Add(inst);
            return;
        }

        GameObject prefab = _prefabMap[typeKey];
        GameObject obj = Instantiate(prefab);
        obj.name = $"VR_{item.label}_{_instances.Count}";

        // Apply transforms from the web editor
        // Three.js: Y-up, right-handed. Unity: Y-up, left-handed.
        // Position: X maps directly, Y maps directly, Z is NEGATED.
        Vector3 pos = item.GetPosition();
        pos.z = -pos.z; // Flip Z for coordinate system difference
        obj.transform.position = pos;

        // Rotation: Y rotation from Three.js maps to -Y in Unity (due to handedness)
        Vector3 rot = item.GetRotationEuler();
        rot.y = -rot.y; // Flip Y rotation for handedness
        obj.transform.eulerAngles = rot * Mathf.Rad2Deg;

        // Scale
        obj.transform.localScale = item.GetScale();

        // Tag for interaction
        var instance = obj.AddComponent<FurnitureInstance>();
        instance.furnitureType = typeKey;
        instance.furnitureLabel = item.label;
        instance.furniturePrice = item.price;
        _instances.Add(instance);
    }

    /// <summary>
    /// Returns all current furniture instances (used by SyncManager).
    /// </summary>
    public List<FurnitureInstance> GetInstances() => _instances;
}

// ─── Data Models ───

[System.Serializable]
public class ApiResponse
{
    public bool success;
    public RoomLayoutResponse data;
}

[System.Serializable]
public class RoomLayoutResponse
{
    public int id;
    public int project_id;
    public string layout_data; // Raw JSON string from MySQL
    public string updated_at;

    // Parsed furniture items (call ParseLayoutData() after deserialization)
    [System.NonSerialized]
    public List<FurnitureData> layout_data_parsed;

    public void ParseLayoutData()
    {
        if (!string.IsNullOrEmpty(layout_data))
        {
            layout_data_parsed = JsonHelper.FromJsonArray<FurnitureData>(layout_data);
        }
    }
}

[System.Serializable]
public class FurnitureData
{
    public string type;
    public string label;
    public string name;
    public float price;
    public Vector3Data position;
    public Vector3Data rotation;
    public Vector3Data scale;

    public Vector3 GetPosition()
    {
        if (position != null) return new Vector3(position.x, position.y, position.z);
        return Vector3.zero;
    }

    public Vector3 GetRotationEuler()
    {
        if (rotation != null) return new Vector3(rotation.x, rotation.y, rotation.z);
        return Vector3.zero;
    }

    public Vector3 GetScale()
    {
        if (scale != null) return new Vector3(scale.x, scale.y, scale.z);
        return Vector3.one;
    }
}

[System.Serializable]
public class Vector3Data
{
    public float x;
    public float y;
    public float z;
}

/// <summary>
/// Helper to deserialize JSON arrays with Unity's JsonUtility.
/// </summary>
public static class JsonHelper
{
    public static List<T> FromJsonArray<T>(string json)
    {
        // JsonUtility can't parse raw arrays, so we wrap it
        string wrapped = "{\"items\":" + json + "}";
        Wrapper<T> wrapper = JsonUtility.FromJson<Wrapper<T>>(wrapped);
        return wrapper.items != null ? new List<T>(wrapper.items) : new List<T>();
    }

    [System.Serializable]
    private class Wrapper<T>
    {
        public T[] items;
    }
}
