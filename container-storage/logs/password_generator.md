
```
# Random numbers added to a password.
pass="mypassword$RANDOM$RANDOM"; echo $pass 

# A simple linear random number generator, not strongly random. Generates a password with only lowercase letters (a-f).
pass=$(md5sum <<< $(($RANDOM * $RANDOM))); echo $pass

# This method is considered good enough to generate a password of any desired length, such as 20 characters, consisting only of alphanumeric characters. It includes all alphabetic characters.
pass=$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20); echo $pass

# A secure way to generate a password.
pass=$(cat /dev/random | tr -dc '[:alnum:]' | head -c 20); echo $pass
```

```
# Another option.
pass=$(openssl rand -base64 20 | head -c 20); echo $pass
```

https://stackoverflow.com/questions/55659819/bash-generate-secure-password-with-no-special-characters
