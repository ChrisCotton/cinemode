/**
 * Created with IntelliJ IDEA.
 * User: Danny Siu <danny.siu@gmail.com>
 * Date: 7/15/13
 * Time: 6:27 PM
 */
var mongoose = require('mongoose');

var init = function () {
  mongoose.connect(global.conf.mongo.url);
  var models = require('../models');
  this.models = models;
};

module.exports = {
  init: init,
  models: null
}
