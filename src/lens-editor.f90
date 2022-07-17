module lens_editor


  use GLOBALS
  use global_widgets
  use cairo
!  use gth_hl
  use gtk_hl_container
  use gtk_hl_progress
  use gtk_hl_button
  use gtk_hl_tree
  use gtk

  use gtk_hl_chooser

  use g
  use zoa_ui
  !use mod_lens_editor_settings

  implicit none


  type(c_ptr) :: ihscrollcontain,ihlist, &
       &  qbut, dbut, lbl


contains


  subroutine lens_editor_destroy(widget, gdata) bind(c)

    type(c_ptr), value :: widget, gdata
    type(c_ptr) :: isurface
    print *, "Exit called"


    !call cairo_destroy(rf_cairo_drawing_area)
    !call gtk_widget_unparent(gdata)
    !call g_object_unref(rf_cairo_drawing_area)
    call gtk_window_destroy(widget)

    lens_editor_window = c_null_ptr

  end subroutine lens_editor_destroy



subroutine callback_lens_editor_settings (widget, gdata ) bind(c)
   use iso_c_binding
   use hl_gtk_zoa
   use zoa_ui
   implicit none
   type(c_ptr), value, intent(in) :: widget, gdata
   integer :: int_value

  integer(kind=c_int), pointer :: ID_SETTING

  call c_f_pointer(gdata, ID_SETTING)

  PRINT *, "Integer Passed is ", ID_SETTING

  PRINT *, "Pointer Passed is ", gdata


   !if (rf_settings%changed.eq.1) THEN
  !    rf_settings%changed = 0
  !    call lens_editor_replot()

   !end if

