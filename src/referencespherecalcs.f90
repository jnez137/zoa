module referencespherecalcs

  integer, parameter :: TC_PERFECT = 1
  integer, parameter :: TC_INFRAD  = 2
  integer, parameter :: TC_AFOCAL  = 3

  integer, parameter :: RF_CHIEF_PARAX = 1
  integer, parameter :: RF_CHIEF_REAL  = 2

contains

        SUBROUTINE LOPDS(REFERR,TPT)
!
        use global_widgets
        USE GLOBALS

        IMPLICIT NONE

        integer :: refSphereAlgo
!
!       THIS IS SUBROUTINE LOPD.FOR. THIS SUBROUTINE IS
!       CALLED BY SPD AND COMPAP ROUTINES. IT CALCULATES ADJUSTMENTS TO THE
!       OPD DUE TO THE IMAGE REFERENCE SPHERE. (FOR AFOCAL
!       SYSTEMS THIS WILL BE A FLAT REFERENCE SURFACE)
!
        INTEGER TPT

        INCLUDE 'DATMAI.INC'
        INCLUDE 'DATLEN.INC'
        INCLUDE 'DATSPD.INC'
        INCLUDE 'DATSP1.INC'
!
      LOGICAL REFERR

        !PRINT *, "LOPDS .f90!"
!
        RCOR=0.0D0
        OCOR=0.0D0
        REFERR=.FALSE.
!
!       CASE OF A PERFECT LENS AT SYSTEM(20)-1,OR IDEAL
      IF(GLANAM(INT(SYSTEM(20))-1,2).EQ.'PERFECT      ' &
      .OR.GLANAM(INT(SYSTEM(20))-1,2).EQ.'IDEAL        ') THEN
!     ALWAYS ASSUME FOCAL MODE BUT THERE IS NOTHING TO SUBTRACT OFF
!     SINCE NOTHING WAS ADDED
!     EXCEPT FOR OFF AXIS IMAGE POINTS WHERE WAVEFRONT TILT MUST
!     BE REMOVED AS IN THE CASE OF AFOCAL SYSTEMS. HERE HOWEVER, THE TILTED
!     PLANE IS AT NEWING-1 RATHER THAN AT NEWIMG
!       FLAT REFERENCE PLANE
!       THE SO-CALLED FLAT REFERENCE PLANE IS A PLANE
!       PERPENDICULAR TO THE REF RAY. THE INTERSECTION
!       OF THIS REFERENCE PLANE WITH THE REFERENCE RAY OCCURRS
!       AT THE FINAL SURFACE (NEWIMG-1). WITH THIS DEFINITION,
!       THE CORRECTION TERM FOR THE REFERENCE RAY IS ALWAYS
!       ZERO.
            RCOR=0.0D0
            OCOR=updateOCOR(TC_PERFECT)
            REFERR=.FALSE.

        END IF
!
!       CASE OF AFOCAL SYSTEMS
!
        IF(SYSTEM(30).EQ.3.0D0.OR.SYSTEM(30).EQ.4.0D0) THEN
!
!       FLAT REFERENCE PLANE
!       THE SO-CALLED FLAT REFERENCE PLANE IS A PLANE
!       PERPENDICULAR TO THE REF RAY. THE INTERSECTION
!       OF THIS REFERENCE PLANE WITH THE REFERENCE RAY OCCURRS
!       AT THE FINAL SURFACE (NEWIMG). WITH THIS DEFINITION,
!       THE CORRECTION TERM FOR THE REFERENCE RAY IS ALWAYS
!       ZERO.
                        RCOR=0.0D0
                        OCOR=updateOCOR(TC_AFOCAL)

        REFERR=.FALSE.

                        END IF
!

!     FOCAL SYSTEMS
!
      IF(sysConfig%isFocalSystem()) THEN
!       SYSTEM FOCAL.

        refSphereAlgo = getImageReferenceSphereAlgo()

        select case(refSphereAlgo)

          case(RF_CHIEF_PARAX)
             call updateRefSphereParaxialPupil(REFERR)

          case (RF_CHIEF_REAL)
            call updateRefSphereRealPupil(REFERR)

        end select

