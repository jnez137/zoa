module DATMAC
!       MACRO SPECIFIC INCLUDE FILE (SET FOR 999, 512 LINE MACROS)
!
        CHARACTER MACCW(0:1023)*8,MACQW(0:1023)*8,MACSTR(0:1023)*80

        CHARACTER FUNCW(1:10,0:1023)*8,FUNQW(1:10,0:1023)*8,            &
     &  FUNSTR(1:10,0:1023)*80,FNAMED(1:10)*8

                CHARACTER MAC_COM1*40
                COMMON/COM1_MAC/MAC_COM1

        COMMON/FFNNAA/FNAMED

!       IF AN ELEMENT IS TRUE, THE FUNCTION EXISTS, ELSE IT DOES NOT

!       NESFUN=TRUE IS A FUNCTION IS RUNNING AND FALSE IF A MACRO
!       IS RUNNING AT A PARTICULAR NESTING LEVEL.
        LOGICAL FUNEXT(0:10),NESFUN(0:10)

        COMMON/NSFUNC/NESFUN

        COMMON/FNEXIS/FUNEXT

        COMMON/FUN1/FUNCW,FUNQW,FUNSTR

        INTEGER MACSTA(1:20,0:1023),MAXLIN,FUNSTA(1:10,1:20,0:1023)

        COMMON/MXLIN/MAXLIN

        REAL*8 MACNW(1:5,0:1023),FUNNW(1:10,1:5,0:1023)

        COMMON/FUN2/FUNNW,FUNSTA

        COMMON/MACRO1/MACCW,MACQW,MACSTR

        COMMON/MACRO2/MACNW,MACSTA

!       MACRO DIRECTORY DATA

        INTEGER OLDIJ,CURLIN,TF(0:20),SSTEP(0:20)

        COMMON/TEEFF/TF,SSTEP

        COMMON/MCPAS2/OLDIJ,CURLIN

        CHARACTER MCDIR1(1:999)*8,MCDIR3(1:999)*20                      &
     &  ,FCDIR1(1:10)*8,FCDIR3(1:10)*20

        INTEGER MCDIR2(1:3,1:999),FCDIR2(1:3,1:10)

        COMMON/DIRMC1/MCDIR1,MCDIR3,FCDIR1,FCDIR3

        COMMON/DIRMC2/MCDIR2,FCDIR2

        CHARACTER ASORT(1:999)*8,BSORT(1:999)*8
        CHARACTER AISORT(1:999)*80,BISORT(1:999)*80

        COMMON/JK_ASRT1/ASORT,BSORT,AISORT,BISORT

!       MAXMAC IS THE MAXIMUM NUMBER OF MACROS IN THE MACRO DIRECTORY
!       THE VALUE IS SET IN PROGRAM.FOR

        INTEGER MAXMAC

        COMMON/MXMAC/MAXMAC

        CHARACTER MWQ(0:20)*8,MWS(0:20)*80,FMWQ*8,FMWS*80

        COMMON/MACWDS/MWQ,MWS,FMWQ,FMWS

        INTEGER MDF(0:20,1:5),MSQ(0:20),FMDF(1:5),FMSQ,MST(0:20),FMST

        REAL*8 MNW(0:20,1:5),FMNW(1:5),REG9(1:10)

      COMMON/REGINALD/REG9

        COMMON/MCNW/MNW,MDF,MSQ,FMNW,FMDF,FMSQ,MST,FMST

        LOGICAL NOEXTRACT,NOMEDIT,ORITEM

        COMMON/OWRITE/ORITEM

        COMMON/EXTRACTOR/NOEXTRACT,NOMEDIT

!     CONTROLS OUTPUT MESSAGE DISPLAY IN MMDEL.FOR

      LOGICAL MACSILENT

      SAVE MACSILENT


      LOGICAL RESOLVEIT
      COMMON/ITRESOLVE/RESOLVEIT

        INTEGER NESTIJ(0:20),NESTI(0:20),NEST,NESTER

        COMMON/MNEST/NEST,NESTI,NESTIJ

        COMMON/FESTER/NESTER


end module