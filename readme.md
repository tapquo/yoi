# Yoi

Yoi is a server based on the NodeJS technology, is very simple but able to supply many of the most common needs of web server and many other general purpose tools. Yoi is written in CoffeeScript for better readability and maintainability.

To use Yoi is necessary to install NodeJS and NPM package manager.

In [yoi-instance](http://https://github.com/tapquo/yoi-instance) we find an example of the basic structure of a server with Yoi.

### package.json

This file contains the basic project data and all necessary dependencies that we need to start: 

    {
      "name"            : "yoi-instance",
      "version"         : "1.04.22",
      "description"     : "Easy (but powerful) example of YOI Instance",
      "homepage"        : "http://",
      "author"          : "Javi Jimenez <javi@tapquo.com>",
      "dependencies": {
        "coffee-script" : "*",
        "yoi"           : "*" },
      "devDependencies" : {},
      "scripts"         : {
        "start": "node yoi.js yoi development" ,
        "test": "node yoitest.js" },
      "engines"         : { "node": "*"}
    }
    
### yoi.yml

In this file is defined the basic configuration of our Yoi, for example the desired environment, where to find our "endpoints" or our "assets", the frequencies of the crons…

	environment: development
	
    endpoints:
        api:
            - example
        www:
            - example
     
	assets:
      - folder : js
        maxage: 3600
      - folder: css
        maxage: 3600
      - folder: img
     
    crons:
      - name    : Example of 5 seconds job
        schedule: "*/5 * * * * *"
        file    : example
        timezone: Europe/Madrid
 
### yoi.js

This is an essential file because is responsible for starting the server.

	"use strict";

	require("coffee-script");
	require("yoi").run();

### environments

As we can see, the first property of the yoi.yml is the working environment. Yoi allows us have different environments to start up the server in different contexts. In the folder "environments", found within the "yoi" folder, create a file by environment , whose name correspond with the attribute "environment" of yoi.yml. Here you can define things like "host", port, the database…

    server:
      type: development
      host: localhost
      port: 1337
      
    mongo:
      - name    : primary
        host    : localhost
        port    : 27017
        db      : db_name
        user    : db_user
        password: db_password
    …
    
Once configured the above, simply run the command in terminal "npm install", which will install all dependencies of the package.json and as seen in this file, with "npm start" command start up the server.

### Api

A project of Yoi, as seen in the instance, in yoi/api contains the file that defining the REST APIs. These files have the extension .coffee and should be referenced in the yoi.yml.

	endpoints:
      api:
        - example

An API is defined this way:

    server.get "/api/contact", (request, response, next) ->
      rest = new Yoi.Rest request, response
      rest.required ["name"]
      name = rest.parameter "name"
      rest.run
        "status": "Hello #{name}!"

This API is executed with a REST request of type "GET" to "http://localhost:1337/api/contact".

Also is possible to make requests type "POST":

    server.post "/api/contact", (request, response, next) ->
      rest = new Yoi.Rest request, response
      rest.run
        "action": "Petición POST"
  
type "PUT":

    server.put "/api/contact", (request, response, next) ->
      rest = new Yoi.Rest request, response
      rest.run
        "action": "Petición PUT"
 
and type "DELETE":

    server.del "/api/contact", (request, response, next) ->
      rest = new Yoi.Rest request, response
      rest.run
        "action": "Petición DELETE"
        
        
### Web requests

Also in yoi/www we found the files that catch web requests. Along with these files is another folder that contains the "templates". These files and the "templates", must be referenced in the yoi.yml.

	endpoints:
      www:
        - example
       
    templates: endpoints/www/templates
    
Web requests are collected as follows:

    server.get "/", (request, response, next) ->
      site = new Yoi.Site request, response
      bindings =
        session: site.session
      site.template "index", bindings
 
This means That When making a call to "http://localhost:1337/" on screen to load the "template" named "index".

Through the bindings object is allowed to access the data of the object within the "template". 


### Assets

To load "assets" such as CSS styles, "scripts" or images on our website, are included in the yoi/assets directory in the appropriate folder, and indicate where to find those folders into the yoi.yml.

	assets:
      - folder : js
        maxage: 3600
      - folder: css
        maxage: 3600
      - folder: img
        maxage: 3600

Followed add in  our "template" the tag to load the corresponding files.

### Tests

Yoi provides an environment to test our APIS. The required files are: yoitest.js and yoitest.yml.

yoitest.js has the necesary to start the test:

	"use strict";

	require("coffee-script");
	require("yoi").test();
	
The yoitest.yml file has an attribute "files" wich indicates what test files are going to be laoded. These files must be in the "test" folder and files are .coffee.

	files:
      - example_test
      
We can create a Mock for help us to test our APIS. This is an example of how defined two users in yoitest.yml:

	users:
      - name      : Pedro
        mail      : pedro@doe.com
      - name      : Carmen
        mail      : carmen@sandiego.com
        
To run the tests, it is recommended to follow this structure.

    "use strict"

    Yoi = require "yoi"

    module.exports = -> 

      tasks = []
      tasks.push _apiWithName(user) for user in test.users
      tasks

    _apiWithName = (user) -> ->
      Yoi.Test "GET", "api", user, null, "Call api with #{user.name} for parameter 'name'", 200      
            
The parameters that are sent to be tested are: the type of request ( "GET", "POST", "PUT", "DELETE", "OPTIONS"), the url of api without domain, the parameters that are sent to that API, the headers we want to send, and the expected response caught. 

Finally to launch these tests only need to run the console:  

	node yoitest.js

In terminal will be listed one by one if the test has been successful or not.

### Crons

In Yoi the crons are routines in background that run at regular intervals. These routines are planned and remain temporarily on hold until the time of execution.

To define the cron in our yoi.yml must include your name, how often, the name of the file where the cron is implemented within "yoi/crons" and the time zone of the server time.

    crons:
      - name    : Example of 5 seconds job
        schedule: "*/5 * * * * *"
        file    : example_cron
        timezone: Europe/Madrid
 
To implement the cron you must first create a class that extends Yoi.cron and implement the method below.


    "use strict"

    Yoi = require "yoi"

    class ExampleCron extends Yoi.Cron

      count = 0

      execute: ->
        count++

    exports = module.exports = ExampleCron
    
The method "execute" will be run in each interval.

You can also add a method to be executed after each interval. The method is defined as follows:

    stop: ->
      super
      console.log "count: #{count}"
 
### Crawlers

Yoi also allows us to implement crawlers, which are routines to scan web pages a of way a methodical, automated in order to access the content of these pages.
 
The way to add a crawler to Yoi is the same as a cron. Inside the folder yoi/crons create a file and add in our crawler yoi.yml the cron.

    crons:
      - name    : Crawler Sample
        schedule: "*/5 * * * * *"
        file    : example_crawler
        timezone: Europe/Amsterdam
 

This time the class must extend from Yoi.Crawler

    "use strict"

    Yoi = require "yoi"
	$   = Yoi.$

    class CrawlerSample extends Yoi.Crawler


    exports = module.exports = CrawlerSample
    
    
The first function to execute is "start" method within that class:

    start: =>
      urls = []
      for category in C.CATEGORIES
         urls.push "#{C.DOMAIN}#{category}"
      super urls, @item

This is the main function. It will add an array all urls where you want to run the crawler and super charge these urls and will pass the function you want to run with each load.

    item: (error, response, body) ->
      body.find(".entry-content > p").each (index, link) =>
        @results.push p.data for p in link.children when p.type is 'text'
    
As seen, the function receives the body of the page, and you just have to manipulate the elements to get the desired information.

If you want to access more pages in our code, the function is:

    @queue "#{next_page}", @page 

The parameters that are sent are the url of the page and the method you want to call to receive it.

There is a method that is executed at the end of the function of the crawler.

    finish: ->
      super
        console.log "Fin"
        

### Yoi.Hope

Hope is a system of promises for chaining callbacks. We have 4 types:

##### Join

Executes functions in parallel and ends when they have finished all functions. Returns an array of results and other of errors. 

    Yoi.Hope.join([ =>
      first()
    , =>
      second()
    ]).then (errors, values) ->
      console.log(errors, results)
 
##### Chain

Chain executes all functions sequentially, allowing pass the result of one function to another. Returns the last error and result.
      
    Yoi.Hope.chain([
      ->
        late(100)
      (error, result) ->
        late(result + 200)
    ]).then (error, result) ->
      console.log result    
      
##### Shield

Shield works similar to Chain, the difference is that if one of the functions returns an error when running the following are not executed. Returns the last error and result.

    Yoi.Hope.shield([
       ->
        method 1
      , ->
        method 10
      , ->
        method 2
    ]).then (error, result) ->
      if error? then console.log error
    
### Yoi.Appnima

Appnima provides a number of common features to all projects. Through Yoi we can access all of them quickly.

Here an example of how a user registers using this service.


    Yoi.Appnima.signup request.headers["user-agent"], rest.parameter("mail"), rest.parameter("password"), rest.parameter("username"),( error, user) ->
		console.log	 user
		
Also provides of quick access for doing "Login":


	Yoi.Appnima.login user_agent, mail, password , username, (error, user) ->
		console.log	 user

and a "refreshToken" which updates the user's security token:

	Yoi.Appnima.refreshToken user_agent, refresh_token, (error, new_token) ->
		console.log new_token

Finally, Yoi.Appima.api gives us access to all other features of Appnima. To know all APIs you can access: [documentation Appnima] (http://appnima.com/documentation/client). An example of use would be:

    Yoi.Appnima.api request.headers["user-agent"], "POST", "user/reset/password", null, parameters, (error, result) =>
       if error then rest.notFound() else rest.successful()
       
### Yoi.Mongo

To access a Mongo data base through Yoi , the first step is to define the database in the yoi.yml.

	mongo:
     - name    : primary
       host    : localhost
       port    : 27017
       db      : db_name
       user    : db_user
       password: db_password

To interact with it you just have to get an instance of the database with Yoi.Mongo service. An example:

	db = Yoi.Mongo.connections.primary
	
And with this you can interact with the database.

	db.users.find(query)
	
### Yoi.Redis

Yoi offers a system of "redistribution", to use the first thing to do is to define the parameters in the ".yml" environment desired.

	redis:
        host : HOST
        port : port
        
An example of how it is used:

    Yoi.Redis.get key, (error, result) -> console.log result

		
### Yoi.Mongoose

Yoi also provides a ODM for Mongo data bases called Mongoose.

The instance is created in the following way:

	Schema    = Yoi.Mongoose.Schema

To define the model:

	User = new Schema
	  mail      : type: String
	  name      : type: String

And an example of the definition of its methods:

    User.statics.findByMail = (mail) ->
      promise = new Yoi.Hope.Promise()
      @findOne(mail: mail).exec (error, value) ->
        if not value
          error = code: 401, message: "User not found"
          promise.done error, null
        promise.done error, value
      promise
   
### Deploy

Thanks to this feature you can set a series of actions or tasks that run on our server automatically.

The tasks which get executed on the server must be defined in the .yml our environment in the following way:

    deploy:
      - ls -l
      - ls -lia
     
To run the task, just run the following method from any API:

    Yoi.Deploy.tasks().then (error, pid) ->
       console.log "Executing tasks!"
       
 
With Yoi.Deploy you can configure your server to be linked to a code repository. 

With this module you can configure a series of actions or tasks you want to run on our server automatically for an environment with integration continues. This is explained in the manual Yoi.