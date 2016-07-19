from the [video on flask at pycon 2015](https://www.youtube.com/watch?v=DIcpEg77gdE)


# setup the project
* requirement
```bash
# python3-virtualenv to create venv
# python3-dev as installing flask need to compile stuff against dev
apt install python3-virtualenv python3-dev
```
* create the virtualenv inside the project (13m40s)
```bash
mkdir my_project
cd my_project
python3 -m venv venv
```
* activate it
```
source venv/bin/activate
```
 * then you'll see on the prompt
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
* video start @ [@50m40s](https://www.youtube.com/watch?v=DIcpEg77gdE#t=50m40s)
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

# secret to avoid the Cross-Site Request Forgery attack
app.config['SECRET_KEY'] = 'secret!'

…

# the class that defined a form
class YesNoQuestionForm(Form):
    answer = RadioField('Your answer', choices=[('yes', 'Yes'), ('no', 'No')])
    submit = SubmitField('Submit')

…

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

# Game Logic:
* video start @ [1h47m](https://www.youtube.com/watch?v=DIcpEg77gdE#t=1h47m)
* ```git checkout v0.9```

The logic of the web application should reside in an other places. This is not
an web applicatio task. In this case, we will put in an other module. The module
is named *guessed.py*.
