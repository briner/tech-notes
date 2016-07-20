[TOC]


These are my notes of the [video on flask at pycon 2015](https://www.youtube.com/watch?v=DIcpEg77gdE) presented by Miguel GRINBERG


# setup the project
* requirement
```bash
# python3-virtualenv to create venv
# python3-dev as installing flask need to compile stuff against dev
apt install python3-virtualenv python3-dev
```
* create the virtualenv inside the project (13m40s)
```bash
git git clone https://github.com/miguelgrinberg/flask-pycon2015
mkdir flask-pycon2015
cd flask-pycon2015
python3 -m venv venv
```
* activate it
```
source venv/bin/activate
```
 * then you'll see on the prompt * debug=True will
  * show you the super awesome verkzeug debuger running within your web pages.

 ```bash
 (venv) root@uniroot@unixpriv3
 ```
* install flask (with proxy)
 ```bash
 pip --proxy="http://proxy.unige.ch:3128" install flask
 ```

# hello world
* first launch worked with parameter host="0.0.0.0" to bind to any adresses
```python
app.run(debug=True, host='0.0.0.0')
```

 * ```debug=True``` will :
   * show you the super awesome verkzeug debuger running within your web pages
   * restart the web server each time you modify your code (so you do not need to
      do this manually)


# add dynamic behaviour
* video start @ [@37m](https://www.youtube.com/watch?v=DIcpEg77gdE#t=37m)
* ```git checkout v0.2```

* snippet allow to pass parameter in the url
```python
@app.route('/guess/<int:id>')
def guess(id):
    return ('<h1>Guess the Language!</h1>'
            '<p>My guess: {0}</p>').format(guesses[id])
```

# make application accessible to other computer
* video start @ [44m28s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=44m28s)
* ```git checkout v0.3```

* snippet to change host and port
```python
app.run(host='0.0.0.0', port=5000, debug=True)
```

# templates with jinja
* video start @ [50m40s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=50m40s)
* ```git checkout v0.4```

* without argument
 * snippet
```python
@app.route('/')
def index():
    return render_template('index.html')
```

 * index.html
```html
<html>
    <head>
        <title>Guess the Language!</title>
    </head>
    <body>
        <h1>Guess the Language</h1>
        <p>Think of your favorite programming language. I'm going to try to guess it!</p>
        <p>Ready? Click <a href="#">here</a> to begin!</p>
    </body>
</html>
```

* with argument
 * snippet
```python
@app.route('/guess/<int:id>')
def guess(id):
    return render_template('guess.html', guess=guesses[id])
```
 * guess.html
```html
 <html>
    <head>
        <title>Guess the Language!</title>
    </head>
    <body>
        <h1>Guess the Language!</h1>
        <p>My guess: {{ guess }}</p>
    </body>
</html>
```

* miguel does create a ```templates``` dir in the main directory

# Create links between pages with "url_for"
* video start @ [58m35s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=58m35s)
* ```git checkout v0.5```

* do use ```url_for``` as in the templates index.html (or question.html). That way
we have a reference to an flask's route.
```html
<html>
    <head>
        <title>Guess the Language!</title>
    </head>
    <body>
        <h1>Guess the Language</h1>
        <p>Think of your favorite programming language. I'm going to try to guess it!</p>
        <p>Ready? Click <a href="{{ url_for('question', id=0) }}">here</a> to begin!</p>
    </body>
</html>
```

# Web Forms: add a form to the application
* video start @ [1h13m10s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=1h13m10s)
* ```git checkout v0.6```

When looking at the snippet, you will see that the decorator ```app.route``` has
a new arguments ```methods```. The *post* method is used when the user submit the
form, the *get* will render the forms.

* snippet on the app
```python
@app.route('/question/<int:id>', methods=['GET', 'POST'])
def question(id):
    if request.method == 'POST':
        if request.form['answer'] == 'yes':
            return redirect(url_for('question', id=id+1))
    return render_template('question.html', question=questions[id])
```

* snippet of question.html
```html
        <h1>Guess the Language!</h1>
        <p>{{ question }}</p>
        <form method="POST">
            <p>
                <input type="radio" name="answer" value="yes"> Yes<br>
                <input type="radio" name="answer" value="no"> No<br>
            </p>
            <input type="submit" value="Submit">
        </form>
```

# Web Forms: post-redirect-get pattern
* video start @ [1h25m30s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=1h25m30s)
* ```git checkout v0.7```
* requirement
```bash
# not really sure
pip install wtforms
```

Each post request must finished by a get request to avoid a display warning when
refreshing a page. That warning occur in the case you do a refresh when the last
action done was a post. In that case the browser is worried that the post will occur
twice. To avoid this, finish each post command with a redirect to a get.

* app snippet, by adding the post-redirect-get pattern line following
```python
def question(id):
    if request.method == 'POST':
        if request.form['answer'] == 'yes':
            return redirect(url_for('question', id=id+1))
        else:
            # post-redirect get-pattern
            return redirect(url_for('question', id=id))
    return render_template('question.html', question=questions[id])
```

# Web Forms: Using Flask-WTF and WTForms
* video start @ [1h28m48s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=1h28m48s)
* ```git checkout v0.8```

Do not trust what the user provides. Check what the user is boring and prone to
error. For that particular case use. It also provide a way to get protected against
the Cross-Site Request Forgery
([CSRF](https://fr.wikipedia.org/wiki/Cross-Site_Request_Forgery))

* app snippet
```python
from flask import Flask, render_template, redirect, url_for
from flask_wtf import Form
from wtforms.fields import RadioField, SubmitField
#
# secret to avoid the Cross-Site Request Forgery attack
app.config['SECRET_KEY'] = 'secret!'
#
# ...
#
# the class that defined a form
class YesNoQuestionForm(Form):
    answer = RadioField('Your answer', choices=[('yes', 'Yes'), ('no', 'No')])
    submit = SubmitField('Submit')
#
# ...
#
@app.route('/question/<int:id>', methods=['GET', 'POST'])
def question(id):
    form = YesNoQuestionForm()
    # validate_on_submit return True if data is submitted and if the data is valid
    if form.validate_on_submit():
        if form.answer.data == 'yes':
            return redirect(url_for('question', id=id+1))
        else:
            return redirect(url_for('question', id=id))
    return render_template('question.html', question=questions[id], form=form)
```

 * question.html snippet
 ```html
<h1>Guess the Language!</h1>
<p>{{ question }}</p>
<form method="POST">
    <!-- form.hidden_tag is hidden field used by the app.secret to avoid CSRF -->
    {{ form.hidden_tag() }}
    <p>
    {% for option in form.answer %}
        {{ option }} {{ option.label }}<br>
    {% endfor %}
    </p>
    {{ form.submit }}
</form>
<p>Click <a href="{{ url_for('index') }}">here</a> to end this game.</p>
```

For information ([2h12m30s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h12m30s))
we can modify the option on how a widget is displayed as they are in question.html of v0.11
```html
    <form method="POST">
        {{ form.hidden_tag() }}
        <p>{{ form.language.label }} {{ form.language(class="required", size=50) }} {% for error in form.language.errors %}[{{ error }}]{% endfor %}</p>
```

# Game Logic: add a module with the logic game
* video start @ [1h47m](https://www.youtube.com/watch?v=DIcpEg77gdE#t=1h47m)
* ```git checkout v0.9```

The logic of the web application should reside in an other places. This is not
an web applicatio task. In this case, we will put in an other module. The module
is named *guessed.py*.

Apart from this there is nothing special.

# Game Logic: implement the end of the game
* video start @ [1h58m55s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=1h58m55s)
* ```git checkout v0.10```

# Game Logic: implement the end of the game
* video start @ [1h58m55s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=1h58m55s)
* ```git checkout v0.10```

# Game Logic: Validate forms
* video start @ [2h9m7s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h9m7s)
* ```git checkout v0.11```

wtforms provides a large array of validators.

* app snnippet
```python
from wtforms.validators import Required
#
class LearnForm(Form):
    language = StringField('What language did you pick?',
                           validators=[Required()])
    question = StringField('What is a question that differentiates your '
                           'language from mine?', validators=[Required()])
    answer = RadioField('What is the answer for your language?',
                        choices=[('yes', 'Yes'), ('no', 'No')])
    submit = SubmitField('Submit')
```
* [[2h14m42s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h14m42s)] Even if we validate in the client, the server must validate it.

* [[2h15m45s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h15m45s)] Validate_forms as said before do:
 * check that there is data
 * check the data follows the validators attached to them :
```python
class LearnForm(Form):
    language = StringField('What language did you pick?',
                           validators=[Required()])
```

*  [[2h17m](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h17m)] Extend the template to show errors:
```html
    <form method="POST">
        {{ form.hidden_tag() }}
        <p>{{ form.language.label }} {{ form.language() }} {% for error in form.language.errors %}[{{ error }}]{% endfor %}</p>
        <p>{{ form.question.label }} {{ form.question() }} {% for error in form.question.errors %}[{{ error }}]{% endfor %}</p>
        <p>What is the answer to this question for your language?</p>
        <p>
        <!-- extend the template errors here --->
        {% for option in form.answer %}
            {{ option }} {{ option.label }}<br>
        {% endfor %}
        {% for error in form.answer.errors %}[{{ error }}]{% endfor %}
        </p>
        {{ form.submit }}
```

# User Sessions: Store game state in the user session
* video start @ [2h23m40s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h23m40s)
* ```git checkout v0.12```

flask create a dictionary per user which will allow to keep a session per user.
This will allow to keep for e.g. the state. In this section we will keep. The
cookie will be cryptographly signed to prevent it to be tampered.

* app snippet:
```python
# import session
from flask import Flask, render_template, redirect, url_for, session
```

[[2h28m30s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h28m30s)] A *flask-kvsession* extension allow to store the session information into a file or a
database and then the cookie will only store the *id* of record in the DB.

# Error Handling:
* video start @ [2h35m20s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h35m20s)
* ```git checkout v0.13```

How can we break what we've done.
 * go to an url that does not exists ```http://localhost:5000/not_a_good_url```
 * break the way that the engine works as we implement. For e.g. what if we put a
 new language *python* when we previously say that it was not *python*. The
 guess.py engine will ```raise GuessError()```. We have to manage such situation.

[[2h38m10s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h38m10s)] Debugger:
 Werkzeug show an enhanced stack trace error of python within the web browser,
 where you can:
 * Look the stack trace.
 * Look for each element of the stack the source.
 * Use a python console on that element to run/test python code.

[[2h42m25s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h42m25s)] Internal
Server Code (error code: 500). This page is not served by our application. So,
the look and the message error are a bit very short.

[[2h43m30s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h43m30s)] Let's treat
this error page within flask.

 * with the app snippet, using the``` GuessError``` class or the *error code*.
```python
@app.errorhandler(GuessError)
@app.errorhandler(404)
def runtime_error(e):
    return render_template('error.html', error=str(e))
```
 * and the error.html snippet
 ```html
<h1>Guess the Language!</h1>
<p>Error: {{ error }}</p>
<p>Click <a href="{{ url_for('index') }}">here</a> to begin a new game.</p>
```

# What's next
* video start @ [2h49m45s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=2h49m45s)

Go to the [Miguel GRINBERG blog](http://blog.miguelgrinberg.com/) to looks of the topic that should be investigated.

* Databases
* Authentication
 * [flask-login](https://flask-login.readthedocs.io/en/latest/https://flask-login.readthedocs.io/en/latest/) a very useful extension.
* HTML/CSS Styling
 * why not use [flask-bootstrap](http://pythonhosted.org/Flask-Bootstrap/http://pythonhosted.org/Flask-Bootstrap/) which nicely wrapp bootstrap
* Structure for large application
 * get a look at [the mega-tutorial](http://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world)
* Application Programming Interfaces (API)
 *  a web server that do not render web pages but only retun json data.
* Rich client applications (Angular, Ember, React...)
* Unit Testing
 * you can test as a web client the application.
* Logging
 * using the stock ```app.logger```
* Beyond HTTP: websocket
 * to allow to have a permanent connection between the client and the server.
 This allow to have an application more realtime.
* Deployment
 * the webserver should not use the python engine. Use NGNX or GUnicor or ??uwhiskey??

# Questions
* video start @ [3h0m50s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=3h0m50s)

* Blueprints
