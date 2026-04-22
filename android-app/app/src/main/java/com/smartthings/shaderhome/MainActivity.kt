package com.smartthings.shaderhome

import android.content.res.AssetManager
import android.graphics.BitmapFactory
import android.os.Bundle
import android.util.Log
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.Image
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.ElectricBolt
import androidx.compose.material.icons.rounded.GridView
import androidx.compose.material.icons.rounded.HelpOutline
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material.icons.rounded.Lightbulb
import androidx.compose.material.icons.rounded.Remove
import androidx.compose.material.icons.rounded.Menu
import androidx.compose.material.icons.rounded.MoreVert
import androidx.compose.material.icons.rounded.OpenWith
import androidx.compose.material.icons.rounded.PlayCircleOutline
import androidx.compose.material.icons.rounded.Thermostat
import androidx.compose.material.icons.rounded.ViewInAr
import androidx.compose.material.icons.rounded.Videocam
import androidx.compose.material.icons.rounded.Bolt
import androidx.compose.material.icons.automirrored.rounded.HelpOutline
import androidx.compose.material.icons.automirrored.rounded.RotateRight
import androidx.compose.material.icons.automirrored.rounded.Redo
import androidx.compose.material.icons.automirrored.rounded.Undo
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import org.godotengine.godot.Godot
import org.godotengine.godot.GodotFragment
import org.godotengine.godot.GodotHost
import org.godotengine.godot.plugin.GodotPlugin
import org.json.JSONArray
import org.json.JSONObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Locale
import com.smartthings.shaderhome.ui.theme.AppTheme
import com.smartthings.shaderhome.ui.theme.LocalSmartThingsTokens

private const val DEVICE_KIND_AIR_CONDITIONER = "air_conditioner"
private const val DEVICE_KIND_AIR_PURIFIER = "air_purifier"
private const val DEVICE_KIND_CAMERA = "camera"

class MainActivity : AppCompatActivity(), GodotHost, ShaderHostPlugin.ActivityBridge {
    private companion object {
        private const val TAG = "SmartHomePlugin"
        private val homeSkinOptions = listOf(
            HomeSkinOption(
                id = "warm_minimal",
                label = "Warm",
                roomColors = listOf(
                    Color(0xFFE9DCCA),
                    Color(0xFFD9C5AE),
                    Color(0xFFE8DFD3),
                    Color(0xFFC7B39A),
                ),
            ),
            HomeSkinOption(
                id = "cool_modern",
                label = "Cool",
                roomColors = listOf(
                    Color(0xFFD9DDE3),
                    Color(0xFFB8C2CF),
                    Color(0xFFE6E9EE),
                    Color(0xFF9EA9BA),
                ),
            ),
            HomeSkinOption(
                id = "soft_contrast",
                label = "Contrast",
                roomColors = listOf(
                    Color(0xFFC7D6B9),
                    Color(0xFFD8D8E8),
                    Color(0xFFA7D0FF),
                    Color(0xFFE8B4E4),
                ),
            ),
        )
        private val floorFinishOptions = listOf(
            FloorFinishOption("oak_light", "Oak Light", Color(0xFFDCC8B1), PatternStyle.WOOD),
            FloorFinishOption("oak_dark", "Oak Dark", Color(0xFF7D614A), PatternStyle.WOOD),
            FloorFinishOption("herringbone_beige", "Herringbone", Color(0xFFC9B7A5), PatternStyle.HERRINGBONE),
            FloorFinishOption("tile_rect_beige", "Rectangle Tile", Color(0xFFD9C7B5), PatternStyle.RECTANGLE),
            FloorFinishOption("zigzag_taupe", "Zig Zag", Color(0xFFC3B2A1), PatternStyle.ZIGZAG),
            FloorFinishOption("grid_ash", "Grid Tile", Color(0xFFBBC4CE), PatternStyle.GRID),
            FloorFinishOption("marble_white", "Marble White", Color(0xFFE8E8EC), PatternStyle.MARBLE),
            FloorFinishOption("tile_soft_gray", "Soft Gray Tile", Color(0xFFBBC4CE), PatternStyle.PEBBLE),
        )
    }

    private var godotFragment: GodotFragment? = null
    private var shaderHostPlugin: ShaderHostPlugin? = null
    private val isCatalogExpanded = mutableStateOf(false)
    private val selectedFurnitureModel = mutableStateOf<String?>(null)
    private val lightFocusActive = mutableStateOf(false)
    private val lightOnCount = mutableStateOf(0)
    private val lightTotalCount = mutableStateOf(0)
    private val temperatureFocusActive = mutableStateOf(false)
    private val airQualityFocusActive = mutableStateOf(false)
    private val cameraFocusActive = mutableStateOf(false)
    private val energyFocusActive = mutableStateOf(false)
    private val energySummary = mutableStateOf<EnergySummaryState?>(null)
    private val temperatureMin = mutableStateOf(0)
    private val temperatureMax = mutableStateOf(0)
    private val airConditionerOnCount = mutableStateOf(0)
    private val airConditionerTotalCount = mutableStateOf(0)
    private val deviceDialogState = mutableStateOf<DeviceControlDialogState?>(null)
    private val floorPlanEditorActive = mutableStateOf(false)
    private val furnitureEditModeActive = mutableStateOf(false)
    private val floorPlanEditorSelection = mutableStateOf<FloorEditorSelectionState?>(null)
    private val is3dMode = mutableStateOf(true)
    private val selectedHomeSkinId = mutableStateOf("warm_minimal")

