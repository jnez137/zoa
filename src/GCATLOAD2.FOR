        SUBROUTINE GCATLOAD2(CATLIST,CVALUE)
        IMPLICIT NONE
        INCLUDE 'DATMAI.INC'
        INCLUDE 'DATLEN.INC'
        INTEGER I,CATLIST
        CHARACTER*132 LINE,CVALUE*80
        INPUT='OUT ED'
        CALL PROCES
        INPUT='GLASSP '//CVALUE(1:27)
        CALL PROCES
        INPUT='OUT TP'
        CALL PROCES
        CALL CLOSE_FILE(9,1)
        OPEN(UNIT=9,ACCESS='SEQUENTIAL',BLANK='NULL'
     1  ,FORM='FORMATTED',FILE='EDITTEXT.DAT'
     2  ,STATUS='UNKNOWN')
        REWIND(9)
        I=1
        I=1
 1      READ(9,25,ERR=90,END=90) LINE
        CATARRAY(I)=LINE(1:50)
        I=I+1
        GO TO 1
 90     CONTINUE
        CALL CLOSE_FILE(9,0)
 25     FORMAT(A132)
        CATLIST=I-1
        RETURN
        END
