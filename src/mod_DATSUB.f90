module DATSUB

    !
!       VARIABLES
!     MAXVB IS MAXIMUM NUMBER OF VARIABLES IN OPTIM
!     MAXTVB IS MAXIMUM NUMBER OF TOLERANCE VARIABLES
!     MAXCMP IS MAXIMUM NUMBER OF COMPENSATORS
    INTEGER TVBCNT,CMPCNT,VBCNT,MAXVB,DELVAL,DELTAG,MAXTVB,MAXCMP
    REAL*8 VARABL(1:100000,1:17)
!
!     TOLER TRACKS COMPUND TOLERANCE VALUES AS THEY CAN'T BE TRACKED IN THE
!     LENS ARRAY
!
  REAL*8 TOLER(1:60,0:499)
  COMMON/TOLCOM/TOLER

  INTEGER OPCALC_TYPE

  COMMON/OPTYPE/OPCALC_TYPE

  LOGICAL OPOK,ISCRIT(1:10)

  COMMON/ISYCRIT/ISCRIT

  LOGICAL ISCOMP(1:10)

  COMMON/COMPIS/ISCOMP

  LOGICAL ISTOP(1:10)

  COMMON/ISYTOP/ISTOP

!       VARIABLES COMMON
    COMMON/SUBPS3/MAXVB,VBCNT,VARABL,DELTAG,DELVAL,TVBCNT,CMPCNT &
  ,MAXTVB,MAXCMP

!       MERIT (OPERANDS)
    LOGICAL OPEXST,FUNCL1,FUNCL2,FUNCL3,FUNCL4,FUNCL5 &
    ,FUNCL6,FUNCL7,FUNCL8,FUNCL9,FUNCL10,FUNCL11,FUNCL12,FUNCL13 &
  ,FUNCL14,FUNCL15,FUNCL16,FUNCL17,FUNCL18,FUNCL19,FUNCL20
    COMMON/FNCALC/FUNCL1,FUNCL2,FUNCL3,FUNCL4,FUNCL5,FUNCL6,FUNCL7 &
    ,FUNCL8,FUNCL9,FUNCL10,FUNCL11,FUNCL12,FUNCL13,FUNCL14,FUNCL15 &
  ,FUNCL16,FUNCL17,FUNCL18,FUNCL19,FUNCL20
    COMMON/OPBOOL/OPEXST
!
  INTEGER MAXOPT,MAXREG
  COMMON/REGMAX/MAXOPT,MAXREG
!
!     MAXOPT IS MAXIMUM NUMBER OF OPERANDS IN OPTIM
!     MAXTOP IS MAXIMUM NUMBER OF TOLERANCE OPERANDS
!     MAXFOCRIT IS MAXIMUM NUMBER OF FOCUS CRITERIA OPERANDS
!
  INTEGER TOPCNT,FCCNT,OPCNT,DELOP,CORMOD,MAXTOP,MAXFOCRIT
!
!     DINCRS
  REAL*8 DINC1,DINC2,DINC3,DINC4,DINC5A,DINC5B &
  ,DINC6A,DINC6B,DINC7A,DINC7B,DINC8A,DINC8B,DINC9A,DINC9B &
  ,DINC10A,DINC10B,DINC11A,DINC11B,DINC12A,DINC12B,DINC13A,DINC13B &
  ,DINC14A,DINC14B,DINC15,DINC16,DINC17,DINC18A,DINC18B,DINC19A &
  ,DINC19B,DINC20A,DINC20B,DINC21A,DINC21B,DINC22,DINC23,DINC24 &
  ,DINC25,DINC26,DINC27,DINC28,DINC29,DINC30,NSSDINC(1:300)
  COMMON/DINKY/DINC1,DINC2,DINC3,DINC4,DINC5A,DINC5B &
  ,DINC6A,DINC6B,DINC7A,DINC7B,DINC8A,DINC8B,DINC9A,DINC9B &
  ,DINC10A,DINC10B,DINC11A,DINC11B,DINC12A,DINC12B,DINC13A,DINC13B &
  ,DINC14A,DINC14B,DINC15,DINC16,DINC17,DINC18A,DINC18B,DINC19A &
  ,DINC19B,DINC20A,DINC20B,DINC21A,DINC21B,DINC22,DINC23,DINC24 &
  ,DINC25,DINC26,DINC27,DINC28,DINC29,DINC30,NSSDINC