!     NOT FOCAL
      END IF


      IF(DABS(RCOR).GT.1.0D10.OR.DABS(OCOR).GT.1.0D10) THEN
!     INFINITE REFERENCE SPHERE

!     OCOR IS THE DISTANCE ALONG THE RAY BETWEEN AN INTERSECTION
!     WITH A PLANE PERPENDICULAR TO A PARALLEL RAY WHICH PASSES
!     THROUGH A POINT ON THE IMAGE SURFACE WHERE THE CHIEF RAY
!     HITS
        RCOR=0.0D0
        OCOR=updateOCOR(TC_INFRAD)

     END IF

      PRINT *, "RCOR = ", RCOR
      PRINT *, "OCOR = ", OCOR

      end subroutine

function updateOCOR(typeCode) result(opdCorrection)
! TODO:  CLean up inputs

        USE GLOBALS
        IMPLICIT NONE

          real*8 :: opdCorrection

          real*8, dimension(3) :: RC, RK, K0, RRC
          integer :: typeCode
!
!       THIS IS SUBROUTINE LOPD.FOR. THIS SUBROUTINE IS
!       CALLED BY SPD AND COMPAP ROUTINES. IT CALCULATES ADJUSTMENTS TO THE
!       OPD DUE TO THE IMAGE REFERENCE SPHERE. (FOR AFOCAL
!       SYSTEMS THIS WILL BE A FLAT REFERENCE SURFACE)
!
        REAL*8 :: T,XA,YA,ZA
!
      INTEGER TPT

!
        INCLUDE 'DATMAI.INC'
        INCLUDE 'DATLEN.INC'
        INCLUDE 'DATSPD.INC'
        INCLUDE 'DATSP1.INC'

    select case (typeCode)
    case(TC_PERFECT)
!     ALWAYS ASSUME FOCAL MODE BUT THERE IS NOTHING TO SUBTRACT OFF
!     SINCE NOTHING WAS ADDED
!     EXCEPT FOR OFF AXIS IMAGE POINTS WHERE WAVEFRONT TILT MUST
!     BE REMOVED AS IN THE CASE OF AFOCAL SYSTEMS. HERE HOWEVER, THE TILTED
!     PLANE IS AT NEWING-1 RATHER THAN AT NEWIMG
!       FLAT REFERENCE PLANE
!       THE SO-CALLED FLAT REFERENCE PLANE IS A PLANE
!       PERPENDICULAR TO THE REF RAY. THE INTERSECTION
!       OF THIS REFERENCE PLANE WITH THE REFERENCE RAY OCCURRS
!       AT THE FINAL SURFACE (NEWIMG-1). WITH THIS DEFINITION,
!       THE CORRECTION TERM FOR THE REFERENCE RAY IS ALWAYS
!       ZERO.
        ! FIrst Ray
        RC = REFRY(1:3,NEWIMG-1)
        PRINT *, "RC is ", RC
        RK = REFRY(19:21,NEWIMG-1)
        ! Second Ray
        RRC = DSPOT(27:29)
        K0 = DSPOT(30:32)

    case(TC_AFOCAL)
!       FLAT REFERENCE PLANE
!       THE SO-CALLED FLAT REFERENCE PLANE IS A PLANE
!       PERPENDICULAR TO THE REF RAY. THE INTERSECTION
!       OF THIS REFERENCE PLANE WITH THE REFERENCE RAY OCCURRS
!       AT THE FINAL SURFACE (NEWIMG). WITH THIS DEFINITION,
!       THE CORRECTION TERM FOR THE REFERENCE RAY IS ALWAYS
!       ZERO.
        RC = REFRY(1:3,NEWIMG)
        PRINT *, "RC is ", RC
        RK = REFRY(19:21,NEWIMG)
        RRC = DSPOT(1:3)
        K0 = DSPOT(22:24)

     case (TC_INFRAD)
               RC = REFRY(1:3,NEWIMG-1)
               PRINT *, "RC is ", RC
               RK = REFRY(30:32,NEWIMG)
               RRC = DSPOT(27:29)
               K0 = DSPOT(30:32)

     end select

