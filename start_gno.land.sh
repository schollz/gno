#!/bin/bash

pkill -f 'build/gnoland'
pkill -f 'build/gnoweb'
rm -rf gno.land/testdir
cd gno.land && ./build/gnoland & 
sleep 5
cd gno.land && ./build/gnoweb -bind 0.0.0.0:8888 & 
sleep 2