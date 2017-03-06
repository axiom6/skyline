

var path  = require( "path"  );

module.exports = {
  context: __dirname,
  entry: '../js/res/Res.js',
  output: {
    path: './',
    filename: 'Pack.js' },
  resolve: {
    root: [
      path.resolve('../') ] },
  module: {
    loaders: [
      { test: /\.json$/,   loader: "json-loader" } ] }

};