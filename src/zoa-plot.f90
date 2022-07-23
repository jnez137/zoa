!Module for bar chart plotting
module zoa_plot
    use collections
    use, intrinsic :: iso_c_binding, only: c_ptr, c_char, c_int, c_float, c_null_char

    !use handlers

   !use global_widgets
   use plplot
   use plplot_extra
   use gtk_draw_hl
    use cairo, only: cairo_get_target, cairo_image_surface_get_height, &
       & cairo_image_surface_get_width

   implicit none

   type(list) :: m_data
   ! Constants for plotting
   integer, parameter :: PL_PLOT_BLACK = 15
   integer, parameter :: PL_PLOT_RED = 2
   integer, parameter :: PL_PLOT_YELLOW = 2
   integer, parameter :: PL_PLOT_GREEN = 3
   integer, parameter :: PL_PLOT_AQUAMARINE = 9
   integer, parameter :: PL_PLOT_PINK = 5
   integer, parameter :: PL_PLOT_WHEAT = 6
   integer, parameter :: PL_PLOT_GREY = 7
   integer, parameter :: PL_PLOT_BROWN = 8
   integer, parameter :: PL_PLOT_BLUE = 4
   integer, parameter :: PL_PLOT_BLUEVIOLET = 10
   integer, parameter :: PL_PLOT_CYAN = 11
   integer, parameter :: PL_PLOT_TURQUOISE = 12
   integer, parameter :: PL_PLOT_MAGENTA = 13
   integer, parameter :: PL_PLOT_SALMON = 14
   integer, parameter :: PL_PLOT_WHITE = 0

type :: zoaplot

    type(c_ptr) :: area

    real, allocatable ::  x(:), y(:)
    character(len=100) :: title = 'untitled'
    character(len=100) :: xlabel = ' x '
    character(len=100) :: ylabel = ' y '
    character(len=20)  :: labelFontColor = "BLACK"
    !character(len=20)  :: labelDataColor = "BLACK"
    integer :: dataColorCode = 0 !  See PL_PLOT paramaters for decoding

contains
    !procedure, public :: initialize

    procedure, public, pass(self) :: drawPlot
    procedure, public, pass(self) :: setLabelFont
    procedure, private, pass(self) :: getAxesLimits
    procedure, private, pass(self) :: getLabelFontCode
    procedure, public, pass(self) :: setDataColorCode

end type

type, extends(zoaplot) :: barchart

    !integer, allocatable :: surface(:)

    !character(kind=plchar_vector) :: title, xlabel, ylabel
    character(len=12) :: xPlotCode
    !character(len=100) :: ylabel
    !character(len=100) :: title = 'untitled'
    !character(len=100) :: xlabel = 'x'
    !character(len=100) :: ylabel = 'y'
contains

    procedure, public :: initialize => bc_init
    procedure, public :: drawPlot => bc_drawPlot

    !procedure, private :: barChartBox


end type barchart

  type, extends(zoaplot) :: multiplot
        !> The collection of plot objects.
        type(list) :: m_plots
        !> The number of rows of plots.
        integer :: m_rows = 0
        !> The number of columns of plots.
        integer :: m_cols = 0
        !> The page title.
        character(len = 100) :: m_title
        !> Has a title?
        logical :: m_hasTitle = .false.
        !> The BNUPLOT terminal object to target.
        !class(terminal), pointer :: m_terminal => null()
    contains
        !final :: mp_clean

        procedure, public :: initialize => mp_init
        !procedure, public :: get_row_count => mp_get_rows
        !procedure, public :: get_column_count => mp_get_cols
        !procedure, public :: get_plot_count => mp_get_count
        !procedure, public :: get_title => mp_get_title
        !procedure, public :: set_title => mp_set_title
        procedure, public :: draw => mp_draw
        procedure, public :: get => mp_get
        procedure, public :: set => mp_set

        !procedure, public :: is_title_defined => mp_has_title
        !procedure, public :: get_font_name => mp_get_font
        !procedure, public :: set_font_name => mp_set_font
        !procedure, public :: get_font_size => mp_get_font_size
        !procedure, public :: set_font_size => mp_set_font_size
    end type



! interface zoaplot
!     module procedure :: initialize
! end interface zoaplot