!       THE EQUATION OF THE OTHER RAY IS
!               XA=RRX0+(T*L0)
!               YA=RRY0+(T*M0)
!               ZA=RRZ0+(T*N0)
! THE PARAMETER T IS DETERMINED BY SUBSTITUTING THIS LINE
!       EQUATION INTO THE REFERENCE SURAFCE EQUATION
!       AND SOLVING FOR T.
!
        T=((RK(1)*(RC(1)-RRC(1)))+(RK(2)*(RC(2)-RRC(2)))+(RK(3)*(RC(3)-RRC(3))))/ &
        ((RK(1)*K0(1))+(RK(2)*K0(2))+(RK(3)*K0(3)))
!
!       NOW X,Y AND Z ARE:
                XA=RRC(1)+(T*RK(1))
                YA=RRC(2)+(T*RK(2))
                ZA=RRC(3)+(T*RK(3))
        opdCorrection=DSQRT( &
        ((RRC(1)-XA)**2)+ &
        ((RRC(2)-YA)**2)+ &
        ((RRC(3)-ZA)**2))
!     IF T IS LESS THAN ZERO, THE RAY INTERSECTION WITH THE
!     REFERENCE PLANE LIES ON THE NEGATIVE SIDE OF THE IMAGE SURFACE
!     AND ZA LT DSPOT(29) AND OCOR MUST BE POSITIVE AND VICE VERSA.
!       THE CORRECT SIGN IS:
        IF(ZA.GT.RRC(3)) opdCorrection=-opdCorrection
        IF(ZA.LE.RRC(3)) opdCorrection=opdCorrection


end function

function getImageReferenceSphereAlgo() result(res)


  IMPLICIT NONE

  integer :: res

        INCLUDE 'DATLEN.INC'


! Comments from original code unless otherwise noted
res = 0
       !PRINT *, "EXPAUT is ", EXPAUT

!     EXPAUT :  SET AUTOMATIC EXIT PUPIL LOCATION CALCULATION TO ON
IF(.NOT.EXPAUT.OR.EXPAUT.AND..NOT.LDIF2) res = RF_CHIEF_PARAX
!       THE REFERENCE SPHERE IS CENTERED WHERE THE REAL CHIEF
!       RAY CROSSES THE FINAL SURFACE.
!       THE RADIUS IS EQUAL
!       TO THE DISTANCE FROM THE FINAL IMAGE SURFACE TO THE SURFACE
!       PRECEEDING THE IMAGE SURFACE IF THE I-1 THICKNESS IS NON-ZERO
!       AND IS THE DISTANCE TO THE PARAXIAL EXIT PUPIL IF TH (I-1)=0
!       THIS IS JUST AS IN ACCOS V AND
!       HEXAGON AND GIVES THE USER THE CHOICE FOR RADIUS. BY USING
!       PIKUPS (NOT AVAILABLE IN CODE V), A WIDE VARIETY OF REFERENCE
!       SURFACES MAY BE SELECTED.
      IF(EXPAUT) res = RF_CHIEF_REAL
!       THE REFERENCE SPHERE IS CENTERED WHERE THE REAL CHIEF
!       RAY CROSSES THE FINAL SURFACE.
!       THE RADIUS IS EQUAL
!       TO THE DISTANCE FROM POINT TO WHERE THE CHIEF RAY CROSSES THE REAL
!     EXIT PUPIL
!       THIS IS JUST AS IN CODE-V AND IS THE DEFAULT WHEN THE PROGRAM
!     BEGINS



end function

subroutine updateRefSphereParaxialPupil(REFERR)
! TODO:  Have propoer input/output.
        USE GLOBALS
        IMPLICIT NONE

        REAL*8 XREFI,XO,XOOY,XOOX,YO,YOOX,YOOY,ZO,ZOOX,ZOOY, &
        YREFI,RAD,AL,BE,GA,A,B,C,LEN,LEN1,LO,LOOX,LOOY,MO,MOOX,MOOY, &
        LEN2,Q,ARG,ZREFI,SIGNB,RL0,RM0,RN0,NO,NOOX,NOOY,THYNUM,THXNUM, &
        RRX0,RRZ0,T,RX0,RY0,RZ0,RRY0,M0,L0,N0,XA,THXDEN,THYDEN, &
        YA,ZA,LLL,MMM,NNN
