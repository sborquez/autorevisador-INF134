#!/bin/bash

# Revisador de tareas automatico
# Estructuras de Datos INF-134
# Sebastian Borquez

# Scripts de Python
comparar="comparator.py"
memocheck="memocheck.py"

# Directorio de .tar.gz's
dirc=$(pwd)


# Leyendo parametros
while [ -n "$1" ]
do
    case "$1" in
        -t) if [[ $2 =~ ^[1-6]$ ]]
            then
                tareaN="tarea$2"
            else
                echo "Argumento incorrecto: numero de tarea"
                exit 1
            fi
            shift;;
        -g) if [[ $2 =~ ^[1-9]$|^1[0-9]$|^2[0-8]$ ]
            then
                if [ $2 -lt 10 ]
                then
                    grupo="grupo0$2"
                else
                    grupo="grupo$2"
                fi
            else
                echo "Argumento incorrecto: grupo"
                exit 1
            fi
            shift;;
    esac
    shift
done

# Parametros dados?
if [ -z "$grupo"] || [ -z "$N" ]
then
    echo "Usar -t y -g"
    echo "Saliendo"
    exit 1
fi


# Print
clear
echo  -e "\tRevisador de tareas individual V0.1\n"
echo "Tarea: $tareaN"
echo "Grupo: $grupo"

# Creacion de informe
fecha=$(date +%T_%d-%m)
informe="$grupo-$tareaN-$fecha.txt" 
echo "Tarea:$tareaN" > $informe

# Buscar archivo y descomprimir
echo -n "Descomprimiendo $grupo-tarea$N.tar.gz ..."
echo -n "Descomprimiendo:" >> $informe
if tar xvzf "$grupo-$tareaN.tar.gz"   
then
    echo " OK"
    echo "Exitoso" >> $informe
else
    echo " FAIL"
    echo "Nombre archivo incorrecto" >> $informe
    echo "Debe extraer manualemente, continue luego de extraerlo."
    sleep 15
    echo -n "desea continuar?[Y]/[N](default): "
    read continuar
    if [[ $continuar =~ ^[Yy][eE]?[sS]?$ ]]
    then
        echo "Continuar"
    else
        echo "Saliendo"
        exit 0
    fi
fi

# Revisar basura
if [ 0 -ne $(ls -p | grep -v / | wc -l) ]
then
    echo "Hay archivos basura:"
    ls -p | grep -v /
    echo "Descuento:Hay archivos basura" >> $informe
fi
# Buscar carpeta
if [ -d "$tareaN-$grupo" ]
then
    echo "Carpeta correcta"
    echo "Carpeta:correcta" >> $informe
    cd "$tareaN-$grupo"
    # Revisar y borrar basura 2
    # TODO

else
    echo "No se encuentra la carpeta"
    echo "Descuento:No se encuentra la carpeta" >> $informe
    
    # Aun se puede probar?
    if [ 0 -ne $(ls | grep \.cpp$ | wc -l) ]
    then
        echo "Se continuara de todas formas"
    elif cd ./*
    then
        echo "Se continuara de todas formas en $(pwd)"
        # Revisar y borrar basura 2
        # TODO
        
    else
        echo "No se puede continuar"
        echo "Saliendo"
        exit 0
    fi 
fi

# Buscar Makefile
if [ ! -f "Makefile" ]
then
    echo "No hay Makefile"
    echo "Descuento:No hay Makefile"
    echo -n "Desea continuar? [Y]/[N](default): "
    read continuar
    if [[ $continuar =~ ^[Yy][eE]?[sS]?$ ]]
    then
        echo "Continuar"
    else
        echo "Saliendo"
        exit 0
    fi
fi

# Compilar
output_make=$(make $tareaN)
if [ $? -ne 0 ]
then
    echo "No se pudo compilar $tareaN"
    echo "Descuento:No compila $tareaN"
    echo "Debe compilar manualemente, continue luego de compilar $tareaN."
    sleep 15
    echo -n "desea continuar?[Y]/[N](default): "
    read continuar
    if [[ $continuar =~ ^[Yy][eE]?[sS]?$ ]]
    then
        echo "Continuar"
    else
        echo "Saliendo"
        exit 0
    fi
else
    # Revisar -Wall
    if [ $(echo $output_make | grep "Wall" -c |) -ne $(echo $output_make | grep "g++" -c) ]
    then
        echo "Compilacion sin Wall"
        echo "Descuento:Compilar sin Wall" >> $informe
        echo "Vuelva a compilar con Wall manualemente"
        sleep 15
    fi
fi

# Revisar Warnings
echo -n "Numero de warnings: "
read warns
echo "Warnings:$warns" >> $informe

# Probar inputs
for ( i = 1; i < 3; i++)
do
    echo "Ejecutando $tareaN con input$i ... "
    tempout=$(mktemp -t output.XXX)
    templog=$(mktemp -t logval.XXX)
    output =$(valgrind --leak-check=full -q --log-file=$templog ./$tareaN < input$i)
    echo $output >> $tempout
    echo -n "Revisando resultados ... "
    resultado=$($comparar "input$i" $tempout)
    echo $resultado
    echo "input$i:$resultado" >> $informe

    echo -n "Revisando memoria ... "
    memoria=$($memocheck $templog)
    
    echo $memoria
    echo "memoria:$memoria" >> $informe
    
    rm -f $tempout
    rm -f $templog
done

echo "Finalizado"
echo "Saliendo"