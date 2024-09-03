! These subs are mainly to avoid circular dependencies.
! This means the design is bad, but a more elegant solution has not been found
! or invested in yet.

! This method should eventually go somewhere else IMO, but for not have it here
subroutine close_zoaTab()
  ! being specific in imports here because had some compiler errors during a clean
  ! build when I just used import handlers.  Never confirmed root cause, but suspect
  ! there was some isuse where I was importing handlers but it imported zoa_tab
  ! where the interface for this method was being defined
  use iso_c_binding
  use handlers, only: zoatabMgr
  use gtk, only:  gtk_notebook_get_nth_page, gtk_notebook_get_current_page, gtk_widget_get_name
  use gtk_sup, only: convert_c_string


  implicit none

  integer(kind=c_int) :: currPageIndex
  type(c_ptr) :: currPage
   character(len=50)  :: choice
 type(c_ptr)  :: cstr
 integer :: tabInfoToDelete

  PRINT *, "Button clicked!"
  !PRINT *, "Test of accessing zoa tab manager ", zoatabMgr%tabNum
  currPageIndex = gtk_notebook_get_current_page(zoatabMgr%notebook)
  currPage = gtk_notebook_get_nth_page(zoatabMgr%notebook, currPageIndex)

  !val = c_loc(result)
  cstr =  gtk_widget_get_name(currPage)

  !cstr = g_value_get_string(val)
  call convert_c_string(cstr, choice)

 !PRINT *, "CHOICE is ", choice
 read(choice(1:3), '(I3)') tabInfoToDelete
 !PRINT *, "After int conversion, ", tabInfoToDelete

 ! Close Tab
 call zoatabMgr%removePlotTab(currPageIndex, tabInfoToDelete)

end subroutine

function getTabPlotCommand(objIdx) result(outStr)
  use handlers, only: zoatabMgr
  integer :: objIdx
  character(len=1040) :: outStr
  
  outStr = zoatabMgr%tabInfo(objIdx)%tabObj%psm%generatePlotCommand()
  !outStr = zoatabMgr%tabInfo(objIdx)%tabObj%plotCommand

end function

function getTabPlotCommandValue(objIdx, SETTING_CODE) result(realVal)
  use handlers, only: zoatabMgr
  integer, intent(in) :: objIdx, SETTING_CODE
  real :: realVal

  realVal = zoatabMgr%tabInfo(objIdx)%tabObj%psm%getSettingValueByCode(SETTING_CODE)

end function

function getSettingUIType(tabIdx, setting_code) result(uitype)
  use handlers, only: zoatabMgr
  use plot_setting_manager, only: zoaplot_setting_manager, UITYPE_SPINBUTTON

  implicit none
  integer :: uitype
  integer :: tabIdx
  integer :: setting_code
  integer :: i
  type(zoaplot_setting_manager) :: psm

   
  ! Just for readability
  uitype = -1 ! Default
  psm = zoatabMgr%tabInfo(tabIdx)%tabObj%psm  
  do i=1,psm%numSettings
    if (psm%ps(i)%ID == setting_code) then
        uitype = psm%ps(i)%uitype
        return
      end if
  end do

end function

function isSpinButtonInput(tabIdx, setting_code) result(boolResult)
  use handlers, only: zoatabMgr
  use plot_setting_manager, only: zoaplot_setting_manager, UITYPE_SPINBUTTON

  implicit none
  logical :: boolResult
  integer :: tabIdx
  integer :: setting_code
  integer :: i
  type(zoaplot_setting_manager) :: psm

  boolResult = .FALSE.  
  ! Just for readability
  psm = zoatabMgr%tabInfo(tabIdx)%tabObj%psm  
  do i=1,psm%numSettings
    if (psm%ps(i)%ID == setting_code) then
      if (psm%ps(i)%uitype == UITYPE_SPINBUTTON) then
        call LogTermFOR("Found SpinButton Type")
        boolResult = .TRUE.
        return
      end if
    end if
  end do

