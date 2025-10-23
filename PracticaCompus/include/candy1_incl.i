@;=== candy1_incl.i: definiciones comunes para ficheros en ensamblador  ===

@; Rango de los números de filas y de columnas -> mínimo: 3, máximo: 11
ROWS = 9
COLUMNS = 9

MASK_GEL = 22 //15+7 


OFFSET_COL=COLUMNS-1

INDEX_COL=COLUMNS-1
INDEX_ROWS=ROWS-1

ESTE=0
SUR=1
OESTE=2
NORTE=3

CAP_DIR=0
ESQUERRA=1
DRETA=2
DOS_DIR=3



MASK_CAR =0x07 
VALOR_CERO=0x0
VALOR_GEL =0x08  //8 en decimal
VALOR_GEL_DOBLE=0x10 //valor 16 en decimal

VALOR_SOLID= 0x07
VALOR_HUECO=0x0f //15 en decimal