!
      INTEGER TPT
      LOGICAL REFERR

!
        INCLUDE 'DATMAI.INC'
        INCLUDE 'DATLEN.INC'
        INCLUDE 'DATSPD.INC'
        INCLUDE 'DATSP1.INC'

!       THE REFERENCE SPHERE IS CENTERED WHERE THE REAL CHIEF
!       RAY CROSSES THE FINAL SURFACE.
!       THE RADIUS IS EQUAL
!       TO THE DISTANCE FROM THE FINAL IMAGE SURFACE TO THE SURFACE
!       PRECEEDING THE IMAGE SURFACE IF THE I-1 THICKNESS IS NON-ZERO
!       AND IS THE DISTANCE TO THE PARAXIAL EXIT PUPIL IF TH (I-1)=0
!       THIS IS JUST AS IN ACCOS V AND
!       HEXAGON AND GIVES THE USER THE CHOICE FOR RADIUS. BY USING
!       PIKUPS (NOT AVAILABLE IN CODE V), A WIDE VARIETY OF REFERENCE
!       SURFACES MAY BE SELECTED.
!
!     IF EXPAUT AND NOT LDIF2, AN ASTOP EX IS DONE EVEN IF THE I-1
!     THICKNESS IS NOT ZERO.
!
!       COORDINATES OF THE REAL CHIEF RAY AT THE IMAGE PLANE ARE:
!       THIS IS THE REFERENCE SPHERE CENTER LOCATION.
        XREFI=REFRY(1,NEWIMG)
        YREFI=REFRY(2,NEWIMG)
        ZREFI=REFRY(3,NEWIMG)
        !call logger%logTextWithNum("XREFI=",XREFI)
        !call logger%logTextWithNum("YREFI=",YREFI)
        !call logger%logTextWithNum("ZREFI=",ZREFI)


        IF(ALENS(3,(NEWIMG-1)).EQ.0.0D0.OR.ALENS(3,(NEWIMG-1)).NE. &
      0.0D0.AND..NOT.LDIF2) THEN
!       DIST FROM I-1 TO I IS ZERO OF LDIF2 IS FALSE AND DIST NOT 0
!       DO AN INTERNAL "ASTOP EX" ADJUSTMENT
        IF(DABS(PXTRAY(5,NEWIMG)*1.0D-15).LT. &
      DABS(PXTRAY(6,NEWIMG))) THEN
              RAD=(PXTRAY(5,NEWIMG)/PXTRAY(6,NEWIMG))
              RREF=RAD

        END IF
        IF(DABS(PXTRAY(5,NEWIMG)*1.0D-15).GE. &
      DABS(PXTRAY(6,NEWIMG))) THEN
!       REF RAY IS TELECENTRIC, SET RAD INFINITY
            RAD=1.0D20
            RREF=RAD
        END IF
!       USE EXISTING THICKNESS OF NEWIMG-1 AS RAD
        ELSE
        RAD=ALENS(3,NEWIMG-1)
        RREF=RAD
                        END IF
!
!       NOW WE HAVE LOCATION OF REFERENCE SPHERE CENTER
!       AND ITS RADIUS
!
!       THE CHIEF RAY INTERSECTS THE REFERENCE SPHERE
!       THE LENGTH FROM THIS INTERSECTION TO THE INTERSECTION
!       OF THE REFERENCE RAY WITH THE FINAL SURFACE IS RCOR=RAD
!       REFERENCE RAY INTERSECTION WITH THE TANGENT PLANE IS:
!
        RCOR=RAD
!
!       THE LENGTH FROM THE REFERENCE SPHERE
!       TO THE FINAL SURFACE ALONG THE "OTHER" RAY IS:
!
        !call logger%logTextWithNum("Ref Sphere Radius is ",RAD)
        !call logger%logTextWithNum("Ref Sphere Distance is ",RCOR)

        AL=DSPOT(1)-XREFI
        BE=DSPOT(2)-YREFI
        GA=DSPOT(3)-ZREFI
        C=(AL**2)+(BE**2)+(GA**2)-(RAD**2)
        B=2.0D0*((DSPOT(22)*AL)+ &
          (DSPOT(23)*BE)+ &
          (DSPOT(24)*GA))
        A=1.0D0
