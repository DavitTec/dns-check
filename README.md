# README

> Summary: [Basic project short summary goes here]

[Back](../README.md) 
---


## dns-check.sh

   Our simple Bash Script to check DNS names −

   ```bash
   #!/bin/bash 
   for name in $(cat $1);
      do 
         host $name.$2 | grep "has address" 
      done 
   exit
   ```

   small wordlist to test DNS resolution on −

   ```
   dns 
   www 
   test 
   dev 
   mail 
   rdp 
   remote
   ```

   ```
   ./dns-check.sh dns-names.txt google.com
   ```
