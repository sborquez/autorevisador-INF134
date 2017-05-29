#!/usr/bin/python2
import sys
from time import sleep

tarea = sys.argv[1]
tarea = tarea.lower().replace("-",".").split(".")
for i in tarea:
    if "grupo" in i:
        index = i.find("grupo") + 5
        try:
            grupo=str(i[index])
            grupo+=str(i[index+1])
        except IndexError:
            print grupo
        else:
            if grupo[0] == "0":
                print grupo[1]
            else:
                print grupo
        break
