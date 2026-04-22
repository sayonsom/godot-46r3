package com.smartthings.shaderhome.ui.preview

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartthings.shaderhome.ui.theme.AppTheme
import com.smartthings.shaderhome.ui.theme.LocalSmartThingsTokens
import com.smartthings.shaderhome.ui.theme.SmartThingsTokens
import com.smartthings.shaderhome.ui.theme.darkTokens
import com.smartthings.shaderhome.ui.theme.lightTokens

private data class TypographySample(
    val token: String,
    val sample: String,
    val style: TextStyle,
)

@Composable
private fun TypographyPreviewContent() {
    val typography = MaterialTheme.typography
    val samples = listOf(
        TypographySample("displayLarge", "Virtual location", typography.displayLarge),
        TypographySample("headlineMedium", "Godot Home", typography.headlineMedium),
        TypographySample("titleLarge", "Exit Virtual Home", typography.titleLarge),
        TypographySample("titleMedium", "66~77\u00b0F • 5 on", typography.titleMedium),
        TypographySample("bodyLarge", "Give the view of your home the look that you want.", typography.bodyLarge),
        TypographySample("bodyMedium", "virtual location", typography.bodyMedium),
        TypographySample("labelLarge", "Good morning • 66~77\u00b0F", typography.labelLarge),
        TypographySample("labelMedium", "Devices", typography.labelMedium),
        TypographySample("labelSmall", "Home", typography.labelSmall),
    )

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background,
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Text(
                text = "SamsungOne Typography",
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onBackground,
            )
            samples.forEach { sample ->
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    color = MaterialTheme.colorScheme.surfaceVariant,
                    shape = RoundedCornerShape(20.dp),
                    tonalElevation = 0.dp,
                    shadowElevation = 0.dp,
                ) {
                    Column(
                        modifier = Modifier.padding(horizontal = 18.dp, vertical = 16.dp),
                        verticalArrangement = Arrangement.spacedBy(6.dp),
                    ) {
                        Text(
                            text = sample.token,
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Text(
                            text = sample.sample,
                            style = sample.style,
                            color = MaterialTheme.colorScheme.onSurface,
                        )
                    }
                }
            }
        }
    }
}

@Preview(
    name = "Typography Light",
    showBackground = true,
    backgroundColor = 0xFFFFFFFF,
    widthDp = 420,
    heightDp = 960,
)
@Composable
private fun TypographyPreviewLight() {
    AppTheme(darkTheme = false) {
        TypographyPreviewContent()
    }
}

@Preview(
    name = "Typography Dark",
    showBackground = true,
    backgroundColor = 0xFF0B1220,
    widthDp = 420,
    heightDp = 960,
)
@Composable
private fun TypographyPreviewDark() {
    AppTheme(darkTheme = true) {
        TypographyPreviewContent()
    }
}

private fun semanticTokenEntries(tokens: SmartThingsTokens): List<Pair<String, Color>> = listOf(
    "pillBackground" to tokens.pillBackground,
    "pillText" to tokens.pillText,
    "ctaBackground" to tokens.ctaBackground,
    "ctaText" to tokens.ctaText,
    "sceneChipBackground" to tokens.sceneChipBackground,
    "roomLabelText" to tokens.roomLabelText,
    "activeIconAmber" to tokens.activeIconAmber,
    "activeIconBlue" to tokens.activeIconBlue,
    "navActiveText" to tokens.navActiveText,
    "navInactiveText" to tokens.navInactiveText,
    "statusGood" to tokens.statusGood,
)

private fun Color.toHexString(): String {
    val argb = toArgb()
    val alpha = argb ushr 24
    return if (alpha == 0xFF) {
        String.format("#%06X", argb and 0xFFFFFF)
    } else {
        String.format("#%08X", argb)
    }
}

@Composable
private fun SemanticTokenColumn(
    title: String,
    background: Color,
    onBackground: Color,
    tokens: SmartThingsTokens,
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = background,
        shape = RoundedCornerShape(24.dp),
    ) {
        Column(
            modifier = Modifier.padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                color = onBackground,
            )
            semanticTokenEntries(tokens).forEach { (name, color) ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(1.dp, onBackground.copy(alpha = 0.08f), RoundedCornerShape(18.dp))
                        .padding(horizontal = 12.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    Box(
                        modifier = Modifier
                            .size(28.dp)
                            .background(color, RoundedCornerShape(10.dp))
                            .border(1.dp, onBackground.copy(alpha = 0.10f), RoundedCornerShape(10.dp)),
                    )
                    Column(
                        modifier = Modifier.weight(1f),
                        verticalArrangement = Arrangement.spacedBy(2.dp),
                    ) {
                        Text(
                            text = name,
                            style = MaterialTheme.typography.labelLarge,
                            color = onBackground,
                        )
                        Text(
                            text = color.toHexString(),
                            style = MaterialTheme.typography.labelSmall,
                            color = onBackground.copy(alpha = 0.72f),
                        )
                    }
                }
            }
        }
    }
}

@Preview(
    name = "Semantic Tokens",
    showBackground = true,
    backgroundColor = 0xFFF3F5F8,
    widthDp = 960,
    heightDp = 900,
)
@Composable
private fun SemanticTokensPreview() {
    AppTheme(darkTheme = false) {
        val previewTokens = LocalSmartThingsTokens.current
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = Color(0xFFF3F5F8),
        ) {
            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    SemanticTokenColumn(
                        title = "Light",
                        background = MaterialTheme.colorScheme.background,
                        onBackground = MaterialTheme.colorScheme.onBackground,
                        tokens = previewTokens,
                    )
                }
                Box(modifier = Modifier.weight(1f)) {
                    SemanticTokenColumn(
                        title = "Dark",
                        background = Color(0xFF0B1220),
                        onBackground = Color(0xFFE5E7EB),
                        tokens = darkTokens(),
                    )
                }
            }
        }
    }
}
