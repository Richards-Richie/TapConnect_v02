const mongoose = require('mongoose');


const dataSchema=mongoose.Schema({
    name : {
        type:String,
        required:true
    },
    mobile : {
        type:String,
        required:true
    },
    email : {
        type:String,
        required:true
    },
},{
    collection :'flutter_user'
})
const data=mongoose.model('Data',dataSchema);


module.exports = data;