contains
!
! Candidate for submodule for multiplot
    subroutine mp_init(self, area, m, n)
        class(multiplot), intent(inout) :: self
        type(c_ptr), intent(in) :: area
        integer, intent(in) :: m,n
        integer :: i
        !real, allocatable :: xin(:), yin(:)
        !integer :: arraysize

        ! TODO - Move this to common function
        !arraysize = size(xin)

        !allocate(self%x(arraysize))
        !allocate(self%y(arraysize))

        self%area = area

        self%m_rows = m
        self%m_cols = n

        do i = 1, m * n
            call self%m_plots%push(i)
        end do

    end subroutine


    subroutine mp_set(self, i, j, plotter)
        ! Arguments
        class(multiplot), intent(inout) :: self
        integer, intent(in) :: i, j
        class(zoaplot), intent(in) :: plotter

        ! Local Variables
        integer :: ind

        PRINT *, "REACHED MP_SET!"

        ! Process
        ind = self%m_rows * (j - 1) + i
        call self%m_plots%set(ind, plotter)
    end subroutine

    function mp_get(self,i,j) result(plotter)
        ! Arguments

        class(multiplot), intent(in) :: self
        integer, intent(in) :: i, j
        class(zoaplot), pointer :: plotter

        ! Local Variables
        class(*), pointer :: item
        integer :: ind

        ! Process
        ind = self%m_rows * (j - 1) + i
        item => self%m_plots%get(ind)
        select type (item)
        class is (zoaplot)
            plotter => item
        class default
            nullify(plotter)
        end select

    end function

    subroutine mp_draw(self)

        class(multiplot), intent(in) :: self

        type(c_ptr)  :: cc, cs
        character(len=20) :: string
        character(len=25) :: geometry
        integer :: m, n
        integer :: plparseopts_rc
        integer :: plsetopt_rc
        class(zoaplot), pointer :: plotter




        ! Define colour map 0 to match the "GRAFFER" colour table in
        ! place of the PLPLOT default.
        ! Note that cmap(0) is the background and is white here.
        ! TODO : put this in zoaplot, and map the parameter labels to these values
        integer, parameter, dimension(16) :: rval = (/255, 0, 255, &
             & 0, 0, 0, 255, 255, 255, 127, 0, 0, 127, 255, 85, 170/),&
             & gval = (/ 255, 0, 0, 255, 0, 255, 0, 255, 127, 255, 255, 127,&
             & 0, 0, 85, 170/), &
             & bval = (/ 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 127, 255, 255,&
             & 127, 85, 170/)

        PRINT *, "Starting mp_plot routine"
        cc = hl_gtk_drawing_area_cairo_new(self%area)
        cs = cairo_get_target(cc)

        !  Initialize plplot
        call plscmap0(rval, gval, bval)

        !call plscolbg(1,1,1)
        call plsdev("extcairo")

        ! By default the "extcairo" driver does not reset the background
        ! This is equivalent to the command line option "-drvopt set_background=1"
        plsetopt_rc = plsetopt("drvopt", "set_background=1")
        if (plsetopt_rc .ne. 0) stop "plsetopt error"

    !      Process command-line arguments
    !plparseopts(PL_PARSE_FULL)
    !if(plparseopts_rc .ne. 0) stop "plparseopts error"

        !      Load color palettes
        !call plspal0('cmap0_white_bg.pal')

        ! The "extcairo" device doesn't read the size from the context.
        write(geometry, "(I0,'x',I0)") cairo_image_surface_get_width(cs), &
             & cairo_image_surface_get_height(cs)
        plsetopt_rc = plsetopt( 'geometry', geometry)
        if (plsetopt_rc .ne. 0) stop "plsetopt error"

        !call plinit()
        !  Divide page into 2x2 plots
        call plstar(self%m_rows,self%m_cols)

        call pl_cmd(PLESC_DEVINIT, cc)

        !call pladv(0)

        !call plvsta
        !call plcol0(15)

        do m=1, self%m_rows
          do n=1, self%m_cols
            call pladv(0)


            !Selects the largest viewport within the subpage that leaves a
            !standard margin (left-hand margin of eight character heights,
            !and a margin around the other three sides of five character heights).
            call plvsta
            plotter => self%get(m,n)
            PRINT *, "Starting to Draw Plot from Plotter"
            call plotter%drawPlot


          end do
        end do





        !    Don't forget to call PLEND to finish off!
        call plend
        call hl_gtk_drawing_area_cairo_destroy(cc)

        end subroutine


