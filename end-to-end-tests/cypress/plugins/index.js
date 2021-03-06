// ***********************************************************
// This example plugins/index.js can be used to load plugins
//
// You can change the location of this file or turn off loading
// the plugins file with the 'pluginsFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/plugins-guide
// ***********************************************************

// This function is called when a project is opened or re-opened (e.g. due to
// the project's config changing)

// NOTE;  Probably uses `cypress` `bundled` nodejs NOT local machine copy
//        Therefore needs to be strict vanilla nodejs.

// promisified fs module
const fs = require('fs-extra');
const path = require('path');

function getConfigurationByFile(file) {
  const pathToConfigFile = path.resolve('config', `${file}.json`)

  return fs.pathExists(pathToConfigFile)
    .then(exists => {
      if (exists) {
        return fs.readJson(pathToConfigFile);
      }
    });
};

// plugins file
module.exports = (on, config) => {
  // accept a configFile value or use local by default
  const file = config.env.configFile || 'local';

  return getConfigurationByFile(file) || config.env;
};
