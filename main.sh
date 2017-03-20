#!/bin/bash

# Revisador de tareas automatico
# Estructuras de Datos INF-134
# Sebastian Borquez

# Scripts de Python
comparar="./comparator.py"
memocheck="./memocheck.py"

# Directorio de .tar.gz's
dirc=$(pwd)

# Directorio de pruebas
pruebas=$dirc

# Directorio de output
output=$dirc

# Tarea
N=0

# Leyendo parametros
while [ -n "$1" ]
do
    case "$1" in
        -d) if [ -d $2 ]
            then
                dirc="$dirc/$2"
            else
                echo "$dirc/$2 no es un directorio valido."
            fi
            shift;;
        -i) if [ -d $2 ]
            then
                pruebas="$pruebas/$2"
            else
                echo "$pruebas/$2 no es un directorio valido."
            fi
            shift;;
        -o) if [ -d $2 ]
            then
                output="$2"
            else
                echo "$output/$2 no es un directorio valido."
            fi
            shift;;
        -n) N=$2
            shift;;
        *) echo "$1 not option";;
    esac
    shift
done


# Cantidad de grupos
if [ $N -eq 0 ] 
then
    echo "Utilice -n N para indicar la tarea."
    echo "Saliendo."
    exit 126
fi

tareas=$(ls | grep .tar.gz | wc -l)
if [ $tareas -eq 0 ]
then
    echo "Directorio sin tareas."
    echo "Saliendo."
    exit 126
fi

# Print
clear
echo  -e "\tRevisador de tareas V0.1\n"
echo "Tarea $N"
echo "Directorio de pruebas: $pruebas"
echo "Directorio de tareas: $dirc"                
echo "Directorio de resumenes: $output"
echo  -e "Cantidad de grupos: $tareas \n"

# Creacion de informe
informe="$output/informe_tarea$N.txt" 
echo "Tarea $N" > $informe
date >> $informe
echo -e "Grupos: $tareas\n\n" >> $informe

# Revisar cada tarea
revisados=0
while [ $tareas -ne $revisados ]
do
    revisados=$[$revisados + 1]
    if [ $revisados -lt 10 ]
    then
        grupo="grupo0$revisados"        
    else
        grupo="grupo$revisados"
    fi
    
    # Escribir en el informe
    echo "Grupo $grupo:" >> $informe

    # Descomprimir tareas
    echo -n "Descomprimiendo $grupo-tarea$N.tar.gz ..."
    tar xvzf "$grupo-tarea$N.tar.gz"

    # Revisar si se descomprimio correctamente
    if [ -d "$dirc/tarea$N-$grupo" ]
    then
        echo -e "\tnombre carpeta correcto"
        echo "Nombre carpeta correcto" >> $informe

        # Compilar
        echo -n "Compilando..."
        make_out=$(make "tarea$N" -C "$dirc/tarea$N-$grupo")
        if [ $? -eq 0 ]
        then
            echo -e "t\compilacion correcta"
            # Revisar -Wall
            if [ $(echo $make_out | grep "Wall" -c) -ne $(echo $make_out | grep "g++" -c) ]
            then
                echo "Revisar -Wall flags en Makefile"
                echo "Revisar -Wall flags en Makefile" >> $informe
            fi
            # Revisar Warnings
            echo -n "Numero de warnings: "
            read warns
            echo "Warnings: $warns" >> $informe 

            # Ejecutar
            for prueba in $(ls $pruebas/ | grep input)
            do
                echo "Ejecutando tarea con $prueba..."
                tempout=$(mktemp -t output.XXX)
                templog=$(mktemp -t logval.XXX)
                output=$(valgrind --leak-check=full -q --log-file=$templog $dirc/tarea$N-$grupo/tarea$N < $pruebas/$prueba)
                echo $output > tempout

                echo "Revisando resultados..."
                echo -n "Resultado en $prueba: "> $informe
                python $comparar $pruebas/$prueba.out $tempout > $informe

                echo -n "Uso de memoria con $prueba: "> $informe
                python $memocheck $templog > $informe 
                
                rm -f $tempout
                rm -f $templog
            done

        else
            # Revisar Warnings
            echo -n "Numero de warnings: "
            read warns
            echo "Warnings: $warns" >> $informe 

            echo -e "Problemas con Makefile\nRevisar manualemente"
            echo -e "Problemas con Makefile\nRevisar manualemente\n" >> $informe
        fi

    else
        echo -e "Nombre carpeta incorrecto\nRevisar manualemente"
        echo -e "Nombre carpeta incorrecto\nRevisar manualemente\n" >> $informe
    fi

done