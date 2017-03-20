

var path  = require( "path"  );

module.exports = {
  context: __dirname,
  entry: '../js/res/Guest.js',
  output: {
    path: './',
    filename: 'js/Pack.js' },
  resolve: {
    root: [
      path.resolve('../') ] },
  module: {
    loaders: [
      { test: /\.json$/,   loader: "json-loader" } ] }

};
