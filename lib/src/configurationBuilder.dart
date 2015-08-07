part of redstone.configuration_plugin;

class ConfigurationBuilder {
  DynamicMap configuration = new DynamicMap({});

  addConfiguration(String configPath){
    var file = new File("${path.current}/$configPath");
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      var map = JSON.decode(content);
      configuration = new DynamicMap(
        configuration..addAll(map)
      );
    }
    else {
      throw new Exception("configuration path '$configPath' not found");
    }
  }

  addConfigurationFromMap (Map map) {
    configuration = new DynamicMap(
        configuration..addAll(map)
    );
  }
}