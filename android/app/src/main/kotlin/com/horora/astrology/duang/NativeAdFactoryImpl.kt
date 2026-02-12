package com.horora.astrology.duang

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactoryImpl(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_layout, null) as NativeAdView

        // Get references to views
        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val callToActionView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)
        val iconView = nativeAdView.findViewById<ImageView>(R.id.ad_app_icon)
        val advertiserView = nativeAdView.findViewById<TextView>(R.id.ad_advertiser)
        val starRatingView = nativeAdView.findViewById<RatingBar>(R.id.ad_stars)
        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media)

        // Set the views
        nativeAdView.headlineView = headlineView
        nativeAdView.bodyView = bodyView
        nativeAdView.callToActionView = callToActionView
        nativeAdView.iconView = iconView
        nativeAdView.advertiserView = advertiserView
        nativeAdView.starRatingView = starRatingView
        nativeAdView.mediaView = mediaView

        // Populate the Headline
        headlineView.text = nativeAd.headline

        // Populate the Body
        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }

        // Populate the Call to Action
        if (nativeAd.callToAction != null) {
            callToActionView.text = nativeAd.callToAction
            callToActionView.visibility = View.VISIBLE
        } else {
            callToActionView.visibility = View.GONE
        }

        // Populate the Icon
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon?.drawable)
            iconView.visibility = View.VISIBLE
        } else {
            iconView.visibility = View.GONE
        }

        // Populate the Advertiser
        if (nativeAd.advertiser != null) {
            advertiserView.text = nativeAd.advertiser
            advertiserView.visibility = View.VISIBLE
        } else {
            advertiserView.visibility = View.GONE
        }

        // Populate the Star Rating
        if (nativeAd.starRating != null) {
            starRatingView.rating = nativeAd.starRating!!.toFloat()
            starRatingView.visibility = View.VISIBLE
        } else {
            starRatingView.visibility = View.GONE
        }

        // Populate Media View
        if (nativeAd.mediaContent != null && nativeAd.mediaContent!!.hasVideoContent()) {
            mediaView.mediaContent = nativeAd.mediaContent
            mediaView.visibility = View.VISIBLE
        } else {
            mediaView.visibility = View.GONE
        }

        // Register the NativeAdView
        nativeAdView.setNativeAd(nativeAd)

        return nativeAdView
    }
}