!     DELTT'S
  REAL*8 &
  DELTT1,DELTT1A,DELTT2,DELTT2A,DELTT3,DELTT4,DELTT5A, &
  DELTT6A,DELTT7A,DELTT8A,DELTT9A,DELTT10A,DELTT11A,DELTT12A, &
  DELTT13A,DELTT14A,DELTT5B,DELTT6B,DELTT7B,DELTT8B,DELTT9B, &
  DELTT10B,DELTT11B,DELTT12B,DELTT13B,DELTT14B,DELTT15,DELTT16, &
  DELTT15A,DELTT16A,DELTT17,DELTT18A,DELTT19A,DELTT20A,DELTT21A, &
  DELTT18B,DELTT19B,DELTT20B,DELTT21B,DELTT29, &
  DELTT22,DELTT23,DELTT24,DELTT25,DELTT26,DELTT27,DELTT28
  COMMON/DLLTTAA/ &
  DELTT1,DELTT1A,DELTT2,DELTT2A,DELTT3,DELTT4,DELTT5A, &
  DELTT6A,DELTT7A,DELTT8A,DELTT9A,DELTT10A,DELTT11A,DELTT12A, &
  DELTT13A,DELTT14A,DELTT5B,DELTT6B,DELTT7B,DELTT8B,DELTT9B, &
  DELTT10B,DELTT11B,DELTT12B,DELTT13B,DELTT14B,DELTT15,DELTT16, &
  DELTT15A,DELTT16A,DELTT17,DELTT18A,DELTT19A,DELTT20A,DELTT21A, &
  DELTT18B,DELTT19B,DELTT20B,DELTT21B, &
  DELTT22,DELTT23,DELTT24,DELTT25,DELTT26,DELTT27,DELTT28,DELTT29
!
  REAL*8 OPERND(1:100000,1:20),OLDOP(1:100000,1:20),CURFIG
!
  CHARACTER VARNAM(1:100000)*8,OPNAM(1:100000)*8, &
  FUNNAM(0:10)*6,CORNAM*3 &
  ,OPERDESC(1:100000)*80
!
!       VARIABLE NAMES COMMON
    COMMON/VBNMCM/VARNAM
!
!       MERIT COMMON
    COMMON/SUBPS5/OPCNT,OPERND,DELOP,CORMOD,OLDOP,CURFIG &
  ,TOPCNT,FCCNT,MAXTOP,MAXFOCRIT
    COMMON/SUBPS6/OPNAM,FUNNAM,CORNAM
    COMMON/DESCRY/OPERDESC
!
!     AUXILLIARY CFG ARRAYS FOR USE WITH AUTO
  INTEGER OPNNM,CFADD(1:410,1:9),AUXMAX,VBCFG,LASCFG
  LOGICAL ULON,USON
  REAL*8 CFVAL(1:410,1:2)
  CHARACTER CFCHAR(1:410,1:2)*23
  COMMON/AUXCF1/CFVAL,CFADD,AUXMAX,VBCFG,LASCFG
  COMMON/AUXCF2/CFCHAR
  COMMON/AUXCF3/ULON,USON
!
  LOGICAL FMTFLG,JK_CHMODE
  REAL*8 FMTFMT,OLDFMT,OOLDFMT
  COMMON/MODECH/JK_CHMODE
  COMMON/FMTT1/FMTFLG
  COMMON/FMTT2/FMTFMT,OLDFMT,OOLDFMT
!
!     THE FIRST ENTRY IS THE ROW ENTRY, EACH ROW IS USED FOR A
!     DIFFERENT OPERAND
!     THE SECOND ENTRY IS THE COLUMN ENTRY, EACH COLUMN IS USED FOR A
!     DIFFERENT VARIABLE
!
!     DERSIZ IS EQUAL TO THE MAXIMUM VALUE OF OPCNT AND VBCNT
  INTEGER DERSIZ
!
  LOGICAL SOLEXT,DEREXT,CFCH,OPTMES,FMTEXT
!
  COMMON/MESOPT/OPTMES
!
!     DERIVATIVE COMMON BLOCK
  COMMON/DERDER/DERSIZ
  COMMON/DEEXIS/SOLEXT,DEREXT,CFCH,FMTEXT
!
!     KEEPS THE LAST CHANGE VECTOR LENGTH
  REAL*8 LCVLCV
!
  COMMON /VCLVCL/LCVLCV

  INTEGER DMP,ODMP
  COMMON/DMPDMP/DMP,ODMP

!     PFIND VARIABLES
!     PFIND DEFAULT VALUES
  REAL*8 PFDELA,PFDELM
  INTEGER PFNUM,MAXFAIL
  COMMON/FINDER/PFDELA,PFDELM,MAXFAIL,PFNUM
