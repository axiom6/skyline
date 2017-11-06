const path  = require( "path"  );

module.exports = {
  context: __dirname,
  entry: 'js/res/Owner.js',
  output: {
    path:     path.resolve( __dirname ),
    filename: 'js/PackOwner.js' },
  resolve: {
    alias: {
      js:     path.resolve( __dirname, '../js'  ),
      data:   path.resolve( __dirname, '../data'),
      public: path.resolve( __dirname, 'public' ) } },
  module: {
    rules: [
      { test: /\.json$/,   loader: "json-loader" } ] }
};