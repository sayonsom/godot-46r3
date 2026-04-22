package com.smartthings.shaderhome

import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class ShaderHostPlugin(
    godot: Godot,
    private val activityBridge: ActivityBridge? = null,
) : GodotPlugin(godot) {
    interface ActivityBridge {
        fun onDeviceDialogRequested(
            deviceId: String,
            roomLabel: String,
            deviceName: String,
            deviceKind: String,
            isOn: Boolean,
            temperatureC: Int,
        )

        fun onLightStatusChanged(onCount: Int, totalCount: Int)

        fun onTemperatureStatusChanged(
            minTemperature: Int,
            maxTemperature: Int,
            onCount: Int,
            totalCount: Int,
        )

        fun onFloorEditorSelectionChanged(
            roomId: String,
            roomLabel: String,
            committedFinishId: String,
            pendingFinishId: String,
        )

        fun onFloorEditorSelectionCleared()

        fun onFurnitureCatalogSelectionCleared()

        fun onCameraCalloutRequested(deviceId: String, roomLabel: String, imageAssetPath: String)

        fun onEnergySummaryUpdated(
            savingRatePercent: Double,
            usageKwh: Double,
            usageCost: Double,
            savingsKwh: Double,
            savingsCost: Double,
        )

        fun onPluginReady()
    }

    companion object {
        private val SHADER_SELECTION_CHANGED = SignalInfo("shader_selection_changed", String::class.java)
        private val VIEW_MODE_CHANGED = SignalInfo("view_mode_changed", Boolean::class.javaObjectType)
        private val ROTATE_REQUESTED = SignalInfo("rotate_requested")
        private val FURNITURE_SELECTION_CHANGED = SignalInfo("furniture_selection_changed", String::class.java)
        private val LIGHT_FOCUS_MODE_CHANGED = SignalInfo(
            "light_focus_mode_changed",
            Boolean::class.javaObjectType,
        )
        private val TEMPERATURE_FOCUS_MODE_CHANGED = SignalInfo(
            "temperature_focus_mode_changed",
            Boolean::class.javaObjectType,
        )
        private val AIR_QUALITY_FOCUS_MODE_CHANGED = SignalInfo(
            "air_quality_focus_mode_changed",
            Boolean::class.javaObjectType,
        )
        private val CAMERA_FOCUS_MODE_CHANGED = SignalInfo(
            "camera_focus_mode_changed",
            Boolean::class.javaObjectType,
        )
        private val ENERGY_FOCUS_MODE_CHANGED = SignalInfo(
            "energy_focus_mode_changed",
            Boolean::class.javaObjectType,
        )
        private val FLOOR_PLAN_EDIT_MODE_CHANGED = SignalInfo(
            "floor_plan_edit_mode_changed",
            Boolean::class.javaObjectType,
        )
        private val FURNITURE_EDIT_MODE_CHANGED = SignalInfo(
            "furniture_edit_mode_changed",
            Boolean::class.javaObjectType,
        )
        private val HOME_SKIN_SELECTED = SignalInfo(
            "home_skin_selected",
            String::class.java,
        )
        private val ROOM_FINISH_PREVIEW_REQUESTED = SignalInfo(
            "room_finish_preview_requested",
            String::class.java,
        )
        private val ROOM_FINISH_APPLY_TO_ALL_REQUESTED = SignalInfo(
            "room_finish_apply_to_all_requested",
            String::class.java,
        )
        private val ROOM_FINISH_APPLY_REQUESTED = SignalInfo("room_finish_apply_requested")
        private val ROOM_FINISH_CANCEL_REQUESTED = SignalInfo("room_finish_cancel_requested")
        private val FLOOR_PLAN_SESSION_APPLY_REQUESTED = SignalInfo("floor_plan_session_apply_requested")
        private val FLOOR_PLAN_SESSION_CANCEL_REQUESTED = SignalInfo("floor_plan_session_cancel_requested")
        private val DEVICE_COMMAND_REQUESTED = SignalInfo(
            "device_command_requested",
            String::class.java,
            Boolean::class.javaObjectType,
        )
    }

    override fun getPluginName() = "SmartHomeAppPlugin"

    override fun getPluginSignals() = setOf(
        SHADER_SELECTION_CHANGED,
        VIEW_MODE_CHANGED,
        ROTATE_REQUESTED,
        FURNITURE_SELECTION_CHANGED,
        LIGHT_FOCUS_MODE_CHANGED,
        TEMPERATURE_FOCUS_MODE_CHANGED,
        AIR_QUALITY_FOCUS_MODE_CHANGED,
        CAMERA_FOCUS_MODE_CHANGED,
        ENERGY_FOCUS_MODE_CHANGED,
        FLOOR_PLAN_EDIT_MODE_CHANGED,
        FURNITURE_EDIT_MODE_CHANGED,
        HOME_SKIN_SELECTED,
        ROOM_FINISH_PREVIEW_REQUESTED,
        ROOM_FINISH_APPLY_TO_ALL_REQUESTED,
        ROOM_FINISH_APPLY_REQUESTED,
        ROOM_FINISH_CANCEL_REQUESTED,
        FLOOR_PLAN_SESSION_APPLY_REQUESTED,
        FLOOR_PLAN_SESSION_CANCEL_REQUESTED,
        DEVICE_COMMAND_REQUESTED,
    )

    private var isRegistered = false

    fun updateShaderSelection(payload: String) {
        emitSignal(SHADER_SELECTION_CHANGED.name, payload)
    }

    fun updateViewMode(is3d: Boolean) {
        emitSignal(VIEW_MODE_CHANGED.name, is3d)
    }

    fun requestRotate() {
        emitSignal(ROTATE_REQUESTED.name)
    }

    fun updateFurnitureSelection(modelId: String) {
        emitSignal(FURNITURE_SELECTION_CHANGED.name, modelId)
    }

    fun updateLightFocusMode(isActive: Boolean) {
        emitSignal(LIGHT_FOCUS_MODE_CHANGED.name, isActive)
    }

    fun updateTemperatureFocusMode(isActive: Boolean) {
        emitSignal(TEMPERATURE_FOCUS_MODE_CHANGED.name, isActive)
    }

    fun updateAirQualityFocusMode(isActive: Boolean) {
        emitSignal(AIR_QUALITY_FOCUS_MODE_CHANGED.name, isActive)
    }

    fun updateCameraFocusMode(isActive: Boolean) {
        emitSignal(CAMERA_FOCUS_MODE_CHANGED.name, isActive)
    }

    fun updateEnergyFocusMode(isActive: Boolean) {
        emitSignal(ENERGY_FOCUS_MODE_CHANGED.name, isActive)
    }

    fun updateFloorPlanEditMode(isActive: Boolean) {
        emitSignal(FLOOR_PLAN_EDIT_MODE_CHANGED.name, isActive)
    }

    fun updateFurnitureEditMode(isActive: Boolean) {
        emitSignal(FURNITURE_EDIT_MODE_CHANGED.name, isActive)
    }

    fun selectHomeSkin(skinId: String) {
        emitSignal(HOME_SKIN_SELECTED.name, skinId)
    }

    fun previewRoomFinish(finishId: String) {
        emitSignal(ROOM_FINISH_PREVIEW_REQUESTED.name, finishId)
    }

    fun applyRoomFinishToAll(finishId: String) {
        emitSignal(ROOM_FINISH_APPLY_TO_ALL_REQUESTED.name, finishId)
    }

    fun applyRoomFinish() {
        emitSignal(ROOM_FINISH_APPLY_REQUESTED.name)
    }

    fun cancelRoomFinish() {
        emitSignal(ROOM_FINISH_CANCEL_REQUESTED.name)
    }

    fun applyFloorPlanSession() {
        emitSignal(FLOOR_PLAN_SESSION_APPLY_REQUESTED.name)
    }

    fun cancelFloorPlanSession() {
        emitSignal(FLOOR_PLAN_SESSION_CANCEL_REQUESTED.name)
    }

    fun requestDeviceCommand(deviceId: String, isOn: Boolean) {
        emitSignal(DEVICE_COMMAND_REQUESTED.name, deviceId, isOn)
    }

    override fun onGodotSetupCompleted() {
        super.onGodotSetupCompleted()
        isRegistered = true
        getActivity()?.runOnUiThread {
            activityBridge?.onPluginReady()
        }
    }

    fun isPluginReady(): Boolean = isRegistered

    @UsedByGodot
    fun showDeviceControlPopup(
        deviceId: String,
        roomLabel: String,
        deviceName: String,
        deviceKind: String,
        isOn: Boolean,
        temperatureC: Int,
    ) {
        getActivity()?.runOnUiThread {
            activityBridge?.onDeviceDialogRequested(
                deviceId,
                roomLabel,
                deviceName,
                deviceKind,
                isOn,
                temperatureC,
            )
        }
    }

    @UsedByGodot
    fun notifyLightStatus(onCount: Int, totalCount: Int) {
        getActivity()?.runOnUiThread {
            activityBridge?.onLightStatusChanged(onCount, totalCount)
        }
    }

    @UsedByGodot
    fun notifyTemperatureStatus(
        minTemperature: Int,
        maxTemperature: Int,
        onCount: Int,
        totalCount: Int,
    ) {
        getActivity()?.runOnUiThread {
            activityBridge?.onTemperatureStatusChanged(
                minTemperature,
                maxTemperature,
                onCount,
                totalCount,
            )
        }
    }

    @UsedByGodot
    fun showFloorEditorSelection(
        roomId: String,
        roomLabel: String,
        committedFinishId: String,
        pendingFinishId: String,
    ) {
        getActivity()?.runOnUiThread {
            activityBridge?.onFloorEditorSelectionChanged(
                roomId,
                roomLabel,
                committedFinishId,
                pendingFinishId,
            )
        }
    }

    @UsedByGodot
    fun clearFloorEditorSelection() {
        getActivity()?.runOnUiThread {
            activityBridge?.onFloorEditorSelectionCleared()
        }
    }

    @UsedByGodot
    fun clearFurnitureCatalogSelection() {
        getActivity()?.runOnUiThread {
            activityBridge?.onFurnitureCatalogSelectionCleared()
        }
    }

    @UsedByGodot
    fun showCameraCallout(
        deviceId: String,
        roomLabel: String,
        imageAssetPath: String,
    ) {
        getActivity()?.runOnUiThread {
            activityBridge?.onCameraCalloutRequested(deviceId, roomLabel, imageAssetPath)
        }
    }

    @UsedByGodot
    fun notifyEnergySummary(
        savingRatePercent: Double,
        usageKwh: Double,
        usageCost: Double,
        savingsKwh: Double,
        savingsCost: Double,
    ) {
        getActivity()?.runOnUiThread {
            activityBridge?.onEnergySummaryUpdated(
                savingRatePercent,
                usageKwh,
                usageCost,
                savingsKwh,
                savingsCost,
            )
        }
    }
}
