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

var UserSchema = new Schema( {
                               isAdmin: {type: Boolean, default: false},
                               email : { type : String, lowercase: true, required : true },
                               passwordEnable : {type : Boolean, default: false},
                               passwordHash : { type : String },
                               createdAt : { type: Date, default: new Date() }
                             },
                             { collection : 'User'} );

var User = mongoose.model( 'User', UserSchema );

User.schema.path( 'email' ).validate( function( value ) { return check( value.trim() ).isEmail(); }, 'Invalid email' );

User.modelName = 'User';

module.exports = User;
