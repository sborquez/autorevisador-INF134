#!/bin/bash

id_grupo="grupo.py"

# Leyendo parametros
while [ -n "$1" ]
do
    case "$1" in
        
        -d) if [ -d $2 ]
            then
                dir_root="$2"
            else
                echo "Argumento incorrecto: directorio tareas"
                exit 1
            fi
            shift;;

        -t) if [[ $2 =~ ^[1-6]$ ]]
            then
                N=$2
            else
                echo "Argumento incorrecto: numero de tarea"
                exit 1
            fi
            shift;; 

        -o) if [ -d $2 ]
            then
                out_dir="$2"
            else
                echo "Argumento incorrecto: directorio informe"
                exit 1
            fi
            shift;;

        -p) if [ -d $2 ]
            then
                inputs="$2"
            else
                echo "Argumento incorrecto: directorio pruebas"
                exit 1
            fi
            shift;;
    esac
    shift
done

# Parametros dados?
if [ -z "$N" ] || [ -z "$inputs" ] || [ -z "$out_dir" ] || [ -z "$dir_root" ]
then
    echo "Usar -t, -d, -o y -p"
    echo "-t: numero tarea."
    echo "-d: directorio donde se encuentran las tareas."
    echo "-o: directorio donde quedarán los informes."
    echo "-p: directorio donde se encuentran inputs y outputs."
    echo "Saliendo"
    exit 1
fi

if [ -d "$dir_root/run" ]
then
    echo "Eliminando directorio"
    rm -rf "$dir_root/run"
fi


for tarea_grupo in $(ls | grep \.tar\.gz)
do
    mkdir "$dir_root/run"
    cp "./$tarea_grupo" "$dir_root/run/"
    grupo=$($id_grupo $tarea_grupo)
    echo $grupo
    cd "$dir_root/run/"
    single -t $N -g $grupo -d "$dir_root/run" -p "$inputs" -o "$out_dir" -full
    cd ..
    rm -rf "$dir_root/run"
done