    private var pendingShaderSelectionPayload: String? = null
    private var pendingViewMode: Boolean? = null
    private var pendingFurnitureSelection: String? = null
    private var pendingLightFocusMode: Boolean? = null
    private var pendingTemperatureFocusMode: Boolean? = null
    private var pendingAirQualityFocusMode: Boolean? = null
    private var pendingCameraFocusMode: Boolean? = null
    private var pendingEnergyFocusMode: Boolean? = null
    private var pendingFloorPlanEditMode: Boolean? = null
    private var pendingFurnitureEditMode: Boolean? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        bindGodotFragment()
        catalogFurnitureItemsCache = loadCatalogFurnitureItems()
        findViewById<ComposeView>(R.id.top_controls_compose_view).setContent {
            AppTheme(darkTheme = true) {
                Surface(
                    color = Color.Transparent,
                ) {
                    TopChrome(
                        lightOnCount = lightOnCount.value,
                        lightFocusActive = lightFocusActive.value,
                        temperatureMin = temperatureMin.value,
                        temperatureMax = temperatureMax.value,
                        airConditionerOnCount = airConditionerOnCount.value,
                        airConditionerTotalCount = airConditionerTotalCount.value,
                        temperatureFocusActive = temperatureFocusActive.value,
                        airQualityFocusActive = airQualityFocusActive.value,
                        cameraFocusActive = cameraFocusActive.value,
                        energyFocusActive = energyFocusActive.value,
                        activeDialog = deviceDialogState.value,
                        isCatalogExpanded = isCatalogExpanded.value,
                        isFloorPlanEditorActive = floorPlanEditorActive.value,
                        isFurnitureEditModeActive = furnitureEditModeActive.value,
                        homeSkinOptions = homeSkinOptions,
                        selectedHomeSkinId = selectedHomeSkinId.value,
                        onToggleLightFocus = { toggleLightFocus() },
                        onToggleTemperatureFocus = { toggleTemperatureFocus() },
                        onToggleAirQualityFocus = { toggleAirQualityFocus() },
                        onToggleCameraFocus = { toggleCameraFocus() },
                        onToggleEnergyFocus = { toggleEnergyFocus() },
                        onToggleCatalogExpansion = { toggleCatalogExpansion() },
                        onToggleFloorPlanEditor = { toggleFloorPlanEditor() },
                        onToggleFurnitureEditMode = { toggleFurnitureEditMode() },
                        onActivateLayoutMode = { activateLayoutMode() },
                        onActivateInteriorMode = { activateInteriorMode() },
                        onHomeSkinSelected = { selectHomeSkin(it) },
                        onDismissDeviceDialog = { deviceDialogState.value = null },
                        onDeviceCommand = { deviceId, isOn -> requestDeviceCommand(deviceId, isOn) },
                    )
                }
            }
        }
        findViewById<ComposeView>(R.id.side_controls_compose_view).setContent {
            AppTheme(darkTheme = true) {
                Surface(
                    color = Color.Transparent,
                ) {
                    FloatingControls(
                        is3dMode = is3dMode.value,
                        enabled = !floorPlanEditorActive.value,
                        isEditMapMode = floorPlanEditorActive.value || furnitureEditModeActive.value,
                        onToggle3d = { setViewMode(it) },
                        onRotate = { requestRotate() },
                    )
                }
            }
        }
        findViewById<ComposeView>(R.id.bottom_controls_compose_view).setContent {
            AppTheme(darkTheme = true) {
                Surface(
                    color = Color.Transparent,
                ) {
                    BottomChrome(
                        isCatalogExpanded = isCatalogExpanded.value,
                        isFloorPlanEditorActive = floorPlanEditorActive.value,
                        isFurnitureEditModeActive = furnitureEditModeActive.value,
                        floorEditorSelection = floorPlanEditorSelection.value,
                        selectedFurnitureModel = selectedFurnitureModel.value,
                        is3dMode = is3dMode.value,
                        floorFinishOptions = floorFinishOptions,
                        energyFocusActive = energyFocusActive.value,
                        energySummary = energySummary.value,
                        onFurnitureSelected = { selectFurniture(it) },
                        onDismissCatalog = { dismissCatalog() },
                        onClearFurnitureSelection = { clearFurnitureSelection() },
                        onToggle3d = { setViewMode(it) },
                        onRotate = { requestRotate() },
                        onCancelFurnitureEdit = { cancelFurnitureEdit() },
                        onDoneFurnitureEdit = { finishFurnitureEdit() },
                        onPreviewFloorFinish = { previewFloorFinish(it) },
                        onApplyFloorFinishToAll = { applyFloorFinishToAll() },
                        onApplyFloorPlanChanges = { applyFloorPlanSession() },
                        onCancelFloorPlanChanges = { cancelFloorPlanSession() },
                    )
                }
            }
        }
    }

    private fun bindGodotFragment() {
        val current = supportFragmentManager.findFragmentById(R.id.godot_fragment_container)
        if (current is GodotFragment) {
            godotFragment = current
        } else {
            godotFragment = GodotFragment()
            supportFragmentManager.beginTransaction()
                .replace(R.id.godot_fragment_container, godotFragment!!)
                .commitNowAllowingStateLoss()
        }
        godot?.let { initPluginIfNeeded(it) }
    }

    private fun emitShaderSelection(shaderIds: List<String>) {
        val payload = JSONArray(shaderIds).toString()
        pendingShaderSelectionPayload = payload
        flushPendingPluginSignals()
    }

    private fun setViewMode(is3d: Boolean) {
        is3dMode.value = is3d
        pendingViewMode = is3d
        flushPendingPluginSignals()
    }

    private fun toggleFloorPlanEditor() {
        if (floorPlanEditorActive.value) {
            cancelFloorPlanSession()
        } else {
            setFloorPlanEditorEnabled(true)
        }
    }

    private fun setFloorPlanEditorEnabled(enabled: Boolean) {
        floorPlanEditorActive.value = enabled
        pendingFloorPlanEditMode = enabled
        if (enabled) {
            setFurnitureEditModeEnabled(false)
            selectedFurnitureModel.value = null
            pendingFurnitureSelection = ""
            isCatalogExpanded.value = false
            setViewMode(false)
        } else {
            floorPlanEditorSelection.value = null
            setViewMode(true)
        }
        flushPendingPluginSignals()
    }

    private fun toggleFurnitureEditMode() {
        setFurnitureEditModeEnabled(!furnitureEditModeActive.value)
    }

    private fun activateLayoutMode() {
        setFloorPlanEditorEnabled(true)
    }

    private fun activateInteriorMode() {
        setFurnitureEditModeEnabled(true)
    }

    private fun setFurnitureEditModeEnabled(enabled: Boolean) {
        if (furnitureEditModeActive.value == enabled) {
            return
        }
        if (enabled && floorPlanEditorActive.value) {
            setFloorPlanEditorEnabled(false)
        }
        furnitureEditModeActive.value = enabled
        pendingFurnitureEditMode = enabled
        isCatalogExpanded.value = false
        if (!enabled) {
            selectedFurnitureModel.value = null
            pendingFurnitureSelection = ""
        }
        flushPendingPluginSignals()
    }

    private fun selectHomeSkin(skinId: String) {
        selectedHomeSkinId.value = skinId
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.selectHomeSkin(skinId)
        }
    }

    private fun previewFloorFinish(finishId: String) {
        val selection = floorPlanEditorSelection.value ?: return
        floorPlanEditorSelection.value = selection.copy(pendingFinishId = finishId)
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.previewRoomFinish(finishId)
        }
    }

    private fun applyFloorFinish() {
        val selection = floorPlanEditorSelection.value ?: return
        val nextFinishId = selection.pendingFinishId
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.applyRoomFinish()
        }
        floorPlanEditorSelection.value = selection.copy(committedFinishId = nextFinishId)
    }

    private fun cancelFloorFinish() {
        val selection = floorPlanEditorSelection.value ?: return
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.cancelRoomFinish()
        }
        floorPlanEditorSelection.value = selection.copy(pendingFinishId = selection.committedFinishId)
    }

    private fun applyFloorFinishToAll() {
        val selection = floorPlanEditorSelection.value ?: return
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.applyRoomFinishToAll(selection.pendingFinishId)
        }
    }

    private fun applyFloorPlanSession() {
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.applyFloorPlanSession()
        }
        setFloorPlanEditorEnabled(false)
    }

    private fun cancelFloorPlanSession() {
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.cancelFloorPlanSession()
        }
        setFloorPlanEditorEnabled(false)
    }

    private fun requestRotate() {
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.requestRotate()
        } else {
            Log.w(TAG, "Dropping rotate request because plugin is not ready yet")
        }
    }

    private fun toggleLightFocus() {
        val nextValue = !lightFocusActive.value
        lightFocusActive.value = nextValue
        if (nextValue) {
            temperatureFocusActive.value = false
            pendingTemperatureFocusMode = false
            airQualityFocusActive.value = false
            pendingAirQualityFocusMode = false
        }
        godot?.let { initPluginIfNeeded(it) }
        pendingLightFocusMode = nextValue
        flushPendingPluginSignals()
    }

    private fun toggleTemperatureFocus() {
        if (airConditionerOnCount.value == 0) {
            temperatureFocusActive.value = false
            pendingTemperatureFocusMode = false
            return
        }
        val nextValue = !temperatureFocusActive.value
        temperatureFocusActive.value = nextValue
        if (nextValue) {
            lightFocusActive.value = false
            pendingLightFocusMode = false
            airQualityFocusActive.value = false
            pendingAirQualityFocusMode = false
        }
        godot?.let { initPluginIfNeeded(it) }
        pendingTemperatureFocusMode = nextValue
        flushPendingPluginSignals()
    }

    private fun toggleAirQualityFocus() {
        val nextValue = !airQualityFocusActive.value
        airQualityFocusActive.value = nextValue
        if (nextValue) {
            lightFocusActive.value = false
            temperatureFocusActive.value = false
            cameraFocusActive.value = false
            energyFocusActive.value = false
            pendingLightFocusMode = false
            pendingTemperatureFocusMode = false
            pendingCameraFocusMode = false
            pendingEnergyFocusMode = false
            energySummary.value = null
        }
        godot?.let { initPluginIfNeeded(it) }
        pendingAirQualityFocusMode = nextValue
        flushPendingPluginSignals()
    }

    private fun toggleCameraFocus() {
        val nextValue = !cameraFocusActive.value
        cameraFocusActive.value = nextValue
        if (nextValue) {
            lightFocusActive.value = false
            temperatureFocusActive.value = false
            airQualityFocusActive.value = false
            energyFocusActive.value = false
            pendingLightFocusMode = false
            pendingTemperatureFocusMode = false
            pendingAirQualityFocusMode = false
            pendingEnergyFocusMode = false
            energySummary.value = null
        }
        godot?.let { initPluginIfNeeded(it) }
        pendingCameraFocusMode = nextValue
        flushPendingPluginSignals()
    }

    private fun toggleEnergyFocus() {
        val nextValue = !energyFocusActive.value
        energyFocusActive.value = nextValue
        if (nextValue) {
            lightFocusActive.value = false
            temperatureFocusActive.value = false
            airQualityFocusActive.value = false
            cameraFocusActive.value = false
            pendingLightFocusMode = false
            pendingTemperatureFocusMode = false
            pendingAirQualityFocusMode = false
            pendingCameraFocusMode = false
        } else {
            energySummary.value = null
        }
        godot?.let { initPluginIfNeeded(it) }
        pendingEnergyFocusMode = nextValue
        flushPendingPluginSignals()
    }

    private fun requestDeviceCommand(deviceId: String, isOn: Boolean) {
        deviceDialogState.value = null
        godot?.let { initPluginIfNeeded(it) }
        if (shaderHostPlugin?.isPluginReady() == true) {
            shaderHostPlugin?.requestDeviceCommand(deviceId, isOn)
        } else {
            Log.w(TAG, "Dropping device command because plugin is not ready yet")
        }
    }

    private fun toggleCatalogExpansion() {
        if (floorPlanEditorActive.value) {
            return
        }
        setFurnitureEditModeEnabled(!furnitureEditModeActive.value)
    }

    private fun dismissCatalog() {
        cancelFurnitureEdit()
    }

    private fun clearFurnitureSelection() {
        selectedFurnitureModel.value = null
        pendingFurnitureSelection = ""
        flushPendingPluginSignals()
    }

    private fun cancelFurnitureEdit() {
        clearFurnitureSelection()
        setFurnitureEditModeEnabled(false)
    }

    private fun finishFurnitureEdit() {
        setFurnitureEditModeEnabled(false)
    }

    private fun selectFurniture(modelId: String) {
        setFurnitureEditModeEnabled(true)
        selectedFurnitureModel.value = modelId
        pendingFurnitureSelection = modelId
        flushPendingPluginSignals()
    }

    private fun loadCatalogFurnitureItems(): List<CatalogFurnitureItem> {
        return runCatching {
            val manifestText = assets.open("GLB/ikea/manifest.json").bufferedReader().use { it.readText() }
            val items = JSONObject(manifestText).optJSONArray("items") ?: JSONArray()
            val ikeaAssetNames = assets.list("GLB/ikea")?.toSet().orEmpty()
            val ikeaItems = buildList {
                for (index in 0 until items.length()) {
                    val item = items.optJSONObject(index) ?: continue
                    val modelId = item.optString("slug").trim()
                    val outputFile = item.optString("output_file").trim()
                    if (modelId.isEmpty() || outputFile.isEmpty() || !outputFile.endsWith(".glb")) {
                        continue
                    }
                    val productName = item.optString("product_name").trim()
                    val articleNumber = item.optString("article_number").trim()
                    val thumbnailKind = furnitureThumbnailKindFor(modelId, productName)
                    add(
                        CatalogFurnitureItem(
                            modelId = modelId,
                            label = furnitureCatalogLabel(productName, modelId),
                            assetFileName = furnitureCatalogAssetLabel(outputFile, articleNumber),
                            sourceLabel = furnitureCatalogSourceLabel(articleNumber),
                            accentColor = accentColorFor(thumbnailKind),
                            thumbnailKind = thumbnailKind,
                            previewAssetPath = furniturePreviewAssetPathFor(
                                modelId = modelId,
                                ikeaAssetNames = ikeaAssetNames,
                                articleNumber = articleNumber,
                            ),
                        ),
                    )
                }
            }
            val rankedIkeaItems = ikeaItems.sortedWith(
                compareByDescending<CatalogFurnitureItem> { furniturePreviewScore(it.previewAssetPath) }
                    .thenBy { it.label },
            )
            if (rankedIkeaItems.isEmpty()) {
                defaultCatalogFurnitureItems()
            } else {
                rankedIkeaItems + defaultLegacyCatalogFurnitureItems()
            }
        }.getOrElse { error ->
            Log.w(TAG, "Failed to load IKEA furniture manifest for catalog", error)
            defaultCatalogFurnitureItems()
        }
    }

    private fun initPluginIfNeeded(godot: Godot) {
        if (shaderHostPlugin == null) {
            shaderHostPlugin = ShaderHostPlugin(godot, this)
            pendingShaderSelectionPayload = JSONArray(emptyList<String>()).toString()
            pendingViewMode = is3dMode.value
            pendingLightFocusMode = lightFocusActive.value
            pendingTemperatureFocusMode = temperatureFocusActive.value
            pendingAirQualityFocusMode = airQualityFocusActive.value
            pendingCameraFocusMode = cameraFocusActive.value
            pendingEnergyFocusMode = energyFocusActive.value
            pendingFurnitureSelection = ""
            pendingFloorPlanEditMode = floorPlanEditorActive.value
            pendingFurnitureEditMode = furnitureEditModeActive.value
            flushPendingPluginSignals()
        }
    }

    private fun flushPendingPluginSignals() {
        val plugin = shaderHostPlugin ?: return
        if (!plugin.isPluginReady()) {
            return
        }

        pendingShaderSelectionPayload?.let { payload ->
            if (safeEmitSignal { plugin.updateShaderSelection(payload) }) {
                pendingShaderSelectionPayload = null
            }
        }

        pendingViewMode?.let { is3d ->
            if (safeEmitSignal { plugin.updateViewMode(is3d) }) {
                pendingViewMode = null
            }
        }

        pendingFurnitureSelection?.let { modelId ->
            if (safeEmitSignal { plugin.updateFurnitureSelection(modelId) }) {
                pendingFurnitureSelection = null
            }
        }

        pendingLightFocusMode?.let { isActive ->
            if (safeEmitSignal { plugin.updateLightFocusMode(isActive) }) {
                pendingLightFocusMode = null
            }
        }

        pendingTemperatureFocusMode?.let { isActive ->
            if (safeEmitSignal { plugin.updateTemperatureFocusMode(isActive) }) {
                pendingTemperatureFocusMode = null
            }
        }

        pendingAirQualityFocusMode?.let { isActive ->
            if (safeEmitSignal { plugin.updateAirQualityFocusMode(isActive) }) {
                pendingAirQualityFocusMode = null
            }
        }

        pendingCameraFocusMode?.let { isActive ->
            if (safeEmitSignal { plugin.updateCameraFocusMode(isActive) }) {
                pendingCameraFocusMode = null
            }
        }

        pendingEnergyFocusMode?.let { isActive ->
            if (safeEmitSignal { plugin.updateEnergyFocusMode(isActive) }) {
                pendingEnergyFocusMode = null
            }
        }

        pendingFloorPlanEditMode?.let { isActive ->
            if (safeEmitSignal { plugin.updateFloorPlanEditMode(isActive) }) {
                pendingFloorPlanEditMode = null
            }
        }

        pendingFurnitureEditMode?.let { isActive ->
            if (safeEmitSignal { plugin.updateFurnitureEditMode(isActive) }) {
                pendingFurnitureEditMode = null
            }
        }
    }

    private fun safeEmitSignal(action: () -> Unit): Boolean {
        return try {
            action()
            true
        } catch (ex: IllegalArgumentException) {
            Log.w(TAG, "Signal emit attempt failed before registration", ex)
            false
        }
    }

    override fun onDeviceDialogRequested(
        deviceId: String,
        roomLabel: String,
        deviceName: String,
        deviceKind: String,
        isOn: Boolean,
        temperatureC: Int,
    ) {
        deviceDialogState.value = DeviceControlDialogState(
            deviceId = deviceId,
            roomLabel = roomLabel,
            deviceName = deviceName,
            deviceKind = deviceKind,
            isOn = isOn,
            temperatureC = temperatureC,
        )
    }

    override fun onLightStatusChanged(onCount: Int, totalCount: Int) {
        lightOnCount.value = onCount
        lightTotalCount.value = totalCount
        if (lightTotalCount.value == 0) {
            lightFocusActive.value = false
            pendingLightFocusMode = false
            flushPendingPluginSignals()
        }
    }

    override fun onTemperatureStatusChanged(
        minTemperature: Int,
        maxTemperature: Int,
        onCount: Int,
        totalCount: Int,
    ) {
        temperatureMin.value = minTemperature
        temperatureMax.value = maxTemperature
        airConditionerOnCount.value = onCount
        airConditionerTotalCount.value = totalCount
        if (airConditionerOnCount.value == 0) {
            temperatureFocusActive.value = false
            pendingTemperatureFocusMode = false
            flushPendingPluginSignals()
        }
    }

    override fun onPluginReady() {
        Log.i(TAG, "Plugin ready; flushing queued signals")
        flushPendingPluginSignals()
    }

    override fun onFloorEditorSelectionChanged(
        roomId: String,
        roomLabel: String,
        committedFinishId: String,
        pendingFinishId: String,
    ) {
        floorPlanEditorSelection.value = FloorEditorSelectionState(
            roomId = roomId,
            roomLabel = roomLabel,
            committedFinishId = committedFinishId,
            pendingFinishId = pendingFinishId,
        )
    }

    override fun onFloorEditorSelectionCleared() {
        floorPlanEditorSelection.value = null
    }

    override fun onFurnitureCatalogSelectionCleared() {
        selectedFurnitureModel.value = null
    }

    override fun onCameraCalloutRequested(
        deviceId: String,
        roomLabel: String,
        imageAssetPath: String,
    ) {
        // Camera callout is rendered in-world (Godot side); nothing to do here.
    }

    override fun onEnergySummaryUpdated(
        savingRatePercent: Double,
        usageKwh: Double,
        usageCost: Double,
        savingsKwh: Double,
        savingsCost: Double,
    ) {
        energySummary.value = EnergySummaryState(
            savingRatePercent = savingRatePercent,
            usageKwh = usageKwh,
            usageCost = usageCost,
            savingsKwh = savingsKwh,
            savingsCost = savingsCost,
        )
    }

    override fun getActivity() = this

    override fun getGodot() = godotFragment?.godot

    override fun getCommandLine(): MutableList<String> {
        return super.getCommandLine().toMutableList()
    }

    override fun getHostPlugins(godot: Godot): Set<GodotPlugin> {
        initPluginIfNeeded(godot)
        return setOfNotNull(shaderHostPlugin)
    }
}