end subroutine callback_lens_editor_settings

  subroutine lens_editor_settings_dialog(box1)

    use hl_gtk_zoa
    use, intrinsic :: iso_c_binding, only: c_ptr, c_funloc, c_null_char
    implicit none

    type(c_ptr), intent(inout) :: box1

    character(len=35) :: line
    integer(kind=c_int) :: i, ltr, j
    integer(kind=type_kind), dimension(6) :: ctypes
    character(len=20), dimension(6) :: titles
    integer(kind=c_int), dimension(6) :: sortable, editable

    PRINT *, "LENS EDITOR DIALOG SUB STARTING!"
    ! Now make a multi column list with multiple selections enabled
    ctypes = (/ G_TYPE_INT, G_TYPE_FLOAT, G_TYPE_FLOAT, G_TYPE_STRING, &
         & G_TYPE_FLOAT, G_TYPE_FLOAT /)
    !ctypes = (/ G_TYPE_STRING, G_TYPE_INT, G_TYPE_INT, G_TYPE_FLOAT, &
    !     & G_TYPE_UINT64, G_TYPE_BOOLEAN /)
    sortable = (/ FALSE, FALSE, FALSE, FALSE, FALSE, FALSE /)
    editable = (/ FALSE, TRUE, TRUE, FALSE, FALSE, FALSE /)

    titles(1) = "Surface"
    titles(2) = "Radius"
    titles(3) = "Thickness"
    titles(4) = "Glass"
    titles(5) = "Index"
    titles(6) = "Abbe"

    ihlist = hl_gtk_tree_new(ihscrollcontain, types=ctypes, &
         & changed=c_funloc(list_select),&
         &  multiple=TRUE, height=250_c_int, swidth=400_c_int, titles=titles, &
         & sortable=sortable, editable=editable)

    PRINT *, "ihlist created!  ", ihlist

    ! Now put 10 top level rows into it
     do i=1,curr_lens_data%num_surfaces
        call hl_gtk_tree_ins(ihlist, row = (/ -1_c_int /))
    !    write(line,"('List entry number ',I0)") i
    !    ltr=len_trim(line)+1
    !    line(ltr:ltr)=c_null_char
        call hl_gtk_tree_set_cell(ihlist, absrow=i-1_c_int, col=0_c_int, &
             & ivalue=(i-1))
        call hl_gtk_tree_set_cell(ihlist, absrow=i-1_c_int, col=1_c_int, &
             & fvalue=curr_lens_data%radii(i))
        call hl_gtk_tree_set_cell(ihlist, absrow=i-1_c_int, col=2_c_int, &
             & fvalue=curr_lens_data%thicknesses(i))
        call hl_gtk_tree_set_cell(ihlist, absrow=i-1_c_int, col=3_c_int, &
             & svalue=curr_lens_data%glassnames(i))
        call hl_gtk_tree_set_cell(ihlist, absrow=i-1_c_int, col=4_c_int, &
             & fvalue=curr_lens_data%surf_index(i))
        call hl_gtk_tree_set_cell(ihlist, absrow=i-1_c_int, col=5_c_int, &
             & fvalue=curr_lens_data%surf_vnum(i))
     end do

    ! Add some child rows
    ! do j = 2, 6, 2
    !    call hl_gtk_tree_ins(ihlist, row = (/ j, -1_c_int /), count=5)
    !    do i = 1, 5
    !       write(line,"('List entry number',I0,':',I0)") j+1,i
    !       ltr=len_trim(line)+1
    !       line(ltr:ltr)=c_null_char
    !       call hl_gtk_tree_set_cell(ihlist, row=(/ j, i-1_c_int/), col=0_c_int, &
    !            & svalue=line)
    !       call hl_gtk_tree_set_cell(ihlist, row=(/ j, i-1_c_int/), col=1_c_int, &
    !            & ivalue=i)
    !       call hl_gtk_tree_set_cell(ihlist, row=(/ j, i-1_c_int/), col=2_c_int, &
    !            & ivalue=3_c_int*i)
    !       call hl_gtk_tree_set_cell(ihlist, row=(/ j, i-1_c_int/), col=3_c_int, &
    !            & fvalue=log10(real(i)))
    !       call hl_gtk_tree_set_cell(ihlist, row=(/ j, i-1_c_int/), col=4_c_int, &
    !            & l64value=int(i,c_int64_t)**4)
    !       call hl_gtk_tree_set_cell(ihlist, row=(/ j, i-1_c_int/), col=5_c_int, &
    !            & ivalue=mod(i,2_c_int))
    !    end do
    ! end do

    box1 = hl_gtk_box_new()
    ! It is the scrollcontainer that is placed into the box.
    call hl_gtk_box_pack(box1, ihscrollcontain)

    PRINT *, "PACKING FIRST CONTAINER!"

    ! Add a note about editable columns
    lbl = gtk_label_new("The ""Name"" and ""3N"" columns are editable"&
         & //c_null_char)
    call hl_gtk_box_pack(box1, lbl)

    ! Delete selected row
    dbut = hl_gtk_button_new("Delete selected row"//c_null_char, &
         & clicked=c_funloc(del_row), &
         & tooltip="Delete the selected row"//c_null_char, sensitive=FALSE)

    call hl_gtk_box_pack(box1, dbut)

    ! Also a quit button
    qbut = hl_gtk_button_new("Quit"//c_null_char, clicked=c_funloc(lens_editor_destroy))
    call hl_gtk_box_pack(box1,qbut)

    PRINT *, "END OF LENS EDITOR DIALOG SUB"

  end subroutine lens_editor_settings_dialog


  subroutine lens_editor_new(parent_window)

    type(c_ptr) :: parent_window
    !type(c_ptr), value :: lens_editor_window

    type(c_ptr) :: content, junk, gfilter
    integer(kind=c_int) :: icreate, idir, action, lval
    integer(kind=c_int) :: i, idx0, idx1
    !type(c_ptr)     :: my_drawing_area
    !integer(c_int)  :: width, height

    type(c_ptr)     :: table, expander, box1

    PRINT *, "ABOUT TO FIRE UP LENS EDITOR WINDOW!"

    ! Create a modal dialogue
    lens_editor_window = gtk_window_new()

        PRINT *, "LENS EDITOR WINDOW PTR IS ", lens_editor_window

    !call gtk_window_set_modal(di, TRUE)
    !title = "Lens Draw Window"
    !if (present(title)) call gtk_window_set_title(dialog, title)
    call gtk_window_set_title(lens_editor_window, "Lens Editor Window"//c_null_char)
    !if (present(wsize)) then
    !   call gtk_window_set_default_size(dialog, wsize(1),&
    !        & wsize(2))
    !else

    width = 1000
    height = 700
       call gtk_window_set_default_size(lens_editor_window, width, height)
    !end if

    !if (present(parent)) then
       call gtk_window_set_transient_for(lens_editor_window, parent_window)
       call gtk_window_set_destroy_with_parent(lens_editor_window, TRUE)
    !end if


    call lens_editor_settings_dialog(box1)


    PRINT *, "FINISHED WITH LENS EDITOR"
    !call gtk_box_append(box1, rf_cairo_drawing_area)
    !call gtk_window_set_child(lens_editor_window, rf_cairo_drawing_area)
    call gtk_window_set_child(lens_editor_window, box1)
    call gtk_widget_set_vexpand (box1, FALSE)

    call g_signal_connect(lens_editor_window, "destroy"//c_null_char, c_funloc(lens_editor_destroy), lens_editor_window)


    call gtk_window_set_mnemonics_visible (lens_editor_window, TRUE)
    !call gtk_widget_queue_draw(my_drawing_area)
    call gtk_widget_show(lens_editor_window)


    PRINT *, "SHOULD SEE GRAPHICS NOW!"
end subroutine lens_editor_new

subroutine lens_editor_replot

  character PART1*5, PART2*5, AJ*3, A6*3, AW1*23, AW2*23
  character(len=100) :: ftext

!

end subroutine lens_editor_replot

 subroutine del_row(but, gdata) bind(c)
    type(c_ptr), value, intent(in) :: but, gdata
    integer(kind=c_int), dimension(:,:), allocatable :: selections
    integer(kind=c_int), dimension(:), allocatable :: dep
    integer(kind=c_int) :: nsel

    nsel = hl_gtk_tree_get_selections(ihlist, selections, &
         & depths=dep)

    if (nsel /= 1) then
       print *, "Not a single selection"
       return
    end if

    call hl_gtk_tree_rem(ihlist, selections(:dep(1),1))

    call gtk_widget_set_sensitive(but, FALSE)
  end subroutine del_row

  subroutine list_select(list, gdata) bind(c)
    type(c_ptr), value, intent(in) :: list, gdata
    integer(kind=c_int) :: nsel
    integer(kind=c_int), dimension(:,:), allocatable :: selections
    integer(kind=c_int), dimension(:), allocatable :: dep
    integer(kind=c_int) :: n, n3
    integer(kind=c_int64_t) :: n4
    real(kind=c_float) :: nlog
    character(len=30) :: name
    character(len=10) :: nodd
    integer :: i
    nsel = hl_gtk_tree_get_selections(C_NULL_PTR, selections, selection=list, &
         & depths=dep)
    if (nsel == 0) then
       print *, "No selection"
       return
    end if

    ! Find and print the selected row(s)
    print *, nsel,"Rows selected"
    print *, "Depths", dep
    print *, "Rows"
    do i = 1, nsel
       print *, selections(:dep(i),i)
    end do

    if (nsel == 1) then
       call hl_gtk_tree_get_cell(ihlist, selections(:dep(1),1), 0_c_int, &
            & ivalue=n)
       ! call hl_gtk_tree_get_cell(ihlist, selections(:dep(1),1), 1_c_int, &
       !      & ivalue=n)
       ! call hl_gtk_tree_get_cell(ihlist, selections(:dep(1),1), 2_c_int, &
       !      & ivalue=n3)
       ! call hl_gtk_tree_get_cell(ihlist, selections(:dep(1),1), 4_c_int, &
       !      & l64value=n4)
       ! call hl_gtk_tree_get_cell(ihlist, selections(:dep(1),1), 3_c_int, &
       !      & fvalue=nlog)
       ! call hl_gtk_tree_get_cell(ihlist, selections(:dep(1),1), 5_c_int,&
       !      & svalue=nodd)
      print *, "first column is , ", n
       ! print "('Name: ',a,' N:',I3,' 3N:',I4,' N**4:',I7,&
       !      &' log(n):',F7.5,' Odd?: ',a)", trim(name), &
       !      & n, n3, n4, nlog, nodd
       call gtk_widget_set_sensitive(dbut, TRUE)
    else
       call gtk_widget_set_sensitive(dbut, FALSE)
    end if

    deallocate(selections)
  end subroutine list_select

end module lens_editor