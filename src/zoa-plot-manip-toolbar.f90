! Eventually this module can hold all relevant info/methods for plot manipulation toolbar
! zoom, shift, etc.  For now I am just prototyping, so will just hold a subset of the total 
! info needed
module zoa_plot_manip_toolbar
    use iso_c_binding
    use gtk
    use gtk_hl_container

    logical :: zoomFlag, shiftFlag
    type(c_ptr) :: controller_c, controller_k, controller_m, plotArea

    integer, parameter :: ID_NONE = 0
    integer, parameter :: ID_ZOOM_IN = 3
    integer, parameter :: ID_ZOOM_OUT = 4
    integer, parameter :: ID_SHIFT = 5
    integer :: toolbarState = ID_NONE

    integer, dimension(2) :: dragStartXY
    logical :: ctrl_pressed = .FALSE.
    contains

    subroutine createPlotManipulationToolbar(cairo_drawing_area,plotBox)
        

        implicit none

        type(c_ptr) :: cairo_drawing_area
        type(c_ptr) :: plotBox ! Output
        type(c_ptr), dimension(6) :: btns
        integer :: i


  
        plotBox = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0_c_int);

        ! Buttons
        ! Reset
        ! Refresh
        ! Zoom In
        ! Zoom Out
        ! Move

        btns(1) = gtk_button_new_from_icon_name ("window-restore-symbolic"//c_null_char)
        btns(2) = gtk_button_new_from_icon_name ("view-refresh-symbolic"//c_null_char)
        btns(3) = gtk_button_new_from_icon_name ("user-home-symbolic"//c_null_char)
        btns(4) = gtk_button_new_from_icon_name ("list-add"//c_null_char)
        btns(5) = gtk_button_new_from_icon_name ("list-remove"//c_null_char)
        btns(6) = gtk_button_new_from_icon_name ("go-previous-symbolic"//c_null_char)
        
        call gtk_widget_set_tooltip_text(btns(1), "Do Nothing"//c_null_char)
        call gtk_widget_set_tooltip_text(btns(2), "Refresh Plot"//c_null_char)
        call gtk_widget_set_tooltip_text(btns(3), "Go back to original plot"//c_null_char)
        call gtk_widget_set_tooltip_text(btns(4), "Zoom In"//c_null_char)
        call gtk_widget_set_tooltip_text(btns(5), "Zoom Out"//c_null_char)
        call gtk_widget_set_tooltip_text(btns(6), "Shift Plot"//c_null_char)

        do i=1,size(btns)
            call gtk_widget_set_valign(btns(i), GTK_ALIGN_START)
            call gtk_button_set_has_frame (btns(i), FALSE)
            call gtk_widget_set_focus_on_click (btns(i), FALSE)
            call hl_gtk_box_pack (plotBox, btns(i))
            call gtk_widget_set_has_tooltip(btns(i), 1_c_int)


        end do
        
       ! What I really wanted is to keep the button clicked until a mouse action is 
       ! complete, but this is not supported.  If there was a toggle button with an icon
       ! that would work, but that doesn't exist.  I found this site that suggested
       ! adding a motion event controller to the icon (child of button) can implement this.
       ! so TODO:  try this out and see if it meets my needs
       ! link:  https://discourse.gnome.org/t/gtk-button-signals-pressed-released/10367/6
       ! pseudo code:
       ! child = gtk_button_get_child(btnWidget)
       ! gesture = gtk_gesture_click_new
       ! g_signal_connect(gesture, "pressed" or "released" or "stopped", or clicked") 
       ! gtk_widget_add_controller(child, gesture) 



        plotArea = cairo_drawing_area
        call g_signal_connect(btns(1), 'clicked'//c_null_char, c_funloc(set_Nothing), cairo_drawing_area)
        call g_signal_connect(btns(2), 'clicked'//c_null_char, c_funloc(refreshPlot), cairo_drawing_area)
        call g_signal_connect(btns(3), 'clicked'//c_null_char, c_funloc(set_autoScale), cairo_drawing_area)
        call g_signal_connect(btns(4), 'clicked'//c_null_char, c_funloc(set_zoomIn), cairo_drawing_area)
        call g_signal_connect(btns(5), 'clicked'//c_null_char, c_funloc(set_zoomOut), cairo_drawing_area)              
        call g_signal_connect(btns(6), 'clicked'//c_null_char, c_funloc(set_plotShift), cairo_drawing_area)
        PRINT *, "cairo in createPlotToolbar", LOC(cairo_drawing_area)   

       controller_c = gtk_gesture_click_new()
       ! 0 to listen to all buttons (button 1 by default):
       call gtk_gesture_single_set_button (controller_c, 0_c_int)
        call g_signal_connect(controller_c, "pressed"//c_null_char, &
        & c_funloc(lensDrawDragBegin), c_null_ptr)  
        call g_signal_connect(controller_c, "released"//c_null_char, &
        & c_funloc(lensDrawDragEnd), c_null_ptr)      
       
        ! Key press controller for plot zoon
        controller_k = gtk_event_controller_key_new()
        !call g_signal_connect(controller_k, "im-update"//c_null_char, &
        !           & c_funloc(im_update_event_h), c_null_ptr)        
        !call g_signal_connect(controller_k2, "key-pressed"//c_null_char, &
        !           & c_funloc(plot_key_event_press), c_null_ptr) 
        call g_signal_connect(controller_k, "key-pressed"//c_null_char, &
                   & c_funloc(tmp_key_event_h), c_null_ptr)                    
        call g_signal_connect(controller_k, "key-released"//c_null_char, &
                   & c_funloc(plot_key_event_released), c_null_ptr)                      
                   
        call gtk_widget_set_focusable(cairo_drawing_area, 1_c_int)
        call gtk_widget_add_controller(cairo_drawing_area, controller_k)           
        
        call gtk_widget_add_controller(cairo_drawing_area, controller_c) 
        
        controller_m = gtk_event_controller_motion_new ()

          call g_signal_connect(controller_m, "motion"//c_null_char, &
                              & c_funloc(tmp_motion_event), c_null_ptr)

  
        call gtk_widget_add_controller(cairo_drawing_area, controller_m)   




        
    end subroutine

  subroutine set_autoScale(widget, event, cairo_drawing_area) bind(c)
      use mod_plotopticalsystem, only: ld_settings, ID_LENSDRAW_AUTOSCALE
      implicit none
      type(c_ptr), value :: widget, event, cairo_drawing_area
      INTEGER VIEXOF,VIEYOF, VIEROT
  
      COMMON/OFFVIE/VIEXOF,VIEYOF,VIEROT
     
      toolbarState = ID_NONE
      ld_settings%autoScale = ID_LENSDRAW_AUTOSCALE
      VIEXOF = 0
      VIEYOF = 0
      call ld_settings%replot()
      
  end subroutine

    subroutine refreshPlot(widget, event, cairo_drawing_area) bind(c)
      use mod_plotopticalsystem, only: ld_settings
      implicit none
      type(c_ptr), value :: widget, event, cairo_drawing_area
     
      toolbarState = ID_NONE
      !TODO:  Add a call to update lens data
      call ld_settings%replot()
      
  end subroutine

   subroutine set_Nothing(widget, event, cairo_drawing_area) bind(c)
      use gdk, only: gdk_cursor_new_from_name
      implicit none
      type(c_ptr), value :: widget, event, cairo_drawing_area
     
      toolbarState = ID_NONE
      call gtk_widget_set_cursor_from_name(plotArea, "default"//c_null_char)
  end subroutine

    subroutine set_zoomIn(widget, event, cairo_drawing_area) bind(c)
      use gdk, only: gdk_cursor_new_from_name
      implicit none
      type(c_ptr), value :: widget, event, cairo_drawing_area
     
      toolbarState = ID_ZOOM_IN
      call gtk_widget_set_cursor_from_name(plotArea, "zoom-in"//c_null_char)
  end subroutine

  subroutine set_zoomOut(widget, event, cairo_drawing_area) bind(c)
    use gdk, only: gdk_cursor_new_from_name
    implicit none
    type(c_ptr), value :: widget, event, cairo_drawing_area
   
    toolbarState = ID_ZOOM_IN
    call gtk_widget_set_cursor_from_name(plotArea, "zoom-out"//c_null_char)
end subroutine

    subroutine set_plotShift(widget, event, cairo_drawing_area) bind(c)
        !use zoa_plot_manip_toolbar
        use gdk, only: gdk_cursor_new_from_name
        implicit none
        type(c_ptr), value :: widget, event, cairo_drawing_area
       
        toolbarState = ID_SHIFT
        call gtk_widget_set_cursor_from_name(plotArea, "move"//c_null_char)
        !cursor = gdk_cursor_new_from_name("move"//c_null_char, c_null_ptr)
        !call gtk_widget_set_cursor(cairo_drawing_area, cursor)

    end subroutine

    subroutine set_plotZoom(widget, event, gdata) bind(c)
        !use zoa_plot_manip_toolbar
        implicit none
        type(c_ptr), value, intent(in) :: widget, event, gdata
      
        zoomFlag = .true.
        shiftFlag = .false.
      
      end subroutine
subroutine lensDrawDragBegin(gesture, n_press, x, y, gdata) bind(c)
  use type_utils, only: int2str
  type(c_ptr), value, intent(in)    :: gesture, gdata
  integer(c_int), value, intent(in) :: n_press
  real(c_double), value, intent(in) :: x, y
  type(c_ptr) :: device, dcname
  character(len=80) :: dname

  print *, "Button ", gtk_gesture_single_get_current_button(gesture)
  print *, n_press, " click(s) at ", int(x), int(y)
  call LogTermFOR("Begin Pos "//int2str(INT(x))//" "//int2str(INT(y)))
  dragStartXY(1) = INT(x)
  dragStartXY(2) = INT(y)

  if (n_press > 1) then
    print *, "Multiple clicks"
  end if



  !device = gtk_event_controller_get_current_event_device(gesture)
  !dcname = gdk_device_get_name(device)
  !call c_f_string(dcname, dname)
  !print *, "Device: ",trim(dname)(widget, event, gdata) bind(c)
end subroutine

  ! use type_utils, only: int2str
  !   type(c_ptr), value, intent(in) :: widget, event, gdata
  !   type(c_ptr) :: xptr, yptr
  !   integer :: result
  !   real(c_double), pointer :: x, y
  !   call LogTermFOR("Begin Event Detected!!")
  !   result = gtk_gesture_get_point(controller_c, c_null_ptr, xptr, yptr)
  !   !call LogTermFOR("Begin Pos "//int2str(INT(x))//" "//int2str(INT(y)))


  ! end subroutine  
subroutine lensDrawDragEnd(gesture, n_press, x, y, gdata) bind(c)
  !use zoa_plot_manip_toolbar
  use mod_plotopticalsystem, only: ld_settings, ID_LENSDRAW_MANUALSCALE
  use type_utils, only: int2str
  type(c_ptr), value, intent(in)    :: gesture, gdata
  integer(c_int), value, intent(in) :: n_press
  integer(c_int) :: height, width
  real(c_double), value, intent(in) :: x, y
  real :: zoomFactor
  type(c_ptr) :: device, dcname
  character(len=80) :: dname
  INTEGER VIEXOF,VIEYOF, VIEROT
  
   COMMON/OFFVIE/VIEXOF,VIEYOF,VIEROT

  print *, "Button ", gtk_gesture_single_get_current_button(gesture)
  print *, n_press, " click(s) at ", int(x), int(y)
  call LogTermFOR("End Pos "//int2str(INT(x))//" "//int2str(INT(y)))
  call LogTermFOR("Shift is "//int2str(INT(x)-dragStartXY(1))//" "// &
  & int2str(INT(y)-dragStartXY(2)))

  select case(toolbarState)

  case(ID_SHIFT)
      ! Update offsets
    VIEXOF = VIEXOF - 10*(INT(x)-dragStartXY(1))
    VIEYOF = VIEYOF - 10*(INT(y)-dragStartXY(2))
  case(ID_ZOOM_IN)
    call LogTermFOR("Zoom in even detected!")
    height = gtk_drawing_area_get_content_height(plotArea)
    width  = gtk_drawing_area_get_content_width(plotArea)
    VIEXOF = VIEXOF - 1.5*(INT(x)-width/2.0)
    VIEYOF = VIEYOF - 1.5*(INT(y)-height/2.0)
    call LogTermFOR("X Offset is "//int2str(INT(VIEXOF)))
    call LogTermFOR("Y Offset is "//int2str(INT(VIEYOF)))

    ld_settings%autoScale = ID_LENSDRAW_MANUALSCALE
    ! Hard code a 20% change
    ld_settings%scaleFactor = 1.20*ld_settings%scaleFactor
  case(ID_ZOOM_OUT)
    height = gtk_drawing_area_get_content_height(plotArea)
    width  = gtk_drawing_area_get_content_width(plotArea)
    VIEXOF = VIEXOF - 1.5*(INT(x)-width/2.0)
    VIEYOF = VIEYOF - 1.5*(INT(y)-height/2.0)
    call LogTermFOR("X Offset is "//int2str(INT(VIEXOF)))
    call LogTermFOR("Y Offset is "//int2str(INT(VIEYOF)))

    ld_settings%autoScale = ID_LENSDRAW_MANUALSCALE
    ! Hard code a 20% change
    ld_settings%scaleFactor = .8*ld_settings%scaleFactor

  end select


  ! if (zoomFlag) then 
  !   call logTermFOR("Zoom True!")
  !   zoomFactor = 0.5*(( x-dragStartXY(1))+(y-dragStartXY(2)) )
  !   zoomFactor = 700.0/zoomFactor
  !   call LogTermFOR("ZoomFactor is "//int2str(INT(zoomFactor)))
  !   call LogTermFOR("New ScaleFactor is "//int2str(INT(ld_settings%scaleFactor*zoomFactor)))
  !   ld_settings%autoScale = ID_LENSDRAW_MANUALSCALE
  !   ld_settings%scaleFactor = ld_settings%scaleFactor*zoomFactor


  !   ! Compute new zoom.  try to get average of x and y in pixels compared to total window

  ! else

  ! end if


  call ld_settings%replot()







  if (n_press > 1) then
    print *, "Multiple clicks"
  end if

  !device = gtk_event_controller_get_current_event_device(gesture)
  !dcname = gdk_device_get_name(device)
  !call c_f_string(dcname, dname)
  !print *, "Device: ",trim(dname)(widget, event, gdata) bind(c)
end subroutine
! (widget, event, gdata) bind(c)
!     type(c_ptr), value, intent(in) :: widget, event, gdata
!     call LogTermFOR("End Event Detected!!")

!   end subroutine

function tmp_key_event_h(controller, keyval, keycode, state, gdata) result(ret) bind(c)
  type(c_ptr), value, intent(in) :: controller, gdata
  integer(c_int), value, intent(in) :: keyval, keycode, state
  logical(c_bool) :: ret
  character(len=20) :: keyname
  integer(c_int) :: key_q

  call logtermFOR("Key Press Event Detected!")

  ! call convert_c_string(gdk_keyval_name(keyval), keyname)
  ! print *, "Keyval: ",keyval," Name: ", trim(keyname), "      Keycode: ", &
  !          & keycode, " Modifier: ", state

  ! key_q = gdk_keyval_from_name("q"//c_null_char)
  ! ! CTRL+Q will close the program:
  ! if ((iand(state, GDK_CONTROL_MASK) /= 0).and.(keyval == key_q)) then
  !   call gtk_window_destroy(my_window)
  ! end if

  ret = .true.
end function 

function plot_key_event_press(controller, keyval, keycode, state, gdata) result(ret) bind(c)

  use gdk, only: gdk_device_get_name, gdk_keyval_from_name, gdk_keyval_name
  use gtk, only: gtk_window_set_child, gtk_window_destroy, &
     & gtk_widget_queue_draw, gtk_widget_show, gtk_init, TRUE, FALSE, &
     & GDK_CONTROL_MASK, &
     & CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL, &
     & gtk_event_controller_get_current_event_device, &
     & gtk_gesture_single_get_current_button
  type(c_ptr), value, intent(in) :: controller, gdata
  integer(c_int), value, intent(in) :: keyval, keycode, state
  logical(c_bool) :: ret
  character(len=20) :: keyname
  integer(kind=c_int) :: key_ctrl
  integer(kind=c_int) :: result

  call logtermFOR("Key Press Event Detected!")

  call convert_c_string(gdk_keyval_name(keyval), keyname)
  !print *, "Keyval: ",keyval," Name: ", trim(keyname), "      Keycode: ", &
  !         & keycode, " Modifier: ", state

  key_ctrl = gdk_keyval_from_name("Ctrl"//c_null_char)
  

  if (keyval == key_ctrl) then
    ctrl_pressed = .true.
    call LogTermFOR("Ctrl pressed!")
  end if

  ret = .true.

end function

function plot_key_event_released(controller, keyval, keycode, state, gdata) result(ret) bind(c)

  use gdk, only: gdk_device_get_name, gdk_keyval_from_name, gdk_keyval_name
  use gtk, only: gtk_window_set_child, gtk_window_destroy, &
     & gtk_widget_queue_draw, gtk_widget_show, gtk_init, TRUE, FALSE, &
     & GDK_CONTROL_MASK, &
     & CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL, &
     & gtk_event_controller_get_current_event_device, &
     & gtk_gesture_single_get_current_button
  type(c_ptr), value, intent(in) :: controller, gdata
  integer(c_int), value, intent(in) :: keyval, keycode, state
  logical(c_bool) :: ret
  character(len=20) :: keyname
  integer(kind=c_int) :: key_ctrl
  integer(kind=c_int) :: result

  call convert_c_string(gdk_keyval_name(keyval), keyname)
  !print *, "Keyval: ",keyval," Name: ", trim(keyname), "      Keycode: ", &
  !         & keycode, " Modifier: ", state

  key_ctrl = gdk_keyval_from_name("Ctrl"//c_null_char)
  

  if (keyval == key_ctrl) then
    ctrl_pressed = .false.
    call LogTermFOR("Ctrl released!")
  end if

  ret = .true.

end function
subroutine tmp_motion_event(controller, x, y, gdata) bind(c)
  type(c_ptr), value, intent(in)    :: controller, gdata
  real(c_double), value, intent(in) :: x, y

  write(*, "(2I5,A)", advance='no') nint(x), nint(y), c_carriage_return
end subroutine 
 !subroutine im_update_event_h(controller, gdata) bind(c)
 ! type(c_ptr), value, intent(in)    :: controller, gdata
 ! print *, "im_update event detected"
 !end subroutine       

end module