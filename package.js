Package.describe({
  name: 'comerc:autoform-fixtures',
  summary: 'Get fixtures data for Collection2',
  version: '1.0.0',
  git: 'https://github.com/comerc/meteor-autoform-fixtures.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.2.1');
  api.use('coffeescript');
  api.use('momentjs:moment@2.8.4', 'client');
  api.use('aldeed:autoform@4.0.0');
  api.addFiles([
    'autoform-fixtures.coffee',
  ], 'client');
});