!       SOLVE FOR LEN
        IF(B.NE.0.0D0) SIGNB=((DABS(B))/(B))
        IF(B.EQ.0.0D0) SIGNB=1.0D0
                IF(A.EQ.0.0D0) THEN
                        LEN=-(C/B)
                      ELSE
        ARG=((B**2)-(4.0D0*A*C))
        IF(ARG.LT.0.0D0) THEN
      IF(TPT.EQ.1) THEN
        PRINT *, "A=", A
        PRINT *, "B=", B
        PRINT *, "C=", C
        PRINT *, "ARG=", ARG
        OUTLYNE='RAY(S) COULD NOT INTERSECT REFERENCE SPHERE'
      CALL SHOWIT(1)
        OUTLYNE= &
        'TRY USING AN "ASTOP EX" OR ASTOP "EN/EX" ADJUSTMENT'
      CALL SHOWIT(1)
        OUTLYNE= &
        'OPD VALUES MAY BE SUSPECT'
      CALL SHOWIT(1)
                       END IF
              OCOR=0.0D0
              RCOR=0.0D0
        REFERR=.TRUE.
                        RETURN
!       REFERENCE SPHERE INTERSECTED
                        END IF
        Q=(-0.5D0*(B+(SIGNB*(DSQRT((B**2)-(4.0D0*A*C))))))
                        LEN1=C/Q
                        LEN2=Q/A
          IF(REFRY(6,NEWIMG).GT.0.0D0) THEN
        IF(RAD.GT.0.0D0) THEN
!     THEN THE INTERSECTION TO USE IS THE NEGATIVE INTERSECTION
        IF(LEN1.LT.0.0D0) LEN=LEN1
        IF(LEN2.LT.0.0D0) LEN=LEN2
                        ELSE
!       RAD NEG
!     THEN THE INTERSECTION TO USE IS THE POSITIVE INTERSECTION
        IF(LEN1.GT.0.0D0) LEN=LEN1
        IF(LEN2.GT.0.0D0) LEN=LEN2
                        END IF
                        END IF
          IF(REFRY(6,NEWIMG).LT.0.0D0) THEN
        IF(RAD.GT.0.0D0) THEN
!     THEN THE INTERSECTION TO USE IS THE NEGATIVE INTERSECTION
        IF(LEN1.LT.0.0D0) LEN=-LEN2
        IF(LEN2.LT.0.0D0) LEN=-LEN1
                        ELSE
!       RAD NEG
!     THEN THE INTERSECTION TO USE IS THE POSITIVE INTERSECTION
        IF(LEN1.GT.0.0D0) LEN=-LEN2
        IF(LEN2.GT.0.0D0) LEN=-LEN1
                        END IF
                        END IF
                        END IF
!       NEGATIVE SIGN SINCE LEN1 AND LEN2 MEASURES DIRECTED
!       DISTANCE FROM IMAGE TO SPHERE INTERSECTION AND
!       LEN IS DIRECTED FROM SPHERE INTERSECTION TO IMAGE

        OCOR=-LEN
        REFERR=.FALSE.


end subroutine

subroutine updateRefSphereRealPupil(REFERR)
! TODO make this proper input/output
        USE GLOBALS
        IMPLICIT NONE

        REAL*8 XREFI,XO,XOOY,XOOX,YO,YOOX,YOOY,ZO,ZOOX,ZOOY, &
        YREFI,RAD,AL,BE,GA,A,B,C,LEN,LEN1,LO,LOOX,LOOY,MO,MOOX,MOOY, &
        LEN2,Q,ARG,ZREFI,SIGNB,RL0,RM0,RN0,NO,NOOX,NOOY,THYNUM,THXNUM, &
        RRX0,RRZ0,T,RX0,RY0,RZ0,RRY0,M0,L0,N0,XA,THXDEN,THYDEN, &
        YA,ZA,LLL,MMM,NNN
