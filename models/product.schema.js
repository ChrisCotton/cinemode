/**
 * Created with IntelliJ IDEA.
 * User: Danny Siu <danny.siu@gmail.com>
 * Date: 7/15/13
 * Time: 6:41 PM
 */


/**
 * Created with IntelliJ IDEA.
 * User: Danny Siu <danny.siu@gmail.com>
 * Date: 7/15/13
 * Time: 6:41 PM
 */

var mongoose = require( 'mongoose' );
var validator = require( 'validator' );
var check = validator.check;
// hack to mute the errors from Validators
validator.Validator.prototype.error = function( msg ) { };

var Schema = mongoose.Schema;

var ProductSchema = new Schema( {
                               name : { type: String },
                               price : { type: Number },
                               imageUrl: { type: String },
                               description : { type : String},
                               likeCount : { type : Number },
                               createdAt : { type: Date, default: new Date() }
                             },
                             { collection : 'Product'} );

var Product = mongoose.model( 'Product', ProductSchema );

Product.modelName = 'Product';

module.exports = Product;
