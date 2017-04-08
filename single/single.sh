#!/bin/bash

# Revisador de tareas automatico
# Estructuras de Datos INF-134
# Sebastian Borquez

# Scripts de Python
comparar="comparator.py"
memocheck="memocheck.py"

# flag
full=false

# Revisardor basura
function limpio {
    if [ 0 -ne $# ]
    then
        total=$(ls -p | grep -v -e "/$\|\.cpp$\|[mM]akefile\|\.h$\|\.hpp$\|README" | wc -l)
        if [ 0 -ne $total]
        then
            echo -e "\nHay archivos basura:"
            ls -p | grep -v -e "/$\|\.cpp$\|[mM]akefile\|\.h$\|\.hpp$\|README"
            echo "Descuento:Hay archivos basura" >> $1
            echo "Limpiando ..."
            rm $(ls -p | grep -v -e "/$\|\.cpp$\|[mM]akefile\|\.h$\|\.hpp$\|README")
        fi
    else
        return 1
    fi
}


# Leyendo parametros
while [ -n "$1" ]
do
    case "$1" in
        -g) if [[ $2 =~ ^[1-9]$|^1[0-9]$|^2[0-8]$ ]]
            then
                if [ $2 -lt 10 ]
                then
                    grupoXX="grupo0$2"
                else
                    grupoXX="grupo$2"
                fi
            else
                echo "Argumento incorrecto: grupo"
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

        -t) if [[ $2 =~ ^[1-6]$ ]]
            then
                tareaN="tarea$2"
            else
                echo "Argumento incorrecto: numero de tarea"
                exit 1
            fi
            shift;;

        -full)
            full=true
    esac
    shift
done

# Parametros dados?
if [ -z "$grupoXX" ] || [ -z "$tareaN" ] || [ -z "$inputs" ] || [ -z "$out_dir" ]
then
    echo "Usar -t, -g y -p"
    echo "Saliendo"
    exit 1
fi


# Print
clear
echo  -e "\tRevisador de tareas individual V0.1\n"
echo "Tarea: $tareaN"
echo "Grupo: $grupoXX"
echo "Inputs: $inputs"

# Creacion de informe
fecha=$(date +%T_%d-%m)
informe="$out_dir/$grupoXX-$tareaN-$fecha.txt" 
echo "Tarea:$tareaN" > $informe

# Buscar archivo y descomprimir
echo -e "\nDescomprimiendo $grupoXX-tarea$N.tar.gz"
echo -n "Descomprimiendo:" >> $informe
if tar xvzf "$grupoXX-$tareaN.tar.gz"   
then
    echo "Descomprimido"
    echo "Exitoso" >> $informe
else
    echo "FAIL"
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
if [ 0 -ne $(ls -p | grep -v -e "/$\|$grupoXX-$tareaN\.tar\.gz" | wc -l) ]
then
    echo -e "\nHay archivos basura:"
    ls -p | grep -v -e "/$\|$grupoXX-$tareaN\.tar\.gz"
    echo "Descuento:Hay archivos basura" >> $informe
    echo "Limpiando ..."
    rm $(ls -p | grep -v -e "/$\|$grupoXX-$tareaN\.tar\.gz")
fi

# Buscar carpeta
echo -e "\nBuscando carpeta $tareaN-$grupoXX/"
if [ -d "$tareaN-$grupoXX" ]
then
    echo "Carpeta correcta"
    echo "Carpeta:correcta" >> $informe
    cd "$tareaN-$grupoXX"
    # Revisar y borrar basura 2
    limpio $informe

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
        # Revisar y borrar basura
        limpio $informe
    else
        echo "No se puede continuar"
        echo "Saliendo"
        exit 0
    fi 
fi

# Buscar Makefile
echo -e "\nBuscando Makefile"
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
echo -e "\nCompilando"
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
    if [ $(echo $output_make | grep "Wall" -c ) -ne $(echo $output_make | grep "g++" -c) ]
    then
        echo "Compilacion sin Wall"
        echo "Descuento:Compilar sin Wall" >> $informe
        echo "Vuelva a compilar con Wall manualemente"
        sleep 15
    fi
fi

