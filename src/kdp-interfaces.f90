module kdp_interfaces

contains

subroutine POWSYM


   use global_widgets
   use handlers, only : updateTerminalLog
    use zoa_plot
    !use mod_plotopticalsystem


  integer(kind=c_int) :: ipick, i, endSurface, ii
 character(len=100) :: ftext, strTitle
 CHARACTER(LEN=*), PARAMETER  :: FMT1 = "(I5, F10.3, F10.3)"
 CHARACTER(LEN=*), PARAMETER  :: FMTHDR = "(A12, A5, A5)"
 character(len=100) :: conLong
 real, ALLOCATABLE :: w(:), symcalc(:)
 real :: w_sum, s_sum, aplanatic, imageNA
 integer :: totalSurfaces
 integer, ALLOCATABLE ::  surfaceno(:)


   PRINT *, "New Command POWSYM in kdp_interfaces!"


  !PRINT *, "Before Mod Call, ", my_window

  !ipick = hl_gtk_file_chooser_show(new_files, &
  !       & create=FALSE, multiple=TRUE, filter=["image/*"], &
  !       & parent=my_window, all=TRUE)

  !ftext = 'LIB GET 1 '
  !ftext = 'CV2PRG DoubleGauss.seq'
  ! ftext = 'CV2PRG LithoBraat.seq'
  !
  ! CALL PROCESKDP(ftext)
  !
  ! ftext = 'RTG ALL'
  ! CALL PROCESKDP(ftext)
  !
  !
  ! ftext = 'COLORSET RAYS 6'
  ! CALL PROCESKDP(ftext)
  ! call getOpticalSystemLastSurface(endSurface)
  ! call ld_settings%set_end_surface(endSurface)
  ! ftext = 'VIECO'
  ! CALL PROCESKDP(ftext)
  !
  ! ftext = 'PXTY ALL'
  ! CALL PROCESKDP(ftext)
  !
  ! ftext = 'OCDY'
  ! CALL PROCESKDP(ftext)


PRINT *, "Magnification is ", curr_par_ray_trace%t_mag




  ! Compute lens weight and symmetry
  allocate(w(curr_lens_data % num_surfaces-2))
  allocate(symcalc(curr_lens_data % num_surfaces-2))
  allocate(surfaceno(curr_lens_data % num_surfaces-2))

  PRINT *, "SIZE OF w is ", size(w)
  PRINT *, "SIZE of no_surfaces is ", size(surfaceno)

  WRITE(conLong, FMTHDR) "Surface", "w_j", "s_j"
  call updateTerminalLog(conLong, "black")


  do ii = 2, curr_lens_data % num_surfaces - 1
     w(ii-1) = -1/(1-curr_par_ray_trace%t_mag)
     w(ii-1) = w(ii-1) * (curr_lens_data % surf_index(ii) - curr_lens_data % surf_index(ii-1)) &
     & * curr_par_ray_trace % marginal_ray_height(ii) * curr_lens_data % curvatures(ii) &
     & / curr_lens_data % surf_index(curr_lens_data % num_surfaces) &
     & / curr_par_ray_trace % marginal_ray_angle(curr_lens_data % num_surfaces)
     w_sum = w_sum + w(ii-1)*w(ii-1)

     !PRINT *, "Check Ref Stop ", curr_lens_data % ref_stop
    !PRINT *, "SURF INDEX ", curr_lens_data % surf_index(ii)
    !PRINT *, "AOI is ", curr_par_ray_trace % chief_ray_aoi(ii)
    !allocate(symcalc(curr_lens_data % num_surfaces-2))

      totalSurfaces = curr_lens_data % num_surfaces
      aplanatic = curr_par_ray_trace % marginal_ray_angle(ii) / curr_lens_data % surf_index(ii)
      aplanatic = aplanatic - curr_par_ray_trace % marginal_ray_angle(ii-1) / curr_lens_data % surf_index(ii-1)
      imageNA = curr_lens_data%surf_index(totalSurfaces) * curr_par_ray_trace%marginal_ray_angle(totalSurfaces)

      !PRINT *, "IMAGE NA is ", imageNA
      !PRINT *, "APLANATIC IS ", aplanatic
      !PRINT *, "Marginal Ray Angle is ", curr_par_ray_trace % marginal_ray_angle(ii)
      !PRINT *, "Surface Index is ", curr_lens_data % surf_index(ii)
      symcalc(ii-1) = 1/(1-curr_par_ray_trace%t_mag)
      ! symcalc(ii-1) = symcalc(ii-1) * aplanatic * curr_lens_data % surf_index(ii) * curr_par_ray_trace % chief_ray_aoi(ii) &
      ! & / ((curr_lens_data % surf_index(curr_lens_data%ref_stop)* curr_par_ray_trace % chief_ray_aoi(curr_lens_data%ref_stop)) &
      ! & * imageNA)

      symcalc(ii-1) = symcalc(ii-1) * curr_lens_data % surf_index(ii-1) * curr_par_ray_trace % chief_ray_aoi(ii)

      !PRINT *, "FIrst Term is ", symcalc(ii-1)

      symcalc(ii-1) = symcalc(ii-1) /curr_lens_data%surf_index(curr_lens_data%ref_stop)
      symcalc(ii-1) = symcalc(ii-1) /curr_par_ray_trace%chief_ray_aoi(curr_lens_data%ref_stop)
      symcalc(ii-1) = symcalc(ii-1)*aplanatic/imageNA


      s_sum = s_sum + symcalc(ii-1)*symcalc(ii-1)

      surfaceno(ii-1) = ii-1

      WRITE(conLong, FMT1) surfaceno(ii-1), w(ii-1), symcalc(ii-1)
      call updateTerminalLog(conLong, "black")


  end do

  w_sum = SQRT(w_sum/(curr_lens_data % num_surfaces-2))
  s_sum = SQRT(s_sum/(curr_lens_data % num_surfaces-2))

  !PRINT *, " w is ", w
  WRITE(conLong, *) " w_sum is ", w_sum
  call updateTerminalLog(conLong, "black")

  !PRINT *, " s is ", symcalc
  WRITE(conLong, *) " s_sum is ", s_sum
  call updateTerminalLog(conLong, "black")

    !call barchart2(x,y)
    ! print *, "Calling Plotter"
     !plotter = barchart(drawing_area_plot,surfaceno,abs(w))
     !call plotter % initialize(drawing_area_plot,surfaceno,abs(w))

     ! call plotter % setxlabel
     ! call plotter % setMajorGridLines(TRUE)

     !call plotter % drawPlot()
    ! print *, "Done calling plotter"

  !PRINT *, "Paraxial Data tst ", curr_par_ray_trace%marginal_ray_height

