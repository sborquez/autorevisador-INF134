#!/bin/bash

if [ "$1" = "-remove" ] || [ "$1" = "-r" ]
then
    echo "Se eliminaran los ejecutables"

    rm -f "$HOME/bin/single"
    echo -e "\t$HOME/bin/single eliminado"
    rm -f "$HOME/bin/multi"
    echo -e "\t$HOME/bin/multi eliminado"
    rm -f "$HOME/bin/comparator.py"
    echo -e "\t$HOME/bin/comparator.py eliminado"
    rm -f "$HOME/bin/memocheck.py"
    echo -e "\t$HOME/bin/memocheck.py eliminado"    
    rm -f "$HOME/bin/grupo.py"
    echo -e "\t$HOME/bin/grupo.py eliminado"    

elif [ -z "$1" ]
then
    if [ ! -d "$HOME/bin" ]
    then
        echo "No existe $HOME/bin"
        echo "Creando $HOME/bin"
        mkdir "$HOME/bin"
    fi

    dir=$(pwd)
    echo "Dando permisos de ejecucion:"
    echo -e "\t$dir/single/single.sh"
    chmod u+x "$dir/single/single.sh"
    echo -e "\t$dir/multi/multi.sh"
    chmod u+x "$dir/multi/multi.sh"

    echo -e "\t$dir/scripts/memocheck.py"
    chmod u+x "$dir/scripts/memocheck.py"

    echo -e "\t$dir/scripts/comparator.py"
    chmod u+x "$dir/scripts/comparator.py"
    
    echo -e "\t$dir/scripts/grupo.py"
    chmod u+x "$dir/scripts/grupo.py"

    echo "Creando links en $HOME/bin"
    ln -s "$dir/single/single.sh" "$HOME/bin/single"
    ln -s "$dir/multi/multi.sh" "$HOME/bin/multi"
    ln -s "$dir/scripts/memocheck.py" "$HOME/bin/memocheck.py"
    ln -s "$dir/scripts/comparator.py" "$HOME/bin/comparator.py"
    ln -s "$dir/scripts/grupo.py" "$HOME/bin/grupo.py"

    echo -e "\nAhora puede utilizar multi para revisar varias tareas:"
    echo -e "\tmulti -t (1-6) -d (dir tareas) -p (dir pruebas) -o (dir informe)"
    echo -e "\nO puede utilizar single para revisar una tarea:"
    echo -e "\tsingle -t (1-6) -g (1-28) -p (dir pruebas) -o (dir informe) [-full]"
else
    echo "Argumento invalido $1"
fi