!
      INTEGER TPT
      LOGICAL REFERR

!
        INCLUDE 'DATMAI.INC'
        INCLUDE 'DATLEN.INC'
        INCLUDE 'DATSPD.INC'
        INCLUDE 'DATSP1.INC'


!       THE REFERENCE SPHERE IS CENTERED WHERE THE REAL CHIEF
!       RAY CROSSES THE FINAL SURFACE.
!       THE RADIUS IS EQUAL
!       TO THE DISTANCE FROM POINT TO WHERE THE CHIEF RAY CROSSES THE REAL
!     EXIT PUPIL
!       THIS IS JUST AS IN CODE-V AND IS THE DEFAULT WHEN THE PROGRAM
!     BEGINS
!
!       COORDINATES OF THE REAL CHIEF RAY AT THE IMAGE PLANE ARE:
!       THIS IS THE REFERENCE SPHERE CENTER LOCATION.
        XREFI=REFRY(1,NEWIMG)
        YREFI=REFRY(2,NEWIMG)
        ZREFI=REFRY(3,NEWIMG)
!
!       DO A REAL RAY INTERNAL EXIT PUPIL ADJUSTMENT
!
          XO=REFRY(1,NEWIMG)
          YO=REFRY(2,NEWIMG)
          ZO=REFRY(3,NEWIMG)
          LO=REFRY(4,NEWIMG)
          MO=REFRY(5,NEWIMG)
          NO=REFRY(6,NEWIMG)
          XOOX=RFDIFF(1,NEWIMG)
          YOOX=RFDIFF(2,NEWIMG)
          ZOOX=RFDIFF(3,NEWIMG)
          LOOX=RFDIFF(4,NEWIMG)
          MOOX=RFDIFF(5,NEWIMG)
          NOOX=RFDIFF(6,NEWIMG)
          XOOY=RFDIFF(7,NEWIMG)
          YOOY=RFDIFF(8,NEWIMG)
          ZOOY=RFDIFF(9,NEWIMG)
          LOOY=RFDIFF(10,NEWIMG)
          MOOY=RFDIFF(11,NEWIMG)
          NOOY=RFDIFF(12,NEWIMG)
      THXNUM=((XO-XOOX)*(LO-LOOX))+((YO-YOOX)*(MO-MOOX)) &
      +((ZO-ZOOX)*(NO-NOOX))
      THYNUM=((XO-XOOY)*(LO-LOOY))+((YO-YOOY)*(MO-MOOY)) &
      +((ZO-ZOOY)*(NO-NOOY))
      THXDEN=((LO-LOOX)**2)+((MO-MOOX)**2) &
      +((NO-NOOX)**2)
      THYDEN=((LO-LOOY)**2)+((MO-MOOY)**2) &
      +((NO-NOOY)**2)
        IF(DABS(THXNUM*1.0D-15).LT.DABS(THXDEN).AND. &
      DABS(THYNUM*1.0D-15).LT. &
      DABS(THYDEN)) THEN
      RAD=-((-THXNUM/THXDEN)+(-THYNUM/THYDEN))/2.0D0
        RREF=RAD
!     THE EXIT PUPIL IS LOCATED AT:
               XA=XO+(-RAD*LO)
               YA=YO+(-RAD*MO)
               ZA=ZO+(-RAD*NO)
      RAD=DSQRT( &
      ((XA-XREFI)**2)+((YA-YREFI)**2)+((ZA-ZREFI)**2) &
      )
        RREF=RAD
      IF(ZA.LE.ZO) THEN
!     PUPIL LIES ON THE NEGATIVE SIDE OF NEWIMG SO RAD IS POS
        RAD=RAD
        RREF=RAD
                      ELSE
      RAD=-RAD
        RREF=RAD
                      END IF
                        END IF
        IF(DABS(THXNUM*1.0D-15).GE.DABS(THXDEN).OR. &
      DABS(THYNUM*1.0D-15).GE. &
      DABS(THYDEN)) THEN
!       REF RAY IS TELECENTRIC, SET RAD INFINITY
!       FLAT REFERENCE PLANE
                       RAD=1.0D20
        RREF=RAD
                        END IF
