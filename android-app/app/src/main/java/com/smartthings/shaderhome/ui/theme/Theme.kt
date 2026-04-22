package com.smartthings.shaderhome.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ProvideTextStyle
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider

@Composable
fun AppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) smartThingsDarkColorScheme() else smartThingsLightColorScheme()
    val semanticTokens = if (darkTheme) darkTokens() else lightTokens()

    MaterialTheme(
        colorScheme = colorScheme,
        typography = SmartThingsTypography,
    ) {
        CompositionLocalProvider(
            LocalSmartThingsTokens provides semanticTokens,
        ) {
            ProvideTextStyle(SmartThingsTypography.bodyLarge, content)
        }
    }
}
