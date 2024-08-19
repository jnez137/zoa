! collection of functions to call during "GO" to finish off plots
! Description of current plot design
! It is a lock and key design.  
! To create a new plot:
! Add a key in zoa-ui as an integer constant parameter.  Needs to be unique compared to other plots
!


module plot_functions


    contains


subroutine zern_go(psm)

    USE GLOBALS
    use command_utils
    use handlers, only: zoatabMgr, updateTerminalLog
    use global_widgets, only:  sysConfig
    use zoa_ui
    use zoa_plot
    use iso_c_binding, only:  c_ptr, c_null_char
    use kdp_utils, only: OUTKDP, logDataVsField
    use type_utils, only: int2str, str2int
    use plot_setting_manager
    use DATMAI


    IMPLICIT NONE

    character(len=23) :: ffieldstr
    character(len=1024) :: inputCmd
    integer :: ii, objIdx, minZ, maxZ, lambda
    integer :: maxPlotZ = 9, numTermsToPlot
    integer :: numPoints = 10
    integer :: pIdx
    logical :: replot
    type(multiplot) :: mplt
    type(zoaplot) :: zernplot
    type(c_ptr) :: canvas
    type(zoaplot_setting_manager) :: psm
    character(len=80) :: tabName


    character(len=5), allocatable :: zLegend(:)

    REAL, allocatable :: xdat(:), ydat(:,:)
    


    REAL*8 X(1:96)
    COMMON/SOLU/X


    numPoints = psm%getDensitySetting()
    call psm%getZernikeSetting_min_and_max(minZ, maxZ)
    numTermsToPlot = maxZ-minZ+1
    !TODO:  Should support a rank one array to set Zernikes
    ! Like this for just minZ and MaxZ
    ! do i = 1,numTermsToPlot
    !     zlist(i) = minZ-1+i
    ! end do
    ! doing this would allow for mor complex entrys by user, such as 4,9,15,25 

    call LogTermFOR("MinZ "//trim(int2str(minZ)))
    call LogTermFOR("MaxZ "//trim(int2str(maxZ)))

    !minZ = 5
    !maxZ = 9
    !numTermsToPlot = 5    
    

    lambda = psm%getWavelengthSetting()
    inputCmd = trim(psm%generatePlotCommand())
    
    !inputCmd = trim(psm%sp%getCommand())      

    ! Compute Values
    allocate(xdat(numPoints))
    allocate(ydat(numPoints,maxZ-minZ+1))
    allocate(zLegend(size(ydat,2)))


    do ii = 0, numPoints-1
      xdat(ii+1) = REAL(ii)/REAL(numPoints-1)
      write(ffieldstr, *) xdat(ii+1)
      CALL PROCESKDP("FOB "// ffieldstr)
      CALL PROCESKDP("CAPFN")
      write(ffieldstr, *) lambda
      CALL PROCESKDP("FITZERN, "//ffieldstr)

      !CALL PROCESKDP("SHO RMSOPD")
      xdat(ii+1) = REAL(xdat(ii+1)*sysConfig%refFieldValue(2))
      ydat(ii+1,1:numTermsToPlot) = real(X(minZ:maxZ),4)
    end do

  
    ! Prep PLot
    canvas = hl_gtk_drawing_area_new(size=[1200,500], &
    & has_alpha=FALSE)
   
    call mplt%initialize(canvas, 1,1)
   
    call zernplot%initialize(c_null_ptr, xdat,ydat(:,1), &
    & xlabel=trim(sysConfig%getFieldText())//c_null_char, &
    & ylabel="Coefficient [waves]"//c_null_char, &
    & title='Zernike Coefficients vs Field'//c_null_char)
    zLegend(1) = 'Z'//trim(int2str(minZ))
    do ii=2,numTermsToPlot
      call zernplot%addXYPlot(xdat, ydat(:,ii))
      call zernplot%setDataColorCode(2+ii)
      zLegend(ii) = 'Z'//trim(int2str(minZ+ii-1))
    end do

    call zernplot%addLegend(zLegend)
    call mplt%set(1,1,zernplot)

    call logDataVsField(xdat, ydat, zLegend)


    ! Check for Mulitple Plots

    pIdx = psm%plotNum

    replot = .FALSE.
    if (pIdx /= -1 ) then
       replot = zoatabMgr%doesPlotExist_new(ID_PLOTTYPE_ZERN_VS_FIELD, objIdx, pIdx)
    end if


    !replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_ZERN_VS_FIELD, objIdx)
    if (replot) then
      call zoatabMgr%updateInputCommand(objIdx, inputCmd)
      call zoatabMgr%updateGenericMultiPlotTab(objIdx, mplt)
     else
      pIdx = zoatabMgr%getNumberOfPlotsByCode(ID_PLOTTYPE_ZERN_VS_FIELD)
     
      psm%plotNum = pIdx+1 ! Noreplot so this is the next num

      !TODO:  Fix this.  need to check if basecmd is multiple pieces or not
      psm%baseCmd = trim(psm%baseCmd)//" P"//int2str(psm%plotNum)
      tabName = "Zernike vs Field" 
      if  (psm%plotNum > 1) then
        tabName = trim(tabName)//" "//int2str(psm%plotNum)
      end if  
      objIdx = zoatabMgr%addGenericMultiPlotTab(ID_PLOTTYPE_ZERN_VS_FIELD, &
      & trim(tabName)//c_null_char, mplt)

      call zoaTabMgr%finalize_with_psm(objIdx, psm, trim(inputCmd))
      call zoaTabMgr%finalizeNewPlotTab(objIdx)

    end if

end subroutine


subroutine vie_go(psm)
    USE GLOBALS
    use command_utils
    use handlers, only: updateTerminalLog
    use zoa_ui
    use zoa_plot
    use iso_c_binding, only:  c_ptr, c_null_char
    use kdp_utils, only: OUTKDP, logDataVsField
    use type_utils, only: int2str, str2int
    use plot_setting_manager
    use DATMAI
    use g
    use handlers, only: zoatabMgr

    implicit none
    type(zoaplot_setting_manager) :: psm
    integer :: plot_code = ID_PLOTTYPE_LENSDRAW
    character(len=20) :: plotName = 'Lens Drawing'

    character(len=1024) :: inputCmd, tabName
    integer :: objIdx, pIdx
    logical :: replot


    call vie_psm(psm)



    pIdx = psm%plotNum
    inputCmd = trim(psm%generatePlotCommand())
    replot = .FALSE.
    if (pIdx /= -1 ) then
       replot = zoatabMgr%doesPlotExist_new(plot_code, objIdx, pIdx)
    end if


    !replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_ZERN_VS_FIELD, objIdx)
    if (replot) then
      call zoatabMgr%updateInputCommand(objIdx, inputCmd)
      call zoatabMgr%updateKDPPlotTab(objIdx)
     else
      pIdx = zoatabMgr%getNumberOfPlotsByCode(plot_code)
     
      psm%plotNum = pIdx+1 ! Noreplot so this is the next num

      !TODO:  Fix this.  need to check if basecmd is multiple pieces or not
      psm%baseCmd = trim(psm%baseCmd)//" P"//int2str(psm%plotNum)
      inputCmd = trim(psm%generatePlotCommand())
      tabName = plotName
      if  (psm%plotNum > 1) then
        tabName = trim(tabName)//" "//int2str(psm%plotNum)
      end if  
      objIdx = zoatabMgr%addKDPPlotTab(plot_code, &
      & trim(tabName)//c_null_char)

      !objIdx = zoatabMgr%addGenericMultiPlotTab(plot_code, &
      !& trim(tabName)//c_null_char, mplt)

      call zoaTabMgr%finalize_with_psm(objIdx, psm, trim(inputCmd))
      call zoaTabMgr%finalizeNewPlotTab(objIdx)
    end if

    


end subroutine

function getTabTextView(objIdx) result (dataTextView)
  use iso_c_binding, only: c_ptr, c_null_ptr
  use handlers, only: zoatabMgr
  use zoa_tab
  implicit none
  integer :: objIdx
  type (c_ptr) :: dataTextView

  type (zoaplotdatatab) :: tabTmp

  dataTextView = c_null_ptr

  select type (tabTmp => zoatabMgr%tabInfo(objIdx)%tabObj)
  type is (zoaplotdatatab)
     dataTextView = tabTmp%textView
     type is (zoadatatab)
     dataTextView = tabTmp%textView     

end select

end function

subroutine spo_go(psm)

    USE GLOBALS
    use command_utils
    use handlers, only: updateTerminalLog
    use global_widgets, only:  sysConfig, ioConfig
    use zoa_ui
    use zoa_plot
    use iso_c_binding, only:  c_ptr, c_null_char
    use kdp_utils, only: OUTKDP, logDataVsField
    use type_utils, only: int2str, str2int
    use plot_setting_manager
    use DATMAI
    use g


    IMPLICIT NONE

    type(multiplot) :: mplt
    type(zoaplot) :: xyscat1
    type(c_ptr) :: canvas

    type(zoaplot_setting_manager) :: psm

    integer :: iField, iLambda, iMethod, nRect, nRand, nRing
    integer :: objIdx
    logical :: replot


    call psm%getSpotDiagramSettings(iField, iLambda, iMethod, nRect, nRand, nRing)

    call initializeGoPlot(psm,ID_PLOTTYPE_SPOT_NEW, "Spot Diagram", replot, objIdx)

    ! Hopefully temporary 
    call ioConfig%setTextViewFromPtr(getTabTextView(objIdx))
    
    call LogTermDebug("Confirm before spot data written")
    print *, "Now look for active plot ptr"
    
    call PROCESKDP(trim(getKDPSpotPlotCommand(iField, iLambda, iMethod, nRect, nRand, nRing)))
    call LogTermDebug("Confirm after spot data written")
    call ioConfig%setTextView(ID_TERMINAL_DEFAULT)

    ! Prep PLot
    canvas = hl_gtk_drawing_area_new(size=[700,500], &
    & has_alpha=FALSE)
    
    ! Todo:  change initialization to sepcify size, and then don't need to 
    ! call gtk_drawing_area
    call mplt%initialize(canvas, 1,1)

    ! TODO:  remove dependency on canvas here after checking it doesn't break anything.
    call xyscat1%initialize(c_null_ptr, REAL(pack(DSPOTT(1,:), &
    &                                   DSPOTT(1,:) /= 0 .and. DSPOTT(2,:) /=0)), &
    &                                   REAL(pack(DSPOTT(2,:), &
    &                                   DSPOTT(1,:) /= 0 .and. DSPOTT(2,:) /=0)), &
    !call xyscat1%initialize(c_null_ptr, REAL(DSPOTT(1,:)), &
    !&                                   REAL(DSPOTT(2,:)), &
    & xlabel=sysConfig%lensUnits(sysConfig%currLensUnitsID)%text//c_null_char, &
    & ylabel=sysConfig%lensUnits(sysConfig%currLensUnitsID)%text//c_null_char, &
    !& xlabel=' (x)'//c_null_char, ylabel='(y)'//c_null_char, &
    & title='Spot Diagram'//c_null_char)
    call xyscat1%setLineStyleCode(-1)

    !Pseudo
    ! if (psm%autoScale == FALSE ) then
    ! xyscat1%autoScale = .FALSE.
    ! xyscat1%minY = 0
    ! xyscat1%maxY = psm%getScaleFactorInLensUnits()
    ! xyScat%minX = minY
    ! xyScat1%maxX = maxY




    call mplt%set(1,1,xyscat1)
    call finalizeGoPlot_new(mplt, psm, replot, objIdx)


    !call finalizeGoPlot(mplt, psm, ID_PLOTTYPE_SPOT_NEW, "Spot Diagram")

end subroutine


function getKDPSpotPlotCommand(iField, iLambda, iSpotCalcMethod, nGrid, nRand, nRing) result(plotCmd)
    use type_utils, only: int2str
    use zoa_ui
    use global_widgets, only: sysConfig
    implicit none
    integer, intent(in) :: iField, iLambda, iSpotCalcMethod
    integer, intent(in) :: nGrid, nRand, nRing

    character(len=80) :: charFLD
    character(len=80) :: charTrace
    character(len=1024) :: plotCmd
    integer :: i
  
    include "DATSP1.INC"

    WRITE(charFLD, *) "FOB ", &
    & sysConfig%relativeFields(2,iField) &
    & , ' ' , sysConfig%relativeFields(1,iField)
  
    call LogTermFOR("iSpotCalcMethod is "//int2str(iSpotCalcMethod))
    select case (iSpotCalcMethod)
    case (ID_SPOT_RAND)
      charTrace = "SPOT RAND;RANNUM "//trim(int2str(nRand))
    case (ID_SPOT_RECT)
      charTrace = "SPOT RECT;RECT "//trim(int2str(nGrid))
    case (ID_SPOT_RING)
      ! This is a bit of a hack.  redistribute ring number and rays per ring
      ! using KDP vars.  this should probably be moved to this type eventually
      do i=1,nRing
            RINGRAD(i) = (REAL(i)/nRing)*1D0
            RINGPNT(i) = INT(RINGRAD(i)*360)
      end do
     
      charTrace = "SPOT RING;RINGS "//int2str(nRing)

    end select
    plotCmd = trim(charFLD)//'; '//trim(charTrace)//";SPD "//trim(int2str(iLambda))
    call LogTermFOR("Plot Cmd is "//trim(plotCmd))
    PRINT *, "Plot command is ", trim(plotCMD)
  
  
end function

subroutine seidel_go(psm)
    USE GLOBALS
    use command_utils
    use handlers, only: updateTerminalLog
    use global_widgets, only:  curr_par_ray_trace, curr_lens_data, ioConfig
    use zoa_ui
    use zoa_plot
    use iso_c_binding, only:  c_ptr, c_null_char
    use kdp_utils, only: OUTKDP, logDataVsField
    use type_utils, only: int2str, str2int
    use plot_setting_manager
    use DATMAI


    IMPLICIT NONE

    type(zoaplot_setting_manager) :: psm
    integer, parameter :: nS = 7 ! number of seidel terms to plot
    real, allocatable, dimension(:,:) :: seidel
    real, allocatable, dimension(:) :: surfIdx
    
    character(len=23) :: ffieldstr
    character(len=40) :: inputCmd
    integer :: ii, objIdx, jj
    logical :: replot
    type(c_ptr) :: canvas
    type(barchart), dimension(nS) :: barGraphs
    integer, dimension(nS) :: graphColors
    type(multiplot) :: mplt
    character(len=100) :: strTitle
    character(len=20), dimension(nS) :: yLabels
    character(len=23) :: cmdTxt

    call initializeGoPlot(psm,ID_PLOTTYPE_SEIDEL, "Seidel Aberrations", replot, objIdx)
    
    call ioConfig%setTextViewFromPtr(getTabTextView(objIdx))
    CALL PROCESKDP('MAB3 ALL')
    call ioConfig%setTextView(ID_TERMINAL_DEFAULT)
    
    allocate(seidel(nS,curr_lens_data%num_surfaces+1))
    allocate(surfIdx(curr_lens_data%num_surfaces+1))
    
    
    
    yLabels(1) = "Spherical"
    yLabels(2) = "Coma"
    yLabels(3) = "Astigmatism"
    yLabels(4) = "Distortion"
    yLabels(5) = "Curvature"
    yLabels(6) = "Axial Chromatic"
    yLabels(7) = "Lateral Chromatic"
    
    
    print *, "Num Surfaces is ", curr_lens_data%num_surfaces
    
    graphColors = [PL_PLOT_RED, PL_PLOT_BLUE, PL_PLOT_GREEN, &
    & PL_PLOT_MAGENTA, PL_PLOT_CYAN, PL_PLOT_GREY, PL_PLOT_BROWN]
    
    
    
    surfIdx =  (/ (ii,ii=0,curr_lens_data%num_surfaces)/)
    seidel(:,:) = curr_par_ray_trace%CSeidel(:,0:curr_lens_data%num_surfaces)
    
     canvas = hl_gtk_drawing_area_new(size=[1200,800], &
     & has_alpha=FALSE)
    
    
     call mplt%initialize(canvas, 1,nS)
    
     do jj=1,nS
      call barGraphs(jj)%initialize(c_null_ptr, real(surfIdx),seidel(jj,:), &
      & xlabel='Surface No (last item actually sum)'//c_null_char, & 
      & ylabel=trim(yLabels(jj))//c_null_char, &
      & title=' '//c_null_char)
      call barGraphs(jj)%setDataColorCode(graphColors(jj))
      barGraphs(jj)%useGridLines = .FALSE.
     end do
    
     do ii=1,nS
      call mplt%set(1,ii,barGraphs(ii))
     end do
    
     call finalizeGoPlot_new(mplt, psm, replot, objIdx)
     !call finalizeGoPlot(mplt, psm, ID_PLOTTYPE_SEIDEL, "Seidel Aberrations")
  
    


end subroutine

subroutine ast_go(psm)

    USE GLOBALS
    use command_utils
    use handlers, only: updateTerminalLog
    use global_widgets, only:  sysConfig
    use zoa_ui
    use zoa_plot
    use iso_c_binding, only:  c_ptr, c_null_char
    use kdp_utils, only: OUTKDP, logDataVsField
    use type_utils, only: int2str, str2int
    use plot_setting_manager
    use DATMAI


    IMPLICIT NONE

    type(multiplot) :: mplt
    type(c_ptr) :: canvas
    type(zoaplot_setting_manager) :: psm
    character(len=80) :: ftext

    !integer(c_int), value, intent(in) :: win_width, win_height
    type(zoaplot) :: lin1, lin2, lin3

    integer :: numPts, numPtsDist, numPtsFC, idxFieldXY

     REAL:: DDTA(0:50), xDist(0:50), yDist(0:50), x1FC(0:50), x2FC(0:50), yFC(0:50)

     REAL:: FLDAN(0:50)

     !COMMON FLDAN, DDTA

     call psm%getAstigSettings(idxFieldXY, numPts)

     select case (idxFieldXY)
     case (ID_AST_FIELD_Y)
      ftext = ",0,,  "
     case (ID_AST_FIELD_X)
      ftext = ",90,, "
     case default
      ftext = ",0,,  "
     end select
     !CALL ITOAA(self%ast_numRays, A6)
     !self%astcalccmd = 'AST'//trim(ftext)//A6
     !PRINT *, "Num rays is ", self%ast_numRays
     !PRINT *, "ftext ", trim(ftext), " A6 ", A6
     !PRINT *, "COMMAND SENT TO KDP IN AST REPLOT IS ", 'AST'//trim(ftext)//A6

     CALL PROCESKDP('AST'//trim(ftext)//int2str(numPts))

     !self%distcalccmd = 'DIST'//trim(ftext)//A6
     !self%fccalccmd   = 'FLDCV'//trim(ftext)//A6

   

 call getFieldCalcResult(DDTA, X2FC, FLDAN, numPts, 1)
  !PRINT *, "DDTA is ", DDTA
  !PRINT *, "FLDAN is ", FLDAN

    canvas = hl_gtk_drawing_area_new(size=[1200,500], &
    & has_alpha=FALSE)
  call mplt%initialize(canvas, 3,1)

  call lin1%initialize(c_null_ptr, REAL(DDTA(0:numPts)),FLDAN(0:numPts), &
  & xlabel='Astigmatism (in)'//c_null_char, &
  & ylabel=sysConfig%lensUnits(sysConfig%currLensUnitsID)%text//c_null_char, &
  & title=''//c_null_char)



CALL PROCESKDP('DIST'//trim(ftext)//int2str(numPts))

 call getFieldCalcResult(xDist, x2FC, yDist, numPtsDist, 2)


  call lin2%initialize(c_null_ptr, REAL(xDist(0:numPtsDist)),yDist(0:numPtsDist), &
  & xlabel='Distortion (%)'//c_null_char, &
  & ylabel=sysConfig%lensUnits(sysConfig%currLensUnitsID)%text//c_null_char, &
  & title=''//c_null_char)

 CALL PROCESKDP('FLDCV'//trim(ftext)//int2str(numPts))
 call getFieldCalcResult(x1FC, x2FC, yFC, numPtsFC, 3)


  call lin3%initialize(c_null_ptr, REAL(x1FC(0:numPtsFC)),yFC(0:numPtsFC), &
  & xlabel='Field Curvature '//c_null_char, &
  & ylabel=sysConfig%lensUnits(sysConfig%currLensUnitsID)%text//c_null_char, &
  & title=''//c_null_char)
  call lin3%addXYPlot(X2FC(0:numPtsFC),FLDAN(0:numPtsFC))
  call lin3%setDataColorCode(PL_PLOT_BLUE)
  call lin3%setLineStyleCode(4)



  call mplt%set(1,1,lin1)
  call mplt%set(2,1,lin2)
  call mplt%set(3,1,lin3)


  call finalizeGoPlot(mplt, psm, ID_PLOTTYPE_AST, "Astig, FC, and Distortion")
  
  
end subroutine

subroutine rayaberration_go(psm)
    USE GLOBALS
    use command_utils
    use handlers, only: updateTerminalLog
    use global_widgets, only:  sysConfig, curr_ray_fan_data
    use type_utils, only: int2str
    use zoa_ui
    use zoa_plot
    use iso_c_binding, only:  c_ptr, c_null_char
    use plplot, PI => PL_PI
    use plplot_extra
    use plot_setting_manager
    use gtk, only: gtk_expander_set_expanded

    character(len=80) :: ffieldstr
    CHARACTER(LEN=*), PARAMETER  :: FMTFAN = "(I1, A1, I3)"
    integer :: lambda, fldIdx
    
    integer, parameter :: nlevel = 10

    type(c_ptr) :: canvas
    !type(zoaPlot3d) :: zp3d 
    type(zoaplot) :: lineplot
    type(multiplot) :: mplt
    type(zoaplot_setting_manager) :: psm
    REAL, allocatable :: x(:), y(:)

    lambda = psm%getWavelengthSetting()
    fldIdx = psm%getFieldSetting()
    numPoints = psm%getDensitySetting()

    
    allocate(x(numPoints))
    allocate(y(numPoints))
    
    ! Set Field
    WRITE(ffieldstr, *) "FOB ", sysConfig%relativeFields(2,fldIdx) &
    & , ' ' , sysConfig%relativeFields(1, fldIdx)
    CALL PROCESKDP(trim(ffieldstr))

    ! Set Fan Input - TODO:  add setting to change fan type
    write(ffieldstr, FMTFAN) lambda,',',numPoints
    

    !CALL PROCESKDP("XFAN, -1, 1, "//ffieldstr)
    !x = curr_ray_fan_data%relAper
    !y(1:numPoints,1) = curr_ray_fan_data%xyfan(1:numPoints,1)
    
    CALL PROCESKDP("YFAN, -1, 1, "//ffieldstr) 
    x = curr_ray_fan_data%relAper
    y(1:numPoints) = curr_ray_fan_data%xyfan(1:numPoints,2)
    
    ! FOB 1
    ! CALL PROCESKDP("FOB 1")
    ! CALL PROCESKDP("XFAN, -1, 1, "//ffieldstr)
    ! y(1:numPoints,3) = curr_ray_fan_data%xyfan(1:numPoints,1)
    ! CALL PROCESKDP("YFAN, -1, 1, "//ffieldstr) 
    ! y(1:numPoints,4) = curr_ray_fan_data%xyfan(1:numPoints,2)
    
    
    
    
     canvas = hl_gtk_drawing_area_new(size=[1200,500], &
     & has_alpha=FALSE)
    
    
     call mplt%initialize(canvas, 1,1)
    

     call lineplot%initialize(c_null_ptr, x,y, &
     & xlabel='Relative '//'Y'//' Pupil Position'//c_null_char, & 
     & ylabel='Y'//' Error ['// &
     & trim(sysConfig%lensUnits(sysConfig%currLensUnitsID)%text)//']'//c_null_char, &
     & title='Y '//c_null_char)
     !PRINT *, "Bar chart color code is ", bar1%dataColorCode
     
     
     call mplt%set(1,1,lineplot)

    
     call finalizeGoPlot(mplt, psm, ID_PLOTTYPE_RIM, "Ray Aberration Fan")
  
     
    


end subroutine

subroutine rmsfield_go(psm)
  USE GLOBALS
  use command_utils
  use handlers, only: updateTerminalLog
  use global_widgets, only:  sysConfig, curr_ray_fan_data
  use type_utils, only: int2str
  use zoa_ui
  use zoa_plot
  use iso_c_binding, only:  c_ptr, c_null_char
  use plplot, PI => PL_PI
  use plplot_extra
  use plot_setting_manager

IMPLICIT NONE

character(len=23) :: ffieldstr
integer :: ii, objIdx, iData, iLambda
integer :: numPoints
type(zoaplot) :: xyscat
type(c_ptr) :: canvas

REAL, allocatable :: x(:), y(:)
type(zoaplot_setting_manager) :: psm
type(multiplot) :: mplt

INCLUDE 'DATMAI.INC'

 !call checkCommandInput(ID_CMD_ALPHA)

 call updateTerminalLog(INPUT, "blue")

 call psm%getRMSFieldSettings(iData, iLambda, numPoints)
     

allocate(x(numPoints))
allocate(y(numPoints))

do ii = 0, numPoints-1
 x(ii+1) = REAL(ii)/REAL(numPoints-1)
 write(ffieldstr, *) x(ii+1)
 CALL PROCESKDP("FOB "// ffieldstr)
 select case(iData)

 case(ID_RMS_DATA_WAVE)
    CALL PROCESKDP("CAPFN")
    CALL PROCESKDP("SHO RMSOPD")
    y(ii+1) = 1000.0*REG(9)
 case(ID_RMS_DATA_SPOT)
  CALL PROCESKDP("SPD")
  CALL PROCESKDP("SHO RMS")
  y(ii+1) = REG(9)
 end select


 x(ii+1) = x(ii+1)*sysConfig%refFieldValue(2)

end do


canvas = hl_gtk_drawing_area_new(size=[1200,500], &
& has_alpha=FALSE)


call mplt%initialize(canvas, 1,1)

select case (iData)
case(ID_RMS_DATA_WAVE)

call xyscat%initialize(c_null_ptr, x,y, &
& xlabel=sysConfig%lensUnits(sysConfig%currLensUnitsID)%text//c_null_char, & 
& ylabel='RMS Error [mWaves]'//c_null_char, &
& title='RMS Error vs Field '//c_null_char)
case(ID_RMS_DATA_SPOT)
  call xyscat%initialize(c_null_ptr, x,y, &
  & xlabel=sysConfig%lensUnits(sysConfig%currLensUnitsID)%text//c_null_char, & 
  & ylabel="RMS ["//trim(sysConfig%getLensUnitsText())//"]"//c_null_char, &
  & title='Spot RMS Size vs Field'//c_null_char)
end select  

call mplt%set(1,1,xyscat)


call finalizeGoPlot(mplt, psm, ID_PLOTTYPE_RMSFIELD, "RMS vs Field")

end subroutine

subroutine pma_go(psm)

    USE GLOBALS
    use command_utils
    use handlers, only: updateTerminalLog
    use global_widgets, only:  sysConfig, curr_opd
    use type_utils, only: int2str
    use zoa_ui
    use zoa_plot
    use iso_c_binding, only:  c_ptr, c_null_char
    use plplot, PI => PL_PI
    use plplot_extra
    use plot_setting_manager
    use gtk, only: gtk_expander_set_expanded
  
  
  IMPLICIT NONE
  
  character(len=1024) :: ffieldstr
  type(zoaplot_setting_manager) :: psm
  
  ! desirable commands
  ! n - density
  ! w - wavelength
  ! f - field
  ! s - surface (i=image, o=object)
  ! p - plot (future implementation eg image vs 3d Plot)
  ! azi alt - azimuth and altitude for 3d plot
  ! eg PLTOPD n64 w1 f3 si p0 azi30 alt60
  
  
  !REAL, allocatable :: x(:), y(:)
  
  
      !   xdim is the leading dimension of z, xpts <= xdim is the leading
      !   dimension of z that is defined.
  integer :: xpts, ypts
  integer, parameter :: xdim=99, ydim=100 
  integer :: lambda, fldIdx
  
  integer, parameter :: nlevel = 10

  type(c_ptr) :: canvas
  !type(zoaPlot3d) :: zp3d 
  type(zoaPlotImg) :: zp3d 
  type(multiplot) :: mplt
  

  lambda = psm%getWavelengthSetting()
  fldIdx = psm%getFieldSetting()
  xpts = psm%getDensitySetting()
  ypts = xpts


  PRINT *, "fldIdx is ", fldIdx
  WRITE(ffieldstr, *) "FOB ", sysConfig%relativeFields(2,fldIdx) &
  & , ' ' , sysConfig%relativeFields(1, fldIdx)
  CALL PROCESKDP(trim(ffieldstr))
  
  !CALL PROCESKDP('FOB 1')
  PRINT *, "Calling CAPFN"
  call PROCESKDP('CAPFN, '//trim(int2str(xpts)))
  !call getOPDData(lambda)
  !PRINT *, "Calling OPDLOD"
  call PROCESKDP('FITZERN, '//trim(int2str(lambda)))
  !call OPDLOD
  
  
  
   !call checkCommandInput(ID_CMD_ALPHA)
  
  canvas = hl_gtk_drawing_area_new(size=[600,600], &
  & has_alpha=FALSE)
  
  call mplt%initialize(canvas, 1,1)
  PRINT *, "size of X is ", size(curr_opd%X)
  !PRINT *, "X is ", real(curr_opd%X)
   call zp3d%init3d(c_null_ptr, real(curr_opd%X),real(curr_opd%Y), & 
   & real(curr_opd%Z), xpts, ypts, & 
   & xlabel='X'//c_null_char, ylabel='Y'//c_null_char, &
   & title='Optical Path Difference'//c_null_char)
  
   call mplt%set(1,1,zp3d)
  
  
   call finalizeGoPlot(mplt, psm, ID_PLOTTYPE_OPD, "Optical Path Difference")
  
  

end subroutine


subroutine initializeGoPlot(psm, plot_code, plotName, replot, objIdx) 

    use zoa_plot    
    use plot_setting_manager
    use handlers, only: zoatabMgr
    use type_utils, only: int2str

    implicit none
    type(zoaplot_setting_manager) :: psm
    integer :: plot_code
    character(len=*) :: plotName

    character(len=1024) :: inputCmd, tabName
    integer :: pIdx
    integer, intent(out) :: objIdx
    logical, intent(out) :: replot

    pIdx = psm%plotNum
    inputCmd = trim(psm%generatePlotCommand())
    replot = .FALSE.
    if (pIdx /= -1 ) then
       replot = zoatabMgr%doesPlotExist_new(plot_code, objIdx, pIdx)
    end if


    !replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_ZERN_VS_FIELD, objIdx)
    if (replot) then
      call zoatabMgr%updateInputCommand(objIdx, inputCmd)
      call zoatabMgr%clearDataTab(objIdx)
     else
      pIdx = zoatabMgr%getNumberOfPlotsByCode(plot_code)
     
      psm%plotNum = pIdx+1 ! Noreplot so this is the next num

      !TODO:  Fix this.  need to check if basecmd is multiple pieces or not
      psm%baseCmd = trim(psm%baseCmd)//" P"//int2str(psm%plotNum)
      inputCmd = trim(psm%generatePlotCommand())
      tabName = plotName
      if  (psm%plotNum > 1) then
        tabName = trim(tabName)//" "//int2str(psm%plotNum)
      end if  
      
      objIdx = zoatabMgr%addMultiPlotTab(plot_code, &
      & trim(tabName)//c_null_char)
      call zoatabMgr%updateInputCommand(objIdx, inputCmd)
    end if


  end subroutine

  subroutine finalizeGoPlot_new(mplt,psm, replot, objIdx)
    use zoa_plot    
    use plot_setting_manager
    use handlers, only: zoatabMgr

    implicit none
    type(multiplot) :: mplt
    type(zoaplot_setting_manager) :: psm

    integer :: objIdx
    logical :: replot

    call zoatabMgr%updateGenericMultiPlotTab(objIdx, mplt) 
    if(replot .EQV. .FALSE. ) then 
      call zoaTabMgr%finalize_with_psm(objIdx, psm)
      call zoaTabMgr%finalizeNewPlotTab(objIdx)
    end if

  end subroutine


! This sub checks for whether a replot is needed or whether 
! this is a new plot, 
! If new plot, andcalls the finalize subs in 
! Zoa tab manager
subroutine finalizeGoPlot(mplt, psm, plot_code, plotName)
    use zoa_plot    
    use plot_setting_manager
    use handlers, only: zoatabMgr
    use type_utils, only: int2str

    implicit none
    type(multiplot) :: mplt
    type(zoaplot_setting_manager) :: psm
    integer :: plot_code
    character(len=*) :: plotName

    character(len=1024) :: inputCmd, tabName
    integer :: objIdx, pIdx
    logical :: replot

    pIdx = psm%plotNum
    inputCmd = trim(psm%generatePlotCommand())
    replot = .FALSE.
    if (pIdx /= -1 ) then
       replot = zoatabMgr%doesPlotExist_new(plot_code, objIdx, pIdx)
    end if


    !replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_ZERN_VS_FIELD, objIdx)
    if (replot) then
      call zoatabMgr%updateInputCommand(objIdx, inputCmd)
      call zoatabMgr%updateGenericMultiPlotTab(objIdx, mplt)
     else
      pIdx = zoatabMgr%getNumberOfPlotsByCode(plot_code)
     
      psm%plotNum = pIdx+1 ! Noreplot so this is the next num

      !TODO:  Fix this.  need to check if basecmd is multiple pieces or not
      psm%baseCmd = trim(psm%baseCmd)//" P"//int2str(psm%plotNum)
      inputCmd = trim(psm%generatePlotCommand())
      tabName = plotName
      if  (psm%plotNum > 1) then
        tabName = trim(tabName)//" "//int2str(psm%plotNum)
      end if  
      objIdx = zoatabMgr%addGenericMultiPlotTab(plot_code, &
      & trim(tabName)//c_null_char, mplt)

      call zoaTabMgr%finalize_with_psm(objIdx, psm, trim(inputCmd))
      call zoaTabMgr%finalizeNewPlotTab(objIdx)
    end if



end subroutine
  

end module