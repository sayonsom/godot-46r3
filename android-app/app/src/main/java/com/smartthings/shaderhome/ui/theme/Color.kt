package com.smartthings.shaderhome.ui.theme

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color

object LightPalette {
    val Background = Color(0xFFFFFFFF)
    val Panel = Color(0xFFF5F7FA)
    val Grid = Color(0xFFE5E7EB)
    val Axis = Color(0xFFD1D5DB)
    val TextPrimary = Color(0xFF111827)
    val TextSecondary = Color(0xFF4B5563)

    val Series1 = Color(0xFF003A8F)
    val Series2 = Color(0xFF1F4CEB)
    val Series3 = Color(0xFF5B7FA6)
    val Series4 = Color(0xFF2F7F9D)
    val Series5 = Color(0xFF2E6F4E)
    val Series6 = Color(0xFFC69214)
    val Series7 = Color(0xFF7A2E2E)
    val Series8 = Color(0xFF6B7280)
}

object DarkPalette {
    val Background = Color(0xFF0B1220)
    val Panel = Color(0xFF111827)
    val Grid = Color(0xFF1F2933)
    val Axis = Color(0xFF374151)
    val TextPrimary = Color(0xFFE5E7EB)
    val TextSecondary = Color(0xFF9CA3AF)

    val Series1 = Color(0xFF4F83CC)
    val Series2 = Color(0xFF1F4CEB)
    val Series3 = Color(0xFF5B7FA6)
    val Series4 = Color(0xFF2F7F9D)
    val Series5 = Color(0xFF4CAF84)
    val Series6 = Color(0xFFE0B84C)
    val Series7 = Color(0xFFC26D6D)
    val Series8 = Color(0xFF9CA3AF)
}

fun smartThingsLightColorScheme(): ColorScheme = lightColorScheme(
    primary = LightPalette.Series2,
    onPrimary = Color.White,
    primaryContainer = LightPalette.Series1,
    onPrimaryContainer = Color.White,
    inversePrimary = LightPalette.Series1,
    secondary = LightPalette.Series4,
    onSecondary = Color.White,
    secondaryContainer = LightPalette.Panel,
    onSecondaryContainer = LightPalette.TextPrimary,
    tertiary = LightPalette.Series6,
    onTertiary = LightPalette.TextPrimary,
    tertiaryContainer = LightPalette.Panel,
    onTertiaryContainer = LightPalette.TextPrimary,
    background = LightPalette.Background,
    onBackground = LightPalette.TextPrimary,
    surface = LightPalette.Background,
    onSurface = LightPalette.TextPrimary,
    surfaceVariant = LightPalette.Panel,
    onSurfaceVariant = LightPalette.TextSecondary,
    surfaceTint = LightPalette.Series2,
    inverseSurface = DarkPalette.Panel,
    inverseOnSurface = DarkPalette.TextPrimary,
    error = LightPalette.Series7,
    onError = Color.White,
    errorContainer = LightPalette.Panel,
    onErrorContainer = LightPalette.TextPrimary,
    outline = LightPalette.Grid,
    outlineVariant = LightPalette.Axis,
    scrim = Color(0x66000000),
)

fun smartThingsDarkColorScheme(): ColorScheme = darkColorScheme(
    primary = DarkPalette.Series2,
    onPrimary = Color.White,
    primaryContainer = DarkPalette.Series1,
    onPrimaryContainer = DarkPalette.TextPrimary,
    inversePrimary = DarkPalette.Series1,
    secondary = DarkPalette.Series4,
    onSecondary = Color.White,
    secondaryContainer = DarkPalette.Panel,
    onSecondaryContainer = DarkPalette.TextPrimary,
    tertiary = DarkPalette.Series6,
    onTertiary = DarkPalette.Background,
    tertiaryContainer = DarkPalette.Panel,
    onTertiaryContainer = DarkPalette.TextPrimary,
    background = DarkPalette.Background,
    onBackground = DarkPalette.TextPrimary,
    surface = DarkPalette.Background,
    onSurface = DarkPalette.TextPrimary,
    surfaceVariant = DarkPalette.Panel,
    onSurfaceVariant = DarkPalette.TextSecondary,
    surfaceTint = DarkPalette.Series2,
    inverseSurface = LightPalette.Panel,
    inverseOnSurface = LightPalette.TextPrimary,
    error = DarkPalette.Series7,
    onError = Color.White,
    errorContainer = DarkPalette.Panel,
    onErrorContainer = DarkPalette.TextPrimary,
    outline = DarkPalette.Grid,
    outlineVariant = DarkPalette.Axis,
    scrim = Color(0x99000000),
)