end function

function updateTabPlotCommand(tabIdx, setting_code, value) result (boolResult)
  use handlers, only: zoatabMgr
  use plot_setting_manager, only: zoaplot_setting_manager, updateWavelengthSetting
  use type_utils, only: int2str
  
  logical :: boolResult
  integer :: tabIdx
  integer :: setting_code
  class(*) :: value
  !double precision :: value
  integer :: i

  type(zoaplot_setting_manager) :: psm

  boolResult = .FALSE.

  !call LogTermFOR("In UPdatePlotCommand")

  ! Just for readability
  psm = zoatabMgr%tabInfo(tabIdx)%tabObj%psm

  !call LogTermFOR("NumZsetings is "//int2str(psm%numSettings))
  do i=1,psm%numSettings
  !call LogTermFOR("ID is "//int2str(psm%ps(i)%ID))
  !call LogTermFOR("Code is "//int2str(setting_code))    
    if (psm%ps(i)%ID == setting_code) then
      !TODO:  Add a way to send index to update setting since we are finding it twice
      ! the way this is written
      call zoatabMgr%tabInfo(tabIdx)%tabObj%psm%updateSetting(setting_code,value)
      boolResult = .TRUE.
      return 
    end if
  end do


end function


function getNumberOfTabs() result(numTabs)
  use handlers, only: zoatabMgr
  integer :: numTabs

  numTabs = zoatabMgr%tabNum

end function

function getTabName(tabNum) result(strName)
  use handlers, only: zoatabMgr
  character(len=100) :: strName
  integer :: tabNum

  strName = zoatabMgr%getTabTitle(tabNum)
end function

function isDocked(tabNum) result(boolResult)
  use handlers, only: zoatabMgr
  logical :: boolResult
  integer :: tabNum

  boolResult = .TRUE.

end function

subroutine updateMenuBar()
  use handlers, only: my_window
  use zoamenubar
  
  call populatezoamenubar(my_window)
  

  !call populateWindowMenu(my_window)

end subroutine


subroutine undock_Window(act, param, gdata) bind(c)
  use iso_c_binding
  use type_utils
  use handlers, only: zoatabMgr
  use gtk
  use zoa_tab
  implicit none
  type(c_ptr), value, intent(in) :: act, param, gdata
  !integer(kind=c_int), pointer :: tabNum
  integer(kind=c_int) :: tabNum

  type(c_ptr) :: pagetomove, childtomove

  type(c_ptr) :: newwin, newnotebook, box2, newpage
  type(c_ptr) :: newlabel, gesture, source, dropTarget
  integer :: newtab
  
  type(zoatab) :: tstTab


  tabNum = 0



 ! call c_f_pointer(gdata, tabNum)



  call LogTermDebug("TabNum is "//int2str(tabNum))

  !child = gtk_notebook_get_nth_page(zoatabMgr%notebook, tabNum)
  pagetomove = gtk_notebook_get_nth_page(zoatabMgr%notebook, tabNum)
  childtomove = gtk_notebook_page_get_child(pagetomove)
  newlabel = gtk_notebook_get_tab_label(zoatabMgr%notebook, pagetomove)
  
  call gtk_notebook_remove_page(zoatabMgr%notebook, tabNum)
  !call gtk_notebook_detach_tab(zoatabMgr%notebook, pagetomove)
  

  !Rebuild page

 ! call gtk_box_append(self%box1, self%canvas)


  

  newpage = gtk_scrolled_window_new()
  !call gtk_scrolled_window_set_child(newpage, zoatabMgr%tabInfo(tabNum)%tabObj%box1)


  !call gtk_notebook_detach_tab(zoatabMgr%notebook, child)
  PRINT *, "Child is ", LOC(pagetomove)
  PRINT *, "notebook is ", LOC(zoatabMgr%notebook)

  newwin = gtk_window_new()

  call gtk_window_set_default_size(newwin, 1300, 700)

  call gtk_window_set_destroy_with_parent(newwin, TRUE)
  box2 = gtk_box_new (GTK_ORIENTATION_VERTICAL, 0_c_int);
  newnotebook = gtk_notebook_new()
  call gtk_widget_set_vexpand (newnotebook, TRUE)
 

  !call hl_gtk_scrolled_window_add(newwin, newnotebook)

  call gtk_notebook_set_group_name(newnotebook,"0"//c_null_char)

 call gtk_scrolled_window_set_child(newpage, pagetomove)
  newTab = gtk_notebook_append_page(newnotebook, pagetomove, gtk_label_new("Testing"//c_null_char))  
  call gtk_notebook_set_current_page(newnotebook, newtab)
  print *, "NEw tab is ", newtab


!   select type(tstTab => zoatabMgr%tabInfo(tabNum)%tabObj)
!   type is (zoaplottab)
!   type is (zoaplotdatatab)
!   call LogTermDebug("In zoaplotdatatab")
!   !newtab = gtk_notebook_append_page(newnotebook, tstTab%dataNotebook, &
!   !& tstTab%tab_label)
!   !newTab = gtk_notebook_append_page(newnotebook,gtk_notebook_get_nth_page(zoatabMgr%notebook, tabNum), &
!   !& newlabel)




! end select

  !newtab = gtk_notebook_append_page(newnotebook, zoatabMgr%tabInfo(tabNum)%tabObj%dataNotebook, &
  !& zoatabMgr%tabInfo(tabNum)%tabObj%tab_label)

  !newtab = gtk_notebook_append_page(newnotebook, newpage,  zoatabMgr%tabInfo(tabNum)%tabObj%tab_label)
  

  call gtk_box_append(box2, newnotebook)

  

  call gtk_window_set_child(newwin, box2)


  call gtk_widget_queue_draw(newnotebook)

  !call gtk_window_set_child(my_window, newwin)


  !call gtk_window_set_child(newwin, widget)

  call gtk_widget_set_vexpand (box2, TRUE)

  print *, "AFter crash?"

  !call gtk_widget_show(newwin)


  call gtk_window_present(newwin)

end subroutine

!For docking/undocking




subroutine dock_Window(act, param, gdata) bind(c)
  use iso_c_binding
  implicit none
  type(c_ptr), value, intent(in) :: act, param, gdata

end subroutine  

! subroutine undock_Window
!   implicit none
!   type(c_ptr), value :: widget, parent_notebook
!   type(c_ptr) :: newwin, newnotebook, box2, scrolled_win
!   type(c_ptr) :: child, newlabel, gesture, source, dropTarget
!   integer :: newtab
!   !PRINT *, "Detach Event Called!"

!   !PRINT *, "widget is ", widget
!   !PRINT *, "Parent Window is ", parent_notebook

!   newwin = gtk_window_new()

!   call gtk_window_set_default_size(newwin, 1300, 700)

!   !call gtk_window_set_transient_for(newwin, my_window)
!   call gtk_window_set_destroy_with_parent(newwin, TRUE)
!   box2 = gtk_box_new (GTK_ORIENTATION_VERTICAL, 0_c_int);
!   newnotebook = gtk_notebook_new()
!   call gtk_widget_set_vexpand (newnotebook, TRUE)
!   !# handler for dropping outside of current window
!   !call hl_gtk_scrolled_window_add(newwin, newnotebook)

!   call gtk_notebook_set_group_name(newnotebook,"0"//c_null_char)
!   child = gtk_notebook_get_nth_page(parent_notebook, -1_c_int)
!   !newlabel = gtk_notebook_get_tab_label(parent_notebook, widget)
!   call gtk_notebook_detach_tab(parent_notebook, child)
!   scrolled_win = gtk_scrolled_window_new()
!   call gtk_scrolled_window_set_child(scrolled_win, child)

!   !newtab = gtk_notebook_append_page(newnotebook, widget, newlabel)
!   newtab = gtk_notebook_append_page(newnotebook, scrolled_win, newlabel)
!   call gtk_notebook_set_tab_detachable(newnotebook, scrolled_win, TRUE)
!   call gtk_box_append(box2, newnotebook)

!   call gtk_window_set_child(newwin, box2)

!   !call gtk_window_set_child(my_window, newwin)


!   !call gtk_window_set_child(newwin, widget)

!   call gtk_widget_set_vexpand (box2, TRUE)


!   !call gtk_widget_show(newwin)
!   !call gtk_widget_show(parent_notebook)
!   !call pending_events()
!   call gtk_window_present(newwin)

!   source = gtk_drag_source_new ()
!   call gtk_drag_source_set_actions (source, GDK_ACTION_MOVE);
!   call g_signal_connect (source, "prepare"//c_null_char, c_funloc(drag_prepare), scrolled_win);
!   !call g_signal_connect (source, "drag-begin"//c_null_char, c_funloc(drag_end), child);        
!   call g_signal_connect (source, "drag-end"//c_null_char, c_funloc(drag_end), child)
!   call gtk_widget_add_controller (newnotebook, source);

!   dropTarget = gtk_drop_target_new(gtk_widget_get_type(), GDK_ACTION_MOVE)
!   call g_signal_connect(dropTarget, "drop", c_funloc(on_drop), c_null_ptr)
!   call g_signal_connect(dropTarget, "motion", c_funloc(on_motion), c_null_ptr)

!   call gtk_widget_add_controller(newnotebook, dropTarget)
!   call gtk_widget_add_controller(gtk_widget_get_parent(newnotebook), dropTarget)




!   gesture = gtk_gesture_click_new ()
!   call g_signal_connect (gesture, "released", c_funloc(click_done), child);
  
!   call gtk_widget_add_controller (child, gesture);       

!   PRINT *, "Modal ? ", gtk_window_get_modal(newwin)
! end subroutine

! For docking/undocking


! subroutine registerPlotSettingManager(tabMgr, objIdx, psm)
!   use zoa_tab_manager, only: zoatabManager
!   use plot_setting_manager, only: zoaplot_setting_manager
!   integer :: objIdx
!   type(zoatabManager) :: tabMgr
!   type(zoaplot_setting_manager) :: psm



  
! end subroutine


! subroutine finalize_with_psm(self, objIdx, inputCmd)
!   use plot_setting_manager
!   use handlers, only: zoaTabMgr
!   use iso_c_binding, only: c_null_char
!   use type_utils, only: int2str
!   implicit none

!   character(len=*) :: inputCmd
!   integer :: objIdx
!   integer :: i
!   class(zoaplot_setting_manager) :: self


!   zoaTabMgr%tabInfo(objIdx)%tabObj%plotCommand = inputCmd
!   do i=1,self%numSettings

!   select case (self%ps(i)%uitype)

!   case(UITYPE_SPINBUTTON)
!   call zoaTabMgr%tabInfo(objIdx)%tabObj%addSpinButton_runCommand_new( & 
!   & trim(int2str(self%ps(i)%ID)), self%ps(i)%default, self%ps(i)%min, self%ps(i)%max, 1, &
!   & trim(self%ps(i)%prefix))
!   !"Number of Field Points", &
!   !& 10.0, 1.0, 20.0, 1, "NUMPTS"//c_null_char)
!   !call zoaTabMgr%tabInfo(objIdx)%tabObj%addSpinButton_runCommand("Test2", 1.0, 0.0, 10.0, 1, "")

!   case(UITYPE_ENTRY)
!   call zoaTabMgr%tabInfo(objIdx)%tabObj%addEntry_runCommand( &
!   & self%ps(i)%label, self%ps(i)%defaultStr, trim(self%ps(i)%prefix))   

!   end select 
!   end do

!   ! This is going to have circular dependences even with an interface?
!   call registerPlotSettingManager(zoatabMgr, objIdx, self)
! end subroutine