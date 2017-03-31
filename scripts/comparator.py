#!/usr/bin/python2
import sys

with open(sys.argv[1]) as output_esperado:
    data_esperada = output_esperado.read()
    data_esperada = data_esperada.strip().split()

with open(sys.argv[2]) as output_tarea:
    data_tarea = output_tarea.read()
    data_tarea = data_tarea.strip().split()

data_esperada = "".join(data_esperada)
data_tarea = "".join(data_tarea)
if data_esperada == data_tarea:
    print "Correcto"
else:
    print "Revisar"