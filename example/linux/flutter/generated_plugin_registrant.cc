//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <whiteboard/whiteboard_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) whiteboard_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WhiteboardPlugin");
  whiteboard_plugin_register_with_registrar(whiteboard_registrar);
}
