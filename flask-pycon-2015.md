from the [video on flask at pycon 2015]( https://www.youtube.com/watch?v=DIcpEg77gdE)


# setup the project
* requirement
```bash
# python3-virtualenv to create venv
# python3-dev as installing flask need to compile stuff against dev
apt install python3-virtualenv python3-dev
* create the virtualenv inside the project (13m40)
```bash
mkdir my_project
cd my_project
python3 -m venv venv
```
* activate it
```
# requirement
apt install python3-virtualenv
source venv/bin/activate
```
 * then you'll see on the prompt
 ```bash
 (venv)...
 ```
 * install flask (with proxy)
 ```bash
 pip --proxy="http://proxy.unige.ch:3128" install flask
 ```
