package com.example.word_frontend

import android.view.LayoutInflater
import android.widget.Button
import android.widget.TextView

import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class SwipeNativeAdFactory(
    private val layoutInflater: LayoutInflater
) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>
    ): NativeAdView {

        val nativeAdView = layoutInflater.inflate(
            R.layout.native_ad_layout,
            null
        ) as NativeAdView

        // Headline
        val headlineView =
            nativeAdView.findViewById<TextView>(R.id.primary)

        headlineView.text = nativeAd.headline

        nativeAdView.headlineView = headlineView

        // Body
        val bodyView =
            nativeAdView.findViewById<TextView>(R.id.body)

        bodyView.text = nativeAd.body

        nativeAdView.bodyView = bodyView

        // CTA Button
        val ctaButton =
            nativeAdView.findViewById<Button>(R.id.cta)

        ctaButton.text = nativeAd.callToAction

        nativeAdView.callToActionView = ctaButton

        // Media View
        val mediaView =
            nativeAdView.findViewById<MediaView>(R.id.media_view)

        nativeAdView.mediaView = mediaView

        mediaView.mediaContent = nativeAd.mediaContent

        // IMPORTANT
        nativeAdView.setNativeAd(nativeAd)

        return nativeAdView
    }
}