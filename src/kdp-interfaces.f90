module kdp_interfaces

contains

subroutine POWSYM


   use global_widgets
   use handlers, only : updateTerminalLog
    use zoa_plot
    !use mod_plotopticalsystem


  integer(kind=c_int) :: ii
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
  !call POWSYM_PLOT(surfaceno, w, w_sum, symcalc, s_sum)
  call powsym_ideal(surfaceno, w, w_sum, symcalc, s_sum)


end subroutine POWSYM

subroutine Sandbox()
  use DATLEN, only: ALENS, SYSTEM
  use codeV_commands, only: execRestore
  use zoa_file_handler

  implicit none

  real*8 ALENSCV(1:160,0:499), ALENSZOA(1:160,0:499)
  real*8 ALENSDIFF(1:160,0:499)
  REAL*8 SYSCV(1:150), SYSZOA(1:150), SYSDIFF(1:150)
  integer :: ii


  call PROCESKDP("CV2PRG LithoKotaro.seq")
  ALENSCV = ALENS
  SYSCV = SYSTEM
  call PROCESKDP('res kdebug2')
  ALENSZOA = ALENS
  SYSZOA = SYSTEM

  ALENSDIFF = ALENSCV-ALENSZOA
  SYSDIFF = SYSCV - SYSZOA
  do ii=1,144
    print *, "ALENS DIFF ", ii
    print *, "", ALENSDIFF(ii,0:61)
  end do
  !   print *, "ALENSDIFF ", ALENSDIFF(1,1:150)
  !print *, "ALENSDIFF ", ALENSDIFF(3,1:150)
  !print *, "CONICDIFF ", ALENSDIFF(2,1:150)
  do ii=1,150
    print *, ii, SYSDIFF(ii)
  end do
  !print *, "SYSDIFF ", SYSDIFF




end subroutine


