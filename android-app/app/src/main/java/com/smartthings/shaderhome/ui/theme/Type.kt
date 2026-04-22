package com.smartthings.shaderhome.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.PlatformTextStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

private val NoFontPaddingPlatformTextStyle = PlatformTextStyle(includeFontPadding = false)

private fun samsungTextStyle(
    fontWeight: FontWeight,
    fontSizeSp: Int,
    lineHeightSp: Int,
    letterSpacingSp: Double,
    tabularFigures: Boolean = false,
): TextStyle = TextStyle(
    fontFamily = SamsungOne,
    fontWeight = fontWeight,
    fontSize = fontSizeSp.sp,
    lineHeight = lineHeightSp.sp,
    letterSpacing = letterSpacingSp.sp,
    platformStyle = NoFontPaddingPlatformTextStyle,
    fontFeatureSettings = if (tabularFigures) "tnum" else null,
)

private fun TextStyle.withSamsungDefaults(): TextStyle = copy(
    fontFamily = SamsungOne,
    platformStyle = NoFontPaddingPlatformTextStyle,
)

private fun Typography.withSamsungDefaults(): Typography = copy(
    displayLarge = displayLarge.withSamsungDefaults(),
    displayMedium = displayMedium.withSamsungDefaults(),
    displaySmall = displaySmall.withSamsungDefaults(),
    headlineLarge = headlineLarge.withSamsungDefaults(),
    headlineMedium = headlineMedium.withSamsungDefaults(),
    headlineSmall = headlineSmall.withSamsungDefaults(),
    titleLarge = titleLarge.withSamsungDefaults(),
    titleMedium = titleMedium.withSamsungDefaults(),
    titleSmall = titleSmall.withSamsungDefaults(),
    bodyLarge = bodyLarge.withSamsungDefaults(),
    bodyMedium = bodyMedium.withSamsungDefaults(),
    bodySmall = bodySmall.withSamsungDefaults(),
    labelLarge = labelLarge.withSamsungDefaults(),
    labelMedium = labelMedium.withSamsungDefaults(),
    labelSmall = labelSmall.withSamsungDefaults(),
)

val SmartThingsTypography = Typography(
    displayLarge = samsungTextStyle(
        fontWeight = FontWeight.Bold,
        fontSizeSp = 32,
        lineHeightSp = 40,
        letterSpacingSp = -0.4,
    ),
    headlineMedium = samsungTextStyle(
        fontWeight = FontWeight.Bold,
        fontSizeSp = 24,
        lineHeightSp = 32,
        letterSpacingSp = -0.2,
    ),
    titleLarge = samsungTextStyle(
        fontWeight = FontWeight.SemiBold,
        fontSizeSp = 20,
        lineHeightSp = 28,
        letterSpacingSp = -0.1,
    ),
    titleMedium = samsungTextStyle(
        fontWeight = FontWeight.SemiBold,
        fontSizeSp = 16,
        lineHeightSp = 24,
        letterSpacingSp = 0.0,
        tabularFigures = true,
    ),
    bodyLarge = samsungTextStyle(
        fontWeight = FontWeight.Normal,
        fontSizeSp = 16,
        lineHeightSp = 24,
        letterSpacingSp = 0.0,
    ),
    bodyMedium = samsungTextStyle(
        fontWeight = FontWeight.Normal,
        fontSizeSp = 14,
        lineHeightSp = 20,
        letterSpacingSp = 0.0,
    ),
    labelLarge = samsungTextStyle(
        fontWeight = FontWeight.SemiBold,
        fontSizeSp = 14,
        lineHeightSp = 20,
        letterSpacingSp = 0.0,
        tabularFigures = true,
    ),
    labelMedium = samsungTextStyle(
        fontWeight = FontWeight.Medium,
        fontSizeSp = 12,
        lineHeightSp = 16,
        letterSpacingSp = 0.1,
    ),
    labelSmall = samsungTextStyle(
        fontWeight = FontWeight.Medium,
        fontSizeSp = 11,
        lineHeightSp = 16,
        letterSpacingSp = 0.2,
    ),
).withSamsungDefaults()