@Composable
private fun TopChrome(
    lightOnCount: Int,
    lightFocusActive: Boolean,
    temperatureMin: Int,
    temperatureMax: Int,
    airConditionerOnCount: Int,
    airConditionerTotalCount: Int,
    temperatureFocusActive: Boolean,
    airQualityFocusActive: Boolean,
    cameraFocusActive: Boolean,
    energyFocusActive: Boolean,
    activeDialog: DeviceControlDialogState?,
    isCatalogExpanded: Boolean,
    isFloorPlanEditorActive: Boolean,
    isFurnitureEditModeActive: Boolean,
    homeSkinOptions: List<HomeSkinOption>,
    selectedHomeSkinId: String,
    onToggleLightFocus: () -> Unit,
    onToggleTemperatureFocus: () -> Unit,
    onToggleAirQualityFocus: () -> Unit,
    onToggleCameraFocus: () -> Unit,
    onToggleEnergyFocus: () -> Unit,
    onToggleCatalogExpansion: () -> Unit,
    onToggleFloorPlanEditor: () -> Unit,
    onToggleFurnitureEditMode: () -> Unit,
    onActivateLayoutMode: () -> Unit,
    onActivateInteriorMode: () -> Unit,
    onHomeSkinSelected: (String) -> Unit,
    onDismissDeviceDialog: () -> Unit,
    onDeviceCommand: (String, Boolean) -> Unit,
) {
    val isMapEditMode = isFloorPlanEditorActive || isFurnitureEditModeActive
    val airPurifierIcon = rememberAssetBitmap("SmartThingsIcons/Air_Purifier.png")
    val cameraPillIcon = rememberAssetBitmap("SmartThingsIcons/Camera_1.png")

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.Transparent)
            .systemBarsPadding()
            .padding(vertical = 10.dp),
    ) {
        if (isMapEditMode) {
            Box(modifier = Modifier.padding(horizontal = 24.dp)) {
                EditMapTopPanel(
                    selectedMode = if (isFloorPlanEditorActive) EditMapMode.LAYOUT else EditMapMode.INTERIOR,
                    onSelectLayout = onActivateLayoutMode,
                    onSelectInterior = onActivateInteriorMode,
                )
            }
        } else {
            Box(modifier = Modifier.padding(horizontal = 24.dp)) {
                HeaderRow(
                    isCatalogExpanded = isCatalogExpanded,
                    isFloorPlanEditorActive = isFloorPlanEditorActive,
                    isFurnitureEditModeActive = isFurnitureEditModeActive,
                    onToggleCatalog = onToggleCatalogExpansion,
                    onToggleFloorPlanEditor = onToggleFloorPlanEditor,
                    onToggleFurnitureEditMode = onToggleFurnitureEditMode,
                )
            }
            Spacer(modifier = Modifier.height(26.dp))
            StatusPills(
                lightOnCount = lightOnCount,
                lightFocusActive = lightFocusActive,
                temperatureMin = temperatureMin,
                temperatureMax = temperatureMax,
                airConditionerOnCount = airConditionerOnCount,
                airConditionerTotalCount = airConditionerTotalCount,
                temperatureFocusActive = temperatureFocusActive,
                airQualityFocusActive = airQualityFocusActive,
                cameraFocusActive = cameraFocusActive,
                energyFocusActive = energyFocusActive,
                airPurifierIcon = airPurifierIcon,
                cameraIcon = cameraPillIcon,
                onToggleLightFocus = onToggleLightFocus,
                onToggleTemperatureFocus = onToggleTemperatureFocus,
                onToggleAirQualityFocus = onToggleAirQualityFocus,
                onToggleCameraFocus = onToggleCameraFocus,
                onToggleEnergyFocus = onToggleEnergyFocus,
            )
        }
        DeviceControlDialog(
            activeDialog = activeDialog,
            onDismiss = onDismissDeviceDialog,
            onDeviceCommand = onDeviceCommand,
        )
    }
}

@Composable
private fun FloatingControls(
    is3dMode: Boolean,
    enabled: Boolean,
    isEditMapMode: Boolean,
    onToggle3d: (Boolean) -> Unit,
    onRotate: () -> Unit,
) {
    Column(
        modifier = Modifier
            .background(Color.Transparent)
            .padding(top = 4.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        if (isEditMapMode) {
            FloatingIconButton(
                icon = Icons.Rounded.OpenWith,
                onClick = {},
            )
        } else if (enabled) {
            FloatingCircleButton(
                label = if (is3dMode) "3D" else "2D",
                onClick = {
                    onToggle3d(!is3dMode)
                },
            )
            FloatingIconButton(
                icon = Icons.AutoMirrored.Rounded.RotateRight,
                onClick = onRotate,
            )
        }
    }
}

@Composable
private fun BottomChrome(
    isCatalogExpanded: Boolean,
    isFloorPlanEditorActive: Boolean,
    isFurnitureEditModeActive: Boolean,
    floorEditorSelection: FloorEditorSelectionState?,
    selectedFurnitureModel: String?,
    is3dMode: Boolean,
    floorFinishOptions: List<FloorFinishOption>,
    energyFocusActive: Boolean,
    energySummary: EnergySummaryState?,
    onFurnitureSelected: (String) -> Unit,
    onDismissCatalog: () -> Unit,
    onClearFurnitureSelection: () -> Unit,
    onToggle3d: (Boolean) -> Unit,
    onRotate: () -> Unit,
    onCancelFurnitureEdit: () -> Unit,
    onDoneFurnitureEdit: () -> Unit,
    onPreviewFloorFinish: (String) -> Unit,
    onApplyFloorFinishToAll: () -> Unit,
    onApplyFloorPlanChanges: () -> Unit,
    onCancelFloorPlanChanges: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.Transparent)
            .navigationBarsPadding()
            .padding(horizontal = 10.dp, vertical = 10.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        if (energyFocusActive && energySummary != null
            && !isFurnitureEditModeActive && !isFloorPlanEditorActive) {
            Box(modifier = Modifier.padding(horizontal = 14.dp)) {
                EnergySummaryCard(summary = energySummary)
            }
        }
        if (isFurnitureEditModeActive) {
            InteriorCatalogBottomSheet(
                items = catalogFurnitureItems(),
                selectedFurnitureModel = selectedFurnitureModel,
                is3dMode = is3dMode,
                onFurnitureSelected = onFurnitureSelected,
                onClearFurnitureSelection = onClearFurnitureSelection,
                onToggle3d = onToggle3d,
                onRotate = onRotate,
                onCancel = onCancelFurnitureEdit,
                onDone = onDoneFurnitureEdit,
            )
        } else if (isFloorPlanEditorActive) {
            FloorPlanEditorSheet(
                selection = floorEditorSelection,
                finishOptions = floorFinishOptions,
                onPreviewFinish = onPreviewFloorFinish,
                onApplyToAll = onApplyFloorFinishToAll,
                onApply = onApplyFloorPlanChanges,
                onCancel = onCancelFloorPlanChanges,
            )
        } else {
            BottomNavigationBar(
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}

private enum class EditMapMode {
    LAYOUT,
    INTERIOR,
}

private enum class EditMapCatalogSection(val title: String) {
    DEVICE("Device"),
    FURNITURE("Furniture"),
    STRUCTURES("Structures"),
    DECORATIONS("Decorations"),
}

@Composable
private fun EditMapTopPanel(
    selectedMode: EditMapMode,
    onSelectLayout: () -> Unit,
    onSelectInterior: () -> Unit,
) {
    val colorScheme = MaterialTheme.colorScheme

    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(24.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Edit Map View",
                color = colorScheme.onBackground,
                style = MaterialTheme.typography.headlineMedium,
            )
            Spacer(modifier = Modifier.weight(1f))
            Surface(
                onClick = {},
                color = Color.Transparent,
                shape = CircleShape,
                border = BorderStroke(1.dp, colorScheme.outlineVariant),
            ) {
                Box(
                    modifier = Modifier.size(40.dp),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Rounded.HelpOutline,
                        contentDescription = null,
                        tint = colorScheme.onBackground,
                        modifier = Modifier.size(20.dp),
                    )
                }
            }
        }

        Surface(
            modifier = Modifier.fillMaxWidth(0.9f),
            color = colorScheme.surfaceVariant,
            shape = RoundedCornerShape(999.dp),
            border = BorderStroke(1.dp, colorScheme.outline),
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(6.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                EditModeSegmentButton(
                    modifier = Modifier.weight(1f),
                    label = "Layout",
                    selected = selectedMode == EditMapMode.LAYOUT,
                    onClick = onSelectLayout,
                )
                EditModeSegmentButton(
                    modifier = Modifier.weight(1f),
                    label = "Interior",
                    selected = selectedMode == EditMapMode.INTERIOR,
                    onClick = onSelectInterior,
                )
            }
        }
    }
}

@Composable
private fun EditModeSegmentButton(
    modifier: Modifier = Modifier,
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
) {
    val colorScheme = MaterialTheme.colorScheme
    val tokens = LocalSmartThingsTokens.current

    Surface(
        modifier = modifier,
        onClick = onClick,
        color = if (selected) tokens.ctaBackground else Color.Transparent,
        shape = RoundedCornerShape(999.dp),
    ) {
        Box(
            modifier = Modifier.padding(horizontal = 18.dp, vertical = 14.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                text = label,
                color = if (selected) tokens.ctaText else colorScheme.onSurfaceVariant,
                style = MaterialTheme.typography.labelLarge,
            )
        }
    }
}

