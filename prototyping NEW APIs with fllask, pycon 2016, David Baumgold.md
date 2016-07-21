# Let's build it fast

* what we want to do as a "PROTOTYPE"
 * JSON data format
 * CRUD operations (Create, Read, Update, Delete)
 * REST semantics
 * Flexible code (it's a prototype)

# Use jsonify [[2m20s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=2m20s)]
```python
from flask import jsonify

@app.route("/")
def hello():
    return jsonify({"message": "Hello world"})
```

# Create an API to manage puppy [[2m27s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=2m20s)]
manage a puppy
```python
@app.route("/")
def get_puppy():
    puppy={ "name": "Rover", "image_url": "http://example.com/rover.jpg"}
    return jsonify(puppy)
```

#  manage many puppies by ID [[3m35s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=3m35s)]
```python
from flask import jsonify, abort
#
PUPPIES=[
    {  "name": "Rover", "image_url": "http://example.com/rover.jpg" },
    {  "name": "Spot", "image_url": "http://example.com/spot.jpg" },
]

@app.route("/<int:index>")
def get_puppy(index):
    try:
        puppy= PUPPIES[index]
    except:
        # 404 : Not found
        abort(404)
    return jsonify(puppy)
```

# Manage many puppies by slug. [[4m20s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=4m20s)]
 * slug definition comes from newspaper production: is a short name given to an article

```python
PUPPIES={
    "rover": {  "name": "Rover", "image_url": "http://example.com/rover.jpg" },
    "spot":  {  "name": "Spot" , "image_url": "http://example.com/spot.jpg" },
}

@app.route("/<slug>")
def get_puppy(slug):
    try:
        puppy= PUPPIES[slug]
    except:
        # 404 : Not found
        abort(404)
    return jsonify(puppy)
```

# How sqlachemy works. [[5m44s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=5m44s)]
* insert a puppy snippet

```python
from flask_sqlalchemy import SQLAlchemy
db=SQLAlchemy()

# create the table defininion
class Puppy(db.model):
    id = db.Column(..)
    sug = db.Column(..)
    name = db.Column(..)
    url_image = db.Column(..)

#insert dog in the table
p1=Puppy(slug="rover", name="Rover", image_url="http://example.com/rover.jpg")
db.add(p1)

## select Puppy
all=Puppy.query.all()
#or
spot=Puppy.query.filter(Puppy.slug=="spot").first()

## update Puppy
spot.image_url="http://example.com/spot_nicer.jpg"
# do not forget to commitc
db.session.add(spot)
db.session.commit()

## Delete
db.session.delete(spot)
db.session.commit()
```


# Integrate sqlachemy [[9m14s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=9m14s)]
 into flask.

* you have to create a module named ```models.py``` with the
```class Puppy(db.Mmodel)``` defined in it and the use it in your main app.py

```python
from models import db, Puppy
#…
app.config["SQLACHEMY_DATABASE_URI"]="squlite://puppy.db"
db.init_app(app)
#…
@app.route("/<slug>")
def get_puppy(slug):
    puppy= Puppy.query.filter(Puppy.slug==slug).first_or_404()
    output={"name", puppy.name, "image_url":puppy.img_url}
    return jsonify(output)
```

[[10m4s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=10m4s)] Do not forget to
initialize & seed the database.

[[11m25s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=11m25s)] Create puppy.

* use reqest to get an post response
```python
from flask import request
#
name=request.form.get("name")
```

* use slugify to create easyly slug name
```python
# within the bash: pip install python-slugify
from slugify import slugify
slug=slugify_name
```

* use url_for to define within the reponse the url for the get
```python
location=url_for("get_puppy", slug=slug)
resp.headers["Location"]=location
return resp
```
 * that way the reponse header will get a ```Location: http://localhost:5000/rover```

# Status [[12m45s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=12m45s)]
Good we have dynamic data, bad we have logic inside the APIs and our code is a bit verbose.


# Use flask-marshmallow [[13m15s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=13m15s)]
The way to automagically create an API based on the SQLAlchemy definition.

* let's create a ```schemas.py```
```python
from flask-marshmallow import Marshmallow
from models import Puppy
#
ma=Marshmallow()
#
class PuppySchema(ma.ModelShema):
    class Meta:
        model=Puppy
#
puppy_schema=PuppySchema()
puppies_schema=PuppySchema(many=True)
```

* now to do a get do
```python
form schemas import ma, puppy_schema
#
ma.init_app(app)
#
@app.route("/<slug>"):
def get_puppy(slug):
    puppy=Puppy.query.filter(Puppy.slug==slug).first_or_404()
    return puppy_schema.jsonify(puppy)
```

 * now to do a create. [[15m09s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=15m09s)]

```python
puppy, errors = puppy_schema.load(request.form)
if errors:
    resp=jsonify(errors)
    resp.status_code=400
    return resp
```

 * editing puppy is quite easy. Get the instance of puppy that you search for in the DB, load the post.

 * delete is also super easy

 * Do better handling [[16m38s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=16m38s)]
 of errors. In the presentation, we are now better handling the case were we delete
 twice the same record
 ```python
 @app.errorhandler(404)
 def page_no_found(error):
     resp=json(error)
     resp.status_code=404
     return resp
```

# Status with Flask Marshmallow [[17m53s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=17m53s)]
* good:
 * flexibility
 * validation
* bad
 * no way to track a *user session*

# Use flask-login [[18m05s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=18m05s)]

To do this, the user must have somehow an api-key each time it do request stuff.
That api-key will be present on the http request with a token ```Authorized: my-api-key```

* modify the models.py
```python
from flask_login import UserMixin
#
class User(db.Model, User.Mixin):
    id=db.Column(...)
    name=db.Column(...)
    api_key=db.Column(..., uniqe=True, index=True)
```

* modify the app.py to
```python
from flask_login import LoginManager
from models import db, User
#...
login_manager=LoginManager()
login_manager.init_app(app)#
#...
@login_manager.request_loader
def load_user_from_request(request):
    api_key=request.headers.get("Authorization")
    if not api_key:
        return None
    return User.query.filter_by(api_key=api_key).first()

```

* we get new feature such as : [[19m5s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=19m5s)]
 * is_authenticated
 * login_required: for sensitive api

# Not having the time to talk about [[20m10s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=20m10s)]
 * pagination
 * rate limiting
 * swagger documentation

# Question [[20m25s](https://www.youtube.com/watch?v=6RdZNiyISVUE#t=20m25s)]
 * Does the list is supported a list:
  * yes with ```many=True``` as a setup in marshmallow
 * Does flask support different type of DB
  * SQLAlchemy do this
 * Thought about flask-restful
  * ???
