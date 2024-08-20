
u can run Gunicorn by using commands or integrate with popular frameworks like Django, Pyramid, or TurboGears. For deploying Gunicorn in production see Deploying Gunicorn.

Commands
After installing Gunicorn you will have access to the command line script gunicorn.

gunicorn
Basic usage:

$ gunicorn [OPTIONS] [WSGI_APP]
Where WSGI_APP is of the pattern $(MODULE_NAME):$(VARIABLE_NAME). The module name can be a full dotted path. The variable name refers to a WSGI callable that should be found in the specified module.

Changed in version 20.1.0: WSGI_APP is optional if it is defined in a config file.

Example with the test app:

def app(environ, start_response):
    """Simplest possible application object"""
    data = b'Hello, World!\n'
    status = '200 OK'
    response_headers = [
        ('Content-type', 'text/plain'),
        ('Content-Length', str(len(data)))
    ]
    start_response(status, response_headers)
    return iter([data])
You can now run the app with the following command:

$ gunicorn --workers=2 test:app
The variable name can also be a function call. In that case the name will be imported from the module, then called to get the application object. This is commonly referred to as the “application factory” pattern.

def create_app():
    app = FrameworkApp()
    ...
    return app
$ gunicorn --workers=2 'test:create_app()'
Positional and keyword arguments can also be passed, but it is recommended to load configuration from environment variables rather than the command line.

Commonly Used Arguments
-c CONFIG, --config=CONFIG - Specify a config file in the form $(PATH), file:$(PATH), or python:$(MODULE_NAME).

-b BIND, --bind=BIND - Specify a server socket to bind. Server sockets can be any of $(HOST), $(HOST):$(PORT), fd://$(FD), or unix:$(PATH). An IP is a valid $(HOST).

-w WORKERS, --workers=WORKERS - The number of worker processes. This number should generally be between 2-4 workers per core in the server. Check the FAQ for ideas on tuning this parameter.

-k WORKERCLASS, --worker-class=WORKERCLASS - The type of worker process to run. You’ll definitely want to read the production page for the implications of this parameter. You can set this to $(NAME) where $(NAME) is one of sync, eventlet, gevent, tornado, gthread. sync is the default. See the worker_class documentation for more information.

-n APP_NAME, --name=APP_NAME - If setproctitle is installed you can adjust the name of Gunicorn process as they appear in the process system table (which affects tools like ps and top).

Settings can be specified by using environment variable GUNICORN_CMD_ARGS.

See Configuration Overview and Settings for detailed usage.

Integration
Gunicorn also provides integration for Django and Paste Deploy applications.

Django
Gunicorn will look for a WSGI callable named application if not specified. So for a typical Django project, invoking Gunicorn would look like:

$ gunicorn myproject.wsgi
Note This requires that your project be on the Python path; the simplest way to ensure that is to run this command from the same directory as your manage.py file.
You can use the –env option to set the path to load the settings. In case you need it you can also add your application path to PYTHONPATH using the –pythonpath option:

$ gunicorn --env DJANGO_SETTINGS_MODULE=myproject.settings myproject.wsgi
Paste Deployment
Frameworks such as Pyramid and Turbogears are typically configured using Paste Deployment configuration files. If you would like to use these files with Gunicorn, there are two approaches.

As a server runner, Gunicorn can serve your application using the commands from your framework, such as pserve or gearbox. To use Gunicorn with these commands, specify it as a server in your configuration file:

[server:main]
use = egg:gunicorn#main
host = 127.0.0.1
port = 8080
workers = 3
This approach is the quickest way to get started with Gunicorn, but there are some limitations. Gunicorn will have no control over how the application is loaded, so settings such as reload will have no effect and Gunicorn will be unable to hot upgrade a running application. Using the daemon option may confuse your command line tool. Instead, use the built-in support for these features provided by that tool. For example, run pserve --reload instead of specifying reload = True in the server configuration block. For advanced configuration of Gunicorn, such as Server Hooks specifying a Gunicorn configuration file using the config key is supported.

To use the full power of Gunicorn’s reloading and hot code upgrades, use the paste option to run your application instead. When used this way, Gunicorn will use the application defined by the PasteDeploy configuration file, but Gunicorn will not use any server configuration defined in the file. Instead, configure gunicorn.

For example:

$ gunicorn --paste development.ini -b :8080 --chdir /path/to/project
Or use a different application:

$ gunicorn --paste development.ini#admin -b :8080 --chdir /path/to/project
The only required argument to Gunicorn tells it how to load your application. The syntax is {module_import}:{app_variable}. module_import is the dotted import name to the module with your application. app_variable is the variable with the application. It can also be a function call (with any arguments) if you’re using the app factory pattern.

# equivalent to 'from hello import app'
$ gunicorn -w 4 'hello:app'

# equivalent to 'from hello import create_app; create_app()'
$ gunicorn -w 4 'hello:create_app()'

Starting gunicorn 20.1.0
Listening at: http://127.0.0.1:8000 (x)
Using worker: sync
Booting worker with pid: x
Booting worker with pid: x
Booting worker with pid: x
Booting worker with pid: x
The -w option specifies the number of processes to run; a starting value could be CPU * 2. The default is only 1 worker, which is probably not what you want for the default worker type.

Logs for each request aren’t shown by default, only worker info and errors are shown. To show access logs on stdout, use the --access-logfile=- option.

Binding Externally
Gunicorn should not be run as root because it would cause your application code to run as root, which is not secure. However, this means it will not be possible to bind to port 80 or 443. Instead, a reverse proxy such as nginx or Apache httpd should be used in front of Gunicorn.

You can bind to all external IPs on a non-privileged port using the -b 0.0.0.0 option. Don’t do this when using a reverse proxy setup, otherwise it will be possible to bypass the proxy.

$ gunicorn -w 4 -b 0.0.0.0 'hello:create_app()'
Listening at: http://0.0.0.0:8000 (x)
0.0.0.0 is not a valid address to navigate to, you’d use a specific IP address in your browser.

Async with gevent or eventlet
The default sync worker is appropriate for many use cases. If you need asynchronous support, Gunicorn provides workers using either gevent or eventlet. This is not the same as Python’s async/await, or the ASGI server spec. You must actually use gevent/eventlet in your own code to see any benefit to using the workers.

When using either gevent or eventlet, greenlet>=1.0 is required, otherwise context locals such as request will not work as expected. When using PyPy, PyPy>=7.3.7 is required.

To use gevent:

$ gunicorn -k gevent 'hello:create_app()'
Starting gunicorn 20.1.0
Listening at: http://127.0.0.1:8000 (x)
Using worker: gevent
Booting worker with pid: x
To use eventlet:

$ gunicorn -k eventlet 'hello:create_app()'
Starting gunicorn 20.1.0
Listening at: http://127.0.0.1:8000 (x)
Using worker: eventlet
Booting worker with pid: x