@Composable
private fun InteriorCatalogBottomSheet(
    items: List<CatalogFurnitureItem>,
    selectedFurnitureModel: String?,
    is3dMode: Boolean,
    onFurnitureSelected: (String) -> Unit,
    onClearFurnitureSelection: () -> Unit,
    onToggle3d: (Boolean) -> Unit,
    onRotate: () -> Unit,
    onCancel: () -> Unit,
    onDone: () -> Unit,
) {
    var selectedSection by rememberSaveable { mutableStateOf(EditMapCatalogSection.DEVICE.name) }
    val selectedCatalogSection = EditMapCatalogSection.valueOf(selectedSection)

    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Surface(
                onClick = {},
                color = Color(0xFF252429),
                shape = RoundedCornerShape(22.dp),
            ) {
                Text(
                    text = "Add floors",
                    color = Color.White,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.padding(horizontal = 20.dp, vertical = 14.dp),
                )
            }
            Spacer(modifier = Modifier.weight(1f))
            EditActionCircleButton(
                icon = Icons.AutoMirrored.Rounded.Undo,
                onClick = {},
            )
            EditActionCircleButton(
                icon = Icons.AutoMirrored.Rounded.Redo,
                onClick = {},
            )
            FloatingCircleButton(
                label = if (is3dMode) "3D" else "2D",
                onClick = { onToggle3d(!is3dMode) },
            )
            FloatingIconButton(
                icon = Icons.AutoMirrored.Rounded.RotateRight,
                onClick = onRotate,
            )
        }

        Surface(
            modifier = Modifier.fillMaxWidth(),
            color = Color(0xF025252A),
            shape = RoundedCornerShape(topStart = 30.dp, topEnd = 30.dp),
            border = BorderStroke(1.dp, Color(0xFF30323A)),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 10.dp, bottom = 18.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterHorizontally)
                        .width(40.dp)
                        .height(4.dp)
                        .clip(RoundedCornerShape(999.dp))
                        .background(Color(0xFF5A5D66)),
                )
                CatalogSectionTabs(
                    selectedSection = selectedCatalogSection,
                    onSectionSelected = { selectedSection = it.name },
                )
                if (selectedCatalogSection == EditMapCatalogSection.STRUCTURES ||
                    selectedCatalogSection == EditMapCatalogSection.DECORATIONS
                ) {
                    Text(
                        text = "Coming soon",
                        color = Color(0xFF8C909C),
                        fontSize = 13.sp,
                        modifier = Modifier.padding(horizontal = 20.dp),
                    )
                } else {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(rememberScrollState())
                            .padding(horizontal = 16.dp),
                        horizontalArrangement = Arrangement.spacedBy(18.dp),
                    ) {
                        AllPlacedTrayItem(
                            selected = selectedFurnitureModel.isNullOrEmpty(),
                            onClick = onClearFurnitureSelection,
                        )
                        items.forEach { item ->
                            FurnitureTrayItem(
                                item = item,
                                selected = selectedFurnitureModel == item.modelId,
                                onClick = { onFurnitureSelected(item.modelId) },
                            )
                        }
                    }
                }
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 22.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Cancel",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.clickable(onClick = onCancel),
            )
            Text(
                text = "Done",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.clickable(onClick = onDone),
            )
        }
    }
}

@Composable
private fun CatalogSectionTabs(
    selectedSection: EditMapCatalogSection,
    onSectionSelected: (EditMapCatalogSection) -> Unit,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        EditMapCatalogSection.entries.forEach { section ->
            Surface(
                onClick = { onSectionSelected(section) },
                color = if (section == selectedSection) Color(0xFF676A74) else Color.Transparent,
                shape = RoundedCornerShape(18.dp),
            ) {
                Text(
                    text = section.title,
                    color = if (section == selectedSection) Color.White else Color(0xFF8E919B),
                    fontSize = 16.sp,
                    fontWeight = if (section == selectedSection) FontWeight.SemiBold else FontWeight.Medium,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp),
                )
            }
        }
    }
}

@Composable
private fun AllPlacedTrayItem(
    selected: Boolean,
    onClick: () -> Unit,
) {
    Column(
        modifier = Modifier
            .width(72.dp)
            .clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Surface(
            shape = RoundedCornerShape(22.dp),
            color = if (selected) Color(0xFF2E384C) else Color.Transparent,
            border = BorderStroke(1.dp, if (selected) Color(0xFF6F93FF) else Color(0xFF3A3D46)),
        ) {
            Box(
                modifier = Modifier
                    .size(width = 68.dp, height = 74.dp),
                contentAlignment = Alignment.Center,
            ) {
                Surface(
                    color = Color(0xFF202228),
                    shape = CircleShape,
                    border = BorderStroke(1.dp, Color(0xFF50535D)),
                ) {
                    Box(
                        modifier = Modifier.size(34.dp),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = "✓",
                            color = Color(0xFF9FA4B1),
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                        )
                    }
                }
            }
        }
        Text(
            text = "All placed",
            color = if (selected) Color.White else Color(0xFF9A9DA7),
            fontSize = 12.sp,
            textAlign = TextAlign.Center,
        )
    }
}

@Composable
private fun FurnitureTrayItem(
    item: CatalogFurnitureItem,
    selected: Boolean,
    onClick: () -> Unit,
) {
    Column(
        modifier = Modifier
            .width(88.dp)
            .clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Surface(
            shape = RoundedCornerShape(22.dp),
            color = if (selected) Color(0xFF2E384C) else Color.Transparent,
            border = BorderStroke(1.dp, if (selected) Color(0xFF6F93FF) else Color.Transparent),
        ) {
            FurnitureTrayThumbnail(
                item = item,
                selected = selected,
            )
        }
        Text(
            text = compactFurnitureLabel(item.label),
            color = if (selected) Color.White else Color(0xFFE4E6EB),
            fontSize = 12.sp,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.Center,
        )
    }
}

@Composable
private fun FurnitureTrayThumbnail(
    item: CatalogFurnitureItem,
    selected: Boolean,
) {
    val previewBitmap = rememberFurniturePreview(item.previewAssetPath)

    Box(
        modifier = Modifier
            .width(88.dp)
            .height(74.dp)
            .clip(RoundedCornerShape(22.dp))
            .background(
                Brush.verticalGradient(
                    listOf(
                        if (selected) Color(0xFF323D54) else Color(0xFF23252B),
                        Color(0xFF17191E),
                    ),
                ),
            ),
    ) {
        if (previewBitmap != null) {
            Image(
                bitmap = previewBitmap,
                contentDescription = item.label,
                contentScale = ContentScale.Fit,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 8.dp, vertical = 8.dp),
            )
        } else {
            Canvas(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 10.dp, vertical = 8.dp),
            ) {
                drawFurnitureShadow()
                when (item.thumbnailKind) {
                    FurnitureThumbnailKind.BED -> drawBedThumbnail(item.accentColor)
                    FurnitureThumbnailKind.CABINET -> drawCabinetThumbnail(item.accentColor)
                    FurnitureThumbnailKind.TABLE -> drawSmallTableThumbnail(item.accentColor)
                    FurnitureThumbnailKind.STEP_STOOL -> drawStepStoolThumbnail(item.accentColor)
                    FurnitureThumbnailKind.CHAIR -> drawChairThumbnail(item.accentColor)
                }
            }
        }
    }
}

@Composable
private fun EditActionCircleButton(
    icon: ImageVector,
    onClick: () -> Unit,
) {
    val colorScheme = MaterialTheme.colorScheme

    Surface(
        onClick = onClick,
        color = colorScheme.surfaceVariant,
        shape = CircleShape,
    ) {
        Box(
            modifier = Modifier.size(48.dp),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = colorScheme.onSurface,
                modifier = Modifier.size(22.dp),
            )
        }
    }
}

@Composable
private fun HeaderRow(
    isCatalogExpanded: Boolean,
    isFloorPlanEditorActive: Boolean,
    isFurnitureEditModeActive: Boolean,
    onToggleCatalog: () -> Unit,
    onToggleFloorPlanEditor: () -> Unit,
    onToggleFurnitureEditMode: () -> Unit,
) {
    var isMenuExpanded by rememberSaveable { mutableStateOf(false) }
    val colorScheme = MaterialTheme.colorScheme

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            imageVector = Icons.Rounded.Home,
            contentDescription = null,
            tint = colorScheme.onBackground,
            modifier = Modifier.size(32.dp),
        )
        Spacer(modifier = Modifier.width(14.dp))
        Text(
            text = "Godot Home",
            color = colorScheme.onBackground,
            style = MaterialTheme.typography.headlineMedium,
        )
        Icon(
            imageVector = Icons.Rounded.KeyboardArrowDown,
            contentDescription = null,
            tint = colorScheme.onBackground,
            modifier = Modifier.size(26.dp),
        )
        Spacer(modifier = Modifier.weight(1f))
        HeaderAction(Icons.Rounded.GridView) {}
        HeaderAction(
            icon = if (isCatalogExpanded) Icons.Rounded.Remove else Icons.Rounded.Add,
            onClick = onToggleCatalog,
        )
        Box {
            HeaderAction(Icons.Rounded.MoreVert) {
                isMenuExpanded = true
            }
            DropdownMenu(
                expanded = isMenuExpanded,
                onDismissRequest = { isMenuExpanded = false },
                modifier = Modifier.background(colorScheme.surfaceVariant),
            ) {
                DropdownMenuItem(
                    text = {
                        Text(
                            text = if (isFloorPlanEditorActive) "Discard Floor Plan Changes" else "Edit Floor Plan",
                            color = colorScheme.onSurface,
                        )
                    },
                    onClick = {
                        isMenuExpanded = false
                        onToggleFloorPlanEditor()
                    },
                )
                DropdownMenuItem(
                    text = {
                        Text(
                            text = if (isFurnitureEditModeActive) {
                                "Done Editing Furniture"
                            } else {
                                "Edit Furniture Location"
                            },
                            color = colorScheme.onSurface,
                        )
                    },
                    onClick = {
                        isMenuExpanded = false
                        onToggleFurnitureEditMode()
                    },
                )
            }
        }
    }
}

@Composable
private fun HeaderAction(icon: ImageVector, onClick: () -> Unit) {
    val colorScheme = MaterialTheme.colorScheme

    IconButton(onClick = onClick) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = colorScheme.onBackground,
            modifier = Modifier.size(27.dp),
        )
    }
}

@Composable
private fun StatusPills(
    lightOnCount: Int,
    lightFocusActive: Boolean,
    temperatureMin: Int,
    temperatureMax: Int,
    airConditionerOnCount: Int,
    airConditionerTotalCount: Int,
    temperatureFocusActive: Boolean,
    airQualityFocusActive: Boolean,
    cameraFocusActive: Boolean,
    energyFocusActive: Boolean,
    airPurifierIcon: ImageBitmap?,
    cameraIcon: ImageBitmap?,
    onToggleLightFocus: () -> Unit,
    onToggleTemperatureFocus: () -> Unit,
    onToggleAirQualityFocus: () -> Unit,
    onToggleCameraFocus: () -> Unit,
    onToggleEnergyFocus: () -> Unit,
) {
    val tokens = LocalSmartThingsTokens.current
    val temperatureValue = when {
        airConditionerOnCount <= 0 -> "AC off"
        temperatureMin > 0 && temperatureMax > 0 && temperatureMin != temperatureMax -> {
            "${temperatureMin}~${temperatureMax}°C"
        }
        temperatureMin > 0 -> "${temperatureMin}°C"
        else -> "AC on"
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Spacer(modifier = Modifier.width(24.dp))
        StatusPill(
            icon = Icons.Rounded.Lightbulb,
            iconTint = tokens.activeIconAmber,
            value = "$lightOnCount on",
            selected = lightFocusActive,
            onClick = onToggleLightFocus,
        )
        StatusPill(
            icon = Icons.Rounded.Thermostat,
            iconTint = tokens.activeIconBlue,
            value = temperatureValue,
            selected = temperatureFocusActive,
            enabled = airConditionerTotalCount > 0 && airConditionerOnCount > 0,
            onClick = onToggleTemperatureFocus,
        )
        StatusPill(
            iconTint = tokens.statusGood,
            iconBitmap = airPurifierIcon,
            value = "3 rooms",
            selected = airQualityFocusActive,
            onClick = onToggleAirQualityFocus,
        )
        StatusPill(
            icon = if (cameraIcon == null) Icons.Rounded.Videocam else null,
            iconBitmap = cameraIcon,
            iconTint = tokens.activeIconBlue,
            value = "1 live",
            selected = cameraFocusActive,
            onClick = onToggleCameraFocus,
        )
        StatusPill(
            icon = Icons.Rounded.Bolt,
            iconTint = tokens.activeIconBlue,
            value = "Energy",
            selected = energyFocusActive,
            onClick = onToggleEnergyFocus,
        )
        Spacer(modifier = Modifier.width(24.dp))
    }
}

