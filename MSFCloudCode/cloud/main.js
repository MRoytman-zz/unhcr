Parse.Cloud.afterSave("Alert", function(request) {

	// @property (nonatomic, strong) NSString *authorName;
	// @property (nonatomic, strong) NSString *authorID;
	// @property (nonatomic, strong) NSString *message;
	// @property (nonatomic, strong) NSString *environment;
	// @property (nonatomic) BOOL read;

  	var authorName = request.object.get('authorName');
  	var message = request.object.get('message');
  	var environment = request.object.get('environment');
 
  	Parse.Push.send({
    	channels: [environment],
    	data: {
      		alert: message,
      		badge: "Increment"
    	}
	}, {
	    success: function() {
    	  	// Push was successful!
    	},
    	error: function(error) {
      	throw "Push failed with error " + error.code + " : " + error.message;
    	}
  	});
});