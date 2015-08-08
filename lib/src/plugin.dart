part of redstone.configuration_plugin;

configurationPlugin(ConfigurationBuilder configurationBuilder) {

  bootstrapMapper();

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
      return _encodeConfig(config, type);
    });

    manager.addParameterProvider(_Environment, (_Environment metadata,
        Type type, String handlerName, String paramName, app.Request req,
        injector) {
      return getEnvironmentAs(configurationBuilder, type);
    });
  };
}

getEnvironmentAs (ConfigurationBuilder configurationBuilder, Type type) {
  var config = configurationBuilder.configuration;
  DynamicMap environments;
  DynamicMap finalConfig;

  if (config.containsKey("environments_")) {
    environments = config.environments_;
    finalConfig = new DynamicMap(environments);
  }
  else {
    throw new Exception(
        "'environments_' field not present in configuration.");
  }


  if (environments.general_ is DynamicMap) {
    finalConfig = environments.general_;
  }
  if (environments.current_ is String) {
    if (environments.containsKey(environments.current_)) {
      finalConfig.addAll(environments[environments.current_]);
    } else {
      throw new Exception(
          "Environment configuration '${environments.current_} not found.'");
    }
  }

  return _encodeConfig(finalConfig, type);
}

_encodeConfig(config, Type paramType) {
  var paramTypeString = paramType.toString();
  if (paramTypeString.startsWith('Map') ||
      paramTypeString.startsWith('DynamicMap')) {
    return config is! DynamicMap ? new DynamicMap(config) : config;
  } else {
    try {
      return decode(config, paramType);
    } catch (e,s) {
      throw new Exception(
          "Failed to encode configuration to type '$paramType'. Error: $e\n$s");
    }
  }
}