@Composable
private fun FloorPlanEditorTopPanel(
    homeSkinOptions: List<HomeSkinOption>,
    selectedHomeSkinId: String,
    onHomeSkinSelected: (String) -> Unit,
) {
    val colorScheme = MaterialTheme.colorScheme

    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(22.dp),
    ) {
        Text(
            text = "Edit skin",
            color = colorScheme.onBackground,
            style = MaterialTheme.typography.headlineMedium,
        )
        Text(
            text = "Give the view of your home the look that you want. After applying the skin, you can select a room and edit it individually.",
            color = colorScheme.onBackground,
            style = MaterialTheme.typography.bodyLarge,
        )
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(18.dp),
        ) {
            homeSkinOptions.forEach { option ->
                HomeSkinPreviewChip(
                    option = option,
                    selected = selectedHomeSkinId == option.id,
                    onClick = { onHomeSkinSelected(option.id) },
                )
            }
        }
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Icon(
                imageVector = Icons.Rounded.KeyboardArrowDown,
                contentDescription = null,
                tint = colorScheme.onSurfaceVariant,
                modifier = Modifier.size(28.dp),
            )
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(colorScheme.outline),
            )
        }
    }
}

@Composable
private fun FloorPlanEditorSheet(
    selection: FloorEditorSelectionState?,
    finishOptions: List<FloorFinishOption>,
    onPreviewFinish: (String) -> Unit,
    onApplyToAll: () -> Unit,
    onApply: () -> Unit,
    onCancel: () -> Unit,
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(18.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Surface(
            modifier = Modifier.fillMaxWidth(0.88f),
            color = Color(0xF04A4A4F),
            shape = RoundedCornerShape(28.dp),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 20.dp),
                verticalArrangement = Arrangement.spacedBy(18.dp),
            ) {
                Text(
                    text = selection?.roomLabel ?: "Select a room",
                    color = Color.White,
                    fontSize = 19.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.align(Alignment.CenterHorizontally),
                )
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .horizontalScroll(rememberScrollState())
                        .padding(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    finishOptions.forEach { option ->
                        FloorFinishCard(
                            option = option,
                            selected = selection?.pendingFinishId == option.id,
                            enabled = selection != null,
                            onClick = { onPreviewFinish(option.id) },
                        )
                    }
                }
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    color = Color(0xFF3E3F44),
                    shape = RoundedCornerShape(bottomStart = 28.dp, bottomEnd = 28.dp),
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable(enabled = selection != null, onClick = onApplyToAll)
                            .padding(horizontal = 24.dp, vertical = 18.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center,
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.GridView,
                            contentDescription = null,
                            tint = if (selection != null) Color.White else Color(0xFF9A9CA4),
                            modifier = Modifier.size(18.dp),
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        Text(
                            text = "Apply to all rooms",
                            color = if (selection != null) Color.White else Color(0xFF9A9CA4),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                        )
                    }
                }
            }
        }
        Canvas(
            modifier = Modifier
                .size(width = 26.dp, height = 14.dp)
                .offset(y = (-10).dp),
        ) {
            val path = Path().apply {
                moveTo(0f, 0f)
                lineTo(size.width / 2f, size.height)
                lineTo(size.width, 0f)
                close()
            }
            drawPath(path = path, color = Color(0xF04A4A4F))
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 28.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Cancel",
                color = Color.White,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.clickable(onClick = onCancel),
            )
            Text(
                text = "Apply",
                color = Color.White,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.clickable(onClick = onApply),
            )
        }
    }
}

@Composable
private fun FloorFinishCard(
    option: FloorFinishOption,
    selected: Boolean,
    enabled: Boolean,
    onClick: () -> Unit,
) {
    val borderColor = when {
        !enabled -> Color(0xFF5A5B62)
        selected -> Color.White
        else -> Color.Transparent
    }

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Surface(
            onClick = onClick,
            enabled = enabled,
            shape = RoundedCornerShape(18.dp),
            color = Color.Transparent,
            border = BorderStroke(if (selected) 2.dp else 1.dp, borderColor),
        ) {
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .padding(4.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(if (enabled) Color(0xFFF4F2EE) else Color(0xFF6A6B73)),
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    drawFloorPattern(option.patternStyle, option.swatchColor, enabled)
                }
            }
        }
        Text(
            text = option.label,
            color = if (enabled) Color.White else Color(0xFF9A9CA4),
            fontSize = 11.sp,
            fontWeight = FontWeight.SemiBold,
        )
    }
}

@Composable
private fun HomeSkinPreviewChip(
    option: HomeSkinOption,
    selected: Boolean,
    onClick: () -> Unit,
) {
    Surface(
        onClick = onClick,
        shape = CircleShape,
        color = if (selected) Color(0xFF3D3E45) else Color(0xFF2B2B30),
        border = BorderStroke(if (selected) 2.dp else 1.dp, if (selected) Color.White else Color(0xFF3A3B43)),
    ) {
        Box(
            modifier = Modifier.size(92.dp),
            contentAlignment = Alignment.Center,
        ) {
            Canvas(
                modifier = Modifier
                    .size(72.dp)
                    .clip(RoundedCornerShape(18.dp)),
            ) {
                drawSkinPreview(option.roomColors)
            }
        }
    }
}

@Composable
private fun StatusPill(
    icon: ImageVector? = null,
    iconTint: Color,
    iconBitmap: ImageBitmap? = null,
    value: String,
    selected: Boolean = false,
    enabled: Boolean = true,
    onClick: (() -> Unit)? = null,
) {
    val colorScheme = MaterialTheme.colorScheme
    val tokens = LocalSmartThingsTokens.current
    val isInteractive = onClick != null && enabled
    val clickAction = onClick ?: {}
    val containerColor = when {
        selected -> tokens.ctaBackground.copy(alpha = 0.75f)
        enabled -> tokens.pillBackground.copy(alpha = 0.55f)
        else -> tokens.sceneChipBackground.copy(alpha = 0.45f)
    }
    val iconBackground = when {
        selected -> colorScheme.primaryContainer
        enabled -> colorScheme.surfaceVariant.copy(alpha = 0.96f)
        else -> colorScheme.surfaceVariant.copy(alpha = 0.72f)
    }
    val textColor = if (enabled) tokens.pillText else colorScheme.onSurfaceVariant

    if (isInteractive) {
        Surface(
            modifier = Modifier.clickable(onClick = clickAction),
            color = containerColor,
            shape = RoundedCornerShape(26.dp),
        ) {
            StatusPillContent(
                icon = icon,
                iconTint = iconTint,
                iconBitmap = iconBitmap,
                iconBackground = iconBackground,
                value = value,
                textColor = textColor,
            )
        }
    } else {
        Surface(
            color = containerColor,
            shape = RoundedCornerShape(26.dp),
        ) {
            StatusPillContent(
                icon = icon,
                iconTint = iconTint,
                iconBitmap = iconBitmap,
                iconBackground = iconBackground,
                value = value,
                textColor = textColor,
            )
        }
    }
}

@Composable
private fun StatusPillContent(
    icon: ImageVector?,
    iconTint: Color,
    iconBitmap: ImageBitmap?,
    iconBackground: Color,
    value: String,
    textColor: Color,
) {
    Row(
        modifier = Modifier.padding(horizontal = 20.dp, vertical = 15.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Box(
            modifier = Modifier
                .size(30.dp)
                .clip(CircleShape)
                .background(iconBackground),
            contentAlignment = Alignment.Center,
        ) {
            if (iconBitmap != null) {
                Image(
                    bitmap = iconBitmap,
                    contentDescription = null,
                    modifier = Modifier.size(19.dp),
                    colorFilter = ColorFilter.tint(iconTint),
                )
            } else if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = iconTint,
                    modifier = Modifier.size(19.dp),
                )
            }
        }
        Text(
            text = value,
            style = MaterialTheme.typography.titleMedium,
            color = textColor,
        )
    }
}

@Composable
private fun EnergySummaryCard(summary: EnergySummaryState) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 14.dp),
        color = Color(0xFF17181C).copy(alpha = 0.94f),
        shape = RoundedCornerShape(24.dp),
        border = BorderStroke(1.dp, Color(0xFF2A2B30)),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Box(
                modifier = Modifier.size(58.dp),
                contentAlignment = Alignment.Center,
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val stroke = 7.dp.toPx()
                    drawArc(
                        color = Color(0xFF2E3036),
                        startAngle = 0f,
                        sweepAngle = 360f,
                        useCenter = false,
                        topLeft = Offset(stroke / 2, stroke / 2),
                        size = Size(size.width - stroke, size.height - stroke),
                        style = androidx.compose.ui.graphics.drawscope.Stroke(width = stroke),
                    )
                    val sweep = (summary.savingRatePercent.coerceIn(0.0, 100.0) / 100.0 * 360.0).toFloat()
                    drawArc(
                        color = Color(0xFF4DA7FF),
                        startAngle = -90f,
                        sweepAngle = sweep,
                        useCenter = false,
                        topLeft = Offset(stroke / 2, stroke / 2),
                        size = Size(size.width - stroke, size.height - stroke),
                        style = androidx.compose.ui.graphics.drawscope.Stroke(
                            width = stroke,
                            cap = androidx.compose.ui.graphics.StrokeCap.Round,
                        ),
                    )
                }
            }
            Column(
                verticalArrangement = Arrangement.spacedBy(1.dp),
            ) {
                Text(
                    text = "Saving",
                    color = Color(0xFFBBBBBB),
                    fontSize = 11.sp,
                    maxLines = 1,
                )
                Text(
                    text = "%.1f%%".format(summary.savingRatePercent),
                    color = Color.White,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                )
            }
            EnergyMetric(
                iconTint = Color(0xFF4DA7FF),
                label = "Usage",
                primary = "%.2f kWh".format(summary.usageKwh),
                secondary = "$%.2f".format(summary.usageCost),
                icon = Icons.Rounded.Bolt,
            )
            EnergyMetric(
                iconTint = Color(0xFF7CE0B5),
                label = "Savings",
                primary = "%.2f kWh".format(summary.savingsKwh),
                secondary = "$%.2f".format(summary.savingsCost),
                icon = Icons.Rounded.Bolt,
            )
        }
    }
}

@Composable
private fun EnergyMetric(
    iconTint: Color,
    label: String,
    primary: String,
    secondary: String,
    icon: ImageVector,
) {
    Column(verticalArrangement = Arrangement.spacedBy(1.dp)) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(3.dp),
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconTint,
                modifier = Modifier.size(13.dp),
            )
            Text(
                text = label,
                color = iconTint,
                fontSize = 11.sp,
                maxLines = 1,
            )
        }
        Text(
            text = primary,
            color = Color.White,
            fontSize = 15.sp,
            fontWeight = FontWeight.SemiBold,
            maxLines = 1,
        )
        Text(
            text = secondary,
            color = Color(0xFFBBBBBB),
            fontSize = 11.sp,
            maxLines = 1,
        )
    }
}

@Composable
private fun DeviceControlDialog(
    activeDialog: DeviceControlDialogState?,
    onDismiss: () -> Unit,
    onDeviceCommand: (String, Boolean) -> Unit,
) {
    val dialog = activeDialog ?: return
    val colorScheme = MaterialTheme.colorScheme
    val isAirConditioner = dialog.deviceKind == DEVICE_KIND_AIR_CONDITIONER
    val isAirPurifier = dialog.deviceKind == DEVICE_KIND_AIR_PURIFIER
    val statusText = when {
        isAirConditioner && dialog.isOn -> "AC is currently on."
        isAirConditioner -> "AC is currently off."
        isAirPurifier -> "Air quality is shown on the floor plan."
        dialog.isOn -> "Light is currently on."
        else -> "Light is currently off."
    }
    val detailText = if (isAirConditioner && dialog.temperatureC > 0) {
        "Set to ${dialog.temperatureC}°C."
    } else {
        null
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = colorScheme.surfaceVariant,
        title = {
            Text(
                text = dialog.roomLabel,
                color = colorScheme.onSurface,
                fontSize = 26.sp,
                fontWeight = FontWeight.Bold,
            )
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text(
                    text = dialog.deviceName,
                    color = colorScheme.onSurface,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.SemiBold,
                )
                Text(
                    text = statusText,
                    color = colorScheme.onSurfaceVariant,
                    fontSize = 18.sp,
                )
                detailText?.let {
                    Text(
                        text = it,
                        color = colorScheme.secondary,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Medium,
                    )
                }
            }
        },
        confirmButton = {
            if (!isAirPurifier) {
                Button(onClick = { onDeviceCommand(dialog.deviceId, true) }) {
                    Text(text = "Turn On", fontSize = 17.sp)
                }
            }
        },
        dismissButton = {
            if (isAirPurifier) {
                OutlinedButton(onClick = onDismiss) {
                    Text(text = "Close", fontSize = 17.sp)
                }
            } else {
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    OutlinedButton(onClick = { onDeviceCommand(dialog.deviceId, false) }) {
                        Text(text = "Turn Off", fontSize = 17.sp)
                    }
                    OutlinedButton(onClick = onDismiss) {
                        Text(text = "Close", fontSize = 17.sp)
                    }
                }
            }
        },
    )
}

