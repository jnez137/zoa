SUBROUTINE WDRAWOPTICALSYSTEM

  !subroutine my_draw_function(widget, my_cairo_context, width, height, gdata) bind(c)

       USE GLOBALS
       use global_widgets
       use handlers
       use zoa_ui

       !USE WINTERACTER
       IMPLICIT NONE





       LOGICAL FIRST
       INTEGER NCOL256,ID,IDRAW1,ISKEY,INFO,IWX,IWY,IX,IY, NEUTTOTAL

    !type(c_ptr), value, intent(in) :: widget
    character(len=256), dimension(:), allocatable :: new_files, tmp
    logical, pointer :: idelete
    integer(kind=c_int) :: ipick, i



       !PRINT *, "After Mod Call, ", my_window
       !PRINT *, "NEUTARRAY is ", NEUTARRAY

       FIRST=.TRUE.
       ISKEY=-999
       READ(NEUTARRAY(1),1000) NEUTTOTAL
 1000  FORMAT(I9,32X)
       PRINT *, "NEUTTOTAL IS ", NEUTTOTAL
       IF(NEUTTOTAL.EQ.0) GO TO 10
!     INITIALIZE SCREEN
!     IDRAW1 IS THE WINDOW HANDLE
!     DRW IS THE STRUCTURE WHICH PASSES CHILD WINDOW CHARACTERISTICS
!     TO THE WINDOW
      !CALL WindowOpenChild(DRW,IDRAW1)
      ! Define black and white, and set the color to black

      !CALL IGRPALETTERGB(223,0,0,0)
      !CALL IGRPALETTERGB(0,255,255,255)
      !CALL IGrColourN(223)
    PRINT *, "Active Plot is ", active_plot
    call zoatabMgr%newPlotIfNeeded(active_plot)
  !
  !   select case (active_plot)
  !   case (ID_NEWPLOT_LENSDRAW)
  !     call zoatabMgr%newPlotIfNeeded(ID_NEWPLOT_LENSDRAW)
  !   ! Only support one window at present.
  !   ! if (.not. c_associated(ld_window))  THEN
  !   !     PRINT *, "Call New Lens Draw Window"
  !   !     call lens_draw_new(my_window)
  !   ! else
  !   !   PRINT *, "Redraw Lens System"
  !   !    !call lens_draw_replot()
  !   !    call gtk_widget_queue_draw(ld_cairo_drawing_area)
  !   ! end if
  !
  ! case (ID_NEWPLOT_RAYFAN)
  !   PRINT *, "ABOUT TO CHECK IF WE NEED RAYFAN PLOT"
  !   call zoatabMgr%newPlotIfNeeded(ID_NEWPLOT_RAYFAN)
  !   ! Only support one window at present.
  !   ! PRINT *, "RAY FAN Plotting Initiated!"
  !   ! !call ray_fan_plot_check_status()
  !   ! if (.not. c_associated(rf_window))  THEN
  !   !    PRINT *, "Call New Ray Fan Window"
  !   !    call ray_fan_new(my_window)
  !   ! else
  !   !   PRINT *, "Redraw Ray Fan "
  !   !   !call rf_settings%replot()
  !   !   call gtk_widget_queue_draw(rf_cairo_drawing_area)
  !   ! end if
  !   ! PRINT *, "READY TO PLOT!"
  !
  !  case (ID_PLOTTYPE_AST)
  !
  !   ! Only support one window at present.
  !   PRINT *, "AST Plotting Initiated!"
  !   call zoatabMgr%newPlotIfNeeded(ID_PLOTTYPE_AST)
  !   !call ray_fan_plot_check_status()
  !   !if (.not. c_associated(ast_window))  THEN
  !   !   PRINT *, "Call New Ast"
  !   !   call ast_fc_dist_new(my_window)
  !   !else
  !   !  PRINT *, "Redraw Astig "
  !     !call ast_settings%replot()
  !   !  PRINT *, "PTR is ", ast_cairo_drawing_area
  !   !  call plot_ast_fc_dist(ast_cairo_drawing_area)
  !     !call gtk_widget_queue_draw(ast_cairo_drawing_area)
  !   !end if
  !   !PRINT *, "READY TO PLOT!"
  ! end select

10 CONTINUE

                        END