!
!       NOW WE HAVE LOCATION OF REFERENCE SPHERE CENTER
!       AND ITS RADIUS MAGNITUDE
!
!       THE CHIEF RAY INTERSECTS THE REFERENCE SPHERE
!       THE LENGTH FROM THIS INTERSECTION TO THE INTERSECTION
!       OF THE REFERENCE RAY WITH THE FINAL SURFACE IS RCOR=RAD
!       REFERENCE RAY INTERSECTION WITH THE TANGENT PLANE IS:
!
        RCOR=RAD
!
!       THE LENGTH FROM THE REFERENCE SPHERE
!       TO THE FINAL SURFACE ALONG THE "OTHER" RAY IS:
!
                LLL=DSPOT(22)
                MMM=DSPOT(23)
                NNN=DSPOT(24)
        AL=DSPOT(1)-XREFI
        BE=DSPOT(2)-YREFI
        GA=DSPOT(3)-ZREFI
        C=(AL**2)+(BE**2)+(GA**2)-(RAD**2)
        B=2.0D0*((LLL*AL)+ &
          (MMM*BE)+ &
          (NNN*GA))
        A=1.0D0
!       SOLVE FOR LEN
        IF(B.NE.0.0D0) SIGNB=((DABS(B))/(B))
        IF(B.EQ.0.0D0) SIGNB=1.0D0
                IF(A.EQ.0.0D0) THEN
                        LEN=-(C/B)
                      ELSE
        ARG=((B**2)-(4.0D0*A*C))
        IF(ARG.LT.0.0D0) THEN
      IF(TPT.EQ.1) THEN
        OUTLYNE='RAY(S) COULD NOT INTERSECT REFERENCE SPHERE'
      CALL SHOWIT(1)
        OUTLYNE= &
        'THE CURRENT SYSTEM MAY HAVE EXCESSIVE ABERRATIONS'
      CALL SHOWIT(1)
        OUTLYNE= &
        'OPD VALUES MAY BE SUSPECT'
      CALL SHOWIT(1)
                       END IF
              OCOR=0.0D0
              RCOR=0.0D0
        REFERR=.TRUE.
                        RETURN
!       REFERENCE SPHERE INTERSECTED
                        END IF
        Q=(-0.5D0*(B+(SIGNB*(DSQRT((B**2)-(4.0D0*A*C))))))
                        LEN1=C/Q
                        LEN2=Q/A
      IF(REFRY(6,NEWIMG).GT.0.0D0) THEN
        IF(RAD.GT.0.0D0) THEN
!     THEN THE INTERSECTION TO USE IS THE NEGATIVE INTERSECTION
        IF(LEN1.LT.0.0D0) LEN=LEN1
        IF(LEN2.LT.0.0D0) LEN=LEN2
                        ELSE
!       RAD NEG
!     THEN THE INTERSECTION TO USE IS THE POSITIVE INTERSECTION
        IF(LEN1.GT.0.0D0) LEN=LEN1
        IF(LEN2.GT.0.0D0) LEN=LEN2
                        END IF
                        END IF
      IF(REFRY(6,NEWIMG).LT.0.0D0) THEN
        IF(RAD.GT.0.0D0) THEN
!     THEN THE INTERSECTION TO USE IS THE NEGATIVE INTERSECTION
        IF(LEN1.LT.0.0D0) LEN=-LEN2
        IF(LEN2.LT.0.0D0) LEN=-LEN1
                        ELSE
!       RAD NEG
!     THEN THE INTERSECTION TO USE IS THE POSITIVE INTERSECTION
        IF(LEN1.GT.0.0D0) LEN=-LEN2
        IF(LEN2.GT.0.0D0) LEN=-LEN1
                        END IF
                        END IF
                        END IF
!       NEGATIVE SIGN SINCE LEN1 AND LEN2 MEASURES DIRECTED
!       DISTANCE FROM IMAGE TO SPHERE INTERSECTION AND
!       LEN IS DIRECTED FROM SPHERE INTERSECTION TO IMAGE
        OCOR=-LEN

end subroutine

end module
