from the [video on flask at pycon 2015]( https://www.youtube.com/watch?v=DIcpEg77gdE)


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
* first launch worked with parameter host="0.0.0.0" to bind to any adressesk
```python
app.run(debug=True, host='0.0.0.0')
```

# add dynamic behaviour (37m)
* ``` checkout v0.2```

* snippet allow to pass parameter in the url
```python
@app.route('/guess/<int:id>')
def guess(id):
    return ('<h1>Guess the Language!</h1>'
            '<p>My guess: {0}</p>').format(guesses[id])
```

# make application accessible to other computer (44m28s)
* ```git checkout v0.3```

* snippet to change host and port
```python
app.run(host='0.0.0.0', port=5000, debug=True)
```

# templates with jinja (50m40s)
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
