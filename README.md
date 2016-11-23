# Bash-NetCat-HTTPD
Simple and small HTTP server in **Bash** with **NetCat**.
```bash
httpd.sh [PORT=8080 [ROOT_DIR=./]]
```

## Basic usage
Put **`httpd.sh`** file into directory with your files, and just run it.
```bash
./httpd.sh
```
By default script will open port **8080** and serve files.

### Custom port example
```bash
./httpd.sh 5000
```

### Custom port and directory example
```bash
./httpd.sh 5000 /home/user/my_project/
```


## More projects
Look at the www.promyk.doleczek.pl, maybe you will find another interesting thing :-)