!! Canidate for dubmodule for zoaplot
    subroutine bc_init(self, area, x, y, xlabel, ylabel, title)
      !import zoa_plot
      class(barchart), intent(inout) :: self
      type(c_ptr), intent(in) :: area
      real ::  x(:), y(:)
      character(len=100), optional :: xlabel, ylabel, title
      integer :: arraysize

      arraysize = size(x)

      !allocate(self%x(arraysize))
      !allocate(self%y(arraysize))
      PRINT *, "ARRAY SIZE IS ", arraysize


      self%area = area
      self%x = x
      self%y = y

      !self % title = trim("untitled")
      !self % xlabel = trim("           x axis")

      !self % ylabel = "y axis"

      self % labelFontColor = trim("BLACK")
      self % dataColorCode = PL_PLOT_RED

    if (present(title)) then
       self%title = title
    else
       self%title = 'untitled'
    end if


    if (present(xlabel)) then
       self%xlabel = xlabel
    else
       self%xlabel = 'x'
    end if

    if (present(ylabel)) then
       self%ylabel = ylabel
    else
       self%ylabel = 'y'
    end if

  end subroutine

  subroutine bc_drawPlot(self)
    class(barchart), intent(in) :: self
    integer :: i
    real(kind=pl_test_flt) :: xmin, xmax, ymin, ymax




            call getAxesLimits(self, xmin, xmax, ymin, ymax)
            call plwind(xmin, xmax, ymin, ymax)
            call plbox( 'bcgnt', 0._pl_test_flt, 0, 'bcgntv', 0._pl_test_flt, 0 )
            call plcol0(getLabelFontCode(self))
            call pllab( trim(self%xlabel)//c_null_char, trim(self%ylabel)//c_null_char, trim(self%title)//c_null_char)
            !call plscmap1l(.true.,pos,red,green,blue)

            do i = 1, size(self%x)
                !       call plcol0(i + 1)
                !call plcol1(real(i,kind=pl_test_flt)/9.0_pl_test_flt)
                call plcol0(self%dataColorCode)
                !PRINT *, "Data Color Code is ", self%dataColorCode
                !call plcol1(real(1,kind=pl_test_flt))
                !call plcol1(1.0_pl_test_fit)
                call plpsty(0)
                !call plfbox( 1980._pl_test_flt+i, y(i+1) )
                call barChartBox(self%x(i), self%y(i) )
          enddo



  end subroutine


    subroutine drawPlot(self)
        class(zoaplot), intent(in) :: self

    type(c_ptr)  :: cc, cs
    character(len=20) :: string
    character(len=25) :: geometry
    integer :: i
    integer :: plparseopts_rc
    integer :: plsetopt_rc

    real(kind=pl_test_flt) :: xmin, xmax, ymin, ymax

    real(kind=pl_test_flt) :: y0(10)
    real(kind=pl_test_flt) :: pos(5)   = (/0.0_pl_test_flt, 0.25_pl_test_flt, 0.5_pl_test_flt, 0.75_pl_test_flt, 1.0_pl_test_flt/)
    real(kind=pl_test_flt) :: red(5)   = (/0.0_pl_test_flt, 0.25_pl_test_flt, 0.5_pl_test_flt, 1.0_pl_test_flt, 1.0_pl_test_flt/)
    real(kind=pl_test_flt) :: green(5) = (/1.0_pl_test_flt, 0.5_pl_test_flt, 0.5_pl_test_flt, 0.5_pl_test_flt, 1.0_pl_test_flt/)
    real(kind=pl_test_flt) :: blue(5)  = (/1.0_pl_test_flt, 1.0_pl_test_flt, 0.5_pl_test_flt, 0.25_pl_test_flt, 0.0_pl_test_flt/)

    ! Define colour map 0 to match the "GRAFFER" colour table in
    ! place of the PLPLOT default.
    integer, parameter, dimension(16) :: rval = (/255, 0, 255, &
         & 0, 0, 0, 255, 255, 255, 127, 0, 0, 127, 255, 85, 170/),&
         & gval = (/ 255, 0, 0, 255, 0, 255, 0, 255, 127, 255, 255, 127,&
         & 0, 0, 85, 170/), &
         & bval = (/ 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 127, 255, 255,&
         & 127, 85, 170/)


    cc = hl_gtk_drawing_area_cairo_new(self%area)
    cs = cairo_get_target(cc)

    !  Initialize plplot
    call plscmap0(rval, gval, bval)
    call plsdev("extcairo")

    ! By default the "extcairo" driver does not reset the background
    ! This is equivalent to the command line option "-drvopt set_background=1"
    plsetopt_rc = plsetopt("drvopt", "set_background=1")
    if (plsetopt_rc .ne. 0) stop "plsetopt error"

    ! The "extcairo" device doesn't read the size from the context.
    write(geometry, "(I0,'x',I0)") cairo_image_surface_get_width(cs), &
         & cairo_image_surface_get_height(cs)
    plsetopt_rc = plsetopt( 'geometry', geometry)
    if (plsetopt_rc .ne. 0) stop "plsetopt error"

    call plinit()

    call pl_cmd(PLESC_DEVINIT, cc)

    call pladv(0)
    call plvsta
    !call plwind( 1980._pl_test_flt, 1990._pl_test_flt, -15._pl_test_flt, 40._pl_test_flt )
    call getAxesLimits(self, xmin, xmax, ymin, ymax)

    !call plwind( -1._pl_test_flt, 11._pl_test_flt, -15._pl_test_flt, 40._pl_test_flt )
    call plwind(xmin, xmax, ymin, ymax)
    call plbox( 'bcgnt', 1._pl_test_flt, 0, 'bcgntv', 0._pl_test_flt, 0 )
    !call plbox( 'bcgnt', 1._pl_test_flt, 0, 'bnstv', 0._pl_test_flt, 0 )

    !call plbox('bcfghlnst', 0.0_plflt, 0, 'bcghnstv', 0.0_plflt, 0)
    !call plcol0(1)
    call plcol0(getLabelFontCode(self))
    !call pllab( 'Surface', 'Y Position [mm]', '#frPLplot Example 12' )
    !call pllab( 'Surface', trim('Y Position [mm]')//c_null_char, '#frPLplot Example 12' )
    call pllab( trim(self%xlabel)//c_null_char, trim(self%ylabel)//c_null_char, trim(self%title)//c_null_char)


    y0 = (/ 5, 15, 12, 24, 28, 30, 20, 8, 12, 3 /)

    call plscmap1l(.true.,pos,red,green,blue)

    do i = 1, size(self%x)
        !       call plcol0(i + 1)
        !call plcol1(real(i,kind=pl_test_flt)/9.0_pl_test_flt)
        call plcol0(2)
        !call plcol1(real(1,kind=pl_test_flt))
        !call plcol1(1.0_pl_test_fit)
        call plpsty(0)
        !call plfbox( 1980._pl_test_flt+i, y(i+1) )
        call barChartBox(self%x(i), self%y(i) )
        !write (string, '(i0)') int(y0(i))

        !call plptex( x(i+1), y(i+1), &
        !       1._pl_test_flt, 0._pl_test_flt, 0.5_pl_test_flt, string )
        !call plptex( 1980._pl_test_flt+i+0.5_pl_test_flt, y0(i+1)+1._pl_test_flt, &
        !       1._pl_test_flt, 0._pl_test_flt, 0.5_pl_test_flt, string )

        !write (string, '(i0)')1980+i
        !call plmtex( 'b', 1._pl_test_flt, (i+1)*0.1_pl_test_flt-0.05_pl_test_flt, 0.5_pl_test_flt, string )
    enddo

    !    Don't forget to call PLEND to finish off!
    call plend
    call hl_gtk_drawing_area_cairo_destroy(cc)

    end subroutine drawPlot

    subroutine setLabelFont(self, desiredColor)

    class(zoaplot), intent(inout) :: self
    character(len=20), intent(in) :: desiredColor

    !if trim(desiredColor) == "RED"
    self % labelFontColor = trim(desiredColor)

    end subroutine setLabelFont

    subroutine setDataColorCode(self, code)
      class(zoaplot), intent(inout) :: self
      integer, intent(in) :: code
      self%dataColorCode = code
    end subroutine

    function getLabelFontCode(self) result(r)

       ! Currently this function does not work correctly
       ! The string in labelFontColor is not being stored
       ! correctly

       class(zoaplot), intent(in) :: self
       integer :: r

       r = 1

       if (trim(self % labelFontColor) == trim("BLACK")) then
           r = 1
       else if (trim(self % labelFontColor) == trim("RED")) then
           r = 2
       end if
       print *, "labelFontColor ", trim(self%labelFontColor)
    end function getLabelFontCode

    subroutine getAxesLimits(self, xmin, xmax, ymin, ymax)

    class(zoaplot), intent(in) :: self
    real(kind=pl_test_flt), intent(inout) :: xmin, xmax, ymin, ymax

    xmin = minval(self%x)
    xmax = maxval(self%x)
    ymin = minval(self%y)
    ymax = maxval(self%y)

    end subroutine getAxesLimits

    subroutine barChartBox(x0, y0)
        !real(kind=pl_test_flt) x0, y0, x(4), y(4)
        real :: x0, y0, x(4), y(4)



        x(1) = x0
        y(1) = 0._pl_test_flt
        x(2) = x0
        y(2) = y0
        !x(3) = x0+1._pl_test_flt
        x(3) = x0+.5_pl_test_flt
        y(3) = y0
        !x(4) = x0+1._pl_test_flt
        x(4) = x0+.5_pl_test_flt
        y(4) = 0._pl_test_flt
        call plfill(x, y)
        call plcol0(1)
        call pllsty(1)
        call plline(x, y)
    end subroutine barChartBox

end module zoa_plot