!     INITIAL VALUES SET IN PROGRAM.FOR ARE:
!              PFDEL=0.6D0
!              MAXFAIL=10
!              PFNUM=10
!
!     RAYS AND FIELDS FOR OPTIMIZATION
!
  REAL*8 FIELDX(1:200),FIELDY(1:200),FIELDZ(1:200) &
  ,FIELDW(1:200),RAYX(1:5000),RAYY(1:5000),RAYW(1:5000)
!
  COMMON/FRS/FIELDX,FIELDY,FIELDZ,FIELDW,RAYX,RAYY,RAYW
!
!     POWELL STUFF

  INTEGER IPMVAR

  REAL*8 IPVAR,IPFMT

  COMMON/IPFUNKY/IPVAR,IPFMT,IPMVAR

!     TRACKS NON-CALCULABLE OPERANDS IN OPTIM
  INTEGER BAAD
  COMMON/NOCALOP/BAAD

!     MODEFLAG IS SET TRUE IF CORMOD EXPLICITLY SET BY USER
!     IN UPDATE MERIT, MODEFLAG IS SET TRUE ELSE IT IS FALSE
  LOGICAL MODEFLAG
  COMMON/MULDER/MODEFLAG

  LOGICAL BADOPS

  COMMON/OPSBAD/BADOPS

!     DILITCNT KEEPS TRACK OF WHETHER OR NOT THE FIRST SET OF DERIVATIVES
!     EXIST.
  INTEGER DILITCNT
!
  COMMON/DILWORTH/DILITCNT
!
!     TVAR LEVEL PIVOT POSITIONS FOR STILT(A, B OR G)
!     AND BTILT(A, B OR G COMMANDS
  REAL*8 ASTILTXP,ASTILTYP,ASTILTZP
  REAL*8 BSTILTXP,BSTILTYP,BSTILTZP
  REAL*8 GSTILTXP,GSTILTYP,GSTILTZP
  REAL*8 ABTILTXP,ABTILTYP,ABTILTZP
  REAL*8 BBTILTXP,BBTILTYP,BBTILTZP
  REAL*8 GBTILTXP,GBTILTYP,GBTILTZP
  COMMON/ASTILTPIV/ASTILTXP,ASTILTYP,ASTILTZP
  COMMON/BSTILTPIV/BSTILTXP,BSTILTYP,BSTILTZP
  COMMON/GSTILTPIV/GSTILTXP,GSTILTYP,GSTILTZP
  COMMON/ABTILTPIV/ABTILTXP,ABTILTYP,ABTILTZP
  COMMON/BBTILTPIV/BBTILTXP,BBTILTYP,BBTILTZP
  COMMON/GBTILTPIV/GBTILTXP,GBTILTYP,GBTILTZP
!
!       SET UP DEFAULT MERIT FUNCTION CONDITIONS
!       DFGRID=1 (HEX) OR =2 FOR (RECT)
!               DFGRID=1
!               DFDEL=0.385
!               DFSEC=8
!               DFRIN=1
!     DEFAULT AUTO STUFF FOR AUTO GENERATION OF OPERANDS 12/7/99
  INTEGER DFPNUMB,DFWAVENUMB,DFTYPENUMB,DF_CFG,DFGRID,DFSEC,DFRIN
  REAL*8 DFWT1,DFWT2,DFWT3,DEFAULT_FOB(1:4,1:25),DFDEL
  COMMON/DEFAUTO/DFDEL,DFPNUMB,DFWAVENUMB,DFTYPENUMB,DFWT1 &
  ,DFWT2,DFWT3,DEFAULT_FOB,DF_CFG,DFGRID,DFSEC,DFRIN
!
    LOGICAL CHROMATIC
    COMMON/MONOCHROME/CHROMATIC
!
!       GLOBAL LIMITS ON TH AND RD VARIABLES IN OPTIMIZATION
    REAL*8 THMINLIM,THMAXLIM,RDNEGLIM,RDPOSLIM
    COMMON/LIMITORS/THMINLIM,THMAXLIM,RDPOSLIM,RDNEGLIM
!
    INTEGER DERLIM
    LOGICAL L_DERLIM
    COMMON/LIMDER/DERLIM,L_DERLIM
!
!       4/27/2003 ITERROR ADDED TO STOP LOOPS WHEN "ITER" GOES BAD.
    LOGICAL ITERROR
!
!       CLEARX,CLEARY VARIABLES
    REAL*8 CLFOB1,CLFOB2,CLRAY1,CLRAY2,CLSRF1,CLSRF2
    COMMON/CLEARANCEVARS/CLFOB1,CLFOB2,CLRAY1,CLRAY2,CLSRF1,CLSRF2
!
!       ITER ADJUST COMMON BLOCK
    REAL*8 ADJUST_VAL1
    COMMON/ITADJUSTCOM/ADJUST_VAL1
!

end module