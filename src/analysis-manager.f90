! This is meant to be a partner to lens data manager where you can get analysis in one place
! Will take a long time to add everything so for now will just add as needed
! Whether something should be in lens data manager or analysis manager should be separated by whether it is calcualted or not.
! FOr example effective focal length should be here, but I initially set it up in ldm.  
! radii, curvature, glass type, pickups, solves should be in LDM
module mod_analysis_manager
    use globals, only: long
    use global_widgets, only: curr_par_ray_trace, sysConfig
    use mod_lens_data_manager
    use type_utils

    type analysis_manager
   
    contains
     procedure :: getTransverseComa, getTransverseAstigmatism, getPetzvalBlur, getTransverseSpherical
     procedure :: getPSF, getImgNA

    end type

    type(analysis_manager) :: am

    contains    

    function getTransverseComa(self) result (res)
        implicit none
        class(analysis_manager) :: self
        real(long) :: res

        res = 0.0_long

        CALL PROCESSILENT('MAB3 ALL')
        call PROCESKDP("MAB3 ALL")
  
        call MMAB3_NEW(.TRUE., sysConfig%refWavelengthIndex)
        ! This essentially serves as documentation for which index is which term
        res = curr_par_ray_trace%CSeidel(2,ubound(curr_par_ray_trace%CSeidel, dim=2))

    end function

    function getTransverseSpherical(self) result (res)
        implicit none
        class(analysis_manager) :: self
        real(long) :: res

        res = 0.0_long

        CALL PROCESSILENT('MAB3 ALL')
        call PROCESKDP("MAB3 ALL")
  
        call MMAB3_NEW(.TRUE., sysConfig%refWavelengthIndex)
        ! This essentially serves as documentation for which index is which term
        res = curr_par_ray_trace%CSeidel(1,ubound(curr_par_ray_trace%CSeidel, dim=2))

    end function    

    ! TODO - refactor with Coma (pass first index to single func)
    function getTransverseAstigmatism(self) result (res)
        implicit none
        class(analysis_manager) :: self
        real(long) :: res

        res = 0.0_long

        CALL PROCESSILENT('MAB3 ALL')
        call PROCESKDP("MAB3 ALL")
  
        call MMAB3_NEW(.TRUE., sysConfig%refWavelengthIndex)
        ! This is conversion of the Smith definition to the CodeV definition.
        res = 3*curr_par_ray_trace%CSeidel(3,ubound(curr_par_ray_trace%CSeidel, dim=2))- &
        & curr_par_ray_trace%CSeidel(5,ubound(curr_par_ray_trace%CSeidel, dim=2))

    end function    

    function getPetzvalBlur(self) result (res)
        implicit none
        class(analysis_manager) :: self
        real(long) :: res

        res = 0.0_long

        CALL PROCESSILENT('MAB3 ALL')
        call PROCESKDP("MAB3 ALL")
  
        call MMAB3_NEW(.TRUE., sysConfig%refWavelengthIndex)
        ! This is conversion of the Smith definition to the CodeV definition.
        res = curr_par_ray_trace%CSeidel(5,ubound(curr_par_ray_trace%CSeidel, dim=2))

    end function        

    function getPSF(self) result(psfData)
        use global_widgets, only: curr_psf
        use DATSPD
        implicit none
        class(analysis_manager) :: self
        real(long), allocatable  :: psfData(:,:)

        allocate(psfData(TGR,TGR))

        !call PROCESSILENT('PSFPLOT OFF')
        call PROCESSILENT('PSFK')

        psfData = curr_psf


    end function

    function getImgNA(self) result(imgNA)
        use data_registers

        implicit none
        class(analysis_manager) :: self
        real(long)  :: imgNA, cosX, cosY, cosR

        ! THis is dumb.  Should move this calc to somewhere else and store it.  for now though...
        call getData('CY f1 w1 s'//trim(int2str(ldm%getLastSurf()))//' 0.0 1.0', cosY)
        call getData('CX f1 w1 s'//trim(int2str(ldm%getLastSurf()))//' 0.0 1.0', cosX)

        cosR = sqrt(cosX**2 + cosY**2)
        imgNA = sin(acos(cosR))





    end function    


end module