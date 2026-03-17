package com.example.ussd_advanced

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import android.telephony.TelephonyManager.UssdResponseCallback
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.CompletableFuture

class UssdAdvancedPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null

    companion object {
        const val CHANNEL_NAME = "plugins.elyudde.com/ussd_advanced"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            val code = call.argument<String>("code") ?: throw Exception("USSD code required")
            val subscriptionId = call.argument<Int>("subscriptionId") ?: -1

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val res = sendUssdV2(code, subscriptionId)
                if (res != null) {
                    res.exceptionally { e ->
                        result.error("USSD_ERROR", e?.message, null)
                        null
                    }.thenAccept(result::success)
                } else {
                    result.success(null)
                }
            } else {
                sendUssdLegacy(code, subscriptionId)
                result.success(null)
            }
        } catch (e: Exception) {
            result.error("USSD_EXCEPTION", e.message, null)
        }
    }

    private fun sendUssdV2(code: String, subscriptionId: Int): CompletableFuture<String>? {
        val useDefault = subscriptionId == -1
        val tm = context!!.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val simManager: TelephonyManager = if (useDefault) tm else tm.createForSubscriptionId(subscriptionId)

        val res = CompletableFuture<String>()

        val callback = object: UssdResponseCallback() {
            override fun onReceiveUssdResponse(
                telephonyManager: TelephonyManager, request: String, response: CharSequence
            ) { res.complete(response.toString()) }

            override fun onReceiveUssdResponseFailed(
                telephonyManager: TelephonyManager, request: String, failureCode: Int
            ) {
                res.completeExceptionally(Exception("USSD failed with code $failureCode"))
            }
        }

        if (ContextCompat.checkSelfPermission(context!!, android.Manifest.permission.CALL_PHONE)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity!!, arrayOf(android.Manifest.permission.CALL_PHONE), 2)
        }

        simManager.sendUssdRequest(code, callback, Handler(Looper.getMainLooper()))
        return res
    }

    private fun sendUssdLegacy(code: String, subscriptionId: Int) {
        val number = "tel:${code.replace("#", "%23")}"
        val intent = Intent(Intent.ACTION_CALL, Uri.parse(number))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context!!.startActivity(intent)
    }
}