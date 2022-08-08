program fortrants
    use brain_mod
    use world_mod
    use colony_mod
    use world_io_mod
    use time_evo_mod
    implicit none

    ! Simulation parameters
    integer, parameter :: n_ants = 500
    class(Colony_t), allocatable :: colony
    integer :: frames_to_save = 0, frame_save_interval, t_to_next_save
    logical :: stop_after_save = .false.
    ! Command line parameters
    character(len=1024) :: world_path
    character(len=1024) :: output_path
    ! World
    class(World_t), allocatable :: world

    call signal(10, set_dump)
    call random_seed()
    ! Get cli params
    call get_command_argument(1, world_path)
    call get_command_argument(2, output_path)
    ! Initialize ants and world
    call colony_init(colony, n_ants)
    call read_world(world, world_path)
    call setup(world, colony)

    do while(.true.)
        if (frames_to_save > 0 .and. t_to_next_save == 0) then
            call dump_colony(world, colony, output_path)
            frames_to_save = frames_to_save - 1
            if (frames_to_save > 0) then
                t_to_next_save = frame_save_interval
            endif
        endif
        if (frames_to_save == 0 .and. stop_after_save) then
            print *, "Stopping..."
            call sleep(1)
            continue
        endif
        call timestep(world, colony)
        t_to_next_save = t_to_next_save - 1
    end do

    call cleanup()

contains

    subroutine cleanup()
        deallocate(colony)
        deallocate(world)
    end subroutine cleanup

    subroutine set_dump()
        integer :: save_duration, foo
        open(file="/simu-req/request", action='read', newunit=foo)
        read(foo, *) save_duration, frames_to_save, stop_after_save
        close(foo)
        frames_to_save = min(frames_to_save, 500)
        frame_save_interval = nint(real(save_duration) / real(frames_to_save))
        t_to_next_save = frame_save_interval
    end subroutine set_dump

end program fortrants