! Multiplot
  call POWSYM_PLOT(surfaceno, w, w_sum, symcalc, s_sum)


end subroutine POWSYM

subroutine POWSYM_PLOT(surfaceno, w, w_sum, symcalc, s_sum)

   use global_widgets

  use zoa_plot
  use zoa_tab
  use gtk_draw_hl
  !use zoa_tab_manager
  use handlers
  implicit none

 real, intent(in) :: w(:), symcalc(:)
 real, intent(in) :: w_sum, s_sum
 integer, intent(in) ::  surfaceno(:)

 character(len=100) :: strTitle
  type(barchart) :: bar1, bar2
  type(multiplot) :: mplt
  type(c_ptr) :: localcanvas
  type(zoatab) :: powsym_tab

  PRINT *, "About to init POWSYM Tab"
  PRINT *, "NOTEBOOK PTR IS ", notebook
  call powsym_tab%initialize(notebook, "Power and Symmetry", -1)
  !call zoaTabMgr%addPlotTab("Power and Symmetry", ID_PLOTTYPE_GENERIC)

  !tabObj = zoaTabMgr%addPlotTab("Power and Symmetry", ID_PLOTTYPE_GENERIC)
  !tabObj%getCanvas() or tabObj%setCanvas(localCanvas)
  !....
  !tabObj%finalizeWindow

    localcanvas = hl_gtk_drawing_area_new(size=[1200,500], &
         & has_alpha=FALSE)

  powsym_tab%canvas = localcanvas
  !powsym_tab = zoatabMgr%addPlotTab(-1, "Power and Symmetry", localcanvas)

  PRINT *, "POWSYM Initialized!"

  WRITE(strTitle, "(A15, F10.3)") "Power:  w = ", w_sum
  call mplt%initialize(powsym_tab%canvas, 2,1)
  !call mplt%initialize(drawing_area_plot, 2,1)
  PRINT *, "MPLOT INITIALIZED!"
  call bar1%initialize(c_null_ptr, real(surfaceno),abs(w), &
  & xlabel='Surface No'//c_null_char, ylabel='w'//c_null_char, &
  & title=trim(strTitle)//c_null_char)
  !PRINT *, "Bar chart color code is ", bar1%dataColorCode
  WRITE(strTitle, "(A15, F10.3)") "Symmetry:  s = ", s_sum
  call bar2%initialize(c_null_ptr, real(surfaceno),abs(symcalc), &
  & xlabel='Surface No'//c_null_char, ylabel='s'//c_null_char, &
  & title=trim(strTitle)//c_null_char)
  call bar2%setDataColorCode(PL_PLOT_BLUE)
  call mplt%set(1,1,bar1)
  call mplt%set(2,1,bar2)
  call mplt%draw()

  PRINT *, "ABOUT TO FINALIZE NEW TAB!"
  call powsym_tab%finalizeWindow()


end subroutine

subroutine SPR

    USE GLOBALS
    use command_utils
    use handlers, only: zoatabMgr, updateTerminalLog
    use global_widgets, only:  sysConfig
    use zoa_ui
    use iso_c_binding, only:  c_ptr, c_null_char


    IMPLICIT NONE

    character(len=23) :: ffieldstr
    character(len=40) :: inputCmd
    integer :: ii, objIdx
    integer :: numPoints = 10
    logical :: replot


    REAL, allocatable :: x(:), y(:)

    INCLUDE 'DATMAI.INC'

    !call checkCommandInput(ID_CMD_ALPHA)

    call updateTerminalLog(INPUT, "blue")
    inputCmd = INPUT

    if(cmdOptionExists('NUMPTS')) then
    numPoints = INT(getCmdInputValue('NUMPTS'))
    end if


    PRINT *, "numPoints is ", numPoints

    allocate(x(numPoints))
    allocate(y(numPoints))

    do ii = 0, numPoints-1
      x(ii+1) = REAL(ii)/REAL(numPoints-1)
      write(ffieldstr, *) x(ii+1)
      CALL PROCESKDP("FOB "// ffieldstr)
      CALL PROCESKDP("SPD")
      !CALL PROCESKDP("SHO RMSOPD")
      y(ii+1) = REG(10)
    end do

    replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_SPOT_VS_FIELD, objIdx)

    if (replot) then
    PRINT *, "SPOT RMS VS FIELD REPLOT REQUESTED"
    PRINT *, "Input Command was ", inputCmd
    call zoatabMgr%updateInputCommand(objIdx, inputCmd)
    !zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd

    call zoatabMgr%updateGenericPlotTab(objIdx, x, y)

    else
    objIdx = zoatabMgr%addGenericPlotTab(ID_PLOTTYPE_SPOT_VS_FIELD, "Spot RMS vs Field"//c_null_char, x,y, &
    & xlabel=trim(sysConfig%getFieldText())//c_null_char, &
      & ylabel="RMS ["//trim(sysConfig%getLensUnitsText())//"]"//c_null_char, &
      & title='Spot RMS Size vs Field'//c_null_char, linetypecode=-1)

    ! Add settings
    zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd
    call zoaTabMgr%tabInfo(objIdx)%tabObj%addSpinButton_runCommand("Number of Field Points", &
    & 10.0, 1.0, 20.0, 1, "NUMP2"//c_null_char)
    call zoaTabMgr%tabInfo(objIdx)%tabObj%addSpinButton_runCommand("Test2", 1.0, 0.0, 10.0, 1, "")

    ! Create Plot + settings tab
    call zoaTabMgr%finalizeNewPlotTab(objIdx)


    end if

end subroutine

subroutine FIR
  use GLOBALS
  use parax_calcs
  use global_widgets

  implicit none
  real :: epRad, epPos

  call calcExitPupil(epRad, epPos)
  !PRINT *, "Angle is ", curr_par_ray_trace % marginal_ray_angle(curr_lens_data % num_surfaces)

  call logger%logText("FIR Called!")

  PRINT *, "Magnification is ", curr_par_ray_trace%t_mag


end subroutine

subroutine RMSFIELD
use GLOBALS
use global_widgets
use handlers, only : updateTerminalLog
 use zoa_plot
   character(len=23) :: ffieldstr
   integer :: ii
   integer :: numPoints = 10

   INCLUDE 'DATMAI.INC'

   ! do ii = 0, numPoints
   !   write(ffieldstr, *), REAL(ii)/REAL(numPoints)
   !   CALL PROCESKDP("FOB "// ffieldstr)
   !   CALL PROCESKDP("CAPFN")
   !   CALL PROCESKDP("SHO RMSOPD")
   !
   !   PRINT *, "REG9 9 is ", REG(9)
   !
   !   !PRINT *, "FOB " // ffieldstr
   !
   ! end do


   call logger%logText('RMSField Routine Starting')



   !call RMSFIELD_PLOT
   call rmsfield_ideal

end subroutine

subroutine RMSFIELD_PLOT
   use global_widgets

  use zoa_plot
  use zoa_tab
  use zoa_ui
  !use zoa_tab_manager
  use gtk_draw_hl
  !use zoa_tab_manager
  use handlers
  implicit none
  type(c_ptr) :: localcanvas

  !  localcanvas = hl_gtk_drawing_area_new(size=[1200,500], &
  !       & has_alpha=FALSE)


  !call zoatabMgr%addPlotTab(ID_PLOTTYPE_RMSFIELD, inputTitle='RMS Field Plot', extcanvas=localcanvas)
  call PROCESKDP('PLOT NEW') ! This needs to be called at some point
  call PROCESKDP('DRAW')

end subroutine

subroutine EDITOR
  use lens_editor
  use global_widgets
  use handlers

    if (.not. c_associated(lens_editor_window))  THEN
       PRINT *, "Call New Lens Editor Window"
       call lens_editor_new(my_window)
       PRINT *, "Lens editor call finished!"
    else
      PRINT *, "Do nothing..lens editor exists. "

    end if



end subroutine EDITOR


subroutine SYSCONFIGUI
  use ui_sys_config
  use global_widgets
  use handlers

    if (.not. c_associated(sys_config_window))  THEN
       PRINT *, "Call New Sys Config Window"
       call sys_config_new(my_window)

    else
      PRINT *, "Do nothing..sys config window exists. "

    end if

end subroutine


SUBROUTINE RUN_WDRAWOPTICALSYSTEM
!     THIS IS THE DRIVER ROUTINE FOR SENDING GRAPHICS TO
!     A GRAPHIC WINDOW
      !USE WINTERACTER
      IMPLICIT NONE
      LOGICAL EXISD
      !INCLUDE 'DATMAI.INC'
      !CALL WDRAWOPTICALSYSTEM
      RETURN
END SUBROUTINE RUN_WDRAWOPTICALSYSTEM

!pseudocode for rms_field minimal effort
! One method that processes inputs and provides x,y data (possible?)
! RMSFIELD_XY
! code to get x and y series from data
! ask zoaTabMgr if plotCode exists
! if yes, then this is a replot call.  Attach xy data to obj and call replot
! if no, then this is a new plot call.  create object (include title, x/y label, etc) and
! call addPlot in zoatabmgr
! For this, should move all settings into settings object and replot into zoaTab obj?
! this works if I only use commands for settings, then replot has an easier time.  Just
! assume have new xy or label data for that matter and redo.
! With this, just need to make methods and add new ID to zoa_ui.  Much cleaner.

subroutine rmsfield_ideal

       USE GLOBALS
       use command_utils
       use handlers, only: zoatabMgr, updateTerminalLog
       use global_widgets, only:  sysConfig
       use zoa_ui
       use iso_c_binding, only:  c_ptr, c_null_char


  IMPLICIT NONE

  character(len=23) :: ffieldstr
  character(len=40) :: inputCmd
  integer :: ii, objIdx
  integer :: numPoints = 10
  logical :: replot


    REAL, allocatable :: x(:), y(:)

    INCLUDE 'DATMAI.INC'

      !call checkCommandInput(ID_CMD_ALPHA)

      call updateTerminalLog(INPUT, "blue")
      inputCmd = INPUT

    if(cmdOptionExists('NUMPTS')) then
      numPoints = INT(getCmdInputValue('NUMPTS'))
    end if


    PRINT *, "numPoints is ", numPoints

    allocate(x(numPoints))
    allocate(y(numPoints))

    do ii = 0, numPoints-1
      x(ii+1) = REAL(ii)/REAL(numPoints-1)
      write(ffieldstr, *) x(ii+1)
      CALL PROCESKDP("FOB "// ffieldstr)
      CALL PROCESKDP("CAPFN")
      CALL PROCESKDP("SHO RMSOPD")
      y(ii+1) = 1000.0*REG(9)
    end do

    replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_RMSFIELD, objIdx)

    if (replot) then
      PRINT *, "RMS FIELD REPLOT REQUESTED"
      PRINT *, "Input Command was ", inputCmd
      call zoatabMgr%updateInputCommand(objIdx, inputCmd)
      !zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd

      call zoatabMgr%updateGenericPlotTab(objIdx, x, y)

    else
      objIdx = zoatabMgr%addGenericPlotTab(ID_PLOTTYPE_RMSFIELD, "RMS vs Field"//c_null_char, x,y, &
      & xlabel=sysConfig%lensUnits(sysConfig%currLensUnitsID)%text//c_null_char, &
         & ylabel='RMS Error [mWaves]'//c_null_char, &
         & title='Wavefront Error vs Field'//c_null_char, linetypecode=-1)

      ! Add settings
      zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd
      call zoaTabMgr%tabInfo(objIdx)%tabObj%addSpinButton_runCommand("Number of Field Points", &
      & 10.0, 1.0, 20.0, 1, "NUMPTS"//c_null_char)
      call zoaTabMgr%tabInfo(objIdx)%tabObj%addSpinButton_runCommand("Test2", 1.0, 0.0, 10.0, 1, "")

      ! Create Plot + settings tab
      call zoaTabMgr%finalizeNewPlotTab(objIdx)


    end if

end subroutine

end module kdp_interfaces
