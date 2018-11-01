module.exports = {
  test: /\.js$/,
  use: [{
    loader: 'babel-loader',
    options: { presets: ['es2015-script'], plugins: 'transform-class-properties' }
  }]
}
