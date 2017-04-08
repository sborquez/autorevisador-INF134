#!/usr/bin/python2
import sys

tarea = sys.argv[1]
tarea = tarea.lower().split(".")
for i in tarea:
    if "grupo" in i:
        index = tarea.find("grupo") + 5
        try:
            grupo=str(tarea[index])
            grupo+=str(tarea[index+1])
        except IndexError:
            print grupo
        else:
            if grupo[0] == "0":
                print grupo[1]
            else:
                print grupo
        break