@Composable
private fun FloatingCircleButton(
    label: String,
    onClick: () -> Unit,
) {
    val colorScheme = MaterialTheme.colorScheme

    Surface(
        onClick = onClick,
        color = colorScheme.surfaceVariant,
        shape = CircleShape,
    ) {
        Box(
            modifier = Modifier.size(54.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                text = label,
                color = colorScheme.onSurface,
                style = MaterialTheme.typography.labelLarge,
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun FloatingIconButton(
    icon: ImageVector,
    onClick: () -> Unit,
) {
    val colorScheme = MaterialTheme.colorScheme

    Surface(
        onClick = onClick,
        color = colorScheme.surfaceVariant,
        shape = CircleShape,
    ) {
        Box(
            modifier = Modifier.size(54.dp),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = colorScheme.onSurface,
                modifier = Modifier.size(24.dp),
            )
        }
    }
}

@Composable
private fun BottomNavigationBar(modifier: Modifier = Modifier) {
    val tokens = LocalSmartThingsTokens.current
    val items = listOf(
        NavItem("Home", Icons.Rounded.Home, true, false),
        NavItem("Devices", Icons.Rounded.GridView, false, true),
        NavItem("Life", Icons.Rounded.ViewInAr, false, true),
        NavItem("Routines", Icons.Rounded.PlayCircleOutline, false, false),
        NavItem("Menu", Icons.Rounded.Menu, false, true),
    )

    Surface(
        modifier = modifier.fillMaxWidth(),
        color = Color.Transparent,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            items.forEach { item ->
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Box(contentAlignment = Alignment.TopEnd) {
                        Icon(
                            imageVector = item.icon,
                            contentDescription = null,
                            tint = if (item.selected) tokens.navActiveText else tokens.navInactiveText,
                            modifier = Modifier.size(28.dp),
                        )
                        if (item.hasBadge) {
                            Box(
                                modifier = Modifier
                                    .size(7.dp)
                                    .clip(CircleShape)
                                    .background(tokens.activeIconAmber)
                                    .align(Alignment.TopEnd),
                            )
                        }
                    }
                    Text(
                        text = item.label,
                        color = if (item.selected) tokens.navActiveText else tokens.navInactiveText,
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = if (item.selected) FontWeight.SemiBold else FontWeight.Medium,
                        ),
                    )
                }
            }
        }
    }
}

@Composable
private fun FurnitureCatalogPeekBar(
    selectedFurnitureModel: String?,
    onExpandCatalog: () -> Unit,
) {
    val colorScheme = MaterialTheme.colorScheme
    val tokens = LocalSmartThingsTokens.current
    val selectedLabel = catalogFurnitureItems().firstOrNull {
        it.modelId == selectedFurnitureModel
    }?.label

    Surface(
        color = colorScheme.surfaceVariant.copy(alpha = 0.94f),
        shape = RoundedCornerShape(30.dp),
        border = BorderStroke(1.dp, colorScheme.outline),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(
                    text = "Furniture",
                    color = colorScheme.onSurface,
                    style = MaterialTheme.typography.titleMedium,
                )
                Text(
                    text = if (selectedLabel.isNullOrEmpty()) {
                        "Tap + to open furniture catalog."
                    } else {
                        "Placing $selectedLabel. Drag it on the floor."
                    },
                    color = colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.labelSmall,
                )
            }
            Spacer(modifier = Modifier.weight(1f))
            Surface(
                onClick = onExpandCatalog,
                color = tokens.ctaBackground,
                shape = RoundedCornerShape(18.dp),
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 9.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Icon(
                        imageVector = Icons.Rounded.Add,
                        contentDescription = null,
                        tint = tokens.ctaText,
                        modifier = Modifier.size(16.dp),
                    )
                    Text(
                        text = "Add",
                        color = tokens.ctaText,
                        style = MaterialTheme.typography.labelLarge,
                    )
                }
            }
        }
    }
}

