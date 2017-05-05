# Captian's Log

## May 4 2017
Working on getting sage installed as a python 2.7 library. Here's the situation:

```
jenny@wrex ~/code/sage-7.6/src [git: master]
$ pip install --verbose .
Processing /home/jenny/code/sage-7.6/src
  Running setup.py (path:/tmp/pip-W3Vhcw-build/setup.py) egg_info for package from file:///home/jenny/code/sage-7.6/src
    Running command python setup.py egg_info
    ************************************************************************
    Traceback (most recent call last):
      File "<string>", line 1, in <module>
      File "/tmp/pip-W3Vhcw-build/setup.py", line 54, in <module>
        import sage.env
      File "sage/env.py", line 151, in <module>
        SINGULAR_SO = SAGE_LOCAL+"/lib/libSingular."+extension
    TypeError: unsupported operand type(s) for +: 'NoneType' and 'str'
    ************************************************************************
    Error building the Sage library
    ************************************************************************
Cleaning up...
Command "python setup.py egg_info" failed with error code 1 in /tmp/pip-W3Vhcw-build/
Exception information:
Traceback (most recent call last):
  File "/usr/local/lib/python2.7/dist-packages/pip-9.0.1-py2.7.egg/pip/basecommand.py", line 215, in main
    status = self.run(options, args)
  File "/usr/local/lib/python2.7/dist-packages/pip-9.0.1-py2.7.egg/pip/commands/install.py", line 324, in run
    requirement_set.prepare_files(finder)
  File "/usr/local/lib/python2.7/dist-packages/pip-9.0.1-py2.7.egg/pip/req/req_set.py", line 380, in prepare_files
    ignore_dependencies=self.ignore_dependencies))
  File "/usr/local/lib/python2.7/dist-packages/pip-9.0.1-py2.7.egg/pip/req/req_set.py", line 634, in _prepare_file
    abstract_dist.prep_for_dist()
  File "/usr/local/lib/python2.7/dist-packages/pip-9.0.1-py2.7.egg/pip/req/req_set.py", line 129, in prep_for_dist
    self.req_to_install.run_egg_info()
  File "/usr/local/lib/python2.7/dist-packages/pip-9.0.1-py2.7.egg/pip/req/req_install.py", line 439, in run_egg_info
    command_desc='python setup.py egg_info')
  File "/usr/local/lib/python2.7/dist-packages/pip-9.0.1-py2.7.egg/pip/utils/__init__.py", line 707, in call_subprocess
    % (command_desc, proc.returncode, cwd))
InstallationError: Command "python setup.py egg_info" failed with error code 1 in /tmp/pip-W3Vhcw-build/
```

Looks like either `SAGE_LOCAL` or `extension` isn't being populated. Line 93 in src/sage/env.py is supposed to populate it:
```
_add_variable_or_fallback('SAGE_LOCAL',      None) 
```

It's not defined anyway in the `src` subdirectory - but `SAGE_LOCAL` is mentioned a bunch in the `local` directory. Looks like it's supposed to be an environmental variable.
