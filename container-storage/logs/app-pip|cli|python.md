```
# pip: package manager
# pipenv, poetry: project environment manager
# pipx: cli tool installer
```

> ## pip

- https://packaging.python.org/en/latest/tutorials/installing-packages/
  
```
# install packages using "pip install" inside a python virtual environment
sudo apt install python3-pip -y
```

```
python3 -m pip --version
```

> ## pipenv, poetry

> ## pipx

```
sudo apt install pipx -y

pipx install black # installs black globally
pipx run black --check # runs a temporary instance of black
pipx uninstall black # removes the global install
```
