        PROGRAM MAIN
C
        IMPLICIT NONE
C
        CHARACTER NAME(1:5000)*13,NUMBER(1:5000)*13,
     1  DUMMY*20,N*20
C
        INTEGER I,J,JJ
C
        DOUBLE PRECISION A0(1:5000),A1(1:5000),
     1  A2(1:5000),A3(1:5000),A4(1:5000),A5(1:5000)
C
        OPEN(UNIT=10,ACCESS='SEQUENTIAL',FILE='CORNIN.DAT',
     1  FORM='FORMATTED',STATUS='UNKNOWN')
        REWIND (UNIT=10)
                J=1
 50             READ(10,100) DUMMY
        IF(DUMMY.EQ.'EOS') THEN
                JJ=J-1
                GO TO 5000
                ELSE
                END IF
                READ(10,105) NAME(J)
                PRINT*,NAME(J),J
C
                READ(10,105) NUMBER(J)
                READ(10,100) N
        IF(N(1:1).EQ.'N') THEN
                A0(J)=0.0D0
                ELSE
        BACKSPACE(10)
        READ(10,120) A0(J)
 120    FORMAT(D20.10)
                END IF
                READ(10,100) N
        IF(N(1:1).EQ.'N') THEN
                A1(J)=0.0D0
                ELSE
        BACKSPACE(10)
        READ(10,120) A1(J)
                END IF
                READ(10,100) N
        IF(N(1:1).EQ.'N') THEN
                A2(J)=0.0D0
                ELSE
        BACKSPACE(10)
        READ(10,120) A2(J)
                END IF
                READ(10,100) N
        IF(N(1:1).EQ.'N') THEN
                A3(J)=0.0D0
                ELSE
        BACKSPACE(10)
        READ(10,120) A3(J)
                END IF
                READ(10,100) N
        IF(N(1:1).EQ.'N') THEN
                A4(J)=0.0D0
                ELSE
        BACKSPACE(10)
        READ(10,120) A4(J)
                END IF
                READ(10,100) N
        IF(N(1:1).EQ.'N') THEN
                A5(J)=0.0D0
                ELSE
        BACKSPACE(10)
        READ(10,120) A5(J)
                END IF
                READ(10,100) DUMMY
                J=J+1
                GO TO 50
 5000           CONTINUE
        PRINT*,'READ COMPLETE'
        CLOSE(UNIT=10,STATUS='KEEP')
        CALL WRITEKDPGLASSLIB('CORNIN.BIN', JJ, NAME, NUMBER, A0,
     1  A1, A2, A3,A4,A5)         
 100    FORMAT(A20)
 105    FORMAT(A13)
                STOP
                END