# Revisar Warnings
echo -e "Compilado\n"
echo -n "Numero de warnings: "
read warns
echo "Warnings:$warns" >> $informe

# Probar inputs
for (( i=1; i < 3; i++ ))
do
    echo "Ejecutando $tareaN con $inputs/input$i:"
    echo "Inputs:"
    cat $inputs/input$i

    tempout=$(mktemp -t output.XXX)
    templog=$(mktemp -t logval.XXX)
    valgrind --leak-check=summary --log-file=$templog ./$tareaN < $inputs/input$i >> $tempout
    
    echo -e "Output esperado:"
    cat "$inputs/output$i"
    
    echo "Output obtenido:"
    cat $tempout
   
    echo -e "\n"
    echo -n "Revisando resultados ... "
    resultado=$($comparar $inputs/output$i $tempout)
    echo $resultado
    
    if [ "Correcto" != $resultado ]
    then
        echo -n "Revise manualemente (0-50): "
        read resultado
    else
        resultado=50
    fi
    echo "input$i:$resultado" >> $informe

    echo -n "Revisando memoria ... "
    memoria=$($memocheck $templog)
    
    echo $memoria
    echo "memoria:$memoria" >> $informe
    
    rm -f $tempout
    rm -f $templog
done

if $full
then
    echo "Revision completa"
    echo "README"
    echo "README" >> $informe
    echo "Abra README"
    sleep 2

    echo "Evaluacion"
    echo "Evaluacion" >> $informe
    echo -n "Nombres(10): "
    read lee
    echo "Nombres:$lee" >> $informe
    echo -n "Supuestos(10): "
    read lee
    echo "Supuestos:$lee" >> $informe
    echo -n "Tiempo(20): "
    read lee
    echo "Tiempo:$lee" >> $informe
    echo -n "Grupo(30): "
    read lee
    echo "Grupo:$lee" >> $informe
    echo -n "Dificultades(30): "
    read lee
    echo "Dificultades:$lee" >> $informe

    echo "Descuentos extras"
    echo "Descuentos extras" >> $informe
    echo -n "Estructura incorrecta(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Estructura incorrecta" >> $informe
    fi
    echo -n "Errores ortograficos readme(cantidad): "
    read lee
    if [ 0 -ne $lee ]
    then
        echo "Descuento:Errores ortograficos:$lee" >> $informe
    fi
    echo -e "\nEntrega"
    echo -n "Atraso(cantidad): "
    read lee
    if [ $lee -ne 0]
    then
        echo "Descuento:Atraso:$lee" >> $informe
    fi
    echo -n "Entrega repetida (s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Entrega repetida" >> $informe
    fi
    echo -e "\nCodigo"
    echo "Abra archivos fuentes"
    sleep 4
    echo -n "Codigo sin citar(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Codigo sin citar" >> $informe
    fi
    echo -n "Copia(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:copia" >> $informe
    fi
    echo -n "Mala identacion(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Mala identacion" >> $informe
    fi
    echo -n "Mala uso de llaves(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Mal uso de llaves" >> $informe
    fi
    echo -n "Mala uso de comentarios(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Mal uso comentarios" >> $informe
    fi
    echo -n "Tildes(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:No ascii" >> $informe
    fi
    echo -n "Errores ortograficos codigo(cantidad): "
    read lee
    if [ $lee -ne 0 ]
    then
        echo "Descuento:Errores ortograficos codigo:$lee" >> $informe
    fi
    echo -n "Uso de no std(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Bibliotecas no std" >> $informe
    fi
    echo -n "Mal uso de tipos de datos(cantidad): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Mal uso de tipos de datos:$lee" >> $informe
    fi
    echo -n "Variables no representativas(s|n): "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:Variables no representativas" >> $informe
    fi
    echo -n "Variables globales: "
    read lee
    if [[ $lee == "s" ]]
    then
        echo "Descuento:variables globales" >> $informe
    fi
    echo -n "Comentarios adicionales: "
    read lee
    echo -e "\n\nComentarios adicionales"
    echo $lee >> informe
fi

cd ..
rm "$tareaN-$grupoXX/" -r
echo -e "\n\n\tResultados:"
cat "$informe"

sleep 1
echo -e "\nFinalizado\nSaliendo"
