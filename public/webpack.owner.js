var path  = require( "path"  );

module.exports = {
  context: __dirname,
  entry: 'js/res/Owner.js',
  output: {
    path: './',
    filename: 'js/PackOwner.js' },
  resolve: {
    root: [
      path.resolve('../') ] },
  module: {
    loaders: [
      { test: /\.json$/,   loader: "json-loader" } ] }

};