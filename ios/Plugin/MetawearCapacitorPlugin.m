#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(MetawearCapacitorPlugin, "MetawearCapacitor",
           CAP_PLUGIN_METHOD(echo, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(connect, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(disconnect, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(startData, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(startAccelData, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(startGyroData, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(stopData, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(downloadData, CAPPluginReturnPromise);
)
