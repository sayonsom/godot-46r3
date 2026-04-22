package com.smartthings.shaderhome.ui.theme

import androidx.compose.runtime.Immutable
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.ui.graphics.Color

@Immutable
data class SmartThingsTokens(
    val pillBackground: Color,
    val pillText: Color,
    val ctaBackground: Color,
    val ctaText: Color,
    val sceneChipBackground: Color,
    val roomLabelText: Color,
    val activeIconAmber: Color,
    val activeIconBlue: Color,
    val navActiveText: Color,
    val navInactiveText: Color,
    val statusGood: Color,
)

fun lightTokens(): SmartThingsTokens = SmartThingsTokens(
    pillBackground = LightPalette.Panel,
    pillText = LightPalette.TextPrimary,
    ctaBackground = LightPalette.Series2,
    ctaText = Color.White,
    sceneChipBackground = LightPalette.Panel,
    roomLabelText = LightPalette.TextSecondary.copy(alpha = 0.72f),
    activeIconAmber = LightPalette.Series6,
    activeIconBlue = LightPalette.Series2,
    navActiveText = LightPalette.TextPrimary,
    navInactiveText = LightPalette.TextSecondary,
    statusGood = LightPalette.Series5,
)

fun darkTokens(): SmartThingsTokens = SmartThingsTokens(
    pillBackground = DarkPalette.Panel,
    pillText = DarkPalette.TextPrimary,
    ctaBackground = DarkPalette.Series2,
    ctaText = Color.White,
    sceneChipBackground = DarkPalette.Panel,
    roomLabelText = DarkPalette.TextSecondary.copy(alpha = 0.68f),
    activeIconAmber = DarkPalette.Series6,
    activeIconBlue = DarkPalette.Series2,
    navActiveText = DarkPalette.TextPrimary,
    navInactiveText = DarkPalette.TextSecondary,
    statusGood = DarkPalette.Series5,
)

val LocalSmartThingsTokens = compositionLocalOf { darkTokens() }
