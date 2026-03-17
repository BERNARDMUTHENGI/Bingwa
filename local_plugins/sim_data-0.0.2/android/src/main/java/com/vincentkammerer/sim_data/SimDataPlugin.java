package com.vincentkammerer.sim_data;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

public class SimDataPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

  public static final String CHANNEL_NAME = "com.vincentkammerer.sim_data/channel_name";
  private Context applicationContext;
  private Activity activity;
  private MethodChannel channel;

  // V2 embedding initialization
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.initialize(flutterPluginBinding.getBinaryMessenger(),
        flutterPluginBinding.getApplicationContext());
  }

  private void initialize(BinaryMessenger messenger, Context context) {
    this.applicationContext = context;
    channel = new MethodChannel(messenger, CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    this.applicationContext = null;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (!checkPermission()) {
      requestPermission();
      result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null);
      return;
    }
    try {
      String simCards = getSimData().toString();
      result.success(simCards);
    } catch (Exception e) {
      result.error("SimData_error", e.getMessage(), e);
    }
  }

  private JSONObject getSimData() throws Exception {
    SubscriptionManager subscriptionManager = (SubscriptionManager) this.applicationContext
        .getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE);

    List<SubscriptionInfo> subscriptionInfos = subscriptionManager
        .getActiveSubscriptionInfoList();

    JSONArray cards = new JSONArray();
    if (subscriptionInfos != null) {
      for (SubscriptionInfo subscriptionInfo : subscriptionInfos) {
        int slotIndex = subscriptionInfo.getSimSlotIndex();

        CharSequence carrierName = subscriptionInfo.getCarrierName();
        String countryIso = subscriptionInfo.getCountryIso();
        int dataRoaming = subscriptionInfo.getDataRoaming();
        CharSequence displayName = subscriptionInfo.getDisplayName();
        String serialNumber = subscriptionInfo.getIccId();
        int mcc = subscriptionInfo.getMcc();
        int mnc = subscriptionInfo.getMnc();
        boolean networkRoaming = subscriptionManager.isNetworkRoaming(slotIndex);
        String phoneNumber = subscriptionInfo.getNumber();
        int subscriptionId = subscriptionInfo.getSubscriptionId();

        JSONObject card = new JSONObject();
        card.put("carrierName", carrierName.toString());
        card.put("countryCode", countryIso);
        card.put("displayName", displayName.toString());
        card.put("isDataRoaming", (dataRoaming == 1));
        card.put("isNetworkRoaming", networkRoaming);
        card.put("mcc", mcc);
        card.put("mnc", mnc);
        card.put("phoneNumber", phoneNumber);
        card.put("serialNumber", serialNumber);
        card.put("slotIndex", slotIndex);
        card.put("subscriptionId", subscriptionId);

        cards.put(card);
      }
    }

    JSONObject simCards = new JSONObject();
    simCards.put("cards", cards);
    return simCards;
  }

  private void requestPermission() {
    if (activity != null) {
      String[] perm = {Manifest.permission.READ_PHONE_STATE};
      ActivityCompat.requestPermissions(activity, perm, 0);
    }
  }

  private boolean checkPermission() {
    return PackageManager.PERMISSION_GRANTED == ContextCompat
        .checkSelfPermission(this.applicationContext, Manifest.permission.READ_PHONE_STATE);
  }

  // ActivityAware implementation
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    this.activity = null;
  }
}