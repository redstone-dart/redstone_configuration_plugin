part of redstone.configuration_plugin;

configurationPlugin(ConfigurationBuilder configurationBuilder) {
  return (app.Manager manager) {
    manager.addParameterProvider(ConfigurationField,
        (ConfigurationField metadata, Type type, String handlerName,
            String paramName, app.Request req, injector) {
      var config = configurationBuilder.configuration;

      if (metadata.configurationField == null) {
        config = config[paramName];
      } else {
        var list = metadata.configurationField.trim().split(':');
        for (var field in list) {
          if (config.containsKey(field)) {
            config = config[field];
          } else {
            throw new Exception("Configuration field '$field' doesnt exist");
          }
        }
      }

      return config is Map ? new DynamicMap(config) : config;
    });
  };
}
