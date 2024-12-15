!Notes:
!It should be true that surfaces start from 0.  curr_lens_data is not stored this way
!so this can lead to confusion
module mod_lens_data_manager
    use iso_fortran_env, only: real64
    use global_widgets, only: curr_lens_data, curr_par_ray_trace, sysConfig
    use globals, only: long
    use zoa_ui

    type lens_data_manager

    real(long), dimension(0:499,3) :: vars ! CCY THC GLC for now.  Hard code max of 500 surfaces.  Default is 100
   
    contains
     procedure :: initialize => init_ldm
     procedure, public, pass(self) :: getSurfThi, setSurfThi
     procedure, public, pass(self) :: isThiSolveOnSurf
     procedure, public, pass(self) :: isYZCurvSolveOnSurf
     procedure, public, pass(self) :: getSurfCurv, getSurfRad
     procedure, public, pass(self) :: getSurfIndex
     procedure, public, pass(self) :: getLastSurf
     procedure, public, pass(self) :: getEFL
     procedure, public, pass(self) :: getTrackLength
     procedure :: getCurrentConfig
     procedure :: getSurfName
     procedure :: getStopSurf
     procedure :: isGlassSurf
     procedure :: getGlassName
     procedure :: updateThiOptimVars
     procedure :: updateCurvOptimVars
     procedure :: setVarOnSurf
     procedure :: isSolveOnSurf, isPikupOnSurf
     procedure :: getCCYCodeAsStr, getTHCCodeAsStr



    end type

    type(lens_data_manager) :: ldm

    

    contains
    subroutine init_ldm(self)
        class (lens_data_manager) :: self
        ! Set all vars to default
        ldm%vars(:,:) = 100
    
    end subroutine

    function getGlassName(self, idx) result(strGlassName)
        use DATLEN, only: GLANAM
        use type_utils, only: blankStr
        implicit none
        class(lens_data_manager) :: self
        integer :: idx
        character(len=15) :: strGlassName

        strGlassName = trim(GLANAM(idx,2))//'_'//trim(GLANAM(idx,1))

        ! Zero out if we get AIR or LAST SURFACE
        if (GLANAM(idx,2).EQ.'AIR') strGlassName = blankStr(len(strGlassName))
        if (GLANAM(idx,2).EQ.'LAST SURFACE') strGlassName = blankStr(len(strGlassName))        



    end function

    function isGlassSurf(self, idx) result(boolResult)
        use DATLEN, only: GLANAM
        class(lens_data_manager) :: self
        integer :: idx
        logical :: boolResult

        boolResult = .TRUE.
        if (GLANAM(idx,2) == 'AIR') boolResult = .FALSE.
        if (GLANAM(idx,2).EQ.'LAST SURFACE') boolResult = .FALSE.

    end function

    function getStopSurf(self) result(iStop)
        class(lens_data_manager) :: self
        integer :: iStop

        ! Since curr lens data is not a 0 indexed array, subtract 1
        iStop = curr_lens_data%ref_stop-1


    end function

    function getSurfName(self, idx) result(strName)
        class(lens_data_manager) :: self
        character(len=3) :: strName

        write(strName, '(I0.3)')  idx
        ! Handle Special surfaces
        if (idx==0) strName = 'OBJ'
        if (idx==self%getStopSurf()) strName = 'STO'
        if (idx==self%getLastSurf()) strName = 'IMG'

    end function

    function getCurrentConfig(self) result(cfg)
        class(lens_data_manager) :: self
        integer :: cfg

        cfg = 1 ! TODO:  Update when configs are fully supported

    end function

    function getLastSurf(self) result(Sf)
        class(lens_data_manager) :: self
        integer :: Sf

        Sf = curr_lens_data%num_surfaces-1

    end function

    function getSurfThi(self, surfIdx) result(thi)
        use DATLEN, only: ALENS
        class(lens_data_manager) :: self
        integer :: surfIdx
        real(kind=real64) :: thi

        thi = ALENS(3,surfIdx)
        !thi = curr_lens_data%thicknesses(surfIdx+1)

    end function


    subroutine setSurfThi(self, surfIdx, thi) 
        use DATLEN, only: ALENS
        implicit none
        class(lens_data_manager) :: self
        integer :: surfIdx
        real(kind=real64) :: thi


        ALENS(3,surfIdx) = thi
   
    end subroutine    

    function isThiSolveOnSurf(self, surfIdx) result(boolResult)
        use DATLEN, only: SOLVE
        class(lens_data_manager) :: self
        integer :: surfIdx
        logical :: boolResult

        boolResult = .FALSE.
        IF(SOLVE(6,surfIdx).NE.0.0D0) boolResult = .TRUE.

    end function

    function isYZCurvSolveOnSurf(self, surfIdx) result(boolResult)
        use DATLEN, only: SOLVE
        class(lens_data_manager) :: self
        integer :: surfIdx
        logical :: boolResult

        boolResult = .FALSE.
        IF(SOLVE(8,surfIdx).NE.0.0D0) boolResult = .TRUE.

    end function

    function getSurfRad(self, surfIdx) result (rad)
        use DATLEN, only: ALENS
        implicit none
        class(lens_data_manager) :: self
        integer :: surfIdx
        real(kind=real64) :: rad

        rad = curr_lens_data%radii(surfIdx+1)

    end function

    function getSurfCurv(self, surfIdx, useXZPlane) result(curv)
        use DATLEN, only: ALENS
        class(lens_data_manager) :: self
        integer :: surfIdx
        logical, optional :: useXZPlane
        real(kind=real64) :: curv

        ! TODO: clean this up, add XZ logic

    !       CHECK FOR X-TORIC. IF FOUND SET CURV=ALENS(24,-)
    !       ELSE SET CURV=ALENS(1,-)
        IF(ALENS(23,surfIdx).EQ.2.0D0) THEN
            curv=ALENS(24,surfIdx)
        ELSE
            IF(ALENS(1,surfIdx).EQ.0.0D0.AND.ALENS(43,surfIdx).NE.0.0D0) THEN
                curv=ALENS(43,surfIdx)*2.0D0
            ELSE
                curv=ALENS(1,surfIdx)
            END IF
        END IF

    end function 

    function getEFL(self) result(EFL)
        implicit none
        class(lens_data_manager) :: self
        real(kind=real64) :: EFL

        EFL = curr_par_ray_trace%EFL

    end function

    function getTrackLength(self) result (OAL)
        implicit none
        class(lens_data_manager) :: self
        real(kind=real64) :: OAL

        OAL = curr_par_ray_trace%OAL


    end function


    
    function getSurfIndex(self, surfIdx, lambdaIdx) result(index)        
        use DATLEN, only: ALENS
        class(lens_data_manager) :: self
        integer :: surfIdx
        integer, optional :: lambdaIdx
        real(kind=real64) :: index

        INTEGER :: WWVN

        ! TODO:  CLean up 

        if(present(lambdaIdx) .EQV. .FALSE. ) then
            WWVN = sysConfig%refWavelengthIndex
        else
           if (lambdaIdx.GT.0.AND.lambdaIdx.LT.6) then
            WWVN = lambdaIdx+45 ! From 46-50
           end if
           if (lambdaIdx.GT.5.AND.lambdaIdx.LT.11) then
            WWVN = lambdaIdx+65 ! From 71-75
           end if           
        end if

        index = ALENS(WWVN,surfIdx)

    end function

    subroutine updateThiOptimVars(self, s0, sf, intCode)
        use type_utils
        !use optim_types
        class(lens_data_manager) :: self
        integer, intent(in) :: s0, sf, intCode
        integer :: i

        !select case (intCode)

        !case(0) ! Make Variable
        !    if (s0==sf) then
        !        CALL PROCESKDP('UPDATE VARIABLE ; TH, '//trim(int2str(s0))//'; EOS ')
        !    else
        !        call PROCESKDP('UPDATE VARIABLE')
        !        do i=s0,sf
        !            CALL PROCESKDP('TH, '//trim(int2str(i)))
        !        end do
        !        call PROCESKDP('EOS')
        !    end if

        !end select

        select case (intCode)        
        case(0) ! Make Variable if no pickups or solves on surface
            if (s0==sf) then
                call self%setVarOnSurf(s0, VAR_THI)
               
                                
            else
                do i=s0,sf
                    call self%setVarOnSurf(i, VAR_THI)    
                end do
            end if

    end select                

        ! New Code
        ! select case (intCode)

        ! case(0) ! Make Variable
        !     if (s0==sf) then
        !         call addOptimVariable(s0,VAR_THI)
        !         !CALL PROCESKDP('UPDATE VARIABLE ; TH, '//trim(int2str(s0))//'; EOS ')
        !     else
        !         !call PROCESKDP('UPDATE VARIABLE')
        !         do i=s0,sf
        !             call addOptimVariable(i,VAR_THI)
        !             !CALL PROCESKDP('TH, '//trim(int2str(i)))
        !         end do
        !         !call PROCESKDP('EOS')
        !     end if

        ! end select

    end subroutine

    function isSolveOnSurf(self, surf, var_code) result(boolResult)
        class(lens_data_manager) :: self
        integer, intent(in) :: surf, var_code
        logical :: boolResult

        ! Default is false
        boolResult = .FALSE.

        select case (var_code)
        case (VAR_CURV)
            boolResult = self%isYZCurvSolveOnSurf(surf)
        case (VAR_THI)
            boolResult = self%isThiSolveOnSurf(surf)
        end select

    end function

    ! TODO:  Refactor with solve?
    function isPikupOnSurf(self, sur, var_code) result(boolResult)
        use DATLEN
        implicit none
        class(lens_data_manager) :: self
        integer, intent(in) :: sur, var_code
        logical :: boolResult

        ! Default is false
        boolResult = .FALSE.

        select case (var_code)
        case (VAR_CURV)
            if(PIKUP(1,sur, ID_PICKUP_RAD) == 1.0) boolResult = .TRUE.
        case (VAR_THI)
            if(PIKUP(1,sur,ID_PICKUP_THIC) == 1.0) boolResult = .TRUE.
        end select

    end function


    subroutine setVarOnSurf(self, surf, var_code)
        use type_utils, only: int2str
        implicit none

        class(lens_data_manager) :: self
        integer, intent(in) :: surf, var_code

        ! Make sure there are no solves or pickups on the surface.  

        if (self%isSolveOnSurf(surf, var_code)) then
            call logtermFOR("Error!  Cannot add variable to surface "//int2str(surf)//" due to presence of solve.  Please remove it first")
            return
        end if
        if (self%isPikupOnSurf(surf, var_code)) then
            call logtermFOR("Error!  Cannot add variable to surface "//int2str(surf)//" due to presence of solve.  Please remove it first")
            return
        end if


        ! Code is 0.  Place it in if var_code is within range
        if (var_code > 0 .and. var_code <= ubound(self%vars,dim=2)) then 
        self%vars(surf,var_code) = 0
        end if
                     

    end subroutine

    !TODO:  Refactor with updateThiOptimVars
    subroutine updateCurvOptimVars(self, s0, sf, intCode)
        use type_utils
        !use optim_types
        class(lens_data_manager) :: self
        integer, intent(in) :: s0, sf, intCode
        integer :: i

        ! KDP code.  Had some problems with setting vars and reading old code so abandoned this for now (may regret this later)
        ! select case (intCode)

        ! case(0) ! Make Variable
        !     if (s0==sf) then
        !         CALL PROCESKDP('UPDATE VARIABLE ; CV, '//trim(int2str(s0))//'; EOS ')
        !     else
        !         call PROCESKDP('UPDATE VARIABLE')
        !         do i=s0,sf
        !             CALL PROCESKDP('CV, '//trim(int2str(i)))
        !         end do
        !         call PROCESKDP('EOS')
        !     end if

            

        ! end select


        select case (intCode)        
        case(0) ! Make Variable if no pickups or solves on surface
            if (s0==sf) then
                call self%setVarOnSurf(s0, VAR_CURV)
               
                                
            else
                do i=s0,sf
                    call self%setVarOnSurf(i, VAR_CURV)    
                end do
            end if

    end select        

        ! New Code
        !select case (intCode)

        ! case(0) ! Make Variable
        !     if (s0==sf) then
        !         call addOptimVariable(s0,VAR_CURV)
        !         !CALL PROCESKDP('UPDATE VARIABLE ; TH, '//trim(int2str(s0))//'; EOS ')
        !     else
        !         !call PROCESKDP('UPDATE VARIABLE')
        !         do i=s0,sf
        !             call addOptimVariable(i,VAR_CURV)
        !             !CALL PROCESKDP('TH, '//trim(int2str(i)))
        !         end do
        !         !call PROCESKDP('EOS')
        !     end if

        ! end select


    end subroutine    

    function getCCYCodeAsStr(self, si) result(outStr)
        use type_utils

        implicit none
        
        class(lens_data_manager) :: self
        character(len=3) :: outStr
        integer :: si

        integer :: optimCode

        outStr = '100'

        outStr = int2str(INT(self%vars(si,1)))


    end function

    function getTHCCodeAsStr(self, si) result(outStr)
        use type_utils

        implicit none
        
        class(lens_data_manager) :: self
        character(len=3) :: outStr
        integer :: si

        integer :: optimCode

        outStr = '100'

        outStr = int2str(INT(self%vars(si,2)))


    end function    


end module