@Composable
private fun FurnitureCatalogDrawer(
    items: List<CatalogFurnitureItem>,
    selectedFurnitureModel: String?,
    onFurnitureSelected: (String) -> Unit,
    onClose: () -> Unit,
) {
    val scrollState = rememberScrollState()

    Dialog(
        onDismissRequest = onClose,
        properties = DialogProperties(
            dismissOnBackPress = true,
            dismissOnClickOutside = true,
            usePlatformDefaultWidth = false,
            decorFitsSystemWindows = false,
        ),
        ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0x22000000))
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onClose,
                ),
            contentAlignment = Alignment.BottomCenter,
        ) {
            Surface(
                modifier = Modifier
                    .heightIn(min = 172.dp, max = 258.dp)
                    .fillMaxWidth()
                    .padding(horizontal = 10.dp, vertical = 10.dp)
                    .navigationBarsPadding()
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = {},
                    ),
                color = Color(0xF01B1B1F),
                shape = RoundedCornerShape(30.dp),
                border = BorderStroke(1.dp, Color(0xFF31333B)),
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 18.dp, vertical = 16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.CenterHorizontally)
                            .width(44.dp)
                            .height(5.dp)
                            .clip(RoundedCornerShape(999.dp))
                            .background(Color(0xFF4B4D55)),
                    )
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(
                                text = "Furniture",
                                color = Color.White,
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold,
                            )
                            Text(
                                text = "Pick a piece, then drag it onto the floor plan.",
                                color = Color(0xFFB7B8C0),
                                fontSize = 12.sp,
                            )
                        }
                        Spacer(modifier = Modifier.weight(1f))
                        Surface(
                            onClick = onClose,
                            color = Color(0xFF2A2A2E),
                            shape = RoundedCornerShape(18.dp),
                        ) {
                            Text(
                                text = "Done",
                                color = Color.White,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.SemiBold,
                                modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                            )
                        }
                    }

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(scrollState),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                    ) {
                        items.forEach { item ->
                            FurnitureCatalogCard(
                                item = item,
                                selected = selectedFurnitureModel == item.modelId,
                                onClick = { onFurnitureSelected(item.modelId) },
                                compact = true,
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun FurnitureCatalogCard(
    item: CatalogFurnitureItem,
    selected: Boolean,
    onClick: () -> Unit,
    compact: Boolean,
) {
    val cardWidth = if (compact) 112.dp else 142.dp
    val cardPadding = if (compact) 9.dp else 14.dp
    val cardShape = RoundedCornerShape(if (compact) 20.dp else 24.dp)
    val backgroundColor = if (selected) Color(0xFF223B73) else Color(0xFF202228)
    val borderColor = if (selected) Color(0xFF77A0FF) else Color(0xFF343741)

    Surface(
        onClick = onClick,
        shape = cardShape,
        color = backgroundColor,
        border = BorderStroke(1.dp, borderColor),
    ) {
        Column(
            modifier = Modifier
                .width(cardWidth)
                .padding(horizontal = cardPadding, vertical = cardPadding),
            verticalArrangement = Arrangement.spacedBy(if (compact) 8.dp else 10.dp),
        ) {
            FurnitureModelThumbnail(
                item = item,
                compact = compact,
            )
            Text(
                text = item.label,
                color = Color.White,
                fontSize = if (compact) 12.sp else 14.sp,
                fontWeight = FontWeight.SemiBold,
                maxLines = if (compact) 2 else 3,
                overflow = TextOverflow.Ellipsis,
            )
            if (compact) {
                Text(
                    text = item.sourceLabel,
                    color = if (selected) Color(0xFFD9E4FF) else Color(0xFF9DA3AF),
                    fontSize = 9.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            } else {
                Text(
                    text = item.assetFileName,
                    color = Color(0xFFB7B8C0),
                    fontSize = 11.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
            Text(
                text = if (selected) "Placing" else "Tap to place",
                color = if (selected) Color.White else Color(0xFFB7B8C0),
                fontSize = if (compact) 10.sp else 11.sp,
            )
        }
    }
}

@Composable
private fun FurnitureModelThumbnail(
    item: CatalogFurnitureItem,
    compact: Boolean,
) {
    val previewBitmap = rememberFurniturePreview(item.previewAssetPath)
    val thumbnailHeight = if (compact) 74.dp else 94.dp
    val cornerRadius = if (compact) 16.dp else 22.dp
    val backgroundBrush = Brush.linearGradient(
        listOf(
            if (compact) Color(0xFF2B2E36) else Color(0xFF23252B),
            Color(0xFF17191E),
        ),
        start = Offset.Zero,
        end = Offset.Infinite,
    )

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(thumbnailHeight)
            .clip(RoundedCornerShape(cornerRadius))
            .background(backgroundBrush),
    ) {
        if (previewBitmap != null) {
            Image(
                bitmap = previewBitmap,
                contentDescription = item.label,
                contentScale = ContentScale.Fit,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = if (compact) 6.dp else 10.dp, vertical = if (compact) 6.dp else 10.dp),
            )
        } else {
            Canvas(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(if (compact) 8.dp else 10.dp),
            ) {
                drawFurnitureShadow()
                when (item.thumbnailKind) {
                    FurnitureThumbnailKind.BED -> drawBedThumbnail(item.accentColor)
                    FurnitureThumbnailKind.CABINET -> drawCabinetThumbnail(item.accentColor)
                    FurnitureThumbnailKind.TABLE -> drawSmallTableThumbnail(item.accentColor)
                    FurnitureThumbnailKind.STEP_STOOL -> drawStepStoolThumbnail(item.accentColor)
                    FurnitureThumbnailKind.CHAIR -> drawChairThumbnail(item.accentColor)
                }
            }
        }
    }
}

private data class NavItem(
    val label: String,
    val icon: ImageVector,
    val selected: Boolean,
    val hasBadge: Boolean,
)

private data class CatalogFurnitureItem(
    val modelId: String,
    val label: String,
    val assetFileName: String,
    val sourceLabel: String,
    val accentColor: Color,
    val thumbnailKind: FurnitureThumbnailKind,
    val previewAssetPath: String? = null,
)

private enum class FurnitureThumbnailKind {
    BED,
    CABINET,
    TABLE,
    STEP_STOOL,
    CHAIR,
}

private data class HomeSkinOption(
    val id: String,
    val label: String,
    val roomColors: List<Color>,
)

private data class FloorFinishOption(
    val id: String,
    val label: String,
    val swatchColor: Color,
    val patternStyle: PatternStyle,
)

private data class FloorEditorSelectionState(
    val roomId: String,
    val roomLabel: String,
    val committedFinishId: String,
    val pendingFinishId: String,
)

private data class DeviceControlDialogState(
    val deviceId: String,
    val roomLabel: String,
    val deviceName: String,
    val deviceKind: String,
    val isOn: Boolean,
    val temperatureC: Int,
)

private data class EnergySummaryState(
    val savingRatePercent: Double,
    val usageKwh: Double,
    val usageCost: Double,
    val savingsKwh: Double,
    val savingsCost: Double,
)

private enum class PatternStyle {
    WOOD,
    HERRINGBONE,
    RECTANGLE,
    ZIGZAG,
    GRID,
    MARBLE,
    PEBBLE,
}

private var catalogFurnitureItemsCache: List<CatalogFurnitureItem> = defaultCatalogFurnitureItems()

private fun catalogFurnitureItems(): List<CatalogFurnitureItem> = catalogFurnitureItemsCache

private fun defaultCatalogFurnitureItems(): List<CatalogFurnitureItem> = defaultLegacyCatalogFurnitureItems()

private fun defaultLegacyCatalogFurnitureItems(): List<CatalogFurnitureItem> {
    return listOf(
        CatalogFurnitureItem(
            modelId = "cabinet",
            label = "Cabinet",
            assetFileName = "cabinet.glb",
            sourceLabel = "Built-in",
            accentColor = accentColorFor(FurnitureThumbnailKind.CABINET),
            thumbnailKind = FurnitureThumbnailKind.CABINET,
            previewAssetPath = "GLB/cabinet_0.png",
        ),
        CatalogFurnitureItem(
            modelId = "small_table",
            label = "Table",
            assetFileName = "small_table.glb",
            sourceLabel = "Built-in",
            accentColor = accentColorFor(FurnitureThumbnailKind.TABLE),
            thumbnailKind = FurnitureThumbnailKind.TABLE,
            previewAssetPath = "GLB/small_table_0.png",
        ),
        CatalogFurnitureItem(
            modelId = "step_stool",
            label = "Step Stool",
            assetFileName = "step_stool.glb",
            sourceLabel = "Built-in",
            accentColor = accentColorFor(FurnitureThumbnailKind.STEP_STOOL),
            thumbnailKind = FurnitureThumbnailKind.STEP_STOOL,
            previewAssetPath = "GLB/step_stool_0.png",
        ),
    )
}

private fun compactFurnitureLabel(label: String): String {
    return label
        .split(' ')
        .filter { it.isNotBlank() }
        .take(2)
        .joinToString(" ")
}

private fun furnitureCatalogLabel(productName: String, modelId: String): String {
    val trimmed = productName.substringBefore(" - ").trim()
    if (trimmed.isNotEmpty()) {
        return trimmed
    }
    return modelId
        .split('-')
        .joinToString(" ") { token ->
            token.replaceFirstChar { char ->
                if (char.isLowerCase()) {
                    char.titlecase(Locale.ROOT)
                } else {
                    char.toString()
                }
            }
        }
}

private fun furnitureCatalogAssetLabel(outputFile: String, articleNumber: String): String {
    if (articleNumber.isNotEmpty()) {
        return "ikea-$articleNumber.glb"
    }
    val fileName = outputFile.substringAfterLast('/')
    return if (fileName.length <= 24) fileName else "${fileName.take(21)}..."
}

private fun furnitureCatalogSourceLabel(articleNumber: String): String {
    return if (articleNumber.isNotEmpty()) {
        "IKEA $articleNumber"
    } else {
        "IKEA"
    }
}

private fun furniturePreviewAssetPathFor(
    modelId: String,
    ikeaAssetNames: Set<String>,
    articleNumber: String,
): String? {
    val preferredNames = buildList {
        if (articleNumber.isNotEmpty()) {
            add("${modelId}_${articleNumber}_PS01_S01_NV01_RQP3_3.jpg")
            add("${modelId}_${articleNumber}_PS01_S01_NV01_RQP3_3_1.jpg")
            add("${modelId}_${articleNumber}_PS01_S01_NV01_RQP3_3_2.png")
            add("${modelId}_${articleNumber}_PS01_S01_NV01_RQP3_3_3.png")
            add("${modelId}_${articleNumber}_PS01_S01_NV01_RQP3_3_4.png")
        }
        add("${modelId}_Image_0.webp")
        add("${modelId}_Image_1.webp")
        add("${modelId}_Image_2.webp")
        add("${modelId}_Image_3.webp")
    }
    preferredNames.firstOrNull { candidate -> candidate in ikeaAssetNames }?.let { return "GLB/ikea/$it" }
    return null
}

@Composable
private fun rememberFurniturePreview(assetPath: String?): ImageBitmap? {
    return rememberAssetBitmap(assetPath, maxDimension = 640)
}

@Composable
private fun rememberAssetBitmap(
    assetPath: String?,
    maxDimension: Int = 256,
): ImageBitmap? {
    val assetManager = LocalContext.current.assets
    val previewBitmap by produceState<ImageBitmap?>(initialValue = null, assetPath, maxDimension) {
        value = if (assetPath.isNullOrBlank()) {
            null
        } else {
            withContext(Dispatchers.IO) {
                loadAssetBitmap(assetManager, assetPath, maxDimension)
            }
        }
    }
    return previewBitmap
}

private fun loadAssetBitmap(
    assetManager: AssetManager,
    assetPath: String,
    maxDimension: Int,
): ImageBitmap? {
    val bounds = BitmapFactory.Options().apply {
        inJustDecodeBounds = true
    }
    assetManager.open(assetPath).use { input ->
        BitmapFactory.decodeStream(input, null, bounds)
    }
    if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
        return null
    }

    val decodeOptions = BitmapFactory.Options().apply {
        inSampleSize = calculateInSampleSize(bounds.outWidth, bounds.outHeight, maxDimension)
    }
    return runCatching {
        assetManager.open(assetPath).use { input ->
            BitmapFactory.decodeStream(input, null, decodeOptions)?.asImageBitmap()
        }
    }.getOrNull()
}

private fun calculateInSampleSize(
    width: Int,
    height: Int,
    maxDimension: Int,
): Int {
    var sampleSize = 1
    var sampledWidth = width
    var sampledHeight = height
    while (sampledWidth > maxDimension || sampledHeight > maxDimension) {
        sampleSize *= 2
        sampledWidth /= 2
        sampledHeight /= 2
    }
    return sampleSize
}

private fun furniturePreviewScore(assetPath: String?): Int {
    return when {
        assetPath.isNullOrBlank() -> 0
        "_PS01_" in assetPath || "_Image_" in assetPath -> 2
        else -> 1
    }
}

private fun furnitureThumbnailKindFor(modelId: String, productName: String): FurnitureThumbnailKind {
    val lowered = "$modelId $productName".lowercase(Locale.ROOT)
    return when {
        "bed" in lowered || "divan" in lowered -> FurnitureThumbnailKind.BED
        "wardrobe" in lowered || "cabinet" in lowered || "closet" in lowered -> FurnitureThumbnailKind.CABINET
        "table" in lowered || "desk" in lowered -> FurnitureThumbnailKind.TABLE
        "step-stool" in lowered || ("step" in lowered && "stool" in lowered) -> FurnitureThumbnailKind.STEP_STOOL
        else -> FurnitureThumbnailKind.CHAIR
    }
}

private fun accentColorFor(kind: FurnitureThumbnailKind): Color {
    return when (kind) {
        FurnitureThumbnailKind.BED -> Color(0xFFCFA8A0)
        FurnitureThumbnailKind.CABINET -> Color(0xFFE2B36C)
        FurnitureThumbnailKind.TABLE -> Color(0xFFD7C2A0)
        FurnitureThumbnailKind.STEP_STOOL -> Color(0xFFFFC96B)
        FurnitureThumbnailKind.CHAIR -> Color(0xFFD8DCE6)
    }
}

private fun DrawScope.drawSkinPreview(roomColors: List<Color>) {
    drawRoundRect(
        color = Color(0xFFF7F4EE),
        cornerRadius = CornerRadius(size.minDimension * 0.16f),
    )
    val wall = Color(0xFFE2DDD4)
    val inset = size.width * 0.08f
    drawRoundRect(
        color = wall,
        topLeft = Offset(inset, inset),
        size = Size(size.width - inset * 2f, size.height - inset * 2f),
        cornerRadius = CornerRadius(size.minDimension * 0.12f),
    )

    val roomA = roomColors.getOrElse(0) { Color(0xFFE4D3BD) }
    val roomB = roomColors.getOrElse(1) { Color(0xFFD2C2AE) }
    val roomC = roomColors.getOrElse(2) { Color(0xFFEAE4D8) }
    val roomD = roomColors.getOrElse(3) { Color(0xFFC4B49D) }
    val inner = inset * 1.45f

    drawRect(color = roomA, topLeft = Offset(inner, inner), size = Size(size.width * 0.34f, size.height * 0.26f))
    drawRect(color = roomB, topLeft = Offset(size.width * 0.48f, inner), size = Size(size.width * 0.24f, size.height * 0.22f))
    drawRect(color = roomC, topLeft = Offset(inner, size.height * 0.45f), size = Size(size.width * 0.28f, size.height * 0.24f))
    drawRect(color = roomD, topLeft = Offset(size.width * 0.42f, size.height * 0.42f), size = Size(size.width * 0.34f, size.height * 0.3f))

    val stroke = size.minDimension * 0.035f
    drawLine(color = wall, start = Offset(size.width * 0.42f, inner), end = Offset(size.width * 0.42f, size.height * 0.78f), strokeWidth = stroke)
    drawLine(color = wall, start = Offset(inner, size.height * 0.41f), end = Offset(size.width * 0.76f, size.height * 0.41f), strokeWidth = stroke)
    drawLine(color = wall, start = Offset(size.width * 0.54f, inner), end = Offset(size.width * 0.74f, size.height * 0.22f), strokeWidth = stroke)
}

private fun DrawScope.drawFloorPattern(patternStyle: PatternStyle, baseColor: Color, enabled: Boolean) {
    val fill = if (enabled) baseColor else baseColor.copy(alpha = 0.55f)
    val line = fill.copy(alpha = 0.72f).blendWith(Color(0xFF66666C), 0.28f)
    drawRoundRect(
        color = fill,
        cornerRadius = CornerRadius(size.minDimension * 0.18f),
    )

    when (patternStyle) {
        PatternStyle.WOOD -> {
            val step = size.width / 4f
            for (index in 1..3) {
                val x = step * index
                drawLine(color = line, start = Offset(x, 0f), end = Offset(x, size.height), strokeWidth = 2.5f)
            }
            drawLine(color = line, start = Offset(0f, size.height * 0.35f), end = Offset(size.width, size.height * 0.35f), strokeWidth = 2f)
            drawLine(color = line, start = Offset(0f, size.height * 0.72f), end = Offset(size.width, size.height * 0.72f), strokeWidth = 2f)
        }
        PatternStyle.HERRINGBONE -> {
            val span = size.width / 3.2f
            var start = -size.width
            while (start < size.width * 1.4f) {
                drawLine(color = line, start = Offset(start, size.height), end = Offset(start + span, 0f), strokeWidth = 2.4f)
                drawLine(color = line, start = Offset(start + span * 0.55f, 0f), end = Offset(start + span * 1.55f, size.height), strokeWidth = 2.4f)
                start += span * 0.82f
            }
        }
        PatternStyle.RECTANGLE -> {
            val tileW = size.width / 2.4f
            val tileH = size.height / 3f
            for (row in 0..2) {
                val y = row * tileH
                val offset = if (row % 2 == 0) 0f else tileW / 2f
                drawLine(color = line, start = Offset(0f, y), end = Offset(size.width, y), strokeWidth = 2.2f)
                var x = -tileW
                while (x < size.width + tileW) {
                    drawLine(color = line, start = Offset(x + offset, y), end = Offset(x + offset, y + tileH), strokeWidth = 2.2f)
                    x += tileW
                }
            }
        }
        PatternStyle.ZIGZAG -> {
            val step = size.width / 4f
            var x = -step
            while (x < size.width + step) {
                drawLine(color = line, start = Offset(x, size.height), end = Offset(x + step, 0f), strokeWidth = 2.4f)
                drawLine(color = line, start = Offset(x + step, 0f), end = Offset(x + step * 2f, size.height), strokeWidth = 2.4f)
                x += step * 1.35f
            }
        }
        PatternStyle.GRID -> {
            val cell = size.width / 3f
            for (index in 1..2) {
                val x = cell * index
                val y = cell * index
                drawLine(color = line, start = Offset(x, 0f), end = Offset(x, size.height), strokeWidth = 2.2f)
                drawLine(color = line, start = Offset(0f, y), end = Offset(size.width, y), strokeWidth = 2.2f)
            }
        }
        PatternStyle.MARBLE -> {
            drawLine(color = line.copy(alpha = 0.45f), start = Offset(size.width * 0.12f, size.height * 0.22f), end = Offset(size.width * 0.78f, size.height * 0.48f), strokeWidth = 3f)
            drawLine(color = line.copy(alpha = 0.38f), start = Offset(size.width * 0.28f, size.height * 0.08f), end = Offset(size.width * 0.64f, size.height * 0.84f), strokeWidth = 2.4f)
            drawLine(color = line.copy(alpha = 0.32f), start = Offset(size.width * 0.08f, size.height * 0.68f), end = Offset(size.width * 0.88f, size.height * 0.32f), strokeWidth = 2f)
        }
        PatternStyle.PEBBLE -> {
            val radius = size.width * 0.08f
            for (row in 0..2) {
                for (column in 0..2) {
                    drawCircle(
                        color = line.copy(alpha = 0.34f),
                        radius = radius,
                        center = Offset(size.width * (0.22f + column * 0.28f), size.height * (0.22f + row * 0.28f)),
                    )
                }
            }
        }
    }
}

private fun DrawScope.drawFurnitureShadow() {
    drawOval(
        color = Color.Black.copy(alpha = 0.18f),
        topLeft = Offset(size.width * 0.18f, size.height * 0.78f),
        size = Size(size.width * 0.64f, size.height * 0.12f),
    )
}

private fun DrawScope.drawCabinetThumbnail(accent: Color) {
    val frontLeft = Offset(size.width * 0.2f, size.height * 0.28f)
    val frontSize = Size(size.width * 0.44f, size.height * 0.4f)
    val depth = Offset(size.width * 0.16f, -size.height * 0.1f)
    val sideColor = accent.blendWith(Color(0xFF5F3F1E), 0.34f)
    val topColor = accent.blendWith(Color.White, 0.22f)
    val bodyColor = accent.blendWith(Color(0xFF8E6331), 0.18f)

    drawPath(
        path = Path().apply {
            moveTo(frontLeft.x, frontLeft.y)
            lineTo(frontLeft.x + depth.x, frontLeft.y + depth.y)
            lineTo(frontLeft.x + frontSize.width + depth.x, frontLeft.y + depth.y)
            lineTo(frontLeft.x + frontSize.width, frontLeft.y)
            close()
        },
        color = topColor,
    )
    drawPath(
        path = Path().apply {
            moveTo(frontLeft.x + frontSize.width, frontLeft.y)
            lineTo(frontLeft.x + frontSize.width + depth.x, frontLeft.y + depth.y)
            lineTo(frontLeft.x + frontSize.width + depth.x, frontLeft.y + frontSize.height + depth.y)
            lineTo(frontLeft.x + frontSize.width, frontLeft.y + frontSize.height)
            close()
        },
        color = sideColor,
    )
    drawRoundRect(
        color = bodyColor,
        topLeft = frontLeft,
        size = frontSize,
        cornerRadius = CornerRadius(size.minDimension * 0.05f),
    )

    val drawerHeight = frontSize.height * 0.42f
    repeat(2) { index ->
        val top = frontLeft.y + size.height * 0.03f + index * (drawerHeight + size.height * 0.025f)
        drawRoundRect(
            color = bodyColor.blendWith(Color.White, 0.08f),
            topLeft = Offset(frontLeft.x + frontSize.width * 0.08f, top),
            size = Size(frontSize.width * 0.84f, drawerHeight),
            cornerRadius = CornerRadius(size.minDimension * 0.04f),
        )
        drawRoundRect(
            color = Color(0xFF5E452B),
            topLeft = Offset(frontLeft.x + frontSize.width * 0.43f, top + drawerHeight * 0.42f),
            size = Size(frontSize.width * 0.14f, drawerHeight * 0.08f),
            cornerRadius = CornerRadius(drawerHeight * 0.04f),
        )
    }
}

private fun DrawScope.drawSmallTableThumbnail(accent: Color) {
    val topLeft = Offset(size.width * 0.22f, size.height * 0.3f)
    val topWidth = size.width * 0.38f
    val topDepth = size.height * 0.12f
    val depth = Offset(size.width * 0.18f, -size.height * 0.1f)
    val topColor = accent.blendWith(Color.White, 0.24f)
    val sideColor = accent.blendWith(Color(0xFF72573C), 0.3f)
    val legColor = Color(0xFFB98B4D)

    drawPath(
        path = Path().apply {
            moveTo(topLeft.x, topLeft.y)
            lineTo(topLeft.x + depth.x, topLeft.y + depth.y)
            lineTo(topLeft.x + topWidth + depth.x, topLeft.y + depth.y)
            lineTo(topLeft.x + topWidth, topLeft.y)
            close()
        },
        color = topColor,
    )
    drawPath(
        path = Path().apply {
            moveTo(topLeft.x + topWidth, topLeft.y)
            lineTo(topLeft.x + topWidth + depth.x, topLeft.y + depth.y)
            lineTo(topLeft.x + topWidth + depth.x, topLeft.y + topDepth + depth.y)
            lineTo(topLeft.x + topWidth, topLeft.y + topDepth)
            close()
        },
        color = sideColor,
    )
    drawRoundRect(
        color = accent,
        topLeft = topLeft,
        size = Size(topWidth, topDepth),
        cornerRadius = CornerRadius(size.minDimension * 0.04f),
    )

    val legTop = topLeft.y + topDepth * 0.9f
    val legBottom = size.height * 0.76f
    val legWidth = size.width * 0.035f
    val xPositions = listOf(
        topLeft.x + topWidth * 0.1f,
        topLeft.x + topWidth * 0.78f,
        topLeft.x + depth.x + topWidth * 0.08f,
        topLeft.x + depth.x + topWidth * 0.76f,
    )
    xPositions.forEachIndexed { index, x ->
        val offsetY = if (index < 2) 0f else -size.height * 0.07f
        drawRoundRect(
            color = legColor,
            topLeft = Offset(x, legTop + offsetY),
            size = Size(legWidth, legBottom - (legTop + offsetY)),
            cornerRadius = CornerRadius(legWidth * 0.5f),
        )
    }
}

private fun DrawScope.drawBedThumbnail(accent: Color) {
    val mattressTop = Offset(size.width * 0.18f, size.height * 0.34f)
    val mattressSize = Size(size.width * 0.5f, size.height * 0.22f)
    val depth = Offset(size.width * 0.16f, -size.height * 0.09f)
    val topColor = accent.blendWith(Color.White, 0.3f)
    val sideColor = accent.blendWith(Color(0xFF7B5C57), 0.28f)
    val frameColor = accent.blendWith(Color(0xFF8F6B63), 0.18f)
    val pillowColor = Color(0xFFF7F1EA)

    drawPath(
        path = Path().apply {
            moveTo(mattressTop.x, mattressTop.y)
            lineTo(mattressTop.x + depth.x, mattressTop.y + depth.y)
            lineTo(mattressTop.x + mattressSize.width + depth.x, mattressTop.y + depth.y)
            lineTo(mattressTop.x + mattressSize.width, mattressTop.y)
            close()
        },
        color = topColor,
    )
    drawPath(
        path = Path().apply {
            moveTo(mattressTop.x + mattressSize.width, mattressTop.y)
            lineTo(mattressTop.x + mattressSize.width + depth.x, mattressTop.y + depth.y)
            lineTo(mattressTop.x + mattressSize.width + depth.x, mattressTop.y + mattressSize.height + depth.y)
            lineTo(mattressTop.x + mattressSize.width, mattressTop.y + mattressSize.height)
            close()
        },
        color = sideColor,
    )
    drawRoundRect(
        color = accent,
        topLeft = mattressTop,
        size = mattressSize,
        cornerRadius = CornerRadius(size.minDimension * 0.045f),
    )
    drawRoundRect(
        color = pillowColor,
        topLeft = Offset(mattressTop.x + mattressSize.width * 0.08f, mattressTop.y + mattressSize.height * 0.08f),
        size = Size(mattressSize.width * 0.24f, mattressSize.height * 0.24f),
        cornerRadius = CornerRadius(size.minDimension * 0.035f),
    )
    drawRoundRect(
        color = pillowColor,
        topLeft = Offset(mattressTop.x + mattressSize.width * 0.38f, mattressTop.y + mattressSize.height * 0.08f),
        size = Size(mattressSize.width * 0.24f, mattressSize.height * 0.24f),
        cornerRadius = CornerRadius(size.minDimension * 0.035f),
    )
    drawRoundRect(
        color = frameColor,
        topLeft = Offset(size.width * 0.14f, size.height * 0.28f),
        size = Size(size.width * 0.08f, size.height * 0.38f),
        cornerRadius = CornerRadius(size.minDimension * 0.035f),
    )
    drawRoundRect(
        color = frameColor.blendWith(Color.Black, 0.08f),
        topLeft = Offset(mattressTop.x, mattressTop.y + mattressSize.height * 0.9f),
        size = Size(mattressSize.width, size.height * 0.08f),
        cornerRadius = CornerRadius(size.minDimension * 0.025f),
    )
}

private fun DrawScope.drawChairThumbnail(accent: Color) {
    val seatTopLeft = Offset(size.width * 0.34f, size.height * 0.44f)
    val seatSize = Size(size.width * 0.23f, size.height * 0.11f)
    val backTopLeft = Offset(size.width * 0.3f, size.height * 0.2f)
    val backSize = Size(size.width * 0.12f, size.height * 0.26f)
    val frameColor = accent.blendWith(Color(0xFF8A6646), 0.22f)
    val backColor = accent.blendWith(Color.White, 0.18f)
    val legColor = frameColor.blendWith(Color(0xFF5C4630), 0.24f)
    val legWidth = size.width * 0.028f
    val legBottom = size.height * 0.78f

    drawRoundRect(
        color = backColor,
        topLeft = backTopLeft,
        size = backSize,
        cornerRadius = CornerRadius(size.minDimension * 0.035f),
    )
    drawRoundRect(
        color = frameColor,
        topLeft = seatTopLeft,
        size = seatSize,
        cornerRadius = CornerRadius(size.minDimension * 0.03f),
    )

    val legStarts = listOf(
        Offset(seatTopLeft.x + seatSize.width * 0.12f, seatTopLeft.y + seatSize.height * 0.7f),
        Offset(seatTopLeft.x + seatSize.width * 0.78f, seatTopLeft.y + seatSize.height * 0.7f),
        Offset(backTopLeft.x + backSize.width * 0.08f, backTopLeft.y + backSize.height * 0.92f),
        Offset(backTopLeft.x + backSize.width * 0.8f, backTopLeft.y + backSize.height * 0.92f),
    )
    legStarts.forEach { start ->
        drawRoundRect(
            color = legColor,
            topLeft = start,
            size = Size(legWidth, legBottom - start.y),
            cornerRadius = CornerRadius(legWidth * 0.5f),
        )
    }
}

private fun DrawScope.drawStepStoolThumbnail(accent: Color) {
    val lowerTop = Offset(size.width * 0.18f, size.height * 0.52f)
    val lowerSize = Size(size.width * 0.42f, size.height * 0.16f)
    val upperTop = Offset(size.width * 0.35f, size.height * 0.34f)
    val upperSize = Size(size.width * 0.28f, size.height * 0.14f)
    val depth = Offset(size.width * 0.13f, -size.height * 0.08f)
    val sideColor = accent.blendWith(Color(0xFF6D512E), 0.28f)
    val topColor = accent.blendWith(Color.White, 0.24f)

    fun DrawScope.drawStep(topLeft: Offset, stepSize: Size, faceColor: Color) {
        drawPath(
            path = Path().apply {
                moveTo(topLeft.x, topLeft.y)
                lineTo(topLeft.x + depth.x, topLeft.y + depth.y)
                lineTo(topLeft.x + stepSize.width + depth.x, topLeft.y + depth.y)
                lineTo(topLeft.x + stepSize.width, topLeft.y)
                close()
            },
            color = topColor,
        )
        drawPath(
            path = Path().apply {
                moveTo(topLeft.x + stepSize.width, topLeft.y)
                lineTo(topLeft.x + stepSize.width + depth.x, topLeft.y + depth.y)
                lineTo(topLeft.x + stepSize.width + depth.x, topLeft.y + stepSize.height + depth.y)
                lineTo(topLeft.x + stepSize.width, topLeft.y + stepSize.height)
                close()
            },
            color = sideColor,
        )
        drawRoundRect(
            color = faceColor,
            topLeft = topLeft,
            size = stepSize,
            cornerRadius = CornerRadius(size.minDimension * 0.04f),
        )
    }

    drawStep(lowerTop, lowerSize, accent)
    drawStep(upperTop, upperSize, accent.blendWith(Color.White, 0.06f))
}

private fun Color.blendWith(other: Color, ratio: Float): Color {
    val clampedRatio = ratio.coerceIn(0f, 1f)
    val inverse = 1f - clampedRatio
    return Color(
        red = (red * inverse) + (other.red * clampedRatio),
        green = (green * inverse) + (other.green * clampedRatio),
        blue = (blue * inverse) + (other.blue * clampedRatio),
        alpha = (alpha * inverse) + (other.alpha * clampedRatio),
    )
}