subroutine Sandbox_old()
  !use kdp_data_types, only: check_clear_apertures
  !use global_widgets
  use codeV_commands, only: execRestore
  use zoa_file_handler


  implicit none

        ! Restore lens from new save file system
        !call execRestore('RES '//trim(getTempDirectory())//'currlens.zoa')  
        call process_zoa_file(trim(getTempDirectory())//'currlens.zoa')
  
  !call printFilesInCurrentDirectory()

  !use optim_debug

  !call check_clear_apertures(curr_lens_data)
  !call simple_matlab_link()
  !call test_slsqp

  ! C code
  ! GDir *dir;
  ! GError *error;
  ! const gchar *filename;
  
  ! dir = g_dir_open(".", 0, &error);
  ! while ((filename = g_dir_read_name(dir)))
  !     printf("%s\n", filename);

end subroutine

! This routine needs to be rewritten to be similar to the
! rmsfield plot once the interface supports multiplots
! Since it is outside the desired infrastructure it doesn't
! support refresh plots or any settings
subroutine POWSYM_PLOT(surfaceno, w, w_sum, symcalc, s_sum)

   use global_widgets

  use zoa_plot
  use zoa_tab
  use gtk_draw_hl
  !use zoa_tab_manager
  use handlers, only: zoatabMgr, updateTerminalLog

  implicit none

 real, intent(in) :: w(:), symcalc(:)
 real, intent(in) :: w_sum, s_sum
 integer, intent(in) ::  surfaceno(:)

 character(len=100) :: strTitle
  type(barchart) :: bar1, bar2
  type(multiplot) :: mplt
  type(c_ptr) :: localcanvas
  type(zoaplottab) :: powsym_tab

    type(c_ptr) :: currPage
    integer(kind=c_int) :: currPageIndex
    integer :: idx
    character(len=3) :: outChar

  !PRINT *, "About to init POWSYM Tab"
  !PRINT *, "NOTEBOOK PTR IS ", LOC(notebook)
  call powsym_tab%initialize(notebook, "Power and Symmetry", -1)
  idx = zoatabMgr%findTabIndex()
  !call zoaTabMgr%addPlotTab("Power and Symmetry", ID_PLOTTYPE_GENERIC)

  !tabObj = zoaTabMgr%addPlotTab("Power and Symmetry", ID_PLOTTYPE_GENERIC)
  !tabObj%getCanvas() or tabObj%setCanvas(localCanvas)
  !....
  !tabObj%finalizeWindow

    localcanvas = hl_gtk_drawing_area_new(size=[1200,500], &
         & has_alpha=FALSE)

  powsym_tab%canvas = localcanvas
  !powsym_tab = zoatabMgr%addPlotTab(-1, "Power and Symmetry", localcanvas)

  !PRINT *, "POWSYM Initialized!"

  WRITE(strTitle, "(A15, F10.3)") "Power:  w = ", w_sum
  call mplt%initialize(powsym_tab%canvas, 2,1)
  !call mplt%initialize(drawing_area_plot, 2,1)
  !PRINT *, "MPLOT INITIALIZED!"
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



  PRINT *, "ABOUT TO FINALIZE NEW TAB! Power Symmetry plot!"
  call powsym_tab%finalizeWindow()
  PRINT *, "After finalize window in power symmetry plot"

    ! Until this is ported to the new functionality, hard
    ! code an idx so the app doesn't crash if the user tries to
    ! close a tab
    currPageIndex = gtk_notebook_get_current_page(notebook)
    currPage = gtk_notebook_get_nth_page(notebook, currPageIndex)
    WRITE(outChar, '(I0.3)') idx
    call gtk_widget_set_name(currPage, outChar//c_null_char)

end subroutine

subroutine SPR

end subroutine

subroutine FIR
  use GLOBALS
  use parax_calcs
  use global_widgets
  use iso_fortran_env, only: real64
  use type_utils, only: real2str
  use handlers, only: updateTerminalLog

  implicit none
  !real(kind=real64) :: epRad, epPos

  include "DATMAI.INC"

  ! TODO:  This needs cleanup
  ! All these values should be calculated elsewhere
  ! Make sure that calcs are correct for all focal/afocal conditions

  !call calcExitPupil(epRad, epPos)
  call curr_lens_data%update()
  !PRINT *, "num surfaces is ", curr_lens_data%num_surfaces
  !call LogTermFOR("Exit Pupil Radius is "//real2str(epRad))
  !PRINT *, "Angle is ", curr_par_ray_trace % marginal_ray_angle(curr_lens_data % num_surfaces)

  !call logger%logText("FIR Called!")

  PRINT *, "Magnification is ", curr_par_ray_trace%t_mag

  call curr_par_ray_trace%calculateFirstOrderParameters(curr_lens_data)

  !print *, "Is Object at Infinity? ", sysConfig%isObjectAfInf()
  call updateTerminalLog("ENTRANCE PUPIL", "blue")
  call updateTerminalLog("DIA       "//trim(real2str(curr_par_ray_trace%ENPUPDIA,4)),"blue")
  call updateTerminalLog("THI       "//trim(real2str(curr_par_ray_trace%ENPUPPOS,4)),"blue")

  call updateTerminalLog("INFINITE CONJUGATES", "blue")
  call updateTerminalLog("EFL       "//trim(real2str(curr_par_ray_trace%EFL,4)),"blue")
  call updateTerminalLog("BFL       "//trim(real2str(curr_par_ray_trace%BFL,4)),"blue")
  call updateTerminalLog("FFL       "//trim(real2str(curr_par_ray_trace%FFL,4)),"blue")
  
  if (sysConfig%isObjectAfInf()) then
    call updateTerminalLog("FNO       "//trim(real2str(curr_par_ray_trace%FNUM,4)),"blue")
  call updateTerminalLog("IMG DIS   "//trim(real2str(curr_par_ray_trace%imageDistance,4)),"blue")
  call updateTerminalLog("OAL       "//trim(real2str(curr_par_ray_trace%OAL,4)),"blue")
  call updateTerminalLog("PARAXIAL IMAGE", "blue")
  ! TODO:  Move this calc somewhere else
  call PROCESKDP("GET GPCY")
  call updateTerminalLog(" HT      "//trim(real2str(reg(9),4)),"blue")
  call PROCESKDP("GET GPUCY")
  call updateTerminalLog("ANG       "//trim(real2str(reg(9),4)),"blue")
  call updateTerminalLog("ENTRANCE PUPIL", "blue")
  call updateTerminalLog("DIA       "//trim(real2str(curr_par_ray_trace%ENPUPDIA,4)),"blue")
  call updateTerminalLog("THI       "//trim(real2str(curr_par_ray_trace%ENPUPPOS,4)),"blue")
  call updateTerminalLog("EXIT PUPIL", "blue")
  call updateTerminalLog("DIA       "//trim(real2str(curr_par_ray_trace%EXPUPDIA,4)),"blue")
  call updateTerminalLog("THI       "//trim(real2str(curr_par_ray_trace%EXPUPPOS,4)),"blue")
  else
    call updateTerminalLog("FNO       "//trim(real2str(curr_par_ray_trace%EFL / &
    & curr_par_ray_trace%ENPUPDIA,4)),"blue")      
    
    call updateTerminalLog("AT USED CONJUGATES", "blue")

    call updateTerminalLog("RED       "//trim(real2str(-1*curr_par_ray_trace%t_mag,4)),"blue")
    call updateTerminalLog("FNO       "//trim(real2str(curr_par_ray_trace%imageDistance/ &
    & curr_par_ray_trace%EXPUPDIA,4)),"blue")
    call updateTerminalLog("OBJ DIS   "//trim(real2str(curr_par_ray_trace%objectDistance,4)),"blue")
    call updateTerminalLog("TT        "//trim(real2str(curr_par_ray_trace%TT,4)),"blue")
    call updateTerminalLog("IMG DIS   "//trim(real2str(curr_par_ray_trace%imageDistance,4)),"blue")
    call updateTerminalLog("OAL       "//trim(real2str(curr_par_ray_trace%OAL,4)),"blue")
  end if


  !call PROCESKDP("GET GPCY")
  !PRINT *, "GPCY IS ", reg(9)

  !call PROCESKDP("GET GPY")
  !PRINT *, "GPUY IS ", reg(9)

  !call LogTermFOR("Exit Pupil Diameter is "//real2str(curr_par_ray_trace%EXPUPDIA))
  

end subroutine



subroutine EDITOR
  use lens_editor
  use global_widgets
  use handlers, only: my_window

    if (.not. c_associated(lens_editor_window))  THEN
       PRINT *, "Call New Lens Editor Window"
       call lens_editor_new(my_window)
       PRINT *, "Lens editor call finished!"
    else
      PRINT *, "Do nothing..lens editor exists. "

    end if



end subroutine EDITOR

subroutine PTSTUFF
  use type_utils, only: real2str, int2str

  integer :: i
  
  include "DATLEN.INC"
  call LogTermFOR("SYSTEM DUMP")
  do i=1,150
    call LogTermFOR("i="//trim(int2str(i)//" "//real2str(SYSTEM(i))))

  end do

end subroutine

subroutine PLTIMTST

  USE GLOBALS
  use command_utils
  use handlers, only: zoatabMgr, updateTerminalLog
  use global_widgets, only:  sysConfig
  use zoa_ui
  use zoa_plot
  use iso_c_binding, only:  c_ptr, c_null_char
  use plplot, PI => PL_PI
  use plplot_extra


IMPLICIT NONE

character(len=23) :: ffieldstr
character(len=40) :: inputCmd
integer :: ii, i, j, objIdx
integer :: numPoints = 10
logical :: replot


!REAL, allocatable :: x(:), y(:)


    !   xdim is the leading dimension of z, xpts <= xdim is the leading
    !   dimension of z that is defined.
integer, parameter :: xdim=99, ydim=100, xpts=35, ypts=45
real(kind=pl_test_flt)   :: x(xpts*ypts), y(xpts*ypts), z(xpts*ypts)
real(kind=pl_test_flt)   :: xx(xpts*ypts), yy(xpts*ypts), r
real(kind=pl_test_flt)   :: zlimited(xdim,ypts)
integer :: index
integer, parameter :: indexxmin = 1
integer, parameter :: indexxmax = xpts
integer            :: indexymin(xpts), indexymax(xpts)

! parameters of ellipse (in x, y index coordinates) that limits the data.
! x0, y0 correspond to the exact floating point centre of the index
! range.
! Note: using the Fortran convention of starting indices at 1
real(kind=pl_test_flt), parameter :: x0 = 0.5_pl_test_flt * ( xpts + 1 )
real(kind=pl_test_flt), parameter :: a  = 0.9_pl_test_flt * ( x0 - 1.0_pl_test_flt )
real(kind=pl_test_flt), parameter :: y0 = 0.5_pl_test_flt * ( ypts + 1 )
real(kind=pl_test_flt), parameter :: b  = 0.7_pl_test_flt * ( y0 - 1.0_pl_test_flt )
real(kind=pl_test_flt)            :: square_root

character (len=80) :: title(2) = &
       (/'#frPLplot Example 8 - Alt=60, Az=30 ', &
       '#frPLplot Example 8 - Alt=40, Az=-30'/)
real(kind=pl_test_flt)   :: alt(2) = (/60.0_pl_test_flt, 40.0_pl_test_flt/)
real(kind=pl_test_flt)   :: az(2)  = (/30.0_pl_test_flt,-30.0_pl_test_flt/)
integer            :: rosen
integer, parameter :: nlevel = 10
real(kind=pl_test_flt)   :: zmin, zmax, step, clevel(nlevel)

real(kind=pl_test_flt)   :: dx, dy
type(c_ptr) :: canvas
type(zoaPlotImg) :: zpImg 
type(multiplot) :: mplt

INCLUDE 'DATMAI.INC'




!   x(1:xpts) = (arange(xpts) - (xpts-1)/2.0_pl_test_flt) / ((xpts-1)/2.0_pl_test_flt)
!   y(1:ypts) = (arange(ypts) - (ypts-1)/2.0_pl_test_flt) / ((ypts-1)/2.0_pl_test_flt)
!

dx = 2.0_pl_test_flt / (xpts - 1)
dy = 2.0_pl_test_flt / (ypts - 1)

do i = 1,xpts
    x(i) = -1.0_pl_test_flt + (i-1) * dx
enddo

do j = 1,ypts
    y(j) = -1.0_pl_test_flt + (j-1) * dy
enddo

index = 1
do j=1,ypts    
    do i=1,xpts
      xx(index) = x(i)
        yy(index) = y(j)
            ! Sombrero function
            r = sqrt(xx(index)**2 + yy(index)**2)
            z(index) = exp(-r**2) * cos(2.0_pl_test_flt*PI*r)
            index = index+1
    enddo
enddo
print *, "index is ", index


 !call checkCommandInput(ID_CMD_ALPHA)

 call updateTerminalLog(INPUT, "blue")
 inputCmd = INPUT

if(cmdOptionExists('NUMPTS')) then
 numPoints = INT(getCmdInputValue('NUMPTS'))
end if


PRINT *, "numPoints is ", numPoints
canvas = hl_gtk_drawing_area_new(size=[600,600], &
& has_alpha=FALSE)

call mplt%initialize(canvas, 1,1)
!print *, "x in PLT3DTST is ", real(x)

!  call zp3d%init3d(c_null_ptr, real(xx),real(yy), real(z), xpts, ypts, &
!  & xlabel='Surface No'//c_null_char, ylabel='w'//c_null_char, &
!  & title='Plot3dTst'//c_null_char)

 call zpImg%init3d(c_null_ptr, real(xx),real(yy), real(z), xpts, ypts, &
 & xlabel='No, an amplitude clipped sombrero'//c_null_char, ylabel=''//c_null_char, &
 & title='Saturn?'//c_null_char)
 !PRINT *, "Bar chart color code is ", bar1%dataColorCode

 call mplt%set(1,1,zpImg)



replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_PLT3DTST, objIdx)

if (replot) then
 PRINT *, "Input Command was ", inputCmd
 call zoatabMgr%updateInputCommand(objIdx, inputCmd)

 call zoatabMgr%updateGenericMultiPlotTab(objIdx, mplt)

else


 objIdx = zoatabMgr%addGenericMultiPlotTab(ID_PLOTTYPE_PLT3DTST, "3D Plot Test"//c_null_char, mplt)

 ! Add settings

 zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd

 ! Create Plot + settings tab
 call zoaTabMgr%finalizeNewPlotTab(objIdx)


end if



end subroutine

subroutine PLT3DTST

  USE GLOBALS
  use command_utils
  use handlers, only: zoatabMgr, updateTerminalLog
  use global_widgets, only:  sysConfig
  use zoa_ui
  use zoa_plot
  use iso_c_binding, only:  c_ptr, c_null_char
  use plplot, PI => PL_PI
  use plplot_extra


IMPLICIT NONE

character(len=23) :: ffieldstr
character(len=40) :: inputCmd
integer :: ii, i, j, objIdx
integer :: numPoints = 10
logical :: replot


!REAL, allocatable :: x(:), y(:)


    !   xdim is the leading dimension of z, xpts <= xdim is the leading
    !   dimension of z that is defined.
integer, parameter :: xdim=99, ydim=100, xpts=35, ypts=45
real(kind=pl_test_flt)   :: x(xpts*ypts), y(xpts*ypts), z(xpts*ypts)
real(kind=pl_test_flt)   :: xx(xpts*ypts), yy(xpts*ypts), r
real(kind=pl_test_flt)   :: zlimited(xdim,ypts)
integer :: index
integer, parameter :: indexxmin = 1
integer, parameter :: indexxmax = xpts
integer            :: indexymin(xpts), indexymax(xpts)

! parameters of ellipse (in x, y index coordinates) that limits the data.
! x0, y0 correspond to the exact floating point centre of the index
! range.
! Note: using the Fortran convention of starting indices at 1
real(kind=pl_test_flt), parameter :: x0 = 0.5_pl_test_flt * ( xpts + 1 )
real(kind=pl_test_flt), parameter :: a  = 0.9_pl_test_flt * ( x0 - 1.0_pl_test_flt )
real(kind=pl_test_flt), parameter :: y0 = 0.5_pl_test_flt * ( ypts + 1 )
real(kind=pl_test_flt), parameter :: b  = 0.7_pl_test_flt * ( y0 - 1.0_pl_test_flt )
real(kind=pl_test_flt)            :: square_root

character (len=80) :: title(2) = &
       (/'#frPLplot Example 8 - Alt=60, Az=30 ', &
       '#frPLplot Example 8 - Alt=40, Az=-30'/)
real(kind=pl_test_flt)   :: alt(2) = (/60.0_pl_test_flt, 40.0_pl_test_flt/)
real(kind=pl_test_flt)   :: az(2)  = (/30.0_pl_test_flt,-30.0_pl_test_flt/)
integer            :: rosen
integer, parameter :: nlevel = 10
integer :: plparseopts_rc
real(kind=pl_test_flt)   :: zmin, zmax, step, clevel(nlevel)

real(kind=pl_test_flt)   :: dx, dy
type(c_ptr) :: canvas
type(zoaPlot3d) :: zp3d 
type(multiplot) :: mplt

INCLUDE 'DATMAI.INC'

!   Process command-line arguments
plparseopts_rc = plparseopts(PL_PARSE_FULL)
if(plparseopts_rc .ne. 0) stop "plparseopts error"

rosen = 0

!   x(1:xpts) = (arange(xpts) - (xpts-1)/2.0_pl_test_flt) / ((xpts-1)/2.0_pl_test_flt)
!   y(1:ypts) = (arange(ypts) - (ypts-1)/2.0_pl_test_flt) / ((ypts-1)/2.0_pl_test_flt)
!

dx = 2.0_pl_test_flt / (xpts - 1)
dy = 2.0_pl_test_flt / (ypts - 1)

do i = 1,xpts
    x(i) = -1.0_pl_test_flt + (i-1) * dx
enddo

do j = 1,ypts
    y(j) = -1.0_pl_test_flt + (j-1) * dy
enddo

index = 1
do j=1,ypts    
    do i=1,xpts
      xx(index) = x(i)
        yy(index) = y(j)
            ! Sombrero function
            r = sqrt(xx(index)**2 + yy(index)**2)
            z(index) = exp(-r**2) * cos(2.0_pl_test_flt*PI*r)
            index = index+1
    enddo
enddo
print *, "index is ", index


 !call checkCommandInput(ID_CMD_ALPHA)

 call updateTerminalLog(INPUT, "blue")
 inputCmd = INPUT

if(cmdOptionExists('NUMPTS')) then
 numPoints = INT(getCmdInputValue('NUMPTS'))
end if


PRINT *, "numPoints is ", numPoints
canvas = hl_gtk_drawing_area_new(size=[600,600], &
& has_alpha=FALSE)

call mplt%initialize(canvas, 1,1)
!print *, "x in PLT3DTST is ", real(x)

!  call zp3d%init3d(c_null_ptr, real(xx),real(yy), real(z), xpts, ypts, &
!  & xlabel='Surface No'//c_null_char, ylabel='w'//c_null_char, &
!  & title='Plot3dTst'//c_null_char)

 call zp3d%init3d(c_null_ptr, real(xx),real(yy), real(z), xpts, ypts, &
 & xlabel='Surface No'//c_null_char, ylabel='w'//c_null_char, &
 & title='Plot3dTst'//c_null_char)
 !PRINT *, "Bar chart color code is ", bar1%dataColorCode

 call mplt%set(1,1,zp3d)



replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_PLT3DTST, objIdx)

if (replot) then
 PRINT *, "Input Command was ", inputCmd
 call zoatabMgr%updateInputCommand(objIdx, inputCmd)

 call zoatabMgr%updateGenericMultiPlotTab(objIdx, mplt)

else


 objIdx = zoatabMgr%addGenericMultiPlotTab(ID_PLOTTYPE_PLT3DTST, "3D Plot Test"//c_null_char, mplt)

 ! Add settings

 zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd

 ! Create Plot + settings tab
 call zoaTabMgr%finalizeNewPlotTab(objIdx)


end if



end subroutine


! subroutine PLT3DTST

!   USE GLOBALS
!   use command_utils
!   use handlers, only: zoatabMgr, updateTerminalLog
!   use global_widgets, only:  sysConfig
!   use zoa_ui
!   use zoa_plot
!   use iso_c_binding, only:  c_ptr, c_null_char
!   use plplot, PI => PL_PI
!   use plplot_extra


! IMPLICIT NONE

! character(len=23) :: ffieldstr
! character(len=40) :: inputCmd
! integer :: ii, i, j, objIdx
! integer :: numPoints = 10
! logical :: replot


! !REAL, allocatable :: x(:), y(:)


!     !   xdim is the leading dimension of z, xpts <= xdim is the leading
!     !   dimension of z that is defined.
! integer, parameter :: xdim=99, ydim=100, xpts=35, ypts=45
! real(kind=pl_test_flt)   :: x(xpts), y(ypts), z(xpts,ypts), xx, yy, r
! real(kind=pl_test_flt)   :: zlimited(xdim,ypts)
! integer, parameter :: indexxmin = 1
! integer, parameter :: indexxmax = xpts
! integer            :: indexymin(xpts), indexymax(xpts)

! ! parameters of ellipse (in x, y index coordinates) that limits the data.
! ! x0, y0 correspond to the exact floating point centre of the index
! ! range.
! ! Note: using the Fortran convention of starting indices at 1
! real(kind=pl_test_flt), parameter :: x0 = 0.5_pl_test_flt * ( xpts + 1 )
! real(kind=pl_test_flt), parameter :: a  = 0.9_pl_test_flt * ( x0 - 1.0_pl_test_flt )
! real(kind=pl_test_flt), parameter :: y0 = 0.5_pl_test_flt * ( ypts + 1 )
! real(kind=pl_test_flt), parameter :: b  = 0.7_pl_test_flt * ( y0 - 1.0_pl_test_flt )
! real(kind=pl_test_flt)            :: square_root

! character (len=80) :: title(2) = &
!        (/'#frPLplot Example 8 - Alt=60, Az=30 ', &
!        '#frPLplot Example 8 - Alt=40, Az=-30'/)
! real(kind=pl_test_flt)   :: alt(2) = (/60.0_pl_test_flt, 40.0_pl_test_flt/)
! real(kind=pl_test_flt)   :: az(2)  = (/30.0_pl_test_flt,-30.0_pl_test_flt/)
! integer            :: rosen
! integer, parameter :: nlevel = 10
! integer :: plparseopts_rc
! real(kind=pl_test_flt)   :: zmin, zmax, step, clevel(nlevel)

! real(kind=pl_test_flt)   :: dx, dy
! type(c_ptr) :: canvas
! type(zoaPlot3d) :: zp3d 
! type(multiplot) :: mplt

! INCLUDE 'DATMAI.INC'

! !   Process command-line arguments
! plparseopts_rc = plparseopts(PL_PARSE_FULL)
! if(plparseopts_rc .ne. 0) stop "plparseopts error"

! rosen = 0

! !   x(1:xpts) = (arange(xpts) - (xpts-1)/2.0_pl_test_flt) / ((xpts-1)/2.0_pl_test_flt)
! !   y(1:ypts) = (arange(ypts) - (ypts-1)/2.0_pl_test_flt) / ((ypts-1)/2.0_pl_test_flt)
! !

! dx = 2.0_pl_test_flt / (xpts - 1)
! dy = 2.0_pl_test_flt / (ypts - 1)

! do i = 1,xpts
!     x(i) = -1.0_pl_test_flt + (i-1) * dx
! enddo

! do j = 1,ypts
!     y(j) = -1.0_pl_test_flt + (j-1) * dy
! enddo

! do i=1,xpts
!     xx = x(i)
!     do j=1,ypts
!         yy = y(j)
!         if (rosen == 1) then
!             z(i,j) = (1._pl_test_flt - xx)**2 + 100._pl_test_flt*(yy - xx**2)**2

!             ! The log argument may be zero for just the right grid.
!             if (z(i,j) > 0._pl_test_flt) then
!                 z(i,j) = log(z(i,j))
!             else
!                 z(i,j) = -5._pl_test_flt
!             endif
!         else
!             ! Sombrero function
!             r = sqrt(xx**2 + yy**2)
!             z(i,j) = exp(-r**2) * cos(2.0_pl_test_flt*PI*r)
!         endif
!     enddo
! enddo


!  !call checkCommandInput(ID_CMD_ALPHA)

!  call updateTerminalLog(INPUT, "blue")
!  inputCmd = INPUT

! if(cmdOptionExists('NUMPTS')) then
!  numPoints = INT(getCmdInputValue('NUMPTS'))
! end if


! PRINT *, "numPoints is ", numPoints
! canvas = hl_gtk_drawing_area_new(size=[600,600], &
! & has_alpha=FALSE)

! call mplt%initialize(canvas, 1,1)
! print *, "x in PLT3DTST is ", real(x)

!  call zp3d%init3d(c_null_ptr, real(x),real(y), real(z), &
!  & xlabel='Surface No'//c_null_char, ylabel='w'//c_null_char, &
!  & title='Plot3dTst'//c_null_char)
!  !PRINT *, "Bar chart color code is ", bar1%dataColorCode

!  call mplt%set(1,1,zp3d)



! replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_PLT3DTST, objIdx)

! if (replot) then
!  PRINT *, "Input Command was ", inputCmd
!  call zoatabMgr%updateInputCommand(objIdx, inputCmd)

!  call zoatabMgr%updateGenericMultiPlotTab(objIdx, mplt)

! else


!  objIdx = zoatabMgr%addGenericMultiPlotTab(ID_PLOTTYPE_PLT3DTST, "3D Plot Test"//c_null_char, mplt)

!  ! Add settings

!  zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd

!  ! Create Plot + settings tab
!  call zoaTabMgr%finalizeNewPlotTab(objIdx)


! end if



! end subroutine


subroutine MACROUI
  use zoa_macro_ui
  use global_widgets, only: macro_ui_window
  use handlers, only: my_window

  if (.not. c_associated(macro_ui_window))  THEN
    call zoa_macrooperationsUI(my_window)
 else
    call gtk_window_present(macro_ui_window)

 end if 



end subroutine MACROUI


subroutine SYSCONFIGUI
  use ui_sys_config
  use global_widgets
  use handlers, only: my_window

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


subroutine powsym_ideal(surfaceno, w, w_sum, symcalc, s_sum)

  USE GLOBALS
  use command_utils
  use handlers, only: zoatabMgr, updateTerminalLog
  use global_widgets, only:  sysConfig
  use zoa_ui
  use zoa_plot
  use gtk_draw_hl 
  use iso_c_binding, only:  c_ptr, c_null_char


IMPLICIT NONE

real, intent(in) :: w(:), symcalc(:)
real, intent(in) :: w_sum, s_sum
integer, intent(in) ::  surfaceno(:)

character(len=23) :: ffieldstr
character(len=40) :: inputCmd
integer :: ii, objIdx
integer :: numPoints = 10
logical :: replot
type(c_ptr) :: canvas
type(barchart) :: bar1, bar2
type(multiplot) :: mplt
character(len=100) :: strTitle


INCLUDE 'DATMAI.INC'

 !call checkCommandInput(ID_CMD_ALPHA)

 call updateTerminalLog(INPUT, "blue")
 inputCmd = INPUT

 canvas = hl_gtk_drawing_area_new(size=[1200,500], &
 & has_alpha=FALSE)

 WRITE(strTitle, "(A15, F10.3)") "Power:  w = ", w_sum
 call mplt%initialize(canvas, 2,1)

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



replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_POWSYM, objIdx)

if (replot) then
 PRINT *, "POWSYM REPLOT REQUESTED"
 PRINT *, "Input Command was ", inputCmd
 call zoatabMgr%updateInputCommand(objIdx, inputCmd)
 !zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd

 call zoatabMgr%updateGenericMultiPlotTab(objIdx, mplt)

else


  !call mplt%draw()


 objIdx = zoatabMgr%addGenericMultiPlotTab(ID_PLOTTYPE_POWSYM, "Power and Symmetry"//c_null_char, mplt)

 ! Add settings
 PRINT *, "Really before crash?"
 zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd
 PRINT *, "Really after crash?"

 ! Create Plot + settings tab
 call zoaTabMgr%finalizeNewPlotTab(objIdx)


end if

end subroutine

subroutine getOPDData(lambda)
  use iso_fortran_env, only: real64
  implicit none
  ! This is taken from PLOTCAPCO in PLOTCAD4.FOR.  
  integer :: lambda, loopFlag, I, KKV, KKK
  real(kind=real64) :: WVAL
  
  INCLUDE 'DATSP1.INC'
  INCLUDE 'DATSPD.INC'  

  loopFlag = 1

  WVAL=real(lambda)
  KKV=(ITOT-1)/NUMCOL
  do while (loopFlag > 0 )
  DO I=1,ITOT-1
!    LOAD DSPOTT(*,ID) INTO DSPOT(*)
     ID=I
     CALL SPOTIT(4)

     IF(DSPOT(16).EQ.WVAL) THEN
      PRINT *, "Found wavelength data for index ", lambda
      loopFlag = 0
      KKK=NINT(SQRT(FLOAT(KKV)))
      ! Need to define refht before calling this (add to curr_lens_data?)
      !CALL CAPPLOT(1,I,REFHT,WVAL,KKV,KKK,1)
      RETURN      
      !KVAL=I

          END IF

          END DO
        end do

end subroutine


subroutine plot_seidel()

  USE GLOBALS
  use command_utils
  use handlers, only: zoatabMgr, updateTerminalLog
  use global_widgets, only:  sysConfig, curr_lens_data,curr_par_ray_trace
  use zoa_ui
  use zoa_plot
  use gtk_draw_hl 
  use iso_c_binding, only:  c_ptr, c_null_char


IMPLICIT NONE

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


INCLUDE 'DATMAI.INC'

call updateTerminalLog(INPUT, "blue")
inputCmd = INPUT

CALL PROCESKDP('MAB3 ALL')

allocate(seidel(nS,curr_lens_data%num_surfaces+1))
allocate(surfIdx(curr_lens_data%num_surfaces+1))



yLabels(1) = "Spherical"
yLabels(2) = "Coma"
yLabels(3) = "Astigmatism"
yLabels(4) = "Distortion"
yLabels(5) = "Curvature"
yLabels(6) = "Axial Chromatic"
yLabels(7) = "Lateral Chromatic"



graphColors = [PL_PLOT_RED, PL_PLOT_BLUE, PL_PLOT_GREEN, &
& PL_PLOT_MAGENTA, PL_PLOT_CYAN, PL_PLOT_GREY, PL_PLOT_BROWN]



surfIdx =  (/ (ii,ii=0,curr_lens_data%num_surfaces)/)
seidel(:,:) = curr_par_ray_trace%CSeidel(:,0:curr_lens_data%num_surfaces)

PRINT *, "lbound of surfIdx is ", lbound(surfIdx)
PRINT *, "lbound of seidel is ", lbound(seidel,2)
PRINT *, "lbound of CSeidel is ", lbound(curr_par_ray_trace%CSeidel,1)
PRINT *, "lbound of CSeidel is ", lbound(curr_par_ray_trace%CSeidel,2)



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


replot = zoatabMgr%doesPlotExist(ID_PLOTTYPE_SEIDEL, objIdx)

if (replot) then
 PRINT *, "PLTSEI REPLOT REQUESTED"
 PRINT *, "Input Command was ", inputCmd
 call zoatabMgr%updateInputCommand(objIdx, inputCmd)
 !zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd

 call zoatabMgr%updateGenericMultiPlotTab(objIdx, mplt)

else


  !call mplt%draw()


 objIdx = zoatabMgr%addGenericMultiPlotTab(ID_PLOTTYPE_SEIDEL, "Seidel Aberrations"//c_null_char, mplt)

 ! Add settings
 zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd
 

 ! Create Plot + settings tab
 call zoaTabMgr%finalizeNewPlotTab(objIdx)


end if

end subroutine


end module kdp_interfaces
