

const path  = require( "path"  );

module.exports = {
  context: path.resolve( __dirname, '../'),
  entry: 'js/res/Guest.js',
  output: {
    filename: 'js/PackGuest.js',
    path: path.resolve(__dirname, './') },
  module: {
    loaders: [
      { test: /\.json$/,   loader: "json-loader" } ] }

};

module.exports = {
  context: __dirname,
  entry: 'js/res/Guest.js',
  output: {
    path:     path.resolve( __dirname ),
    filename: 'js/PackGuest.js' },
  resolve: {
    alias: {
      js:     path.resolve( __dirname, '../js'  ),
      data:   path.resolve( __dirname, '../data'),
      public: path.resolve( __dirname, 'public' ) } },
  module: {
    rules: [
      { test: /\.json$/,   loader: "json-loader" } ] }
};
